package users

import (
	"context"
	"strings"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/users/dto"
)

// ListRoles returns one page of roles: the system templates plus the roles the
// company defined itself.
func (s *Service) ListRoles(ctx context.Context, f RoleFilter) ([]dto.Role, int64, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, 0, err
	}
	f.CompanyID = companyID

	rows, total, err := s.repo.ListRoles(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "role")
	}

	ids := make([]uuid.UUID, 0, len(rows))
	for _, row := range rows {
		ids = append(ids, row.ID)
	}
	perms, err := s.repo.PermissionsForRoles(ctx, ids)
	if err != nil {
		return nil, 0, db.MapError(err, "role")
	}

	out := make([]dto.Role, 0, len(rows))
	for _, row := range rows {
		out = append(out, toRole(db.GetRoleWithUserCountRow(row), sortedKeys(perms[row.ID])))
	}
	return out, total, nil
}

// CreateRole defines a company role. Every permission key is validated against
// the catalogue, so an unknown key can never widen access (TZ Q82).
func (s *Service) CreateRole(ctx context.Context, in dto.RoleCreate, meta RequestMeta) (*dto.Role, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}
	permissions, err := validatePermissions(in.Permissions)
	if err != nil {
		return nil, err
	}
	// Least privilege: a role may never carry more than its author holds.
	if err := assertMayGrant(ctx, permissions); err != nil {
		return nil, err
	}

	name := strings.TrimSpace(in.Name)
	description := strings.TrimSpace(in.Description)

	created, err := s.repo.CreateRole(ctx, CreateRoleInput{
		CompanyID:   companyID,
		Name:        name,
		Description: pgconv.NilIfEmpty(description),
		Scope:       in.Scope,
		Permissions: permissions,
	}, func(roleID uuid.UUID) []audit.Entry {
		after := roleAuditFields(name, description, in.Scope, permissions)
		return s.entries("roles", roleID, audit.ActionCreate, companyID, meta,
			audit.Changes("roles", roleID, audit.ActionCreate, nil, after))
	})
	if err != nil {
		return nil, db.MapError(err, "role")
	}

	out := toRoleFromModel(created, permissions, 0)
	return &out, nil
}

// UpdateRole changes a company role. System roles are immutable (403). Any
// change invalidates the permission cache and revokes the sessions of every
// holder so the new set takes effect immediately (TZ B§3.1).
func (s *Service) UpdateRole(ctx context.Context, id uuid.UUID, in dto.RoleUpdate, meta RequestMeta) (*dto.Role, error) {
	companyID, current, err := s.loadRole(ctx, id)
	if err != nil {
		return nil, err
	}

	before, err := s.repo.RolePermissions(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "role")
	}
	after := before

	update := UpdateRoleInput{CompanyID: companyID, ID: id}
	if in.Name != nil {
		update.Name = trimmedPtr(*in.Name)
	}
	if in.Description != nil {
		update.Description = trimmedPtr(*in.Description)
	}
	if in.Scope != nil {
		update.Scope = in.Scope
	}
	if in.Permissions != nil {
		permissions, err := validatePermissions(*in.Permissions)
		if err != nil {
			return nil, err
		}
		if err := assertMayGrant(ctx, permissions); err != nil {
			return nil, err
		}
		update.Permissions = permissions
		after = permissions
	}

	beforeFields := roleAuditFields(current.Name, pgconv.Deref(current.Description), current.Scope, before)
	afterFields := roleAuditFields(
		valueOr(update.Name, current.Name),
		valueOr(update.Description, pgconv.Deref(current.Description)),
		valueOr(update.Scope, current.Scope),
		after)

	updated, err := s.repo.UpdateRole(ctx, update,
		s.entries("roles", id, audit.ActionUpdate, companyID, meta,
			audit.Changes("roles", id, audit.ActionUpdate, beforeFields, afterFields)))
	if err != nil {
		return nil, db.MapError(err, "role")
	}

	s.invalidateRole(ctx, companyID, id)

	out := toRoleFromModel(updated, after, current.UserCount)
	return &out, nil
}

// DeleteRole soft deletes a company role. A role that still has users answers
// 409 ROLE_IN_USE; system roles answer 403.
func (s *Service) DeleteRole(ctx context.Context, id uuid.UUID, meta RequestMeta) error {
	companyID, current, err := s.loadRole(ctx, id)
	if err != nil {
		return err
	}

	inUse, err := s.repo.CountUsersWithRole(ctx, companyID, id)
	if err != nil {
		return db.MapError(err, "role")
	}
	if inUse > 0 {
		return apierr.Conflict(apierr.CodeRoleInUse, "the role is still assigned to users")
	}

	permissions, err := s.repo.RolePermissions(ctx, id)
	if err != nil {
		return db.MapError(err, "role")
	}
	before := roleAuditFields(current.Name, pgconv.Deref(current.Description), current.Scope, permissions)
	after := map[string]any{"name": current.Name, "deleted": "true"}

	if err := s.repo.SoftDeleteRole(ctx, companyID, id,
		s.entries("roles", id, audit.ActionDelete, companyID, meta,
			audit.Changes("roles", id, audit.ActionDelete, before, after))); err != nil {
		return db.MapError(err, "role")
	}

	s.invalidateRole(ctx, companyID, id)
	return nil
}

// loadRole reads a role of the tenant and rejects writes against system roles.
func (s *Service) loadRole(ctx context.Context, id uuid.UUID) (uuid.UUID, db.GetRoleWithUserCountRow, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return uuid.Nil, db.GetRoleWithUserCountRow{}, err
	}
	row, err := s.repo.GetRole(ctx, companyID, id)
	if err != nil {
		return uuid.Nil, db.GetRoleWithUserCountRow{}, db.MapError(err, "role")
	}
	// A system template belongs to no company: it is readable by everyone and
	// writable by no one (TZ Q81).
	if row.IsSystem || !row.CompanyID.Valid {
		return uuid.Nil, db.GetRoleWithUserCountRow{}, errSystemRoleImmutable()
	}
	return companyID, row, nil
}

// invalidateRole drops the cached permission set and revokes the sessions of
// every holder of the role.
func (s *Service) invalidateRole(ctx context.Context, companyID, roleID uuid.UUID) {
	if err := s.permissions.Invalidate(ctx, roleID); err != nil {
		s.log.WarnContext(ctx, "could not invalidate the role permission cache", "error", err.Error())
	}
	revoked, err := s.repo.RevokeRoleSessions(ctx, companyID, roleID, core.ReasonPermissionChange)
	if err != nil {
		s.log.WarnContext(ctx, "could not revoke the sessions of a changed role", "error", err.Error())
		return
	}
	s.revoke(ctx, revoked)
}

func sortedKeys(keys []string) []string {
	if keys == nil {
		return []string{}
	}
	out := append([]string(nil), keys...)
	for i := 1; i < len(out); i++ {
		for j := i; j > 0 && out[j] < out[j-1]; j-- {
			out[j], out[j-1] = out[j-1], out[j]
		}
	}
	return out
}

func valueOr(v *string, def string) string {
	if v == nil {
		return def
	}
	return *v
}
