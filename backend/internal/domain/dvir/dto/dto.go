// Package dto holds the DVIR module payloads: reports, defects, the repair and
// certification actions and the company defect type catalogue.
//
// Distances are metres (`_m`), engine hours are decimal hours and every
// timestamp is ISO 8601 UTC. Time, location and odometer are captured by the
// server from telemetry (Q28), never trusted from the request body.
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

// DVIR types (TZ §7.1).
const (
	TypePreTrip  = "pre_trip"
	TypePostTrip = "post_trip"
)

// DVIR statuses (TZ §7.2 state machine).
const (
	// StatusDraft only ever reaches the server through the paper import path;
	// the mobile app keeps its local `in_progress` and submits a final state.
	StatusDraft = "draft"
	// StatusSubmittedNoDefects is the terminal state of a clean inspection.
	StatusSubmittedNoDefects = "submitted_no_defects"
	// StatusSubmittedDefectsFound waits for the Service Manager.
	StatusSubmittedDefectsFound = "submitted_defects_found"
	// StatusRepaired waits for the driver's "Previous defects repaired?" signature.
	StatusRepaired = "repaired"
	// StatusCertified is the terminal state of a defect flow.
	StatusCertified = "certified"
	// StatusClosedNoCertification is the Q30.1 fallback outcome.
	StatusClosedNoCertification = "closed_no_certification"
)

// Derived mobile labels (TZ §7.3).
const (
	KindNoDefects          = "no_defects"
	KindDefectsNotFixed    = "defects_not_fixed"
	KindDefectsFixed       = "defects_fixed"
	KindDefectsUncertified = "defects_uncertified"
)

// Defect type categories.
const (
	CategoryTruck   = "truck"
	CategoryTrailer = "trailer"
)

// Report sources.
const (
	SourceApp         = "app"
	SourcePaperImport = "paper_import"
)

// MaxDefectPhotos is the Q27.1 ceiling of photos attached to one defect.
const MaxDefectPhotos = 5

// ---------------------------------------------------------------- requests

// DefectInput is one reported defect. `defect_type_id` must belong to the
// company catalogue or to the system defaults.
type DefectInput struct {
	DefectTypeID string `json:"defect_type_id" example:"7f2c1b3d-4e5a-4b6c-8d9e-0f1a2b3c4d5e" validate:"required,uuid4"`
	Note         string `json:"note" example:"Left front tyre below tread limit" validate:"max=1000"`
	// PhotoKeys are object storage keys produced by POST /files/presign
	// (kind `dvir_photo`). At most five per defect (Q27.1).
	PhotoKeys []string `json:"photo_keys" example:"c1/dvir_photo/2026/09/06/abc.jpg" validate:"max=5,dive,max=512"`
}

// DvirCreate is the mobile POST /dvir-reports payload. Q28: time, location and
// odometer are read from telemetry, so the body carries none of them.
type DvirCreate struct {
	UnitID string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f" validate:"required,uuid4"`
	// Type is the pre/post trip toggle of the mobile form.
	Type string `json:"type" example:"pre_trip" enums:"pre_trip,post_trip" validate:"required,oneof=pre_trip post_trip"`
	// TrailerIDs are the trailers inspected together with the unit.
	TrailerIDs []string `json:"trailer_ids" example:"9b8a7c6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d" validate:"max=10,dive,uuid4"`
	// Defects is empty for a clean inspection (`submitted_no_defects`).
	Defects []DefectInput `json:"defects" validate:"max=100,dive"`
	// DriverSignatureKey is the storage key of the driver signature image.
	DriverSignatureKey string `json:"driver_signature_key" example:"c1/signature/2026/09/06/sig.png" validate:"required,max=512"`
	// Notes is the free text remark of the inspection.
	Notes string `json:"notes" example:"Checked at the Dallas yard" validate:"max=2000"`
}

// DvirRepair is the POST /dvir-reports/{id}/repair payload (Q27 — the mechanic
// signature exists only on the "defects fixed" transition).
type DvirRepair struct {
	MechanicNote         string `json:"mechanic_note" example:"Replaced left front tyre" validate:"required,max=2000"`
	MechanicSignatureKey string `json:"mechanic_signature_key" example:"c1/signature/2026/09/06/mech.png" validate:"required,max=512"`
	// InvoiceKey is the optional repair invoice (kind `invoice`).
	InvoiceKey string `json:"invoice_key" example:"c1/invoice/2026/09/06/inv.pdf" validate:"max=512"`
	// InvoiceNo, Vendor and Cost are optional bookkeeping of the repair.
	InvoiceNo string   `json:"invoice_no" example:"INV-10233" validate:"max=64"`
	Vendor    string   `json:"vendor" example:"Dallas Truck Service" validate:"max=200"`
	Cost      *float64 `json:"cost" example:"420.5" validate:"omitempty,gte=0"`
}

// DvirCertify is the POST /dvir-reports/{id}/certify payload: the driver's
// "Previous defects repaired?" signature.
type DvirCertify struct {
	SignatureKey string `json:"signature_key" example:"c1/signature/2026/09/07/sig.png" validate:"required,max=512"`
}

// DefectTypeCreate is the POST /defect-types payload.
type DefectTypeCreate struct {
	Name       string `json:"name" example:"Brakes (Service)" validate:"required,max=120"`
	Category   string `json:"category" example:"truck" enums:"truck,trailer" validate:"required,oneof=truck trailer"`
	IsCritical bool   `json:"is_critical" example:"true"`
	IsActive   bool   `json:"is_active" example:"true"`
	SortOrder  int32  `json:"sort_order" example:"8" validate:"gte=0,lte=10000"`
}

// DefectTypeUpdate is the PATCH /defect-types/{id} payload; nil fields are left
// untouched.
type DefectTypeUpdate struct {
	Name       *string `json:"name" example:"Brakes (Service)" validate:"omitempty,max=120"`
	Category   *string `json:"category" example:"truck" enums:"truck,trailer" validate:"omitempty,oneof=truck trailer"`
	IsCritical *bool   `json:"is_critical" example:"true"`
	IsActive   *bool   `json:"is_active" example:"false"`
	SortOrder  *int32  `json:"sort_order" example:"8" validate:"omitempty,gte=0,lte=10000"`
}

// ---------------------------------------------------------------- responses

// Defect is one stored defect of a report.
type Defect struct {
	DefectTypeID string   `json:"defect_type_id" example:"7f2c1b3d-4e5a-4b6c-8d9e-0f1a2b3c4d5e"`
	Name         string   `json:"name" example:"Tires"`
	Category     string   `json:"category" example:"truck" enums:"truck,trailer"`
	IsCritical   bool     `json:"is_critical" example:"true"`
	Note         string   `json:"note" example:"Left front tyre below tread limit"`
	PhotoKeys    []string `json:"photo_keys" example:"c1/dvir_photo/2026/09/06/abc.jpg"`
}

// DriverBrief identifies the driver who signed the report.
type DriverBrief struct {
	ID        string `json:"id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	FirstName string `json:"first_name" example:"John"`
	LastName  string `json:"last_name" example:"Doe"`
}

// DvirReport is one inspection report.
type DvirReport struct {
	ID         string `json:"id" example:"1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d"`
	UnitID     string `json:"unit_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	UnitNumber string `json:"unit_number" example:"1021"`
	// OutOfService mirrors units.out_of_service after the Q27.2 evaluation.
	OutOfService bool         `json:"out_of_service" example:"false"`
	Driver       *DriverBrief `json:"driver"`
	Type         string       `json:"type" example:"pre_trip" enums:"pre_trip,post_trip"`
	Status       string       `json:"status" example:"submitted_defects_found" enums:"draft,submitted_no_defects,submitted_defects_found,repaired,certified,closed_no_certification"`
	// Kind is the derived mobile label of TZ §7.3.
	Kind       string   `json:"kind" example:"defects_not_fixed" enums:"no_defects,defects_not_fixed,defects_fixed,defects_uncertified"`
	TrailerIDs []string `json:"trailer_ids" example:"9b8a7c6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d"`
	Defects    []Defect `json:"defects"`
	// HasCriticalDefect is true when at least one defect is `is_critical`.
	HasCriticalDefect bool `json:"has_critical_defect" example:"true"`

	Lat          *float64 `json:"lat" example:"31.52"`
	Lng          *float64 `json:"lng" example:"74.35"`
	LocationText string   `json:"location_text" example:"3 mi NE of Dallas, TX"`
	OdometerM    *int64   `json:"odometer_m" example:"128430000"`
	EngineHours  *float64 `json:"engine_hours" example:"1234.5"`

	DriverSignatureKey        string  `json:"driver_signature_key" example:"c1/signature/2026/09/06/sig.png"`
	MechanicID                *string `json:"mechanic_id" example:"4c5d6e7f-8a9b-4c0d-9e1f-2a3b4c5d6e7f"`
	MechanicNote              string  `json:"mechanic_note" example:"Replaced left front tyre"`
	MechanicSignatureKey      string  `json:"mechanic_signature_key" example:"c1/signature/2026/09/06/mech.png"`
	CertificationSignatureKey string  `json:"certification_signature_key" example:"c1/signature/2026/09/07/sig.png"`

	RepairedAt        *time.Time `json:"repaired_at" format:"date-time" example:"2026-09-06T15:04:05Z"`
	CertifiedAt       *time.Time `json:"certified_at" format:"date-time" example:"2026-09-07T06:10:00Z"`
	CertifiedByDriver *string    `json:"certified_by_driver_id" example:"3b0e1f2a-5c6d-4e7f-8a9b-0c1d2e3f4a5b"`
	ClosedAt          *time.Time `json:"closed_at" format:"date-time" example:"2026-09-14T00:00:00Z"`
	ClosedReason      string     `json:"closed_reason" example:"no follow-up DVIR within 7 days"`
	Source            string     `json:"source" example:"app" enums:"app,paper_import"`
	PerformedAt       time.Time  `json:"performed_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	CreatedAt         time.Time  `json:"created_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	UpdatedAt         time.Time  `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// DefectType is one entry of the inspection catalogue.
type DefectType struct {
	ID         string `json:"id" example:"7f2c1b3d-4e5a-4b6c-8d9e-0f1a2b3c4d5e"`
	Name       string `json:"name" example:"Brakes (Service)"`
	Category   string `json:"category" example:"truck" enums:"truck,trailer"`
	IsCritical bool   `json:"is_critical" example:"true"`
	IsActive   bool   `json:"is_active" example:"true"`
	SortOrder  int32  `json:"sort_order" example:"8"`
	// IsSystem marks a default catalogue row (company_id IS NULL); it is
	// readable by every tenant but only editable as a company copy.
	IsSystem  bool      `json:"is_system" example:"true"`
	CreatedAt time.Time `json:"created_at" format:"date-time" example:"2026-01-01T00:00:00Z"`
	UpdatedAt time.Time `json:"updated_at" format:"date-time" example:"2026-01-01T00:00:00Z"`
}

// ---------------------------------------------------------------- envelopes

// DvirReportEnvelope wraps one report.
type DvirReportEnvelope struct {
	Data DvirReport `json:"data"`
}

// DvirReportListEnvelope wraps a page of reports.
type DvirReportListEnvelope struct {
	Data []DvirReport `json:"data"`
	Meta Meta         `json:"meta"`
}

// DefectTypeEnvelope wraps one catalogue entry.
type DefectTypeEnvelope struct {
	Data DefectType `json:"data"`
}

// DefectTypeListEnvelope wraps a page of catalogue entries.
type DefectTypeListEnvelope struct {
	Data []DefectType `json:"data"`
	Meta Meta         `json:"meta"`
}
