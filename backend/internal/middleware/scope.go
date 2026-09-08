package middleware

import (
	"context"
	"net/http"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

type scopeCtxKey struct{}

// ScopeFilter is the resolved visibility of the caller. Repositories translate
// it into WHERE clauses: company scope filters on company_id only, branch scope
// adds branch_id, self scope pins the row owner to the caller.
type ScopeFilter struct {
	Scope     tenant.Scope
	CompanyID uuid.UUID
	// BranchID is set for branch scoped roles.
	BranchID *uuid.UUID
	// SelfUserID is set for self scoped roles (drivers on the mobile API).
	SelfUserID *uuid.UUID
	// IsSuperAdmin bypasses the company filter at the platform endpoints only.
	IsSuperAdmin bool
}

// AllowsCompany reports whether the caller may read rows of companyID.
func (f ScopeFilter) AllowsCompany(companyID uuid.UUID) bool {
	if f.IsSuperAdmin {
		return true
	}
	return f.CompanyID != uuid.Nil && f.CompanyID == companyID
}

// AllowsBranch reports whether the caller may read rows of branchID.
func (f ScopeFilter) AllowsBranch(branchID *uuid.UUID) bool {
	if f.Scope != tenant.ScopeBranch || f.BranchID == nil {
		return true
	}
	return branchID != nil && *branchID == *f.BranchID
}

// AllowsUser reports whether the caller may read rows owned by userID.
func (f ScopeFilter) AllowsUser(userID uuid.UUID) bool {
	if f.Scope != tenant.ScopeSelf || f.SelfUserID == nil {
		return true
	}
	return *f.SelfUserID == userID
}

// Scope resolves the caller visibility once per request and stores it on the
// context. It must run after Authenticate.
func Scope(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p, ok := tenant.PrincipalFrom(r.Context())
		if !ok {
			httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
			return
		}
		next.ServeHTTP(w, r.WithContext(WithScope(r.Context(), FilterFor(p))))
	})
}

// FilterFor derives the scope filter of a principal.
func FilterFor(p *tenant.Principal) ScopeFilter {
	f := ScopeFilter{Scope: tenant.ScopeAll}
	if p == nil {
		return f
	}
	f.Scope = p.Scope
	f.IsSuperAdmin = p.IsSuperAdmin
	if p.CompanyID != nil {
		f.CompanyID = *p.CompanyID
	}
	switch p.Scope {
	case tenant.ScopeBranch:
		f.BranchID = p.BranchID
	case tenant.ScopeSelf:
		id := p.UserID
		f.SelfUserID = &id
	}
	return f
}

// WithScope stores a resolved filter on the context.
func WithScope(ctx context.Context, f ScopeFilter) context.Context {
	return context.WithValue(ctx, scopeCtxKey{}, f)
}

// ScopeFrom returns the resolved filter, deriving it from the principal when
// the Scope middleware did not run.
func ScopeFrom(ctx context.Context) (ScopeFilter, bool) {
	if f, ok := ctx.Value(scopeCtxKey{}).(ScopeFilter); ok {
		return f, true
	}
	if p, ok := tenant.PrincipalFrom(ctx); ok {
		return FilterFor(p), true
	}
	return ScopeFilter{}, false
}
