package maintenance

import (
	"math"
	"math/big"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/maintenance/dto"
)

// metresPerMile is the exact statute mile used by the km/mi conversion.
const metresPerMile = 1609.344

// unitRow is the shape shared by the list, detail and reminder rows.
type unitRow struct {
	db.MaintenanceScheduleUnit
	UnitNumber          string
	UnitStatus          string
	ScheduleName        string
	ScheduleType        *string
	IntervalValue       pgtype.Numeric
	IntervalUnit        string
	ReminderBeforeValue pgtype.Numeric
	AlertType           string
	DeliveryMethods     []string
	NotifyCoDriver      bool
	OdometerM           *int64
	CurrentEngineHours  pgtype.Numeric
}

func rowFromDetail(r db.GetScheduleUnitDetailRow) unitRow {
	return unitRow{
		MaintenanceScheduleUnit: db.MaintenanceScheduleUnit{
			ID: r.ID, CompanyID: r.CompanyID, ScheduleID: r.ScheduleID, UnitID: r.UnitID,
			LastServiceValue: r.LastServiceValue, NextDueValue: r.NextDueValue,
			NextDueAt: r.NextDueAt, ReminderSentAt: r.ReminderSentAt, Status: r.Status,
			CreatedAt: r.CreatedAt, UpdatedAt: r.UpdatedAt, DeletedAt: r.DeletedAt,
			LastServiceAt: r.LastServiceAt, CancelledReason: r.CancelledReason,
		},
		UnitNumber: r.UnitNumber, UnitStatus: r.UnitStatus,
		ScheduleName: r.ScheduleName, ScheduleType: r.ScheduleType,
		IntervalValue: r.IntervalValue, IntervalUnit: r.IntervalUnit,
		ReminderBeforeValue: r.ReminderBeforeValue, AlertType: r.AlertType,
		DeliveryMethods: r.DeliveryMethods, NotifyCoDriver: r.NotifyCoDriver,
		OdometerM: r.OdometerM, CurrentEngineHours: r.CurrentEngineHours,
	}
}

func rowFromList(r db.ListScheduleUnitsWithStateRow) unitRow {
	return rowFromDetail(db.GetScheduleUnitDetailRow(r))
}

func rowFromReminder(r db.ListScheduleUnitsForReminderRow) unitRow {
	return rowFromDetail(db.GetScheduleUnitDetailRow(r))
}

// currentValue resolves the live reading in the schedule's own unit (Q33).
// Distance intervals read the telemetry odometer, engine hour intervals the
// telemetry engine hours, and a day interval counts elapsed calendar days.
func currentValue(r unitRow, now time.Time) *float64 {
	switch r.IntervalUnit {
	case dto.UnitKm:
		if r.OdometerM == nil {
			return nil
		}
		v := float64(*r.OdometerM) / 1000
		return &v
	case dto.UnitMi:
		if r.OdometerM == nil {
			return nil
		}
		v := float64(*r.OdometerM) / metresPerMile
		return &v
	case dto.UnitEngineHours:
		return numericToFloat(r.CurrentEngineHours)
	case dto.UnitDays:
		if !r.LastServiceAt.Valid {
			return nil
		}
		v := now.Sub(r.LastServiceAt.Time).Hours() / 24
		return &v
	}
	return nil
}

// scheduleUnitFrom builds the wire row, computing next_due_value, remaining and
// the overdue / reminder flags (Q33, Q34, Q37).
func scheduleUnitFrom(r unitRow, now time.Time) dto.ScheduleUnit {
	interval := valueOrZero(numericToFloat(r.IntervalValue))
	reminderBefore := valueOrZero(numericToFloat(r.ReminderBeforeValue))
	last := numericToFloat(r.LastServiceValue)
	current := currentValue(r, now)

	next := numericToFloat(r.NextDueValue)
	if next == nil && last != nil {
		v := *last + interval
		next = &v
	}
	if r.IntervalUnit == dto.UnitDays && next == nil {
		v := interval
		next = &v
	}

	var remaining *float64
	if next != nil && current != nil {
		v := *next - *current
		remaining = &v
	} else if r.IntervalUnit == dto.UnitDays && r.NextDueAt.Valid {
		v := r.NextDueAt.Time.Sub(now).Hours() / 24
		remaining = &v
	}

	out := dto.ScheduleUnit{
		ID:               r.ID.String(),
		ScheduleID:       r.ScheduleID.String(),
		ScheduleName:     r.ScheduleName,
		ScheduleType:     derefStr(r.ScheduleType),
		UnitID:           r.UnitID.String(),
		UnitNumber:       r.UnitNumber,
		IntervalValue:    interval,
		IntervalUnit:     r.IntervalUnit,
		LastServiceValue: last,
		CurrentValue:     current,
		NextDueValue:     next,
		Remaining:        remaining,
		NextDueAt:        pgTime(r.NextDueAt),
		LastServiceAt:    pgTime(r.LastServiceAt),
		ReminderSentAt:   pgTime(r.ReminderSentAt),
		Status:           r.Status,
		CancelledReason:  derefStr(r.CancelledReason),
		OdometerM:        r.OdometerM,
		EngineHours:      numericToFloat(r.CurrentEngineHours),
		CreatedAt:        r.CreatedAt.UTC(),
		UpdatedAt:        r.UpdatedAt.UTC(),
	}
	if remaining != nil {
		out.Overdue = *remaining < 0
		out.ReminderDue = *remaining <= reminderBefore
	}
	return out
}

func scheduleFrom(r db.MaintenanceSchedule, unitCount int64) dto.Schedule {
	methods := r.DeliveryMethods
	if methods == nil {
		methods = []string{}
	}
	return dto.Schedule{
		ID:                  r.ID.String(),
		Name:                r.Name,
		Type:                derefStr(r.Type),
		IntervalValue:       valueOrZero(numericToFloat(r.IntervalValue)),
		IntervalUnit:        r.IntervalUnit,
		ReminderBeforeValue: valueOrZero(numericToFloat(r.ReminderBeforeValue)),
		AlertType:           r.AlertType,
		DeliveryMethods:     methods,
		NotifyCoDriver:      r.NotifyCoDriver,
		Notes:               derefStr(r.Notes),
		Status:              r.Status,
		UnitCount:           unitCount,
		CreatedAt:           r.CreatedAt.UTC(),
		UpdatedAt:           r.UpdatedAt.UTC(),
	}
}

func recordFrom(r db.MaintenanceRecord, unitNumber string) dto.Record {
	out := dto.Record{
		ID:              r.ID.String(),
		UnitID:          r.UnitID.String(),
		UnitNumber:      unitNumber,
		Status:          r.Status,
		PerformedAt:     r.PerformedAt.UTC(),
		InvoiceNo:       derefStr(r.InvoiceNo),
		Vendor:          derefStr(r.Vendor),
		Cost:            numericToFloat(r.Cost),
		Currency:        r.Currency,
		OdometerM:       r.OdometerM,
		EngineHours:     numericToFloat(r.EngineHours),
		InvoiceKey:      derefStr(r.InvoiceKey),
		CancelledReason: derefStr(r.CancelledReason),
		Notes:           derefStr(r.Notes),
		CreatedAt:       r.CreatedAt.UTC(),
	}
	if r.ScheduleUnitID.Valid {
		s := uuidString(r.ScheduleUnitID)
		out.ScheduleUnitID = &s
	}
	return out
}

func recordFromList(r db.ListMaintenanceRecordsRow) dto.Record {
	return recordFrom(db.MaintenanceRecord{
		ID: r.ID, CompanyID: r.CompanyID, ScheduleUnitID: r.ScheduleUnitID, UnitID: r.UnitID,
		Status: r.Status, PerformedAt: r.PerformedAt, InvoiceNo: r.InvoiceNo, Vendor: r.Vendor,
		Cost: r.Cost, Currency: r.Currency, OdometerM: r.OdometerM, EngineHours: r.EngineHours,
		InvoiceKey: r.InvoiceKey, DvirPreID: r.DvirPreID, DvirPostID: r.DvirPostID,
		CancelledReason: r.CancelledReason, Notes: r.Notes,
		CreatedAt: r.CreatedAt, UpdatedAt: r.UpdatedAt,
	}, r.UnitNumber)
}

// ---------------------------------------------------------------- primitives

func derefStr(v *string) string {
	if v == nil {
		return ""
	}
	return *v
}

func valueOrZero(v *float64) float64 {
	if v == nil {
		return 0
	}
	return *v
}

func pgTime(v pgtype.Timestamptz) *time.Time {
	if !v.Valid {
		return nil
	}
	t := v.Time.UTC()
	return &t
}

func uuidString(v pgtype.UUID) string {
	return uuid.UUID(v.Bytes).String()
}

// numericToFloat converts a Postgres numeric into a float pointer.
func numericToFloat(v pgtype.Numeric) *float64 {
	if !v.Valid || v.NaN || v.Int == nil {
		return nil
	}
	f, err := v.Float64Value()
	if err != nil || !f.Valid {
		return nil
	}
	out := f.Float64
	return &out
}

// floatToNumeric converts a float into a Postgres numeric with two decimals,
// matching the numeric(14,2) columns of the maintenance tables.
func floatToNumeric(v float64) pgtype.Numeric {
	scaled := math.Round(v * 100)
	return pgtype.Numeric{Int: big.NewInt(int64(scaled)), Exp: -2, Valid: true}
}
