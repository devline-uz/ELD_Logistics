// Package dto holds the wire contract of the driver management module. sqlc
// models never leave the repository layer; only these types are serialised.
package dto

import (
	"time"

	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared envelopes re-exported so swagger annotations can stay local.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
	// MessageResponse is a generic acknowledgement payload.
	MessageResponse = shared.MessageResponse
)

// Driver statuses (drivers.status CHECK constraint).
const (
	StatusInvited  = "invited"
	StatusActive   = "active"
	StatusInactive = "inactive"
)

// Driver is one row of Driver Management. `license_no` is never serialised in
// clear text: only the last four characters are exposed (TZ B§3.4).
type Driver struct {
	ID               string     `json:"id" example:"7c3b6d3e-9a1f-4a2a-8f0c-2c1d4e5f6a7b"`
	UserID           string     `json:"user_id" example:"1b2c3d4e-5f60-4718-92a3-b4c5d6e7f809"`
	FirstName        string     `json:"first_name" example:"John"`
	LastName         string     `json:"last_name" example:"Doe"`
	Username         string     `json:"username" example:"john.doe"`
	Email            string     `json:"email,omitempty" example:"john.doe@example.com"`
	Phone            string     `json:"phone,omitempty" example:"+14155550123"`
	LicenseNoMasked  string     `json:"license_no_masked" example:"***4821"`
	LicenseRegion    string     `json:"license_region,omitempty" example:"TX"`
	HomeTerminal     string     `json:"home_terminal,omitempty" example:"Dallas Yard"`
	City             string     `json:"city,omitempty" example:"Dallas"`
	State            string     `json:"state,omitempty" example:"TX"`
	Zip              string     `json:"zip,omitempty" example:"75201"`
	Address1         string     `json:"address1,omitempty" example:"1200 Main St"`
	Address2         string     `json:"address2,omitempty" example:"Suite 4"`
	Notes            string     `json:"notes,omitempty" example:"Prefers night shifts"`
	BranchID         string     `json:"branch_id,omitempty" example:"3f2a1b0c-4d5e-6f70-8192-a3b4c5d6e7f8"`
	BranchName       string     `json:"branch_name,omitempty" example:"North Terminal"`
	FleetManagerID   string     `json:"fleet_manager_id,omitempty" example:"9a8b7c6d-5e4f-4031-a2b3-c4d5e6f70819"`
	FleetManagerName string     `json:"fleet_manager_name,omitempty" example:"Jane Smith"`
	DefaultUnitID    string     `json:"default_unit_id,omitempty" example:"5e6f7081-92a3-4b4c-95d6-e7f8091a2b3c"`
	DefaultUnit      string     `json:"default_unit_number,omitempty" example:"1021"`
	Status           string     `json:"status" example:"active" enums:"invited,active,inactive"`
	UserStatus       string     `json:"user_status" example:"active" enums:"invited,active,inactive"`
	AppVersion       string     `json:"app_version,omitempty" example:"2.4.1"`
	ActivatedOn      *time.Time `json:"activated_on,omitempty" format:"date-time" example:"2026-01-14T09:00:00Z"`
	LastLoginAt      *time.Time `json:"last_login_at,omitempty" format:"date-time" example:"2026-09-05T18:22:00Z"`
	CreatedAt        time.Time  `json:"created_at" format:"date-time" example:"2026-01-14T08:59:00Z"`
	UpdatedAt        time.Time  `json:"updated_at" format:"date-time" example:"2026-02-01T12:00:00Z"`
}

// DriverCreate is the POST /drivers payload. Q18.1: there is no password field
// — the account is activated through an invitation link.
type DriverCreate struct {
	FirstName      string `json:"first_name" example:"John" validate:"required,max=64"`
	LastName       string `json:"last_name" example:"Doe" validate:"required,max=64"`
	Username       string `json:"username" example:"john.doe" validate:"required,min=4,max=32"`
	Phone          string `json:"phone,omitempty" example:"+14155550123" validate:"omitempty,max=32"`
	Email          string `json:"email,omitempty" example:"john.doe@example.com" validate:"omitempty,email,max=255"`
	LicenseNo      string `json:"license_no" example:"TX-9930-4821" validate:"required,min=4,max=64"`
	LicenseRegion  string `json:"license_region,omitempty" example:"TX" validate:"omitempty,max=32"`
	HomeTerminal   string `json:"home_terminal,omitempty" example:"Dallas Yard" validate:"omitempty,max=128"`
	City           string `json:"city,omitempty" example:"Dallas" validate:"omitempty,max=64"`
	State          string `json:"state,omitempty" example:"TX" validate:"omitempty,max=64"`
	Zip            string `json:"zip,omitempty" example:"75201" validate:"omitempty,max=16"`
	Address1       string `json:"address1,omitempty" example:"1200 Main St" validate:"omitempty,max=128"`
	Address2       string `json:"address2,omitempty" example:"Suite 4" validate:"omitempty,max=128"`
	Notes          string `json:"notes,omitempty" example:"Prefers night shifts" validate:"omitempty,max=60"`
	BranchID       string `json:"branch_id,omitempty" example:"3f2a1b0c-4d5e-6f70-8192-a3b4c5d6e7f8" validate:"omitempty,uuid"`
	FleetManagerID string `json:"fleet_manager_id,omitempty" example:"9a8b7c6d-5e4f-4031-a2b3-c4d5e6f70819" validate:"omitempty,uuid"`
	DefaultUnitID  string `json:"default_unit_id,omitempty" example:"5e6f7081-92a3-4b4c-95d6-e7f8091a2b3c" validate:"omitempty,uuid"`
	// CoDriverID is optional (Q18.1) and creates a symmetric driver_pairs row.
	CoDriverID string `json:"co_driver_id,omitempty" example:"a1b2c3d4-e5f6-4071-8293-a4b5c6d7e8f9" validate:"omitempty,uuid"`
}

// DriverUpdate is the PATCH /drivers/{id} payload; nil means "leave unchanged".
type DriverUpdate struct {
	FirstName      *string `json:"first_name,omitempty" example:"John" validate:"omitempty,min=1,max=64"`
	LastName       *string `json:"last_name,omitempty" example:"Doe" validate:"omitempty,min=1,max=64"`
	Phone          *string `json:"phone,omitempty" example:"+14155550123" validate:"omitempty,max=32"`
	Email          *string `json:"email,omitempty" example:"john.doe@example.com" validate:"omitempty,email,max=255"`
	LicenseNo      *string `json:"license_no,omitempty" example:"TX-9930-4821" validate:"omitempty,min=4,max=64"`
	LicenseRegion  *string `json:"license_region,omitempty" example:"TX" validate:"omitempty,max=32"`
	HomeTerminal   *string `json:"home_terminal,omitempty" example:"Dallas Yard" validate:"omitempty,max=128"`
	City           *string `json:"city,omitempty" example:"Dallas" validate:"omitempty,max=64"`
	State          *string `json:"state,omitempty" example:"TX" validate:"omitempty,max=64"`
	Zip            *string `json:"zip,omitempty" example:"75201" validate:"omitempty,max=16"`
	Address1       *string `json:"address1,omitempty" example:"1200 Main St" validate:"omitempty,max=128"`
	Address2       *string `json:"address2,omitempty" example:"Suite 4" validate:"omitempty,max=128"`
	Notes          *string `json:"notes,omitempty" example:"Prefers night shifts" validate:"omitempty,max=60"`
	BranchID       *string `json:"branch_id,omitempty" example:"3f2a1b0c-4d5e-6f70-8192-a3b4c5d6e7f8" validate:"omitempty,uuid"`
	FleetManagerID *string `json:"fleet_manager_id,omitempty" example:"9a8b7c6d-5e4f-4031-a2b3-c4d5e6f70819" validate:"omitempty,uuid"`
	DefaultUnitID  *string `json:"default_unit_id,omitempty" example:"5e6f7081-92a3-4b4c-95d6-e7f8091a2b3c" validate:"omitempty,uuid"`
}

// DriverLicense carries the decrypted licence number. It is served only to a
// caller holding `drivers.update` and is never part of a list response.
type DriverLicense struct {
	DriverID  string `json:"driver_id" example:"7c3b6d3e-9a1f-4a2a-8f0c-2c1d4e5f6a7b"`
	LicenseNo string `json:"license_no" example:"TX-9930-4821"`
	Region    string `json:"license_region,omitempty" example:"TX"`
}

// CoDriver is one entry of the symmetric co-driver list (TZ §1.1, Q45).
type CoDriver struct {
	DriverID  string    `json:"driver_id" example:"a1b2c3d4-e5f6-4071-8293-a4b5c6d7e8f9"`
	FirstName string    `json:"first_name" example:"Maria"`
	LastName  string    `json:"last_name" example:"Lopez"`
	Username  string    `json:"username" example:"maria.lopez"`
	Status    string    `json:"status" example:"active" enums:"invited,active,inactive"`
	PairID    string    `json:"pair_id" example:"0c1d2e3f-4a5b-4c6d-8e7f-90a1b2c3d4e5"`
	PairedAt  time.Time `json:"paired_at" format:"date-time" example:"2026-03-02T10:15:00Z"`
}

// CoDriverCreate links two drivers. Storage is a single symmetric row.
type CoDriverCreate struct {
	CoDriverID string `json:"co_driver_id" example:"a1b2c3d4-e5f6-4071-8293-a4b5c6d7e8f9" validate:"required,uuid"`
}

// Activity is one entry of the driver activity feed: an audit_log change, a
// login or a session state transition.
type Activity struct {
	ID         string    `json:"id" example:"6c5b4a39-2817-4655-9483-a2b1c0d9e8f7"`
	OccurredAt time.Time `json:"occurred_at" format:"date-time" example:"2026-09-05T18:22:00Z"`
	Action     string    `json:"action" example:"update" enums:"create,update,soft_delete,login,logout,failed_login,export,activate,deactivate,password_reset,session_active,session_paused,session_revoked"`
	Source     string    `json:"source" example:"drivers" enums:"drivers,users,sessions,audit"`
	Field      string    `json:"field,omitempty" example:"status"`
	OldValue   string    `json:"old_value,omitempty" example:"\"active\""`
	NewValue   string    `json:"new_value,omitempty" example:"\"inactive\""`
	ActorID    string    `json:"actor_id,omitempty" example:"1b2c3d4e-5f60-4718-92a3-b4c5d6e7f809"`
	UserAgent  string    `json:"user_agent,omitempty" example:"ONEBOOK-ELD/2.4.1 (iOS 18)"`
}

// StatusChange is the optional reason body of activate / deactivate.
type StatusChange struct {
	Reason string `json:"reason,omitempty" example:"Left the company" validate:"omitempty,max=200"`
}

// ResetPasswordResult reports how the new invitation link was delivered. The
// token itself is never returned over the API.
type ResetPasswordResult struct {
	DriverID  string    `json:"driver_id" example:"7c3b6d3e-9a1f-4a2a-8f0c-2c1d4e5f6a7b"`
	Channel   string    `json:"channel" example:"email" enums:"email,sms"`
	ExpiresAt time.Time `json:"expires_at" format:"date-time" example:"2026-09-09T18:22:00Z"`
}

// Envelopes.

// DriverEnvelope wraps a single driver.
type DriverEnvelope struct {
	Data Driver `json:"data"`
}

// DriverListEnvelope wraps a page of drivers.
type DriverListEnvelope struct {
	Data []Driver `json:"data"`
	Meta Meta     `json:"meta"`
}

// DriverLicenseEnvelope wraps a decrypted licence number.
type DriverLicenseEnvelope struct {
	Data DriverLicense `json:"data"`
}

// CoDriverListEnvelope wraps the co-driver list.
type CoDriverListEnvelope struct {
	Data []CoDriver `json:"data"`
	Meta Meta       `json:"meta"`
}

// CoDriverEnvelope wraps a single co-driver link.
type CoDriverEnvelope struct {
	Data CoDriver `json:"data"`
}

// ActivityListEnvelope wraps a page of driver activities.
type ActivityListEnvelope struct {
	Data []Activity `json:"data"`
	Meta Meta       `json:"meta"`
}

// ResetPasswordEnvelope wraps the invitation delivery result.
type ResetPasswordEnvelope struct {
	Data ResetPasswordResult `json:"data"`
}
