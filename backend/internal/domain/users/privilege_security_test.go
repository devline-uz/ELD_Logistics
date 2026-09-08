//go:build integration

// Least privilege regression coverage: neither the role editor nor the role
// assignment may hand out a permission the caller does not already hold.
package users_test

import (
	"net/http"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/users/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

// roleEditorPermissions is the smallest set that reaches the role and user
// editors: exactly the "Sub Admin"-shaped principal an attacker would own.
func roleEditorPermissions() []string {
	return []string{
		core.PermRolesRead, core.PermRolesCreate, core.PermRolesUpdate, core.PermRolesDelete,
		core.PermUsersRead, core.PermUsersCreate, core.PermUsersUpdate,
		core.PermUnitsRead,
	}
}

// A principal holding roles.create must not be able to mint a role carrying
// company.update / users.delete and then step into it.
func TestCreateRoleCannotGrantPermissionsTheCallerLacks(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, roleEditorPermissions()...)

	resp := h.srv.AsTenant(tn).Post("/api/v1/roles", map[string]any{
		"name":        "Escalation",
		"scope":       "company",
		"permissions": []string{core.PermUnitsRead, core.PermCompanyUpdate, core.PermUsersDelete},
	})
	testutil.RequireStatusCode(t, resp, http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireNoPII(t, resp.Body)
}

// The same role may still be defined out of permissions the caller holds.
func TestCreateRoleAllowsPermissionsTheCallerHolds(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, roleEditorPermissions()...)

	resp := h.srv.AsTenant(tn).Post("/api/v1/roles", map[string]any{
		"name":        "Unit Viewer",
		"scope":       "company",
		"permissions": []string{core.PermUnitsRead},
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)
}

// PATCH /roles/{id} is the same door: widening an existing role beyond the
// caller's own grants must be refused.
func TestUpdateRoleCannotWidenBeyondTheCaller(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, roleEditorPermissions()...)
	client := h.srv.AsTenant(tn)

	created := client.Post("/api/v1/roles", map[string]any{
		"name":        "Yard",
		"scope":       "company",
		"permissions": []string{core.PermUnitsRead},
	})
	testutil.RequireStatus(t, created, http.StatusCreated)
	var env dto.RoleEnvelope
	created.JSON(&env)

	resp := client.Patch("/api/v1/roles/"+env.Data.ID, map[string]any{
		"permissions": []string{core.PermUnitsRead, core.PermRolesDelete, core.PermHosPolicyUpdate},
	})
	testutil.RequireStatusCode(t, resp, http.StatusForbidden, apierr.CodeForbidden)

	// The stored set must be untouched: a rejected update writes nothing.
	list := client.Get("/api/v1/roles",
		testutil.Query("is_system", "false"), testutil.Query("per_page", "50"))
	testutil.RequireStatus(t, list, http.StatusOK)
	var roles dto.RoleListEnvelope
	list.JSON(&roles)

	found := false
	for _, role := range roles.Data {
		if role.ID != env.Data.ID {
			continue
		}
		found = true
		require.ElementsMatch(t, []string{core.PermUnitsRead}, role.Permissions,
			"a rejected update must not have been partially applied")
	}
	require.True(t, found, "the role must still exist")
}

// The cheapest escalation of all: assign yourself the company-less
// Administrator template, which RLS lets every tenant read.
func TestAssignSystemAdministratorRoleIsForbidden(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, roleEditorPermissions()...)

	resp := h.srv.AsTenant(tn).Patch("/api/v1/users/"+tn.User.ID.String(), map[string]any{
		"role_id": systemRoleID(t).String(),
	})
	testutil.RequireStatusCode(t, resp, http.StatusForbidden, apierr.CodeForbidden)
}

// Inviting a new user into a stronger role is the same escalation with one
// extra step (accept the invitation), so it must fail too.
func TestCreateUserIntoStrongerRoleIsForbidden(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, roleEditorPermissions()...)

	resp := h.srv.AsTenant(tn).Post("/api/v1/users", map[string]any{
		"first_name": "Esc",
		"last_name":  "Alation",
		"email":      "esc.alation@example.com",
		"username":   "esc.alation",
		"role_id":    systemRoleID(t).String(),
	})
	testutil.RequireStatusCode(t, resp, http.StatusForbidden, apierr.CodeForbidden)
}

// A full Administrator keeps working: the guard bounds the caller, it does not
// break legitimate administration.
func TestAdministratorMayStillAssignTheSystemRole(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)

	resp := h.srv.AsTenant(tn).Post("/api/v1/users", map[string]any{
		"first_name": "Ann",
		"last_name":  "Admin",
		"email":      "ann.admin@example.com",
		"username":   "ann.admin",
		"role_id":    systemRoleID(t).String(),
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)
}
