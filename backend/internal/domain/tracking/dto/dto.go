// Package dto holds the tracking module payloads: the live map, trip history,
// trip detail and the unidentified driving buffer.
//
// Units are raw on the wire: distance is metres (`_m`), speed is km/h, and all
// timestamps are ISO 8601 UTC. The backend performs no unit conversion; the
// only place a company timezone is applied is the day boundary of
// GET /units/{id}/trips.
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

// ELD states shown on the admin live map (TZ §10.1).
const (
	// OnlineStatusOnline means telemetry arrived within the last five minutes.
	OnlineStatusOnline = "online"
	// OnlineStatusOffline means the last state is known but stale.
	OnlineStatusOffline = "offline"
	// OnlineStatusDisconnected means the ELD reported losing the phone link.
	OnlineStatusDisconnected = "disconnected"
	// OnlineStatusMalfunction means the wired ELD carries an active FMCSA
	// Appendix A code; it wins over the connectivity state.
	OnlineStatusMalfunction = "malfunction"
)

// Unidentified driving statuses (TZ A§10.4).
const (
	UnidentifiedPending   = "pending"
	UnidentifiedAssigned  = "assigned"
	UnidentifiedAnnotated = "annotated"
)

// DriverBrief identifies the driver behind the wheel.
type DriverBrief struct {
	ID        string `json:"id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	FirstName string `json:"first_name" example:"John"`
	LastName  string `json:"last_name" example:"Doe"`
}

// LiveUnit is one row of the live tracking map.
type LiveUnit struct {
	UnitID     string  `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber string  `json:"unit_number" example:"1021"`
	BranchID   *string `json:"branch_id" example:"2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f"`
	BranchName string  `json:"branch_name" example:"Dallas terminal"`
	// OnlineStatus is Online / Offline / Disconnected / Malfunction (TZ §10.1).
	OnlineStatus string `json:"online_status" example:"online" enums:"online,offline,disconnected,malfunction"`
	// OutOfService mirrors units.out_of_service.
	OutOfService bool `json:"out_of_service" example:"false"`

	// LastSeenAt is the timestamp of the last telemetry sample, null when the
	// unit has never reported.
	LastSeenAt  *time.Time `json:"last_seen_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	Lat         *float64   `json:"lat" example:"31.52"`
	Lng         *float64   `json:"lng" example:"74.35"`
	SpeedKmh    *float64   `json:"speed_kmh" example:"62.5"`
	HeadingDeg  *float64   `json:"heading_deg" example:"180"`
	OdometerM   *int64     `json:"odometer_m" example:"128430000"`
	EngineHours *float64   `json:"engine_hours" example:"1234.5"`

	// DutyStatus is the HOS status of the driver at the wheel.
	DutyStatus string       `json:"duty_status" example:"DR" enums:"OFF,SB,DR,ON"`
	Driver     *DriverBrief `json:"driver"`

	EldDeviceID      *string  `json:"eld_device_id" example:"9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f"`
	EldDeviceSerial  string   `json:"eld_device_serial" example:"ELD-000123"`
	MalfunctionCodes []string `json:"malfunction_codes" example:"T,L"`
}

// LiveUnitListEnvelope is the GET /tracking/live response.
type LiveUnitListEnvelope struct {
	Data []LiveUnit `json:"data"`
	Meta Meta       `json:"meta"`
}

// Trip is one drive segment (TZ §13 Q64/Q65).
type Trip struct {
	ID         string `json:"id" example:"1d2c3b4a-5e6f-4708-8192-a3b4c5d6e7f8"`
	UnitID     string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber string `json:"unit_number" example:"1021"`

	StartAt time.Time  `json:"start_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	EndAt   *time.Time `json:"end_at" format:"date-time" example:"2026-09-06T07:44:00Z"`

	StartLat *float64 `json:"start_lat" example:"31.52"`
	StartLng *float64 `json:"start_lng" example:"74.35"`
	EndLat   *float64 `json:"end_lat" example:"31.98"`
	EndLng   *float64 `json:"end_lng" example:"74.91"`

	// DistanceM is metres; DurationSec is seconds; MaxSpeedKmh is km/h.
	DistanceM   int64    `json:"distance_m" example:"152300"`
	DurationSec *int32   `json:"duration_sec" example:"9120"`
	MaxSpeedKmh *float64 `json:"max_speed_kmh" example:"104.2"`

	Driver *DriverBrief `json:"driver"`
	// Open is true while the trip has no end yet.
	Open bool `json:"open" example:"false"`
}

// TripDetail adds the track of a trip.
type TripDetail struct {
	Trip
	// PolylineKey is the object storage key of the stored track, null when the
	// trip was never closed or the upload failed.
	PolylineKey *string `json:"polyline_key" example:"6f1a1a5e/trips/2026/09/9d1c0f4e.polyline"`
	// Polyline is the Google encoded polyline (precision 5) rebuilt from the
	// telemetry of the trip window. Empty when include_polyline=false or when
	// the samples fell outside the retention window.
	Polyline string `json:"polyline" example:"_p~iF~ps|U_ulLnnqC"`
	// PointCount is how many fixes the polyline was built from.
	PointCount int `json:"point_count" example:"412"`
}

// TripEnvelope is the GET /trips/{id} response.
type TripEnvelope struct {
	Data TripDetail `json:"data"`
}

// TripListEnvelope is the GET /units/{id}/trips response.
type TripListEnvelope struct {
	Data []Trip `json:"data"`
	Meta Meta   `json:"meta"`
}

// UnidentifiedEvent is one buffered driver-less driving interval (TZ A§10.4).
type UnidentifiedEvent struct {
	ID         string `json:"id" example:"7c8d9e0f-1a2b-4c3d-8e4f-5a6b7c8d9e0f"`
	UnitID     string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber string `json:"unit_number" example:"1021"`

	StartAt time.Time  `json:"start_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	EndAt   *time.Time `json:"end_at" format:"date-time" example:"2026-09-06T05:31:00Z"`
	// DistanceM is metres driven without an identified driver.
	DistanceM int64 `json:"distance_m" example:"8400"`
	// TrackKey is the object storage key of the recorded track.
	TrackKey *string `json:"track_key" example:"6f1a1a5e/unidentified/2026/09/2b7c4d1a.polyline"`

	Status string `json:"status" example:"pending" enums:"pending,assigned,annotated"`
	// AssignedDriverID is set once an admin assignment or a driver claim
	// resolved the event.
	AssignedDriverID *string    `json:"assigned_driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	Annotation       string     `json:"annotation" example:"Workshop test drive"`
	ResolvedAt       *time.Time `json:"resolved_at" format:"date-time" example:"2026-09-08T09:00:00Z"`
	// PendingDays is how long the event has been unresolved; beyond 8 days it
	// raises an admin alert (TZ A§10.4).
	PendingDays int       `json:"pending_days" example:"3"`
	CreatedAt   time.Time `json:"created_at" format:"date-time" example:"2026-09-06T05:31:04Z"`
}

// UnidentifiedEventListEnvelope is the GET /unidentified-events response.
type UnidentifiedEventListEnvelope struct {
	Data []UnidentifiedEvent `json:"data"`
	Meta Meta                `json:"meta"`
}
