// Package dto holds the users / roles / permissions request and response
// payloads. sqlc models never leave the repository layer: everything a client
// sees is defined here and carries an example tag for the generated Swagger
// document. No payload ever exposes password_hash, totp_secret_enc, pin_hash
// or an invitation token.
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

// ---------------------------------------------------------------- users

// UserRole is the role summary embedded in a user payload.
type UserRole struct {
	ID       string `json:"id" example:"9d1b7f3e-4c2a-4a1b-9e7d-2f5a6b8c0d1e"`
	Name     string `json:"name" example:"Fleet Manager"`
	Scope    string `json:"scope" example:"company" enums:"company,branch,self"`
	IsSystem bool   `json:"is_system" example:"false"`
}

// User is the user representation returned by every users endpoint.
type User struct {
	ID        string  `json:"id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	FirstName string  `json:"first_name" example:"John"`
	LastName  string  `json:"last_name" example:"Doe"`
	FullName  string  `json:"full_name" example:"John Doe"`
	Email     *string `json:"email" example:"john.doe@example.com"`
	Phone     *string `json:"phone" example:"+13125550142"`
	Username  string  `json:"username" example:"jdoe"`
	// Status follows TZ Q1: invited -> active, active <-> inactive.
	Status      string     `json:"status" example:"active" enums:"invited,active,inactive"`
	Role        UserRole   `json:"role"`
	BranchID    *string    `json:"branch_id" example:"2b7c9d1e-3f4a-4b5c-8d9e-0f1a2b3c4d5e"`
	BranchName  *string    `json:"branch_name" example:"Chicago"`
	TotpEnabled bool       `json:"totp_enabled" example:"false"`
	InvitedAt   *time.Time `json:"invited_at" format:"date-time" example:"2026-09-01T10:00:00Z"`
	ActivatedAt *time.Time `json:"activated_at" format:"date-time" example:"2026-09-02T08:15:00Z"`
	LastLoginAt *time.Time `json:"last_login_at" format:"date-time" example:"2026-09-05T17:42:00Z"`
	CreatedAt   time.Time  `json:"created_at" format:"date-time" example:"2026-09-01T10:00:00Z"`
	UpdatedAt   time.Time  `json:"updated_at" format:"date-time" example:"2026-09-05T17:42:00Z"`
}

// UserCreate is the POST /users payload. There is no password field: the
// account is created with status `invited` and the user sets the password from
// the invitation link (TZ A§16, 72 hours).
type UserCreate struct {
	FirstName string `json:"first_name" example:"John" validate:"required,max=64"`
	LastName  string `json:"last_name" example:"Doe" validate:"required,max=64"`
	// Email or Phone is required: it is the channel the invitation is sent on.
	Email string `json:"email" example:"john.doe@example.com" validate:"omitempty,email,max=254"`
	Phone string `json:"phone" example:"+13125550142" validate:"omitempty,max=32"`
	// Username must be unique inside the company.
	Username string `json:"username" example:"jdoe" validate:"required,min=3,max=64"`
	RoleID   string `json:"role_id" example:"9d1b7f3e-4c2a-4a1b-9e7d-2f5a6b8c0d1e" validate:"required,uuid4"`
	// BranchID is required for a branch scoped role.
	BranchID string `json:"branch_id" example:"2b7c9d1e-3f4a-4b5c-8d9e-0f1a2b3c4d5e" validate:"omitempty,uuid4"`
	// Channel selects how the invitation is delivered; empty picks email when
	// an address is present, otherwise sms.
	Channel string `json:"channel" example:"email" enums:"email,sms,telegram" validate:"omitempty,oneof=email sms telegram"`
}

// UserUpdate is the PATCH /users/{id} payload. Every field is optional; a nil
// field is left untouched. Status is not settable here: use the activate and
// deactivate endpoints so sessions are revoked consistently.
type UserUpdate struct {
	FirstName *string `json:"first_name,omitempty" example:"John" validate:"omitempty,min=1,max=64"`
	LastName  *string `json:"last_name,omitempty" example:"Doe" validate:"omitempty,min=1,max=64"`
	Email     *string `json:"email,omitempty" example:"john.doe@example.com" validate:"omitempty,email,max=254"`
	Phone     *string `json:"phone,omitempty" example:"+13125550142" validate:"omitempty,max=32"`
	Username  *string `json:"username,omitempty" example:"jdoe" validate:"omitempty,min=3,max=64"`
	RoleID    *string `json:"role_id,omitempty" example:"9d1b7f3e-4c2a-4a1b-9e7d-2f5a6b8c0d1e" validate:"omitempty,uuid4"`
	// BranchID accepts an explicit null to detach the user from its branch.
	BranchID *string `json:"branch_id,omitempty" example:"2b7c9d1e-3f4a-4b5c-8d9e-0f1a2b3c4d5e" validate:"omitempty,uuid4"`
}

// InvitationSent acknowledges an invitation or password reset link. The token
// itself is never returned: it is delivered out of band.
type InvitationSent struct {
	UserID    string    `json:"user_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	Channel   string    `json:"channel" example:"email" enums:"email,sms,telegram"`
	Purpose   string    `json:"purpose" example:"invitation" enums:"invitation,password_reset"`
	ExpiresAt time.Time `json:"expires_at" format:"date-time" example:"2026-09-04T10:00:00Z"`
}

// ---------------------------------------------------------------- roles

// Role is the role representation returned by every roles endpoint.
type Role struct {
	ID          string  `json:"id" example:"9d1b7f3e-4c2a-4a1b-9e7d-2f5a6b8c0d1e"`
	Name        string  `json:"name" example:"Fleet Manager"`
	Description *string `json:"description" example:"Fleet and driver management"`
	// Scope decides how far a holder of the role can see (TZ Q82.1).
	Scope string `json:"scope" example:"company" enums:"company,branch,self"`
	// IsSystem roles (Super Admin, Administrator, ...) cannot be edited.
	IsSystem    bool      `json:"is_system" example:"false"`
	Permissions []string  `json:"permissions" example:"units.read,units.create"`
	UserCount   int64     `json:"user_count" example:"7"`
	CreatedAt   time.Time `json:"created_at" format:"date-time" example:"2026-09-01T10:00:00Z"`
	UpdatedAt   time.Time `json:"updated_at" format:"date-time" example:"2026-09-05T17:42:00Z"`
}

// RoleCreate is the POST /roles payload.
type RoleCreate struct {
	Name        string `json:"name" example:"Yard Supervisor" validate:"required,min=2,max=64"`
	Description string `json:"description" example:"Yard operations only" validate:"omitempty,max=255"`
	// Scope is company or branch; `self` is reserved for the built in Driver role.
	Scope string `json:"scope" example:"company" enums:"company,branch" validate:"required,oneof=company branch"`
	// Permissions must be keys of GET /permissions; unknown keys are rejected.
	Permissions []string `json:"permissions" example:"units.read,drivers.read" validate:"required,min=1,dive,required,max=64"`
}

// RoleUpdate is the PATCH /roles/{id} payload; nil fields are left untouched.
type RoleUpdate struct {
	Name        *string `json:"name,omitempty" example:"Yard Supervisor" validate:"omitempty,min=2,max=64"`
	Description *string `json:"description,omitempty" example:"Yard operations only" validate:"omitempty,max=255"`
	Scope       *string `json:"scope,omitempty" example:"branch" enums:"company,branch" validate:"omitempty,oneof=company branch"`
	// Permissions replaces the whole set when present.
	Permissions *[]string `json:"permissions,omitempty" example:"units.read,drivers.read" validate:"omitempty,dive,required,max=64"`
}

// ---------------------------------------------------------------- permissions

// Permission is one RBAC key with its human readable description.
type Permission struct {
	Key         string `json:"key" example:"units.read"`
	Description string `json:"description" example:"View units"`
}

// PermissionModule groups the keys of one module (TZ A§16 Q82).
type PermissionModule struct {
	Module string `json:"module" example:"units"`
	Label  string `json:"label" example:"Units"`
	// Permissions are ordered exactly like the catalogue.
	Permissions []Permission `json:"permissions"`
}

// ---------------------------------------------------------------- envelopes

// UserEnvelope wraps a single user.
type UserEnvelope struct {
	Data User `json:"data"`
}

// UserListEnvelope wraps a page of users.
type UserListEnvelope struct {
	Data []User `json:"data"`
	Meta Meta   `json:"meta"`
}

// InvitationEnvelope wraps an invitation acknowledgement.
type InvitationEnvelope struct {
	Data InvitationSent `json:"data"`
}

// RoleEnvelope wraps a single role.
type RoleEnvelope struct {
	Data Role `json:"data"`
}

// RoleListEnvelope wraps a page of roles.
type RoleListEnvelope struct {
	Data []Role `json:"data"`
	Meta Meta   `json:"meta"`
}

// PermissionListEnvelope wraps the permission catalogue grouped by module.
type PermissionListEnvelope struct {
	Data []PermissionModule `json:"data"`
}
