package reports

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// ActivityFilter is the resolved GET /reports/activity query.
type ActivityFilter struct {
	// Subject is "drivers" or "units".
	Subject string
	// From is inclusive, To is exclusive; both are UTC instants.
	From, To  time.Time
	DriverIDs []uuid.UUID
	UnitIDs   []uuid.UUID
	// BranchID narrows the report to one branch (TZ A§16 `branch` scope). It
	// is never read from the query string; the service fills it from the
	// caller's ScopeFilter.
	BranchID *uuid.UUID
	Limit    int32
	Offset   int32
}

// RegionFilter is the resolved Distance by Region window. From and To are
// inclusive dates.
type RegionFilter struct {
	From, To time.Time
	UnitIDs  []uuid.UUID
	// BranchID narrows the roll-up to the units of one branch.
	BranchID *uuid.UUID
}

// HosFilter is the resolved HOS summary window. From and To are inclusive
// dates.
type HosFilter struct {
	From, To  time.Time
	DriverIDs []uuid.UUID
	// BranchID narrows the summary to the drivers of one branch.
	BranchID *uuid.UUID
	Limit    int32
	Offset   int32
}

// JobFilter is the resolved export job list query.
type JobFilter struct {
	Status      *string
	Type        *string
	RequestedBy *uuid.UUID
	Limit       int32
	Offset      int32
}

// Repo is everything the reporting service needs from storage.
type Repo interface {
	ActivityUnits(ctx context.Context, f ActivityFilter) ([]db.ReportActivityUnitsRow, int64, error)
	ActivityDrivers(ctx context.Context, f ActivityFilter) ([]db.ReportActivityDriversRow, int64, error)
	RegionTotals(ctx context.Context, f RegionFilter) ([]db.ReportDistanceByRegionRow, error)
	RegionByUnit(ctx context.Context, f RegionFilter) ([]db.ReportDistanceByRegionUnitsRow, error)
	HosSummary(ctx context.Context, f HosFilter) ([]db.ReportHosSummaryRow, int64, error)
	// Company resolves the tenant row; the regulator export reads its
	// regulation profile from it.
	Company(ctx context.Context) (db.Company, error)

	CreateJob(ctx context.Context, arg db.CreateReportExportJobParams,
		mk func(db.ReportExportJob) []audit.Entry) (db.ReportExportJob, error)
	GetJob(ctx context.Context, id uuid.UUID) (db.ReportExportJob, error)
	ListJobs(ctx context.Context, f JobFilter) ([]db.ReportExportJob, int64, error)
	StartJob(ctx context.Context, id uuid.UUID) (db.ReportExportJob, error)
	FinishJob(ctx context.Context, arg db.FinishReportExportJobParams,
		mk func(db.ReportExportJob) []audit.Entry) (db.ReportExportJob, error)
	FailJob(ctx context.Context, id uuid.UUID, reason string) (db.ReportExportJob, error)

	// The daily Distance by Region aggregation.
	UnitsWithTelemetry(ctx context.Context, from, to time.Time) ([]uuid.UUID, error)
	UnitTrack(ctx context.Context, unitID uuid.UUID, from, to time.Time) ([]db.ListUnitTrackRow, error)
	RegionAt(ctx context.Context, lat, lng float64) (db.FindRegionByPointRow, error)
	ResetRegionDay(ctx context.Context, unitID uuid.UUID, day time.Time) error
	AddRegionDistance(ctx context.Context, unitID uuid.UUID, regionCode string, day time.Time, distanceM int64) error
}

// PgRepo is the pgx/sqlc implementation of Repo.
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

// date turns a UTC instant into the SQL date the daily roll-up is keyed by.
func date(t time.Time) pgtype.Date {
	return pgtype.Date{Time: time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC), Valid: true}
}

// ActivityUnits implements Repo.
func (r *PgRepo) ActivityUnits(ctx context.Context, f ActivityFilter) ([]db.ReportActivityUnitsRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ReportActivityUnitsRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ReportActivityUnits(ctx, db.ReportActivityUnitsParams{
			CompanyID: companyID, FromTs: f.From, ToTs: f.To,
			UnitIds: f.UnitIDs, BranchID: pgconv.UUIDPtr(f.BranchID),
			Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountReportActivityUnits(ctx, db.CountReportActivityUnitsParams{
			CompanyID: companyID, UnitIds: f.UnitIDs, BranchID: pgconv.UUIDPtr(f.BranchID),
		})
		return err
	})
	return rows, total, err
}

// ActivityDrivers implements Repo.
func (r *PgRepo) ActivityDrivers(ctx context.Context, f ActivityFilter) ([]db.ReportActivityDriversRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ReportActivityDriversRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ReportActivityDrivers(ctx, db.ReportActivityDriversParams{
			CompanyID: companyID, FromTs: f.From, ToTs: f.To,
			DriverIds: f.DriverIDs, BranchID: pgconv.UUIDPtr(f.BranchID),
			Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountReportActivityDrivers(ctx, db.CountReportActivityDriversParams{
			CompanyID: companyID, DriverIds: f.DriverIDs, BranchID: pgconv.UUIDPtr(f.BranchID),
		})
		return err
	})
	return rows, total, err
}

// RegionTotals implements Repo.
func (r *PgRepo) RegionTotals(ctx context.Context, f RegionFilter) ([]db.ReportDistanceByRegionRow, error) {
	var rows []db.ReportDistanceByRegionRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ReportDistanceByRegion(ctx, db.ReportDistanceByRegionParams{
			CompanyID: tenant.CompanyID(ctx), FromDate: date(f.From), ToDate: date(f.To),
			UnitIds: f.UnitIDs, BranchID: pgconv.UUIDPtr(f.BranchID),
		})
		return err
	})
	return rows, err
}

// RegionByUnit implements Repo.
func (r *PgRepo) RegionByUnit(ctx context.Context, f RegionFilter) ([]db.ReportDistanceByRegionUnitsRow, error) {
	var rows []db.ReportDistanceByRegionUnitsRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ReportDistanceByRegionUnits(ctx, db.ReportDistanceByRegionUnitsParams{
			CompanyID: tenant.CompanyID(ctx), FromDate: date(f.From), ToDate: date(f.To),
			UnitIds: f.UnitIDs, BranchID: pgconv.UUIDPtr(f.BranchID),
		})
		return err
	})
	return rows, err
}

// HosSummary implements Repo.
func (r *PgRepo) HosSummary(ctx context.Context, f HosFilter) ([]db.ReportHosSummaryRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ReportHosSummaryRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ReportHosSummary(ctx, db.ReportHosSummaryParams{
			CompanyID: companyID, FromDate: date(f.From), ToDate: date(f.To),
			DriverIds: f.DriverIDs, BranchID: pgconv.UUIDPtr(f.BranchID),
			Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountReportHosSummary(ctx, db.CountReportHosSummaryParams{
			CompanyID: companyID, FromDate: date(f.From), ToDate: date(f.To),
			DriverIds: f.DriverIDs, BranchID: pgconv.UUIDPtr(f.BranchID),
		})
		return err
	})
	return rows, total, err
}

// Company implements Repo.
func (r *PgRepo) Company(ctx context.Context) (db.Company, error) {
	var out db.Company
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetCompany(ctx, tenant.CompanyID(ctx))
		return err
	})
	return out, err
}

// CreateJob implements Repo.
func (r *PgRepo) CreateJob(ctx context.Context, arg db.CreateReportExportJobParams,
	mk func(db.ReportExportJob) []audit.Entry) (db.ReportExportJob, error) {
	arg.CompanyID = tenant.CompanyID(ctx)
	var out db.ReportExportJob
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		var err error
		out, err = q.CreateReportExportJob(ctx, arg)
		if err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(out)...)
	})
	return out, err
}

// GetJob implements Repo.
func (r *PgRepo) GetJob(ctx context.Context, id uuid.UUID) (db.ReportExportJob, error) {
	var out db.ReportExportJob
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetReportExportJob(ctx, db.GetReportExportJobParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// ListJobs implements Repo.
func (r *PgRepo) ListJobs(ctx context.Context, f JobFilter) ([]db.ReportExportJob, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ReportExportJob
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListReportExportJobs(ctx, db.ListReportExportJobsParams{
			CompanyID: companyID, Status: f.Status, Type: f.Type,
			RequestedBy: pgconv.UUIDPtr(f.RequestedBy), Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountReportExportJobs(ctx, db.CountReportExportJobsParams{
			CompanyID: companyID, Status: f.Status, Type: f.Type,
			RequestedBy: pgconv.UUIDPtr(f.RequestedBy),
		})
		return err
	})
	return rows, total, err
}

// StartJob implements Repo.
func (r *PgRepo) StartJob(ctx context.Context, id uuid.UUID) (db.ReportExportJob, error) {
	var out db.ReportExportJob
	err := r.write(ctx, func(q *db.Queries, _ pgx.Tx) error {
		var err error
		out, err = q.StartReportExportJob(ctx, db.StartReportExportJobParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// FinishJob implements Repo.
func (r *PgRepo) FinishJob(ctx context.Context, arg db.FinishReportExportJobParams,
	mk func(db.ReportExportJob) []audit.Entry) (db.ReportExportJob, error) {
	arg.CompanyID = tenant.CompanyID(ctx)
	var out db.ReportExportJob
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		var err error
		out, err = q.FinishReportExportJob(ctx, arg)
		if err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(out)...)
	})
	return out, err
}

// FailJob implements Repo.
func (r *PgRepo) FailJob(ctx context.Context, id uuid.UUID, reason string) (db.ReportExportJob, error) {
	var out db.ReportExportJob
	err := r.write(ctx, func(q *db.Queries, _ pgx.Tx) error {
		var err error
		out, err = q.FailReportExportJob(ctx, db.FailReportExportJobParams{
			CompanyID: tenant.CompanyID(ctx), ID: id, Error: &reason,
		})
		return err
	})
	return out, err
}

// UnitsWithTelemetry implements Repo.
func (r *PgRepo) UnitsWithTelemetry(ctx context.Context, from, to time.Time) ([]uuid.UUID, error) {
	var ids []uuid.UUID
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		ids, err = q.ListUnitIDsWithTelemetry(ctx, db.ListUnitIDsWithTelemetryParams{
			CompanyID: tenant.CompanyID(ctx), FromTs: from, ToTs: to,
		})
		return err
	})
	return ids, err
}

// UnitTrack implements Repo.
func (r *PgRepo) UnitTrack(ctx context.Context, unitID uuid.UUID, from, to time.Time) ([]db.ListUnitTrackRow, error) {
	var rows []db.ListUnitTrackRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListUnitTrack(ctx, db.ListUnitTrackParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID, FromTs: from, ToTs: to,
		})
		return err
	})
	return rows, err
}

// RegionAt implements Repo. `regions` is a global reference table, not tenant
// data, so the lookup carries no company predicate.
func (r *PgRepo) RegionAt(ctx context.Context, lat, lng float64) (db.FindRegionByPointRow, error) {
	var out db.FindRegionByPointRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.FindRegionByPoint(ctx, db.FindRegionByPointParams{Lng: lng, Lat: lat})
		return err
	})
	return out, err
}

// ResetRegionDay implements Repo. The upsert adds to the stored distance, so a
// rerun of the same day has to start from zero to stay idempotent.
func (r *PgRepo) ResetRegionDay(ctx context.Context, unitID uuid.UUID, day time.Time) error {
	return r.write(ctx, func(q *db.Queries, _ pgx.Tx) error {
		return q.DeleteRegionDistanceDay(ctx, db.DeleteRegionDistanceDayParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID, Date: date(day),
		})
	})
}

// AddRegionDistance implements Repo.
func (r *PgRepo) AddRegionDistance(ctx context.Context, unitID uuid.UUID, regionCode string,
	day time.Time, distanceM int64) error {
	return r.write(ctx, func(q *db.Queries, _ pgx.Tx) error {
		return q.UpsertRegionDistanceDaily(ctx, db.UpsertRegionDistanceDailyParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID, RegionCode: regionCode,
			Date: date(day), DistanceM: distanceM,
		})
	})
}

// compile time guard.
var _ Repo = (*PgRepo)(nil)
