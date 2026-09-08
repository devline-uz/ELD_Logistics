package maintenance

import (
	"context"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/maintenance/dto"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
)

// reminderBatchLimit bounds one reminder sweep.
const reminderBatchLimit = 500

// defaultCurrency is used when the completion payload omits one.
const defaultCurrency = "USD"

// Service holds the maintenance business rules (TZ §8).
type Service struct {
	repo    Repo
	alerter Alerter
	log     *slog.Logger
	now     func() time.Time
}

// NewService builds the service. A nil alerter degrades to NopAlerter so the
// module runs before the notification module is wired.
func NewService(repo Repo, alerter Alerter, log *slog.Logger, now func() time.Time) *Service {
	if alerter == nil {
		alerter = NopAlerter{}
	}
	if log == nil {
		log = slog.Default()
	}
	if now == nil {
		now = time.Now
	}
	return &Service{repo: repo, alerter: alerter, log: log, now: now}
}

// ---------------------------------------------------------------- schedules

// CreateSchedule stores a plan together with its fleet (Q39/Q40).
func (s *Service) CreateSchedule(ctx context.Context, in dto.ScheduleCreate) (*dto.Schedule, error) {
	units, err := s.resolveUnits(ctx, in.Units, in.IntervalUnit, in.IntervalValue)
	if err != nil {
		return nil, err
	}
	params := db.CreateMaintenanceScheduleParams{
		CompanyID:           tenant.CompanyID(ctx),
		Name:                in.Name,
		Type:                strPtr(in.Type),
		IntervalValue:       floatToNumeric(in.IntervalValue),
		IntervalUnit:        in.IntervalUnit,
		ReminderBeforeValue: floatToNumeric(in.ReminderBeforeValue),
		AlertType:           orDefault(in.AlertType, dto.AlertNotification),
		DeliveryMethods:     orEmpty(in.DeliveryMethods),
		NotifyCoDriver:      in.NotifyCoDriver,
		Notes:               strPtr(in.Notes),
		Status:              orDefault(in.Status, dto.ScheduleActive),
	}
	row, err := s.repo.CreateSchedule(ctx, params, units)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule")
	}
	out := scheduleFrom(row, int64(len(units)))
	return &out, nil
}

// GetSchedule returns one plan; a cross-tenant id answers 404.
func (s *Service) GetSchedule(ctx context.Context, id uuid.UUID) (*dto.Schedule, error) {
	row, err := s.repo.GetSchedule(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule")
	}
	n, err := s.repo.CountUnitsOfSchedule(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule")
	}
	out := scheduleFrom(row, n)
	return &out, nil
}

// ListSchedules returns a page of plans.
func (s *Service) ListSchedules(ctx context.Context, f ScheduleFilter) ([]dto.Schedule, int64, error) {
	rows, total, err := s.repo.ListSchedules(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "maintenance schedule")
	}
	out := make([]dto.Schedule, 0, len(rows))
	for _, r := range rows {
		n, err := s.repo.CountUnitsOfSchedule(ctx, r.ID)
		if err != nil {
			return nil, 0, db.MapError(err, "maintenance schedule")
		}
		out = append(out, scheduleFrom(r, n))
	}
	return out, total, nil
}

// UpdateSchedule patches a plan and, when `units` is present, replaces the
// attached fleet.
func (s *Service) UpdateSchedule(ctx context.Context, id uuid.UUID, in dto.ScheduleUpdate) (*dto.Schedule, error) {
	current, err := s.repo.GetSchedule(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule")
	}
	params := db.UpdateMaintenanceScheduleParams{
		CompanyID:      tenant.CompanyID(ctx),
		ID:             id,
		Name:           in.Name,
		Type:           in.Type,
		IntervalUnit:   in.IntervalUnit,
		AlertType:      in.AlertType,
		NotifyCoDriver: in.NotifyCoDriver,
		Notes:          in.Notes,
		Status:         in.Status,
	}
	if in.IntervalValue != nil {
		params.IntervalValue = floatToNumeric(*in.IntervalValue)
	}
	if in.ReminderBeforeValue != nil {
		params.ReminderBeforeValue = floatToNumeric(*in.ReminderBeforeValue)
	}
	if in.DeliveryMethods != nil {
		params.DeliveryMethods = orEmpty(*in.DeliveryMethods)
	}

	var units *[]db.AttachUnitToScheduleParams
	if in.Units != nil {
		intervalUnit := current.IntervalUnit
		if in.IntervalUnit != nil {
			intervalUnit = *in.IntervalUnit
		}
		intervalValue := valueOrZero(numericToFloat(current.IntervalValue))
		if in.IntervalValue != nil {
			intervalValue = *in.IntervalValue
		}
		resolved, err := s.resolveUnits(ctx, *in.Units, intervalUnit, intervalValue)
		if err != nil {
			return nil, err
		}
		units = &resolved
	}

	row, err := s.repo.UpdateSchedule(ctx, params, units)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule")
	}
	n, err := s.repo.CountUnitsOfSchedule(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule")
	}
	out := scheduleFrom(row, n)
	return &out, nil
}

// DeleteSchedule soft deletes a plan.
func (s *Service) DeleteSchedule(ctx context.Context, id uuid.UUID) error {
	if err := s.repo.DeleteSchedule(ctx, id); err != nil {
		return db.MapError(err, "maintenance schedule")
	}
	return nil
}

// ---------------------------------------------------------------- due list

// Due returns the per unit progress rows (Q33/Q34). Rows whose remaining value
// fell below zero carry `overdue=true`.
func (s *Service) Due(ctx context.Context, f UnitFilter) ([]dto.ScheduleUnit, int64, error) {
	rows, total, err := s.repo.ListScheduleUnits(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "maintenance schedule")
	}
	now := s.now().UTC()
	out := make([]dto.ScheduleUnit, 0, len(rows))
	for _, r := range rows {
		out = append(out, scheduleUnitFrom(rowFromList(r), now))
	}
	return out, total, nil
}

// ScheduleUnit returns one progress row.
func (s *Service) ScheduleUnit(ctx context.Context, id uuid.UUID) (*dto.ScheduleUnit, error) {
	row, err := s.repo.ScheduleUnit(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule unit")
	}
	out := scheduleUnitFrom(rowFromDetail(row), s.now().UTC())
	return &out, nil
}

// Complete records a finished service (Q41–Q43). Q42.1: `last_service_value`
// becomes the reading captured now and the row returns to `scheduled` with a
// fresh `next_due_value`.
func (s *Service) Complete(ctx context.Context, id uuid.UUID, in dto.CompleteInput) (*dto.ScheduleUnit, error) {
	row, err := s.repo.ScheduleUnit(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule unit")
	}
	if row.Status != dto.StatusScheduled && row.Status != dto.StatusDue {
		return nil, apierr.New(apierr.CodeMaintenanceInvalidState, http.StatusConflict,
			"only a scheduled or due maintenance entry can be completed")
	}

	now := s.now().UTC()
	performedAt := now
	if in.PerformedAt != nil {
		performedAt = in.PerformedAt.UTC()
	}
	if performedAt.After(now.Add(time.Minute)) {
		return nil, apierr.New(apierr.CodeTimeInFuture, http.StatusUnprocessableEntity,
			"performed_at cannot be in the future")
	}

	if key := strings.TrimSpace(in.InvoiceKey); key != "" &&
		!storage.OwnsKey(tenant.CompanyID(ctx), key) {
		// A foreign object key would be stored and honoured by a later
		// presigned download (TZ B§3.4).
		return nil, apierr.Validation("invoice_key does not belong to this company",
			apierr.FieldError{Field: "invoice_key", Message: "unknown object key"})
	}

	r := rowFromDetail(row)
	current := currentValue(r, now)
	interval := valueOrZero(numericToFloat(row.IntervalValue))

	params := db.CompleteScheduleUnitParams{CompanyID: tenant.CompanyID(ctx), ID: id}
	switch row.IntervalUnit {
	case dto.UnitDays:
		params.LastServiceAt = pgtype.Timestamptz{Time: performedAt, Valid: true}
		params.NextDueAt = pgtype.Timestamptz{
			Time: performedAt.AddDate(0, 0, int(interval)), Valid: true,
		}
	default:
		if current == nil {
			return nil, apierr.New(apierr.CodeMaintenanceNoReading, http.StatusUnprocessableEntity,
				"no telemetry reading for this unit yet; the odometer or engine hours are required to close a "+
					row.IntervalUnit+" schedule")
		}
		params.LastServiceValue = floatToNumeric(*current)
		params.NextDueValue = floatToNumeric(*current + interval)
		params.LastServiceAt = pgtype.Timestamptz{Time: performedAt, Valid: true}
	}

	rec := db.CreateMaintenanceRecordParams{
		CompanyID:      tenant.CompanyID(ctx),
		ScheduleUnitID: pgtype.UUID{Bytes: id, Valid: true},
		UnitID:         row.UnitID,
		Status:         "completed",
		PerformedAt:    performedAt,
		InvoiceNo:      strPtr(in.InvoiceNo),
		Vendor:         strPtr(in.Vendor),
		Currency:       orDefault(in.Currency, defaultCurrency),
		OdometerM:      row.OdometerM,
		EngineHours:    row.CurrentEngineHours,
		InvoiceKey:     strPtr(in.InvoiceKey),
		Notes:          strPtr(in.Notes),
	}
	if in.Cost != nil {
		rec.Cost = floatToNumeric(*in.Cost)
	}

	updated, _, err := s.repo.Complete(ctx, CompleteInput{ScheduleUnit: params, Record: rec})
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule unit")
	}
	out := scheduleUnitFrom(rowFromDetail(updated), now)
	return &out, nil
}

// Cancel closes a schedule unit without financial fields (Q43).
func (s *Service) Cancel(ctx context.Context, id uuid.UUID, in dto.CancelInput) (*dto.ScheduleUnit, error) {
	row, err := s.repo.ScheduleUnit(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule unit")
	}
	if row.Status != dto.StatusScheduled && row.Status != dto.StatusDue {
		return nil, apierr.New(apierr.CodeMaintenanceInvalidState, http.StatusConflict,
			"only a scheduled or due maintenance entry can be cancelled")
	}
	now := s.now().UTC()
	rec := db.CreateMaintenanceRecordParams{
		CompanyID:       tenant.CompanyID(ctx),
		ScheduleUnitID:  pgtype.UUID{Bytes: id, Valid: true},
		UnitID:          row.UnitID,
		Status:          "cancelled",
		PerformedAt:     now,
		Currency:        defaultCurrency,
		OdometerM:       row.OdometerM,
		EngineHours:     row.CurrentEngineHours,
		CancelledReason: strPtr(in.Reason),
	}
	updated, _, err := s.repo.Cancel(ctx, id, in.Reason, rec)
	if err != nil {
		return nil, db.MapError(err, "maintenance schedule unit")
	}
	out := scheduleUnitFrom(rowFromDetail(updated), now)
	return &out, nil
}

// Records returns a page of the completion / cancellation history (Q32).
func (s *Service) Records(ctx context.Context, f RecordFilter) ([]dto.Record, int64, error) {
	rows, total, err := s.repo.ListRecords(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "maintenance record")
	}
	out := make([]dto.Record, 0, len(rows))
	for _, r := range rows {
		out = append(out, recordFromList(r))
	}
	return out, total, nil
}
