package fleet

import (
	"context"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/tenant"
)

// UnitFilter is the resolved GET /units query. Nil pointers mean "no filter".
type UnitFilter struct {
	Search          *string
	Status          *string
	BranchID        *uuid.UUID
	OutOfService    *bool
	IncludeInactive bool
	Sort            string
	Order           string
	Limit           int32
	Offset          int32
}

// DeviceFilter is the resolved GET /eld-devices query.
type DeviceFilter struct {
	Search         *string
	Status         *string
	UnitID         *uuid.UUID
	ConnectionType *string
	Sort           string
	Order          string
	Limit          int32
	Offset         int32
}

// CatalogFilter is the resolved query of the trailer / shipping document lists.
type CatalogFilter struct {
	Search string
	Limit  int32
	Offset int32
}

// HistoryFilter is the resolved GET /units/{id}/history?from&to query.
type HistoryFilter struct {
	UnitID uuid.UUID
	From   *time.Time
	To     *time.Time
	Limit  int32
	Offset int32
}

// AssignDriverInput describes one unit ↔ driver assignment request.
type AssignDriverInput struct {
	UnitID   uuid.UUID
	DriverID uuid.UUID
	Role     string
}

// AssignDeviceInput describes one ELD device ↔ unit wiring request. UnitID is
// nil when the device is being detached.
type AssignDeviceInput struct {
	DeviceID uuid.UUID
	UnitID   *uuid.UUID
}

// Repo is everything the fleet service needs from storage. Mutating methods
// take a callback that builds the audit entries; the repository writes the
// change and its audit trail inside one transaction so they can never diverge.
type Repo interface {
	ListUnits(ctx context.Context, f UnitFilter) ([]db.FleetListUnitsRow, int64, error)
	GetUnit(ctx context.Context, id uuid.UUID) (db.FleetGetUnitRow, error)
	CreateUnit(ctx context.Context, arg db.CreateUnitParams, deviceID *uuid.UUID,
		mk func(db.Unit) []audit.Entry) (db.FleetGetUnitRow, error)
	UpdateUnit(ctx context.Context, arg db.FleetUpdateUnitParams,
		mk func(before, after db.Unit) []audit.Entry) (db.FleetGetUnitRow, error)
	SetUnitStatus(ctx context.Context, id uuid.UUID, status string,
		mk func(before, after db.Unit) []audit.Entry) (db.FleetGetUnitRow, error)
	DeleteUnit(ctx context.Context, id uuid.UUID, mk func(db.Unit) []audit.Entry) error
	AssignDriver(ctx context.Context, in AssignDriverInput,
		mk func(db.UnitDriverAssignment) []audit.Entry) (db.FleetListUnitAssignmentsRow, error)
	UnitDiagnostics(ctx context.Context, id uuid.UUID) (db.FleetGetUnitDiagnosticsRow, error)
	UnitAudit(ctx context.Context, f HistoryFilter) ([]db.FleetListUnitAuditRow, int64, error)
	UnitAssignments(ctx context.Context, f HistoryFilter) ([]db.FleetListUnitAssignmentsRow, int64, error)
	GetDriver(ctx context.Context, id uuid.UUID) (db.FleetGetDriverBriefRow, error)
	GetBranch(ctx context.Context, id uuid.UUID) (db.FleetGetBranchRow, error)

	ListDevices(ctx context.Context, f DeviceFilter) ([]db.FleetListEldDevicesRow, int64, error)
	GetDevice(ctx context.Context, id uuid.UUID) (db.FleetGetEldDeviceRow, error)
	CreateDevice(ctx context.Context, arg db.CreateEldDeviceParams,
		mk func(db.EldDevice) []audit.Entry) (db.FleetGetEldDeviceRow, error)
	UpdateDevice(ctx context.Context, arg db.FleetUpdateEldDeviceParams,
		mk func(before, after db.EldDevice) []audit.Entry) (db.FleetGetEldDeviceRow, error)
	DeleteDevice(ctx context.Context, id uuid.UUID, mk func(db.EldDevice) []audit.Entry) error
	AssignDevice(ctx context.Context, in AssignDeviceInput,
		mk func(before db.EldDevice) []audit.Entry) (db.FleetGetEldDeviceRow, error)
	ActiveDeviceForUnit(ctx context.Context, unitID uuid.UUID) (db.FleetActiveDeviceForUnitRow, error)

	ListTrailers(ctx context.Context, f CatalogFilter) ([]db.Trailer, int64, error)
	GetTrailer(ctx context.Context, id uuid.UUID) (db.Trailer, error)
	CreateTrailer(ctx context.Context, arg db.CreateTrailerParams,
		mk func(db.Trailer) []audit.Entry) (db.Trailer, error)
	UpdateTrailer(ctx context.Context, arg db.FleetUpdateTrailerParams,
		mk func(before, after db.Trailer) []audit.Entry) (db.Trailer, error)
	DeleteTrailer(ctx context.Context, id uuid.UUID, mk func(db.Trailer) []audit.Entry) error

	ListDocs(ctx context.Context, f CatalogFilter) ([]db.ShippingDocument, int64, error)
	GetDoc(ctx context.Context, id uuid.UUID) (db.ShippingDocument, error)
	CreateDoc(ctx context.Context, arg db.CreateShippingDocumentParams,
		mk func(db.ShippingDocument) []audit.Entry) (db.ShippingDocument, error)
	UpdateDoc(ctx context.Context, arg db.FleetUpdateShippingDocumentParams,
		mk func(before, after db.ShippingDocument) []audit.Entry) (db.ShippingDocument, error)
	DeleteDoc(ctx context.Context, id uuid.UUID, mk func(db.ShippingDocument) []audit.Entry) error
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

// ---------------------------------------------------------------------- units

// ListUnits implements Repo.
func (r *PgRepo) ListUnits(ctx context.Context, f UnitFilter) ([]db.FleetListUnitsRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.FleetListUnitsRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.FleetListUnits(ctx, db.FleetListUnitsParams{
			CompanyID:       companyID,
			Search:          f.Search,
			Status:          f.Status,
			BranchID:        pgconv.UUIDPtr(f.BranchID),
			OutOfService:    f.OutOfService,
			IncludeInactive: f.IncludeInactive,
			Sort:            f.Sort,
			SortOrder:       f.Order,
			Limit:           f.Limit,
			Offset:          f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.FleetCountUnits(ctx, db.FleetCountUnitsParams{
			CompanyID:       companyID,
			Search:          f.Search,
			Status:          f.Status,
			BranchID:        pgconv.UUIDPtr(f.BranchID),
			OutOfService:    f.OutOfService,
			IncludeInactive: f.IncludeInactive,
		})
		return err
	})
	return rows, total, err
}

// GetUnit implements Repo.
func (r *PgRepo) GetUnit(ctx context.Context, id uuid.UUID) (db.FleetGetUnitRow, error) {
	var out db.FleetGetUnitRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.FleetGetUnit(ctx, db.FleetGetUnitParams{CompanyID: tenant.CompanyID(ctx), ID: id})
		return err
	})
	return out, err
}

// CreateUnit implements Repo. When deviceID is set the device is wired to the
// new unit in the same transaction.
func (r *PgRepo) CreateUnit(ctx context.Context, arg db.CreateUnitParams, deviceID *uuid.UUID,
	mk func(db.Unit) []audit.Entry) (db.FleetGetUnitRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.FleetGetUnitRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		unit, err := q.CreateUnit(ctx, arg)
		if err != nil {
			return err
		}
		if deviceID != nil {
			if _, err := q.AssignEldDeviceToUnit(ctx, db.AssignEldDeviceToUnitParams{
				CompanyID: companyID, EldDeviceID: *deviceID, UnitID: unit.ID,
			}); err != nil {
				return err
			}
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(unit)...); err != nil {
			return err
		}
		out, err = q.FleetGetUnit(ctx, db.FleetGetUnitParams{CompanyID: companyID, ID: unit.ID})
		return err
	})
	return out, err
}

// UpdateUnit implements Repo.
func (r *PgRepo) UpdateUnit(ctx context.Context, arg db.FleetUpdateUnitParams,
	mk func(before, after db.Unit) []audit.Entry) (db.FleetGetUnitRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.FleetGetUnitRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetUnit(ctx, db.GetUnitParams{CompanyID: companyID, ID: arg.ID})
		if err != nil {
			return err
		}
		after, err := q.FleetUpdateUnit(ctx, arg)
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(before, after)...); err != nil {
			return err
		}
		out, err = q.FleetGetUnit(ctx, db.FleetGetUnitParams{CompanyID: companyID, ID: arg.ID})
		return err
	})
	return out, err
}

// SetUnitStatus implements Repo (activate / deactivate).
func (r *PgRepo) SetUnitStatus(ctx context.Context, id uuid.UUID, status string,
	mk func(before, after db.Unit) []audit.Entry) (db.FleetGetUnitRow, error) {
	companyID := tenant.CompanyID(ctx)

	var out db.FleetGetUnitRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetUnit(ctx, db.GetUnitParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		after, err := q.SetUnitStatus(ctx, db.SetUnitStatusParams{
			CompanyID: companyID, ID: id, Status: status,
		})
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(before, after)...); err != nil {
			return err
		}
		out, err = q.FleetGetUnit(ctx, db.FleetGetUnitParams{CompanyID: companyID, ID: id})
		return err
	})
	return out, err
}

// DeleteUnit implements Repo (soft delete).
func (r *PgRepo) DeleteUnit(ctx context.Context, id uuid.UUID, mk func(db.Unit) []audit.Entry) error {
	companyID := tenant.CompanyID(ctx)
	return r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetUnit(ctx, db.GetUnitParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		if err := q.SoftDeleteUnit(ctx, db.SoftDeleteUnitParams{CompanyID: companyID, ID: id}); err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(before)...)
	})
}

// AssignDriver implements Repo. Q1.1 — one open assignment per (unit, role):
// the previous holder of the role and any other open assignment of the driver
// are closed first, inside the same transaction.
func (r *PgRepo) AssignDriver(ctx context.Context, in AssignDriverInput,
	mk func(db.UnitDriverAssignment) []audit.Entry) (db.FleetListUnitAssignmentsRow, error) {
	companyID := tenant.CompanyID(ctx)

	var out db.FleetListUnitAssignmentsRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		if err := q.FleetCloseUnitRoleAssignment(ctx, db.FleetCloseUnitRoleAssignmentParams{
			CompanyID: companyID, UnitID: in.UnitID, Role: in.Role,
		}); err != nil {
			return err
		}
		if err := q.FleetCloseDriverAssignments(ctx, db.FleetCloseDriverAssignmentsParams{
			CompanyID: companyID, DriverID: in.DriverID,
		}); err != nil {
			return err
		}
		row, err := q.AssignDriverToUnit(ctx, db.AssignDriverToUnitParams{
			CompanyID: companyID, UnitID: in.UnitID, DriverID: in.DriverID, Role: in.Role,
		})
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(row)...); err != nil {
			return err
		}
		rows, err := q.FleetListUnitAssignments(ctx, db.FleetListUnitAssignmentsParams{
			CompanyID: companyID, UnitID: in.UnitID, Limit: 1, Offset: 0,
		})
		if err != nil {
			return err
		}
		if len(rows) > 0 {
			out = rows[0]
		}
		return nil
	})
	return out, err
}

// UnitDiagnostics implements Repo.
func (r *PgRepo) UnitDiagnostics(ctx context.Context, id uuid.UUID) (db.FleetGetUnitDiagnosticsRow, error) {
	var out db.FleetGetUnitDiagnosticsRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.FleetGetUnitDiagnostics(ctx, db.FleetGetUnitDiagnosticsParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// UnitAudit implements Repo.
func (r *PgRepo) UnitAudit(ctx context.Context, f HistoryFilter) ([]db.FleetListUnitAuditRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.FleetListUnitAuditRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.FleetListUnitAudit(ctx, db.FleetListUnitAuditParams{
			CompanyID: companyID, RecordID: f.UnitID,
			FromTs: pgconv.TimePtr(f.From), ToTs: pgconv.TimePtr(f.To),
			Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.FleetCountUnitAudit(ctx, db.FleetCountUnitAuditParams{
			CompanyID: companyID, RecordID: f.UnitID,
			FromTs: pgconv.TimePtr(f.From), ToTs: pgconv.TimePtr(f.To),
		})
		return err
	})
	return rows, total, err
}

// UnitAssignments implements Repo.
func (r *PgRepo) UnitAssignments(ctx context.Context, f HistoryFilter) ([]db.FleetListUnitAssignmentsRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.FleetListUnitAssignmentsRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.FleetListUnitAssignments(ctx, db.FleetListUnitAssignmentsParams{
			CompanyID: companyID, UnitID: f.UnitID,
			FromTs: pgconv.TimePtr(f.From), ToTs: pgconv.TimePtr(f.To),
			Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.FleetCountUnitAssignments(ctx, db.FleetCountUnitAssignmentsParams{
			CompanyID: companyID, UnitID: f.UnitID,
			FromTs: pgconv.TimePtr(f.From), ToTs: pgconv.TimePtr(f.To),
		})
		return err
	})
	return rows, total, err
}

// GetDriver implements Repo.
func (r *PgRepo) GetDriver(ctx context.Context, id uuid.UUID) (db.FleetGetDriverBriefRow, error) {
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

// GetBranch implements Repo.
func (r *PgRepo) GetBranch(ctx context.Context, id uuid.UUID) (db.FleetGetBranchRow, error) {
	var out db.FleetGetBranchRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.FleetGetBranch(ctx, db.FleetGetBranchParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}
