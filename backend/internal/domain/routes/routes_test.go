//go:build integration

// Integration coverage of the trip planner (TZ §13, Q66–Q68): the ongoing →
// completed / not_completed lifecycle, the two minute destination geofence
// dwell, the Q68 rule that only the current (lowest sequence) route is ever
// checked, the fixed closure reasons, the cached directions and cross-tenant
// isolation (404, never 403).
package routes_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/routes"
	"github.com/devline/onebook-eld/internal/domain/routes/dto"
	"github.com/devline/onebook-eld/internal/geo"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// allRoutePerms is every permission the module gates on.
var allRoutePerms = []string{
	core.PermRoutesRead, core.PermRoutesCreate, core.PermRoutesUpdate,
	core.PermRoutesDelete, core.PermRoutesComplete,
}

// chicago is the destination every fixture drives to.
var chicago = geo.Point{Lat: 41.8781, Lng: -87.6298}

// springfield is the origin every fixture starts from.
var springfield = geo.Point{Lat: 39.7817, Lng: -89.6501}

// baseNow is the frozen clock of the harness.
var baseNow = time.Date(2026, 9, 6, 12, 0, 0, 0, time.UTC)

// stubGeo is a directions provider that counts its calls.
type stubGeo struct{ calls int }

func (s *stubGeo) ReverseGeocode(context.Context, float64, float64) (geo.Place, error) {
	return geo.Place{}, nil
}

func (s *stubGeo) Directions(context.Context, geo.Point, geo.Point) (geo.Route, error) {
	s.calls++
	return geo.Route{DistanceM: 412345, DurationS: 15600, Polyline: "_p~iF~ps|U", Provider: "stub"}, nil
}

func (s *stubGeo) Name() string { return "stub" }

// recordingAlerter captures the alerts the module raises.
type recordingAlerter struct{ kinds []string }

func (a *recordingAlerter) Alert(_ context.Context, kind string, _ routes.Alert) error {
	a.kinds = append(a.kinds, kind)
	return nil
}

type harness struct {
	srv     *testutil.TestServer
	svc     *routes.Service
	pool    *db.Pool
	geo     *stubGeo
	alerts  *recordingAlerter
	nowFunc func() time.Time
	now     time.Time
}

func newHarness(t testing.TB) *harness {
	t.Helper()
	pool := testutil.NewDB(t)
	h := &harness{
		pool: pool, geo: &stubGeo{}, alerts: &recordingAlerter{}, now: baseNow,
	}
	h.nowFunc = func() time.Time { return h.now }

	mod := routes.New(routes.Deps{
		Repo:     routes.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger())),
		Verifier: testutil.ContextVerifier(),
		Geo:      h.geo,
		Alerter:  h.alerts,
		Log:      testutil.Logger(),
		Now:      h.nowFunc,
	})
	h.srv = testutil.NewServer(t, mod)
	h.svc = mod.Service()
	return h
}

// tenantCtx is the worker side context of one tenant, the same shape the asynq
// handler builds.
func tenantCtx(t testing.TB, companyID uuid.UUID) context.Context {
	t.Helper()
	return tenant.WithCompanyID(testutil.Ctx(t), companyID)
}

// createBody is the canonical POST /routes payload.
func createBody(tn *testutil.Tenant) map[string]any {
	return map[string]any{
		"unit_id":   tn.Unit.ID.String(),
		"driver_id": tn.Driver.ID.String(),
		"origin":    map[string]any{"text": "Springfield, IL", "lat": springfield.Lat, "lng": springfield.Lng},
		"destination": map[string]any{
			"text": "Chicago, IL", "lat": chicago.Lat, "lng": chicago.Lng,
		},
		"note": "Drop at dock 4",
	}
}

func decodeRoute(t testing.TB, resp *testutil.Response) dto.Route {
	t.Helper()
	var env struct {
		Data dto.Route `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

// seedUnitPosition writes the last known position the geofence sweep reads.
func seedUnitPosition(t testing.TB, companyID, unitID uuid.UUID, at geo.Point, ts time.Time) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO unit_last_state (unit_id, company_id, ts, lat, lng, online_status)
		 VALUES ($1,$2,$3,$4,$5,'online')
		 ON CONFLICT (unit_id) DO UPDATE SET ts = EXCLUDED.ts, lat = EXCLUDED.lat, lng = EXCLUDED.lng`,
		unitID, companyID, ts, at.Lat, at.Lng)
	require.NoError(t, err, "seed unit_last_state")
}

// ------------------------------------------------------------------- CRUD

func TestCreateAppliesTheQ66Defaults(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)

	resp := h.srv.AsTenant(tn).Post("/api/v1/routes", createBody(tn))
	testutil.RequireStatus(t, resp, http.StatusCreated)

	route := decodeRoute(t, resp)
	require.Equal(t, dto.StatusOngoing, route.Status, "a route is created ongoing, there is no manual start")
	require.Equal(t, dto.DefaultGeofenceM, route.GeofenceM, "the destination geofence defaults to 300 m")
	require.Equal(t, int32(1), route.Sequence, "the first route of a unit takes sequence 1")
	require.Equal(t, tn.Unit.ID.String(), route.UnitID)
	require.Contains(t, h.alerts.kinds, routes.AlertRouteAssigned, "the driver must be notified (Q66.1)")
}

func TestSequenceDefaultsToTheNextFreeSlot(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)
	c := h.srv.AsTenant(tn)

	first := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))
	second := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))

	require.Equal(t, int32(1), first.Sequence)
	require.Equal(t, int32(2), second.Sequence, "Q68 — several routes queue on one unit")
}

func TestUpdateIsRefusedOnATerminalRoute(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)
	c := h.srv.AsTenant(tn)

	route := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))
	testutil.RequireStatus(t, c.Post("/api/v1/routes/"+route.ID+"/not-completed",
		map[string]any{"reason": dto.ReasonBreakdown, "note": "Coolant leak"}), http.StatusOK)

	resp := c.Patch("/api/v1/routes/"+route.ID, map[string]any{"note": "changed"})
	testutil.RequireStatusCode(t, resp, http.StatusConflict, apierr.CodeInvalidState)
}

// ------------------------------------------------------------ not completed

func TestNotCompletedAcceptsOnlyTheFixedReasons(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)
	c := h.srv.AsTenant(tn)

	for _, reason := range dto.Reasons {
		route := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))
		resp := c.Post("/api/v1/routes/"+route.ID+"/not-completed",
			map[string]any{"reason": reason, "note": "documented"})
		testutil.RequireStatus(t, resp, http.StatusOK)

		closed := decodeRoute(t, resp)
		require.Equal(t, dto.StatusNotCompleted, closed.Status)
		require.Equal(t, reason, closed.NotCompletedReason)
		require.NotNil(t, closed.CompletedAt)
	}

	route := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))
	resp := c.Post("/api/v1/routes/"+route.ID+"/not-completed", map[string]any{"reason": "weather"})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestNotCompletedRequiresANoteForOther(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)
	c := h.srv.AsTenant(tn)

	route := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))
	resp := c.Post("/api/v1/routes/"+route.ID+"/not-completed", map[string]any{"reason": dto.ReasonOther})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

// ---------------------------------------------------------------- geofence

func TestGeofenceCompletesAfterTwoMinutesInside(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)
	c := h.srv.AsTenant(tn)
	route := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))
	ctx := tenantCtx(t, tn.ID())

	// 100 m from the destination: inside the 300 m circle.
	arrival := baseNow.Add(-3 * time.Minute)
	seedUnitPosition(t, tn.ID(), tn.Unit.ID,
		geo.Point{Lat: chicago.Lat + 0.0009, Lng: chicago.Lng}, arrival)

	// First sweep only starts the dwell clock.
	h.now = arrival
	n, err := h.svc.SweepGeofences(ctx)
	require.NoError(t, err)
	require.Zero(t, n, "one sample inside is not two minutes of dwell")

	after := decodeRoute(t, c.Get("/api/v1/routes/"+route.ID))
	require.Equal(t, dto.StatusOngoing, after.Status)
	require.NotNil(t, after.GeofenceEnteredAt, "the dwell clock must have started")

	// One minute later is still short of the window.
	h.now = arrival.Add(time.Minute)
	n, err = h.svc.SweepGeofences(ctx)
	require.NoError(t, err)
	require.Zero(t, n, "the dwell window is two minutes")

	// Past the window the route completes.
	h.now = arrival.Add(dto.DwellSeconds * time.Second)
	n, err = h.svc.SweepGeofences(ctx)
	require.NoError(t, err)
	require.Equal(t, 1, n)

	done := decodeRoute(t, c.Get("/api/v1/routes/"+route.ID))
	require.Equal(t, dto.StatusCompleted, done.Status)
	require.NotNil(t, done.CompletedAt)
	require.Contains(t, h.alerts.kinds, routes.AlertRouteCompleted)
}

func TestLeavingTheGeofenceRestartsTheDwellClock(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)
	c := h.srv.AsTenant(tn)
	route := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))
	ctx := tenantCtx(t, tn.ID())

	h.now = baseNow
	seedUnitPosition(t, tn.ID(), tn.Unit.ID, chicago, baseNow)
	_, err := h.svc.SweepGeofences(ctx)
	require.NoError(t, err)
	require.NotNil(t, decodeRoute(t, c.Get("/api/v1/routes/"+route.ID)).GeofenceEnteredAt)

	// The unit drove off again: 5 km away is well outside the 300 m circle.
	seedUnitPosition(t, tn.ID(), tn.Unit.ID,
		geo.Point{Lat: chicago.Lat + 0.045, Lng: chicago.Lng}, baseNow.Add(time.Minute))
	h.now = baseNow.Add(time.Minute)
	_, err = h.svc.SweepGeofences(ctx)
	require.NoError(t, err)

	after := decodeRoute(t, c.Get("/api/v1/routes/"+route.ID))
	require.Equal(t, dto.StatusOngoing, after.Status)
	require.Nil(t, after.GeofenceEnteredAt, "leaving the circle clears the dwell")

	// Even much later, the clock has to run again from scratch.
	h.now = baseNow.Add(time.Hour)
	n, err := h.svc.SweepGeofences(ctx)
	require.NoError(t, err)
	require.Zero(t, n)
}

func TestOnlyTheCurrentSequenceIsChecked(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)
	c := h.srv.AsTenant(tn)
	ctx := tenantCtx(t, tn.ID())

	// Two queued legs on the same unit. The second one's destination is where
	// the unit already is; Q68 says it must not complete before the first.
	first := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))

	secondBody := createBody(tn)
	secondBody["destination"] = map[string]any{
		"text": "Springfield, IL", "lat": springfield.Lat, "lng": springfield.Lng,
	}
	second := decodeRoute(t, c.Post("/api/v1/routes", secondBody))
	require.Equal(t, int32(2), second.Sequence)

	arrival := baseNow.Add(-10 * time.Minute)
	seedUnitPosition(t, tn.ID(), tn.Unit.ID, springfield, arrival)

	h.now = arrival
	_, err := h.svc.SweepGeofences(ctx)
	require.NoError(t, err)
	h.now = arrival.Add(5 * time.Minute)
	n, err := h.svc.SweepGeofences(ctx)
	require.NoError(t, err)
	require.Zero(t, n, "the current route's destination is Chicago, so nothing completes")

	require.Equal(t, dto.StatusOngoing, decodeRoute(t, c.Get("/api/v1/routes/"+first.ID)).Status)
	require.Equal(t, dto.StatusOngoing, decodeRoute(t, c.Get("/api/v1/routes/"+second.ID)).Status,
		"a later leg must never complete ahead of the current one")

	// Close the first leg by hand; the second becomes current and completes.
	testutil.RequireStatus(t, c.Post("/api/v1/routes/"+first.ID+"/not-completed",
		map[string]any{"reason": dto.ReasonDriverChange, "note": "swap"}), http.StatusOK)

	h.now = arrival
	_, err = h.svc.SweepGeofences(ctx)
	require.NoError(t, err)
	h.now = arrival.Add(5 * time.Minute)
	n, err = h.svc.SweepGeofences(ctx)
	require.NoError(t, err)
	require.Equal(t, 1, n)
	require.Equal(t, dto.StatusCompleted, decodeRoute(t, c.Get("/api/v1/routes/"+second.ID)).Status)
}

// -------------------------------------------------------------- directions

func TestDirectionsComeFromTheProvider(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)
	c := h.srv.AsTenant(tn)
	route := decodeRoute(t, c.Post("/api/v1/routes", createBody(tn)))

	resp := c.Get("/api/v1/routes/" + route.ID + "/directions")
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env struct {
		Data dto.Directions `json:"data"`
	}
	resp.JSON(&env)
	require.Equal(t, int64(412345), env.Data.DistanceM)
	require.Equal(t, "_p~iF~ps|U", env.Data.Polyline)
	require.Equal(t, 1, h.geo.calls)
}

// ------------------------------------------------------------ isolation

func TestCrossTenantRouteAnswersNotFound(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allRoutePerms...)

	route := decodeRoute(t, h.srv.AsTenant(a).Post("/api/v1/routes", createBody(a)))
	other := h.srv.AsTenant(b)

	testutil.RequireStatus(t, other.Get("/api/v1/routes/"+route.ID), http.StatusNotFound)
	testutil.RequireStatus(t, other.Get("/api/v1/routes/"+route.ID+"/directions"), http.StatusNotFound)
	testutil.RequireStatus(t, other.Patch("/api/v1/routes/"+route.ID,
		map[string]any{"note": "hijack"}), http.StatusNotFound)
	testutil.RequireStatus(t, other.Post("/api/v1/routes/"+route.ID+"/not-completed",
		map[string]any{"reason": dto.ReasonCancelled}), http.StatusNotFound)
	testutil.RequireStatus(t, other.Delete("/api/v1/routes/"+route.ID), http.StatusNotFound)
}

func TestCrossTenantUnitCannotBeRouted(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allRoutePerms...)

	body := createBody(a)
	body["unit_id"] = b.Unit.ID.String()
	resp := h.srv.AsTenant(a).Post("/api/v1/routes", body)
	testutil.RequireStatus(t, resp, http.StatusNotFound)
}

func TestSweepIsScopedToItsTenant(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allRoutePerms...)

	route := decodeRoute(t, h.srv.AsTenant(a).Post("/api/v1/routes", createBody(a)))
	arrival := baseNow.Add(-10 * time.Minute)
	seedUnitPosition(t, a.ID(), a.Unit.ID, chicago, arrival)

	// Sweeping the other tenant must not touch this route at all.
	h.now = arrival
	_, err := h.svc.SweepGeofences(tenantCtx(t, b.ID()))
	require.NoError(t, err)
	h.now = arrival.Add(5 * time.Minute)
	n, err := h.svc.SweepGeofences(tenantCtx(t, b.ID()))
	require.NoError(t, err)
	require.Zero(t, n)

	after := decodeRoute(t, h.srv.AsTenant(a).Get("/api/v1/routes/"+route.ID))
	require.Equal(t, dto.StatusOngoing, after.Status)
	require.Nil(t, after.GeofenceEnteredAt)
}
