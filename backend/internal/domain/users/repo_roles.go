package users

import (
	"context"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/tenant"
)

// ListRoles implements Repo.
func (r *PgRepo) ListRoles(ctx context.Context, f RoleFilter) ([]db.ListRolesRow, int64, error) {
	var (
		rows  []db.ListRolesRow
		total int64
	)
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		rows, err = q.ListRoles(ctx, db.ListRolesParams{
			CompanyID:  f.CompanyID,
			Search:     f.Search,
			Scope:      f.Scope,
			IsSystem:   f.IsSystem,
			SortKey:    f.Sort,
			SortDesc:   f.SortDesc,
			PageLimit:  f.Limit,
			PageOffset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountRoles(ctx, db.CountRolesParams{
			CompanyID: f.CompanyID,
			Search:    f.Search,
			Scope:     f.Scope,
			IsSystem:  f.IsSystem,
		})
		return err
	})
	return rows, total, err
}

// GetRole implements Repo.
func (r *PgRepo) GetRole(ctx context.Context, companyID, id uuid.UUID) (db.GetRoleWithUserCountRow, error) {
	var out db.GetRoleWithUserCountRow
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.GetRoleWithUserCount(ctx, db.GetRoleWithUserCountParams{CompanyID: companyID, ID: id})
		return err
	})
	return out, err
}

// RolePermissions implements Repo.
func (r *PgRepo) RolePermissions(ctx context.Context, roleID uuid.UUID) ([]string, error) {
	var out []string
	err := r.read(ctx, tenant.CompanyID(ctx), func(q *db.Queries) error {
		var err error
		out, err = q.ListRolePermissions(ctx, roleID)
		return err
	})
	return out, err
}

// PermissionsForRoles implements Repo.
func (r *PgRepo) PermissionsForRoles(ctx context.Context, roleIDs []uuid.UUID) (map[uuid.UUID][]string, error) {
	out := make(map[uuid.UUID][]string, len(roleIDs))
	if len(roleIDs) == 0 {
		return out, nil
	}
	err := r.read(ctx, tenant.CompanyID(ctx), func(q *db.Queries) error {
		rows, err := q.ListPermissionsForRoles(ctx, roleIDs)
		if err != nil {
			return err
		}
		for _, row := range rows {
			out[row.RoleID] = append(out[row.RoleID], row.PermissionKey)
		}
		return nil
	})
	return out, err
}

// CountUsersWithRole implements Repo.
func (r *PgRepo) CountUsersWithRole(ctx context.Context, companyID, roleID uuid.UUID) (int64, error) {
	var out int64
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.CountUsersWithRole(ctx, db.CountUsersWithRoleParams{
			CompanyID: pgconv.UUID(companyID), RoleID: roleID,
		})
		return err
	})
	return out, err
}

// CreateRole implements Repo: role, permissions and audit in one transaction.
func (r *PgRepo) CreateRole(ctx context.Context, in CreateRoleInput,
	entries func(roleID uuid.UUID) []audit.Entry) (db.Role, error) {
	var out db.Role
	err := r.tx(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		created, err := q.CreateRole(ctx, db.CreateRoleParams{
			CompanyID:   pgconv.UUID(in.CompanyID),
			Name:        in.Name,
			Description: in.Description,
			Scope:       in.Scope,
		})
		if err != nil {
			return err
		}
		if err := q.AddRolePermissions(ctx, db.AddRolePermissionsParams{
			RoleID: created.ID, Column2: in.Permissions,
		}); err != nil {
			return err
		}
		out = created
		if entries == nil {
			return nil
		}
		return r.recorder.RecordTx(ctx, tx, entries(created.ID)...)
	})
	return out, err
}

// UpdateRole implements Repo. A non nil Permissions slice replaces the whole
// set; the delete and insert stay in the same transaction.
func (r *PgRepo) UpdateRole(ctx context.Context, in UpdateRoleInput, entries []audit.Entry) (db.Role, error) {
	var out db.Role
	err := r.tx(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		updated, err := q.UpdateRole(ctx, db.UpdateRoleParams{
			CompanyID:   in.CompanyID,
			ID:          in.ID,
			Name:        in.Name,
			Description: in.Description,
			Scope:       in.Scope,
		})
		if err != nil {
			return err
		}
		if in.Permissions != nil {
			if err := q.DeleteRolePermissions(ctx, in.ID); err != nil {
				return err
			}
			if err := q.AddRolePermissions(ctx, db.AddRolePermissionsParams{
				RoleID: in.ID, Column2: in.Permissions,
			}); err != nil {
				return err
			}
		}
		out = updated
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	return out, err
}

// SoftDeleteRole implements Repo.
func (r *PgRepo) SoftDeleteRole(ctx context.Context, companyID, id uuid.UUID, entries []audit.Entry) error {
	return r.tx(ctx, companyID, func(tx pgx.Tx, q *db.Queries) error {
		if err := q.SoftDeleteRole(ctx, db.SoftDeleteRoleParams{
			CompanyID: pgconv.UUID(companyID), ID: id,
		}); err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
}

// RevokeRoleSessions implements Repo: every session of every user holding the
// role is revoked so a narrowed role takes effect immediately.
func (r *PgRepo) RevokeRoleSessions(ctx context.Context, companyID, roleID uuid.UUID, reason string) ([]uuid.UUID, error) {
	var out []uuid.UUID
	err := r.tx(ctx, companyID, func(_ pgx.Tx, q *db.Queries) error {
		var err error
		out, err = q.RevokeSessionsByRoleReturning(ctx, db.RevokeSessionsByRoleReturningParams{
			CompanyID: companyID, RoleID: roleID, Reason: pgconv.NilIfEmpty(reason),
		})
		return err
	})
	return out, err
}
