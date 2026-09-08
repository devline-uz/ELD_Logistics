package users

import (
	"context"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/tenant"
)

// maxGrantDetails caps how many offending keys are echoed back so the error
// body cannot be used to dump the caller's whole permission set.
const maxGrantDetails = 5

// assertMayGrant enforces least privilege on every path that hands a
// permission to somebody else: defining a role (POST/PATCH /roles) and putting
// a user into a role (POST/PATCH /users).
//
// Without it a principal holding only `roles.create` + `users.update` mints a
// role carrying `company.update`, `users.delete` or `audit.view`, assigns it to
// itself and owns the tenant; likewise a Sub Admin (which by seed lacks
// `company.update`, `roles.*`, `users.delete`, `hos_policy.update`) simply
// assigns itself the company-less `Administrator` template, which every tenant
// can read. A caller may only ever grant what it already holds.
func assertMayGrant(ctx context.Context, keys []string) error {
	if len(keys) == 0 {
		return nil
	}
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok {
		return apierr.Unauthorized("authentication required")
	}
	// A platform administrator holds the whole catalogue by definition.
	if p.IsSuperAdmin {
		return nil
	}

	details := make([]apierr.FieldError, 0, maxGrantDetails)
	missing := 0
	for _, key := range keys {
		if p.HasPermission(key) {
			continue
		}
		missing++
		if len(details) < maxGrantDetails {
			details = append(details, apierr.FieldError{
				Field:   "permissions",
				Message: "you do not hold " + key + " and cannot grant it",
			})
		}
	}
	if missing == 0 {
		return nil
	}
	return apierr.Forbidden("a role cannot be granted permissions you do not hold").
		WithDetails(details...)
}

// assertMayAssignRole rejects handing a user a role that is more powerful than
// the caller's own. It resolves the role's effective permission set first, so
// the company-less system templates are covered as well.
func (s *Service) assertMayAssignRole(ctx context.Context, roleID uuid.UUID) error {
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok {
		return apierr.Unauthorized("authentication required")
	}
	if p.IsSuperAdmin {
		return nil
	}
	// Keeping one's own role is always allowed; it grants nothing new.
	if roleID == p.RoleID {
		return nil
	}
	granted, err := s.repo.RolePermissions(ctx, roleID)
	if err != nil {
		return apierr.Internal(err, "could not resolve the role permissions")
	}
	if err := assertMayGrant(ctx, granted); err != nil {
		return apierr.Forbidden("this role holds permissions you do not have").
			WithDetails(detailsOf(err)...)
	}
	return nil
}

// detailsOf lifts the field errors out of an *apierr.E.
func detailsOf(err error) []apierr.FieldError {
	if e, ok := apierr.From(err); ok {
		return e.Details
	}
	return nil
}
