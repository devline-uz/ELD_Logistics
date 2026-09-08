//go:build integration

// 00020 made the role_permissions tenant policy self contained: before it, the
// predicate was `EXISTS (SELECT 1 FROM roles r WHERE r.id = role_id)` and the
// isolation came only from the roles policy nested inside that subquery.
package testutil

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
)

// A role of another tenant must be invisible through role_permissions, and the
// policy has to say so itself.
func TestRolePermissionsRLSCarriesTheCompanyPredicate(t *testing.T) {
	t.Parallel()
	a, b := SeedTwoCompanies(t, "units.read", "drivers.read")

	const q = `SELECT count(*) FROM role_permissions WHERE role_id = $1`
	require.Positive(t, countAs(t, a.Company.ID, q, a.Role.ID),
		"a tenant must see the grants of its own role")
	require.Equal(t, 0, countAs(t, a.Company.ID, q, b.Role.ID),
		"the grants of another tenant's role must be invisible")
	require.Equal(t, 0, countAs(t, b.Company.ID, q, a.Role.ID))

	// The predicate is written into the policy, not inherited from `roles`.
	var using string
	require.NoError(t, AdminPool(t).QueryRow(Ctx(t),
		`SELECT pg_get_expr(pol.polqual, pol.polrelid)
		   FROM pg_policy pol JOIN pg_class c ON c.oid = pol.polrelid
		  WHERE c.relname = 'role_permissions' AND pol.polname = 'tenant_isolation'`).Scan(&using))
	require.Contains(t, using, "company_id", "the USING clause must filter on company_id itself")
	require.Contains(t, using, "app.company_id")
}

// Writing a grant onto another tenant's role must be refused by WITH CHECK,
// otherwise a tenant could widen a foreign role.
func TestRolePermissionsRLSBlocksCrossTenantWrites(t *testing.T) {
	t.Parallel()
	a, b := SeedTwoCompanies(t)

	err := execTx(t, a.Company.ID,
		`INSERT INTO role_permissions (role_id, permission_key) VALUES ($1, 'company.update')`,
		b.Role.ID)
	require.Error(t, err, "a cross-tenant grant must be rejected")

	// The victim's role is untouched.
	require.Equal(t, 0, countAs(t, b.Company.ID,
		`SELECT count(*) FROM role_permissions WHERE role_id = $1 AND permission_key = 'company.update'`,
		b.Role.ID))

	// The same statement against its own role succeeds.
	require.NoError(t, execTx(t, a.Company.ID,
		`INSERT INTO role_permissions (role_id, permission_key) VALUES ($1, 'company.update')`,
		a.Role.ID))
}

// System roles (company_id IS NULL) stay readable for every tenant — that is
// how a seeded Driver role resolves its permissions — but never writable.
func TestRolePermissionsRLSKeepsSystemRolesReadOnly(t *testing.T) {
	t.Parallel()
	a := SeedTenant(t)

	var systemRole uuid.UUID
	err := AdminPool(t).QueryRow(Ctx(t),
		`SELECT id FROM roles WHERE company_id IS NULL AND is_system AND name = 'Driver'`).Scan(&systemRole)
	require.NoError(t, err)

	require.Positive(t, countAs(t, a.Company.ID,
		`SELECT count(*) FROM role_permissions WHERE role_id = $1`, systemRole),
		"a system role must stay readable for every tenant")

	require.Error(t, execTx(t, a.Company.ID,
		`INSERT INTO role_permissions (role_id, permission_key) VALUES ($1, 'company.update')`,
		systemRole), "a tenant must not be able to widen a system role")
}

// 00020 also grants drivers.license.view wherever drivers.update already is,
// so the licence endpoint keeps working for the seeded roles.
func TestSeededRolesCarryTheLicenseViewKey(t *testing.T) {
	t.Parallel()

	var withUpdate, withReveal int
	ctx := context.Background()
	require.NoError(t, AdminPool(t).QueryRow(ctx,
		`SELECT
		   count(*) FILTER (WHERE permission_key = 'drivers.update'),
		   count(*) FILTER (WHERE permission_key = 'drivers.license.view')
		 FROM role_permissions rp
		 JOIN roles r ON r.id = rp.role_id
		 WHERE r.company_id IS NULL AND r.is_system`).Scan(&withUpdate, &withReveal))
	require.Positive(t, withUpdate)
	require.Equal(t, withUpdate, withReveal,
		"every role that could edit a driver keeps the licence reveal it already had")

	// The key is published by GET /permissions as well.
	require.Contains(t, PermissionKeys(t), "drivers.license.view")
}
