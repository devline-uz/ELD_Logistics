// Package dto holds the telemetry ingestion payloads. Ingestion has no public
// HTTP surface of its own: /sync/push and the device gateway call the service
// with these types, so they are documented and validated exactly like a
// request body would be.
//
// Units are raw: distance in metres (`_m`), speed in km/h, temperature in
// Celsius, voltage in volts, time in UTC. The backend never converts.
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

// MaxBatchPoints is the ingestion batch ceiling (eld-sync skill: ≤5000 points).
// A larger batch answers 422 BATCH_TOO_LARGE.
const MaxBatchPoints = 5000

// Telemetry sources accepted by telemetry.source.
const (
	SourceELD       = "eld"
	SourcePhone     = "phone"
	SourceSimulator = "simulator"
)

// Point is one telemetry sample. Every optional signal is a pointer so an
// unreported value stays NULL instead of collapsing into a zero reading.
type Point struct {
	TS         time.Time `json:"ts" format:"date-time" example:"2026-09-06T05:12:00Z" validate:"required"`
	Lat        *float64  `json:"lat" example:"31.52" validate:"omitempty,gte=-90,lte=90"`
	Lng        *float64  `json:"lng" example:"74.35" validate:"omitempty,gte=-180,lte=180"`
	SpeedKmh   *float64  `json:"speed_kmh" example:"62.5" validate:"omitempty,gte=0,lte=400"`
	HeadingDeg *float64  `json:"heading_deg" example:"180" validate:"omitempty,gte=0,lt=360"`
	// OdometerM is the ECM total distance in metres.
	OdometerM *int64 `json:"odometer_m" example:"128430000" validate:"omitempty,gte=0"`
	// EngineHours is the ECM total engine time in hours.
	EngineHours     *float64 `json:"engine_hours" example:"1234.5" validate:"omitempty,gte=0"`
	FuelPct         *float64 `json:"fuel_pct" example:"74" validate:"omitempty,gte=0,lte=100"`
	CoolantTempC    *float64 `json:"coolant_temp_c" example:"88"`
	CoolantLevelPct *float64 `json:"coolant_level_pct" example:"92" validate:"omitempty,gte=0,lte=100"`
	OilLevelPct     *float64 `json:"oil_level_pct" example:"60" validate:"omitempty,gte=0,lte=100"`
	BatteryPct      *float64 `json:"battery_pct" example:"87" validate:"omitempty,gte=0,lte=100"`
	BatteryVoltageV *float64 `json:"battery_voltage_v" example:"13.8" validate:"omitempty,gte=0,lte=60"`
	Ignition        *bool    `json:"ignition" example:"true"`
	// DriverID is null for unidentified driving (TZ A§10.4); the sample then
	// opens or extends an unidentified_events buffer entry.
	DriverID *string `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b" validate:"omitempty,uuid4"`
	// DutyStatus is the duty status in force at TS, when known.
	DutyStatus string `json:"duty_status" example:"DR" enums:"OFF,SB,DR,ON" validate:"omitempty,oneof=OFF SB DR ON"`
	// Diagnostics are the FMCSA Appendix A letters active at TS (TZ §10.5).
	// Send an empty array to clear the stored codes; omit the field to leave
	// them untouched.
	Diagnostics []string `json:"diagnostics" example:"T,L" validate:"omitempty,dive,oneof=P E T L R S O"`
	// Disconnected marks the sample the ELD sends when it loses the link to the
	// phone (TZ §10.1 "Disconnected").
	Disconnected bool `json:"disconnected" example:"false"`
}

// Batch is one unit's telemetry upload.
type Batch struct {
	UnitID string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f" validate:"required,uuid4"`
	// DeviceID is the reporting eld_devices row; when omitted the unit's
	// currently wired device is used.
	DeviceID *string `json:"device_id" example:"9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f" validate:"omitempty,uuid4"`
	// Firmware, when present, refreshes eld_devices.firmware.
	Firmware string  `json:"firmware" example:"1.4.2" validate:"omitempty,max=32"`
	Source   string  `json:"source" example:"eld" enums:"eld,phone,simulator" validate:"omitempty,oneof=eld phone simulator"`
	Points   []Point `json:"points" validate:"required,min=1,max=5000,dive"`
}

// Result is the ingestion outcome. Duplicates are not an error: `(unit_id, ts)`
// is the telemetry primary key and repeats are silently ignored.
type Result struct {
	Accepted  int   `json:"accepted" example:"120"`
	Duplicate int   `json:"duplicate" example:"3"`
	DistanceM int64 `json:"distance_m" example:"12400"`

	TripsOpened int `json:"trips_opened" example:"1"`
	TripsClosed int `json:"trips_closed" example:"1"`

	UnidentifiedOpened int `json:"unidentified_opened" example:"0"`
	UnidentifiedClosed int `json:"unidentified_closed" example:"0"`

	OnlineStatus string     `json:"online_status" example:"online" enums:"online,idle,offline,disconnected"`
	LastSeenAt   *time.Time `json:"last_seen_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// LastState is the cached `unit:last:<unit_id>` value (Redis, TTL 10 minutes)
// and the payload pushed to the WebSocket `tracking` channel.
type LastState struct {
	UnitID       string     `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	TS           time.Time  `json:"ts" format:"date-time" example:"2026-09-06T05:12:00Z"`
	Lat          *float64   `json:"lat" example:"31.52"`
	Lng          *float64   `json:"lng" example:"74.35"`
	SpeedKmh     *float64   `json:"speed_kmh" example:"62.5"`
	HeadingDeg   *float64   `json:"heading_deg" example:"180"`
	OdometerM    *int64     `json:"odometer_m" example:"128430000"`
	EngineHours  *float64   `json:"engine_hours" example:"1234.5"`
	DutyStatus   string     `json:"duty_status" example:"DR" enums:"OFF,SB,DR,ON"`
	DriverID     *string    `json:"driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	OnlineStatus string     `json:"online_status" example:"online" enums:"online,idle,offline,disconnected"`
	UpdatedAt    *time.Time `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:03Z"`
}
