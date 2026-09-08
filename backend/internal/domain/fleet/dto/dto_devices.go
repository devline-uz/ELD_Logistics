package dto

import "time"

// ELD device connection types accepted by eld_devices.connection_type.
const (
	ConnBluetooth = "bluetooth"
	ConnWifi      = "wifi"
	ConnCellular  = "cellular"
	ConnUSB       = "usb"
)

// EldDevice is one ELD hardware unit registered by the company.
type EldDevice struct {
	ID             string  `json:"id" example:"9c3f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f"`
	Vendor         string  `json:"vendor" example:"Geotab"`
	Model          string  `json:"model" example:"GO9"`
	Serial         string  `json:"serial" example:"ELD-000123"`
	Firmware       string  `json:"firmware" example:"4.12.1"`
	ConnectionType string  `json:"connection_type" example:"bluetooth" enums:"bluetooth,wifi,cellular,usb"`
	SimPresent     bool    `json:"sim_present" example:"true"`
	Status         string  `json:"status" example:"active" enums:"active,inactive,malfunction"`
	Notes          string  `json:"notes" example:"Spare unit"`
	UnitID         *string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber     string  `json:"unit_number" example:"1021"`
	// MalfunctionCodes are the raised FMCSA Appendix A letters (P/E/T/L/R/S/O).
	MalfunctionCodes []string   `json:"malfunction_codes" example:"E,L"`
	LastSeenAt       *time.Time `json:"last_seen_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	CreatedAt        time.Time  `json:"created_at" format:"date-time" example:"2026-01-14T09:00:00Z"`
	UpdatedAt        time.Time  `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// EldDeviceCreate is the POST /eld-devices payload.
type EldDeviceCreate struct {
	Vendor         string  `json:"vendor" example:"Geotab" validate:"required,max=64"`
	Serial         string  `json:"serial" example:"ELD-000123" validate:"required,max=64"`
	Model          string  `json:"model" example:"GO9" validate:"omitempty,max=64"`
	Firmware       string  `json:"firmware" example:"4.12.1" validate:"omitempty,max=32"`
	ConnectionType string  `json:"connection_type" example:"bluetooth" enums:"bluetooth,wifi,cellular,usb" validate:"omitempty,oneof=bluetooth wifi cellular usb"`
	SimPresent     bool    `json:"sim_present" example:"true"`
	Status         string  `json:"status" example:"active" enums:"active,inactive,malfunction" validate:"omitempty,oneof=active inactive malfunction"`
	Notes          string  `json:"notes" example:"Spare unit" validate:"omitempty,max=60"`
	UnitID         *string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f" validate:"omitempty,uuid4"`
}

// EldDeviceUpdate is the PATCH /eld-devices/{id} payload.
type EldDeviceUpdate struct {
	Vendor         *string `json:"vendor" example:"Geotab" validate:"omitempty,max=64"`
	Serial         *string `json:"serial" example:"ELD-000123" validate:"omitempty,max=64"`
	Model          *string `json:"model" example:"GO9" validate:"omitempty,max=64"`
	Firmware       *string `json:"firmware" example:"4.12.1" validate:"omitempty,max=32"`
	ConnectionType *string `json:"connection_type" example:"bluetooth" enums:"bluetooth,wifi,cellular,usb" validate:"omitempty,oneof=bluetooth wifi cellular usb"`
	SimPresent     *bool   `json:"sim_present" example:"true"`
	Status         *string `json:"status" example:"active" enums:"active,inactive,malfunction" validate:"omitempty,oneof=active inactive malfunction"`
	Notes          *string `json:"notes" example:"Spare unit" validate:"omitempty,max=60"`
}

// EldDeviceAssignUnit wires a device to a unit (eld_device_assignments).
type EldDeviceAssignUnit struct {
	// UnitID is null to detach the device from its current unit.
	UnitID *string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f" validate:"omitempty,uuid4"`
}

// Trailer is a towed unit referenced by logs and DVIR reports.
type Trailer struct {
	ID        string    `json:"id" example:"5b6c7d8e-9f0a-4b1c-8d2e-3f4a5b6c7d8e"`
	Number    string    `json:"number" example:"TR-4410"`
	Notes     string    `json:"notes" example:"Reefer"`
	CreatedAt time.Time `json:"created_at" format:"date-time" example:"2026-01-14T09:00:00Z"`
	UpdatedAt time.Time `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// ShippingDocument is a bill of lading / manifest number.
type ShippingDocument struct {
	ID        string    `json:"id" example:"8e9f0a1b-2c3d-4e5f-8a9b-0c1d2e3f4a5b"`
	Number    string    `json:"number" example:"BOL-99127"`
	Notes     string    `json:"notes" example:"Cold chain"`
	CreatedAt time.Time `json:"created_at" format:"date-time" example:"2026-01-14T09:00:00Z"`
	UpdatedAt time.Time `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// CatalogCreate is the create payload shared by trailers and shipping
// documents: both are number + notes only.
type CatalogCreate struct {
	Number string `json:"number" example:"TR-4410" validate:"required,max=32"`
	Notes  string `json:"notes" example:"Reefer" validate:"omitempty,max=60"`
}

// CatalogUpdate is the partial update shared by trailers and shipping
// documents.
type CatalogUpdate struct {
	Number *string `json:"number" example:"TR-4410" validate:"omitempty,max=32"`
	Notes  *string `json:"notes" example:"Reefer" validate:"omitempty,max=60"`
}

// Envelopes.

// EldDeviceEnvelope wraps a single ELD device.
type EldDeviceEnvelope struct {
	Data EldDevice `json:"data"`
}

// EldDeviceListEnvelope wraps a page of ELD devices.
type EldDeviceListEnvelope struct {
	Data []EldDevice `json:"data"`
	Meta Meta        `json:"meta"`
}

// TrailerEnvelope wraps a single trailer.
type TrailerEnvelope struct {
	Data Trailer `json:"data"`
}

// TrailerListEnvelope wraps a page of trailers.
type TrailerListEnvelope struct {
	Data []Trailer `json:"data"`
	Meta Meta      `json:"meta"`
}

// ShippingDocumentEnvelope wraps a single shipping document.
type ShippingDocumentEnvelope struct {
	Data ShippingDocument `json:"data"`
}

// ShippingDocumentListEnvelope wraps a page of shipping documents.
type ShippingDocumentListEnvelope struct {
	Data []ShippingDocument `json:"data"`
	Meta Meta               `json:"meta"`
}
