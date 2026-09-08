// Package tenant carries the authenticated principal and the active company
// (tenant) through the request context. Business code MUST read company_id and
// the principal from here, never from the request body or query string.
package tenant

import (
	"context"

	"github.com/google/uuid"
)

type ctxKey int

const (
	ctxKeyCompanyID ctxKey = iota + 1
	ctxKeyPrincipal
)

// Scope enumerates the visibility level a principal is granted.
type Scope string

// Known principal scopes.
const (
	ScopeAll    Scope = "all"
	ScopeBranch Scope = "branch"
	ScopeSelf   Scope = "self"
)

// Device types a session may originate from. The values MUST match the
// sessions.device_type CHECK constraint: one active session per device type.
const (
	DeviceWeb    = "web"
	DevicePhone  = "phone"
	DeviceTablet = "tablet"
)

// DeviceTypes lists every accepted device type.
var DeviceTypes = []string{DeviceWeb, DevicePhone, DeviceTablet}

// IsDeviceType reports whether v is an accepted device type.
func IsDeviceType(v string) bool {
	for _, d := range DeviceTypes {
		if d == v {
			return true
		}
	}
	return false
}

// Principal is the authenticated caller extracted from the access token.
type Principal struct {
	UserID       uuid.UUID
	CompanyID    *uuid.UUID
	RoleID       uuid.UUID
	Scope        Scope
	BranchID     *uuid.UUID
	SessionID    uuid.UUID
	DeviceType   string
	Permissions  []string
	IsSuperAdmin bool

	// Restricted marks a limited capability token, e.g. "totp_setup" issued to
	// an admin that still has to enrol in 2FA. A restricted principal holds no
	// permission at all, so every gated route rejects it.
	Restricted string
}

// IsRestricted reports whether the principal carries a limited capability token.
func (p *Principal) IsRestricted() bool {
	return p != nil && p.Restricted != ""
}

// HasPermission reports whether the principal holds the permission key.
// Super admins implicitly hold every permission.
func (p *Principal) HasPermission(key string) bool {
	if p == nil || p.Restricted != "" {
		return false
	}
	if p.IsSuperAdmin {
		return true
	}
	for _, perm := range p.Permissions {
		if perm == key || perm == "*" {
			return true
		}
	}
	return false
}

// WithCompanyID stores the active tenant in the context.
func WithCompanyID(ctx context.Context, companyID uuid.UUID) context.Context {
	return context.WithValue(ctx, ctxKeyCompanyID, companyID)
}

// CompanyID returns the active tenant, or uuid.Nil when unset (super admin or
// unauthenticated request).
func CompanyID(ctx context.Context) uuid.UUID {
	if v, ok := ctx.Value(ctxKeyCompanyID).(uuid.UUID); ok {
		return v
	}
	return uuid.Nil
}

// CompanyIDOK returns the active tenant and whether one was set.
func CompanyIDOK(ctx context.Context) (uuid.UUID, bool) {
	v, ok := ctx.Value(ctxKeyCompanyID).(uuid.UUID)
	return v, ok && v != uuid.Nil
}

// WithPrincipal stores the authenticated principal and, when present, its
// company id in the context.
func WithPrincipal(ctx context.Context, p *Principal) context.Context {
	ctx = context.WithValue(ctx, ctxKeyPrincipal, p)
	if p != nil && p.CompanyID != nil {
		ctx = WithCompanyID(ctx, *p.CompanyID)
	}
	return ctx
}

// PrincipalFrom returns the authenticated principal, if any.
func PrincipalFrom(ctx context.Context) (*Principal, bool) {
	p, ok := ctx.Value(ctxKeyPrincipal).(*Principal)
	return p, ok && p != nil
}

// HasPermission reports whether the context principal holds the permission key.
func HasPermission(ctx context.Context, key string) bool {
	p, ok := PrincipalFrom(ctx)
	if !ok {
		return false
	}
	return p.HasPermission(key)
}

// UserID returns the authenticated user id, or uuid.Nil.
func UserID(ctx context.Context) uuid.UUID {
	if p, ok := PrincipalFrom(ctx); ok {
		return p.UserID
	}
	return uuid.Nil
}
