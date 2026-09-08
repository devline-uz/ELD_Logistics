// Package users is the users, roles and permissions module: invited accounts,
// activation state, dynamic RBAC roles and the permission catalogue. It
// implements server.Module.
package users

import (
	"context"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/db"
	authdomain "github.com/devline/onebook-eld/internal/domain/auth"
	"github.com/devline/onebook-eld/internal/domain/users/dto"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Account states mirrored from the users.status CHECK constraint (TZ Q1).
const (
	StatusInvited  = "invited"
	StatusActive   = "active"
	StatusInactive = "inactive"
)

// Invitation purposes mirrored from the invitations.purpose CHECK constraint.
const (
	PurposeInvitation    = authdomain.PurposeInvitation
	PurposePasswordReset = authdomain.PurposePasswordReset
)

// Delivery channels for an invitation link (TZ A§16: SMS for drivers, email
// for the office).
const (
	ChannelEmail    = "email"
	ChannelSMS      = "sms"
	ChannelTelegram = "telegram"
)

// administratorRole is the name of the system role that must always have at
// least one active holder per company (TZ Q81).
const administratorRole = "administrator"

// Sort whitelists. Anything outside them is rejected with 422 before a query
// is built, so no user input ever reaches an ORDER BY clause.
var (
	userSortFields = []string{"last_name", "first_name", "username", "email", "status", "created_at"}
	roleSortFields = []string{"name", "scope", "created_at"}
)

// RequestMeta carries the transport facts the audit trail records. It is filled
// from the request by the handler, never from the JSON body.
type RequestMeta struct {
	IP        string
	UserAgent string
}

// Deps are the users service collaborators.
type Deps struct {
	Repo Repo
	// Permissions is invalidated whenever a role or its permission set changes.
	Permissions *core.RolePermissionCache
	// Revocations is the access token deny list: deactivating a user or
	// changing a role must take effect before the access token expires.
	Revocations *core.Revocations
	Notifier    authdomain.Notifier
	Logger      *slog.Logger
	// Now is overridable in tests.
	Now func() time.Time
}

// Service holds the users, roles and permissions business logic. It never
// touches SQL directly.
type Service struct {
	repo        Repo
	permissions *core.RolePermissionCache
	revocations *core.Revocations
	notifier    authdomain.Notifier
	log         *slog.Logger
	now         func() time.Time

	catalogue []dto.PermissionModule
}

// NewService wires the users service.
func NewService(d Deps) *Service {
	s := &Service{
		repo:        d.Repo,
		permissions: d.Permissions,
		revocations: d.Revocations,
		notifier:    d.Notifier,
		log:         d.Logger,
		now:         d.Now,
		catalogue:   permissionCatalogue(),
	}
	if s.log == nil {
		s.log = slog.Default()
	}
	if s.notifier == nil {
		s.notifier = authdomain.LogNotifier{Log: s.log}
	}
	if s.now == nil {
		s.now = time.Now
	}
	return s
}

// Permissions returns the RBAC catalogue grouped by module (TZ A§16 Q82).
func (s *Service) Permissions(context.Context) []dto.PermissionModule {
	return s.catalogue
}

// ---------------------------------------------------------------- users

// ListUsers returns one page of users. A branch scoped caller only ever sees
// its own branch, whatever the branch_id query parameter says.
func (s *Service) ListUsers(ctx context.Context, f UserFilter, scope mw.ScopeFilter) ([]dto.User, int64, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, 0, err
	}
	f.CompanyID = companyID
	if scope.Scope == tenant.ScopeBranch && scope.BranchID != nil {
		branch := *scope.BranchID
		if f.BranchID != nil && *f.BranchID != branch {
			return []dto.User{}, 0, nil
		}
		f.BranchID = &branch
	}

	rows, total, err := s.repo.ListUsers(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "user")
	}
	out := make([]dto.User, 0, len(rows))
	for _, row := range rows {
		out = append(out, toUserFromList(row))
	}
	return out, total, nil
}

// CreateUser invites a new account. There is no password field: the account is
// stored with status `invited` and a 72 hour invitation link is delivered out
// of band (TZ A§16).
func (s *Service) CreateUser(ctx context.Context, in dto.UserCreate, scope mw.ScopeFilter, meta RequestMeta) (*dto.User, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}

	email := strings.TrimSpace(strings.ToLower(in.Email))
	phone := strings.TrimSpace(in.Phone)
	if email == "" && phone == "" {
		return nil, apierr.Validation("validation failed",
			apierr.FieldError{Field: "email", Message: "email or phone is required"},
			apierr.FieldError{Field: "phone", Message: "email or phone is required"})
	}

	roleID, err := parseUUIDField("role_id", in.RoleID)
	if err != nil {
		return nil, err
	}
	role, err := s.repo.GetRole(ctx, companyID, *roleID)
	if err != nil {
		return nil, db.MapError(err, "role")
	}
	// Least privilege: no handing out a role stronger than the caller's own.
	if err := s.assertMayAssignRole(ctx, *roleID); err != nil {
		return nil, err
	}

	branchID, err := parseOptionalUUID("branch_id", in.BranchID)
	if err != nil {
		return nil, err
	}
	if branchID, err = s.resolveBranch(role.Scope, branchID, scope); err != nil {
		return nil, err
	}

	channel := resolveChannel(in.Channel, email, phone)
	token, err := appcrypto.RandomToken(core.RefreshTokenBytes)
	if err != nil {
		return nil, apierr.Internal(err, "could not create an invitation token")
	}
	now := s.now().UTC()
	expiresAt := now.Add(core.InvitationTTL)

	row, err := s.repo.CreateInvitedUser(ctx,
		CreateUserInput{
			CompanyID: companyID,
			BranchID:  branchID,
			FirstName: strings.TrimSpace(in.FirstName),
			LastName:  strings.TrimSpace(in.LastName),
			Email:     pgconv.NilIfEmpty(email),
			Phone:     pgconv.NilIfEmpty(phone),
			Username:  strings.TrimSpace(in.Username),
			RoleID:    *roleID,
			InvitedAt: now,
		},
		InvitationInput{
			CompanyID: companyID,
			TokenHash: appcrypto.HashSHA256(token),
			Channel:   channel,
			Purpose:   PurposeInvitation,
			ExpiresAt: expiresAt,
		},
		func(userID uuid.UUID) []audit.Entry {
			after := map[string]any{
				"first_name": strings.TrimSpace(in.FirstName),
				"last_name":  strings.TrimSpace(in.LastName),
				"email":      email,
				"phone":      phone,
				"username":   strings.TrimSpace(in.Username),
				"role_id":    roleID.String(),
				"branch_id":  uuidString(branchID),
				"status":     StatusInvited,
			}
			return s.entries("users", userID, audit.ActionCreate, companyID, meta,
				audit.Changes("users", userID, audit.ActionCreate, nil, after))
		},
	)
	if err != nil {
		return nil, db.MapError(err, "user")
	}

	s.deliver(ctx, row, channel, PurposeInvitation, token, expiresAt)
	out := toUser(row)
	return &out, nil
}

// applySimpleUserFields copies the scalar, always-safe fields of a partial
// update onto the repo input.
func applySimpleUserFields(update *UpdateUserInput, in dto.UserUpdate) {
	if in.FirstName != nil {
		update.FirstName = trimmedPtr(*in.FirstName)
	}
	if in.LastName != nil {
		update.LastName = trimmedPtr(*in.LastName)
	}
	if in.Email != nil {
		v := strings.TrimSpace(strings.ToLower(*in.Email))
		update.Email = &v
	}
	if in.Phone != nil {
		update.Phone = trimmedPtr(*in.Phone)
	}
	if in.Username != nil {
		update.Username = trimmedPtr(*in.Username)
	}
}

// applyRoleChange validates and applies a role_id change, reporting whether
// the account's effective role actually changed (TZ B§3.1: that revokes
// sessions).
func (s *Service) applyRoleChange(
	ctx context.Context, companyID uuid.UUID, current db.GetUserDetailRow, in dto.UserUpdate, update *UpdateUserInput,
) (bool, error) {
	if in.RoleID == nil {
		return false, nil
	}
	roleID, err := parseUUIDField("role_id", *in.RoleID)
	if err != nil {
		return false, err
	}
	role, err := s.repo.GetRole(ctx, companyID, *roleID)
	if err != nil {
		return false, db.MapError(err, "role")
	}
	if err := s.assertMayAssignRole(ctx, *roleID); err != nil {
		return false, err
	}
	update.RoleID = roleID
	if role.Scope == string(tenant.ScopeBranch) && in.BranchID == nil && pgconv.ToUUIDPtr(current.BranchID) == nil {
		return false, apierr.Validation("validation failed", apierr.FieldError{
			Field: "branch_id", Message: "required for a branch scoped role",
		})
	}
	return *roleID != current.RoleID, nil
}

// applyBranchChange validates and applies a branch_id change, enforcing that
// a branch scoped caller cannot move an account to another branch.
func applyBranchChange(scope mw.ScopeFilter, in dto.UserUpdate, update *UpdateUserInput) error {
	if in.BranchID == nil {
		return nil
	}
	if strings.TrimSpace(*in.BranchID) == "" {
		update.ClearBranch = true
		return nil
	}
	branchID, err := parseUUIDField("branch_id", *in.BranchID)
	if err != nil {
		return err
	}
	if scope.Scope == tenant.ScopeBranch && scope.BranchID != nil && *branchID != *scope.BranchID {
		return apierr.Forbidden("a branch scoped user cannot move accounts to another branch")
	}
	update.BranchID = branchID
	return nil
}

// UpdateUser applies a partial change. Changing the role revokes the account's
// sessions so the new permission set takes effect immediately (TZ B§3.1).
func (s *Service) UpdateUser(
	ctx context.Context, id uuid.UUID, in dto.UserUpdate, scope mw.ScopeFilter, meta RequestMeta,
) (*dto.User, error) {
	companyID, current, err := s.load(ctx, id, scope)
	if err != nil {
		return nil, err
	}

	update := UpdateUserInput{CompanyID: companyID, ID: id}
	applySimpleUserFields(&update, in)

	roleChanged, err := s.applyRoleChange(ctx, companyID, current, in, &update)
	if err != nil {
		return nil, err
	}
	if err := applyBranchChange(scope, in, &update); err != nil {
		return nil, err
	}

	before := userAuditFields(current)
	after := map[string]any{}
	for k, v := range before {
		after[k] = v
	}
	applyUserAudit(after, update)

	// A role change is a permission change: the sessions of the account are
	// revoked in the same transaction (TZ B§3.1).
	update.RevokeSessions = roleChanged
	row, revoked, err := s.repo.UpdateUser(ctx, update,
		s.entries("users", id, audit.ActionUpdate, companyID, meta,
			audit.Changes("users", id, audit.ActionUpdate, before, after)))
	if err != nil {
		return nil, db.MapError(err, "user")
	}
	s.revoke(ctx, revoked)

	out := toUser(row)
	return &out, nil
}

// DeleteUser soft deletes an account (TZ Q1: irreversible in the UI). The last
// active Administrator of a company and the caller itself are protected.
func (s *Service) DeleteUser(ctx context.Context, id uuid.UUID, scope mw.ScopeFilter, meta RequestMeta) error {
	companyID, current, err := s.load(ctx, id, scope)
	if err != nil {
		return err
	}
	if err := s.guardSelf(ctx, id, "delete"); err != nil {
		return err
	}
	if err := s.guardLastAdministrator(ctx, companyID, current); err != nil {
		return err
	}

	before := userAuditFields(current)
	after := map[string]any{"status": StatusInactive, "deleted_at": s.now().UTC().Format(time.RFC3339)}

	revoked, err := s.repo.SoftDeleteUser(ctx, companyID, id, core.ReasonUserInactive,
		s.entries("users", id, audit.ActionDelete, companyID, meta,
			audit.Changes("users", id, audit.ActionDelete, before, after)))
	if err != nil {
		return db.MapError(err, "user")
	}
	s.revoke(ctx, revoked)
	return nil
}

// SetActive flips the account between active and inactive (TZ Q1, Q3.1).
// Deactivating revokes every session of the account.
func (s *Service) SetActive(ctx context.Context, id uuid.UUID, active bool, scope mw.ScopeFilter, meta RequestMeta) (*dto.User, error) {
	companyID, current, err := s.load(ctx, id, scope)
	if err != nil {
		return nil, err
	}

	status := StatusInactive
	if active {
		status = StatusActive
	}
	if current.Status == status {
		out := toUser(current)
		return &out, nil
	}
	if active && current.PasswordHash == nil {
		return nil, apierr.New(apierr.CodeInvalidState, http.StatusConflict,
			"the invitation has not been accepted yet; resend the invitation instead")
	}
	if !active {
		if err := s.guardSelf(ctx, id, "deactivate"); err != nil {
			return nil, err
		}
		if err := s.guardLastAdministrator(ctx, companyID, current); err != nil {
			return nil, err
		}
	}

	before := map[string]any{"status": current.Status}
	after := map[string]any{"status": status}

	row, revoked, err := s.repo.SetUserStatus(ctx, companyID, id, status, core.ReasonUserInactive,
		s.entries("users", id, audit.ActionUpdate, companyID, meta,
			audit.Changes("users", id, audit.ActionUpdate, before, after)))
	if err != nil {
		return nil, db.MapError(err, "user")
	}
	s.revoke(ctx, revoked)

	out := toUser(row)
	return &out, nil
}
