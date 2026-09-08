// Package dto holds the daily log, certification, log edit request,
// unidentified driving, violation and roadside inspection payloads
// (TZ A§5, A§6, A§10.4, A§11, A§12).
//
// Times are UTC (RFC 3339), calendar days are the home terminal local day
// (Q10.2), distances metres (`_m`) and durations minutes (`_min`). The sqlc
// model never leaves the repository.
package dto

import (
	"time"

	dutydto "github.com/devline/onebook-eld/internal/domain/duty/dto"
	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared envelopes re-exported so swagger annotations can reference dto.X.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
	// DayTotals are the four duty-line totals of one log day (Q10.2).
	DayTotals = dutydto.DayTotals
)

// ---------------------------------------------------------------- daily log

// DailyLogSummary is one row of the certification window (Q19).
type DailyLogSummary struct {
	ID       string `json:"id" example:"4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0"`
	DriverID string `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	// DriverName is "First Last" of the log owner.
	DriverName string `json:"driver_name" example:"Ali Karimov"`
	// LogDate is the home terminal calendar day (Q10.2).
	LogDate  string `json:"log_date" format:"date" example:"2026-09-06"`
	Timezone string `json:"timezone" example:"America/Chicago"`
	// CertificationStatus is the Q19 tri-state.
	CertificationStatus string `json:"certification_status" example:"uncertified" enums:"uncertified,certified,needs_recertify"`
	// Ready is false while the day still misses its signature (Q25).
	Ready     bool       `json:"ready" example:"false"`
	SignedAt  *time.Time `json:"signed_at" format:"date-time" example:"2026-09-06T23:50:00Z"`
	DistanceM int64      `json:"distance_m" example:"412000"`
	Totals    DayTotals  `json:"totals"`
	UnitIDs   []string   `json:"unit_ids" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	// CoDriverName is the second seat of the day, null when driving alone.
	CoDriverName *string   `json:"co_driver_name" example:"Bekzod Rasulov"`
	UpdatedAt    time.Time `json:"updated_at" format:"date-time" example:"2026-09-06T23:50:01Z"`
}

// DailyLogListEnvelope is the paginated certification window.
type DailyLogListEnvelope struct {
	Data []DailyLogSummary `json:"data"`
	Meta Meta              `json:"meta"`
}

// UnitRef identifies one unit on the log form.
type UnitRef struct {
	ID           string  `json:"id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber   string  `json:"unit_number" example:"1021"`
	VIN          *string `json:"vin" example:"1FUJGLDR9CSBP8834"`
	LicensePlate *string `json:"license_plate" example:"AA1234BB"`
}

// NumberRef is a trailer or shipping document reference.
type NumberRef struct {
	ID     string `json:"id" example:"9f8e7d6c-5b4a-4392-8281-706f5e4d3c2b"`
	Number string `json:"number" example:"TR-77"`
}

// LogForm is the daily log header (Q16). Distance comes from telemetry and is
// never edited by hand.
type LogForm struct {
	Units        []UnitRef   `json:"units"`
	DriverName   string      `json:"driver_name" example:"Ali Karimov"`
	CoDriverName *string     `json:"co_driver_name" example:"Bekzod Rasulov"`
	DistanceM    int64       `json:"distance_m" example:"412000"`
	Trailers     []NumberRef `json:"trailers"`
	ShippingDocs []NumberRef `json:"shipping_docs"`
	// SignatureKey is the object storage key of the stored signature image.
	SignatureKey   *string    `json:"signature_key" example:"companies/6f1a/signatures/2026/09/sig.png"`
	SignedAt       *time.Time `json:"signed_at" format:"date-time" example:"2026-09-06T23:50:00Z"`
	SignedDeviceID *string    `json:"signed_device_id" example:"pixel-8-a1b2"`
	SignedIP       *string    `json:"signed_ip" example:"203.0.113.7"`
	CarrierName    string     `json:"carrier_name" example:"ONEBOOK Logistics"`
	// HomeTerminalAddress is the carrier's home terminal (Q16).
	HomeTerminalAddress *string `json:"home_terminal_address" example:"1200 Industrial Rd, Dallas, TX"`
}

// LogEvent is one duty_status_events row on a log day.
type LogEvent struct {
	ID        string `json:"id" example:"7d1e2f3a-4b5c-4d6e-8f90-1a2b3c4d5e6f"`
	EventType string `json:"event_type" example:"duty_status" enums:"duty_status,intermediate,login,logout,power_on,power_off,engine_on,engine_off,malfunction,diagnostic,certification,yard_moves,personal_use"`
	Status    string `json:"status" example:"ON" enums:"OFF,SB,DR,ON"`
	Special   string `json:"special" example:"none" enums:"none,pc,ym"`
	// Origin says who produced the row; `auto` is the ELD itself (Q13.1).
	Origin       string    `json:"origin" example:"auto" enums:"auto,driver,driver_edit,admin_edit,assigned"`
	EventTime    time.Time `json:"event_time" format:"date-time" example:"2026-09-06T05:12:00Z"`
	TimeSource   string    `json:"time_source" example:"eld_rtc" enums:"eld_rtc,server,phone"`
	ReceivedAt   time.Time `json:"received_at" format:"date-time" example:"2026-09-06T05:14:11Z"`
	UnitID       *string   `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber   *string   `json:"unit_number" example:"1021"`
	Lat          *float64  `json:"lat" example:"31.52"`
	Lng          *float64  `json:"lng" example:"74.35"`
	LocationText *string   `json:"location_text" example:"12 km NE of Lahore"`
	OdometerM    *int64    `json:"odometer_m" example:"128430000"`
	EngineHours  *float64  `json:"engine_hours" example:"1234.5"`
	Notes        *string   `json:"notes" example:"Admin correction: forgot to switch to ON"`
	// Edited marks the ✎ badge: the row came from an edit (Q17.2).
	Edited bool `json:"edited" example:"false"`
	// SupersededBy points at the row that replaced this one. The original is
	// never deleted (Q17).
	SupersededBy *string `json:"superseded_by" example:"8a9b0c1d-2e3f-4a5b-8c6d-7e8f9a0b1c2d"`
	// Locked is true once the day has been certified (Q26.1).
	Locked bool `json:"locked" example:"false"`
}

// DailyLogDetail is one log day with its events, its form and its violations.
type DailyLogDetail struct {
	DailyLogSummary
	Form       LogForm     `json:"form"`
	Events     []LogEvent  `json:"events"`
	Violations []Violation `json:"violations"`
}

// DailyLogEnvelope wraps one log day.
type DailyLogEnvelope struct {
	Data DailyLogDetail `json:"data"`
}

// CertifyRequest certifies one log day (Q26.1). Exactly one signature source
// is used: signature_id (a stored signature), signature_key (a freshly drawn
// one already uploaded) or, when both are omitted, the driver's default.
type CertifyRequest struct {
	SignatureID  *string `json:"signature_id" example:"5c6d7e8f-9a0b-4c1d-8e2f-3a4b5c6d7e8f" validate:"omitempty,uuid4"`
	SignatureKey *string `json:"signature_key" example:"companies/6f1a/signatures/2026/09/sig.png" validate:"omitempty,max=512"`
	DeviceID     *string `json:"device_id" example:"pixel-8-a1b2" validate:"omitempty,max=128"`
}

// UncertifiedLog is one row of the admin "uncertified logs" alert (Q19.1).
type UncertifiedLog struct {
	DailyLogID          string `json:"daily_log_id" example:"4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0"`
	DriverID            string `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	DriverName          string `json:"driver_name" example:"Ali Karimov"`
	LogDate             string `json:"log_date" format:"date" example:"2026-08-20"`
	CertificationStatus string `json:"certification_status" example:"uncertified" enums:"uncertified,needs_recertify"`
	// DaysOverdue counts calendar days past the 8 day certification window.
	DaysOverdue int `json:"days_overdue" example:"3"`
}

// UncertifiedLogListEnvelope is the paginated uncertified logs report.
type UncertifiedLogListEnvelope struct {
	Data []UncertifiedLog `json:"data"`
	Meta Meta             `json:"meta"`
}

// ---------------------------------------------------------- log edit model

// LogEditChange is one proposed duty status interval (Q17). `note` is
// mandatory: an edit without a reason is refused.
type LogEditChange struct {
	From    time.Time `json:"from" format:"date-time" example:"2026-09-06T13:00:00Z" validate:"required"`
	To      time.Time `json:"to" format:"date-time" example:"2026-09-06T15:00:00Z" validate:"required"`
	Status  string    `json:"status" example:"ON" enums:"OFF,SB,DR,ON" validate:"required,oneof=OFF SB DR ON"`
	Special string    `json:"special" example:"none" enums:"none,pc,ym" validate:"omitempty,oneof=none pc ym"`
	Note    string    `json:"note" example:"Loading at the dock, forgot to switch" validate:"required,min=3,max=500"`
}

// LogEditRequestCreate is the admin proposal (Q17, [MUST]). The admin never
// writes the log directly; the driver approves or rejects.
type LogEditRequestCreate struct {
	DriverID   string          `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b" validate:"required,uuid4"`
	DailyLogID string          `json:"daily_log_id" example:"4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0" validate:"required,uuid4"`
	Changes    []LogEditChange `json:"changes" validate:"required,min=1,max=50,dive"`
}

// LogEditRequest is one row of the propose/approve queue.
type LogEditRequest struct {
	ID         string `json:"id" example:"7b8c9d0e-1f2a-4b3c-8d4e-5f6a7b8c9d0e"`
	DriverID   string `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	DriverName string `json:"driver_name" example:"Ali Karimov"`
	DailyLogID string `json:"daily_log_id" example:"4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0"`
	LogDate    string `json:"log_date" format:"date" example:"2026-09-06"`
	Timezone   string `json:"timezone" example:"America/Chicago"`
	Status     string `json:"status" example:"pending" enums:"pending,approved,rejected"`
	// Source separates an admin proposal from an unidentified driving
	// assignment awaiting the same driver approval (§10.4).
	Source      string          `json:"source" example:"admin_edit" enums:"admin_edit,unidentified_assign"`
	Changes     []LogEditChange `json:"changes"`
	RequestedBy string          `json:"requested_by" example:"1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d"`
	// DriverNote carries the rejection reason once the driver answered.
	DriverNote          *string    `json:"driver_note" example:"That was my co-driver, not me"`
	UnidentifiedEventID *string    `json:"unidentified_event_id" example:"2b3c4d5e-6f70-4819-a2b3-c4d5e6f7a8b9"`
	ResolvedAt          *time.Time `json:"resolved_at" format:"date-time" example:"2026-09-06T19:04:00Z"`
	CreatedAt           time.Time  `json:"created_at" format:"date-time" example:"2026-09-06T18:00:00Z"`
	UpdatedAt           time.Time  `json:"updated_at" format:"date-time" example:"2026-09-06T19:04:00Z"`
}

// LogEditRequestEnvelope wraps one edit request.
type LogEditRequestEnvelope struct {
	Data LogEditRequest `json:"data"`
}

// LogEditRequestListEnvelope is the paginated edit request queue.
type LogEditRequestListEnvelope struct {
	Data []LogEditRequest `json:"data"`
	Meta Meta             `json:"meta"`
}

// LogEditReject carries the mandatory rejection reason.
type LogEditReject struct {
	Reason string `json:"reason" example:"That block was my co-driver" validate:"required,min=3,max=500"`
}

// LogEventCreate is the driver's own edit (Q17): applied immediately, the
// original event is kept behind `superseded_by`.
type LogEventCreate struct {
	From    time.Time `json:"from" format:"date-time" example:"2026-09-06T13:00:00Z" validate:"required"`
	To      time.Time `json:"to" format:"date-time" example:"2026-09-06T15:00:00Z" validate:"required"`
	Status  string    `json:"status" example:"ON" enums:"OFF,SB,DR,ON" validate:"required,oneof=OFF SB DR ON"`
	Special string    `json:"special" example:"none" enums:"none,pc,ym" validate:"omitempty,oneof=none pc ym"`
	Note    string    `json:"note" example:"Yard move at the terminal" validate:"required,min=3,max=500"`
	UnitID  *string   `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f" validate:"omitempty,uuid4"`
}

// ------------------------------------------------------ unidentified driving

// UnidentifiedEvent is one unassigned driving block (§10.4).
type UnidentifiedEvent struct {
	ID         string     `json:"id" example:"2b3c4d5e-6f70-4819-a2b3-c4d5e6f7a8b9"`
	UnitID     string     `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber string     `json:"unit_number" example:"1021"`
	StartAt    time.Time  `json:"start_at" format:"date-time" example:"2026-09-05T14:00:00Z"`
	EndAt      *time.Time `json:"end_at" format:"date-time" example:"2026-09-05T14:40:00Z"`
	DistanceM  int64      `json:"distance_m" example:"18400"`
	// Status is `proposed` while an admin assignment waits for the driver.
	Status             string    `json:"status" example:"pending" enums:"pending,proposed,assigned,annotated"`
	AssignedDriverID   *string   `json:"assigned_driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	AssignedDriverName *string   `json:"assigned_driver_name" example:"Ali Karimov"`
	Annotation         *string   `json:"annotation" example:"Mechanic test drive"`
	EditRequestID      *string   `json:"edit_request_id" example:"7b8c9d0e-1f2a-4b3c-8d4e-5f6a7b8c9d0e"`
	CreatedAt          time.Time `json:"created_at" format:"date-time" example:"2026-09-05T14:41:00Z"`
}

// UnidentifiedEventEnvelope wraps one unassigned driving block.
type UnidentifiedEventEnvelope struct {
	Data UnidentifiedEvent `json:"data"`
}

// UnidentifiedAssign proposes an unassigned block to a driver. The block is
// only moved once the driver approves the generated edit request.
type UnidentifiedAssign struct {
	DriverID string `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b" validate:"required,uuid4"`
	Note     string `json:"note" example:"Matches your dispatch for that trip" validate:"required,min=3,max=500"`
}

// UnidentifiedAnnotate leaves the block unassigned with an explanation.
type UnidentifiedAnnotate struct {
	Annotation string `json:"annotation" example:"Mechanic test drive after brake repair" validate:"required,min=3,max=500"`
}

// ---------------------------------------------------------------- violations

// ViolationDetails is the machine readable context of a violation.
type ViolationDetails struct {
	// LimitMin is the policy limit that was measured against, in minutes.
	LimitMin int64 `json:"limit_min" example:"660"`
	// RemainingMin is what was left when a warning was raised.
	RemainingMin int64 `json:"remaining_min" example:"20"`
	// DaysUncertified counts the uncertified days behind an `uncertified_log`.
	DaysUncertified int `json:"days_uncertified" example:"2"`
	// Note is the human readable explanation.
	Note string `json:"note" example:"driving beyond the 11 hour limit"`
}

// Violation is one stored warning/violation. Violations are never deleted;
// they are closed with resolved_at + resolved_reason (Q58).
type Violation struct {
	ID string `json:"id" example:"0a1b2c3d-4e5f-4a6b-8c7d-8e9f0a1b2c3d"`
	// DriverID is null for `unidentified_driving`, which has no driver yet.
	DriverID   *string `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	DriverName *string `json:"driver_name" example:"Ali Karimov"`
	DailyLogID *string `json:"daily_log_id" example:"4b5c6d7e-8f90-41a2-b3c4-d5e6f7a8b9c0"`
	LogDate    *string `json:"log_date" format:"date" example:"2026-09-06"`
	UnitID     *string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	// Type is the canonical HOS violation catalogue (Q57).
	Type     string `json:"type" example:"drive_limit" enums:"form_manner_trailer,form_manner_doc,drive_limit,shift_limit,break_required,cycle_limit,uncertified_log,unidentified_driving,eld_malfunction,missing_dvir"`
	Severity string `json:"severity" example:"violation" enums:"warning,violation"`
	// OccurredAt is the instant the engine placed the breach.
	OccurredAt time.Time        `json:"occurred_at" format:"date-time" example:"2026-09-06T17:00:00Z"`
	Details    ViolationDetails `json:"details"`
	// PolicyVersionID is the hos_policy_versions row the day was judged under
	// (Q10.1); null means the built-in FMCSA defaults.
	PolicyVersionID *string `json:"policy_version_id" example:"2f3a4b5c-6d7e-4f80-9a1b-2c3d4e5f6a7b"`
	// ResolvedAt closes the violation; the row itself stays forever (Q58).
	ResolvedAt     *time.Time `json:"resolved_at" format:"date-time" example:"2026-09-07T06:00:00Z"`
	ResolvedReason *string    `json:"resolved_reason" example:"daily rest completed"`
	CreatedAt      time.Time  `json:"created_at" format:"date-time" example:"2026-09-06T17:00:05Z"`
}

// ViolationEnvelope wraps one violation.
type ViolationEnvelope struct {
	Data Violation `json:"data"`
}

// ViolationListEnvelope is the paginated violation list.
type ViolationListEnvelope struct {
	Data []Violation `json:"data"`
	Meta Meta        `json:"meta"`
}

// ---------------------------------------------------------------- inspection

// InspectionSession is the short lived, read only roadside token (Q54).
type InspectionSession struct {
	Token string `json:"token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	// ExpiresAt bounds the inspector's read window.
	ExpiresAt  time.Time `json:"expires_at" format:"date-time" example:"2026-09-06T20:00:00Z"`
	DriverID   string    `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	DriverName string    `json:"driver_name" example:"Ali Karimov"`
}

// InspectionSessionEnvelope wraps the roadside token.
type InspectionSessionEnvelope struct {
	Data InspectionSession `json:"data"`
}

// InspectionReport is the 7 days + today roadside view (Q53).
type InspectionReport struct {
	DriverID            string  `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	DriverName          string  `json:"driver_name" example:"Ali Karimov"`
	CarrierName         string  `json:"carrier_name" example:"ONEBOOK Logistics"`
	HomeTerminalAddress *string `json:"home_terminal_address" example:"1200 Industrial Rd, Dallas, TX"`
	Timezone            string  `json:"timezone" example:"America/Chicago"`
	// RegulationProfile decides the transfer format (Q56).
	RegulationProfile string           `json:"regulation_profile" example:"generic" enums:"us_fmcsa,generic,canada,texas,california,alaska,hawaii"`
	From              string           `json:"from" format:"date" example:"2026-08-30"`
	To                string           `json:"to" format:"date" example:"2026-09-06"`
	GeneratedAt       time.Time        `json:"generated_at" format:"date-time" example:"2026-09-06T18:00:00Z"`
	Days              []DailyLogDetail `json:"days"`
}

// InspectionReportEnvelope wraps the roadside view.
type InspectionReportEnvelope struct {
	Data InspectionReport `json:"data"`
}

// InspectionEmail sends the PDF of the roadside window (Q55).
type InspectionEmail struct {
	Email   string  `json:"email" example:"inspector@dot.gov" validate:"required,email,max=255"`
	Comment *string `json:"comment" example:"Roadside check, I-35 mile 220" validate:"omitempty,max=500"`
	// DriverID is required for an admin caller; a driver always sends its own.
	DriverID *string `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b" validate:"omitempty,uuid4"`
	// Date anchors the 7 days + today window; defaults to today.
	Date *string `json:"date" format:"date" example:"2026-09-06" validate:"omitempty,datetime=2006-01-02"`
}

// InspectionTransfer builds the regulator output file (Q56).
type InspectionTransfer struct {
	Comment  *string `json:"comment" example:"Roadside check, I-35 mile 220" validate:"omitempty,max=500"`
	DriverID *string `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b" validate:"omitempty,uuid4"`
	Date     *string `json:"date" format:"date" example:"2026-09-06" validate:"omitempty,datetime=2006-01-02"`
}

// InspectionTransferResult reports the produced output file.
type InspectionTransferResult struct {
	// FileKey is the object storage key of the produced archive.
	FileKey string `json:"file_key" example:"companies/6f1a/inspection/2026/09/eld-output.zip"`
	Format  string `json:"format" example:"csv_pdf_zip" enums:"csv_pdf_zip,fmcsa_eld_output"`
	// SizeBytes is the archive size.
	SizeBytes int64 `json:"size_bytes" example:"48213"`
	// RegulationProfile is the company profile that selected the format.
	RegulationProfile string    `json:"regulation_profile" example:"generic" enums:"us_fmcsa,generic,canada,texas,california,alaska,hawaii"`
	GeneratedAt       time.Time `json:"generated_at" format:"date-time" example:"2026-09-06T18:00:00Z"`
}

// InspectionTransferEnvelope wraps the transfer result.
type InspectionTransferEnvelope struct {
	Data InspectionTransferResult `json:"data"`
}

// MessageEnvelope acknowledges an action that returns no resource.
type MessageEnvelope struct {
	Data shared.MessageResponse `json:"data"`
}
