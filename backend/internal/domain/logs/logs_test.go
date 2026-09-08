//go:build integration

// Integration coverage of stage 4: certification and the day lock (Q26.1),
// the propose/approve edit model with its Q17.1 prohibitions, the driver's own
// edit, unidentified driving assignment and claim (§10.4), the canonical
// violation catalogue (Q57/Q58), the read only roadside token (Q54) and
// cross-tenant isolation (404, never 403).
package logs_test

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/duty"
	"github.com/devline/onebook-eld/internal/domain/logs"
	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// now is the fixed server instant every case is measured against.
var now = time.Date(2026, 9, 6, 18, 0, 0, 0, time.UTC)

// chicago is the fixture company timezone; the log day is cut in it (Q10.2).
var chicago = mustLoad("America/Chicago")

// logDay is the calendar day every fixture writes into.
var logDay = time.Date(2026, 9, 6, 0, 0, 0, 0, time.UTC)

func mustLoad(name string) *time.Location {
	loc, err := time.LoadLocation(name)
	if err != nil {
		panic(err)
	}
	return loc
}

// dayStart is the UTC instant of local midnight of the fixture log day.
func dayStart() time.Time {
	return time.Date(2026, 9, 6, 0, 0, 0, 0, chicago).UTC()
}

// allPerms are every permission stage 4 gates on, so one seeded role can drive
// both the admin and the driver side of a case.
var allPerms = []string{
	core.PermLogsRead, core.PermLogsCertify, core.PermLogsExport, core.PermLogsAddEvent,
	core.PermLogsProposeEdit, core.PermLogsApproveEdit, core.PermLogsRejectEdit,
	core.PermLogsAssignUnidentified, core.PermLogsClaimUnidentified, core.PermLogsAnnotateUnidentifed,
	core.PermViolationsRead, core.PermReportsRead,
	core.PermInspectionView, core.PermInspectionEmail, core.PermInspectionTransfer,
}

func newServer(t testing.TB) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	nowFn := func() time.Time { return now }

	dutyMod := duty.New(duty.Deps{
		Repo:     duty.NewRepo(pool, nil),
		Verifier: testutil.ContextVerifier(),
		Now:      nowFn,
	})
	tokens, err := core.NewTokenService("test-secret-test-secret-test-secret-32", time.Hour)
	require.NoError(t, err)

	return testutil.NewServer(t, logs.New(logs.Deps{
		Repo:     logs.NewRepo(pool, nil),
		Duty:     dutyMod.Service(),
		Verifier: testutil.ContextVerifier(),
		Now:      nowFn,
		Tokens:   tokens,
	}))
}

// ----------------------------------------------------------------- fixtures

// crew is one driver plus the user behind it, so a case can own a log day
// without colliding with the tenant's default driver.
type crew struct {
	Driver testutil.Driver
	User   testutil.User
	Log    testutil.DailyLog
}

func seedCrew(t testing.TB, tn *testutil.Tenant) crew {
	t.Helper()
	u := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))
	d := testutil.NewDriver(t, tn.ID(), testutil.WithUser(u))
	l := testutil.NewDailyLog(t, tn.ID(), testutil.WithDriver(d), testutil.WithLogDate(logDay))
	return crew{Driver: d, User: u, Log: l}
}

// driver builds the self scoped mobile principal of this crew.
func (c crew) driver(tn *testutil.Tenant) *tenant.Principal {
	p := tn.Principal()
	p.UserID = c.User.ID
	p.Scope = tenant.ScopeSelf
	p.DeviceType = tenant.DevicePhone
	return p
}

// seedEvent writes one duty status event into the crew's log day.
func seedEvent(t testing.TB, tn *testutil.Tenant, c crew, at time.Time, status, origin string) testutil.DutyStatusEvent {
	t.Helper()
	return testutil.NewDutyStatusEvent(t, tn.ID(),
		testutil.WithDriver(c.Driver), testutil.WithUnit(tn.Unit),
		testutil.WithEventTime(at), testutil.With("status", status),
		testutil.With("event_type", "duty_status"), testutil.With("origin", origin),
		testutil.With("daily_log_id", c.Log.ID))
}

func decodeLog(t testing.TB, resp *testutil.Response) dto.DailyLogDetail {
	t.Helper()
	var env struct {
		Data dto.DailyLogDetail `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

func decodeEditRequest(t testing.TB, resp *testutil.Response) dto.LogEditRequest {
	t.Helper()
	var env struct {
		Data dto.LogEditRequest `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

func decodeViolations(t testing.TB, resp *testutil.Response) []dto.Violation {
	t.Helper()
	var env struct {
		Data []dto.Violation `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

// certify signs the crew's log day with an explicit signature key.
func certify(t testing.TB, srv *testutil.TestServer, tn *testutil.Tenant, c crew) *testutil.Response {
	t.Helper()
	return srv.AsPrincipal(c.driver(tn)).Post(
		"/api/v1/daily-logs/"+c.Log.ID.String()+"/certify",
		map[string]any{"signature_key": "companies/test/signatures/sig.png", "device_id": "pixel-8"})
}

func scalar[T any](t testing.TB, query string, args ...any) T {
	t.Helper()
	var out T
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t), query, args...).Scan(&out))
	return out
}

// ------------------------------------------------------------ certification

// Q26.1: the signature locks the day's events; only an approved edit request
// may move them afterwards.
func TestCertifyLocksTheDay(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(6*time.Hour), "ON", "auto")

	resp := certify(t, srv, tn, c)
	testutil.RequireStatus(t, resp, 200)

	body := decodeLog(t, resp)
	require.Equal(t, "certified", body.CertificationStatus)
	require.True(t, body.Ready, "Q25: a signed day is ready")
	require.NotNil(t, body.Form.SignedAt)
	require.NotNil(t, body.Form.SignedIP, "Q26.1 stores signed_ip")

	locked := scalar[int](t, `SELECT count(*) FROM duty_status_events
		WHERE daily_log_id = $1 AND locked`, c.Log.ID)
	require.Positive(t, locked, "certified events are locked")
}

// Q26: an administrator never certifies on the driver's behalf.
func TestAdminCannotCertifyForTheDriver(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)

	resp := srv.AsTenant(tn).Post("/api/v1/daily-logs/"+c.Log.ID.String()+"/certify",
		map[string]any{"signature_key": "companies/test/signatures/sig.png"})
	testutil.RequireStatusCode(t, resp, 403, "FORBIDDEN")

	status := scalar[string](t, `SELECT certification_status FROM daily_logs WHERE id = $1`, c.Log.ID)
	require.Equal(t, "uncertified", status)
}

// Q25: `Not Ready` means exactly one thing — there is no signature yet.
func TestCertifyWithoutASignatureIsNotReady(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)

	resp := srv.AsPrincipal(c.driver(tn)).Post(
		"/api/v1/daily-logs/"+c.Log.ID.String()+"/certify", map[string]any{})
	testutil.RequireStatusCode(t, resp, 409, "LOG_NOT_READY")
}

// Q19: the driver's certification window is the last 8 days.
func TestDriverDailyLogsWindow(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)

	var env struct {
		Data []dto.DailyLogSummary `json:"data"`
		Meta dto.Meta              `json:"meta"`
	}
	resp := srv.AsTenant(tn).Get("/api/v1/drivers/"+c.Driver.ID.String()+"/daily-logs",
		testutil.Query("from", "2026-09-01"), testutil.Query("to", "2026-09-06"))
	testutil.RequireStatus(t, resp, 200)
	resp.JSON(&env)

	require.Len(t, env.Data, 1)
	require.Equal(t, "2026-09-06", env.Data[0].LogDate)
	require.Equal(t, "uncertified", env.Data[0].CertificationStatus)
}

// ------------------------------------------------------------- log edits

// Q17 [MUST]: the admin proposes, the driver approves; the new events carry
// origin=admin_edit, the originals survive behind superseded_by and the day
// falls back to needs_recertify (Q18).
func TestEditRequestApproveRewritesTheDay(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)

	original := seedEvent(t, tn, c, dayStart().Add(9*time.Hour), "OFF", "driver")
	testutil.RequireStatus(t, certify(t, srv, tn, c), 200)

	created := srv.AsTenant(tn).Post("/api/v1/log-edit-requests", map[string]any{
		"driver_id":    c.Driver.ID.String(),
		"daily_log_id": c.Log.ID.String(),
		"changes": []map[string]any{{
			"from":   dayStart().Add(9 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(11 * time.Hour).Format(time.RFC3339),
			"status": "ON",
			"note":   "Loading at the dock, forgot to switch",
		}},
	})
	testutil.RequireStatus(t, created, 201)
	req := decodeEditRequest(t, created)
	require.Equal(t, "pending", req.Status)
	require.Equal(t, "admin_edit", req.Source)
	require.Len(t, req.Changes, 1)

	approved := srv.AsPrincipal(c.driver(tn)).Post(
		"/api/v1/log-edit-requests/"+req.ID+"/approve", nil)
	testutil.RequireStatus(t, approved, 200)
	require.Equal(t, "approved", decodeEditRequest(t, approved).Status)

	adminEdits := scalar[int](t, `SELECT count(*) FROM duty_status_events
		WHERE daily_log_id = $1 AND origin = 'admin_edit'`, c.Log.ID)
	require.Positive(t, adminEdits, "the approved edit writes origin=admin_edit events")

	supersededBy := scalar[*uuid.UUID](t,
		`SELECT superseded_by FROM duty_status_events WHERE id = $1`, original.ID)
	require.NotNil(t, supersededBy, "the original event is kept, only flagged")

	status := scalar[string](t, `SELECT certification_status FROM daily_logs WHERE id = $1`, c.Log.ID)
	require.Equal(t, "needs_recertify", status, "Q18")
}

// Q17: only the driver answers a proposal.
func TestOnlyTheDriverMayAnswerAnEditRequest(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(9*time.Hour), "OFF", "driver")

	req := decodeEditRequest(t, srv.AsTenant(tn).Post("/api/v1/log-edit-requests", map[string]any{
		"driver_id":    c.Driver.ID.String(),
		"daily_log_id": c.Log.ID.String(),
		"changes": []map[string]any{{
			"from":   dayStart().Add(9 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(10 * time.Hour).Format(time.RFC3339),
			"status": "ON", "note": "dock work",
		}},
	}))

	testutil.RequireStatusCode(t,
		srv.AsTenant(tn).Post("/api/v1/log-edit-requests/"+req.ID+"/approve", nil), 403, "FORBIDDEN")
}

// Q17: a rejection needs a reason and leaves the log untouched.
func TestEditRequestRejectKeepsTheLog(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(9*time.Hour), "OFF", "driver")

	req := decodeEditRequest(t, srv.AsTenant(tn).Post("/api/v1/log-edit-requests", map[string]any{
		"driver_id":    c.Driver.ID.String(),
		"daily_log_id": c.Log.ID.String(),
		"changes": []map[string]any{{
			"from":   dayStart().Add(9 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(10 * time.Hour).Format(time.RFC3339),
			"status": "ON", "note": "dock work",
		}},
	}))

	client := srv.AsPrincipal(c.driver(tn))
	testutil.RequireStatusCode(t,
		client.Post("/api/v1/log-edit-requests/"+req.ID+"/reject", map[string]any{}),
		422, "VALIDATION_ERROR")

	rejected := client.Post("/api/v1/log-edit-requests/"+req.ID+"/reject",
		map[string]any{"reason": "That block was my co-driver"})
	testutil.RequireStatus(t, rejected, 200)
	out := decodeEditRequest(t, rejected)
	require.Equal(t, "rejected", out.Status)
	require.NotNil(t, out.DriverNote)

	edits := scalar[int](t, `SELECT count(*) FROM duty_status_events
		WHERE daily_log_id = $1 AND origin = 'admin_edit'`, c.Log.ID)
	require.Zero(t, edits, "a rejected proposal never touches the log")
}

// Q17.1: automatically recorded driving may not be shortened or re-classified.
func TestAutomaticDrivingIsImmutable(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(6*time.Hour), "DR", "auto")
	seedEvent(t, tn, c, dayStart().Add(10*time.Hour), "OFF", "auto")

	resp := srv.AsTenant(tn).Post("/api/v1/log-edit-requests", map[string]any{
		"driver_id":    c.Driver.ID.String(),
		"daily_log_id": c.Log.ID.String(),
		"changes": []map[string]any{{
			"from":   dayStart().Add(7 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(8 * time.Hour).Format(time.RFC3339),
			"status": "ON", "note": "that was yard work",
		}},
	})
	testutil.RequireStatusCode(t, resp, 409, "DR_IMMUTABLE")
}

// Q17.1: intermediate, power and malfunction events are never editable.
func TestPositionalEventsAreImmutable(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(6*time.Hour), "ON", "driver")
	testutil.NewDutyStatusEvent(t, tn.ID(),
		testutil.WithDriver(c.Driver), testutil.WithUnit(tn.Unit),
		testutil.WithEventTime(dayStart().Add(7*time.Hour)),
		testutil.With("event_type", "intermediate"), testutil.With("status", "DR"),
		testutil.With("origin", "auto"), testutil.With("daily_log_id", c.Log.ID))

	resp := srv.AsTenant(tn).Post("/api/v1/log-edit-requests", map[string]any{
		"driver_id":    c.Driver.ID.String(),
		"daily_log_id": c.Log.ID.String(),
		"changes": []map[string]any{{
			"from":   dayStart().Add(6 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(8 * time.Hour).Format(time.RFC3339),
			"status": "OFF", "note": "was actually resting",
		}},
	})
	testutil.RequireStatusCode(t, resp, 409, "EVENT_IMMUTABLE")
}

// Q17: the driver's own edit applies immediately and keeps the original.
func TestDriverSelfEditAppliesImmediately(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	original := seedEvent(t, tn, c, dayStart().Add(8*time.Hour), "OFF", "driver")

	resp := srv.AsPrincipal(c.driver(tn)).Post(
		"/api/v1/daily-logs/"+c.Log.ID.String()+"/events", map[string]any{
			"from":   dayStart().Add(8 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(9 * time.Hour).Format(time.RFC3339),
			"status": "ON", "note": "pre-trip inspection",
		})
	testutil.RequireStatus(t, resp, 200)

	edits := scalar[int](t, `SELECT count(*) FROM duty_status_events
		WHERE daily_log_id = $1 AND origin = 'driver_edit'`, c.Log.ID)
	require.Positive(t, edits)
	supersededBy := scalar[*uuid.UUID](t,
		`SELECT superseded_by FROM duty_status_events WHERE id = $1`, original.ID)
	require.NotNil(t, supersededBy, "the original event survives the driver edit")
}

// Q17: an edit without a reason is refused.
func TestEditWithoutANoteIsRefused(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)

	resp := srv.AsPrincipal(c.driver(tn)).Post(
		"/api/v1/daily-logs/"+c.Log.ID.String()+"/events", map[string]any{
			"from":   dayStart().Add(8 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(9 * time.Hour).Format(time.RFC3339),
			"status": "ON",
		})
	testutil.RequireStatusCode(t, resp, 422, "VALIDATION_ERROR")
}

// ------------------------------------------------------ unidentified driving

func seedBlock(t testing.TB, tn *testutil.Tenant, from, to time.Time) uuid.UUID {
	t.Helper()
	id := uuid.New()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO unidentified_events (id, company_id, unit_id, start_at, end_at, distance_m, status)
		VALUES ($1,$2,$3,$4,$5,18400,'pending')`, id, tn.ID(), tn.Unit.ID, from, to)
	require.NoError(t, err)
	return id
}

// §10.4: an admin assignment is a proposal, not a move.
func TestAssignUnidentifiedCreatesAnEditRequest(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	from := dayStart().Add(14 * time.Hour)
	block := seedBlock(t, tn, from, from.Add(40*time.Minute))

	resp := srv.AsTenant(tn).Post("/api/v1/unidentified-events/"+block.String()+"/assign",
		map[string]any{"driver_id": c.Driver.ID.String(), "note": "matches your dispatch"})
	testutil.RequireStatus(t, resp, 201)

	req := decodeEditRequest(t, resp)
	require.Equal(t, "unidentified_assign", req.Source)
	require.Equal(t, "pending", req.Status)
	require.NotNil(t, req.UnidentifiedEventID)

	status := scalar[string](t, `SELECT status FROM unidentified_events WHERE id = $1`, block)
	require.Equal(t, "proposed", status, "the block waits for the driver's answer")
}

// §10.4: approving the assignment hands the stored rows over unchanged.
func TestApprovingAnAssignmentMovesTheEvents(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	from := dayStart().Add(14 * time.Hour)
	block := seedBlock(t, tn, from, from.Add(40*time.Minute))

	orphan := testutil.NewDutyStatusEvent(t, tn.ID(),
		testutil.WithUnit(tn.Unit), testutil.WithEventTime(from.Add(5*time.Minute)),
		testutil.With("status", "DR"), testutil.With("event_type", "duty_status"))

	req := decodeEditRequest(t, srv.AsTenant(tn).Post(
		"/api/v1/unidentified-events/"+block.String()+"/assign",
		map[string]any{"driver_id": c.Driver.ID.String(), "note": "matches your dispatch"}))

	approved := srv.AsPrincipal(c.driver(tn)).Post(
		"/api/v1/log-edit-requests/"+req.ID+"/approve", nil)
	testutil.RequireStatus(t, approved, 200)

	origin := scalar[string](t, `SELECT origin FROM duty_status_events WHERE id = $1`, orphan.ID)
	require.Equal(t, "assigned", origin)
	owner := scalar[*uuid.UUID](t, `SELECT driver_id FROM duty_status_events WHERE id = $1`, orphan.ID)
	require.NotNil(t, owner)
	require.Equal(t, c.Driver.ID, *owner)

	status := scalar[string](t, `SELECT status FROM unidentified_events WHERE id = $1`, block)
	require.Equal(t, "assigned", status)
}

// §10.4: the driver may claim an unassigned block without a second approval.
func TestClaimUnidentified(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	from := dayStart().Add(14 * time.Hour)
	block := seedBlock(t, tn, from, from.Add(30*time.Minute))
	orphan := testutil.NewDutyStatusEvent(t, tn.ID(),
		testutil.WithUnit(tn.Unit), testutil.WithEventTime(from.Add(2*time.Minute)),
		testutil.With("status", "DR"), testutil.With("event_type", "duty_status"))

	resp := srv.AsPrincipal(c.driver(tn)).Post(
		"/api/v1/unidentified-events/"+block.String()+"/claim", nil)
	testutil.RequireStatus(t, resp, 200)

	var env struct {
		Data dto.UnidentifiedEvent `json:"data"`
	}
	resp.JSON(&env)
	require.Equal(t, "assigned", env.Data.Status)

	origin := scalar[string](t, `SELECT origin FROM duty_status_events WHERE id = $1`, orphan.ID)
	require.Equal(t, "assigned", origin)
}

// §10.4: an annotated block stays unassigned with its explanation.
func TestAnnotateUnidentified(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	from := dayStart().Add(14 * time.Hour)
	block := seedBlock(t, tn, from, from.Add(20*time.Minute))

	resp := srv.AsTenant(tn).Post("/api/v1/unidentified-events/"+block.String()+"/annotate",
		map[string]any{"annotation": "Mechanic test drive after brake repair"})
	testutil.RequireStatus(t, resp, 200)

	status := scalar[string](t, `SELECT status FROM unidentified_events WHERE id = $1`, block)
	require.Equal(t, "annotated", status)
}

// ---------------------------------------------------------------- violations

// Q57/Q58: the server persists what internal/hos computes and closes what it
// stops reporting, without ever deleting a row.
func TestViolationsArePersistedAndResolved(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)

	// 12 hours of driving breaches the 11 hour drive limit (Q10.4/Q57).
	seedEvent(t, tn, c, dayStart(), "DR", "auto")
	seedEvent(t, tn, c, dayStart().Add(12*time.Hour), "OFF", "auto")
	testutil.RequireStatus(t, certify(t, srv, tn, c), 200)

	open := decodeViolations(t, srv.AsTenant(tn).Get("/api/v1/violations",
		testutil.Query("driver_id", c.Driver.ID.String()), testutil.Query("resolved", "false")))
	types := map[string]string{}
	for _, v := range open {
		types[v.Type] = v.Severity
	}
	require.Contains(t, types, "drive_limit", "internal/hos reports the drive limit breach")
	require.Equal(t, "violation", types["drive_limit"])
	require.Contains(t, types, "break_required")
	require.Contains(t, types, "form_manner_trailer", "Q57: an empty trailer field on a certified day")
	require.Equal(t, "violation", types["form_manner_trailer"])

	// Filling the form field in and re-certifying closes the form & manner
	// violations; the rows stay with resolved_at + resolved_reason (Q58).
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE daily_logs SET trailer_ids = ARRAY[$2::uuid], shipping_doc_ids = ARRAY[$3::uuid] WHERE id = $1`,
		c.Log.ID, tn.Trailer.ID, tn.Doc.ID)
	require.NoError(t, err)
	testutil.RequireStatus(t, certify(t, srv, tn, c), 200)

	resolved := decodeViolations(t, srv.AsTenant(tn).Get("/api/v1/violations",
		testutil.Query("driver_id", c.Driver.ID.String()), testutil.Query("resolved", "true")))
	var closed *dto.Violation
	for i := range resolved {
		if resolved[i].Type == "form_manner_trailer" {
			closed = &resolved[i]
		}
	}
	require.NotNil(t, closed, "the violation is closed, never deleted")
	require.NotNil(t, closed.ResolvedAt)
	require.NotNil(t, closed.ResolvedReason)
	require.Equal(t, logs.ResolutionReason("form_manner_trailer"), *closed.ResolvedReason)

	still := scalar[int](t, `SELECT count(*) FROM violations WHERE daily_log_id = $1`, c.Log.ID)
	require.GreaterOrEqual(t, still, len(open), "no violation row is ever removed")
}

func TestViolationDetailAndCrossTenant(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, allPerms...)
	c := seedCrew(t, a)
	seedEvent(t, a, c, dayStart(), "DR", "auto")
	seedEvent(t, a, c, dayStart().Add(12*time.Hour), "OFF", "auto")
	testutil.RequireStatus(t, certify(t, srv, a, c), 200)

	rows := decodeViolations(t, srv.AsTenant(a).Get("/api/v1/violations"))
	require.NotEmpty(t, rows)

	testutil.RequireStatus(t, srv.AsTenant(a).Get("/api/v1/violations/"+rows[0].ID), 200)
	testutil.RequireStatusCode(t, srv.AsTenant(b).Get("/api/v1/violations/"+rows[0].ID), 404, "NOT_FOUND")
}

// ---------------------------------------------------------------- inspection

// Q54: the roadside token reads the 7 days + today window and can do nothing
// else — it holds no permission, so every gated route refuses it.
func TestInspectionTokenIsReadOnly(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(6*time.Hour), "ON", "auto")

	begin := srv.AsPrincipal(c.driver(tn)).Post("/api/v1/inspection/begin", nil)
	testutil.RequireStatus(t, begin, 201)
	var session struct {
		Data dto.InspectionSession `json:"data"`
	}
	begin.JSON(&session)
	require.NotEmpty(t, session.Data.Token)
	require.True(t, session.Data.ExpiresAt.After(now))

	inspector := c.driver(tn)
	inspector.Restricted = logs.RestrictionInspection
	inspector.Permissions = nil
	client := srv.AsPrincipal(inspector)

	read := client.Get("/api/v1/inspection/logs")
	testutil.RequireStatus(t, read, 200)
	var report struct {
		Data dto.InspectionReport `json:"data"`
	}
	read.JSON(&report)
	require.Equal(t, c.Driver.ID.String(), report.Data.DriverID)
	require.NotEmpty(t, report.Data.Days)

	// Everything else is closed to the roadside token.
	testutil.RequireStatus(t, client.Get("/api/v1/daily-logs/"+c.Log.ID.String()), 403)
	testutil.RequireStatus(t, client.Post("/api/v1/inspection/email",
		map[string]any{"email": "inspector@dot.gov"}), 403)
	testutil.RequireStatus(t, client.Post("/api/v1/inspection/transfer", map[string]any{}), 403)
	testutil.RequireStatus(t, client.Post("/api/v1/daily-logs/"+c.Log.ID.String()+"/certify",
		map[string]any{"signature_key": "k"}), 403)
}

// Q56: the generic profile ships a CSV + report archive.
func TestInspectionTransferGenericProfile(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(6*time.Hour), "ON", "auto")
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE companies SET regulation_profile = 'generic' WHERE id = $1`, tn.ID())
	require.NoError(t, err)

	resp := srv.AsPrincipal(c.driver(tn)).Post("/api/v1/inspection/transfer", map[string]any{})
	testutil.RequireStatus(t, resp, 200)
	var env struct {
		Data dto.InspectionTransferResult `json:"data"`
	}
	resp.JSON(&env)
	require.Equal(t, "csv_pdf_zip", env.Data.Format)
	require.Positive(t, env.Data.SizeBytes)
}

// Q55: the printable log falls back to HTML when no headless Chrome is around,
// so a roadside check never fails on a missing binary.
func TestDailyLogReportRenders(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(6*time.Hour), "ON", "auto")

	resp := srv.AsTenant(tn).Get("/api/v1/daily-logs/" + c.Log.ID.String() + "/pdf")
	testutil.RequireStatus(t, resp, 200)
	require.Contains(t, resp.Header.Get("Content-Type"), "text/html")
	require.Contains(t, resp.String(), "Driver's Daily Log")
}

// ------------------------------------------------------------- isolation

// Cross-tenant access answers 404, never 403.
func TestCrossTenantDailyLogIsNotFound(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, allPerms...)
	c := seedCrew(t, a)

	testutil.RequireStatus(t, srv.AsTenant(a).Get("/api/v1/daily-logs/"+c.Log.ID.String()), 200)
	testutil.RequireStatusCode(t, srv.AsTenant(b).Get("/api/v1/daily-logs/"+c.Log.ID.String()),
		404, "NOT_FOUND")
	testutil.RequireStatusCode(t, srv.AsTenant(b).Get("/api/v1/drivers/"+c.Driver.ID.String()+"/daily-logs"),
		404, "NOT_FOUND")
}

// Q19.1: days that left the 8 day window without a signature stay visible to
// the administrator.
func TestUncertifiedLogsReport(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	u := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))
	d := testutil.NewDriver(t, tn.ID(), testutil.WithUser(u))
	testutil.NewDailyLog(t, tn.ID(), testutil.WithDriver(d),
		testutil.WithLogDate(time.Date(2026, 8, 20, 0, 0, 0, 0, time.UTC)))

	var env struct {
		Data []dto.UncertifiedLog `json:"data"`
	}
	resp := srv.AsTenant(tn).Get("/api/v1/reports/uncertified-logs",
		testutil.Query("driver_id", d.ID.String()))
	testutil.RequireStatus(t, resp, 200)
	resp.JSON(&env)

	require.Len(t, env.Data, 1)
	require.Equal(t, "2026-08-20", env.Data[0].LogDate)
	require.Positive(t, env.Data[0].DaysOverdue)
}
