package sync

import (
	"strings"
	"time"
	"unicode/utf8"
)

// Fault is a single validation failure: the field that is wrong and the reason
// to report for it.
type Fault struct {
	Field  string
	Reason string
}

// ok is the zero Fault.
var ok = Fault{}

// failed reports whether f describes a failure.
func (f Fault) failed() bool { return f.Reason != "" }

// invalid builds an invalid_payload fault for field.
func invalid(field string) Fault { return Fault{Field: field, Reason: ReasonInvalidPayload} }

// ValidStatus reports whether s is one of the four duty statuses.
func ValidStatus(s string) bool {
	switch s {
	case StatusOff, StatusSB, StatusDrive, StatusOn:
		return true
	}
	return false
}

// ValidSpecial reports whether sp is a known special mode. Empty means none.
func ValidSpecial(sp string) bool {
	switch sp {
	case "", SpecialNone, SpecialPC, SpecialYM:
		return true
	}
	return false
}

// ValidEventType reports whether t is a storable event_type. `status_change` is
// accepted as the wire alias of `duty_status`.
func ValidEventType(t string) bool { return NormalizeEventType(t) != "" }

// NormalizeEventType maps the wire event type onto the stored enum, returning
// "" for an unknown kind.
func NormalizeEventType(t string) string {
	switch t {
	case EventDutyStatus, EventStatusChange:
		return EventDutyStatus
	case EventIntermediate, EventLogin, EventLogout, EventPowerOn, EventPowerOff,
		EventEngineOn, EventEngineOff, EventMalfunction, EventDiagnostic,
		EventCertification, EventYardMoves, EventPersonalUse:
		return t
	}
	return ""
}

// ValidOrigin reports whether o is a storable origin. Empty defaults to auto.
func ValidOrigin(o string) bool {
	switch o {
	case "", OriginAuto, OriginDriver, OriginDriverEdit, OriginAdminEdit,
		OriginAssigned, OriginManualNoELD:
		return true
	}
	return false
}

// ValidDeviceOrigin reports whether o is an origin a device may assert on
// /sync/push.
//
// `driver_edit`, `admin_edit` and `assigned` are written by the server alone —
// by the log edit approval path and by the unidentified driving hand over. A
// device that could claim them would forge the FMCSA record's provenance and,
// because neither is `auto`, escape the Q17.1 DR_IMMUTABLE guard on the
// driving time it uploaded (`assigned` also slips past the Q4 "DR is never
// picked by hand" rejection, which only knows the manual origins).
func ValidDeviceOrigin(o string) bool {
	switch o {
	case "", OriginAuto, OriginDriver, OriginManualNoELD:
		return true
	}
	return false
}

// IsUUID reports whether s is a canonical lowercase-or-uppercase UUID string.
// The rule layer cannot import a uuid package (stdlib only), and the domain
// layer parses the value again, so a shape check is enough here.
func IsUUID(s string) bool {
	if len(s) != 36 {
		return false
	}
	for i := 0; i < 36; i++ {
		c := s[i]
		if i == 8 || i == 13 || i == 18 || i == 23 {
			if c != '-' {
				return false
			}
			continue
		}
		if !isHex(c) {
			return false
		}
	}
	return true
}

func isHex(c byte) bool {
	return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
}

// validateEventEnums checks the closed-vocabulary fields: type, special,
// origin, status (conditionally required) and time_source.
func validateEventEnums(e Event, kind string) Fault {
	if !ValidSpecial(e.Special) {
		return invalid("special")
	}
	if !ValidDeviceOrigin(e.Origin) {
		return invalid("origin")
	}
	// A duty status change must name the status; the positional kinds may.
	if kind == EventDutyStatus {
		if !ValidStatus(e.Status) {
			return invalid("status")
		}
	} else if e.Status != "" && !ValidStatus(e.Status) {
		return invalid("status")
	}
	if e.TimeSource != "" && !ValidTimeSource(e.TimeSource) {
		return invalid("time_source")
	}
	return ok
}

// validateEventMeasurements checks the numeric telemetry-ish fields carried
// on an event: gps accuracy, odometer, engine hours, speed and coordinates.
func validateEventMeasurements(e Event) Fault {
	if f := validCoords(e.Lat, e.Lng); f.failed() {
		return f
	}
	if e.GPSAccuracyM != nil && *e.GPSAccuracyM < 0 {
		return invalid("gps_accuracy_m")
	}
	if e.OdometerM != nil && *e.OdometerM < 0 {
		return invalid("odometer_m")
	}
	if e.EngineHours != nil && *e.EngineHours < 0 {
		return invalid("engine_hours")
	}
	if e.SpeedKmh != nil && (*e.SpeedKmh < 0 || *e.SpeedKmh > 400) {
		return invalid("speed_kmh")
	}
	return ok
}

// validateEventReferences checks the UUID-shaped reference fields: trailers,
// shipping docs, unit and ELD device.
func validateEventReferences(e Event) Fault {
	if f := validIDs("trailer_ids", e.TrailerIDs); f.failed() {
		return f
	}
	if f := validIDs("shipping_doc_ids", e.ShippingDocIDs); f.failed() {
		return f
	}
	if e.UnitID != "" && !IsUUID(e.UnitID) {
		return invalid("unit_id")
	}
	if e.ELDDeviceID != "" && !IsUUID(e.ELDDeviceID) {
		return invalid("eld_device_id")
	}
	return ok
}

// ValidateEvent checks one incoming event against the required fields, the
// enums and the event_time bounds. now is the server instant.
//
// The order matters: a payload fault is reported before a time fault, so a
// malformed event never masquerades as a clock problem.
func ValidateEvent(e Event, now time.Time) Fault {
	if !IsUUID(e.ClientEventID) {
		return invalid("client_event_id")
	}
	kind := NormalizeEventType(e.EventType)
	if kind == "" {
		return invalid("event_type")
	}
	if f := validateEventEnums(e, kind); f.failed() {
		return f
	}
	if e.EventTime.IsZero() {
		return invalid("event_time")
	}
	if e.DeviceSeq != nil && *e.DeviceSeq < 0 {
		return invalid("device_seq")
	}
	if utf8.RuneCountInString(e.Notes) > MaxNotesLen {
		return invalid("notes")
	}
	if f := validateEventMeasurements(e); f.failed() {
		return f
	}
	if f := validateEventReferences(e); f.failed() {
		return f
	}
	return CheckEventTime(e.EventTime, now)
}

// CheckEventTime enforces the event_time window: rule 3 refuses anything more
// than FutureSkew ahead of the server, and an event older than MaxPastAge is
// outside the supported offline window.
func CheckEventTime(t, now time.Time) Fault {
	if t.After(now.Add(FutureSkew)) {
		return Fault{Field: "event_time", Reason: ReasonTimeInFuture}
	}
	if t.Before(now.Add(-MaxPastAge)) {
		return Fault{Field: "event_time", Reason: ReasonTimeOutOfRange}
	}
	return ok
}

func validCoords(lat, lng *float64) Fault {
	if lat != nil && (*lat < -90 || *lat > 90) {
		return invalid("lat")
	}
	if lng != nil && (*lng < -180 || *lng > 180) {
		return invalid("lng")
	}
	return ok
}

func validIDs(field string, ids []string) Fault {
	for _, id := range ids {
		if !IsUUID(id) {
			return invalid(field)
		}
	}
	return ok
}

// ValidateBatch enforces the four batch ceilings. It returns the first breach,
// so the caller answers one 422 BATCH_TOO_LARGE.
func ValidateBatch(b Batch) error {
	switch {
	case len(b.Events) > MaxEvents:
		return ErrTooManyEvents
	case len(b.Telemetry) > MaxTelemetryPoints:
		return ErrTooManyTelemetry
	case b.DvirCount > MaxDvir:
		return ErrTooManyDvir
	case b.ChatCount > MaxChat:
		return ErrTooManyChat
	}
	return nil
}

// NormalizeEvent applies the storage defaults: the stored event_type spelling,
// `none` for an absent special mode, `auto` for an absent origin, the batch
// time source when the event does not name one, and a trimmed note.
func NormalizeEvent(e Event, in Integrity) Event {
	e.EventType = NormalizeEventType(e.EventType)
	if e.Special == "" {
		e.Special = SpecialNone
	}
	if e.Origin == "" {
		e.Origin = OriginAuto
	}
	e.TimeSource, e.TimeUnverified, e.ClockSkewSec = EventIntegrity(e, in)
	e.Notes = strings.TrimSpace(e.Notes)
	return e
}
