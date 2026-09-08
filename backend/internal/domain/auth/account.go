package auth

import (
	"context"
	"net/http"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/auth/dto"
	"github.com/devline/onebook-eld/internal/tenant"
)

// account bundles a user with the role and company facts the flows need.
type account struct {
	user         db.User
	role         db.Role
	company      *db.Company
	permissions  []string
	isSuperAdmin bool
	readonly     bool
}

func (a account) scope() tenant.Scope {
	switch a.role.Scope {
	case string(tenant.ScopeBranch):
		return tenant.ScopeBranch
	case string(tenant.ScopeSelf):
		return tenant.ScopeSelf
	default:
		return tenant.ScopeAll
	}
}

// loadAccount resolves the role, permissions and company of a user.
func (s *Service) loadAccount(ctx context.Context, user db.User) (account, error) {
	acc := account{user: user, isSuperAdmin: !user.CompanyID.Valid}

	role, err := s.repo.GetRoleByID(ctx, user.RoleID)
	if err != nil {
		return acc, db.MapError(err, "role")
	}
	acc.role = role

	perms, err := s.permissions.PermissionsForRole(ctx, user.RoleID)
	if err != nil {
		return acc, apierr.Internal(err, "could not resolve permissions")
	}
	acc.permissions = perms

	if companyID := pgconv.ToUUIDPtr(user.CompanyID); companyID != nil {
		company, err := s.repo.GetCompany(ctx, *companyID)
		if err != nil {
			return acc, db.MapError(err, "company")
		}
		acc.company = &company

		if end := pgconv.ToTimePtr(company.SubscriptionEndAt); end != nil {
			now := s.now().UTC()
			if end.Before(now) {
				acc.readonly = true
				if end.Add(core.SubscriptionGrace).Before(now) {
					return acc, apierr.New(apierr.CodeSubscriptionExpired, http.StatusForbidden,
						"the company subscription has expired")
				}
			}
		}
		if company.SubscriptionStatus != "active" {
			acc.readonly = true
		}
	}
	return acc, nil
}

func (s *Service) principal(acc account, session db.Session, restricted string) *tenant.Principal {
	p := &tenant.Principal{
		UserID:       acc.user.ID,
		CompanyID:    pgconv.ToUUIDPtr(acc.user.CompanyID),
		RoleID:       acc.user.RoleID,
		Scope:        acc.scope(),
		BranchID:     pgconv.ToUUIDPtr(acc.user.BranchID),
		SessionID:    session.ID,
		DeviceType:   session.DeviceType,
		Permissions:  acc.permissions,
		IsSuperAdmin: acc.isSuperAdmin,
		Restricted:   restricted,
	}
	return p
}

func (s *Service) revokeAll(ctx context.Context, meta RequestMeta, user db.User, reason string) {
	ids, err := s.repo.RevokeAllUserSessions(ctx, user.ID, reason)
	if err != nil {
		s.log.WarnContext(ctx, "could not revoke sessions", "error", err.Error())
		return
	}
	if len(ids) == 0 {
		return
	}
	_ = s.revocations.Revoke(ctx, ids...)
	s.record(ctx, meta, user, audit.ActionSessionRevoked, "status", reason)
}

func subscriptionEnd(c *db.Company) *time.Time {
	if c == nil {
		return nil
	}
	return pgconv.ToTimePtr(c.SubscriptionEndAt)
}

// record writes one audit entry, never failing the caller's request.
func (s *Service) record(ctx context.Context, meta RequestMeta, user db.User, action audit.Action, field, value string) {
	entry := audit.Entry{
		TableName: "users",
		RecordID:  user.ID,
		Field:     field,
		NewValue:  value,
		Action:    action,
		EditedBy:  user.ID,
		IP:        meta.IP,
		CreatedAt: s.now().UTC(),
	}
	if companyID := pgconv.ToUUIDPtr(user.CompanyID); companyID != nil {
		entry.CompanyID = *companyID
	}
	if err := s.recorder.Record(ctx, entry); err != nil {
		s.log.WarnContext(ctx, "audit write failed", "action", string(action), "error", err.Error())
	}
}

// recordAnonymousFailure audits a failed login that could not be attributed to
// a user. The submitted username is never written: it is attacker controlled
// and frequently a real credential typed into the wrong field.
func (s *Service) recordAnonymousFailure(ctx context.Context, meta RequestMeta) {
	err := s.recorder.Record(ctx, audit.Entry{
		TableName: "users",
		RecordID:  uuid.Nil,
		Field:     "login",
		NewValue:  "unknown account",
		Action:    audit.ActionFailedLogin,
		IP:        meta.IP,
		CreatedAt: s.now().UTC(),
	})
	if err != nil {
		s.log.WarnContext(ctx, "audit write failed", "action", string(audit.ActionFailedLogin))
	}
}

func profileOf(acc account) dto.Profile {
	p := dto.Profile{
		ID:           acc.user.ID.String(),
		FirstName:    acc.user.FirstName,
		LastName:     acc.user.LastName,
		Username:     acc.user.Username,
		RoleID:       acc.user.RoleID.String(),
		RoleName:     acc.role.Name,
		Scope:        acc.role.Scope,
		Status:       acc.user.Status,
		IsSuperAdmin: acc.isSuperAdmin,
		TOTPEnabled:  acc.user.TotpEnabled,
		PINSet:       acc.user.PinHash != nil && *acc.user.PinHash != "",
		Permissions:  acc.permissions,
		LastLoginAt:  pgconv.ToTimePtr(acc.user.LastLoginAt),
	}
	if acc.user.Email != nil {
		p.Email = *acc.user.Email
	}
	if id := pgconv.ToUUIDPtr(acc.user.CompanyID); id != nil {
		p.CompanyID = id.String()
	}
	if id := pgconv.ToUUIDPtr(acc.user.BranchID); id != nil {
		p.BranchID = id.String()
	}
	if p.Permissions == nil {
		p.Permissions = []string{}
	}
	return p
}
