//go:build integration

// Branch scope regression coverage of the trip planner (TZ A§16 / Q82).
//
// A `branch` scoped role — a branch manager holding the routes permissions —
// must only ever see and touch the legs of the drivers domiciled in its own
// branch. The visibility axis is drivers.branch_id, not units.branch_id: a
// route is an assignment handed to a driver, the notification goes to that
// driver, and every other branch aware module of the codebase (logs, duty,
// chat, unidentified) partitions on the driver's branch as well. The unit is
// still checked on write, so a branch manager cannot pull another branch's
// truck into its own dispatch.
package routes_test

import (
	"net/http"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/routes/dto"
	httpxdto "github.com/devline/onebook-eld/internal/httpx/dto"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// branchPrincipal builds a `branch` scoped principal pinned to branchID.
func branchPrincipal(tn *testutil.Tenant, branchID uuid.UUID, permissions ...string) *tenant.Principal {
	p := tn.Principal()
	p.Scope = tenant.ScopeBranch
	p.BranchID = &branchID
	if len(permissions) > 0 {
		p.Permissions = permissions
	}
	return p
}

// branchFixture seeds two branches, each with its own driver and unit, and one
// route per branch.
type branchFixture struct {
	tn                 *testutil.Tenant
	north, south       testutil.Branch
	northRoute         dto.Route
	southRoute         dto.Route
	southDriverID      uuid.UUID
	southUnitID        uuid.UUID
	northDriverID      uuid.UUID
	northUnitID        uuid.UUID
	unbranchedUnitID   uuid.UUID
	unbranchedDriverID uuid.UUID
}

func seedBranches(t testing.TB, h *harness) branchFixture {
	t.Helper()
	tn := testutil.SeedTenant(t, allRoutePerms...)
	admin := h.srv.AsTenant(tn)

	north := tn.Branch
	south := testutil.NewBranch(t, tn.ID())

	newLeg := func(branch *testutil.Branch) (uuid.UUID, uuid.UUID, dto.Route) {
		var driverOpts, unitOpts []testutil.Option
		if branch != nil {
			driverOpts = append(driverOpts, testutil.WithBranch(*branch))
			unitOpts = append(unitOpts, testutil.WithBranch(*branch))
		}
		user := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))
		driver := testutil.NewDriver(t, tn.ID(), append(driverOpts, testutil.WithUser(user))...)
		unit := testutil.NewUnit(t, tn.ID(), unitOpts...)

		body := createBody(tn)
		body["driver_id"] = driver.ID.String()
		body["unit_id"] = unit.ID.String()
		resp := admin.Post("/api/v1/routes", body)
		testutil.RequireStatus(t, resp, http.StatusCreated)
		return driver.ID, unit.ID, decodeRoute(t, resp)
	}

	f := branchFixture{tn: tn, north: north, south: south}
	f.northDriverID, f.northUnitID, f.northRoute = newLeg(&north)
	f.southDriverID, f.southUnitID, f.southRoute = newLeg(&south)
	f.unbranchedDriverID, f.unbranchedUnitID, _ = newLeg(nil)
	return f
}

func TestBranchManagerOnlySeesItsOwnBranchRoutes(t *testing.T) {
	h := newHarness(t)
	f := seedBranches(t, h)

	mgr := h.srv.AsPrincipal(branchPrincipal(f.tn, f.north.ID, allRoutePerms...))

	var env struct {
		Data []dto.Route   `json:"data"`
		Meta httpxdto.Meta `json:"meta"`
	}
	resp := mgr.Get("/api/v1/routes")
	testutil.RequireStatus(t, resp, http.StatusOK)
	resp.JSON(&env)

	ids := make([]string, 0, len(env.Data))
	for _, r := range env.Data {
		ids = append(ids, r.ID)
	}
	require.Contains(t, ids, f.northRoute.ID)
	require.NotContains(t, ids, f.southRoute.ID,
		"a branch manager must never see another branch's leg")
	require.Equal(t, int64(len(env.Data)), env.Meta.Total,
		"the total has to be counted with the same branch predicate as the page")

	// A branch manager cannot widen its own filter through the query string.
	resp = mgr.Get("/api/v1/routes", testutil.Query("driver_id", f.southDriverID.String()))
	testutil.RequireStatus(t, resp, http.StatusOK)
	env.Data = nil
	resp.JSON(&env)
	require.Empty(t, env.Data, "driver_id must not escape the branch predicate")
}

func TestBranchManagerCannotReachAnotherBranchRoute(t *testing.T) {
	h := newHarness(t)
	f := seedBranches(t, h)

	mgr := h.srv.AsPrincipal(branchPrincipal(f.tn, f.north.ID, allRoutePerms...))
	foreign := "/api/v1/routes/" + f.southRoute.ID

	// Read, edit, close and delete all answer 404 — existence stays hidden.
	testutil.RequireStatusCode(t, mgr.Get(foreign), http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, mgr.Get(foreign+"/directions"),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, mgr.Patch(foreign, map[string]any{"note": "mine now"}),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, mgr.Post(foreign+"/not-completed",
		map[string]any{"reason": dto.ReasonBreakdown, "note": "not mine"}),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, mgr.Delete(foreign), http.StatusNotFound, apierr.CodeNotFound)

	// The manager's own leg still works, so the guard is not a blanket refusal.
	testutil.RequireStatus(t, mgr.Get("/api/v1/routes/"+f.northRoute.ID), http.StatusOK)
}

func TestBranchManagerCannotAssignAcrossBranches(t *testing.T) {
	h := newHarness(t)
	f := seedBranches(t, h)

	mgr := h.srv.AsPrincipal(branchPrincipal(f.tn, f.north.ID, allRoutePerms...))

	// A foreign driver is a 404 on `driver`, a foreign unit a 404 on `unit`:
	// neither may be enumerated through the create endpoint.
	body := createBody(f.tn)
	body["driver_id"] = f.southDriverID.String()
	body["unit_id"] = f.northUnitID.String()
	testutil.RequireStatusCode(t, mgr.Post("/api/v1/routes", body),
		http.StatusNotFound, apierr.CodeNotFound)

	body = createBody(f.tn)
	body["driver_id"] = f.northDriverID.String()
	body["unit_id"] = f.southUnitID.String()
	testutil.RequireStatusCode(t, mgr.Post("/api/v1/routes", body),
		http.StatusNotFound, apierr.CodeNotFound)

	// A row without a branch is not "everyone's": it stays invisible too.
	body = createBody(f.tn)
	body["driver_id"] = f.unbranchedDriverID.String()
	body["unit_id"] = f.northUnitID.String()
	testutil.RequireStatusCode(t, mgr.Post("/api/v1/routes", body),
		http.StatusNotFound, apierr.CodeNotFound)

	// Its own branch on both sides is accepted.
	body = createBody(f.tn)
	body["driver_id"] = f.northDriverID.String()
	body["unit_id"] = f.northUnitID.String()
	testutil.RequireStatus(t, mgr.Post("/api/v1/routes", body), http.StatusCreated)

	// Reassignment is guarded the same way as creation.
	testutil.RequireStatusCode(t,
		mgr.Patch("/api/v1/routes/"+f.northRoute.ID,
			map[string]any{"driver_id": f.southDriverID.String()}),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t,
		mgr.Patch("/api/v1/routes/"+f.northRoute.ID,
			map[string]any{"unit_id": f.southUnitID.String()}),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestCompanyScopeStillSeesEveryBranch(t *testing.T) {
	h := newHarness(t)
	f := seedBranches(t, h)

	var env struct {
		Data []dto.Route `json:"data"`
	}
	resp := h.srv.AsTenant(f.tn).Get("/api/v1/routes")
	testutil.RequireStatus(t, resp, http.StatusOK)
	resp.JSON(&env)

	ids := make([]string, 0, len(env.Data))
	for _, r := range env.Data {
		ids = append(ids, r.ID)
	}
	require.Contains(t, ids, f.northRoute.ID)
	require.Contains(t, ids, f.southRoute.ID,
		"the branch predicate must not leak into a company scoped caller")
}
