package auditlog

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Filter is the resolved GET /audit-log query. Nil pointers mean "no filter".
type Filter struct {
	TableName *string
	RecordID  *uuid.UUID
	// UserID filters on audit_log.edited_by — the `user` query parameter.
	UserID *uuid.UUID
	Action *string
	From   *time.Time
	To     *time.Time
	Order  string
	Limit  int32
	Offset int32
}

// Repo is everything the audit log service needs from storage. There is no
// write method on purpose: `audit_log` is append-only and a database trigger
// rejects UPDATE and DELETE. Entries are written by internal/audit only.
type Repo interface {
	List(ctx context.Context, f Filter) ([]db.ListAuditLogRow, int64, error)
	Tables(ctx context.Context) ([]string, error)
}

// PgRepo is the pgx/sqlc implementation of Repo.
type PgRepo struct {
	pool *db.Pool
}

// NewRepo builds the storage adapter.
func NewRepo(pool *db.Pool) *PgRepo { return &PgRepo{pool: pool} }

func (r *PgRepo) read(ctx context.Context, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, tenant.CompanyID(ctx), func(tx pgx.Tx) error {
		return fn(db.New(tx))
	})
}

// List implements Repo.
func (r *PgRepo) List(ctx context.Context, f Filter) ([]db.ListAuditLogRow, int64, error) {
	companyID := pgconv.UUID(tenant.CompanyID(ctx))
	var rows []db.ListAuditLogRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListAuditLog(ctx, db.ListAuditLogParams{
			CompanyID: companyID,
			TableName: f.TableName,
			RecordID:  pgconv.UUIDPtr(f.RecordID),
			EditedBy:  pgconv.UUIDPtr(f.UserID),
			Action:    f.Action,
			FromTs:    pgconv.TimePtr(f.From),
			ToTs:      pgconv.TimePtr(f.To),
			SortDir:   f.Order,
			RowLimit:  f.Limit,
			RowOffset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountAuditLog(ctx, db.CountAuditLogParams{
			CompanyID: companyID,
			TableName: f.TableName,
			RecordID:  pgconv.UUIDPtr(f.RecordID),
			EditedBy:  pgconv.UUIDPtr(f.UserID),
			Action:    f.Action,
			FromTs:    pgconv.TimePtr(f.From),
			ToTs:      pgconv.TimePtr(f.To),
		})
		return err
	})
	return rows, total, err
}

// Tables implements Repo.
func (r *PgRepo) Tables(ctx context.Context) ([]string, error) {
	var out []string
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.ListAuditLogTables(ctx, pgconv.UUID(tenant.CompanyID(ctx)))
		return err
	})
	return out, err
}
