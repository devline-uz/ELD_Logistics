//go:build integration

// HTTP contract coverage shared by every operation in docs/swagger.json (TZ
// 9-bosqich 3-qism, item 2): the envelope shape, the auth-less/bad-id/
// unknown-id/cross-tenant status codes and the pagination bounds. The
// permission x role matrix itself lives in permission_matrix_integration_test.go.
package main

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/contract"
	"github.com/devline/onebook-eld/internal/testutil"
)

// TestContractAuthRequired asserts that every operation except the six
// documented "public" ones answers 401 without a bearer token. That includes
// the seven "authenticated" (no permission key, session only) operations:
// Authenticate still runs before RequireFullSession for those.
func TestContractAuthRequired(t *testing.T) {
	app := newFullApp(t)
	ops, err := contract.LoadOperations(contract.DefaultSwaggerPath)
	require.NoError(t, err)

	checked := 0
	for _, op := range ops {
		if op.Permission == contract.Public {
			continue
		}
		path := "/api/v1" + contract.ResolvePath(op.Path, func() string { return uuid.NewString() })
		resp := app.Do(op.Method, path, nil) // no bearer: anonymous
		checked++
		require.Equalf(t, http.StatusUnauthorized, resp.Code,
			"%s %s (perm=%s) must reject an anonymous caller: got %d %s",
			op.Method, op.Path, op.Permission, resp.Code, resp.ErrorCode())
	}
	require.Positive(t, checked)
}

// TestContractPublicRoutesNeverRequireAuth is the mirror check: the six
// public operations must not 401/403 an anonymous caller, even though most of
// them will still fail validation on an empty body.
func TestContractPublicRoutesNeverRequireAuth(t *testing.T) {
	app := newFullApp(t)
	ops, err := contract.LoadOperations(contract.DefaultSwaggerPath)
	require.NoError(t, err)

	var publicOps int
	for _, op := range ops {
		if op.Permission != contract.Public {
			continue
		}
		publicOps++
		path := "/api/v1" + contract.ResolvePath(op.Path, func() string { return uuid.NewString() })
		resp := app.Do(op.Method, path, nil)
		require.NotEqualf(t, http.StatusUnauthorized, resp.Code, "%s %s must not require auth", op.Method, op.Path)
		require.NotEqualf(t, http.StatusForbidden, resp.Code, "%s %s must not require auth", op.Method, op.Path)
	}
	require.Equal(t, 6, publicOps, "the public surface changed size; update the count deliberately")
}

// idParamOps returns every GET/DELETE operation with a {param} in its path
// and a real permission key. GET/DELETE never take a body, so id parsing is
// deterministically the first thing the handler does — unlike a POST/PATCH,
// where an empty body can legitimately fail validation before the id is even
// looked at. That determinism is what makes the bad-id and unknown-id checks
// below safe to run generically across the whole surface.
// requiresMoreThanPathID lists GET/DELETE operations whose path {id} is not
// the only thing the handler needs before it can look a row up, so an unknown
// (but valid) path id alone cannot be expected to reach a 404. Found while
// writing this test: DELETE /drivers/{id}/co-drivers additionally requires
// the co_driver_id query parameter (TZ D§3), so an id-only request 422s on
// the missing query param before ever touching the co-driver row.
var requiresMoreThanPathID = map[string]bool{
	"DELETE /drivers/{id}/co-drivers": true,
}

func idParamOps(t testing.TB) []contract.Operation {
	t.Helper()
	ops, err := contract.LoadOperations(contract.DefaultSwaggerPath)
	require.NoError(t, err)
	out := make([]contract.Operation, 0, len(ops))
	for _, op := range ops {
		if !op.Gated() || !op.HasPathParam() {
			continue
		}
		if op.Method == http.MethodGet || op.Method == http.MethodDelete {
			out = append(out, op)
		}
	}
	require.NotEmpty(t, out)
	return out
}

// TestContractMalformedID asserts a non-uuid path segment is a client error
// (400 or 422, per the task contract) rather than a 404 or 500. The caller
// holds every permission (Administrator) so the id parser is what is on test.
func TestContractMalformedID(t *testing.T) {
	app := newFullApp(t)
	admin := seedRoleFixture(t, "Administrator")

	for _, op := range idParamOps(t) {
		path := "/api/v1" + contract.ResolvePath(op.Path, func() string { return "not-a-uuid" })
		resp := app.Do(op.Method, path, nil, app.bearer(t, admin.principal()))
		require.Containsf(t, []int{http.StatusBadRequest, http.StatusUnprocessableEntity}, resp.Code,
			"%s %s: malformed id must be a 400/422, got %d %s", op.Method, op.Path, resp.Code, resp.ErrorCode())
	}
}

// TestContractUnknownID asserts a syntactically valid but nonexistent id is a
// 404, never a 403 or 500: RLS filters on company_id, so "not mine" and "does
// not exist" are the same NOT FOUND row set and must answer identically
// (Q-note: this also covers cross-tenant reads structurally — see
// TestContractCrossTenantIsNotFound for a concrete two-tenant proof on a
// couple of resource families).
func TestContractUnknownID(t *testing.T) {
	app := newFullApp(t)
	admin := seedRoleFixture(t, "Administrator")

	for _, op := range idParamOps(t) {
		if requiresMoreThanPathID[op.Method+" "+op.Path] {
			continue
		}
		path := "/api/v1" + contract.ResolvePath(op.Path, func() string { return uuid.NewString() })
		resp := app.Do(op.Method, path, nil, app.bearer(t, admin.principal()))
		require.Equalf(t, http.StatusNotFound, resp.Code,
			"%s %s: unknown id must be 404, got %d %s", op.Method, op.Path, resp.Code, resp.ErrorCode())
		require.Equal(t, apierr.CodeNotFound, resp.ErrorCode())
	}
}

// TestContractCrossTenantIsNotFound proves, with two real companies and a
// real row, that a foreign id is 404 (never 403) on a couple of representative
// resource families. It complements the id-shaped equivalence argument above
// with an end-to-end check that RLS is actually wired on these routes.
func TestContractCrossTenantIsNotFound(t *testing.T) {
	app := newFullApp(t)
	adminA := seedRoleFixture(t, "Administrator")
	_ = seedRoleFixture(t, "Administrator") // company B, unused fixture beyond its id

	companyB := testutil.NewCompany(t)
	unitB := testutil.NewUnit(t, companyB.ID)
	driverB := testutil.NewDriver(t, companyB.ID)

	cases := []struct {
		method, path string
	}{
		{http.MethodGet, "/api/v1/units/" + unitB.ID.String()},
		{http.MethodGet, "/api/v1/drivers/" + driverB.ID.String()},
	}
	for _, c := range cases {
		resp := app.Do(c.method, c.path, nil, app.bearer(t, adminA.principal()))
		require.Equalf(t, http.StatusNotFound, resp.Code,
			"%s %s across tenants must be 404, got %d", c.method, c.path, resp.Code)
	}
}

// TestContractListEnvelope checks the {"data":[...],"meta":{...}} shape and
// TestContractItemEnvelope the {"data":{...}} shape (eld-api-contract).
func TestContractListEnvelope(t *testing.T) {
	app := newFullApp(t)
	admin := seedRoleFixture(t, "Administrator")
	testutil.NewUnit(t, admin.Company.ID)

	resp := app.Do(http.MethodGet, "/api/v1/units", nil, app.bearer(t, admin.principal()))
	require.Equal(t, http.StatusOK, resp.Code)

	var env struct {
		Data []json.RawMessage `json:"data"`
		Meta struct {
			Page    int   `json:"page"`
			PerPage int   `json:"per_page"`
			Total   int64 `json:"total"`
		} `json:"meta"`
	}
	resp.JSON(&env)
	require.NotEmpty(t, env.Data)
	require.Equal(t, 1, env.Meta.Page)
	require.Positive(t, env.Meta.PerPage)
	require.GreaterOrEqual(t, env.Meta.Total, int64(len(env.Data)))
}

func TestContractItemEnvelope(t *testing.T) {
	app := newFullApp(t)
	admin := seedRoleFixture(t, "Administrator")
	unit := testutil.NewUnit(t, admin.Company.ID)

	resp := app.Do(http.MethodGet, "/api/v1/units/"+unit.ID.String(), nil, app.bearer(t, admin.principal()))
	require.Equal(t, http.StatusOK, resp.Code)

	var env struct {
		Data struct {
			ID string `json:"id"`
		} `json:"data"`
	}
	resp.JSON(&env)
	require.Equal(t, unit.ID.String(), env.Data.ID)
}

// TestContractErrorEnvelope checks the {"error":{"code","message"}} shape.
func TestContractErrorEnvelope(t *testing.T) {
	app := newFullApp(t)
	admin := seedRoleFixture(t, "Administrator")

	resp := app.Do(http.MethodGet, "/api/v1/units/"+uuid.NewString(), nil, app.bearer(t, admin.principal()))
	require.Equal(t, http.StatusNotFound, resp.Code)

	var env struct {
		Error struct {
			Code    string `json:"code"`
			Message string `json:"message"`
		} `json:"error"`
	}
	resp.JSON(&env)
	require.Equal(t, apierr.CodeNotFound, env.Error.Code)
	require.NotEmpty(t, env.Error.Message)
}

// TestContractPagination asserts the bounds enforced by
// internal/httpx.ParsePagination: per_page must be one of {10,25,50}
// (TZ B§18.3) and page must be a positive integer.
func TestContractPagination(t *testing.T) {
	app := newFullApp(t)
	admin := seedRoleFixture(t, "Administrator")
	opts := app.bearer(t, admin.principal())

	for _, perPage := range []string{"10", "25", "50"} {
		resp := app.Do(http.MethodGet, "/api/v1/units", nil, opts, testutil.Query("per_page", perPage))
		require.Equalf(t, http.StatusOK, resp.Code, "per_page=%s must be accepted", perPage)
	}

	for _, bad := range []struct{ key, value string }{
		{"page", "0"},
		{"page", "-1"},
		{"per_page", "0"},
		{"per_page", "-1"},
		{"per_page", "30"},
		{"per_page", "101"},
	} {
		resp := app.Do(http.MethodGet, "/api/v1/units", nil, opts, testutil.Query(bad.key, bad.value))
		require.Equalf(t, http.StatusUnprocessableEntity, resp.Code, "%s=%s must be 422", bad.key, bad.value)
		require.Equal(t, apierr.CodeValidationError, resp.ErrorCode())
	}
}
