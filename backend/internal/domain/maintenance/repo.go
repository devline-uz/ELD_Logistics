package maintenance

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

// ScheduleFilter is the resolved GET /maintenance-schedules query.
type ScheduleFilter struct {
	Status *string
	Query  *string
	Limit  int32
	Offset int32
}

// UnitFilter is the resolved GET /maintenance/due query.
type UnitFilter struct {
	ScheduleID *uuid.UUID
	UnitID     *uuid.UUID
	Status     *string
	// OpenOnly keeps only `scheduled` and `due` rows; it is what
	// GET /maintenance/due uses.
	OpenOnly bool
	Limit    int32
	Offset   int32
}

// RecordFilter is the resolved GET /maintenance-records query.
type RecordFilter struct {
	UnitID *uuid.UUID
	Status *string
	From   *time.Time
	To     *time.Time
	Limit  int32
	Offset int32
}

// CompleteInput is the Q42.1 completion: the schedule unit moves back to
// `scheduled` with a fresh due point and a history record is written.
type CompleteInput struct {
	ScheduleUnit db.CompleteScheduleUnitParams
	Record       db.CreateMaintenanceRecordParams
}

// Repo is everything the maintenance service needs from storage.
type Repo interface {
	CreateSchedule(
		ctx context.Context, in db.CreateMaintenanceScheduleParams, units []db.AttachUnitToScheduleParams,
	) (db.MaintenanceSchedule, error)
	GetSchedule(ctx context.Context, id uuid.UUID) (db.MaintenanceSchedule, error)
	ListSchedules(ctx context.Context, f ScheduleFilter) ([]db.MaintenanceSchedule, int64, error)
	UpdateSchedule(
		ctx context.Context, in db.UpdateMaintenanceScheduleParams, units *[]db.AttachUnitToScheduleParams,
	) (db.MaintenanceSchedule, error)
	DeleteSchedule(ctx context.Context, id uuid.UUID) error

	Unit(ctx context.Context, id uuid.UUID) (db.GetMaintenanceUnitRow, error)
	Reading(ctx context.Context, unitID uuid.UUID) (db.GetUnitCurrentReadingRow, error)
	ScheduleUnit(ctx context.Context, id uuid.UUID) (db.GetScheduleUnitDetailRow, error)
	ListScheduleUnits(ctx context.Context, f UnitFilter) ([]db.ListScheduleUnitsWithStateRow, int64, error)
	ListForReminder(ctx context.Context, limit int32) ([]db.ListScheduleUnitsForReminderRow, error)
	MarkReminderSent(ctx context.Context, id uuid.UUID) (int64, error)
	MarkDue(ctx context.Context, id uuid.UUID) (int64, error)
	UnitDrivers(ctx context.Context, unitID uuid.UUID) ([]db.ListUnitDriversForNotifyRow, error)

	Complete(ctx context.Context, in CompleteInput) (db.GetScheduleUnitDetailRow, db.MaintenanceRecord, error)
	Cancel(
		ctx context.Context, id uuid.UUID, reason string, rec db.CreateMaintenanceRecordParams,
	) (db.GetScheduleUnitDetailRow, db.MaintenanceRecord, error)
	ListRecords(ctx context.Context, f RecordFilter) ([]db.ListMaintenanceRecordsRow, int64, error)
	CountUnitsOfSchedule(ctx context.Context, scheduleID uuid.UUID) (int64, error)
}

// PgRepo is the pgx/sqlc implementation of Repo.
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

// CreateSchedule implements Repo.
func (r *PgRepo) CreateSchedule(
	ctx context.Context, in db.CreateMaintenanceScheduleParams, units []db.AttachUnitToScheduleParams,
) (db.MaintenanceSchedule, error) {
	var out db.MaintenanceSchedule
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		row, err := q.CreateMaintenanceSchedule(ctx, in)
		if err != nil {
			return err
		}
		out = row
		for _, u := range units {
			u.ScheduleID = row.ID
			if _, err := q.AttachUnitToSchedule(ctx, u); err != nil {
				return err
			}
		}
		return r.audit.RecordTx(ctx, tx, audit.Changes("maintenance_schedules", row.ID, audit.ActionCreate, nil,
			map[string]any{"name": row.Name, "interval_unit": row.IntervalUnit, "units": len(units)})...)
	})
	return out, err
}

// GetSchedule implements Repo.
func (r *PgRepo) GetSchedule(ctx context.Context, id uuid.UUID) (db.MaintenanceSchedule, error) {
	var out db.MaintenanceSchedule
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetMaintenanceSchedule(ctx, db.GetMaintenanceScheduleParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// ListSchedules implements Repo.
func (r *PgRepo) ListSchedules(ctx context.Context, f ScheduleFilter) ([]db.MaintenanceSchedule, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.MaintenanceSchedule
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListMaintenanceSchedules(ctx, db.ListMaintenanceSchedulesParams{
			CompanyID: companyID, Status: f.Status, Q: f.Query, Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountMaintenanceSchedules(ctx, db.CountMaintenanceSchedulesParams{
			CompanyID: companyID, Status: f.Status, Q: f.Query,
		})
		return err
	})
	return rows, total, err
}

// UpdateSchedule implements Repo. A non nil units slice replaces the attached
// fleet inside the same transaction.
func (r *PgRepo) UpdateSchedule(
	ctx context.Context, in db.UpdateMaintenanceScheduleParams, units *[]db.AttachUnitToScheduleParams,
) (db.MaintenanceSchedule, error) {
	var out db.MaintenanceSchedule
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		before, err := q.GetMaintenanceSchedule(ctx, db.GetMaintenanceScheduleParams{
			CompanyID: in.CompanyID, ID: in.ID,
		})
		if err != nil {
			return err
		}
		row, err := q.UpdateMaintenanceSchedule(ctx, in)
		if err != nil {
			return err
		}
		out = row
		if units != nil {
			existing, err := q.ListScheduleUnitsWithState(ctx, db.ListScheduleUnitsWithStateParams{
				CompanyID: in.CompanyID, ScheduleID: pgconv.UUID(row.ID), Limit: 1000, Offset: 0,
			})
			if err != nil {
				return err
			}
			keep := make(map[uuid.UUID]bool, len(*units))
			for _, u := range *units {
				keep[u.UnitID] = true
			}
			have := make(map[uuid.UUID]bool, len(existing))
			for _, e := range existing {
				have[e.UnitID] = true
				if !keep[e.UnitID] {
					if err := q.DetachUnitFromSchedule(ctx, db.DetachUnitFromScheduleParams{
						CompanyID: in.CompanyID, ID: e.ID,
					}); err != nil {
						return err
					}
				}
			}
			for _, u := range *units {
				if have[u.UnitID] {
					continue
				}
				u.ScheduleID = row.ID
				if _, err := q.AttachUnitToSchedule(ctx, u); err != nil {
					return err
				}
			}
		}
		return r.audit.RecordTx(ctx, tx, audit.Changes("maintenance_schedules", row.ID, audit.ActionUpdate,
			map[string]any{"name": before.Name, "status": before.Status},
			map[string]any{"name": row.Name, "status": row.Status})...)
	})
	return out, err
}

// DeleteSchedule implements Repo (soft delete).
func (r *PgRepo) DeleteSchedule(ctx context.Context, id uuid.UUID) error {
	companyID := tenant.CompanyID(ctx)
	return r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		if _, err := q.GetMaintenanceSchedule(ctx, db.GetMaintenanceScheduleParams{
			CompanyID: companyID, ID: id,
		}); err != nil {
			return err
		}
		if err := q.SoftDeleteMaintenanceSchedule(ctx, db.SoftDeleteMaintenanceScheduleParams{
			CompanyID: companyID, ID: id,
		}); err != nil {
			return err
		}
		return r.audit.RecordTx(ctx, tx, audit.Changes("maintenance_schedules", id, audit.ActionDelete,
			nil, map[string]any{"deleted": true})...)
	})
}

// Unit implements Repo.
func (r *PgRepo) Unit(ctx context.Context, id uuid.UUID) (db.GetMaintenanceUnitRow, error) {
	var out db.GetMaintenanceUnitRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetMaintenanceUnit(ctx, db.GetMaintenanceUnitParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// Reading implements Repo.
func (r *PgRepo) Reading(ctx context.Context, unitID uuid.UUID) (db.GetUnitCurrentReadingRow, error) {
	var out db.GetUnitCurrentReadingRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetUnitCurrentReading(ctx, db.GetUnitCurrentReadingParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID,
		})
		return err
	})
	return out, err
}

// ScheduleUnit implements Repo.
func (r *PgRepo) ScheduleUnit(ctx context.Context, id uuid.UUID) (db.GetScheduleUnitDetailRow, error) {
	var out db.GetScheduleUnitDetailRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetScheduleUnitDetail(ctx, db.GetScheduleUnitDetailParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// ListScheduleUnits implements Repo.
func (r *PgRepo) ListScheduleUnits(ctx context.Context, f UnitFilter) ([]db.ListScheduleUnitsWithStateRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ListScheduleUnitsWithStateRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListScheduleUnitsWithState(ctx, db.ListScheduleUnitsWithStateParams{
			CompanyID:  companyID,
			ScheduleID: pgconv.UUIDPtr(f.ScheduleID),
			UnitID:     pgconv.UUIDPtr(f.UnitID),
			Status:     f.Status,
			OpenOnly:   f.OpenOnly,
			Limit:      f.Limit,
			Offset:     f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountScheduleUnitsWithState(ctx, db.CountScheduleUnitsWithStateParams{
			CompanyID:  companyID,
			ScheduleID: pgconv.UUIDPtr(f.ScheduleID),
			UnitID:     pgconv.UUIDPtr(f.UnitID),
			Status:     f.Status,
			OpenOnly:   f.OpenOnly,
		})
		return err
	})
	return rows, total, err
}

// ListForReminder implements Repo.
func (r *PgRepo) ListForReminder(ctx context.Context, limit int32) ([]db.ListScheduleUnitsForReminderRow, error) {
	var rows []db.ListScheduleUnitsForReminderRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListScheduleUnitsForReminder(ctx, db.ListScheduleUnitsForReminderParams{
			CompanyID: tenant.CompanyID(ctx), Limit: limit,
		})
		return err
	})
	return rows, err
}

// MarkReminderSent implements Repo. The affected row count is the "fire once"
// guard: a second worker sees zero.
func (r *PgRepo) MarkReminderSent(ctx context.Context, id uuid.UUID) (int64, error) {
	var n int64
	err := r.write(ctx, func(_ pgx.Tx, q *db.Queries) error {
		var err error
		n, err = q.MarkScheduleUnitReminderSent(ctx, db.MarkScheduleUnitReminderSentParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return n, err
}

// MarkDue implements Repo.
func (r *PgRepo) MarkDue(ctx context.Context, id uuid.UUID) (int64, error) {
	var n int64
	err := r.write(ctx, func(_ pgx.Tx, q *db.Queries) error {
		var err error
		n, err = q.MarkScheduleUnitDue(ctx, db.MarkScheduleUnitDueParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return n, err
}

// UnitDrivers implements Repo.
func (r *PgRepo) UnitDrivers(ctx context.Context, unitID uuid.UUID) ([]db.ListUnitDriversForNotifyRow, error) {
	var rows []db.ListUnitDriversForNotifyRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListUnitDriversForNotify(ctx, db.ListUnitDriversForNotifyParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID,
		})
		return err
	})
	return rows, err
}

// Complete implements Repo.
func (r *PgRepo) Complete(ctx context.Context, in CompleteInput) (db.GetScheduleUnitDetailRow, db.MaintenanceRecord, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.GetScheduleUnitDetailRow
	var rec db.MaintenanceRecord
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		row, err := q.CompleteScheduleUnit(ctx, in.ScheduleUnit)
		if err != nil {
			return err
		}
		rec, err = q.CreateMaintenanceRecord(ctx, in.Record)
		if err != nil {
			return err
		}
		if err := r.audit.RecordTx(ctx, tx, audit.Changes("maintenance_schedule_units", row.ID, audit.ActionUpdate,
			map[string]any{"status": "due"},
			map[string]any{"status": row.Status, "record_id": rec.ID.String()})...); err != nil {
			return err
		}
		out, err = q.GetScheduleUnitDetail(ctx, db.GetScheduleUnitDetailParams{CompanyID: companyID, ID: row.ID})
		return err
	})
	return out, rec, err
}

// Cancel implements Repo.
func (r *PgRepo) Cancel(
	ctx context.Context, id uuid.UUID, reason string, recIn db.CreateMaintenanceRecordParams,
) (db.GetScheduleUnitDetailRow, db.MaintenanceRecord, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.GetScheduleUnitDetailRow
	var rec db.MaintenanceRecord
	err := r.write(ctx, func(tx pgx.Tx, q *db.Queries) error {
		reasonPtr := &reason
		row, err := q.CancelScheduleUnit(ctx, db.CancelScheduleUnitParams{
			CompanyID: companyID, ID: id, CancelledReason: reasonPtr,
		})
		if err != nil {
			return err
		}
		rec, err = q.CreateMaintenanceRecord(ctx, recIn)
		if err != nil {
			return err
		}
		if err := r.audit.RecordTx(ctx, tx, audit.Changes("maintenance_schedule_units", row.ID, audit.ActionUpdate,
			nil, map[string]any{"status": row.Status, "cancelled_reason": reason})...); err != nil {
			return err
		}
		out, err = q.GetScheduleUnitDetail(ctx, db.GetScheduleUnitDetailParams{CompanyID: companyID, ID: row.ID})
		return err
	})
	return out, rec, err
}

// ListRecords implements Repo.
func (r *PgRepo) ListRecords(ctx context.Context, f RecordFilter) ([]db.ListMaintenanceRecordsRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ListMaintenanceRecordsRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListMaintenanceRecords(ctx, db.ListMaintenanceRecordsParams{
			CompanyID: companyID, UnitID: pgconv.UUIDPtr(f.UnitID), Status: f.Status,
			From: pgconv.TimePtr(f.From), To: pgconv.TimePtr(f.To),
			Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountMaintenanceRecords(ctx, db.CountMaintenanceRecordsParams{
			CompanyID: companyID, UnitID: pgconv.UUIDPtr(f.UnitID), Status: f.Status,
			From: pgconv.TimePtr(f.From), To: pgconv.TimePtr(f.To),
		})
		return err
	})
	return rows, total, err
}

// CountUnitsOfSchedule implements Repo.
func (r *PgRepo) CountUnitsOfSchedule(ctx context.Context, scheduleID uuid.UUID) (int64, error) {
	var n int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		n, err = q.CountScheduleUnitsWithState(ctx, db.CountScheduleUnitsWithStateParams{
			CompanyID: tenant.CompanyID(ctx), ScheduleID: pgconv.UUID(scheduleID),
		})
		return err
	})
	return n, err
}
