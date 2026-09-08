package routes

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Filter is the resolved GET /routes query. Nil pointers mean "no filter".
type Filter struct {
	Status   *string
	DriverID *uuid.UUID
	UnitID   *uuid.UUID
	// BranchID narrows the page to the legs of one branch. It is never taken
	// from the query string: the service fills it from the caller's scope.
	BranchID *uuid.UUID
	Sort     string
	Order    string
	Limit    int32
	Offset   int32
}

// Repo is everything the routes service needs from storage. Mutating methods
// take a callback that builds the audit entries; the repository writes the
// change and its audit trail inside one transaction so they can never diverge.
type Repo interface {
	List(ctx context.Context, f Filter) ([]db.ListRoutesRow, int64, error)
	Get(ctx context.Context, id uuid.UUID) (db.GetRouteDetailRow, error)
	NextSequence(ctx context.Context, unitID uuid.UUID) (int32, error)
	Create(ctx context.Context, arg db.CreateRouteParams,
		mk func(db.Route) []audit.Entry) (db.GetRouteDetailRow, error)
	Update(ctx context.Context, arg db.UpdateRouteParams,
		mk func(before, after db.Route) []audit.Entry) (db.GetRouteDetailRow, error)
	Delete(ctx context.Context, id uuid.UUID, mk func(db.Route) []audit.Entry) error
	NotCompleted(ctx context.Context, arg db.SetRouteNotCompletedParams,
		mk func(before, after db.Route) []audit.Entry) (db.GetRouteDetailRow, error)

	// CurrentForGeofence returns, per unit, the current ongoing route (Q68 —
	// the lowest sequence) together with the unit's last known position.
	CurrentForGeofence(ctx context.Context) ([]db.ListCurrentRoutesForGeofenceRow, error)
	// SetGeofenceEnteredAt records or clears the dwell start of one route.
	SetGeofenceEnteredAt(ctx context.Context, id uuid.UUID, at *time.Time) error
	// Complete moves an ongoing route to `completed`.
	Complete(ctx context.Context, id uuid.UUID, at time.Time,
		mk func(db.Route) []audit.Entry) (db.Route, error)

	// Unit and Driver resolve the referenced rows inside the tenant. They are
	// the cross-tenant guard: a foreign id must answer 404, never link.
	Unit(ctx context.Context, id uuid.UUID) (db.Unit, error)
	Driver(ctx context.Context, id uuid.UUID) (db.FleetGetDriverBriefRow, error)
	// DriverIDForUser resolves the caller's own driver row. It backs the
	// `self` scope of the driver application (TZ A§16).
	DriverIDForUser(ctx context.Context, userID uuid.UUID) (uuid.UUID, error)
}

// PgRepo is the pgx/sqlc implementation of Repo. Every statement runs through
// Pool.WithTx / Pool.WithConn, which sets `SET LOCAL app.company_id` so RLS is
// the second line of defence behind the explicit company_id predicates.
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

func (r *PgRepo) read(ctx context.Context, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, tenant.CompanyID(ctx), func(tx pgx.Tx) error {
		return fn(db.New(tx))
	})
}

func (r *PgRepo) write(ctx context.Context, fn func(q *db.Queries, tx pgx.Tx) error) error {
	return r.pool.WithTx(ctx, tenant.CompanyID(ctx), func(tx pgx.Tx) error {
		return fn(db.New(tx), tx)
	})
}

// List implements Repo.
func (r *PgRepo) List(ctx context.Context, f Filter) ([]db.ListRoutesRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ListRoutesRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListRoutes(ctx, db.ListRoutesParams{
			CompanyID: companyID,
			Status:    f.Status,
			DriverID:  pgconv.UUIDPtr(f.DriverID),
			UnitID:    pgconv.UUIDPtr(f.UnitID),
			BranchID:  pgconv.UUIDPtr(f.BranchID),
			Sort:      f.Sort,
			SortOrder: f.Order,
			Limit:     f.Limit,
			Offset:    f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountRoutes(ctx, db.CountRoutesParams{
			CompanyID: companyID,
			Status:    f.Status,
			DriverID:  pgconv.UUIDPtr(f.DriverID),
			UnitID:    pgconv.UUIDPtr(f.UnitID),
			BranchID:  pgconv.UUIDPtr(f.BranchID),
		})
		return err
	})
	return rows, total, err
}

// Get implements Repo.
func (r *PgRepo) Get(ctx context.Context, id uuid.UUID) (db.GetRouteDetailRow, error) {
	var out db.GetRouteDetailRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetRouteDetail(ctx, db.GetRouteDetailParams{CompanyID: tenant.CompanyID(ctx), ID: id})
		return err
	})
	return out, err
}

// NextSequence implements Repo.
func (r *PgRepo) NextSequence(ctx context.Context, unitID uuid.UUID) (int32, error) {
	var next int32
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		next, err = q.NextRouteSequence(ctx, db.NextRouteSequenceParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID,
		})
		return err
	})
	return next, err
}

// Create implements Repo.
func (r *PgRepo) Create(ctx context.Context, arg db.CreateRouteParams,
	mk func(db.Route) []audit.Entry) (db.GetRouteDetailRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.GetRouteDetailRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		row, err := q.CreateRoute(ctx, arg)
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(row)...); err != nil {
			return err
		}
		out, err = q.GetRouteDetail(ctx, db.GetRouteDetailParams{CompanyID: companyID, ID: row.ID})
		return err
	})
	return out, err
}

// Update implements Repo.
func (r *PgRepo) Update(ctx context.Context, arg db.UpdateRouteParams,
	mk func(before, after db.Route) []audit.Entry) (db.GetRouteDetailRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.GetRouteDetailRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetRoute(ctx, db.GetRouteParams{CompanyID: companyID, ID: arg.ID})
		if err != nil {
			return err
		}
		after, err := q.UpdateRoute(ctx, arg)
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(before, after)...); err != nil {
			return err
		}
		out, err = q.GetRouteDetail(ctx, db.GetRouteDetailParams{CompanyID: companyID, ID: after.ID})
		return err
	})
	return out, err
}

// Delete implements Repo.
func (r *PgRepo) Delete(ctx context.Context, id uuid.UUID, mk func(db.Route) []audit.Entry) error {
	companyID := tenant.CompanyID(ctx)
	return r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetRoute(ctx, db.GetRouteParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		if err := q.SoftDeleteRoute(ctx, db.SoftDeleteRouteParams{CompanyID: companyID, ID: id}); err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(before)...)
	})
}

// NotCompleted implements Repo.
func (r *PgRepo) NotCompleted(ctx context.Context, arg db.SetRouteNotCompletedParams,
	mk func(before, after db.Route) []audit.Entry) (db.GetRouteDetailRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.GetRouteDetailRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetRoute(ctx, db.GetRouteParams{CompanyID: companyID, ID: arg.ID})
		if err != nil {
			return err
		}
		after, err := q.SetRouteNotCompleted(ctx, arg)
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(before, after)...); err != nil {
			return err
		}
		out, err = q.GetRouteDetail(ctx, db.GetRouteDetailParams{CompanyID: companyID, ID: after.ID})
		return err
	})
	return out, err
}

// CurrentForGeofence implements Repo.
func (r *PgRepo) CurrentForGeofence(ctx context.Context) ([]db.ListCurrentRoutesForGeofenceRow, error) {
	var rows []db.ListCurrentRoutesForGeofenceRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListCurrentRoutesForGeofence(ctx, tenant.CompanyID(ctx))
		return err
	})
	return rows, err
}

// SetGeofenceEnteredAt implements Repo.
func (r *PgRepo) SetGeofenceEnteredAt(ctx context.Context, id uuid.UUID, at *time.Time) error {
	return r.write(ctx, func(q *db.Queries, _ pgx.Tx) error {
		return q.SetRouteGeofenceEnteredAt(ctx, db.SetRouteGeofenceEnteredAtParams{
			CompanyID: tenant.CompanyID(ctx), ID: id, GeofenceEnteredAt: pgconv.TimePtr(at),
		})
	})
}

// Complete implements Repo.
func (r *PgRepo) Complete(ctx context.Context, id uuid.UUID, at time.Time,
	mk func(db.Route) []audit.Entry) (db.Route, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.Route
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		var err error
		out, err = q.CompleteRoute(ctx, db.CompleteRouteParams{
			CompanyID: companyID, ID: id, CompletedAt: pgconv.Time(at),
		})
		if err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(out)...)
	})
	return out, err
}

// Unit implements Repo.
func (r *PgRepo) Unit(ctx context.Context, id uuid.UUID) (db.Unit, error) {
	var out db.Unit
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetUnit(ctx, db.GetUnitParams{CompanyID: tenant.CompanyID(ctx), ID: id})
		return err
	})
	return out, err
}

// Driver implements Repo.
func (r *PgRepo) Driver(ctx context.Context, id uuid.UUID) (db.FleetGetDriverBriefRow, error) {
	var out db.FleetGetDriverBriefRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.FleetGetDriverBrief(ctx, db.FleetGetDriverBriefParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// DriverIDForUser implements Repo.
func (r *PgRepo) DriverIDForUser(ctx context.Context, userID uuid.UUID) (uuid.UUID, error) {
	var out uuid.UUID
	err := r.read(ctx, func(q *db.Queries) error {
		row, err := q.GetDriverByUserID(ctx, db.GetDriverByUserIDParams{
			CompanyID: tenant.CompanyID(ctx), UserID: userID,
		})
		if err != nil {
			return err
		}
		out = row.ID
		return nil
	})
	return out, err
}

// compile time guard.
var _ Repo = (*PgRepo)(nil)
