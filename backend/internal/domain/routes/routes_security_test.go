//go:build integration

// Scope regression coverage of the trip planner. The driver application is a
// `self` scoped principal (TZ A§16): it holds `routes.read` and
// `routes.complete`, so every read and every closure has to be pinned to the
// caller's own legs. A route of another driver — or of another tenant — must
// answer 404, never 403 and never a body.
package routes_test

import (
	"net/http"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/routes/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

// driverPerms is the driver application's slice of the routes module.
var driverPerms = []string{core.PermRoutesRead, core.PermRoutesComplete}

func TestDriverOnlySeesItsOwnRoutes(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)
	admin := h.srv.AsTenant(tn)

	// One leg for the tenant's own driver, one for a colleague.
	mine := decodeRoute(t, admin.Post("/api/v1/routes", createBody(tn)))

	colleague := testutil.NewDriver(t, tn.ID())
	otherUnit := testutil.NewUnit(t, tn.ID())
	body := createBody(tn)
	body["driver_id"] = colleague.ID.String()
	body["unit_id"] = otherUnit.ID.String()
	theirs := decodeRoute(t, admin.Post("/api/v1/routes", body))

	driver := h.srv.AsPrincipal(tn.DriverPrincipal(driverPerms...))

	// The list is pinned to the caller, even when it asks for the colleague.
	var env struct {
		Data []dto.Route `json:"data"`
	}
	resp := driver.Get("/api/v1/routes", testutil.Query("driver_id", colleague.ID.String()))
	testutil.RequireStatus(t, resp, http.StatusOK)
	resp.JSON(&env)
	require.Len(t, env.Data, 1, "a self scoped caller never widens its own filter")
	require.Equal(t, mine.ID, env.Data[0].ID)

	// The colleague's leg is invisible on every route level endpoint.
	testutil.RequireStatusCode(t, driver.Get("/api/v1/routes/"+theirs.ID),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, driver.Get("/api/v1/routes/"+theirs.ID+"/directions"),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, driver.Post("/api/v1/routes/"+theirs.ID+"/not-completed",
		map[string]any{"reason": dto.ReasonBreakdown, "note": "not mine"}),
		http.StatusNotFound, apierr.CodeNotFound)

	// The driver's own leg still works, so the guard is not a blanket refusal.
	testutil.RequireStatus(t, driver.Get("/api/v1/routes/"+mine.ID), http.StatusOK)
	testutil.RequireStatus(t, driver.Post("/api/v1/routes/"+mine.ID+"/not-completed",
		map[string]any{"reason": dto.ReasonBreakdown, "note": "coolant leak"}), http.StatusOK)
}

func TestDriverCannotBurnDirectionsQuotaOnAForeignRoute(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allRoutePerms...)

	colleague := testutil.NewDriver(t, tn.ID())
	body := createBody(tn)
	body["driver_id"] = colleague.ID.String()
	theirs := decodeRoute(t, h.srv.AsTenant(tn).Post("/api/v1/routes", body))

	before := h.geo.calls
	driver := h.srv.AsPrincipal(tn.DriverPrincipal(driverPerms...))
	testutil.RequireStatusCode(t, driver.Get("/api/v1/routes/"+theirs.ID+"/directions"),
		http.StatusNotFound, apierr.CodeNotFound)
	require.Equal(t, before, h.geo.calls, "a refused route must never reach the map provider")
}

func TestCrossTenantRouteIsNotFoundForEveryVerb(t *testing.T) {
	h := newHarness(t)
	a := testutil.SeedTenant(t, allRoutePerms...)
	b := testutil.SeedTenant(t, allRoutePerms...)

	route := decodeRoute(t, h.srv.AsTenant(a).Post("/api/v1/routes", createBody(a)))
	intruder := h.srv.AsTenant(b)

	testutil.RequireStatusCode(t, intruder.Get("/api/v1/routes/"+route.ID),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, intruder.Patch("/api/v1/routes/"+route.ID,
		map[string]any{"note": "hijacked"}), http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, intruder.Delete("/api/v1/routes/"+route.ID),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, intruder.Post("/api/v1/routes/"+route.ID+"/not-completed",
		map[string]any{"reason": dto.ReasonCancelled}), http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, intruder.Get("/api/v1/routes/"+route.ID+"/directions"),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestForeignUnitOrDriverIsNotFoundOnCreate(t *testing.T) {
	h := newHarness(t)
	a := testutil.SeedTenant(t, allRoutePerms...)
	b := testutil.SeedTenant(t, allRoutePerms...)
	c := h.srv.AsTenant(a)

	foreignUnit := createBody(a)
	foreignUnit["unit_id"] = b.Unit.ID.String()
	testutil.RequireStatusCode(t, c.Post("/api/v1/routes", foreignUnit),
		http.StatusNotFound, apierr.CodeNotFound)

	foreignDriver := createBody(a)
	foreignDriver["driver_id"] = b.Driver.ID.String()
	testutil.RequireStatusCode(t, c.Post("/api/v1/routes", foreignDriver),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestRouteWritesRequireTheirPermission(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, core.PermRoutesRead)
	c := h.srv.AsTenant(tn)

	testutil.RequireStatusCode(t, c.Post("/api/v1/routes", createBody(tn)),
		http.StatusForbidden, apierr.CodeForbidden)

	full := testutil.SeedTenant(t, allRoutePerms...)
	route := decodeRoute(t, h.srv.AsTenant(full).Post("/api/v1/routes", createBody(full)))

	p := full.Principal()
	p.Permissions = []string{core.PermRoutesRead}
	testutil.RequireStatusCode(t, h.srv.AsPrincipal(p).Patch("/api/v1/routes/"+route.ID,
		map[string]any{"note": "no permission"}), http.StatusForbidden, apierr.CodeForbidden)
}
