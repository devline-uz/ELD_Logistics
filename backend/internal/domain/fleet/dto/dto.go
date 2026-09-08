// Package dto holds the fleet module request and response payloads (units,
// ELD devices, trailers and shipping documents). sqlc models never leave the
// repository layer; everything a client sees is defined here and carries an
// example tag for the generated Swagger document.
//
// Units are metric on the wire: distance is metres (`odometer_m`), speed is
// km/h. No unit conversion happens in the backend.
package dto

import (
	"time"

	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared envelopes re-exported so swagger annotations can reference dto.X.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// MessageResponse is a generic acknowledgement payload.
	MessageResponse = shared.MessageResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
)

// Fuel types accepted by units.fuel_type.
const (
	FuelDiesel   = "diesel"
	FuelPetrol   = "petrol"
	FuelCNG      = "cng"
	FuelLPG      = "lpg"
	FuelElectric = "electric"
	FuelHybrid   = "hybrid"
)

// Activity statuses shared by units and ELD devices (TZ §2).
const (
	StatusActive   = "active"
	StatusInactive = "inactive"
)

// Assignment roles of unit_driver_assignments.
const (
	RolePrimary  = "primary"
	RoleCoDriver = "co"
)

// Unit is one vehicle of the fleet.
type Unit struct {
	ID           string  `json:"id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber   string  `json:"unit_number" example:"1021"`
	Make         string  `json:"make" example:"Freightliner"`
	Model        string  `json:"model" example:"Cascadia"`
	Year         *int32  `json:"year" example:"2021"`
	VIN          string  `json:"vin" example:"1FUJGLDR9CLBP8834"`
	LicensePlate string  `json:"license_plate" example:"AA123BB"`
	PlateRegion  string  `json:"plate_region" example:"TX"`
	FuelType     string  `json:"fuel_type" example:"diesel" enums:"diesel,petrol,cng,lpg,electric,hybrid"`
	SleeperBerth bool    `json:"sleeper_berth" example:"true"`
	GVWRClass    string  `json:"gvwr_class" example:"class_8"`
	Status       string  `json:"status" example:"active" enums:"active,inactive"`
	OutOfService bool    `json:"out_of_service" example:"false"`
	Notes        string  `json:"notes" example:"Winter tyres fitted"`
	BranchID     *string `json:"branch_id" example:"2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f"`
	BranchName   string  `json:"branch_name" example:"Dallas terminal"`
	// EldDeviceID is the ELD currently wired to this unit, null when none.
	EldDeviceID     *string `json:"eld_device_id" example:"9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f"`
	EldDeviceSerial string  `json:"eld_device_serial" example:"ELD-000123"`
	// OdometerM is the last telemetry odometer reading in metres, null when the
	// unit has never reported. The backend never converts units.
	OdometerM   *int64     `json:"odometer_m" example:"128430000"`
	TelemetryAt *time.Time `json:"telemetry_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	ActivatedOn *time.Time `json:"activated_on" format:"date-time" example:"2026-01-14T09:00:00Z"`
	CreatedAt   time.Time  `json:"created_at" format:"date-time" example:"2026-01-14T09:00:00Z"`
	UpdatedAt   time.Time  `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// UnitCreate is the POST /units payload. Q18.1 — unit_number, make, model,
// license_plate and fuel_type are mandatory; VIN and the ELD device are not.
type UnitCreate struct {
	UnitNumber   string  `json:"unit_number" example:"1021" validate:"required,max=32"`
	Make         string  `json:"make" example:"Freightliner" validate:"required,max=64"`
	Model        string  `json:"model" example:"Cascadia" validate:"required,max=64"`
	LicensePlate string  `json:"license_plate" example:"AA123BB" validate:"required,max=32"`
	FuelType     string  `json:"fuel_type" example:"diesel" enums:"diesel,petrol,cng,lpg,electric,hybrid" validate:"required,oneof=diesel petrol cng lpg electric hybrid"`
	Year         *int32  `json:"year" example:"2021" validate:"omitempty,gte=1900,lte=2100"`
	VIN          string  `json:"vin" example:"1FUJGLDR9CLBP8834" validate:"omitempty,len=17"`
	PlateRegion  string  `json:"plate_region" example:"TX" validate:"omitempty,max=32"`
	SleeperBerth bool    `json:"sleeper_berth" example:"true"`
	GVWRClass    string  `json:"gvwr_class" example:"class_8" validate:"omitempty,max=32"`
	Notes        string  `json:"notes" example:"Winter tyres fitted" validate:"omitempty,max=60"`
	BranchID     *string `json:"branch_id" example:"2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f" validate:"omitempty,uuid4"`
	EldDeviceID  *string `json:"eld_device_id" example:"9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f" validate:"omitempty,uuid4"`
}

// UnitUpdate is the PATCH /units/{id} payload; every field is optional and a
// nil pointer leaves the column untouched.
type UnitUpdate struct {
	UnitNumber   *string `json:"unit_number" example:"1021" validate:"omitempty,max=32"`
	Make         *string `json:"make" example:"Freightliner" validate:"omitempty,max=64"`
	Model        *string `json:"model" example:"Cascadia" validate:"omitempty,max=64"`
	LicensePlate *string `json:"license_plate" example:"AA123BB" validate:"omitempty,max=32"`
	FuelType     *string `json:"fuel_type" example:"diesel" enums:"diesel,petrol,cng,lpg,electric,hybrid" validate:"omitempty,oneof=diesel petrol cng lpg electric hybrid"`
	Year         *int32  `json:"year" example:"2021" validate:"omitempty,gte=1900,lte=2100"`
	VIN          *string `json:"vin" example:"1FUJGLDR9CLBP8834" validate:"omitempty,len=17"`
	PlateRegion  *string `json:"plate_region" example:"TX" validate:"omitempty,max=32"`
	SleeperBerth *bool   `json:"sleeper_berth" example:"true"`
	GVWRClass    *string `json:"gvwr_class" example:"class_8" validate:"omitempty,max=32"`
	Notes        *string `json:"notes" example:"Winter tyres fitted" validate:"omitempty,max=60"`
	OutOfService *bool   `json:"out_of_service" example:"false"`
	BranchID     *string `json:"branch_id" example:"2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f" validate:"omitempty,uuid4"`
}

// UnitAssignDriver links a driver to a unit (unit_driver_assignments).
type UnitAssignDriver struct {
	DriverID string `json:"driver_id" example:"4a2b3c4d-5e6f-4a1b-8c2d-3e4f5a6b7c8d" validate:"required,uuid4"`
	Role     string `json:"role" example:"primary" enums:"primary,co" validate:"required,oneof=primary co"`
}

// UnitAssignment is one row of the unit ↔ driver assignment history.
type UnitAssignment struct {
	ID           string     `json:"id" example:"1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f"`
	UnitID       string     `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	DriverID     string     `json:"driver_id" example:"4a2b3c4d-5e6f-4a1b-8c2d-3e4f5a6b7c8d"`
	DriverName   string     `json:"driver_name" example:"John Doe"`
	Role         string     `json:"role" example:"primary" enums:"primary,co"`
	AssignedAt   time.Time  `json:"assigned_at" format:"date-time" example:"2026-09-01T06:00:00Z"`
	UnassignedAt *time.Time `json:"unassigned_at" format:"date-time" example:"2026-09-05T18:30:00Z"`
}

// ELD connectivity states shown to an administrator (TZ §10.1).
const (
	// ConnOnline means telemetry arrived within the last five minutes.
	ConnOnline = "online"
	// ConnOffline means the last telemetry is older than five minutes.
	ConnOffline = "offline"
	// ConnDisconnected means the device reported the phone link is down.
	ConnDisconnected = "disconnected"
	// ConnMalfunction means at least one malfunction code is raised.
	ConnMalfunction = "malfunction"
	// ConnNoDevice means the unit has no ELD wired to it.
	ConnNoDevice = "no_device"
)

// UnitDiagnostics is the GET /units/{id}/diagnostics payload (TZ §10.1, §10.5).
type UnitDiagnostics struct {
	UnitID     string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber string `json:"unit_number" example:"1021"`
	// ConnectionState is the administrator facing device state.
	ConnectionState string  `json:"connection_state" example:"online" enums:"online,offline,disconnected,malfunction,no_device"`
	DeviceID        *string `json:"device_id" example:"9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f"`
	DeviceSerial    string  `json:"device_serial" example:"ELD-000123"`
	DeviceVendor    string  `json:"device_vendor" example:"Geotab"`
	DeviceModel     string  `json:"device_model" example:"GO9"`
	DeviceFirmware  string  `json:"device_firmware" example:"4.12.1"`
	ConnectionType  string  `json:"connection_type" example:"bluetooth" enums:"bluetooth,wifi,cellular,usb"`
	SimPresent      bool    `json:"sim_present" example:"true"`
	DeviceStatus    string  `json:"device_status" example:"active" enums:"active,inactive,malfunction"`
	// MalfunctionCodes are FMCSA Appendix A letters: P power, E engine sync,
	// T timing, L positioning, R data recording, S data transfer, O other.
	MalfunctionCodes []MalfunctionCode `json:"malfunction_codes"`
	LastSeenAt       *time.Time        `json:"last_seen_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	TelemetryAt      *time.Time        `json:"telemetry_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	Telemetry        UnitTelemetry     `json:"telemetry"`
}

// MalfunctionCode is one raised FMCSA diagnostic letter with its meaning.
type MalfunctionCode struct {
	Code        string `json:"code" example:"E" enums:"P,E,T,L,R,S,O"`
	Description string `json:"description" example:"engine synchronization"`
}

// UnitTelemetry carries the last raw reading of a unit. Distance is metres and
// speed is km/h — no conversion happens server side.
type UnitTelemetry struct {
	OdometerM       *int64   `json:"odometer_m" example:"128430000"`
	EngineHours     *float64 `json:"engine_hours" example:"14320.75"`
	FuelPct         *float64 `json:"fuel_pct" example:"62.5"`
	CoolantTempC    *float64 `json:"coolant_temp_c" example:"88.4"`
	CoolantLevelPct *float64 `json:"coolant_level_pct" example:"91.2"`
	OilLevelPct     *float64 `json:"oil_level_pct" example:"78"`
	BatteryPct      *float64 `json:"battery_pct" example:"96.5"`
	BatteryVoltageV *float64 `json:"battery_voltage_v" example:"13.8"`
}

// UnitHistoryEntry is one audited change or assignment of a unit.
type UnitHistoryEntry struct {
	// Kind separates the two sources merged into one timeline.
	Kind      string    `json:"kind" example:"audit" enums:"audit,assignment"`
	ID        string    `json:"id" example:"1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f"`
	At        time.Time `json:"at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	Action    string    `json:"action" example:"update" enums:"create,update,delete,restore,assign"`
	Field     string    `json:"field" example:"status"`
	OldValue  string    `json:"old_value" example:"\"active\""`
	NewValue  string    `json:"new_value" example:"\"inactive\""`
	ActorID   *string   `json:"actor_id" example:"7c9f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f"`
	ActorName string    `json:"actor_name" example:"Jane Admin"`
}

// Envelopes.

// UnitEnvelope wraps a single unit.
type UnitEnvelope struct {
	Data Unit `json:"data"`
}

// UnitListEnvelope wraps a page of units.
type UnitListEnvelope struct {
	Data []Unit `json:"data"`
	Meta Meta   `json:"meta"`
}

// UnitAssignmentEnvelope wraps one driver assignment.
type UnitAssignmentEnvelope struct {
	Data UnitAssignment `json:"data"`
}

// UnitDiagnosticsEnvelope wraps the diagnostics payload.
type UnitDiagnosticsEnvelope struct {
	Data UnitDiagnostics `json:"data"`
}

// UnitHistoryEnvelope wraps a page of history entries.
type UnitHistoryEnvelope struct {
	Data []UnitHistoryEntry `json:"data"`
	Meta Meta               `json:"meta"`
}
