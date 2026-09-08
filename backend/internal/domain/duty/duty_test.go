//go:build integration

// Integration coverage of the duty status and HOS endpoints: the event window,
// the home terminal day boundary, the HOS summary against internal/hos itself,
// the policy version in force on the day (Q10.1), the driver self scope and
// cross-tenant isolation (404, never 403).
package duty_test

import (
	"encoding/json"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/duty"
	"github.com/devline/onebook-eld/internal/domain/duty/dto"
	"github.com/devline/onebook-eld/internal/hos"
	"github.com/devline/onebook-eld/internal/testutil"
)

// now is the fixed server instant every case is measured against.
var now = time.Date(2026, 9, 6, 18, 0, 0, 0, time.UTC)

// chicago is the fixture company timezone; the log day is cut in it (Q10.2).
var chicago = mustLoad("America/Chicago")

func mustLoad(name string) *time.Location {
	loc, err := time.LoadLocation(name)
	if err != nil {
		panic(err)
	}
	return loc
}

func newServer(t testing.TB) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	return testutil.NewServer(t, duty.New(duty.Deps{
		Repo:     duty.NewRepo(pool, nil),
		Verifier: testutil.ContextVerifier(),
		Now:      func() time.Time { return now },
	}))
}

func decodeEvents(t testing.TB, resp *testutil.Response) []dto.DutyStatusEvent {
	t.Helper()
	var env struct {
		Data []dto.DutyStatusEvent `json:"data"`
		Meta dto.Meta              `json:"meta"`
	}
	resp.JSON(&env)
	return env.Data
}

func decodeSummary(t testing.TB, resp *testutil.Response) dto.HosSummary {
	t.Helper()
	var env struct {
		Data dto.HosSummary `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

// seedDay writes a status change at the given offset from the log day start.
func seedDay(t testing.TB, tn *testutil.Tenant, dayStart time.Time, offsets []time.Duration, statuses []string) {
	t.Helper()
	require.Equal(t, len(offsets), len(statuses))
	for i := range offsets {
		testutil.NewDutyStatusEvent(t, tn.ID(),
			testutil.WithDriver(tn.Driver), testutil.WithUnit(tn.Unit),
			testutil.WithEventTime(dayStart.Add(offsets[i])),
			testutil.With("status", statuses[i]),
			testutil.With("event_type", "duty_status"))
	}
}

// dayStartOf returns the UTC instant of local midnight of the given day.
func dayStartOf(y int, m time.Month, d int) time.Time {
	return time.Date(y, m, d, 0, 0, 0, 0, chicago).UTC()
}

// ------------------------------------------------------- duty status events

func TestEventsReturnsTheDriversWindow(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermLogsRead)

	dayStart := dayStartOf(2026, 9, 5)
	seedDay(t, tn, dayStart,
		[]time.Duration{0, 6 * time.Hour, 12 * time.Hour},
		[]string{"OFF", "ON", "OFF"})

	rows := decodeEvents(t, srv.AsTenant(tn).Get(
		"/api/v1/drivers/"+tn.Driver.ID.String()+"/duty-status-events",
		testutil.Query("from", dayStart.Format(time.RFC3339)),
		testutil.Query("to", dayStart.Add(24*time.Hour).Format(time.RFC3339))))

	require.Len(t, rows, 3)
	require.Equal(t, "OFF", rows[0].Status)
	require.Equal(t, "ON", rows[1].Status)
	require.True(t, rows[0].EventTime.Before(rows[1].EventTime), "ordered by event_time")
}

// A superseded event is hidden from the list: the surviving row is canonical
// while the loser stays in the table (conflict rule 1).
func TestEventsHidesSupersededRows(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermLogsRead)

	at := now.Add(-2 * time.Hour).Truncate(time.Second)
	winner := testutil.NewDutyStatusEvent(t, tn.ID(),
		testutil.WithDriver(tn.Driver), testutil.WithEventTime(at))
	loser := testutil.NewDutyStatusEvent(t, tn.ID(),
		testutil.WithDriver(tn.Driver), testutil.WithEventTime(at))
	supersede(t, loser.ID, winner.ID)

	rows := decodeEvents(t, srv.AsTenant(tn).Get(
		"/api/v1/drivers/"+tn.Driver.ID.String()+"/duty-status-events",
		testutil.Query("from", at.Add(-time.Hour).Format(time.RFC3339)),
		testutil.Query("to", at.Add(time.Hour).Format(time.RFC3339))))

	require.Len(t, rows, 1)
	require.Equal(t, winner.ID.String(), rows[0].ID)
}

func TestEventsRejectsAnUnusableWindow(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermLogsRead)
	c := srv.AsTenant(tn)
	base := "/api/v1/drivers/" + tn.Driver.ID.String() + "/duty-status-events"

	inverted := c.Get(base,
		testutil.Query("from", now.Format(time.RFC3339)),
		testutil.Query("to", now.Add(-time.Hour).Format(time.RFC3339)))
	testutil.RequireStatus(t, inverted, http.StatusUnprocessableEntity)

	tooWide := c.Get(base,
		testutil.Query("from", now.AddDate(0, 0, -90).Format(time.RFC3339)),
		testutil.Query("to", now.Format(time.RFC3339)))
	testutil.RequireStatus(t, tooWide, http.StatusUnprocessableEntity)
}

// ------------------------------------------------------------- hos summary

// The endpoint must agree with internal/hos exactly: the engine is canonical
// and the endpoint is only a projection of it.
func TestHosSummaryMatchesTheEngine(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermLogsRead)

	// A plain day: 10h off, 5h driving, 2h on duty, then off.
	dayStart := dayStartOf(2026, 9, 5)
	offsets := []time.Duration{0, 10 * time.Hour, 15 * time.Hour, 17 * time.Hour}
	statuses := []string{"OFF", "DR", "ON", "OFF"}
	seedDay(t, tn, dayStart, offsets, statuses)

	out := decodeSummary(t, srv.AsTenant(tn).Get(
		"/api/v1/drivers/"+tn.Driver.ID.String()+"/hos-summary",
		testutil.Query("date", "2026-09-05")))

	require.Equal(t, "2026-09-05", out.Date)
	require.Equal(t, "America/Chicago", out.Timezone)

	// Rebuild the same inputs and compare against the engine directly.
	events := make([]hos.Event, 0, len(offsets))
	for i := range offsets {
		events = append(events, hos.Event{
			Time:    dayStart.Add(offsets[i]),
			Status:  hos.Status(statuses[i]),
			Special: hos.SpecialNone,
			Type:    hos.EventStatusChange,
		})
	}
	day := time.Date(2026, 9, 5, 0, 0, 0, 0, chicago)
	_, dayEnd := hos.DayRange(day, chicago)

	wantTotals := hos.DayTotalsFor(events, day, chicago)
	require.EqualValues(t, int64(wantTotals.Drive/time.Minute), out.Totals.DriveMin)
	require.EqualValues(t, int64(wantTotals.On/time.Minute), out.Totals.OnMin)
	require.EqualValues(t, int64(wantTotals.Off/time.Minute), out.Totals.OffMin)
	require.EqualValues(t, 300, out.Totals.DriveMin, "5h of driving")
	require.EqualValues(t, 120, out.Totals.OnMin, "2h on duty")

	wantCounters, err := hos.Compute(events, hos.DefaultPolicy(), dayEnd.UTC(), chicago)
	require.NoError(t, err)
	require.EqualValues(t, int64(wantCounters.DriveLeft/time.Minute), out.Counters.DriveLeftMin)
	require.EqualValues(t, int64(wantCounters.CycleLeft/time.Minute), out.Counters.CycleLeftMin)
	require.EqualValues(t, int64(wantCounters.DrivingTimeLeft/time.Minute), out.Counters.DrivingTimeLeftMin)

	// Q10.7: the recap covers cycle_days rows ending on the log day.
	require.Len(t, out.Recap, hos.DefaultPolicy().CycleDays)
	require.Equal(t, "2026-09-05", out.Recap[len(out.Recap)-1].Date)
	require.EqualValues(t, 420, out.Recap[len(out.Recap)-1].OnDutyMin, "ON+DR of the day")

	// Violations are computed and shown, but stage 3 never writes them.
	require.NotNil(t, out.Violations)
	require.Zero(t, countViolations(t, tn.ID()))
}

// Q10.1: the day is evaluated with the policy version that was in force then,
// so a later policy change never rewrites history.
func TestHosSummaryUsesThePolicyInForceOnThatDay(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermLogsRead)

	// An older, stricter policy and a newer, looser one.
	oldID := seedPolicy(t, tn.ID(), dayStartOf(2026, 1, 1), `{"drive_limit_min":600}`)
	newID := seedPolicy(t, tn.ID(), dayStartOf(2026, 9, 6), `{"drive_limit_min":660}`)

	past := decodeSummary(t, srv.AsTenant(tn).Get(
		"/api/v1/drivers/"+tn.Driver.ID.String()+"/hos-summary",
		testutil.Query("date", "2026-09-05")))
	require.NotNil(t, past.PolicyVersionID)
	require.Equal(t, oldID.String(), *past.PolicyVersionID)
	require.EqualValues(t, 600, past.Counters.DriveLeftMin, "the 10h limit of the old policy")

	today := decodeSummary(t, srv.AsTenant(tn).Get(
		"/api/v1/drivers/"+tn.Driver.ID.String()+"/hos-summary",
		testutil.Query("date", "2026-09-06")))
	require.NotNil(t, today.PolicyVersionID)
	require.Equal(t, newID.String(), *today.PolicyVersionID)
	// The seeded tenant carries one DR event today, so the counter is just
	// under the ceiling; what matters is that it is above the old 10h limit,
	// which is only possible under the newer policy.
	require.Greater(t, today.Counters.DriveLeftMin, int64(600), "the 11h limit of the new policy")
	require.LessOrEqual(t, today.Counters.DriveLeftMin, int64(660))
}

// Q10.2: the log day is the home terminal 00:00-24:00 window, not UTC. In
// September Chicago is UTC-5, so 04:00Z belongs to the previous local day.
func TestHosSummaryCutsTheDayInTheHomeTerminalTimezone(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermLogsRead)

	dayStart := dayStartOf(2026, 9, 5) // 2026-09-05T05:00:00Z
	seedDay(t, tn, dayStart,
		[]time.Duration{-time.Hour, time.Hour},
		[]string{"ON", "OFF"})

	// The 04:00Z event is on 2026-09-04 locally: the 5th only sees one hour
	// of ON carried over the boundary.
	fifth := decodeSummary(t, srv.AsTenant(tn).Get(
		"/api/v1/drivers/"+tn.Driver.ID.String()+"/hos-summary",
		testutil.Query("date", "2026-09-05")))
	require.EqualValues(t, 60, fifth.Totals.OnMin)

	fourth := decodeSummary(t, srv.AsTenant(tn).Get(
		"/api/v1/drivers/"+tn.Driver.ID.String()+"/hos-summary",
		testutil.Query("date", "2026-09-04")))
	require.EqualValues(t, 60, fourth.Totals.OnMin, "23:00 local to midnight")
}

// -------------------------------------------------------------- scoping

// A Driver (scope self) reads its own data and nothing else. A driver of the
// same company answers 404, never 403: the endpoint never confirms a row the
// caller may not see.
func TestDriverSelfScope(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermLogsRead)
	other := testutil.NewDriver(t, tn.ID())

	c := srv.AsPrincipal(tn.DriverPrincipal(core.PermLogsRead))

	own := c.Get("/api/v1/drivers/" + tn.Driver.ID.String() + "/hos-summary")
	testutil.RequireStatus(t, own, http.StatusOK)

	foreign := c.Get("/api/v1/drivers/" + other.ID.String() + "/hos-summary")
	testutil.RequireStatus(t, foreign, http.StatusNotFound)

	foreignEvents := c.Get("/api/v1/drivers/" + other.ID.String() + "/duty-status-events")
	testutil.RequireStatus(t, foreignEvents, http.StatusNotFound)
}

func TestCrossTenantAnswers404(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, core.PermLogsRead)

	c := srv.AsTenant(a)
	testutil.RequireStatus(t, c.Get("/api/v1/drivers/"+b.Driver.ID.String()+"/hos-summary"),
		http.StatusNotFound)
	testutil.RequireStatus(t, c.Get("/api/v1/drivers/"+b.Driver.ID.String()+"/duty-status-events"),
		http.StatusNotFound)
}

func TestPermissionAndAuthentication(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t) // no permissions at all

	path := "/api/v1/drivers/" + tn.Driver.ID.String() + "/hos-summary"
	testutil.RequireStatus(t, srv.Anonymous().Get(path), http.StatusUnauthorized)
	testutil.RequireStatus(t, srv.AsTenant(tn).Get(path), http.StatusForbidden)
}

func TestResponsesCarryNoPII(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermLogsRead)

	resp := srv.AsTenant(tn).Get("/api/v1/drivers/" + tn.Driver.ID.String() + "/duty-status-events")
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)
}

// --------------------------------------------------------------- helpers

func supersede(t testing.TB, loser, winner uuid.UUID) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE duty_status_events SET superseded_by = $2 WHERE id = $1`, loser, winner)
	require.NoError(t, err)
}

func seedPolicy(t testing.TB, companyID uuid.UUID, from time.Time, policy string) uuid.UUID {
	t.Helper()
	require.True(t, json.Valid([]byte(policy)))
	id := uuid.New()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO hos_policy_versions (id, company_id, effective_from, policy)
		 VALUES ($1, $2, $3, $4::jsonb)`, id, companyID, from, policy)
	require.NoError(t, err)
	return id
}

func countViolations(t testing.TB, companyID uuid.UUID) int {
	t.Helper()
	var n int
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM violations WHERE company_id = $1`, companyID).Scan(&n)
	require.NoError(t, err)
	return n
}
