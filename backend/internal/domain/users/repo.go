package users

import (
	"context"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
)

// PgRepo is the pgx/sqlc implementation of Repo. Every statement runs inside
// Pool.WithTx, which opens the transaction with SET LOCAL app.company_id so RLS
// is the second line of defence behind the explicit company_id predicates.
type PgRepo struct {
	pool     *db.Pool
	recorder audit.Recorder
}

// NewRepo builds the storage adapter.
func NewRepo(pool *db.Pool, recorder audit.Recorder) *PgRepo {
	if recorder == nil {
		recorder = audit.NopRecorder{}
	}
	return &PgRepo{pool: pool, recorder: recorder}
}

func (r *PgRepo) tx(ctx context.Context, companyID uuid.UUID, fn func(tx pgx.Tx, q *db.Queries) error) error {
	return r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		return fn(tx, db.New(tx))
	})
}

func (r *PgRepo) read(ctx context.Context, companyID uuid.UUID, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error {
		return fn(db.New(tx))
	})
}

// ListUsers implements Repo.
func (r *PgRepo) ListUsers(ctx context.Context, f UserFilter) ([]db.ListUsersRow, int64, error) {
	var (
		rows  []db.ListUsersRow
		total int64
	)
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		rows, err = q.ListUsers(ctx, db.ListUsersParams{
			CompanyID:  f.CompanyID,
			Search:     f.Search,
			Status:     f.Status,
			RoleID:     pgconv.UUIDPtr(f.RoleID),
			BranchID:   pgconv.UUIDPtr(f.BranchID),
			SortKey:    f.Sort,
			SortDesc:   f.SortDesc,
			PageLimit:  f.Limit,
			PageOffset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountUsers(ctx, db.CountUsersParams{
			CompanyID: f.CompanyID,
			Search:    f.Search,
			Status:    f.Status,
			RoleID:    pgconv.UUIDPtr(f.RoleID),
			BranchID:  pgconv.UUIDPtr(f.BranchID),
		})
		return err
	})
	return rows, total, err
}

// GetUser implements Repo.
func (r *PgRepo) GetUser(ctx context.Context, companyID, id uuid.UUID) (db.GetUserDetailRow, error) {
	var out db.GetUserDetailRow
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.GetUserDetail(ctx, db.GetUserDetailParams{CompanyID: companyID, ID: id})
		return err
	})
	return out, err
}

// CountAdministrators implements Repo.
func (r *PgRepo) CountAdministrators(ctx context.Context, companyID, excludeUserID uuid.UUID) (int64, error) {
	var out int64
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.CountCompanyAdministrators(ctx, db.CountCompanyAdministratorsParams{
			CompanyID: companyID, ExcludeUserID: excludeUserID,
		})
		return err
	})
	return out, err
}

// CreateInvitedUser implements Repo: user row, invitation and audit entries are
// written atomically.
func (r *PgRepo) CreateInvitedUser(ctx context.Context, in CreateUserInput, inv InvitationInput,
	entries func(userID uuid.UUID) []audit.Entry) (db.GetUserDetailRow, error) {
	var out db.GetUserDetailRow
	err := r.tx(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		created, err := q.CreateUser(ctx, db.CreateUserParams{
			CompanyID: pgconv.UUID(in.CompanyID),
			BranchID:  pgconv.UUIDPtr(in.BranchID),
			FirstName: in.FirstName,
			LastName:  in.LastName,
			Email:     in.Email,
			Phone:     in.Phone,
			Username:  in.Username,
			RoleID:    in.RoleID,
			Status:    StatusInvited,
			InvitedAt: pgconv.Time(in.InvitedAt),
		})
		if err != nil {
			return err
		}
		if _, err := q.CreateInvitation(ctx, db.CreateInvitationParams{
			CompanyID: pgconv.UUID(inv.CompanyID),
			UserID:    created.ID,
			TokenHash: inv.TokenHash,
			Channel:   inv.Channel,
			Purpose:   inv.Purpose,
			ExpiresAt: inv.ExpiresAt.UTC(),
		}); err != nil {
			return err
		}
		if entries != nil {
			if err := r.recorder.RecordTx(ctx, tx, entries(created.ID)...); err != nil {
				return err
			}
		}
		out, err = q.GetUserDetail(ctx, db.GetUserDetailParams{CompanyID: in.CompanyID, ID: created.ID})
		return err
	})
	return out, err
}

// UpdateUser implements Repo. When RevokeSessions is set, the sessions of the
// account are revoked in the same transaction and their ids are returned.
func (r *PgRepo) UpdateUser(ctx context.Context, in UpdateUserInput, entries []audit.Entry) (db.GetUserDetailRow, []uuid.UUID, error) {
	var (
		out      db.GetUserDetailRow
		sessions []uuid.UUID
	)
	err := r.tx(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		if _, err := q.UpdateUser(ctx, db.UpdateUserParams{
			CompanyID:   in.CompanyID,
			ID:          in.ID,
			FirstName:   in.FirstName,
			LastName:    in.LastName,
			Email:       in.Email,
			Phone:       in.Phone,
			Username:    in.Username,
			RoleID:      pgconv.UUIDPtr(in.RoleID),
			BranchID:    pgconv.UUIDPtr(in.BranchID),
			ClearBranch: in.ClearBranch,
		}); err != nil {
			return err
		}
		if in.RevokeSessions {
			revoked, err := q.RevokeAllUserSessionsReturning(ctx, db.RevokeAllUserSessionsReturningParams{
				UserID: in.ID, RevokedReason: pgconv.NilIfEmpty(reasonPermissionChange),
			})
			if err != nil {
				return err
			}
			sessions = revoked
		}
		if err := r.recorder.RecordTx(ctx, tx, entries...); err != nil {
			return err
		}
		var err error
		out, err = q.GetUserDetail(ctx, db.GetUserDetailParams{CompanyID: in.CompanyID, ID: in.ID})
		return err
	})
	return out, sessions, err
}

// SetUserStatus implements Repo. Deactivating also revokes every session of the
// account and returns their ids so the caller can add them to the deny list
// (TZ Q3.1).
func (r *PgRepo) SetUserStatus(ctx context.Context, companyID, id uuid.UUID, status, reason string,
	entries []audit.Entry) (db.GetUserDetailRow, []uuid.UUID, error) {
	var (
		out      db.GetUserDetailRow
		sessions []uuid.UUID
	)
	err := r.tx(ctx, companyID, func(tx pgx.Tx, q *db.Queries) error {
		if _, err := q.SetUserStatus(ctx, db.SetUserStatusParams{
			CompanyID: companyID, ID: id, Status: status,
		}); err != nil {
			return err
		}
		if status != StatusActive {
			revoked, err := q.RevokeAllUserSessionsReturning(ctx, db.RevokeAllUserSessionsReturningParams{
				UserID: id, RevokedReason: pgconv.NilIfEmpty(reason),
			})
			if err != nil {
				return err
			}
			sessions = revoked
		}
		if err := r.recorder.RecordTx(ctx, tx, entries...); err != nil {
			return err
		}
		var err error
		out, err = q.GetUserDetail(ctx, db.GetUserDetailParams{CompanyID: companyID, ID: id})
		return err
	})
	return out, sessions, err
}

// SoftDeleteUser implements Repo: deleted_at is stamped, every session is
// revoked and the audit entry is written in one transaction.
func (r *PgRepo) SoftDeleteUser(ctx context.Context, companyID, id uuid.UUID, reason string,
	entries []audit.Entry) ([]uuid.UUID, error) {
	var sessions []uuid.UUID
	err := r.tx(ctx, companyID, func(tx pgx.Tx, q *db.Queries) error {
		if err := q.SoftDeleteUser(ctx, db.SoftDeleteUserParams{CompanyID: pgconv.UUID(companyID), ID: id}); err != nil {
			return err
		}
		revoked, err := q.RevokeAllUserSessionsReturning(ctx, db.RevokeAllUserSessionsReturningParams{
			UserID: id, RevokedReason: pgconv.NilIfEmpty(reason),
		})
		if err != nil {
			return err
		}
		sessions = revoked
		_ = q.InvalidateUserInvitations(ctx, db.InvalidateUserInvitationsParams{
			UserID: id, Purpose: PurposeInvitation,
		})
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	return sessions, err
}

// ReissueInvitation implements Repo: the previous link is invalidated and a new
// one is stored in the same transaction as the audit entry.
func (r *PgRepo) ReissueInvitation(ctx context.Context, inv InvitationInput, entries []audit.Entry) error {
	return r.tx(ctx, inv.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		if err := q.InvalidateUserInvitations(ctx, db.InvalidateUserInvitationsParams{
			UserID: inv.UserID, Purpose: inv.Purpose,
		}); err != nil {
			return err
		}
		if _, err := q.CreateInvitation(ctx, db.CreateInvitationParams{
			CompanyID: pgconv.UUID(inv.CompanyID),
			UserID:    inv.UserID,
			TokenHash: inv.TokenHash,
			Channel:   inv.Channel,
			Purpose:   inv.Purpose,
			ExpiresAt: inv.ExpiresAt.UTC(),
		}); err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
}

// ---------------------------------------------------------------- helpers

// reasonPermissionChange is the sessions.revoked_reason written when a role or
// permission change invalidates the sessions of an account.
const reasonPermissionChange = "permission_change"
