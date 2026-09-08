package dashboard

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Windows are the company timezone boundaries already converted to UTC.
type Windows struct {
	DayStart time.Time
	DayEnd   time.Time
	// WeekStart / WeekEnd bound the current ISO week (Monday–Sunday).
	WeekStart time.Time
	WeekEnd   time.Time
	// UncertifiedBefore is the newest log date that already counts as
	// uncertified (TZ A§20 — two days or more).
	UncertifiedBefore time.Time
	// BranchID narrows every KPI card and the route block for a branch
	// scoped principal. Nil means company-wide.
	BranchID *uuid.UUID
	// RouteLimit bounds the "Route's Details" block.
	RouteLimit int32
}

// Repo is everything the dashboard needs from storage; it is a read-only
// surface, so no method writes and none of them audit.
type Repo interface {
	KPI(ctx context.Context, w Windows) (db.DashboardKPIRow, error)
	Routes(ctx context.Context, w Windows) ([]db.DashboardTodayRoutesRow, error)
	CompanyTimezone(ctx context.Context) (string, error)
	// OwnsUnits reports whether every id belongs to the tenant; it backs the
	// WebSocket tracking subscription check.
	OwnsUnits(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) error
}

// PgRepo is the pgx/sqlc implementation of Repo.
type PgRepo struct {
	pool *db.Pool
}

// NewRepo builds the storage adapter.
func NewRepo(pool *db.Pool) *PgRepo { return &PgRepo{pool: pool} }

func (r *PgRepo) read(ctx context.Context, companyID uuid.UUID, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error {
		return fn(db.New(tx))
	})
}

// KPI implements Repo.
func (r *PgRepo) KPI(ctx context.Context, w Windows) (db.DashboardKPIRow, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.DashboardKPIRow
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.DashboardKPI(ctx, db.DashboardKPIParams{
			CompanyID:         companyID,
			BranchID:          pgconv.UUIDPtr(w.BranchID),
			DayStart:          w.DayStart,
			WeekStart:         w.WeekStart,
			WeekEnd:           w.WeekEnd,
			UncertifiedBefore: pgtypeDate(w.UncertifiedBefore),
		})
		return err
	})
	return out, err
}

// Routes implements Repo.
func (r *PgRepo) Routes(ctx context.Context, w Windows) ([]db.DashboardTodayRoutesRow, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.DashboardTodayRoutesRow
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		rows, err = q.DashboardTodayRoutes(ctx, db.DashboardTodayRoutesParams{
			CompanyID: companyID,
			BranchID:  pgconv.UUIDPtr(w.BranchID),
			DayStart:  w.DayStart,
			DayEnd:    w.DayEnd,
			RowLimit:  w.RouteLimit,
		})
		return err
	})
	return rows, err
}

// CompanyTimezone implements Repo.
func (r *PgRepo) CompanyTimezone(ctx context.Context) (string, error) {
	companyID := tenant.CompanyID(ctx)
	var tz string
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		v, err := q.DashboardCompanyTimezone(ctx, companyID)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		if err != nil {
			return err
		}
		tz = v
		return nil
	})
	return tz, err
}

// OwnsUnits implements Repo and ws.UnitOwner.
func (r *PgRepo) OwnsUnits(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) error {
	if len(ids) == 0 {
		return nil
	}
	var n int64
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		n, err = q.CountUnitsOwned(ctx, db.CountUnitsOwnedParams{CompanyID: companyID, Column2: ids})
		return err
	})
	if err != nil {
		return err
	}
	if int(n) != len(unique(ids)) {
		return errUnknownUnits
	}
	return nil
}

func unique(ids []uuid.UUID) []uuid.UUID {
	seen := make(map[uuid.UUID]struct{}, len(ids))
	out := make([]uuid.UUID, 0, len(ids))
	for _, id := range ids {
		if _, ok := seen[id]; ok {
			continue
		}
		seen[id] = struct{}{}
		out = append(out, id)
	}
	return out
}

// pgtypeDate renders a calendar day for a `date` column.
func pgtypeDate(t time.Time) pgtype.Date {
	return pgtype.Date{Time: time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC), Valid: true}
}
