// Package dto holds the duty status and HOS payloads (TZ A§3, A§4).
//
// Times are UTC, distances metres (`_m`), durations minutes (`_min`). The log
// day is the home terminal 00:00-24:00 window (Q10.2), so `date` and the recap
// keys are local calendar days while every instant stays UTC.
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

// DutyStatusEvent is one duty_status_events row as the API exposes it. The sqlc
// model never leaves the repository.
type DutyStatusEvent struct {
	ID            string `json:"id" example:"7d1e2f3a-4b5c-4d6e-8f90-1a2b3c4d5e6f"`
	ClientEventID string `json:"client_event_id" example:"11111111-1111-4111-8111-111111111111"`
	EventType     string `json:"event_type" example:"duty_status" enums:"duty_status,intermediate,login,logout,power_on,power_off,engine_on,engine_off,malfunction,diagnostic,certification,yard_moves,personal_use"`
	Status        string `json:"status" example:"ON" enums:"OFF,SB,DR,ON"`
	Special       string `json:"special" example:"none" enums:"none,pc,ym"`
	Origin        string `json:"origin" example:"auto" enums:"auto,driver,driver_edit,admin_edit,assigned,manual_no_eld"`

	EventTime time.Time `json:"event_time" format:"date-time" example:"2026-09-06T05:12:00Z"`
	// TimeSource is the clock the event_time came from (Q-B1.2).
	TimeSource string `json:"time_source" example:"eld_rtc" enums:"eld_rtc,server,phone"`
	// TimeUnverified marks an event stamped from the phone only; the admin log
	// shows it with a yellow marker (Q7.1).
	TimeUnverified bool `json:"time_unverified" example:"false"`
	// ClockSkewSec is phone minus reference clock, in seconds.
	ClockSkewSec int32     `json:"clock_skew_sec" example:"0"`
	ReceivedAt   time.Time `json:"received_at" format:"date-time" example:"2026-09-06T05:14:11Z"`

	UnitID       *string  `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	Lat          *float64 `json:"lat" example:"31.52"`
	Lng          *float64 `json:"lng" example:"74.35"`
	LocationText *string  `json:"location_text" example:"12 km NE of Lahore"`
	GPSAccuracyM *int32   `json:"gps_accuracy_m" example:"12"`
	OdometerM    *int64   `json:"odometer_m" example:"128430000"`
	EngineHours  *float64 `json:"engine_hours" example:"1234.5"`
	Notes        *string  `json:"notes" example:"Pickup"`

	TrailerIDs     []string `json:"trailer_ids" example:"9f8e7d6c-5b4a-4392-8281-706f5e4d3c2b"`
	ShippingDocIDs []string `json:"shipping_doc_ids" example:"1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f"`

	DeviceSeq *int64 `json:"device_seq" example:"1042"`
	// SupersededBy points at the event that won conflict rule 1; a superseded
	// event stays in the log and never disappears.
	SupersededBy *string `json:"superseded_by" example:"8a9b0c1d-2e3f-4a5b-8c6d-7e8f9a0b1c2d"`
	Locked       bool    `json:"locked" example:"false"`
	DailyLogID   *string `json:"daily_log_id" example:"4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0"`
}

// DutyStatusEventListEnvelope is the paginated event list.
type DutyStatusEventListEnvelope struct {
	Data []DutyStatusEvent `json:"data"`
	Meta Meta              `json:"meta"`
}

// Counters are the four remaining-time counters plus Q10.9's derived minimum.
type Counters struct {
	BreakLeftMin       int64 `json:"break_left_min" example:"180"`
	DriveLeftMin       int64 `json:"drive_left_min" example:"420"`
	ShiftLeftMin       int64 `json:"shift_left_min" example:"540"`
	CycleLeftMin       int64 `json:"cycle_left_min" example:"3600"`
	DrivingTimeLeftMin int64 `json:"driving_time_left_min" example:"180"`
}

// DayTotals are the four duty-line totals of one log day (Q10.2).
type DayTotals struct {
	OffMin   int64 `json:"off_min" example:"600"`
	SBMin    int64 `json:"sb_min" example:"0"`
	DriveMin int64 `json:"drive_min" example:"480"`
	OnMin    int64 `json:"on_min" example:"360"`
}

// RecapDay is one row of the cycle recap table (Q10.7).
type RecapDay struct {
	Date          string `json:"date" format:"date" example:"2026-09-06"`
	OnDutyMin     int64  `json:"on_duty_min" example:"840"`
	AvailableMin  int64  `json:"available_min" example:"3360"`
	GainedNextMin int64  `json:"gained_next_min" example:"120"`
}

// Violation is a computed warning or violation. Stage 3 only reports them;
// persisting to the `violations` table is stage 4 (server canonical).
type Violation struct {
	Type     string    `json:"type" example:"break_required" enums:"drive_limit,shift_limit,break_required,cycle_limit,form_manner_trailer,form_manner_doc"`
	Severity string    `json:"severity" example:"warning" enums:"warning,violation"`
	At       time.Time `json:"at" format:"date-time" example:"2026-09-06T13:00:00Z"`
}

// HosSummary is the driver's HOS state for one log day.
type HosSummary struct {
	DriverID string `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	// Date is the log day in the home terminal timezone (Q10.2).
	Date string `json:"date" format:"date" example:"2026-09-06"`
	// Timezone is the home terminal timezone the day boundary was taken in.
	Timezone string `json:"timezone" example:"America/Chicago"`
	// EvaluatedAt is the instant the counters describe: `now` for today, the
	// end of the log day for a past date.
	EvaluatedAt time.Time `json:"evaluated_at" format:"date-time" example:"2026-09-06T18:00:00Z"`
	// PolicyVersionID is the hos_policy_versions row in force on that day
	// (Q10.1); null means the built-in FMCSA 70/8 defaults were used.
	PolicyVersionID *string `json:"policy_version_id" example:"2f3a4b5c-6d7e-4f80-9a1b-2c3d4e5f6a7b"`

	Counters   Counters    `json:"counters"`
	Totals     DayTotals   `json:"totals"`
	Recap      []RecapDay  `json:"recap"`
	Violations []Violation `json:"violations"`
}

// HosSummaryEnvelope wraps a single HOS summary.
type HosSummaryEnvelope struct {
	Data HosSummary `json:"data"`
}
