// Package dto holds the maintenance module payloads: schedules, the per unit
// due list and the completion / cancellation history.
//
// TZ §8 Q33 vocabulary: `last_service_value` is the reading at the last
// service (the design calls it "Current Frequency"), `interval_value` is the
// maintenance frequency, `next_due_value = last_service_value + interval_value`
// and `remaining = next_due_value - current_value`. `current_value` comes from
// telemetry (odometer or engine hours) or from the calendar for day intervals.
// Distances on the wire are kilometres or miles as chosen by `interval_unit`;
// the raw odometer stays metres.
package dto

import (
	"time"

	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared envelopes re-exported so swagger annotations can reference dto.X.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
)

// Interval units (Q35).
const (
	UnitKm          = "km"
	UnitMi          = "mi"
	UnitDays        = "days"
	UnitEngineHours = "engine_hours"
)

// Schedule unit statuses (Q32 — the row changes state, it never moves).
const (
	StatusScheduled = "scheduled"
	StatusDue       = "due"
	StatusCompleted = "completed"
	StatusCancelled = "cancelled"
)

// Schedule statuses.
const (
	ScheduleActive   = "active"
	ScheduleInactive = "inactive"
)

// Alert types offered by a schedule.
const (
	AlertNotification = "notification"
	AlertEmail        = "email"
	AlertSMS          = "sms"
	AlertNone         = "none"
)

// ---------------------------------------------------------------- requests

// ScheduleUnitInput attaches one unit to a schedule with its own starting
// reading (Q39/Q40 — every unit keeps its own progress).
type ScheduleUnitInput struct {
	UnitID string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f" validate:"required,uuid4"`
	// LastServiceValue is the odometer / engine hour reading of the last
	// service in `interval_unit`. Omitted means "read it from telemetry now".
	LastServiceValue *float64 `json:"last_service_value" example:"128430" validate:"omitempty,gte=0"`
}

// ScheduleCreate is the POST /maintenance-schedules payload.
type ScheduleCreate struct {
	Name string `json:"name" example:"Engine oil change" validate:"required,max=160"`
	// Type is the free form service category shown in the UI.
	Type          string  `json:"type" example:"oil_change" validate:"max=64"`
	IntervalValue float64 `json:"interval_value" example:"25000" validate:"required,gt=0"`
	IntervalUnit  string  `json:"interval_unit" example:"km" enums:"km,mi,days,engine_hours" validate:"required,oneof=km mi days engine_hours"`
	// ReminderBeforeValue fires the Q37 reminder this far ahead of the due
	// point, in the same unit as the interval.
	ReminderBeforeValue float64 `json:"reminder_before_value" example:"1000" validate:"gte=0"`
	AlertType           string  `json:"alert_type" example:"notification" enums:"notification,email,sms,none" validate:"omitempty,oneof=notification email sms none"`
	// DeliveryMethods are the channels the reminder is fanned out to.
	DeliveryMethods []string `json:"delivery_methods" example:"push,email" validate:"max=8,dive,oneof=push email sms telegram"`
	// NotifyCoDriver also reminds the co-driver of the unit (Q38).
	NotifyCoDriver bool   `json:"notify_co_driver" example:"true"`
	Notes          string `json:"notes" example:"Use synthetic oil only" validate:"max=2000"`
	Status         string `json:"status" example:"active" enums:"active,inactive" validate:"omitempty,oneof=active inactive"`
	// Units attaches the fleet covered by this schedule.
	Units []ScheduleUnitInput `json:"units" validate:"max=500,dive"`
}

// ScheduleUpdate is the PATCH /maintenance-schedules/{id} payload; nil fields
// are left untouched.
type ScheduleUpdate struct {
	Name                *string   `json:"name" example:"Engine oil change" validate:"omitempty,max=160"`
	Type                *string   `json:"type" example:"oil_change" validate:"omitempty,max=64"`
	IntervalValue       *float64  `json:"interval_value" example:"25000" validate:"omitempty,gt=0"`
	IntervalUnit        *string   `json:"interval_unit" example:"km" enums:"km,mi,days,engine_hours" validate:"omitempty,oneof=km mi days engine_hours"`
	ReminderBeforeValue *float64  `json:"reminder_before_value" example:"1000" validate:"omitempty,gte=0"`
	AlertType           *string   `json:"alert_type" example:"email" enums:"notification,email,sms,none" validate:"omitempty,oneof=notification email sms none"`
	DeliveryMethods     *[]string `json:"delivery_methods" example:"push,email" validate:"omitempty,max=8,dive,oneof=push email sms telegram"`
	NotifyCoDriver      *bool     `json:"notify_co_driver" example:"false"`
	Notes               *string   `json:"notes" example:"Use synthetic oil only" validate:"omitempty,max=2000"`
	Status              *string   `json:"status" example:"inactive" enums:"active,inactive" validate:"omitempty,oneof=active inactive"`
	// Units replaces the attached fleet when present; omit to keep it as is.
	Units *[]ScheduleUnitInput `json:"units" validate:"omitempty,max=500,dive"`
}

// CompleteInput is the POST /maintenance-schedule-units/{id}/complete payload
// (Q41–Q43). Q42.1: `last_service_value` becomes the reading captured now, so
// the caller never sends it.
type CompleteInput struct {
	InvoiceNo string   `json:"invoice_no" example:"INV-10233" validate:"max=64"`
	Vendor    string   `json:"vendor" example:"Dallas Truck Service" validate:"max=200"`
	Cost      *float64 `json:"cost" example:"420.5" validate:"omitempty,gte=0"`
	Currency  string   `json:"currency" example:"USD" validate:"omitempty,len=3,alpha"`
	// PerformedAt defaults to now when omitted.
	PerformedAt *time.Time `json:"performed_at" format:"date-time" example:"2026-09-06T15:04:05Z"`
	// InvoiceKey is the storage key of the invoice PDF/JPG (kind `invoice`).
	InvoiceKey string `json:"invoice_key" example:"c1/invoice/2026/09/06/inv.pdf" validate:"max=512"`
	Notes      string `json:"notes" example:"Oil and filter replaced" validate:"max=2000"`
}

// CancelInput is the POST /maintenance-schedule-units/{id}/cancel payload.
// Q43: a cancellation carries no financial fields.
type CancelInput struct {
	Reason string `json:"cancelled_reason" example:"Unit sold" validate:"required,max=500"`
}

// ---------------------------------------------------------------- responses

// Schedule is one maintenance plan.
type Schedule struct {
	ID                  string   `json:"id" example:"2f3e4d5c-6b7a-4980-9a1b-2c3d4e5f6a7b"`
	Name                string   `json:"name" example:"Engine oil change"`
	Type                string   `json:"type" example:"oil_change"`
	IntervalValue       float64  `json:"interval_value" example:"25000"`
	IntervalUnit        string   `json:"interval_unit" example:"km" enums:"km,mi,days,engine_hours"`
	ReminderBeforeValue float64  `json:"reminder_before_value" example:"1000"`
	AlertType           string   `json:"alert_type" example:"notification" enums:"notification,email,sms,none"`
	DeliveryMethods     []string `json:"delivery_methods" example:"push,email"`
	NotifyCoDriver      bool     `json:"notify_co_driver" example:"true"`
	Notes               string   `json:"notes" example:"Use synthetic oil only"`
	Status              string   `json:"status" example:"active" enums:"active,inactive"`
	// UnitCount is the number of units currently attached.
	UnitCount int64     `json:"unit_count" example:"12"`
	CreatedAt time.Time `json:"created_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	UpdatedAt time.Time `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// ScheduleUnit is one unit's progress against one schedule (Q33/Q34).
type ScheduleUnit struct {
	ID           string `json:"id" example:"8c7b6a59-4d3e-4f2a-9b8c-7d6e5f4a3b2c"`
	ScheduleID   string `json:"schedule_id" example:"2f3e4d5c-6b7a-4980-9a1b-2c3d4e5f6a7b"`
	ScheduleName string `json:"schedule_name" example:"Engine oil change"`
	ScheduleType string `json:"schedule_type" example:"oil_change"`
	UnitID       string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber   string `json:"unit_number" example:"1021"`

	IntervalValue float64 `json:"interval_value" example:"25000"`
	IntervalUnit  string  `json:"interval_unit" example:"km" enums:"km,mi,days,engine_hours"`
	// LastServiceValue is the reading at the last completed service.
	LastServiceValue *float64 `json:"last_service_value" example:"103430"`
	// CurrentValue is the live reading: telemetry for km/mi/engine hours,
	// elapsed days for a day interval. Null when the unit never reported.
	CurrentValue *float64 `json:"current_value" example:"127100"`
	// NextDueValue is last_service_value + interval_value.
	NextDueValue *float64 `json:"next_due_value" example:"128430"`
	// Remaining is next_due_value - current_value; negative means overdue.
	Remaining *float64 `json:"remaining" example:"1330"`
	// Overdue is Remaining < 0 (Q34 — shown red in the UI).
	Overdue bool `json:"overdue" example:"false"`
	// ReminderDue is true once Remaining fell to reminder_before_value.
	ReminderDue    bool       `json:"reminder_due" example:"false"`
	NextDueAt      *time.Time `json:"next_due_at" format:"date-time" example:"2026-11-01T00:00:00Z"`
	LastServiceAt  *time.Time `json:"last_service_at" format:"date-time" example:"2026-05-01T00:00:00Z"`
	ReminderSentAt *time.Time `json:"reminder_sent_at" format:"date-time" example:"2026-10-20T09:00:00Z"`

	Status          string `json:"status" example:"scheduled" enums:"scheduled,due,completed,cancelled"`
	CancelledReason string `json:"cancelled_reason" example:"Unit sold"`
	// OdometerM is the raw telemetry odometer in metres, for clients that do
	// their own unit conversion.
	OdometerM   *int64   `json:"odometer_m" example:"127100000"`
	EngineHours *float64 `json:"engine_hours" example:"1234.5"`

	CreatedAt time.Time `json:"created_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	UpdatedAt time.Time `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// Record is one completed or cancelled maintenance entry (Q32 history).
type Record struct {
	ID              string    `json:"id" example:"5a4b3c2d-1e0f-4a9b-8c7d-6e5f4a3b2c1d"`
	ScheduleUnitID  *string   `json:"schedule_unit_id" example:"8c7b6a59-4d3e-4f2a-9b8c-7d6e5f4a3b2c"`
	UnitID          string    `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber      string    `json:"unit_number" example:"1021"`
	Status          string    `json:"status" example:"completed" enums:"completed,cancelled"`
	PerformedAt     time.Time `json:"performed_at" format:"date-time" example:"2026-09-06T15:04:05Z"`
	InvoiceNo       string    `json:"invoice_no" example:"INV-10233"`
	Vendor          string    `json:"vendor" example:"Dallas Truck Service"`
	Cost            *float64  `json:"cost" example:"420.5"`
	Currency        string    `json:"currency" example:"USD"`
	OdometerM       *int64    `json:"odometer_m" example:"128430000"`
	EngineHours     *float64  `json:"engine_hours" example:"1234.5"`
	InvoiceKey      string    `json:"invoice_key" example:"c1/invoice/2026/09/06/inv.pdf"`
	CancelledReason string    `json:"cancelled_reason" example:"Unit sold"`
	Notes           string    `json:"notes" example:"Oil and filter replaced"`
	CreatedAt       time.Time `json:"created_at" format:"date-time" example:"2026-09-06T15:04:05Z"`
}

// ---------------------------------------------------------------- envelopes

// ScheduleEnvelope wraps one schedule.
type ScheduleEnvelope struct {
	Data Schedule `json:"data"`
}

// ScheduleListEnvelope wraps a page of schedules.
type ScheduleListEnvelope struct {
	Data []Schedule `json:"data"`
	Meta Meta       `json:"meta"`
}

// ScheduleUnitEnvelope wraps one unit progress row.
type ScheduleUnitEnvelope struct {
	Data ScheduleUnit `json:"data"`
}

// ScheduleUnitListEnvelope wraps a page of unit progress rows.
type ScheduleUnitListEnvelope struct {
	Data []ScheduleUnit `json:"data"`
	Meta Meta           `json:"meta"`
}

// RecordEnvelope wraps one history entry.
type RecordEnvelope struct {
	Data Record `json:"data"`
}

// RecordListEnvelope wraps a page of history entries.
type RecordListEnvelope struct {
	Data []Record `json:"data"`
	Meta Meta     `json:"meta"`
}
