//go:build integration

package main

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// defaultRoleNames are the eight system role templates seeded by
// db/migrations/00012_seed.sql (roles.company_id IS NULL, is_system).
var defaultRoleNames = []string{
	"Administrator", "Sub Admin", "Fleet Manager", "Dispatcher",
	"Service Manager", "Safety Manager", "Data Analyst", "Driver",
}

// systemRole is a default role template read straight from the database:
// permission grants come from role_permissions, never a hand written list
// (the task explicitly forbids re-typing the seed).
type systemRole struct {
	ID          uuid.UUID
	Scope       string // roles.scope: "company", "branch" or "self"
	Permissions map[string]bool
}

func has(perms map[string]bool, key string) bool { return perms[key] }

// loadSystemRole reads one default role template and its live grants.
func loadSystemRole(t testing.TB, name string) systemRole {
	t.Helper()
	var id uuid.UUID
	var scope string
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT id, scope FROM roles WHERE company_id IS NULL AND is_system AND name = $1`, name).
		Scan(&id, &scope)
	require.NoError(t, err, "load system role %q", name)

	rows, err := testutil.AdminPool(t).Query(testutil.Ctx(t),
		`SELECT permission_key FROM role_permissions WHERE role_id = $1`, id)
	require.NoError(t, err, "load permissions of %q", name)
	defer rows.Close()

	perms := make(map[string]bool)
	for rows.Next() {
		var key string
		require.NoError(t, rows.Scan(&key))
		perms[key] = true
	}
	require.NoError(t, rows.Err())
	return systemRole{ID: id, Scope: scope, Permissions: perms}
}

// principalScope translates roles.scope into tenant.Scope exactly like
// internal/domain/auth/account.go does for a real login (duplicated here on
// purpose: this package must not import a domain package's unexported
// helpers, and the mapping is a three line CHECK-constraint mirror, not
// business logic worth sharing).
func principalScope(dbScope string) tenant.Scope {
	switch dbScope {
	case string(tenant.ScopeBranch):
		return tenant.ScopeBranch
	case string(tenant.ScopeSelf):
		return tenant.ScopeSelf
	default:
		return tenant.ScopeAll
	}
}

// roleFixture is one seeded tenant plus a user wearing a given default role
// template, ready to be signed into an access token.
type roleFixture struct {
	Name    string
	Role    systemRole
	Company testutil.Company
	User    testutil.User
}

// seedRoleFixture creates a fresh company and a user whose role_id points at
// the named system role template (company_id IS NULL is fine on users.role_id:
// there is no FK tying a role to the company of the user wearing it — that is
// exactly how a real company assigns "Fleet Manager" to one of its users).
func seedRoleFixture(t testing.TB, name string) roleFixture {
	t.Helper()
	role := loadSystemRole(t, name)
	company := testutil.NewCompany(t)
	user := testutil.NewUser(t, company.ID, testutil.WithRoleID(role.ID))
	if principalScope(role.Scope) == tenant.ScopeSelf {
		// Driver-shaped self scope routes resolve the caller through the
		// drivers table; give it one so "authorized but resource missing"
		// takes the 404 branch instead of an unrelated lookup failure.
		testutil.NewDriver(t, company.ID, testutil.WithUser(user))
	}
	return roleFixture{Name: name, Role: role, Company: company, User: user}
}

// principal builds the tenant.Principal a real login would have produced for
// this fixture. Permissions are intentionally left empty: fullApp.issue signs
// a real token carrying only role_id, and the verifier resolves permissions
// from role_permissions at request time, just like production.
func (f roleFixture) principal() *tenant.Principal {
	companyID := f.Company.ID
	return &tenant.Principal{
		UserID:     f.User.ID,
		CompanyID:  &companyID,
		RoleID:     f.Role.ID,
		Scope:      principalScope(f.Role.Scope),
		SessionID:  uuid.New(),
		DeviceType: tenant.DeviceWeb,
	}
}

// seedAllRoleFixtures builds one fixture per default role template.
func seedAllRoleFixtures(t testing.TB) map[string]roleFixture {
	t.Helper()
	out := make(map[string]roleFixture, len(defaultRoleNames))
	for _, name := range defaultRoleNames {
		out[name] = seedRoleFixture(t, name)
	}
	return out
}
