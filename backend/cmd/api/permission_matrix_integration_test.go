//go:build integration

package main

import (
	"fmt"
	"net/http"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/contract"
)

// compositePermissions documents the two routes gated by
// mw.RequireAnyPermission instead of mw.RequirePermission: their swag
// @x-permission only names the more specific key (swag has no syntax for an
// OR of two), so the matrix must accept either grant as authorized. Found
// while building this test — see the report for the two exact routes;
// internal/domain/tracking/http.go and internal/domain/users/http.go carry
// the RequireAnyPermission call this mirrors. Keyed by "METHOD PATH", not by
// the permission string: POST /unidentified-events/{id}/assign documents the
// same "logs.assign_unidentified" key but is a plain RequirePermission route,
// so it must not inherit the OR.
var compositePermissions = map[string][]string{
	"GET /unidentified-events": {"logs.assign_unidentified", "logs.read"},
	"GET /permissions":         {"permissions.read", "roles.read"},
}

// selfOnlyOps lists routes whose swag @x-permission is a company-wide read
// key (so office roles legitimately hold it) but whose handler additionally
// requires the caller to own a drivers row — internal/domain/duty.Service.
// DriverByUser and internal/domain/logs's selfDriver both answer
// apierr.Forbidden("the caller is not a driver") for anyone else. Found while
// building this test: POST /inspection/begin, GET /sync/pull and POST
// /unidentified-events/{id}/claim are driver-only actions layered on top of a
// broader view permission (inspection.view, logs.read, logs.claim_unidentified
// respectively), so only the Driver fixture is expected to clear them — see
// the task report for the design note.
var selfOnlyOps = map[string]bool{
	"POST /inspection/begin":               true,
	"GET /sync/pull":                       true,
	"POST /unidentified-events/{id}/claim": true,
}

func acceptedKeys(op string, permission string) []string {
	if alt, ok := compositePermissions[op]; ok {
		return alt
	}
	return []string{permission}
}

// TestPermissionMatrix is the regression shield described in the 9-bosqich
// 3-qism task: every gated operation in docs/swagger.json, crossed with every
// default role, must answer 403 exactly when the role's live role_permissions
// grants do not cover the declared @x-permission (or, for the two composite
// routes above, none of the accepted keys), and never 403 when they do. A new
// endpoint shipped without a permission gate, or with the wrong key, turns
// this red immediately.
func TestPermissionMatrix(t *testing.T) {
	app := newFullApp(t)
	fixtures := seedAllRoleFixtures(t)

	ops, err := contract.LoadOperations(contract.DefaultSwaggerPath)
	require.NoError(t, err)

	var (
		checked    int
		mismatches []string
	)
	for _, op := range ops {
		if !op.Gated() {
			continue // public/authenticated: no permission key to check, see contract_test.go
		}
		opKey := op.Method + " " + op.Path
		path := "/api/v1" + contract.ResolvePath(op.Path, func() string { return uuid.NewString() })
		accepted := acceptedKeys(opKey, op.Permission)

		for _, name := range defaultRoleNames {
			f := fixtures[name]
			granted := false
			for _, key := range accepted {
				if key == contract.SuperAdmin {
					continue // no default company role is ever a platform super admin
				}
				if has(f.Role.Permissions, key) {
					granted = true
					break
				}
			}
			if selfOnlyOps[opKey] {
				// The permission key is necessary but not sufficient: the
				// handler also requires an actual drivers row.
				granted = name == "Driver"
			}

			resp := app.Do(op.Method, path, nil, app.bearer(t, f.principal()))
			checked++

			switch {
			case !granted && resp.Code != http.StatusForbidden:
				mismatches = append(mismatches, fmt.Sprintf(
					"%-6s %-45s perm=%-28s role=%-16s: got %d, want 403 (role lacks the permission)",
					op.Method, op.Path, op.Permission, name, resp.Code))
			case granted && resp.Code == http.StatusForbidden:
				mismatches = append(mismatches, fmt.Sprintf(
					"%-6s %-45s perm=%-28s role=%-16s: got 403 though the role holds it",
					op.Method, op.Path, op.Permission, name))
			}
		}
	}

	t.Logf("permission matrix: %d gated operations x %d default roles = %d checks, %d mismatches",
		checked/len(defaultRoleNames), len(defaultRoleNames), checked, len(mismatches))
	require.Empty(t, mismatches, "permission matrix mismatches:\n%s", strings.Join(mismatches, "\n"))
}

// TestPermissionMatrixSuperAdminRoutesRejectEveryDefaultRole covers the four
// `x-permission: "super_admin"` operations (platform company management):
// they are gated by mw.RequireSuperAdmin, not a role_permissions key, so no
// default tenant role — including Administrator — may ever pass.
func TestPermissionMatrixSuperAdminRoutesRejectEveryDefaultRole(t *testing.T) {
	app := newFullApp(t)
	fixtures := seedAllRoleFixtures(t)

	ops, err := contract.LoadOperations(contract.DefaultSwaggerPath)
	require.NoError(t, err)

	var superAdminOps int
	for _, op := range ops {
		if op.Permission != contract.SuperAdmin {
			continue
		}
		superAdminOps++
		path := "/api/v1" + contract.ResolvePath(op.Path, func() string { return uuid.NewString() })
		for _, name := range defaultRoleNames {
			resp := app.Do(op.Method, path, nil, app.bearer(t, fixtures[name].principal()))
			require.Equalf(t, http.StatusForbidden, resp.Code,
				"%s %s must reject role %s (super_admin only): got %d", op.Method, op.Path, name, resp.Code)
		}
	}
	require.Positive(t, superAdminOps, "expected at least one super_admin gated operation")
}
