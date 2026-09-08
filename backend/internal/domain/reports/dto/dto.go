// Package dto holds the reporting payloads (TZ §14).
//
// Two reports answer live because their data is pre-aggregated: the activity
// report reads odometer extremes straight from telemetry, and Distance by
// Region reads the daily `unit_region_distance_daily` roll-up, so the quarter
// is ready the moment it is asked for. Everything heavy — the regulator
// export, the HOS and DVIR bundles, and the file versions of the two live
// reports — goes through an asynchronous export job (Q75).
//
// Distances are metres (`_m`), durations are seconds and every timestamp is
// ISO 8601 UTC. Dates are `YYYY-MM-DD` in the company timezone.
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

// Export job types (TZ §14).
const (
	// TypeDistanceByRegion is the IFTA style quarterly distance report.
	TypeDistanceByRegion = "distance_by_region"
	// TypeRegulator is the roadside/regulator bundle.
	TypeRegulator = "regulator"
	// TypeActivity is the odometer activity report.
	TypeActivity = "activity"
	// TypeHOS is the per driver daily hours of service summary.
	TypeHOS = "hos"
	// TypeDVIR is the filtered DVIR list.
	TypeDVIR = "dvir"
)

// Types lists every accepted export job type.
var Types = []string{TypeDistanceByRegion, TypeRegulator, TypeActivity, TypeHOS, TypeDVIR}

// Export formats.
const (
	FormatCSV  = "csv"
	FormatXLSX = "xlsx"
	FormatPDF  = "pdf"
	// FormatZIP is the regulator bundle: a PDF and a CSV in one archive.
	FormatZIP = "zip"
)

// Formats lists every accepted export format.
var Formats = []string{FormatCSV, FormatXLSX, FormatPDF, FormatZIP}

// Export job statuses.
const (
	StatusQueued  = "queued"
	StatusRunning = "running"
	StatusDone    = "done"
	StatusFailed  = "failed"
)

// Activity report subjects.
const (
	SubjectDrivers = "drivers"
	SubjectUnits   = "units"
)

// Subjects lists every accepted activity report subject.
var Subjects = []string{SubjectDrivers, SubjectUnits}

// Distance by Region modes.
const (
	// ModeRegionsAndUnits breaks the distance down per unit inside each region.
	ModeRegionsAndUnits = "regions_and_units"
	// ModeRegionsOnly returns one row per region.
	ModeRegionsOnly = "regions_only"
)

// Modes lists every accepted Distance by Region mode.
var Modes = []string{ModeRegionsAndUnits, ModeRegionsOnly}

// DownloadTTL is how long a finished export stays downloadable (Q75).
const DownloadTTL = 24 * time.Hour

// ActivityRow is one line of the activity report.
type ActivityRow struct {
	// SubjectID is the driver or unit the row describes.
	SubjectID string `json:"subject_id" example:"2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8"`
	// SubjectType tells which of the two the row describes.
	SubjectType string `json:"subject_type" example:"units" enums:"drivers,units"`
	// Name is the unit number or the driver's display name.
	Name string `json:"name" example:"1021"`
	// StartOdometerM is the first odometer reading in the window, in metres.
	StartOdometerM int64 `json:"start_odometer_m" example:"128430000"`
	// EndOdometerM is the last odometer reading in the window, in metres.
	EndOdometerM int64 `json:"end_odometer_m" example:"129180000"`
	// OdometerChangeM is Q75: End − Start. It is zero when the window holds no
	// telemetry at all.
	OdometerChangeM int64 `json:"odometer_change_m" example:"750000"`
	// HasData is false when the subject reported nothing in the window, which
	// is why its odometer columns are zero.
	HasData bool `json:"has_data" example:"true"`
}

// RegionDistanceRow is one line of the Distance by Region report.
type RegionDistanceRow struct {
	// RegionCode is the jurisdiction code, e.g. "US-IL".
	RegionCode string `json:"region_code" example:"US-IL"`
	// RegionName is the jurisdiction name.
	RegionName string `json:"region_name" example:"Illinois"`
	// Country is the ISO 3166-1 alpha-2 country code.
	Country string `json:"country" example:"US"`
	// UnitID is set only in `regions_and_units` mode.
	UnitID string `json:"unit_id,omitempty" example:"2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8"`
	// UnitNumber is set only in `regions_and_units` mode.
	UnitNumber string `json:"unit_number,omitempty" example:"1021"`
	// DistanceM is the distance driven inside the region, in metres.
	DistanceM int64 `json:"distance_m" example:"412345"`
}

// DistanceByRegionMeta describes the period the report covers.
type DistanceByRegionMeta struct {
	// Quarter is the calendar quarter, 1 to 4.
	Quarter int `json:"quarter" example:"3"`
	// Year is the calendar year.
	Year int `json:"year" example:"2026"`
	// Mode is the breakdown that was requested.
	Mode string `json:"mode" example:"regions_and_units" enums:"regions_and_units,regions_only"`
	// From is the first day of the quarter.
	From string `json:"from" format:"date" example:"2026-07-01"`
	// To is the last day of the quarter.
	To string `json:"to" format:"date" example:"2026-09-30"`
	// TotalDistanceM is the sum of every row, in metres.
	TotalDistanceM int64 `json:"total_distance_m" example:"9184320"`
}

// HosSummaryRow is one driver-day of the HOS summary export.
type HosSummaryRow struct {
	// DriverID is the driver the day belongs to.
	DriverID string `json:"driver_id" example:"9b2f5c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d"`
	// DriverName is the driver's display name.
	DriverName string `json:"driver_name" example:"John Miller"`
	// LogDate is the log day in the home terminal timezone.
	LogDate string `json:"log_date" format:"date" example:"2026-09-06"`
	// DrivingSec, OnDutySec, SleeperSec and OffDutySec are the daily totals.
	DrivingSec int64 `json:"driving_sec" example:"32400"`
	OnDutySec  int64 `json:"on_duty_sec" example:"7200"`
	SleeperSec int64 `json:"sleeper_sec" example:"0"`
	OffDutySec int64 `json:"off_duty_sec" example:"46800"`
	// DistanceM is the distance driven that day, in metres.
	DistanceM int64 `json:"distance_m" example:"612000"`
	// CertificationStatus mirrors the daily log.
	CertificationStatus string `json:"certification_status" example:"certified" enums:"uncertified,certified,needs_recertify"`
	// Violations is the number of violations raised on that day.
	Violations int64 `json:"violations" example:"1"`
}

// ExportParams is the request specific part of an export job. Every field is
// optional; each job type reads the ones it needs.
type ExportParams struct {
	// From is the first day of the window (inclusive).
	From string `json:"from,omitempty" format:"date" example:"2026-09-01" validate:"omitempty,datetime=2006-01-02"`
	// To is the last day of the window (inclusive).
	To string `json:"to,omitempty" format:"date" example:"2026-09-30" validate:"omitempty,datetime=2006-01-02"`
	// Quarter selects the Distance by Region period.
	Quarter int `json:"quarter,omitempty" example:"3" validate:"omitempty,min=1,max=4"`
	// Year selects the Distance by Region period.
	Year int `json:"year,omitempty" example:"2026" validate:"omitempty,min=2000,max=2100"`
	// Mode is the Distance by Region breakdown.
	Mode string `json:"mode,omitempty" example:"regions_and_units" enums:"regions_and_units,regions_only" validate:"omitempty,oneof=regions_and_units regions_only"`
	// Subject is the activity report axis.
	Subject string `json:"subject,omitempty" example:"units" enums:"drivers,units" validate:"omitempty,oneof=drivers units"`
	// DriverIDs filters the export to these drivers.
	DriverIDs []string `json:"driver_ids,omitempty" example:"9b2f5c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d" validate:"omitempty,dive,uuid"`
	// UnitIDs filters the export to these units.
	UnitIDs []string `json:"unit_ids,omitempty" example:"2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8" validate:"omitempty,dive,uuid"`
	// Comment is the free text the regulator export carries on its cover page.
	Comment string `json:"comment,omitempty" example:"Roadside inspection, unit 1021" validate:"omitempty,max=1000"`
	// BranchID narrows the export to one branch. A `branch` scoped requester
	// never controls it: the server overwrites the field with the caller's own
	// branch before the job is stored (TZ A§16).
	BranchID string `json:"branch_id,omitempty" example:"b1f0c2d3-4e5f-6071-8293-a4b5c6d7e8f9" validate:"omitempty,uuid"`
}

// ExportJob is one asynchronous export.
type ExportJob struct {
	// ID is the job identifier.
	ID string `json:"id" example:"7c9e6679-7425-40de-944b-e07fc1f90ae7"`
	// Type is the report the job renders.
	Type string `json:"type" example:"distance_by_region" enums:"distance_by_region,regulator,activity,hos,dvir"`
	// Format is the requested output format.
	Format string `json:"format" example:"xlsx" enums:"csv,xlsx,pdf,zip"`
	// Status is the job state.
	Status string `json:"status" example:"done" enums:"queued,running,done,failed"`
	// Params echoes the request so the UI can label the download.
	Params ExportParams `json:"params"`
	// Error carries the failure reason on a failed job.
	Error string `json:"error,omitempty" example:"the map provider is unavailable"`
	// FileName is the suggested download file name.
	FileName string `json:"file_name,omitempty" example:"distance-by-region-2026-Q3.xlsx"`
	// FileSizeB is the rendered size in bytes.
	FileSizeB int64 `json:"file_size_b,omitempty" example:"20480"`
	// DownloadURL is a presigned link, valid until ExpiresAt. It is present
	// only while the job is `done` and inside its 24 hour window (Q75).
	DownloadURL string `json:"download_url,omitempty" example:"https://storage.example.com/onebook/…"`
	// ExpiresAt is when the download stops working.
	ExpiresAt *time.Time `json:"expires_at,omitempty" format:"date-time" example:"2026-09-07T05:12:00Z"`
	// RequestedBy is the user that asked for the export.
	RequestedBy string `json:"requested_by" example:"3a7b1c2d-4e5f-6071-8293-a4b5c6d7e8f9"`
	// CreatedAt is when the job was queued.
	CreatedAt time.Time `json:"created_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	// StartedAt is when a worker picked the job up.
	StartedAt *time.Time `json:"started_at,omitempty" format:"date-time" example:"2026-09-06T05:12:03Z"`
	// FinishedAt is when the job reached a terminal state.
	FinishedAt *time.Time `json:"finished_at,omitempty" format:"date-time" example:"2026-09-06T05:12:31Z"`
}

// ExportJobCreate is the POST /reports/export-jobs payload.
type ExportJobCreate struct {
	// Type is the report to render.
	Type string `json:"type" example:"distance_by_region" enums:"distance_by_region,regulator,activity,hos,dvir" validate:"required,oneof=distance_by_region regulator activity hos dvir"`
	// Format is the output format; it defaults per type when omitted.
	Format string `json:"format,omitempty" example:"xlsx" enums:"csv,xlsx,pdf,zip" validate:"omitempty,oneof=csv xlsx pdf zip"`
	// Params carries the report specific window and filters.
	Params ExportParams `json:"params"`
}

// ActivityListEnvelope wraps a page of activity rows.
type ActivityListEnvelope struct {
	// Data is the page of rows.
	Data []ActivityRow `json:"data"`
	// Meta carries the pagination counters.
	Meta Meta `json:"meta"`
}

// DistanceByRegionEnvelope wraps the Distance by Region report.
type DistanceByRegionEnvelope struct {
	// Data is the report body.
	Data []RegionDistanceRow `json:"data"`
	// Meta describes the period the report covers.
	Meta DistanceByRegionMeta `json:"meta"`
}

// ExportJobEnvelope wraps a single export job.
type ExportJobEnvelope struct {
	// Data is the job.
	Data ExportJob `json:"data"`
}

// ExportJobListEnvelope wraps a page of export jobs.
type ExportJobListEnvelope struct {
	// Data is the page of jobs.
	Data []ExportJob `json:"data"`
	// Meta carries the pagination counters.
	Meta Meta `json:"meta"`
}
