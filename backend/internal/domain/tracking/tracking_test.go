//go:build integration

// Integration coverage of the tracking module: the live map and its four ELD
// states, the company timezone day boundary of the trip list, the trip detail
// track, the unidentified driving buffer, branch scoping and cross-tenant
// isolation (404, never 403).
package tracking_test

import (
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/tracking"
	"github.com/devline/onebook-eld/internal/domain/tracking/dto"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// allTrackingPerms is every permission the module gates on.
var allTrackingPerms = []string{
	core.PermTrackingViewLive, core.PermTrackingViewHistory,
	core.PermLogsAssignUnidentified, core.PermLogsRead,
}

var now = time.Date(2026, 9, 6, 18, 0, 0, 0, time.UTC)

func newServer(t testing.TB) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	return testutil.NewServer(t, tracking.New(tracking.Deps{
		Repo:     tracking.NewRepo(pool),
		Verifier: testutil.ContextVerifier(),
		Now:      func() time.Time { return now },
	}))
}

func f(v float64) *float64 { return &v }

// ------------------------------------------------------------ live tracking

func TestLiveReturnsLastKnownState(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allTrackingPerms...)
	seedLastState(t, tn.Unit.ID, tn.ID(), stateOpts{
		ts: now.Add(-2 * time.Minute), lat: f(31.52), lng: f(74.35), speed: f(62.5),
		odometer: 128430000, duty: "DR", driverID: &tn.Driver.ID, online: "online",
	})

	resp := srv.AsTenant(tn).Get("/api/v1/tracking/live")
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	units := decodeLive(t, resp)
	require.Len(t, units, 1)
	u := units[0]
	require.Equal(t, tn.Unit.ID.String(), u.UnitID)
	require.Equal(t, dto.OnlineStatusOnline, u.OnlineStatus)
	require.InDelta(t, 31.52, *u.Lat, 1e-9)
	require.InDelta(t, 62.5, *u.SpeedKmh, 1e-9)
	require.EqualValues(t, 128430000, *u.OdometerM)
	require.Equal(t, "DR", u.DutyStatus)
	require.NotNil(t, u.Driver)
	require.Equal(t, tn.Driver.ID.String(), u.Driver.ID)
	require.NotNil(t, u.LastSeenAt)
}

func TestLiveDerivesTheFourEldStates(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allTrackingPerms...)
	c := srv.AsTenant(tn)

	// TZ §10.1 — Offline: the last state is known but stale. Freshness is a
	// stored decision, so `offline` on the row is reported as Offline.
	seedLastState(t, tn.Unit.ID, tn.ID(), stateOpts{ts: now.Add(-time.Hour), online: "offline"})
	require.Equal(t, dto.OnlineStatusOffline, liveOf(t, c, tn.Unit.ID).OnlineStatus)

	// Disconnected: the ELD announced losing the phone link.
	setOnlineStatus(t, tn.Unit.ID, "disconnected")
	require.Equal(t, dto.OnlineStatusDisconnected, liveOf(t, c, tn.Unit.ID).OnlineStatus)

	// Malfunction wins over the connectivity state (§10.5).
	setOnlineStatus(t, tn.Unit.ID, "online")
	setMalfunction(t, tn.Device.ID, []string{"T", "L"})
	u := liveOf(t, c, tn.Unit.ID)
	require.Equal(t, dto.OnlineStatusMalfunction, u.OnlineStatus)
	require.Equal(t, []string{"T", "L"}, u.MalfunctionCodes)

	setMalfunction(t, tn.Device.ID, []string{})
	require.Equal(t, dto.OnlineStatusOnline, liveOf(t, c, tn.Unit.ID).OnlineStatus)
}

func TestLiveFiltersByUnitIDsAndStatus(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allTrackingPerms...)
	other := testutil.NewUnit(t, tn.ID())
	seedLastState(t, tn.Unit.ID, tn.ID(), stateOpts{ts: now, online: "online"})
	seedLastState(t, other.ID, tn.ID(), stateOpts{ts: now.Add(-time.Hour), online: "offline"})
	c := srv.AsTenant(tn)

	all := decodeLive(t, c.Get("/api/v1/tracking/live"))
	require.Len(t, all, 2)

	only := decodeLive(t, c.Get("/api/v1/tracking/live", testutil.Query("unit_ids", tn.Unit.ID.String())))
	require.Len(t, only, 1)
	require.Equal(t, tn.Unit.ID.String(), only[0].UnitID)

	offline := decodeLive(t, c.Get("/api/v1/tracking/live", testutil.Query("online_status", "offline")))
	require.Len(t, offline, 1)
	require.Equal(t, other.ID.String(), offline[0].UnitID)

	bad := c.Get("/api/v1/tracking/live", testutil.Query("online_status", "nope"))
	testutil.RequireStatusCode(t, bad, http.StatusUnprocessableEntity, apierr.CodeValidationError)

	badIDs := c.Get("/api/v1/tracking/live", testutil.Query("unit_ids", "not-a-uuid"))
	testutil.RequireStatusCode(t, badIDs, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestLiveIsBranchScoped(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allTrackingPerms...)
	otherBranch := testutil.NewBranch(t, tn.ID())

	mine := testutil.NewUnit(t, tn.ID(), testutil.WithBranch(tn.Branch))
	theirs := testutil.NewUnit(t, tn.ID(), testutil.WithBranch(otherBranch))
	seedLastState(t, mine.ID, tn.ID(), stateOpts{ts: now, online: "online"})
	seedLastState(t, theirs.ID, tn.ID(), stateOpts{ts: now, online: "online"})

	branchID := tn.Branch.ID
	p := tn.Principal()
	p.Scope = tenant.ScopeBranch
	p.BranchID = &branchID

	units := decodeLive(t, srv.AsPrincipal(p).Get("/api/v1/tracking/live"))
	require.Len(t, units, 1)
	require.Equal(t, mine.ID.String(), units[0].UnitID)
}

func TestLiveNeverCrossesTheTenantBoundary(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, other := testutil.SeedTwoCompanies(t, allTrackingPerms...)
	seedLastState(t, a.Unit.ID, a.ID(), stateOpts{ts: now, online: "online"})
	seedLastState(t, other.Unit.ID, other.ID(), stateOpts{ts: now, online: "online"})

	units := decodeLive(t, srv.AsTenant(a).Get("/api/v1/tracking/live"))
	require.Len(t, units, 1)
	require.Equal(t, a.Unit.ID.String(), units[0].UnitID)
}

func TestLiveRequiresItsPermission(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermTrackingViewHistory)
	testutil.RequireStatusCode(t, srv.AsTenant(tn).Get("/api/v1/tracking/live"),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatus(t, srv.Anonymous().Get("/api/v1/tracking/live"), http.StatusUnauthorized)
}

// ------------------------------------------------------------------- trips

func TestUnitTripsUseTheCompanyTimezoneDay(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allTrackingPerms...)
	setTimezone(t, tn.ID(), "America/Chicago")

	// 2026-09-06 in America/Chicago (UTC-5 in September) runs from
	// 05:00Z that day to 05:00Z the next.
	inside := seedTrip(t, tn, now.Add(-8*time.Hour), now.Add(-7*time.Hour))  // 10:00Z
	early := seedTrip(t, tn, now.Add(-14*time.Hour), now.Add(-13*time.Hour)) // 04:00Z, previous local day
	c := srv.AsTenant(tn)

	trips := decodeTrips(t, c.Get("/api/v1/units/"+tn.Unit.ID.String()+"/trips",
		testutil.Query("date", "2026-09-06")))
	require.Len(t, trips, 1)
	require.Equal(t, inside.String(), trips[0].ID)

	prev := decodeTrips(t, c.Get("/api/v1/units/"+tn.Unit.ID.String()+"/trips",
		testutil.Query("date", "2026-09-05")))
	require.Len(t, prev, 1)
	require.Equal(t, early.String(), prev[0].ID)

	// Without an explicit date the window is today in the company timezone.
	today := decodeTrips(t, c.Get("/api/v1/units/"+tn.Unit.ID.String()+"/trips"))
	require.Len(t, today, 1)
	require.Equal(t, inside.String(), today[0].ID)
}

func TestUnitTripsRejectBadDateAndCrossTenantUnit(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, other := testutil.SeedTwoCompanies(t, allTrackingPerms...)
	c := srv.AsTenant(a)

	testutil.RequireStatusCode(t, c.Get("/api/v1/units/"+a.Unit.ID.String()+"/trips",
		testutil.Query("date", "06-09-2026")), http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// Cross-tenant is 404, never 403.
	testutil.RequireStatusCode(t, c.Get("/api/v1/units/"+other.Unit.ID.String()+"/trips"),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, c.Get("/api/v1/units/"+uuid.NewString()+"/trips"),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestUnitTripsAreBranchScoped(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allTrackingPerms...)
	otherBranch := testutil.NewBranch(t, tn.ID())
	setUnitBranch(t, tn.Unit.ID, otherBranch.ID)

	branchID := tn.Branch.ID
	p := tn.Principal()
	p.Scope = tenant.ScopeBranch
	p.BranchID = &branchID

	testutil.RequireStatusCode(t, srv.AsPrincipal(p).Get("/api/v1/units/"+tn.Unit.ID.String()+"/trips"),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestTripDetailCarriesTheTrack(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allTrackingPerms...)
	start := now.Add(-3 * time.Hour)
	tripID := seedTrip(t, tn, start, start.Add(30*time.Minute))
	seedTelemetry(t, tn, start, 4)

	resp := srv.AsTenant(tn).Get("/api/v1/trips/" + tripID.String())
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env dto.TripEnvelope
	resp.JSON(&env)
	require.Equal(t, tripID.String(), env.Data.ID)
	require.Equal(t, tn.Unit.UnitNumber, env.Data.UnitNumber)
	require.False(t, env.Data.Open)
	require.EqualValues(t, 152300, env.Data.DistanceM)
	require.Equal(t, 4, env.Data.PointCount)
	require.NotEmpty(t, env.Data.Polyline)
	require.NotNil(t, env.Data.PolylineKey)

	// include_polyline=false keeps the response small for list views.
	plain := srv.AsTenant(tn).Get("/api/v1/trips/"+tripID.String(), testutil.Query("include_polyline", "false"))
	testutil.RequireStatus(t, plain, http.StatusOK)
	plain.JSON(&env)
	require.Empty(t, env.Data.Polyline)
	require.Zero(t, env.Data.PointCount)
}

func TestTripDetailCrossTenantIs404(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, other := testutil.SeedTwoCompanies(t, allTrackingPerms...)
	tripID := seedTrip(t, other, now.Add(-2*time.Hour), now.Add(-time.Hour))

	testutil.RequireStatusCode(t, srv.AsTenant(a).Get("/api/v1/trips/"+tripID.String()),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestTripEndpointsRequireHistoryPermission(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermTrackingViewLive)
	c := srv.AsTenant(tn)

	testutil.RequireStatusCode(t, c.Get("/api/v1/units/"+tn.Unit.ID.String()+"/trips"),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatusCode(t, c.Get("/api/v1/trips/"+uuid.NewString()),
		http.StatusForbidden, apierr.CodeForbidden)
}

// ---------------------------------------------------------- unidentified

func TestUnidentifiedEventsListAndFilters(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allTrackingPerms...)
	pending := seedUnidentified(t, tn, now.Add(-10*24*time.Hour), "pending")
	assigned := seedUnidentified(t, tn, now.Add(-2*24*time.Hour), "assigned")
	c := srv.AsTenant(tn)

	all := decodeUnidentified(t, c.Get("/api/v1/unidentified-events"))
	require.Len(t, all, 2)

	only := decodeUnidentified(t, c.Get("/api/v1/unidentified-events", testutil.Query("status", "pending")))
	require.Len(t, only, 1)
	require.Equal(t, pending.String(), only[0].ID)
	// A§10.4: beyond 8 pending days the admin alert fires.
	require.Equal(t, 10, only[0].PendingDays)

	byUnit := decodeUnidentified(t, c.Get("/api/v1/unidentified-events",
		testutil.Query("unit_id", tn.Unit.ID.String())))
	require.Len(t, byUnit, 2)

	window := decodeUnidentified(t, c.Get("/api/v1/unidentified-events",
		testutil.Query("from", now.Add(-3*24*time.Hour).Format(time.RFC3339))))
	require.Len(t, window, 1)
	require.Equal(t, assigned.String(), window[0].ID)
	require.Zero(t, window[0].PendingDays, "pending_days only applies to pending events")

	testutil.RequireStatusCode(t, c.Get("/api/v1/unidentified-events", testutil.Query("status", "nope")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestUnidentifiedEventsNeverCrossTheTenantBoundary(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, other := testutil.SeedTwoCompanies(t, allTrackingPerms...)
	seedUnidentified(t, other, now.Add(-time.Hour), "pending")

	require.Empty(t, decodeUnidentified(t, srv.AsTenant(a).Get("/api/v1/unidentified-events")))
}

func TestUnidentifiedEventsAcceptEitherPermission(t *testing.T) {
	t.Parallel()
	srv := newServer(t)

	assign := testutil.SeedTenant(t, core.PermLogsAssignUnidentified)
	testutil.RequireStatus(t, srv.AsTenant(assign).Get("/api/v1/unidentified-events"), http.StatusOK)

	read := testutil.SeedTenant(t, core.PermLogsRead)
	testutil.RequireStatus(t, srv.AsTenant(read).Get("/api/v1/unidentified-events"), http.StatusOK)

	none := testutil.SeedTenant(t, core.PermTrackingViewLive)
	testutil.RequireStatusCode(t, srv.AsTenant(none).Get("/api/v1/unidentified-events"),
		http.StatusForbidden, apierr.CodeForbidden)
}

// ------------------------------------------------------------------ helpers

func decodeLive(t testing.TB, resp *testutil.Response) []dto.LiveUnit {
	t.Helper()
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.LiveUnitListEnvelope
	resp.JSON(&env)
	return env.Data
}

func liveOf(t testing.TB, c *testutil.TestServer, unitID uuid.UUID) dto.LiveUnit {
	t.Helper()
	units := decodeLive(t, c.Get("/api/v1/tracking/live", testutil.Query("unit_ids", unitID.String())))
	require.Len(t, units, 1)
	return units[0]
}

func decodeTrips(t testing.TB, resp *testutil.Response) []dto.Trip {
	t.Helper()
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.TripListEnvelope
	resp.JSON(&env)
	return env.Data
}

func decodeUnidentified(t testing.TB, resp *testutil.Response) []dto.UnidentifiedEvent {
	t.Helper()
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.UnidentifiedEventListEnvelope
	resp.JSON(&env)
	return env.Data
}

type stateOpts struct {
	ts       time.Time
	lat      *float64
	lng      *float64
	speed    *float64
	odometer int64
	duty     string
	driverID *uuid.UUID
	online   string
}

func seedLastState(t testing.TB, unitID, companyID uuid.UUID, o stateOpts) {
	t.Helper()
	var duty *string
	if o.duty != "" {
		duty = &o.duty
	}
	var odo *int64
	if o.odometer != 0 {
		odo = &o.odometer
	}
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO unit_last_state (unit_id, company_id, ts, lat, lng, speed_kmh, odometer_m, duty_status, driver_id, online_status)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		ON CONFLICT (unit_id) DO UPDATE SET ts = EXCLUDED.ts, online_status = EXCLUDED.online_status`,
		unitID, companyID, o.ts, o.lat, o.lng, o.speed, odo, duty, o.driverID, o.online)
	require.NoError(t, err)
}

func setOnlineStatus(t testing.TB, unitID uuid.UUID, status string) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE unit_last_state SET online_status = $2 WHERE unit_id = $1`, unitID, status)
	require.NoError(t, err)
}

func setMalfunction(t testing.TB, deviceID uuid.UUID, codes []string) {
	t.Helper()
	status := "active"
	if len(codes) > 0 {
		status = "malfunction"
	}
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE eld_devices SET malfunction_codes = $2, status = $3 WHERE id = $1`, deviceID, codes, status)
	require.NoError(t, err)
}

func setTimezone(t testing.TB, companyID uuid.UUID, tz string) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE companies SET timezone = $2 WHERE id = $1`, companyID, tz)
	require.NoError(t, err)
}

func setUnitBranch(t testing.TB, unitID, branchID uuid.UUID) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE units SET branch_id = $2 WHERE id = $1`, unitID, branchID)
	require.NoError(t, err)
}

func seedTrip(t testing.TB, tn *testutil.Tenant, start, end time.Time) uuid.UUID {
	t.Helper()
	id := uuid.New()
	key := "tenant/trips/2026/09/" + id.String() + ".polyline"
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO trips (id, company_id, unit_id, driver_id, start_at, end_at,
		                   start_lat, start_lng, end_lat, end_lng,
		                   distance_m, duration_sec, max_speed_kmh, polyline_key)
		VALUES ($1,$2,$3,$4,$5,$6, 31.50, 74.30, 31.98, 74.91, 152300, 9120, 104.2, $7)`,
		id, tn.ID(), tn.Unit.ID, tn.Driver.ID, start, end, key)
	require.NoError(t, err)
	return id
}

// seedTelemetry writes n fixes one minute apart, from which the trip detail
// rebuilds its polyline.
func seedTelemetry(t testing.TB, tn *testutil.Tenant, start time.Time, n int) {
	t.Helper()
	for i := 0; i < n; i++ {
		_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
			INSERT INTO telemetry (ts, company_id, unit_id, lat, lng, speed_kmh, ignition, source)
			VALUES ($1,$2,$3,$4,$5,$6,true,'eld')`,
			start.Add(time.Duration(i)*time.Minute), tn.ID(), tn.Unit.ID,
			31.50+float64(i)/100, 74.30+float64(i)/100, 60.0)
		require.NoError(t, err)
	}
}

func seedUnidentified(t testing.TB, tn *testutil.Tenant, start time.Time, status string) uuid.UUID {
	t.Helper()
	id := uuid.New()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO unidentified_events (id, company_id, unit_id, eld_device_id, start_at, end_at, distance_m, status)
		VALUES ($1,$2,$3,$4,$5,$6,8400,$7)`,
		id, tn.ID(), tn.Unit.ID, tn.Device.ID, start, start.Add(19*time.Minute), status)
	require.NoError(t, err)
	return id
}
