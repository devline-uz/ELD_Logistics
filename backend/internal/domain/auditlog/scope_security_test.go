//go:build integration

// Scope and actor disclosure regression coverage of the audit journal
// (TZ A§16, A§17).
//
// Two findings are pinned here:
//
//  1. The actor join was not tenant scoped, so a platform super admin — whose
//     users row carries company_id IS NULL — appeared by name inside a tenant's
//     journal. A tenant must never learn the identity of platform staff.
//  2. The journal cannot be partitioned by branch: an entry addresses
//     `table_name` + `record_id` across every audited table and most of them
//     carry no branch. Serving it unfiltered to a `branch` scoped role is a
//     scope violation, so the endpoint requires a company scoped role.
package auditlog_test

import (
	"net/http"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// newSuperAdminUser inserts a platform user (company_id IS NULL) reusing the
// tenant's role row, which is all the foreign key needs.
func newSuperAdminUser(t testing.TB, roleID uuid.UUID) uuid.UUID {
	t.Helper()
	id := uuid.New()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO users (id, company_id, first_name, last_name, username, role_id, status)
		 VALUES ($1, NULL, 'Platform', 'Superadmin', $2, $3, 'active')`,
		id, "super-"+id.String()[:8], roleID)
	require.NoError(t, err, "seed platform super admin")
	return id
}

func TestJournalNeverNamesAPlatformSuperAdmin(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermAuditView)

	superID := newSuperAdminUser(t, tn.Role.ID)
	byPlatform := insertEntry(t, tn.Company.ID, entry{
		Table: "companies", RecordID: tn.Company.ID, Field: "subscription_status",
		Old: `"active"`, New: `"suspended"`, Action: "update", EditedBy: superID,
	})
	byTenant := insertEntry(t, tn.Company.ID, entry{
		Table: "units", RecordID: tn.Unit.ID, Field: "status",
		Old: `"active"`, New: `"inactive"`, Action: "update", EditedBy: tn.User.ID,
	})

	env := list(t, srv.AsTenant(tn))

	platform := find(t, env, byPlatform)
	require.Empty(t, platform.EditedByName,
		"a platform super admin must stay anonymous inside a tenant journal")
	require.Empty(t, platform.Username)

	// The tenant's own actor is still resolved, so the join was narrowed and
	// not simply removed.
	own := find(t, env, byTenant)
	require.NotEmpty(t, own.EditedByName)
	require.NotEmpty(t, own.Username)
}

func TestJournalRequiresACompanyScopedRole(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermAuditView)
	insertEntry(t, tn.Company.ID, entry{
		Table: "units", RecordID: tn.Unit.ID, Field: "status",
		Old: `"active"`, New: `"inactive"`, EditedBy: tn.User.ID,
	})

	branchID := tn.Branch.ID
	branchPrincipal := tn.Principal()
	branchPrincipal.Scope = tenant.ScopeBranch
	branchPrincipal.BranchID = &branchID
	branchPrincipal.Permissions = []string{core.PermAuditView}
	mgr := srv.AsPrincipal(branchPrincipal)

	// A branch role holding audit.view still cannot read a company wide trail.
	testutil.RequireStatusCode(t, mgr.Get("/api/v1/audit-log"),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatusCode(t, mgr.Get("/api/v1/audit-log/tables"),
		http.StatusForbidden, apierr.CodeForbidden)

	// The driver application (self scope) is refused for the same reason.
	self := tn.DriverPrincipal(core.PermAuditView)
	testutil.RequireStatusCode(t, srv.AsPrincipal(self).Get("/api/v1/audit-log"),
		http.StatusForbidden, apierr.CodeForbidden)

	// The company scoped role is unaffected.
	testutil.RequireStatus(t, srv.AsTenant(tn).Get("/api/v1/audit-log"), http.StatusOK)
}
