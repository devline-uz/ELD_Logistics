// Package sync implements the offline sync rule layer (TZ D§2, B§1).
//
// The package is pure: stdlib only, no DB/HTTP, no global state and it never
// calls time.Now — the server instant is always a parameter. The same rules are
// ported to Dart for the offline mobile client, so every decision made here has
// to be reproducible from the batch alone plus the small Lookup callbacks the
// caller supplies.
package sync

import (
	"errors"
	"time"
)

// Batch ceilings (eld-sync skill). A larger batch is refused as a whole.
const (
	// MaxEvents is the duty-status event ceiling of one /sync/push.
	MaxEvents = 500
	// MaxTelemetryPoints is the telemetry ceiling of one /sync/push.
	MaxTelemetryPoints = 5000
	// MaxDvir and MaxChat bound the two batches handed to stages 5-6.
	MaxDvir = 100
	MaxChat = 500
)

// Time integrity thresholds (Q-B1.2).
const (
	// FutureSkew is how far ahead of the server an event may be stamped
	// before it is refused (conflict rule 3).
	FutureSkew = 5 * time.Minute
	// MaxPastAge bounds how old an offline event may be. The mobile client
	// keeps 14 days locally (Q-B1.3); a much wider window is accepted so a
	// long-parked device can still drain, but not an arbitrary one.
	MaxPastAge = 90 * 24 * time.Hour
	// WarnSkew is the |phone - reference| difference that raises a driver
	// warning and is stored in clock_skew_sec.
	WarnSkew = 2 * time.Minute
	// MalfunctionSkew is the FMCSA "timing compliance" malfunction threshold.
	MalfunctionSkew = 10 * time.Minute
)

// MalfunctionTiming is the FMCSA Appendix A letter of a timing compliance
// malfunction (>10 minutes of clock drift).
const MalfunctionTiming = "T"

// Time sources, in priority order (Q-B1.2).
const (
	TimeSourceELDRTC = "eld_rtc"
	TimeSourceServer = "server"
	TimeSourcePhone  = "phone"
)

// TimeSourceRank returns the conflict priority of a time source:
// eld_rtc > server > phone. An unknown source ranks below all of them.
func TimeSourceRank(src string) int {
	switch src {
	case TimeSourceELDRTC:
		return 3
	case TimeSourceServer:
		return 2
	case TimeSourcePhone:
		return 1
	default:
		return 0
	}
}

// ValidTimeSource reports whether src is one of the three known sources.
func ValidTimeSource(src string) bool { return TimeSourceRank(src) > 0 }

// Duty statuses (Q4). Mirrors internal/hos and the duty_status_events CHECK.
const (
	StatusOff   = "OFF"
	StatusSB    = "SB"
	StatusDrive = "DR"
	StatusOn    = "ON"
)

// Special modes layered on OFF/ON (Q4.1, Q4.2).
const (
	SpecialNone = "none"
	SpecialPC   = "pc"
	SpecialYM   = "ym"
)

// Event kinds accepted by duty_status_events.event_type. `status_change` is
// accepted as the wire alias of `duty_status` because the protocol document
// (TZ D§2) uses that spelling.
const (
	EventDutyStatus    = "duty_status"
	EventStatusChange  = "status_change"
	EventIntermediate  = "intermediate"
	EventLogin         = "login"
	EventLogout        = "logout"
	EventPowerOn       = "power_on"
	EventPowerOff      = "power_off"
	EventEngineOn      = "engine_on"
	EventEngineOff     = "engine_off"
	EventMalfunction   = "malfunction"
	EventDiagnostic    = "diagnostic"
	EventCertification = "certification"
	EventYardMoves     = "yard_moves"
	EventPersonalUse   = "personal_use"
)

// Origins accepted by duty_status_events.origin.
const (
	OriginAuto        = "auto"
	OriginDriver      = "driver"
	OriginDriverEdit  = "driver_edit"
	OriginAdminEdit   = "admin_edit"
	OriginAssigned    = "assigned"
	OriginManualNoELD = "manual_no_eld"
)

// Per-element results of /sync/push.
const (
	ResultAccepted  = "accepted"
	ResultDuplicate = "duplicate"
	ResultRejected  = "rejected"
)

// Rejection and annotation reasons carried next to a result.
const (
	// ReasonTimeInFuture — conflict rule 3.
	ReasonTimeInFuture = "time_in_future"
	// ReasonTimeOutOfRange — the event predates the accepted offline window.
	ReasonTimeOutOfRange = "time_out_of_range"
	// ReasonLogLocked — conflict rule 5, the day is certified.
	ReasonLogLocked = "log_locked"
	// ReasonInvalidPayload — a required field is missing or out of its enum.
	ReasonInvalidPayload = "invalid_payload"
	// ReasonSuperseded annotates an accepted event that lost conflict rule 1;
	// it is stored with superseded_by pointing at the winner.
	ReasonSuperseded = "superseded"
)

// MaxNotesLen is the status-change note ceiling (Q7).
const MaxNotesLen = 60

// Clock is the device clock snapshot sent with every push (Q-B1.2). A zero
// ELDRTC means no ELD was connected when the batch was assembled.
type Clock struct {
	Phone  time.Time
	ELDRTC time.Time
}

// Event is one incoming duty_status_events row, before any server decision.
// Pointers mark signals the device may legitimately not have.
type Event struct {
	ClientEventID string
	EventType     string
	Status        string
	Special       string
	Origin        string
	EventTime     time.Time
	TimeSource    string
	DeviceSeq     *int64
	// TimeUnverified and ClockSkewSec are filled in by NormalizeEvent from
	// the batch clock verdict; the device never sets them.
	TimeUnverified bool
	ClockSkewSec   int

	Lat          *float64
	Lng          *float64
	GPSAccuracyM *int32
	LocationText string
	OdometerM    *int64
	EngineHours  *float64
	// SpeedKmh is the speed observed at EventTime. It drives the server side
	// auto-DR and yard-move exit checks (Q5, Q4.2).
	SpeedKmh *float64

	Notes          string
	TrailerIDs     []string
	ShippingDocIDs []string
	UnitID         string
	ELDDeviceID    string
}

// TelemetryPoint is one telemetry sample of the same batch. Only the fields the
// rule layer needs to validate and de-duplicate are modelled here; the full
// sample is carried by the domain DTO.
type TelemetryPoint struct {
	TS       time.Time
	Lat      *float64
	Lng      *float64
	SpeedKmh *float64
}

// Batch is one /sync/push payload as the rule layer sees it.
type Batch struct {
	DeviceID   string
	AppVersion string
	Clock      Clock
	Events     []Event
	Telemetry  []TelemetryPoint
	DvirCount  int
	ChatCount  int
}

// Candidate is the minimal shape of a duty status event competing for the same
// (driver, event_time) slot — either already stored or newly arrived.
type Candidate struct {
	// ID is the stored duty_status_events.id; empty for the incoming event.
	ID string
	// ClientEventID identifies the event across devices.
	ClientEventID string
	EventTime     time.Time
	TimeSource    string
	DeviceSeq     *int64
	ReceivedAt    time.Time
}

// Decision is the outcome of one incoming event.
type Decision struct {
	ClientEventID string
	// Result is accepted, duplicate or rejected.
	Result string
	// Reason is set on a rejection and on an accepted-but-superseded event.
	Reason string
	// Field names the offending field of an invalid_payload rejection.
	Field string
	// SupersededBy is the client_event_id of the winner when this event lost
	// conflict rule 1; the event is still stored (never dropped).
	SupersededBy string
	// SupersededByID is the stored id of that winner, which is what the
	// loser's superseded_by column is set to.
	SupersededByID string
	// Supersedes lists the stored duty_status_events.id values this event
	// wins over; the caller stamps superseded_by on each of them.
	Supersedes []string
}

// Accepted reports whether the event has to be written to storage. A superseded
// event is still written — conflict rule 1 keeps the loser.
func (d Decision) Accepted() bool { return d.Result == ResultAccepted }

// Integrity is the batch level time-integrity verdict (Q-B1.2).
type Integrity struct {
	// Source is the reference used when an event does not name its own.
	Source string
	// SkewSec is |phone - reference| in seconds, stored on every event.
	SkewSec int
	// Unverified marks a batch whose only clock is the phone.
	Unverified bool
	// Warn is true above WarnSkew: the driver has to be told.
	Warn bool
	// Malfunction is true above MalfunctionSkew: a `timing` malfunction.
	Malfunction bool
}

// MalfunctionCode returns the FMCSA Appendix A letter to raise, or "".
func (i Integrity) MalfunctionCode() string {
	if i.Malfunction {
		return MalfunctionTiming
	}
	return ""
}

// TelemetryPlan is the telemetry half of a planned batch.
type TelemetryPlan struct {
	// Points are the samples to write, de-duplicated by ts and ordered.
	Points []TelemetryPoint
	// Duplicate counts samples dropped inside the batch (rule 4: ignore).
	Duplicate int
	// Rejected counts samples with an unusable timestamp.
	Rejected int
}

// Plan is the full decision set of one push, ready to be executed by the
// domain layer.
type Plan struct {
	Integrity Integrity
	Events    []Decision
	// Normalized carries the events to write, aligned with Events by index.
	// A rejected entry has a zero Event.
	Normalized []Event
	Telemetry  TelemetryPlan
}

// Lookup supplies the three pieces of stored state the rule layer cannot know
// on its own. Every field is optional: a nil callback means "nothing stored",
// which is what a fresh driver looks like.
type Lookup struct {
	// Known reports whether client_event_id was already stored (idempotency).
	Known func(clientEventID string) bool
	// DayLocked reports whether the log day covering t is certified (rule 5).
	DayLocked func(t time.Time) bool
	// Existing returns the stored events occupying the same instant as t,
	// excluding the incoming client_event_id (rule 1).
	Existing func(t time.Time) []Candidate
}

// Batch errors. They abort the whole push instead of producing decisions.
var (
	ErrTooManyEvents    = errors.New("sync: batch exceeds 500 events")
	ErrTooManyTelemetry = errors.New("sync: batch exceeds 5000 telemetry points")
	ErrTooManyDvir      = errors.New("sync: batch exceeds 100 dvir reports")
	ErrTooManyChat      = errors.New("sync: batch exceeds 500 chat messages")
)
