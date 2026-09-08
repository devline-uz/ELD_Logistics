// Package dto holds the Super Admin (platform) company management payloads.
// The tenant profile shape is shared with the tenant facing company module so
// both APIs describe a company exactly the same way.
package dto

import (
	"time"

	companydto "github.com/devline/onebook-eld/internal/domain/company/dto"
	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared types re-exported so swagger annotations can reference dto.X.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
	// Company is the tenant profile, identical to GET /company.
	Company = companydto.Company
	// Settings is the company level configuration document.
	Settings = companydto.Settings
)

// AdministratorInvite is the first user of a new company. The account is
// created in `invited` state and receives a one time invitation link; no
// password is ever transmitted (TZ A§16).
type AdministratorInvite struct {
	FirstName string `json:"first_name" example:"Jane" validate:"required,min=1,max=80"`
	LastName  string `json:"last_name" example:"Doe" validate:"required,min=1,max=80"`
	Email     string `json:"email" example:"jane.doe@onebook.example" validate:"required,email,max=254"`
	Phone     string `json:"phone" example:"+15125550143" validate:"omitempty,max=32"`
	// Username defaults to the local part of the email address.
	Username string `json:"username" example:"jane.doe" validate:"omitempty,min=3,max=128"`
	// Channel selects how the invitation link is delivered.
	Channel string `json:"channel" example:"email" enums:"email,sms,telegram" validate:"omitempty,oneof=email sms telegram"`
}

// CompanyCreate provisions a tenant: the company row, the FMCSA 70/8 default
// HOS policy version, a copy of the system roles, the A§19 notification
// defaults and the Administrator invitation (TZ A§15).
type CompanyCreate struct {
	Name                string     `json:"name" example:"Onebook Logistics LLC" validate:"required,min=2,max=160"`
	Address             string     `json:"address" example:"1200 Industrial Rd, Dallas, TX 75207" validate:"omitempty,max=512"`
	HomeTerminalAddress string     `json:"home_terminal_address" example:"1200 Industrial Rd, Dallas, TX 75207" validate:"omitempty,max=512"`
	Timezone            string     `json:"timezone" example:"America/Chicago" validate:"required,max=64"`
	Email               string     `json:"email" example:"ops@onebook.example" validate:"omitempty,email,max=254"`
	Phone               string     `json:"phone" example:"+15125550143" validate:"omitempty,max=32"`
	RegistrationNo      string     `json:"registration_no" example:"3928471" validate:"omitempty,max=64"`
	Region              string     `json:"region" example:"US" enums:"PK,UZ,US,other" validate:"required,oneof=PK UZ US other"`
	UnitSystem          string     `json:"unit_system" example:"imperial" enums:"metric,imperial" validate:"required,oneof=metric imperial"`
	RegulationProfile   string     `json:"regulation_profile" example:"us_fmcsa" enums:"us_fmcsa,generic,canada,texas,california,alaska,hawaii" validate:"required,oneof=us_fmcsa generic canada texas california alaska hawaii"`
	Plan                string     `json:"plan" example:"fleet_50" validate:"omitempty,max=64"`
	SubscriptionStatus  string     `json:"subscription_status" example:"trial" enums:"trial,active,grace,readonly" validate:"omitempty,oneof=trial active grace readonly"`
	SubscriptionEndAt   *time.Time `json:"subscription_end_at" format:"date-time" example:"2026-12-31T23:59:59Z"`

	Administrator AdministratorInvite `json:"administrator" validate:"required"`
}

// CompanyUpdate patches a tenant from the platform console.
type CompanyUpdate struct {
	Name                *string `json:"name" example:"Onebook Logistics LLC" validate:"omitempty,min=2,max=160"`
	Address             *string `json:"address" example:"1200 Industrial Rd, Dallas, TX 75207" validate:"omitempty,max=512"`
	HomeTerminalAddress *string `json:"home_terminal_address" example:"1200 Industrial Rd, Dallas, TX 75207" validate:"omitempty,max=512"`
	Timezone            *string `json:"timezone" example:"America/Chicago" validate:"omitempty,max=64"`
	Email               *string `json:"email" example:"ops@onebook.example" validate:"omitempty,email,max=254"`
	Phone               *string `json:"phone" example:"+15125550143" validate:"omitempty,max=32"`
	RegistrationNo      *string `json:"registration_no" example:"3928471" validate:"omitempty,max=64"`
	LogoKey             *string `json:"logo_key" example:"companies/3f7c2d1a/logo.png" validate:"omitempty,max=256"`
	Region              *string `json:"region" example:"US" enums:"PK,UZ,US,other" validate:"omitempty,oneof=PK UZ US other"`
	UnitSystem          *string `json:"unit_system" example:"imperial" enums:"metric,imperial" validate:"omitempty,oneof=metric imperial"`
	RegulationProfile   *string `json:"regulation_profile" example:"us_fmcsa" enums:"us_fmcsa,generic,canada,texas,california,alaska,hawaii" validate:"omitempty,oneof=us_fmcsa generic canada texas california alaska hawaii"`
	Plan                *string `json:"plan" example:"fleet_50" validate:"omitempty,max=64"`
}

// SubscriptionUpdate moves a tenant between billing states (TZ A§15). MVP
// billing is manual: the platform administrator extends subscription_end_at
// once an invoice is settled.
type SubscriptionUpdate struct {
	Plan   *string `json:"plan" example:"fleet_50" validate:"omitempty,max=64"`
	Status *string `json:"subscription_status" example:"active" enums:"trial,active,grace,readonly" validate:"omitempty,oneof=trial active grace readonly"`
	// EndAt is the moment the paid period ends. Send null together with
	// clear_end_at to drop the date entirely.
	EndAt *time.Time `json:"subscription_end_at" format:"date-time" example:"2026-12-31T23:59:59Z"`
	// ClearEndAt removes subscription_end_at (perpetual / internal tenants).
	ClearEndAt bool `json:"clear_end_at" example:"false"`
}

// CompanyCreated is the result of provisioning a tenant. The invitation token
// itself is delivered out of band and never returned by the API.
type CompanyCreated struct {
	Company Company `json:"company"`
	// AdministratorUserID is the invited Administrator account.
	AdministratorUserID string `json:"administrator_user_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	// AdministratorRoleID is the company's copy of the Administrator role.
	AdministratorRoleID string `json:"administrator_role_id" example:"11f0a1b2-c3d4-4e5f-8a9b-0c1d2e3f4a5b"`
	// InvitationExpiresAt is when the invitation link stops working (72 h).
	InvitationExpiresAt time.Time `json:"invitation_expires_at" format:"date-time" example:"2026-09-09T05:12:00Z"`
	// InvitationChannel is how the link was delivered.
	InvitationChannel string `json:"invitation_channel" example:"email" enums:"email,sms,telegram"`
	// RolesCreated is the number of system role templates copied.
	RolesCreated int `json:"roles_created" example:"8"`
}

// Envelopes. The names are unique across the API so the generated Swagger
// document never has to disambiguate them.
type (
	// AdminCompanyEnvelope wraps one company for the platform console.
	AdminCompanyEnvelope struct {
		Data Company `json:"data"`
	}
	// AdminCompanyListEnvelope wraps a paginated company collection.
	AdminCompanyListEnvelope struct {
		Data []Company `json:"data"`
		Meta Meta      `json:"meta"`
	}
	// CompanyCreatedEnvelope wraps the provisioning result.
	CompanyCreatedEnvelope struct {
		Data CompanyCreated `json:"data"`
	}
)
