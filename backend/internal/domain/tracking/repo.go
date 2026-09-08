package tracking

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// LiveFilter is the resolved GET /tracking/live query. Nil pointers mean
// "no filter"; BranchID is forced by the scope middleware for a branch
// restricted principal.
type LiveFilter struct {
	UnitIDs         []uuid.UUID
	BranchID        *uuid.UUID
	OnlineStatus    *string
	IncludeInactive bool
	Limit           int32
	Offset          int32
}

// TripFilter is the resolved GET /units/{id}/trips query. From and To are the
// company timezone day boundaries already converted to UTC.
type TripFilter struct {
	UnitID uuid.UUID
	From   time.Time
	To     time.Time
	Limit  int32
	Offset int32
}

// UnidentifiedFilter is the resolved GET /unidentified-events query.
type UnidentifiedFilter struct {
	Status   *string
	UnitID   *uuid.UUID
	BranchID *uuid.UUID
	From     *time.Time
	To       *time.Time
	Limit    int32
	Offset   int32
}

// Repo is everything the tracking service needs from storage. Tracking is a
// read-only surface, so no method writes and none of them audit.
type Repo interface {
	ListLive(ctx context.Context, f LiveFilter) ([]db.TrackingListLiveUnitsRow, int64, error)
	UnitBrief(ctx context.Context, id uuid.UUID) (db.TrackingGetUnitBriefRow, error)
	ListTrips(ctx context.Context, f TripFilter) ([]db.TrackingListUnitTripsRow, int64, error)
	GetTrip(ctx context.Context, id uuid.UUID) (db.TrackingGetTripRow, error)
	TripPoints(ctx context.Context, unitID uuid.UUID, from, to time.Time, limit int32) ([]db.TrackingListTripPointsRow, error)
	CompanyTimezone(ctx context.Context) (string, error)
	ListUnidentified(ctx context.Context, f UnidentifiedFilter) ([]db.TrackingListUnidentifiedEventsRow, int64, error)
}

// PgRepo is the pgx/sqlc implementation of Repo. Every statement runs through
// Pool.WithConn, which sets `SET LOCAL app.company_id` so RLS is the second
// line of defence behind the explicit company_id predicates.
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

// ListLive implements Repo.
func (r *PgRepo) ListLive(ctx context.Context, f LiveFilter) ([]db.TrackingListLiveUnitsRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.TrackingListLiveUnitsRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.TrackingListLiveUnits(ctx, db.TrackingListLiveUnitsParams{
			CompanyID:       companyID,
			UnitIds:         f.UnitIDs,
			BranchID:        pgconv.UUIDPtr(f.BranchID),
			OnlineStatus:    f.OnlineStatus,
			IncludeInactive: f.IncludeInactive,
			Limit:           f.Limit,
			Offset:          f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.TrackingCountLiveUnits(ctx, db.TrackingCountLiveUnitsParams{
			CompanyID:       companyID,
			UnitIds:         f.UnitIDs,
			BranchID:        pgconv.UUIDPtr(f.BranchID),
			OnlineStatus:    f.OnlineStatus,
			IncludeInactive: f.IncludeInactive,
		})
		return err
	})
	return rows, total, err
}

// UnitBrief implements Repo.
func (r *PgRepo) UnitBrief(ctx context.Context, id uuid.UUID) (db.TrackingGetUnitBriefRow, error) {
	var out db.TrackingGetUnitBriefRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.TrackingGetUnitBrief(ctx, db.TrackingGetUnitBriefParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// ListTrips implements Repo.
func (r *PgRepo) ListTrips(ctx context.Context, f TripFilter) ([]db.TrackingListUnitTripsRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.TrackingListUnitTripsRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.TrackingListUnitTrips(ctx, db.TrackingListUnitTripsParams{
			CompanyID: companyID, UnitID: f.UnitID, FromAt: f.From, ToAt: f.To,
			Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.TrackingCountUnitTrips(ctx, db.TrackingCountUnitTripsParams{
			CompanyID: companyID, UnitID: f.UnitID, FromAt: f.From, ToAt: f.To,
		})
		return err
	})
	return rows, total, err
}

// GetTrip implements Repo.
func (r *PgRepo) GetTrip(ctx context.Context, id uuid.UUID) (db.TrackingGetTripRow, error) {
	var out db.TrackingGetTripRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.TrackingGetTrip(ctx, db.TrackingGetTripParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// TripPoints implements Repo.
func (r *PgRepo) TripPoints(
	ctx context.Context, unitID uuid.UUID, from, to time.Time, limit int32,
) ([]db.TrackingListTripPointsRow, error) {
	var rows []db.TrackingListTripPointsRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.TrackingListTripPoints(ctx, db.TrackingListTripPointsParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID,
			FromAt: from, ToAt: to, Limit: limit,
		})
		return err
	})
	return rows, err
}

// CompanyTimezone implements Repo.
func (r *PgRepo) CompanyTimezone(ctx context.Context) (string, error) {
	var tz string
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		tz, err = q.TrackingGetCompanyTimezone(ctx, tenant.CompanyID(ctx))
		return err
	})
	return tz, err
}

// ListUnidentified implements Repo.
func (r *PgRepo) ListUnidentified(ctx context.Context, f UnidentifiedFilter) ([]db.TrackingListUnidentifiedEventsRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.TrackingListUnidentifiedEventsRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.TrackingListUnidentifiedEvents(ctx, db.TrackingListUnidentifiedEventsParams{
			CompanyID: companyID,
			Status:    f.Status,
			UnitID:    pgconv.UUIDPtr(f.UnitID),
			BranchID:  pgconv.UUIDPtr(f.BranchID),
			FromAt:    pgconv.TimePtr(f.From),
			ToAt:      pgconv.TimePtr(f.To),
			Limit:     f.Limit,
			Offset:    f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.TrackingCountUnidentifiedEvents(ctx, db.TrackingCountUnidentifiedEventsParams{
			CompanyID: companyID,
			Status:    f.Status,
			UnitID:    pgconv.UUIDPtr(f.UnitID),
			BranchID:  pgconv.UUIDPtr(f.BranchID),
			FromAt:    pgconv.TimePtr(f.From),
			ToAt:      pgconv.TimePtr(f.To),
		})
		return err
	})
	return rows, total, err
}
