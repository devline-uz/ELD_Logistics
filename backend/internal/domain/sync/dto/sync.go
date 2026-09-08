// Package dto holds the offline sync payloads (TZ D§2).
//
// Units are raw: distance in metres (`_m`), speed in km/h, durations in minutes
// (`_min`), time in UTC. The log day is the home terminal 00:00-24:00 window
// (Q10.2), so calendar days are local while every instant is UTC.
package dto

import (
	"time"

	dutydto "github.com/devline/onebook-eld/internal/domain/duty/dto"
	logsdto "github.com/devline/onebook-eld/internal/domain/logs/dto"
	telemetrydto "github.com/devline/onebook-eld/internal/domain/telemetry/dto"
	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared envelopes re-exported so swagger annotations can reference dto.X.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
	// TelemetryPoint is one telemetry sample; the ingestion pipeline owns it.
	TelemetryPoint = telemetrydto.Point
	// DutyStatusEvent is the canonical server copy of one duty status event.
	DutyStatusEvent = dutydto.DutyStatusEvent
)

// Batch ceilings, mirrored from internal/sync so the contract is documented
// where the payload is. Exceeding one answers 422 BATCH_TOO_LARGE.
const (
	MaxEvents          = 500
	MaxTelemetryPoints = 5000
	MaxDvir            = 100
	MaxChat            = 500
)

// Clock is the device clock snapshot sent with every push (Q-B1.2). Omit
// `eld_rtc` when no ELD was connected: the batch is then phone stamped and
// every event it carries is `time_unverified` (Q7.1).
type Clock struct {
	Phone  *time.Time `json:"phone" format:"date-time" example:"2026-09-06T05:12:03Z"`
	ELDRTC *time.Time `json:"eld_rtc" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// EventPush is one duty status event as the device uploads it.
type EventPush struct {
	// ClientEventID is the device generated idempotency key. Re-uploading it
	// answers `duplicate`, never an error.
	ClientEventID string `json:"client_event_id" example:"11111111-1111-4111-8111-111111111111" validate:"required,uuid"`
	EventType     string `json:"event_type" example:"status_change" enums:"status_change,duty_status,intermediate,login,logout,power_on,power_off,engine_on,engine_off,malfunction,diagnostic,certification,yard_moves,personal_use" validate:"required"`
	Status        string `json:"status" example:"ON" enums:"OFF,SB,DR,ON" validate:"omitempty,oneof=OFF SB DR ON"`
	Special       string `json:"special" example:"none" enums:"none,pc,ym" validate:"omitempty,oneof=none pc ym"`
	// Origin records how the event came to be. `manual_no_eld` marks a status
	// entered with the ELD disconnected (Q7.1). `driver_edit`, `admin_edit`
	// and `assigned` are server side origins (log edit approval, §10.4 hand
	// over) and are refused here with `rejected(invalid_payload)`.
	Origin string `json:"origin" example:"driver" enums:"auto,driver,manual_no_eld" validate:"omitempty,oneof=auto driver manual_no_eld"`

	EventTime time.Time `json:"event_time" format:"date-time" example:"2026-09-06T05:12:00Z" validate:"required"`
	// TimeSource is the clock event_time came from (Q-B1.2).
	TimeSource string `json:"time_source" example:"eld_rtc" enums:"eld_rtc,server,phone" validate:"omitempty,oneof=eld_rtc server phone"`
	// DeviceSeq is the monotonic device counter; retries preserve its order
	// and it breaks a conflict tie between two devices (rule 1).
	DeviceSeq *int64 `json:"device_seq" example:"1042" validate:"omitempty,gte=0"`

	UnitID       string   `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f" validate:"omitempty,uuid"`
	ELDDeviceID  string   `json:"eld_device_id" example:"9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f" validate:"omitempty,uuid"`
	Lat          *float64 `json:"lat" example:"31.52" validate:"omitempty,gte=-90,lte=90"`
	Lng          *float64 `json:"lng" example:"74.35" validate:"omitempty,gte=-180,lte=180"`
	LocationText string   `json:"location_text" example:"12 km NE of Lahore" validate:"omitempty,max=120"`
	GPSAccuracyM *int32   `json:"gps_accuracy_m" example:"12" validate:"omitempty,gte=0"`
	OdometerM    *int64   `json:"odometer_m" example:"128430000" validate:"omitempty,gte=0"`
	EngineHours  *float64 `json:"engine_hours" example:"1234.5" validate:"omitempty,gte=0"`
	// SpeedKmh at event_time drives the server side auto-DR and yard-move exit
	// checks (Q5, Q4.2).
	SpeedKmh *float64 `json:"speed_kmh" example:"62.5" validate:"omitempty,gte=0,lte=400"`

	Notes          string   `json:"notes" example:"Pickup" validate:"omitempty,max=60"`
	TrailerIDs     []string `json:"trailer_ids" example:"9f8e7d6c-5b4a-4392-8281-706f5e4d3c2b" validate:"omitempty,dive,uuid"`
	ShippingDocIDs []string `json:"shipping_doc_ids" example:"1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f" validate:"omitempty,dive,uuid"`
}

// DvirPush is a placeholder element of the DVIR batch.
//
// TODO(stage 6): DVIR is processed in stage 6 (defect list, state machine,
// critical defect -> out_of_service). Stage 3 accepts and acknowledges the
// element so the device can drain its queue without losing ordering; nothing is
// stored yet.
type DvirPush struct {
	// ClientID is the device generated idempotency key of the report.
	ClientID string `json:"client_id" example:"44444444-4444-4444-8444-444444444444" validate:"required,uuid"`
}

// ChatPush is a placeholder element of the chat batch.
//
// TODO(stage 5): chat delivery, read receipts and the driving-mode block land
// in stage 5. Stage 3 acknowledges the element without storing it.
type ChatPush struct {
	// ClientID is the device generated idempotency key of the message.
	ClientID string `json:"client_id" example:"55555555-5555-4555-8555-555555555555" validate:"required,uuid"`
}

// PushRequest is one POST /sync/push payload.
type PushRequest struct {
	// DeviceID identifies the uploading phone; it namespaces the per device
	// rate limit and is echoed into the audit trail.
	DeviceID   string `json:"device_id" example:"a1b2c3d4-e5f6-4718-9a0b-1c2d3e4f5a6b" validate:"required,max=128"`
	AppVersion string `json:"app_version" example:"1.2.0" validate:"omitempty,max=32"`
	Clock      Clock  `json:"clock"`
	// UnitID is the unit the telemetry belongs to; required when `telemetry`
	// is not empty.
	UnitID string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f" validate:"omitempty,uuid"`

	Events    []EventPush      `json:"events" validate:"omitempty,dive"`
	Telemetry []TelemetryPoint `json:"telemetry" validate:"omitempty,dive"`
	Dvir      []DvirPush       `json:"dvir" validate:"omitempty,dive"`
	Chat      []ChatPush       `json:"chat" validate:"omitempty,dive"`
}

// ElementResult is the outcome of one uploaded element.
type ElementResult struct {
	// ClientEventID echoes the element's idempotency key.
	ClientEventID string `json:"client_event_id" example:"11111111-1111-4111-8111-111111111111"`
	Result        string `json:"result" example:"accepted" enums:"accepted,duplicate,rejected"`
	// Reason explains a rejection, and annotates an accepted event that the
	// server changed or that lost conflict rule 1.
	Reason string `json:"reason" example:"time_in_future" enums:"time_in_future,time_out_of_range,log_locked,invalid_payload,superseded,pc_not_allowed,ym_not_allowed,sleeper_berth_unavailable,drive_not_manual,auto_drive,yard_move_ended"`
	// Field names the offending field of an invalid_payload rejection.
	Field string `json:"field" example:"event_time"`
	// SupersededBy is the client_event_id that won conflict rule 1. The losing
	// event is still stored, flagged, and shown to the driver as a warning.
	SupersededBy string `json:"superseded_by" example:"22222222-2222-4222-8222-222222222222"`
}

// TelemetryResult is the aggregate outcome of the telemetry half of a push.
// A repeated `(unit_id, ts)` sample is ignored, not an error (rule 4).
type TelemetryResult struct {
	Accepted  int `json:"accepted" example:"120"`
	Duplicate int `json:"duplicate" example:"3"`
	Rejected  int `json:"rejected" example:"0"`
	// DistanceM is the distance the accepted samples added to the unit.
	DistanceM int64 `json:"distance_m" example:"12400"`
}

// ClockVerdict is the batch time-integrity result (Q-B1.2).
type ClockVerdict struct {
	// Source is the clock the events were stamped from.
	Source string `json:"source" example:"eld_rtc" enums:"eld_rtc,server,phone"`
	// SkewSec is phone minus reference clock, in seconds.
	SkewSec int `json:"clock_skew_sec" example:"0"`
	// TimeUnverified marks a batch whose only clock was the phone.
	TimeUnverified bool `json:"time_unverified" example:"false"`
	// Warning is raised above two minutes of drift: tell the driver.
	Warning bool `json:"warning" example:"false"`
	// MalfunctionCode is the FMCSA Appendix A letter to raise above ten
	// minutes of drift ("T", timing compliance); empty when the clock is fine.
	MalfunctionCode string `json:"malfunction_code" example:"" enums:"T"`
}

// PushResponse is the per element outcome of one push.
type PushResponse struct {
	ServerTime time.Time       `json:"server_time" format:"date-time" example:"2026-09-06T05:14:11Z"`
	Clock      ClockVerdict    `json:"clock"`
	Events     []ElementResult `json:"events"`
	Telemetry  TelemetryResult `json:"telemetry"`
	Dvir       []ElementResult `json:"dvir"`
	Chat       []ElementResult `json:"chat"`
}

// PushEnvelope wraps the push outcome.
type PushEnvelope struct {
	Data PushResponse `json:"data"`
}

// HosPolicy is the company policy in force, as the offline engine needs it
// (TZ A§4.2). Durations are minutes.
type HosPolicy struct {
	// VersionID is the hos_policy_versions row; null means the built-in
	// FMCSA 70/8 defaults.
	VersionID     *string    `json:"version_id" example:"2f3a4b5c-6d7e-4f80-9a1b-2c3d4e5f6a7b"`
	EffectiveFrom *time.Time `json:"effective_from" format:"date-time" example:"2026-01-01T00:00:00Z"`

	DriveLimitMin              int      `json:"drive_limit_min" example:"660"`
	ShiftWindowMin             int      `json:"shift_window_min" example:"840"`
	BreakRequiredAfterDriveMin int      `json:"break_required_after_drive_min" example:"480"`
	BreakDurationMin           int      `json:"break_duration_min" example:"30"`
	BreakQualifyingStatuses    []string `json:"break_qualifying_statuses" example:"OFF,SB,ON" enums:"OFF,SB,DR,ON"`
	DailyRestMin               int      `json:"daily_rest_min" example:"600"`
	CycleLimitMin              int      `json:"cycle_limit_min" example:"4200"`
	CycleDays                  int      `json:"cycle_days" example:"8"`
	// CycleRestartMin is null when the policy has no restart provision.
	CycleRestartMin         *int    `json:"cycle_restart_min" example:"2040"`
	SleeperSplitEnabled     bool    `json:"sleeper_split_enabled" example:"true"`
	AllowPC                 bool    `json:"allow_pc" example:"true"`
	AllowYM                 bool    `json:"allow_ym" example:"true"`
	YMMaxSpeedKmh           float64 `json:"ym_max_speed_kmh" example:"32"`
	MotionThresholdKmh      float64 `json:"motion_threshold_kmh" example:"8"`
	ShortHaulException      bool    `json:"short_haul_exception" example:"false"`
	AdverseConditionsExtMin int     `json:"adverse_conditions_extension_min" example:"120"`

	WarnDriveMin int `json:"warn_drive_min" example:"30"`
	WarnShiftMin int `json:"warn_shift_min" example:"60"`
	WarnBreakMin int `json:"warn_break_min" example:"30"`
	WarnCycleMin int `json:"warn_cycle_min" example:"120"`
}

// UnidentifiedEvent is one pending unidentified driving buffer entry of the
// driver's unit (TZ A§10.4). The driver claims it from the app.
type UnidentifiedEvent struct {
	ID         string     `json:"id" example:"6a7b8c9d-0e1f-4a2b-8c3d-4e5f6a7b8c9d"`
	UnitID     string     `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber string     `json:"unit_number" example:"1021"`
	StartAt    time.Time  `json:"start_at" format:"date-time" example:"2026-09-05T14:00:00Z"`
	EndAt      *time.Time `json:"end_at" format:"date-time" example:"2026-09-05T14:35:00Z"`
	DistanceM  int64      `json:"distance_m" example:"18400"`
	Status     string     `json:"status" example:"pending" enums:"pending,assigned,annotated"`
	UpdatedAt  time.Time  `json:"updated_at" format:"date-time" example:"2026-09-05T14:36:02Z"`
}

// LogEditRequest is a pending edit awaiting the driver's answer (Q17). It is
// either an admin proposal (`source=admin_edit`) or an unidentified driving
// assignment (`source=unidentified_assign`, TZ A§10.4); both are answered with
// POST /log-edit-requests/{id}/approve or /reject.
type LogEditRequest struct {
	ID         string `json:"id" example:"7b8c9d0e-1f2a-4b3c-8d4e-5f6a7b8c9d0e"`
	DailyLogID string `json:"daily_log_id" example:"4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0"`
	// LogDate is the home terminal calendar day the proposal touches (Q10.2).
	LogDate  string `json:"log_date" format:"date" example:"2026-09-05"`
	Timezone string `json:"timezone" example:"America/Chicago"`
	Status   string `json:"status" example:"pending" enums:"pending,approved,rejected"`
	Source   string `json:"source" example:"admin_edit" enums:"admin_edit,unidentified_assign"`
	// Changes are the proposed duty status intervals; `note` is always set.
	Changes   []logsdto.LogEditChange `json:"changes"`
	CreatedAt time.Time               `json:"created_at" format:"date-time" example:"2026-09-05T09:00:00Z"`
	UpdatedAt time.Time               `json:"updated_at" format:"date-time" example:"2026-09-05T09:00:00Z"`
}

// DailyLogSummary is the canonical server copy of one log day (rule 2).
type DailyLogSummary struct {
	ID       string `json:"id" example:"4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0"`
	LogDate  string `json:"log_date" format:"date" example:"2026-09-06"`
	Timezone string `json:"timezone" example:"America/Chicago"`
	// Totals are the four duty-line minutes of the day.
	Totals              dutydto.DayTotals `json:"totals"`
	DistanceM           int64             `json:"distance_m" example:"412000"`
	CertificationStatus string            `json:"certification_status" example:"uncertified" enums:"uncertified,certified,needs_recertify"`
	SignedAt            *time.Time        `json:"signed_at" format:"date-time" example:"2026-09-06T23:50:00Z"`
	UpdatedAt           time.Time         `json:"updated_at" format:"date-time" example:"2026-09-06T23:50:01Z"`
}

// DefectType is one row of the DVIR defect catalogue.
type DefectType struct {
	ID         string `json:"id" example:"8c9d0e1f-2a3b-4c4d-8e5f-6a7b8c9d0e1f"`
	Name       string `json:"name" example:"Brakes"`
	Category   string `json:"category" example:"truck" enums:"truck,trailer"`
	IsCritical bool   `json:"is_critical" example:"true"`
	SortOrder  int32  `json:"sort_order" example:"10"`
}

// ChatMessage is one message of the driver's thread.
type ChatMessage struct {
	ID          string     `json:"id" example:"9d0e1f2a-3b4c-4d5e-8f6a-7b8c9d0e1f2a"`
	SenderID    string     `json:"sender_id" example:"0e1f2a3b-4c5d-4e6f-8a7b-8c9d0e1f2a3b"`
	Kind        string     `json:"kind" example:"text" enums:"text,image,file,location"`
	Text        *string    `json:"text" example:"Please call dispatch"`
	FileKey     *string    `json:"file_key" example:"chat/2026/09/abc.jpg"`
	Lat         *float64   `json:"lat" example:"31.52"`
	Lng         *float64   `json:"lng" example:"74.35"`
	SentAt      time.Time  `json:"sent_at" format:"date-time" example:"2026-09-06T05:00:00Z"`
	DeliveredAt *time.Time `json:"delivered_at" format:"date-time" example:"2026-09-06T05:00:02Z"`
	ReadAt      *time.Time `json:"read_at" format:"date-time" example:"2026-09-06T05:01:00Z"`
	UpdatedAt   time.Time  `json:"updated_at" format:"date-time" example:"2026-09-06T05:01:00Z"`
}

// PullResponse is everything the device has to catch up on since the cursor.
type PullResponse struct {
	ServerTime time.Time `json:"server_time" format:"date-time" example:"2026-09-06T05:14:11Z"`
	// NextSince is the cursor to send on the next pull. It is the newest
	// `updated_at` actually returned, so a truncated page is resumed exactly.
	NextSince time.Time `json:"next_since" format:"date-time" example:"2026-09-06T05:13:59Z"`
	// Truncated is true when a list hit its ceiling: pull again immediately
	// with next_since.
	Truncated bool `json:"truncated" example:"false"`

	LogEditRequests    []LogEditRequest    `json:"log_edit_requests"`
	UnidentifiedEvents []UnidentifiedEvent `json:"unidentified_events"`
	// Events are the server's canonical copies of changed duty status events
	// (rule 2: the server wins, the device rebuilds its local log).
	Events    []DutyStatusEvent `json:"events"`
	DailyLogs []DailyLogSummary `json:"daily_logs"`

	HosPolicy   HosPolicy     `json:"hos_policy"`
	DefectTypes []DefectType  `json:"defect_types"`
	QuickNotes  []string      `json:"quick_notes" example:"Pickup,Delivery,Fuel"`
	Chat        []ChatMessage `json:"chat"`
}

// PullEnvelope wraps the pull payload.
type PullEnvelope struct {
	Data PullResponse `json:"data"`
}
