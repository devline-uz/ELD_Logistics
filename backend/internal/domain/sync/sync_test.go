//go:build integration

// Integration coverage of the offline sync protocol: push idempotency, the five
// conflict rules, the batch ceilings, the server side duty checks, the daily
// log totals, the pull cursor, the driver scope and cross-tenant isolation
// (404/403, never a leak).
package sync_test

import (
	"encoding/json"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/duty"
	syncmod "github.com/devline/onebook-eld/internal/domain/sync"
	"github.com/devline/onebook-eld/internal/domain/sync/dto"
	"github.com/devline/onebook-eld/internal/domain/telemetry"
	syncrules "github.com/devline/onebook-eld/internal/sync"
	"github.com/devline/onebook-eld/internal/testutil"
)

// now is the fixed server instant every case is measured against.
var now = time.Date(2026, 9, 6, 18, 0, 0, 0, time.UTC)

// allPerms is every permission the two modules gate on.
var allPerms = []string{core.PermLogsRead, core.PermLogsAddEvent}

func nowFn() time.Time { return now }

func newServer(t testing.TB) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	dutyMod := duty.New(duty.Deps{
		Repo:     duty.NewRepo(pool, nil),
		Verifier: testutil.ContextVerifier(),
		Now:      nowFn,
	})
	syncMod := syncmod.New(syncmod.Deps{
		Repo:      syncmod.NewRepo(pool),
		Duty:      dutyMod.Service(),
		Telemetry: telemetry.New(telemetry.Deps{Repo: telemetry.NewRepo(pool, nil), Now: nowFn}),
		Verifier:  testutil.ContextVerifier(),
		// A per server store so the Idempotency-Key replay and the sync rate
		// limit are exercised without leaking between parallel tests.
		Store: cache.NewMemoryStore(),
		Now:   nowFn,
	})
	return testutil.NewServer(t, syncMod, dutyMod)
}

// driverClient is a self scoped mobile client for the tenant's driver.
func driverClient(t testing.TB, srv *testutil.TestServer, tn *testutil.Tenant) *testutil.TestServer {
	t.Helper()
	return srv.AsPrincipal(tn.DriverPrincipal(allPerms...))
}

func idem() testutil.RequestOption {
	return testutil.Header("Idempotency-Key", uuid.NewString())
}

func f64(v float64) *float64 { return &v }
func seq(v int64) *int64     { return &v }

// event builds a valid duty status change at the given instant.
func event(at time.Time, mut ...func(*dto.EventPush)) dto.EventPush {
	e := dto.EventPush{
		ClientEventID: uuid.NewString(),
		EventType:     "status_change",
		Status:        "ON",
		Origin:        "driver",
		EventTime:     at,
		TimeSource:    syncrules.TimeSourceELDRTC,
		DeviceSeq:     seq(10),
	}
	for _, m := range mut {
		m(&e)
	}
	return e
}

func push(t testing.TB, c *testutil.TestServer, body dto.PushRequest) *testutil.Response {
	t.Helper()
	return c.Post("/api/v1/sync/push", body, idem())
}

func decodePush(t testing.TB, resp *testutil.Response) dto.PushResponse {
	t.Helper()
	var env struct {
		Data dto.PushResponse `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

func decodePull(t testing.TB, resp *testutil.Response) dto.PullResponse {
	t.Helper()
	var env struct {
		Data dto.PullResponse `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

// baseRequest is a push carrying one event and nothing else.
func baseRequest(events ...dto.EventPush) dto.PushRequest {
	return dto.PushRequest{
		DeviceID:   uuid.NewString(),
		AppVersion: "1.2.0",
		Clock:      dto.Clock{Phone: &now, ELDRTC: &now},
		Events:     events,
	}
}

// ------------------------------------------------------------------ push

func TestPushRequiresIdempotencyKey(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)

	resp := driverClient(t, srv, tn).Post("/api/v1/sync/push", baseRequest(event(now.Add(-time.Hour))))
	testutil.RequireStatusCode(t, resp, http.StatusBadRequest, apierr.CodeBadRequest)
}

// Idempotency: the same client_event_id twice answers `duplicate`, not an error
// (TZ D§2), and the row is written exactly once.
func TestPushIsIdempotentOnClientEventID(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	ev := event(now.Add(-2 * time.Hour))
	first := decodePush(t, push(t, c, baseRequest(ev)))
	require.Len(t, first.Events, 1)
	require.Equal(t, syncrules.ResultAccepted, first.Events[0].Result)

	// A new Idempotency-Key forces the batch to be decided again; the stored
	// client_event_id is what makes the retry a duplicate.
	second := decodePush(t, push(t, c, baseRequest(ev)))
	require.Len(t, second.Events, 1)
	require.Equal(t, syncrules.ResultDuplicate, second.Events[0].Result)

	require.Equal(t, 1, countEvents(t, tn.ID(), ev.ClientEventID))
}

// The same Idempotency-Key replays the recorded response.
func TestPushReplaysTheSameIdempotencyKey(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	key := testutil.Header("Idempotency-Key", uuid.NewString())
	ev := event(now.Add(-3 * time.Hour))
	first := c.Post("/api/v1/sync/push", baseRequest(ev), key)
	testutil.RequireStatus(t, first, http.StatusOK)

	second := c.Post("/api/v1/sync/push", baseRequest(ev), key)
	testutil.RequireStatus(t, second, http.StatusOK)
	require.Equal(t, string(first.Body), string(second.Body))
	require.Equal(t, 1, countEvents(t, tn.ID(), ev.ClientEventID))
}

// Conflict rule 3: an event more than five minutes ahead of the server.
func TestPushRejectsFutureEvent(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	ev := event(now.Add(30 * time.Minute))
	out := decodePush(t, push(t, c, baseRequest(ev)))
	require.Equal(t, syncrules.ResultRejected, out.Events[0].Result)
	require.Equal(t, syncrules.ReasonTimeInFuture, out.Events[0].Reason)
	require.Zero(t, countEvents(t, tn.ID(), ev.ClientEventID))

	// Inside the five minute tolerance the same event is accepted.
	ok := decodePush(t, push(t, c, baseRequest(event(now.Add(4*time.Minute)))))
	require.Equal(t, syncrules.ResultAccepted, ok.Events[0].Result)
}

// Conflict rule 5: a certified day only accepts edit requests.
func TestPushRejectsLockedDay(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	at := now.Add(-30 * time.Hour)
	certifyDay(t, tn, at)

	ev := event(at)
	out := decodePush(t, push(t, c, baseRequest(ev)))
	require.Equal(t, syncrules.ResultRejected, out.Events[0].Result)
	require.Equal(t, syncrules.ReasonLogLocked, out.Events[0].Reason)
	require.Zero(t, countEvents(t, tn.ID(), ev.ClientEventID))
}

// Conflict rule 1: the arriving eld_rtc event beats the stored phone event and
// stamps superseded_by on it. The loser is kept, never deleted.
func TestPushSupersedesTheWeakerStoredEvent(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	at := now.Add(-5 * time.Hour).Truncate(time.Second)
	stored := testutil.NewDutyStatusEvent(t, tn.ID(),
		testutil.WithDriver(tn.Driver), testutil.WithUnit(tn.Unit),
		testutil.WithEventTime(at), testutil.With("time_source", "phone"),
		testutil.With("device_seq", int64(99)), testutil.With("status", "OFF"))

	out := decodePush(t, push(t, c, baseRequest(event(at))))
	require.Equal(t, syncrules.ResultAccepted, out.Events[0].Result)
	require.Empty(t, out.Events[0].Reason)

	winner := eventIDByClientID(t, tn.ID(), out.Events[0].ClientEventID)
	require.Equal(t, winner, supersededBy(t, stored.ID))
}

// Conflict rule 1, the other direction: the arriving phone event loses to the
// stored eld_rtc event but is still stored, flagged, and reported back so the
// driver can be warned.
func TestPushStoresTheLoserWithSupersededBy(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	at := now.Add(-6 * time.Hour).Truncate(time.Second)
	winnerClientID := uuid.New()
	testutil.NewDutyStatusEvent(t, tn.ID(),
		testutil.WithDriver(tn.Driver), testutil.WithUnit(tn.Unit),
		testutil.WithEventTime(at), testutil.With("time_source", "eld_rtc"),
		testutil.WithClientEventID(winnerClientID))

	loser := event(at, func(e *dto.EventPush) { e.TimeSource = syncrules.TimeSourcePhone })
	out := decodePush(t, push(t, c, baseRequest(loser)))
	require.Equal(t, syncrules.ResultAccepted, out.Events[0].Result)
	require.Equal(t, syncrules.ReasonSuperseded, out.Events[0].Reason)
	require.Equal(t, winnerClientID.String(), out.Events[0].SupersededBy)

	// The loser is stored and points at the winner.
	require.Equal(t, 1, countEvents(t, tn.ID(), loser.ClientEventID))
	storedLoser := eventIDByClientID(t, tn.ID(), loser.ClientEventID)
	require.Equal(t, eventIDByClientID(t, tn.ID(), winnerClientID.String()), supersededBy(t, uuid.MustParse(storedLoser)))
}

// The batch ceilings answer one 422 BATCH_TOO_LARGE for the whole upload.
func TestPushRefusesOversizedBatch(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	events := make([]dto.EventPush, 0, syncrules.MaxEvents+1)
	for i := 0; i <= syncrules.MaxEvents; i++ {
		events = append(events, event(now.Add(-time.Duration(i)*time.Minute)))
	}
	resp := push(t, c, baseRequest(events...))
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeBatchTooLarge)
}

// The server owns the duty rules the device cannot be trusted with (Q4-Q5).
func TestPushAppliesServerSideDutyChecks(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	// Q4.3: the seeded unit has no sleeper berth, so SB does not exist.
	sb := event(now.Add(-time.Hour), func(e *dto.EventPush) {
		e.Status = "SB"
		e.UnitID = tn.Unit.ID.String()
	})
	out := decodePush(t, push(t, c, baseRequest(sb)))
	require.Equal(t, syncrules.ResultRejected, out.Events[0].Result)
	require.Equal(t, duty.ReasonSleeperUnavailable, out.Events[0].Reason)

	// Q4: DR is produced by motion, never picked in the status modal.
	dr := event(now.Add(-time.Hour), func(e *dto.EventPush) { e.Status = "DR"; e.Origin = "driver" })
	out = decodePush(t, push(t, c, baseRequest(dr)))
	require.Equal(t, syncrules.ResultRejected, out.Events[0].Result)
	require.Equal(t, duty.ReasonDriveNotManual, out.Events[0].Reason)

	// Q5: motion at or above motion_threshold_kmh coerces the status to DR.
	moving := event(now.Add(-time.Hour), func(e *dto.EventPush) { e.SpeedKmh = f64(50) })
	out = decodePush(t, push(t, c, baseRequest(moving)))
	require.Equal(t, syncrules.ResultAccepted, out.Events[0].Result)
	require.Equal(t, duty.ReasonAutoDrive, out.Events[0].Reason)
	require.Equal(t, "DR", storedStatus(t, tn.ID(), moving.ClientEventID))

	// Q4.2: a yard move above ym_max_speed_kmh ends and becomes driving.
	yard := event(now.Add(-time.Hour), func(e *dto.EventPush) {
		e.Special = "ym"
		e.SpeedKmh = f64(60)
	})
	out = decodePush(t, push(t, c, baseRequest(yard)))
	require.Equal(t, syncrules.ResultAccepted, out.Events[0].Result)
	require.Equal(t, duty.ReasonYardMoveEnded, out.Events[0].Reason)
	require.Equal(t, "DR", storedStatus(t, tn.ID(), yard.ClientEventID))
	require.Equal(t, "none", storedSpecial(t, tn.ID(), yard.ClientEventID))
}

// Q-B1.2: the batch clock verdict is reported back and stored on every event.
func TestPushReportsClockIntegrity(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	// No ELD: the phone is the only clock, so the batch is unverified.
	drifted := now.Add(12 * time.Minute)
	req := dto.PushRequest{
		DeviceID: uuid.NewString(),
		Clock:    dto.Clock{Phone: &drifted},
		Events:   []dto.EventPush{event(now.Add(-time.Hour), func(e *dto.EventPush) { e.TimeSource = "" })},
	}
	out := decodePush(t, push(t, c, req))
	require.Equal(t, syncrules.TimeSourcePhone, out.Clock.Source)
	require.Equal(t, 720, out.Clock.SkewSec)
	require.True(t, out.Clock.TimeUnverified)
	require.True(t, out.Clock.Warning)
	require.Equal(t, syncrules.MalfunctionTiming, out.Clock.MalfunctionCode)

	unverified, skew := storedClock(t, tn.ID(), req.Events[0].ClientEventID)
	require.True(t, unverified)
	require.EqualValues(t, 720, skew)
}

// The accepted events land on their home terminal log day and rewrite its
// totals with hos.DayTotalsFor (Q10.2).
func TestPushRecomputesDailyLogTotals(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	// America/Chicago (the fixture default) is UTC-5 in September, so the log
	// day starts at 05:00Z. A day of 6h ON then OFF is 360 on-duty minutes.
	dayStart := time.Date(2026, 9, 5, 5, 0, 0, 0, time.UTC)
	out := decodePush(t, push(t, c, baseRequest(
		event(dayStart, func(e *dto.EventPush) { e.Status = "OFF" }),
		event(dayStart.Add(6*time.Hour), func(e *dto.EventPush) { e.Status = "ON" }),
		event(dayStart.Add(12*time.Hour), func(e *dto.EventPush) { e.Status = "OFF" }),
	)))
	for _, r := range out.Events {
		require.Equal(t, syncrules.ResultAccepted, r.Result, "%+v", r)
	}

	totals := dayTotals(t, tn.Driver.ID, "2026-09-05")
	require.EqualValues(t, 360, totals["on"], "6h ON: %v", totals)
	require.EqualValues(t, 1080, totals["off"], "the rest of the day is OFF: %v", totals)
	require.EqualValues(t, 0, totals["dr"])
}

// A caller that is not a driver cannot push at all.
func TestPushRejectsNonDriver(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)

	resp := push(t, srv.AsTenant(tn), baseRequest(event(now.Add(-time.Hour))))
	testutil.RequireStatus(t, resp, http.StatusForbidden)
}

// Cross-tenant: the driver of company A never writes into company B, and B's
// events stay invisible.
func TestPushIsTenantIsolated(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, allPerms...)

	ev := event(now.Add(-time.Hour))
	out := decodePush(t, push(t, driverClient(t, srv, a), baseRequest(ev)))
	require.Equal(t, syncrules.ResultAccepted, out.Events[0].Result)

	require.Equal(t, 1, countEvents(t, a.ID(), ev.ClientEventID))
	require.Zero(t, countEvents(t, b.ID(), ev.ClientEventID))
}

// ------------------------------------------------------------------ pull

func TestPullReturnsServerChangesAndAdvancesTheCursor(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	// The fixtures carry the database clock, not the frozen test instant, so
	// the cursor has to be taken from the database to exclude them.
	seeded := dbNow(t)
	first := decodePull(t, c.Get("/api/v1/sync/pull",
		testutil.Query("since", seeded.Format(time.RFC3339Nano))))
	require.Empty(t, first.Events)
	require.NotEmpty(t, first.QuickNotes, "companies.settings.quick_notes ship with every pull")
	require.NotEmpty(t, first.DefectTypes, "the seeded global defect catalogue")
	require.Equal(t, 660, first.HosPolicy.DriveLimitMin)
	require.NotNil(t, first.LogEditRequests, "stage 4 ships the field empty, never null")

	// A server side change is picked up and moves next_since forward.
	cursor := first.NextSince
	touchEvent(t, tn.Event.ID)
	second := decodePull(t, c.Get("/api/v1/sync/pull",
		testutil.Query("since", cursor.Format(time.RFC3339Nano))))
	require.Len(t, second.Events, 1)
	require.Equal(t, tn.Event.ID.String(), second.Events[0].ID)
	require.True(t, second.NextSince.After(cursor))

	// Replaying with the new cursor returns nothing: no row is seen twice.
	third := decodePull(t, c.Get("/api/v1/sync/pull",
		testutil.Query("since", second.NextSince.Format(time.RFC3339Nano))))
	require.Empty(t, third.Events)
}

func TestPullOffersTheUnitsUnidentifiedBuffer(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := driverClient(t, srv, tn)

	before := dbNow(t)
	id := seedUnidentified(t, tn.ID(), tn.Unit.ID)
	out := decodePull(t, c.Get("/api/v1/sync/pull",
		testutil.Query("since", before.Format(time.RFC3339Nano)),
		testutil.Query("unit_id", tn.Unit.ID.String())))

	require.Len(t, out.UnidentifiedEvents, 1)
	require.Equal(t, id.String(), out.UnidentifiedEvents[0].ID)
	require.Equal(t, tn.Unit.UnitNumber, out.UnidentifiedEvents[0].UnitNumber)

	// Another company's unit is simply not there: no leak, no error.
	other := testutil.SeedTenant(t, allPerms...)
	empty := decodePull(t, c.Get("/api/v1/sync/pull",
		testutil.Query("since", before.Format(time.RFC3339Nano)),
		testutil.Query("unit_id", other.Unit.ID.String())))
	require.Empty(t, empty.UnidentifiedEvents)
}

func TestPullRejectsNonDriver(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)

	resp := srv.AsTenant(tn).Get("/api/v1/sync/pull")
	testutil.RequireStatus(t, resp, http.StatusForbidden)
}

func TestSyncRequiresAuthentication(t *testing.T) {
	t.Parallel()
	srv := newServer(t)

	testutil.RequireStatus(t, srv.Anonymous().Get("/api/v1/sync/pull"), http.StatusUnauthorized)
	testutil.RequireStatus(t, srv.Anonymous().Post("/api/v1/sync/push", baseRequest(), idem()),
		http.StatusUnauthorized)
}

// A role without logs.read cannot sync at all, even as a driver.
func TestSyncRequiresLogsRead(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t) // no permissions
	c := srv.AsPrincipal(tn.DriverPrincipal())

	testutil.RequireStatus(t, c.Get("/api/v1/sync/pull"), http.StatusForbidden)
	testutil.RequireStatus(t, push(t, c, baseRequest(event(now.Add(-time.Hour)))), http.StatusForbidden)
}

// --------------------------------------------------------------- helpers

func countEvents(t testing.TB, companyID uuid.UUID, clientEventID string) int {
	t.Helper()
	var n int
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM duty_status_events WHERE company_id = $1 AND client_event_id = $2`,
		companyID, uuid.MustParse(clientEventID)).Scan(&n)
	require.NoError(t, err)
	return n
}

func eventIDByClientID(t testing.TB, companyID uuid.UUID, clientEventID string) string {
	t.Helper()
	var id uuid.UUID
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT id FROM duty_status_events WHERE company_id = $1 AND client_event_id = $2`,
		companyID, uuid.MustParse(clientEventID)).Scan(&id)
	require.NoError(t, err)
	return id.String()
}

func supersededBy(t testing.TB, id uuid.UUID) string {
	t.Helper()
	var out *uuid.UUID
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT superseded_by FROM duty_status_events WHERE id = $1`, id).Scan(&out)
	require.NoError(t, err)
	require.NotNil(t, out, "the loser of conflict rule 1 must carry superseded_by")
	return out.String()
}

func storedStatus(t testing.TB, companyID uuid.UUID, clientEventID string) string {
	t.Helper()
	var status *string
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT status FROM duty_status_events WHERE company_id = $1 AND client_event_id = $2`,
		companyID, uuid.MustParse(clientEventID)).Scan(&status)
	require.NoError(t, err)
	require.NotNil(t, status)
	return *status
}

func storedSpecial(t testing.TB, companyID uuid.UUID, clientEventID string) string {
	t.Helper()
	var special string
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT special FROM duty_status_events WHERE company_id = $1 AND client_event_id = $2`,
		companyID, uuid.MustParse(clientEventID)).Scan(&special)
	require.NoError(t, err)
	return special
}

func storedClock(t testing.TB, companyID uuid.UUID, clientEventID string) (bool, int32) {
	t.Helper()
	var (
		unverified bool
		skew       int32
	)
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT time_unverified, clock_skew_sec FROM duty_status_events
		 WHERE company_id = $1 AND client_event_id = $2`,
		companyID, uuid.MustParse(clientEventID)).Scan(&unverified, &skew)
	require.NoError(t, err)
	return unverified, skew
}

// certifyDay locks the driver's log day covering at.
func certifyDay(t testing.TB, tn *testutil.Tenant, at time.Time) {
	t.Helper()
	loc, err := time.LoadLocation("America/Chicago")
	require.NoError(t, err)
	local := at.In(loc)
	day := time.Date(local.Year(), local.Month(), local.Day(), 0, 0, 0, 0, time.UTC)

	_, err = testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO daily_logs (company_id, driver_id, log_date, timezone, certification_status)
		 VALUES ($1, $2, $3, 'America/Chicago', 'certified')
		 ON CONFLICT (driver_id, log_date) DO UPDATE SET certification_status = 'certified'`,
		tn.ID(), tn.Driver.ID, day)
	require.NoError(t, err)
}

// dayTotals reads back the recomputed daily_logs.totals document.
func dayTotals(t testing.TB, driverID uuid.UUID, day string) map[string]int64 {
	t.Helper()
	var raw []byte
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT totals FROM daily_logs WHERE driver_id = $1 AND log_date = $2::date`,
		driverID, day).Scan(&raw)
	require.NoError(t, err, "daily log %s", day)

	out := map[string]int64{}
	require.NoError(t, json.Unmarshal(raw, &out))
	return out
}

// dbNow reads the database clock: every updated_at cursor is stamped by it, so
// a cursor taken from the test process clock can be off by a few microseconds
// and let a fixture row through.
func dbNow(t testing.TB) time.Time {
	t.Helper()
	var at time.Time
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t), `SELECT now()`).Scan(&at))
	return at.UTC()
}

func touchEvent(t testing.TB, id uuid.UUID) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE duty_status_events SET notes = 'touched' WHERE id = $1`, id)
	require.NoError(t, err)
}

func seedUnidentified(t testing.TB, companyID, unitID uuid.UUID) uuid.UUID {
	t.Helper()
	id := uuid.New()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO unidentified_events (id, company_id, unit_id, start_at, end_at, distance_m, status)
		 VALUES ($1, $2, $3, $4, $5, 18400, 'pending')`,
		id, companyID, unitID, now.Add(-2*time.Hour), now.Add(-90*time.Minute))
	require.NoError(t, err)
	return id
}
