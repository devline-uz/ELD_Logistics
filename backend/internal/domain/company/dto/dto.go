// Package dto holds the request and response payloads of the tenant facing
// company module. sqlc models never leave the repository layer; every field a
// client sees is declared here with an example tag for the generated Swagger
// document.
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

// Settings is the free form company configuration stored in companies.settings.
type Settings struct {
	// QuickNotes are the note presets offered on the duty status form (Q1.3).
	QuickNotes []string `json:"quick_notes" example:"PTI,Hook,Pickup,Drop-off,Delivery"`
	// FuelTypes limits the values a unit may declare.
	FuelTypes []string `json:"fuel_types" example:"diesel,petrol,cng,lpg,electric,hybrid"`
	// DistanceRegionsSet selects the region catalogue used by the distance
	// report (Q0.1).
	DistanceRegionsSet string `json:"distance_regions_set" example:"us_states" enums:"us_states,pk_provinces,uz_regions,none"`
}

// Company is the tenant profile returned by GET /company.
type Company struct {
	ID                  string     `json:"id" example:"3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f"`
	Name                string     `json:"name" example:"Onebook Logistics LLC"`
	Address             string     `json:"address" example:"1200 Industrial Rd, Dallas, TX 75207"`
	HomeTerminalAddress string     `json:"home_terminal_address" example:"1200 Industrial Rd, Dallas, TX 75207"`
	Timezone            string     `json:"timezone" example:"America/Chicago"`
	Email               string     `json:"email" example:"ops@onebook.example"`
	Phone               string     `json:"phone" example:"+15125550143"`
	RegistrationNo      string     `json:"registration_no" example:"3928471"`
	LogoKey             string     `json:"logo_key" example:"companies/3f7c2d1a/logo.png"`
	Region              string     `json:"region" example:"US" enums:"PK,UZ,US,other"`
	UnitSystem          string     `json:"unit_system" example:"imperial" enums:"metric,imperial"`
	RegulationProfile   string     `json:"regulation_profile" example:"us_fmcsa" enums:"us_fmcsa,generic,canada,texas,california,alaska,hawaii"`
	SubscriptionStatus  string     `json:"subscription_status" example:"active" enums:"trial,active,grace,readonly"`
	SubscriptionEndAt   *time.Time `json:"subscription_end_at" format:"date-time" example:"2026-12-31T23:59:59Z"`
	Plan                string     `json:"plan" example:"fleet_50"`
	Settings            Settings   `json:"settings"`
	CreatedAt           time.Time  `json:"created_at" format:"date-time" example:"2026-01-14T09:30:00Z"`
	UpdatedAt           time.Time  `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// CompanyUpdate is the PATCH /company payload. Omitted fields are left alone.
type CompanyUpdate struct {
	Name                *string   `json:"name" example:"Onebook Logistics LLC" validate:"omitempty,min=2,max=160"`
	Address             *string   `json:"address" example:"1200 Industrial Rd, Dallas, TX 75207" validate:"omitempty,max=512"`
	HomeTerminalAddress *string   `json:"home_terminal_address" example:"1200 Industrial Rd, Dallas, TX 75207" validate:"omitempty,max=512"`
	Timezone            *string   `json:"timezone" example:"America/Chicago" validate:"omitempty,max=64"`
	Email               *string   `json:"email" example:"ops@onebook.example" validate:"omitempty,email,max=254"`
	Phone               *string   `json:"phone" example:"+15125550143" validate:"omitempty,max=32"`
	RegistrationNo      *string   `json:"registration_no" example:"3928471" validate:"omitempty,max=64"`
	LogoKey             *string   `json:"logo_key" example:"companies/3f7c2d1a/logo.png" validate:"omitempty,max=256"`
	Region              *string   `json:"region" example:"US" enums:"PK,UZ,US,other" validate:"omitempty,oneof=PK UZ US other"`
	UnitSystem          *string   `json:"unit_system" example:"imperial" enums:"metric,imperial" validate:"omitempty,oneof=metric imperial"`
	RegulationProfile   *string   `json:"regulation_profile" example:"us_fmcsa" enums:"us_fmcsa,generic,canada,texas,california,alaska,hawaii" validate:"omitempty,oneof=us_fmcsa generic canada texas california alaska hawaii"`
	Settings            *Settings `json:"settings"`
}

// Branch is one company location (Sub Admin scope target).
type Branch struct {
	ID        string    `json:"id" example:"9c1d5e7a-2b3c-4d5e-8f90-1a2b3c4d5e6f"`
	Name      string    `json:"name" example:"Dallas Terminal"`
	Address   string    `json:"address" example:"1200 Industrial Rd, Dallas, TX 75207"`
	Timezone  string    `json:"timezone" example:"America/Chicago"`
	CreatedAt time.Time `json:"created_at" format:"date-time" example:"2026-01-14T09:30:00Z"`
	UpdatedAt time.Time `json:"updated_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// BranchCreate is the POST /company/branches payload.
type BranchCreate struct {
	Name     string `json:"name" example:"Dallas Terminal" validate:"required,min=2,max=160"`
	Address  string `json:"address" example:"1200 Industrial Rd, Dallas, TX 75207" validate:"omitempty,max=512"`
	Timezone string `json:"timezone" example:"America/Chicago" validate:"omitempty,max=64"`
}

// BranchUpdate is the PATCH /company/branches/{id} payload.
type BranchUpdate struct {
	Name     *string `json:"name" example:"Dallas Terminal" validate:"omitempty,min=2,max=160"`
	Address  *string `json:"address" example:"1200 Industrial Rd, Dallas, TX 75207" validate:"omitempty,max=512"`
	Timezone *string `json:"timezone" example:"America/Chicago" validate:"omitempty,max=64"`
}

// WarningThresholds are the "remaining minutes" levels that raise a warning.
type WarningThresholds struct {
	Drive int `json:"drive" example:"30"`
	Shift int `json:"shift" example:"60"`
	Break int `json:"break" example:"30"`
	Cycle int `json:"cycle" example:"120"`
}

// WarningThresholdsInput is the partial form of WarningThresholds.
type WarningThresholdsInput struct {
	Drive *int `json:"drive" example:"30" validate:"omitempty,min=0,max=1440"`
	Shift *int `json:"shift" example:"60" validate:"omitempty,min=0,max=1440"`
	Break *int `json:"break" example:"30" validate:"omitempty,min=0,max=1440"`
	Cycle *int `json:"cycle" example:"120" validate:"omitempty,min=0,max=1440"`
}

// HosPolicyDoc is a fully resolved hos_policy document (TZ A§4.2). Every
// duration is in minutes, every speed in km/h.
type HosPolicyDoc struct {
	DriveLimitMin              int               `json:"drive_limit_min" example:"660"`
	ShiftWindowMin             int               `json:"shift_window_min" example:"840"`
	BreakRequiredAfterDriveMin int               `json:"break_required_after_drive_min" example:"480"`
	BreakDurationMin           int               `json:"break_duration_min" example:"30"`
	BreakQualifyingStatuses    []string          `json:"break_qualifying_statuses" example:"OFF,SB,ON" enums:"OFF,SB,ON,DR"`
	DailyRestMin               int               `json:"daily_rest_min" example:"600"`
	CycleLimitMin              int               `json:"cycle_limit_min" example:"4200"`
	CycleDays                  int               `json:"cycle_days" example:"8"`
	CycleRestartMin            *int              `json:"cycle_restart_min" example:"2040"`
	SleeperSplitEnabled        bool              `json:"sleeper_split_enabled" example:"true"`
	SleeperBerthAvailable      bool              `json:"sleeper_berth_available" example:"true"`
	AllowPC                    bool              `json:"allow_pc" example:"true"`
	AllowYM                    bool              `json:"allow_ym" example:"true"`
	YMMaxSpeedKmh              float64           `json:"ym_max_speed_kmh" example:"32"`
	MotionThresholdKmh         float64           `json:"motion_threshold_kmh" example:"8"`
	ShortHaulException         bool              `json:"short_haul_exception" example:"false"`
	AdverseConditionsExtMin    int               `json:"adverse_conditions_extension_min" example:"120"`
	WarningThresholds          WarningThresholds `json:"warning_thresholds"`
}

// HosPolicyDocInput is the partial form of HosPolicyDoc: omitted keys keep the
// value of the currently active version (Q10.1).
type HosPolicyDocInput struct {
	DriveLimitMin              *int                    `json:"drive_limit_min" example:"660" validate:"omitempty,min=60,max=1440"`
	ShiftWindowMin             *int                    `json:"shift_window_min" example:"840" validate:"omitempty,min=60,max=1440"`
	BreakRequiredAfterDriveMin *int                    `json:"break_required_after_drive_min" example:"480" validate:"omitempty,min=30,max=1440"`
	BreakDurationMin           *int                    `json:"break_duration_min" example:"30" validate:"omitempty,min=5,max=480"`
	BreakQualifyingStatuses    []string                `json:"break_qualifying_statuses" example:"OFF,SB,ON" enums:"OFF,SB,ON,DR" validate:"omitempty,max=4,dive,oneof=OFF SB ON DR"`
	DailyRestMin               *int                    `json:"daily_rest_min" example:"600" validate:"omitempty,min=60,max=1440"`
	CycleLimitMin              *int                    `json:"cycle_limit_min" example:"4200" validate:"omitempty,min=600,max=20160"`
	CycleDays                  *int                    `json:"cycle_days" example:"8" validate:"omitempty,min=1,max=14"`
	CycleRestartMin            *int                    `json:"cycle_restart_min" example:"2040" validate:"omitempty,min=0,max=10080"`
	SleeperSplitEnabled        *bool                   `json:"sleeper_split_enabled" example:"true"`
	SleeperBerthAvailable      *bool                   `json:"sleeper_berth_available" example:"true"`
	AllowPC                    *bool                   `json:"allow_pc" example:"true"`
	AllowYM                    *bool                   `json:"allow_ym" example:"true"`
	YMMaxSpeedKmh              *float64                `json:"ym_max_speed_kmh" example:"32" validate:"omitempty,min=0,max=80"`
	MotionThresholdKmh         *float64                `json:"motion_threshold_kmh" example:"8" validate:"omitempty,min=0,max=50"`
	ShortHaulException         *bool                   `json:"short_haul_exception" example:"false"`
	AdverseConditionsExtMin    *int                    `json:"adverse_conditions_extension_min" example:"120" validate:"omitempty,min=0,max=480"`
	WarningThresholds          *WarningThresholdsInput `json:"warning_thresholds"`
}

// HosPolicy is one hos_policy_versions row.
type HosPolicy struct {
	ID            string       `json:"id" example:"5b2e8f10-7c3d-4a1b-9e6f-2c3d4e5f6a7b"`
	EffectiveFrom time.Time    `json:"effective_from" format:"date-time" example:"2026-10-01T00:00:00Z"`
	CreatedBy     *string      `json:"created_by" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	CreatedAt     time.Time    `json:"created_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	Policy        HosPolicyDoc `json:"policy"`
}

// HosPolicyCreate publishes a new policy version (Q10.1). Existing days keep
// being evaluated with the version that was effective back then.
type HosPolicyCreate struct {
	// EffectiveFrom must not be in the past: retroactive violations are
	// forbidden. Omitted means "now".
	EffectiveFrom *time.Time        `json:"effective_from" format:"date-time" example:"2026-10-01T00:00:00Z"`
	Policy        HosPolicyDocInput `json:"policy" validate:"required"`
}

// NotificationSetting is the delivery configuration of one alert type (A§19).
type NotificationSetting struct {
	AlertType      string   `json:"alert_type" example:"hos_violation" enums:"hos_warning,hos_violation,route_assigned,route_completed,dvir_defects,dvir_critical,log_edit_request,log_edit_resolved,uncertified_log,unidentified_driving,eld_disconnected,eld_malfunction,maintenance_upcoming,maintenance_overdue,chat_message,subscription_expiring"`
	Channels       []string `json:"channels" example:"push,email" enums:"push,email,sms,telegram"`
	RecipientRoles []string `json:"recipient_roles" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	Enabled        bool     `json:"enabled" example:"true"`
}

// NotificationSettingUpdate is one entry of the PATCH payload.
type NotificationSettingUpdate struct {
	AlertType      string   `json:"alert_type" example:"hos_violation" enums:"hos_warning,hos_violation,route_assigned,route_completed,dvir_defects,dvir_critical,log_edit_request,log_edit_resolved,uncertified_log,unidentified_driving,eld_disconnected,eld_malfunction,maintenance_upcoming,maintenance_overdue,chat_message,subscription_expiring" validate:"required,max=64"`
	Channels       []string `json:"channels" example:"push,email" enums:"push,email,sms,telegram" validate:"omitempty,max=4,dive,oneof=push email sms telegram"`
	RecipientRoles []string `json:"recipient_roles" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f" validate:"omitempty,max=32,dive,uuid4"`
	Enabled        *bool    `json:"enabled" example:"true"`
}

// NotificationSettingsUpdate is the PATCH /company/notification-settings body.
type NotificationSettingsUpdate struct {
	Settings []NotificationSettingUpdate `json:"settings" validate:"required,min=1,max=64,dive"`
}

// HistoryEntry is one audit_log row of the company configuration.
type HistoryEntry struct {
	ID           string    `json:"id" example:"2d4f6a8c-1e3b-4d5f-9a7c-8b6d4e2f0a1c"`
	TableName    string    `json:"table_name" example:"companies"`
	RecordID     *string   `json:"record_id" example:"3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f"`
	Field        string    `json:"field" example:"timezone"`
	OldValue     any       `json:"old_value" swaggertype:"string" example:"America/Chicago"`
	NewValue     any       `json:"new_value" swaggertype:"string" example:"America/Denver"`
	Action       string    `json:"action" example:"update" enums:"create,update,delete,soft_delete,hos_policy_change,subscription_change"`
	EditedBy     *string   `json:"edited_by" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	EditedByName string    `json:"edited_by_name" example:"Jane Doe"`
	Timestamp    time.Time `json:"ts" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// Envelopes.
type (
	// CompanyEnvelope wraps a single company profile.
	CompanyEnvelope struct {
		Data Company `json:"data"`
	}
	// BranchEnvelope wraps a single branch.
	BranchEnvelope struct {
		Data Branch `json:"data"`
	}
	// BranchListEnvelope wraps a paginated branch collection.
	BranchListEnvelope struct {
		Data []Branch `json:"data"`
		Meta Meta     `json:"meta"`
	}
	// HosPolicyEnvelope wraps the effective HOS policy version.
	HosPolicyEnvelope struct {
		Data HosPolicy `json:"data"`
	}
	// NotificationSettingsEnvelope wraps the full alert configuration.
	NotificationSettingsEnvelope struct {
		Data []NotificationSetting `json:"data"`
	}
	// HistoryListEnvelope wraps a paginated audit trail.
	HistoryListEnvelope struct {
		Data []HistoryEntry `json:"data"`
		Meta Meta           `json:"meta"`
	}
)
