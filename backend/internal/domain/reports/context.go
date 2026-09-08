package reports

import (
	"context"
	"net/http"

	"github.com/google/uuid"

	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// tenantUserID reads the authenticated user from the request context. The
// caller identity is never taken from the query string.
func tenantUserID(r *http.Request) uuid.UUID { return tenant.UserID(r.Context()) }

// scopeBranch returns the branch a `branch` scoped caller is pinned to (TZ
// A§16). Every other scope answers false, which leaves the report unfiltered.
func scopeBranch(ctx context.Context) (uuid.UUID, bool) {
	f, ok := mw.ScopeFrom(ctx)
	if !ok || f.Scope != tenant.ScopeBranch || f.BranchID == nil {
		return uuid.Nil, false
	}
	return *f.BranchID, true
}

// scopeSelfUser returns the user a `self` scoped caller is pinned to.
func scopeSelfUser(ctx context.Context) (uuid.UUID, bool) {
	f, ok := mw.ScopeFrom(ctx)
	if !ok || f.Scope != tenant.ScopeSelf || f.SelfUserID == nil {
		return uuid.Nil, false
	}
	return *f.SelfUserID, true
}
