// Package dto holds the dashboard payloads (TZ A§20). Every counter is cut on
// the company timezone: "today" is the company's calendar day and "this week"
// is the current ISO week (Monday–Sunday) of that timezone, converted to UTC
// instants before it reaches SQL.
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

// KPI is the card row of the dashboard.
type KPI struct {
	// ActiveUnits counts the units that reported telemetry today.
	ActiveUnits int64 `json:"active_units" example:"38"`
	// DriversOnDuty counts the drivers currently in ON or DR.
	DriversOnDuty int64 `json:"drivers_on_duty" example:"21"`
	// Violations counts the violations of the current ISO week.
	Violations int64 `json:"violations" example:"4"`
	// DisconnectedELD counts the units whose ELD reported losing the link.
	DisconnectedELD int64 `json:"disconnected_eld" example:"2"`
	// MalfunctionELD counts the devices carrying an active FMCSA code.
	MalfunctionELD int64 `json:"malfunction_eld" example:"1"`
	// UncertifiedLogs counts the logs uncertified for two days or more.
	UncertifiedLogs int64 `json:"uncertified_logs" example:"6"`
	// UnassignedDriving counts the unidentified driving events still pending.
	UnassignedDriving int64 `json:"unassigned_driving" example:"3"`
	// ActiveDrivers is the denominator of the status block.
	ActiveDrivers int64 `json:"active_drivers" example:"44"`
	// PendingLogEdits counts the log edit requests waiting for a decision.
	PendingLogEdits int64 `json:"pending_log_edits" example:"2"`
}

// StatusBlock is the current duty status distribution.
type StatusBlock struct {
	Off int64 `json:"off" example:"18"`
	SB  int64 `json:"sb" example:"5"`
	DR  int64 `json:"dr" example:"12"`
	On  int64 `json:"on" example:"9"`
}

// Route is one entry of the "Route's Details" block.
type Route struct {
	ID          string     `json:"id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	Status      string     `json:"status" example:"in_progress" enums:"planned,in_progress,completed,not_completed,cancelled"`
	Sequence    int32      `json:"sequence" example:"1"`
	Origin      string     `json:"origin" example:"Dallas, TX"`
	Destination string     `json:"destination" example:"Oklahoma City, OK"`
	UnitID      string     `json:"unit_id" example:"2b7c8d9e-1122-3344-5566-778899aabbcc"`
	UnitNumber  string     `json:"unit_number" example:"1021"`
	DriverID    string     `json:"driver_id" example:"1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34"`
	DriverName  string     `json:"driver_name" example:"John Doe"`
	StartedAt   *time.Time `json:"started_at" format:"date-time" example:"2026-09-06T13:05:00Z"`
	CompletedAt *time.Time `json:"completed_at" format:"date-time" example:"2026-09-06T19:41:00Z"`
	CreatedAt   time.Time  `json:"created_at" format:"date-time" example:"2026-09-06T11:00:00Z"`
}

// Window is a closed-open time range in UTC.
type Window struct {
	From time.Time `json:"from" format:"date-time" example:"2026-09-06T05:00:00Z"`
	To   time.Time `json:"to" format:"date-time" example:"2026-09-07T05:00:00Z"`
}

// Summary is the whole dashboard payload.
type Summary struct {
	// Timezone is the company timezone the windows were cut in.
	Timezone string      `json:"timezone" example:"America/Chicago"`
	Day      Window      `json:"day"`
	Week     Window      `json:"week"`
	KPI      KPI         `json:"kpi"`
	Status   StatusBlock `json:"status"`
	Routes   []Route     `json:"routes"`
	// GeneratedAt lets a 60 second poller detect a stale payload.
	GeneratedAt time.Time `json:"generated_at" format:"date-time" example:"2026-09-06T18:05:00Z"`
}

// SummaryEnvelope wraps the dashboard payload.
type SummaryEnvelope struct {
	Data Summary `json:"data"`
}
