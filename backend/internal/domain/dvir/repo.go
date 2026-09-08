package dvir

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

// ReportFilter is the resolved GET /dvir-reports query. Nil pointers mean
// "no filter".
type ReportFilter struct {
	UnitID   *uuid.UUID
	DriverID *uuid.UUID
	// BranchID scopes the result to one branch (a branch scoped principal;
	// TZ B§branch scoping). Nil means company-wide.
	BranchID *uuid.UUID
	Status   *string
	Type     *string
	From     *time.Time
	To       *time.Time
	Limit    int32
	Offset   int32
}

// DefectTypeFilter is the resolved GET /defect-types query.
type DefectTypeFilter struct {
	Category   *string
	IsActive   *bool
	IsCritical *bool
	Limit      int32
	Offset     int32
}

// CreateInput is one submitted inspection together with the side effects that
// must be atomic with it: the Q27.2 out of service flag and the audit entry.
type CreateInput struct {
	Report db.CreateDvirReportParams
	// OutOfService is set when at least one reported defect is critical.
	OutOfService bool
}

// RepairInput is the Service Manager transition plus its optional invoice.
type RepairInput struct {
	ID       uuid.UUID
	Params   db.RepairDvirReportParams
	Invoice  *db.CreateMaintenanceRecordParams
	EditedBy uuid.UUID
}

// Repo is everything the DVIR service needs from storage.
type Repo interface {
	Unit(ctx context.Context, id uuid.UUID) (db.GetDvirUnitRow, error)
	Trailers(ctx context.Context, ids []uuid.UUID) ([]db.ListDvirTrailersRow, error)
	DriverByUser(ctx context.Context, userID uuid.UUID) (db.GetDvirDriverByUserRow, error)
	LastState(ctx context.Context, unitID uuid.UUID) (db.UnitLastState, error)
	DefectTypesByIDs(ctx context.Context, ids []uuid.UUID) ([]db.DefectType, error)

	Create(ctx context.Context, in CreateInput) (db.GetDvirReportDetailRow, error)
	Get(ctx context.Context, id uuid.UUID) (db.GetDvirReportDetailRow, error)
	List(ctx context.Context, f ReportFilter) ([]db.ListDvirReportsRow, int64, error)
	PendingCertification(ctx context.Context, unitID *uuid.UUID, limit int32) ([]db.ListDvirPendingCertificationRow, error)
	Repair(ctx context.Context, in RepairInput) (db.GetDvirReportDetailRow, error)
	Certify(ctx context.Context, id, driverID uuid.UUID, signatureKey string) (db.GetDvirReportDetailRow, error)
	Close(ctx context.Context, id uuid.UUID, reason string) (db.DvirReport, error)
	CertificationOverdue(ctx context.Context, graceDays, limit int32) ([]db.ListDvirCertificationOverdueRow, error)
	CountReportsAfter(ctx context.Context, unitID uuid.UUID, after time.Time) (int64, error)
	SetOutOfService(ctx context.Context, unitID uuid.UUID, v bool) error

	ListDefectTypes(ctx context.Context, f DefectTypeFilter) ([]db.DefectType, int64, error)
	GetDefectType(ctx context.Context, id uuid.UUID) (db.DefectType, error)
	CreateDefectType(ctx context.Context, in db.CreateDefectTypeParams) (db.DefectType, error)
	UpdateDefectType(ctx context.Context, in db.UpdateDefectTypeParams) (db.DefectType, error)
}

// PgRepo is the pgx/sqlc implementation of Repo. Every statement runs through
// the tenant aware pool, which sets `SET LOCAL app.company_id` so RLS is the
// second line of defence behind the explicit company_id predicates.
type PgRepo struct {
	pool  *db.Pool
	audit audit.Recorder
}

// NewRepo builds the storage adapter.
func NewRepo(pool *db.Pool, rec audit.Recorder) *PgRepo {
	if rec == nil {
		rec = audit.NopRecorder{}
	}
	return &PgRepo{pool: pool, audit: rec}
}

func (r *PgRepo) read(ctx context.Context, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, tenant.CompanyID(ctx), func(tx pgx.Tx) error { return fn(db.New(tx)) })
}

func (r *PgRepo) write(ctx context.Context, fn func(tx pgx.Tx, q *db.Queries) error) error {
	return r.pool.WithTx(ctx, tenant.CompanyID(ctx), func(tx pgx.Tx) error { return fn(tx, db.New(tx)) })
}

// Unit implements Repo.
func (r *PgRepo) Unit(ctx context.Context, id uuid.UUID) (db.GetDvirUnitRow, error) {
	var out db.GetDvirUnitRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetDvirUnit(ctx, db.GetDvirUnitParams{CompanyID: tenant.CompanyID(ctx), ID: id})
		return err
	})
	return out, err
}

// Trailers implements Repo.
func (r *PgRepo) Trailers(ctx context.Context, ids []uuid.UUID) ([]db.ListDvirTrailersRow, error) {
	var out []db.ListDvirTrailersRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.ListDvirTrailers(ctx, db.ListDvirTrailersParams{CompanyID: tenant.CompanyID(ctx), Ids: ids})
		return err
	})
	return out, err
}

// DriverByUser implements Repo.
func (r *PgRepo) DriverByUser(ctx context.Context, userID uuid.UUID) (db.GetDvirDriverByUserRow, error) {
	var out db.GetDvirDriverByUserRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetDvirDriverByUser(ctx, db.GetDvirDriverByUserParams{
			CompanyID: tenant.CompanyID(ctx), UserID: userID,
		})
		return err
	})
	return out, err
}

// LastState implements Repo.
func (r *PgRepo) LastState(ctx context.Context, unitID uuid.UUID) (db.UnitLastState, error) {
	var out db.UnitLastState
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetUnitLastState(ctx, db.GetUnitLastStateParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID,
		})
		return err
	})
	return out, err
}

// DefectTypesByIDs implements Repo.
func (r *PgRepo) DefectTypesByIDs(ctx context.Context, ids []uuid.UUID) ([]db.DefectType, error) {
	var out []db.DefectType
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.ListDefectTypesByIDs(ctx, db.ListDefectTypesByIDsParams{
			CompanyID: pgconv.UUID(tenant.CompanyID(ctx)), Ids: ids,
		})
		return err
	})
	return out, err
}

// Create implements Repo. Insert, the Q27.2 out of service flag and the audit
// entry share one transaction.
func (r *PgRepo) Create(ctx context.Context, in CreateInput) (db.GetDvirReportDetailRow, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.GetDvirReportDetailRow
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		row, err := q.CreateDvirReport(ctx, in.Report)
		if err != nil {
			return err
		}
		if in.OutOfService {
			if _, err := q.SetUnitOutOfService(ctx, db.SetUnitOutOfServiceParams{
				CompanyID: companyID, ID: row.UnitID, OutOfService: true,
			}); err != nil {
				return err
			}
			if err := r.audit.RecordTx(ctx, tx, audit.Changes("units", row.UnitID, audit.ActionUpdate,
				map[string]any{"out_of_service": false},
				map[string]any{"out_of_service": true})...); err != nil {
				return err
			}
		}
		if err := r.audit.RecordTx(ctx, tx, audit.Changes("dvir_reports", row.ID, audit.ActionCreate, nil,
			map[string]any{"status": row.Status, "type": row.Type, "unit_id": row.UnitID.String()})...); err != nil {
			return err
		}
		out, err = q.GetDvirReportDetail(ctx, db.GetDvirReportDetailParams{CompanyID: companyID, ID: row.ID})
		return err
	})
	return out, err
}

// Get implements Repo.
func (r *PgRepo) Get(ctx context.Context, id uuid.UUID) (db.GetDvirReportDetailRow, error) {
	var out db.GetDvirReportDetailRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetDvirReportDetail(ctx, db.GetDvirReportDetailParams{CompanyID: tenant.CompanyID(ctx), ID: id})
		return err
	})
	return out, err
}

// List implements Repo.
func (r *PgRepo) List(ctx context.Context, f ReportFilter) ([]db.ListDvirReportsRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ListDvirReportsRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListDvirReports(ctx, db.ListDvirReportsParams{
			CompanyID: companyID,
			UnitID:    pgconv.UUIDPtr(f.UnitID),
			DriverID:  pgconv.UUIDPtr(f.DriverID),
			BranchID:  pgconv.UUIDPtr(f.BranchID),
			Status:    f.Status,
			Type:      f.Type,
			From:      pgconv.TimePtr(f.From),
			To:        pgconv.TimePtr(f.To),
			Limit:     f.Limit,
			Offset:    f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountDvirReports(ctx, db.CountDvirReportsParams{
			CompanyID: companyID,
			UnitID:    pgconv.UUIDPtr(f.UnitID),
			DriverID:  pgconv.UUIDPtr(f.DriverID),
			BranchID:  pgconv.UUIDPtr(f.BranchID),
			Status:    f.Status,
			Type:      f.Type,
			From:      pgconv.TimePtr(f.From),
			To:        pgconv.TimePtr(f.To),
		})
		return err
	})
	return rows, total, err
}

// PendingCertification implements Repo.
func (r *PgRepo) PendingCertification(ctx context.Context, unitID *uuid.UUID, limit int32) ([]db.ListDvirPendingCertificationRow, error) {
	var rows []db.ListDvirPendingCertificationRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListDvirPendingCertification(ctx, db.ListDvirPendingCertificationParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: pgconv.UUIDPtr(unitID), Limit: limit,
		})
		return err
	})
	return rows, err
}

// Repair implements Repo.
func (r *PgRepo) Repair(ctx context.Context, in RepairInput) (db.GetDvirReportDetailRow, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.GetDvirReportDetailRow
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		row, err := q.RepairDvirReport(ctx, in.Params)
		if err != nil {
			return err
		}
		if in.Invoice != nil {
			if _, err := q.CreateMaintenanceRecord(ctx, *in.Invoice); err != nil {
				return err
			}
		}
		if err := r.audit.RecordTx(ctx, tx, audit.Changes("dvir_reports", row.ID, audit.ActionUpdate,
			map[string]any{"status": "submitted_defects_found"},
			map[string]any{"status": row.Status})...); err != nil {
			return err
		}
		out, err = q.GetDvirReportDetail(ctx, db.GetDvirReportDetailParams{CompanyID: companyID, ID: row.ID})
		return err
	})
	return out, err
}

// Certify implements Repo.
func (r *PgRepo) Certify(ctx context.Context, id, driverID uuid.UUID, signatureKey string) (db.GetDvirReportDetailRow, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.GetDvirReportDetailRow
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		key := signatureKey
		row, err := q.CertifyDvirReport(ctx, db.CertifyDvirReportParams{
			CompanyID:                 companyID,
			ID:                        id,
			CertifiedByDriverID:       pgconv.UUID(driverID),
			CertificationSignatureKey: &key,
		})
		if err != nil {
			return err
		}
		if err := r.audit.RecordTx(ctx, tx, audit.Changes("dvir_reports", row.ID, audit.ActionCertify,
			map[string]any{"status": "repaired"},
			map[string]any{"status": row.Status, "certified_by_driver_id": driverID.String()})...); err != nil {
			return err
		}
		out, err = q.GetDvirReportDetail(ctx, db.GetDvirReportDetailParams{CompanyID: companyID, ID: row.ID})
		return err
	})
	return out, err
}

// Close implements Repo (Q30.1 fallback, driven by the cron task).
func (r *PgRepo) Close(ctx context.Context, id uuid.UUID, reason string) (db.DvirReport, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.DvirReport
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		reasonPtr := &reason
		row, err := q.CloseDvirNoCertification(ctx, db.CloseDvirNoCertificationParams{
			CompanyID: companyID, ID: id, ClosedReason: reasonPtr,
		})
		if err != nil {
			return err
		}
		out = row
		return r.audit.RecordTx(ctx, tx, audit.Changes("dvir_reports", row.ID, audit.ActionUpdate,
			nil, map[string]any{"status": row.Status, "closed_reason": reason})...)
	})
	return out, err
}

// CertificationOverdue implements Repo.
func (r *PgRepo) CertificationOverdue(ctx context.Context, graceDays, limit int32) ([]db.ListDvirCertificationOverdueRow, error) {
	var rows []db.ListDvirCertificationOverdueRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListDvirCertificationOverdue(ctx, db.ListDvirCertificationOverdueParams{
			CompanyID: tenant.CompanyID(ctx), GraceDays: graceDays, Limit: limit,
		})
		return err
	})
	return rows, err
}

// CountReportsAfter implements Repo.
func (r *PgRepo) CountReportsAfter(ctx context.Context, unitID uuid.UUID, after time.Time) (int64, error) {
	var n int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		n, err = q.CountDvirForUnitAfter(ctx, db.CountDvirForUnitAfterParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID, After: after,
		})
		return err
	})
	return n, err
}

// SetOutOfService implements Repo.
func (r *PgRepo) SetOutOfService(ctx context.Context, unitID uuid.UUID, v bool) error {
	companyID := tenant.CompanyID(ctx)
	return r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		if _, err := q.SetUnitOutOfService(ctx, db.SetUnitOutOfServiceParams{
			CompanyID: companyID, ID: unitID, OutOfService: v,
		}); err != nil {
			return err
		}
		return r.audit.RecordTx(ctx, tx, audit.Changes("units", unitID, audit.ActionUpdate,
			map[string]any{"out_of_service": !v}, map[string]any{"out_of_service": v})...)
	})
}

// ListDefectTypes implements Repo.
func (r *PgRepo) ListDefectTypes(ctx context.Context, f DefectTypeFilter) ([]db.DefectType, int64, error) {
	companyID := pgconv.UUID(tenant.CompanyID(ctx))
	var rows []db.DefectType
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListDefectTypes(ctx, db.ListDefectTypesParams{
			CompanyID: companyID, Category: f.Category, IsActive: f.IsActive,
			IsCritical: f.IsCritical, Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountDefectTypes(ctx, db.CountDefectTypesParams{
			CompanyID: companyID, Category: f.Category, IsActive: f.IsActive, IsCritical: f.IsCritical,
		})
		return err
	})
	return rows, total, err
}

// GetDefectType implements Repo.
func (r *PgRepo) GetDefectType(ctx context.Context, id uuid.UUID) (db.DefectType, error) {
	var out db.DefectType
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetDefectType(ctx, db.GetDefectTypeParams{
			ID: id, CompanyID: pgconv.UUID(tenant.CompanyID(ctx)),
		})
		return err
	})
	return out, err
}

// CreateDefectType implements Repo.
func (r *PgRepo) CreateDefectType(ctx context.Context, in db.CreateDefectTypeParams) (db.DefectType, error) {
	var out db.DefectType
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		row, err := q.CreateDefectType(ctx, in)
		if err != nil {
			return err
		}
		out = row
		return r.audit.RecordTx(ctx, tx, audit.Changes("defect_types", row.ID, audit.ActionCreate, nil,
			map[string]any{"name": row.Name, "category": row.Category, "is_critical": row.IsCritical})...)
	})
	return out, err
}

// UpdateDefectType implements Repo.
func (r *PgRepo) UpdateDefectType(ctx context.Context, in db.UpdateDefectTypeParams) (db.DefectType, error) {
	var out db.DefectType
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		before, err := q.GetDefectType(ctx, db.GetDefectTypeParams{ID: in.ID, CompanyID: in.CompanyID})
		if err != nil {
			return err
		}
		row, err := q.UpdateDefectType(ctx, in)
		if err != nil {
			return err
		}
		out = row
		return r.audit.RecordTx(ctx, tx, audit.Changes("defect_types", row.ID, audit.ActionUpdate,
			map[string]any{"name": before.Name, "is_critical": before.IsCritical, "is_active": before.IsActive},
			map[string]any{"name": row.Name, "is_critical": row.IsCritical, "is_active": row.IsActive})...)
	})
	return out, err
}
