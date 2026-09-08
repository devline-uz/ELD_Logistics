//go:build integration

// Integration coverage of the dashboard: every KPI card against a fixed
// fixture, the company timezone day and ISO week boundaries, the duty status
// block, today's routes and cross-tenant isolation.
package dashboard_test

import (
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/dashboard"
	"github.com/devline/onebook-eld/internal/domain/dashboard/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

// now is a Sunday 18:00 UTC = Sunday 13:00 America/Chicago, so the company day
// and the ISO week (Monday–Sunday) are both unambiguous.
var now = time.Date(2026, 9, 6, 18, 0, 0, 0, time.UTC)

func newServer(t testing.TB) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	return testutil.NewServer(t, dashboard.New(dashboard.Deps{
		Repo:     dashboard.NewRepo(pool),
		Verifier: testutil.ContextVerifier(),
		Now:      func() time.Time { return now },
	}))
}

func summary(t *testing.T, c *testutil.TestServer) dto.Summary {
	t.Helper()
	resp := c.Get("/api/v1/dashboard/summary")
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)
	var body struct {
		Data dto.Summary `json:"data"`
	}
	resp.JSON(&body)
	return body.Data
}

func seedLastState(t *testing.T, unitID, companyID uuid.UUID, ts time.Time, online string) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO unit_last_state (unit_id, company_id, ts, online_status)
		VALUES ($1,$2,$3,$4)
		ON CONFLICT (unit_id) DO UPDATE SET ts = EXCLUDED.ts, online_status = EXCLUDED.online_status`,
		unitID, companyID, ts, online)
	require.NoError(t, err)
}

func seedViolation(t *testing.T, tn *testutil.Tenant, at time.Time) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO violations (company_id, driver_id, type, severity, occurred_at)
		VALUES ($1,$2,'drive_limit','violation',$3)`, tn.ID(), tn.Driver.ID, at)
	require.NoError(t, err)
}

func seedUnidentified(t *testing.T, tn *testutil.Tenant, status string, at time.Time) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO unidentified_events (company_id, unit_id, start_at, status)
		VALUES ($1,$2,$3,$4)`, tn.ID(), tn.Unit.ID, at, status)
	require.NoError(t, err)
}

func seedRoute(t *testing.T, tn *testutil.Tenant, status string, createdAt time.Time) uuid.UUID {
	t.Helper()
	var id uuid.UUID
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t), `
		INSERT INTO routes (company_id, unit_id, driver_id, sequence, origin_text, dest_text, status, created_at)
		VALUES ($1,$2,$3,1,'Dallas, TX','Oklahoma City, OK',$4,$5) RETURNING id`,
		tn.ID(), tn.Unit.ID, tn.Driver.ID, status, createdAt).Scan(&id)
	require.NoError(t, err)
	return id
}

// dutySeq keeps every duty status event strictly newer than the DR event that
// SeedTenant writes by default.
var dutySeq int64

func setDutyStatus(t *testing.T, companyID uuid.UUID, driverID, unitID uuid.UUID, status string) {
	t.Helper()
	dutySeq++
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO duty_status_events
		  (company_id, driver_id, unit_id, event_type, status, special, event_time, time_source, origin, client_event_id)
		VALUES ($1,$2,$3,'duty_status',$4,'none',$5,'server','auto',$6)`,
		companyID, driverID, unitID, status,
		time.Now().UTC().Add(time.Duration(dutySeq)*time.Second), uuid.New())
	require.NoError(t, err)
}

func setUncertifiedLog(t *testing.T, tn *testutil.Tenant, driverID uuid.UUID, day time.Time) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO daily_logs (company_id, driver_id, log_date, certification_status)
		VALUES ($1,$2,$3,'uncertified')
		ON CONFLICT (driver_id, log_date) DO UPDATE SET certification_status = 'uncertified'`,
		tn.ID(), driverID, day)
	require.NoError(t, err)
}

// ----------------------------------------------------------------- boundaries

func TestBoundariesCutTheCompanyDayAndISOWeek(t *testing.T) {
	t.Parallel()
	loc, err := time.LoadLocation("America/Chicago")
	require.NoError(t, err)

	// Sunday belongs to the ISO week that started on the previous Monday.
	w := dashboard.Boundaries(now.In(loc), loc)
	require.Equal(t, time.Date(2026, 9, 6, 5, 0, 0, 0, time.UTC), w.DayStart)
	require.Equal(t, time.Date(2026, 9, 7, 5, 0, 0, 0, time.UTC), w.DayEnd)
	require.Equal(t, time.Date(2026, 8, 31, 5, 0, 0, 0, time.UTC), w.WeekStart)
	require.Equal(t, time.Date(2026, 9, 7, 5, 0, 0, 0, time.UTC), w.WeekEnd)
	require.Equal(t, 7*24*time.Hour, w.WeekEnd.Sub(w.WeekStart))

	// A Monday starts its own week.
	monday := time.Date(2026, 9, 7, 12, 0, 0, 0, time.UTC).In(loc)
	w = dashboard.Boundaries(monday, loc)
	require.Equal(t, w.DayStart, w.WeekStart)
}

// ------------------------------------------------------------------ KPI cards

func TestSummaryCountsEveryCard(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermDashboardRead)
	loc, err := time.LoadLocation("America/Chicago")
	require.NoError(t, err)
	windows := dashboard.Boundaries(now.In(loc), loc)

	// Active units: one reported today, one yesterday.
	seedLastState(t, tn.Unit.ID, tn.ID(), windows.DayStart.Add(2*time.Hour), "online")
	stale := testutil.NewUnit(t, tn.ID())
	seedLastState(t, stale.ID, tn.ID(), windows.DayStart.Add(-3*time.Hour), "offline")

	// Disconnected ELD.
	disconnected := testutil.NewUnit(t, tn.ID())
	seedLastState(t, disconnected.ID, tn.ID(), windows.DayStart.Add(time.Hour), "disconnected")

	// Violations: one inside the ISO week, one before it.
	seedViolation(t, tn, windows.WeekStart.Add(time.Hour))
	seedViolation(t, tn, windows.WeekStart.Add(-24*time.Hour))

	// Unassigned driving: one pending, one already assigned.
	seedUnidentified(t, tn, "pending", now.Add(-9*24*time.Hour))
	seedUnidentified(t, tn, "assigned", now.Add(-2*24*time.Hour))

	// Uncertified logs: only the ones at least two days old count.
	setUncertifiedLog(t, tn, tn.Driver.ID, now.AddDate(0, 0, -5))
	fresh := testutil.NewDriver(t, tn.ID())
	setUncertifiedLog(t, tn, fresh.ID, now)

	// Duty status block: the seeded driver goes ON, the second one stays DR.
	setDutyStatus(t, tn.ID(), tn.Driver.ID, tn.Unit.ID, "ON")
	setDutyStatus(t, tn.ID(), fresh.ID, tn.Unit.ID, "DR")

	out := summary(t, srv.AsTenant(tn))

	require.Equal(t, "America/Chicago", out.Timezone)
	require.Equal(t, windows.DayStart, out.Day.From)
	require.Equal(t, windows.WeekStart, out.Week.From)

	require.EqualValues(t, 2, out.KPI.ActiveUnits, "only units that reported today")
	require.EqualValues(t, 1, out.KPI.DisconnectedELD)
	require.EqualValues(t, 1, out.KPI.Violations, "only the current ISO week")
	require.EqualValues(t, 1, out.KPI.UnassignedDriving, "only pending events")
	require.EqualValues(t, 1, out.KPI.UncertifiedLogs, "a log is uncertified after two days")
	require.EqualValues(t, 2, out.KPI.DriversOnDuty, "ON and DR both count as on duty")
	require.EqualValues(t, 2, out.KPI.ActiveDrivers)

	require.EqualValues(t, 1, out.Status.On)
	require.EqualValues(t, 1, out.Status.DR)
	require.EqualValues(t, 0, out.Status.Off)
	require.EqualValues(t, 0, out.Status.SB)
	require.Equal(t, out.KPI.ActiveDrivers, out.Status.On+out.Status.DR+out.Status.Off+out.Status.SB)
}

func TestSummaryIsEmptyForAFreshTenant(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermDashboardRead)
	// SeedTenant writes one DR duty event and one daily log dated today.
	out := summary(t, srv.AsTenant(tn))

	require.EqualValues(t, 0, out.KPI.ActiveUnits)
	require.EqualValues(t, 0, out.KPI.Violations)
	require.EqualValues(t, 0, out.KPI.DisconnectedELD)
	require.EqualValues(t, 0, out.KPI.UnassignedDriving)
	require.EqualValues(t, 1, out.KPI.DriversOnDuty)
	require.Empty(t, out.Routes)
	require.Equal(t, now, out.GeneratedAt)
}

func TestSummaryCountsMalfunctioningDevices(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermDashboardRead)

	require.EqualValues(t, 0, summary(t, srv.AsTenant(tn)).KPI.MalfunctionELD)

	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE eld_devices SET status = 'malfunction', malfunction_codes = ARRAY['T','L'] WHERE id = $1`,
		tn.Device.ID)
	require.NoError(t, err)
	require.EqualValues(t, 1, summary(t, srv.AsTenant(tn)).KPI.MalfunctionELD)
}

// --------------------------------------------------------------------- routes

func TestRoutesBlockHoldsTodaysWork(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermDashboardRead)
	loc, err := time.LoadLocation("America/Chicago")
	require.NoError(t, err)
	windows := dashboard.Boundaries(now.In(loc), loc)

	today := seedRoute(t, tn, "ongoing", windows.DayStart.Add(3*time.Hour))
	seedRoute(t, tn, "completed", windows.DayStart.Add(-48*time.Hour))
	running := seedRoute(t, tn, "ongoing", windows.DayStart.Add(-48*time.Hour))

	out := summary(t, srv.AsTenant(tn))
	ids := map[string]bool{}
	for _, r := range out.Routes {
		ids[r.ID] = true
		require.Equal(t, tn.Unit.UnitNumber, r.UnitNumber)
		require.NotEmpty(t, r.DriverName)
	}
	require.True(t, ids[today.String()], "a route created today is listed")
	require.True(t, ids[running.String()], "a running route is listed whenever it started")
	require.Len(t, out.Routes, 2, "an old, finished route is not listed")
}

// ------------------------------------------------------------------ isolation

func TestSummaryIsScopedToTheTenant(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, core.PermDashboardRead)
	loc, err := time.LoadLocation("America/Chicago")
	require.NoError(t, err)
	windows := dashboard.Boundaries(now.In(loc), loc)

	seedLastState(t, b.Unit.ID, b.ID(), windows.DayStart.Add(time.Hour), "online")
	seedViolation(t, b, windows.WeekStart.Add(time.Hour))
	seedRoute(t, b, "ongoing", windows.DayStart.Add(time.Hour))

	out := summary(t, srv.AsTenant(a))
	require.EqualValues(t, 0, out.KPI.ActiveUnits, "another tenant's telemetry is invisible")
	require.EqualValues(t, 0, out.KPI.Violations)
	require.Empty(t, out.Routes)
}

func TestSummaryRequiresThePermission(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t) // no dashboard.read

	testutil.RequireStatusCode(t, srv.AsTenant(tn).Get("/api/v1/dashboard/summary"),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatusCode(t, srv.Anonymous().Get("/api/v1/dashboard/summary"),
		http.StatusUnauthorized, apierr.CodeUnauthorized)
}
