// Package dto holds the auth module request and response payloads. sqlc models
// never leave the repository layer; everything a client sees is defined here
// and carries an example tag for the generated Swagger document.
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

// LoginRequest is the credential payload of POST /auth/login.
type LoginRequest struct {
	Username string `json:"username" example:"jdoe" validate:"required,max=128"`
	Password string `json:"password" example:"Str0ngPassphrase" validate:"required,min=1,max=128"`
	// DeviceType decides which of the three concurrent session slots is used.
	DeviceType string `json:"device_type" example:"web" enums:"web,phone,tablet" validate:"required,oneof=web phone tablet"`
	DeviceID   string `json:"device_id" example:"7c9f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f" validate:"omitempty,max=128"`
	AppVersion string `json:"app_version" example:"1.4.2" validate:"omitempty,max=32"`
	// TOTPCode is required once two factor authentication is enabled.
	TOTPCode string `json:"totp_code" example:"123456" validate:"omitempty,len=6,numeric"`
	// CompanyID disambiguates a username that exists in several tenants. It is
	// a pre-authentication hint only: the effective tenant always comes from
	// the resolved user row, never from this field.
	CompanyID string `json:"company_id" example:"3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f" validate:"omitempty,uuid4"`
}

// RefreshRequest rotates an opaque refresh token.
type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" example:"o1Wm4c9vJ3xQ7pL0aZ2bY5nR8tK6sD4fH1gU3jE" validate:"required,max=256"`
	AppVersion   string `json:"app_version" example:"1.4.2" validate:"omitempty,max=32"`
}

// LogoutRequest ends or pauses the current session.
type LogoutRequest struct {
	// Pause keeps the session recoverable with a PIN (Leave Truck).
	Pause bool `json:"pause" example:"false"`
	// RefreshToken optionally targets one session explicitly.
	RefreshToken string `json:"refresh_token" example:"o1Wm4c9vJ3xQ7pL0aZ2bY5nR8tK6sD4fH1gU3jE" validate:"omitempty,max=256"`
}

// TOTPVerifyRequest confirms an enrolment or a step up challenge.
type TOTPVerifyRequest struct {
	Code string `json:"code" example:"123456" validate:"omitempty,len=6,numeric"`
	// RecoveryCode is accepted instead of Code when the device is lost.
	RecoveryCode string `json:"recovery_code" example:"3f9a1c2d4e6b8a0c1d2e" validate:"omitempty,max=64"`
}

// InvitationAcceptRequest sets the first password from an invitation link.
type InvitationAcceptRequest struct {
	Token    string `json:"token" example:"Zr4KpN1vQ8sT2mL5xB7cD0eF3gH6jI9k" validate:"required,max=256"`
	Password string `json:"password" example:"Str0ngPassphrase" validate:"required,min=10,max=128"`
	// PIN optionally sets the 6 digit driver PIN in the same call.
	PIN string `json:"pin" example:"483920" validate:"omitempty,len=6,numeric"`
}

// PasswordForgotRequest starts a password reset.
type PasswordForgotRequest struct {
	// Login is the username or the email address of the account.
	Login string `json:"login" example:"jdoe" validate:"required,max=254"`
}

// PasswordResetRequest completes a password reset.
type PasswordResetRequest struct {
	Token    string `json:"token" example:"Zr4KpN1vQ8sT2mL5xB7cD0eF3gH6jI9k" validate:"required,max=256"`
	Password string `json:"password" example:"Str0ngPassphrase" validate:"required,min=10,max=128"`
}

// PINVerifyRequest authorises Switch driver / Return to truck.
type PINVerifyRequest struct {
	PIN string `json:"pin" example:"483920" validate:"required,len=6,numeric"`
	// Action selects what the verified PIN unlocks.
	Action string `json:"action" example:"return_to_truck" enums:"switch_driver,return_to_truck" validate:"omitempty,oneof=switch_driver return_to_truck"`
}

// Tokens is the credential pair handed to a client.
type Tokens struct {
	AccessToken string `json:"access_token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIifQ.sig"`
	TokenType   string `json:"token_type" example:"Bearer"`
	// ExpiresIn is the access token lifetime in seconds.
	ExpiresIn int `json:"expires_in" example:"900"`
	// RefreshToken is empty while the session is limited to 2FA enrolment.
	RefreshToken string `json:"refresh_token" example:"o1Wm4c9vJ3xQ7pL0aZ2bY5nR8tK6sD4fH1gU3jE"`
	// RefreshExpiresAt is when the refresh window closes.
	RefreshExpiresAt *time.Time `json:"refresh_expires_at" format:"date-time" example:"2026-10-06T05:12:00Z"`
}

// LoginResult is the body of a successful login.
type LoginResult struct {
	Tokens
	// ReplacedSession reports that another session of the same device type was
	// revoked by this login (TZ A§20).
	ReplacedSession bool `json:"replaced_session" example:"false"`
	// RequiresTOTPSetup marks a limited token: the account must enrol in two
	// factor authentication before anything else is permitted.
	RequiresTOTPSetup bool `json:"requires_totp_setup" example:"false"`
	// SubscriptionReadonly reports that the company subscription lapsed and
	// only read operations are accepted.
	SubscriptionReadonly bool `json:"subscription_readonly" example:"false"`
	// SessionID identifies the session created by this login.
	SessionID string  `json:"session_id" example:"9e2c4a1b-7d3f-4e5a-8b6c-0d1e2f3a4b5c"`
	User      Profile `json:"user"`
}

// Profile is the non sensitive view of the signed in user. It never carries a
// password hash, a TOTP secret, a PIN or a token.
type Profile struct {
	ID        string `json:"id" example:"5c1d2e3f-4a5b-6c7d-8e9f-0a1b2c3d4e5f"`
	FirstName string `json:"first_name" example:"John"`
	LastName  string `json:"last_name" example:"Doe"`
	Username  string `json:"username" example:"jdoe"`
	// Email is masked for anyone but the account owner.
	Email string `json:"email" example:"j***e@example.com"`
	// CompanyID is empty for platform (super admin) accounts.
	CompanyID    string     `json:"company_id" example:"3f7c2d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f"`
	BranchID     string     `json:"branch_id" example:"8a7b6c5d-4e3f-2a1b-0c9d-8e7f6a5b4c3d"`
	RoleID       string     `json:"role_id" example:"1b2c3d4e-5f6a-7b8c-9d0e-1f2a3b4c5d6e"`
	RoleName     string     `json:"role_name" example:"Fleet Manager"`
	Scope        string     `json:"scope" example:"company" enums:"company,branch,self"`
	Status       string     `json:"status" example:"active" enums:"invited,active,inactive"`
	IsSuperAdmin bool       `json:"is_super_admin" example:"false"`
	TOTPEnabled  bool       `json:"totp_enabled" example:"true"`
	PINSet       bool       `json:"pin_set" example:"true"`
	Permissions  []string   `json:"permissions" example:"units.read,drivers.read"`
	LastLoginAt  *time.Time `json:"last_login_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// TOTPSetup is returned when two factor enrolment starts.
type TOTPSetup struct {
	// OtpauthURL is rendered as a QR code by the client.
	OtpauthURL string `json:"otpauth_url" example:"otpauth://totp/ONEBOOK%20ELD:jdoe?secret=JBSWY3DPEHPK3PXP&issuer=ONEBOOK%20ELD"`
	// Secret is the base32 value for manual entry. It is shown once and is
	// stored AES-256-GCM encrypted.
	Secret string `json:"secret" example:"JBSWY3DPEHPK3PXP"`
	Issuer string `json:"issuer" example:"ONEBOOK ELD"`
	// Digits and Period describe the expected authenticator configuration.
	Digits int `json:"digits" example:"6"`
	Period int `json:"period" example:"30"`
}

// TOTPVerified is returned once two factor authentication is confirmed.
type TOTPVerified struct {
	Enabled bool `json:"enabled" example:"true"`
	// RecoveryCodes are shown exactly once, at enrolment. Only their hashes
	// are stored and each code works a single time.
	RecoveryCodes []string `json:"recovery_codes" example:"3f9a1c2d4e6b8a0c1d2e,7b1c9d0e2f3a4b5c6d7e"`
	// Tokens is filled when the verification upgraded a limited session.
	Tokens *Tokens `json:"tokens,omitempty"`
}

// PINVerified is the result of POST /auth/pin/verify.
type PINVerified struct {
	Verified bool `json:"verified" example:"true"`
	// SessionResumed reports that a paused session was reactivated.
	SessionResumed bool   `json:"session_resumed" example:"true"`
	Action         string `json:"action" example:"return_to_truck" enums:"switch_driver,return_to_truck"`
}

// Session is one entry of GET /auth/sessions.
type Session struct {
	ID         string `json:"id" example:"9e2c4a1b-7d3f-4e5a-8b6c-0d1e2f3a4b5c"`
	DeviceType string `json:"device_type" example:"phone" enums:"web,phone,tablet"`
	DeviceID   string `json:"device_id" example:"7c9f2f1e-2b4a-4f7d-9a1e-0f2b3c4d5e6f"`
	Status     string `json:"status" example:"active" enums:"active,paused,revoked"`
	AppVersion string `json:"app_version" example:"1.4.2"`
	// IP is truncated; the full address stays in the audit trail only.
	IP         string     `json:"ip" example:"203.0.113.0"`
	UserAgent  string     `json:"user_agent" example:"ONEBOOK-ELD/1.4.2 (Android 14)"`
	Current    bool       `json:"current" example:"true"`
	CreatedAt  time.Time  `json:"created_at" format:"date-time" example:"2026-09-06T05:12:00Z"`
	LastSeenAt *time.Time `json:"last_seen_at" format:"date-time" example:"2026-09-06T07:40:00Z"`
	ExpiresAt  time.Time  `json:"expires_at" format:"date-time" example:"2026-10-06T05:12:00Z"`
}

// AppConfig is the bootstrap payload of GET /app/config.
type AppConfig struct {
	MinSupportedVersion string `json:"min_supported_version" example:"1.0.0"`
	LatestVersion       string `json:"latest_version" example:"1.4.2"`
	ForceUpdate         bool   `json:"force_update" example:"false"`
	// FeatureFlags toggles optional modules per deployment.
	FeatureFlags map[string]bool `json:"feature_flags"`
	// AccessTokenTTLSeconds lets a client schedule its refresh.
	AccessTokenTTLSeconds int `json:"access_token_ttl_seconds" example:"900"`
	// SupportEmail is shown on the mobile about screen.
	SupportEmail string `json:"support_email" example:"support@onebook-eld.com"`
	// ServerTime lets the client detect clock drift before signing events.
	ServerTime time.Time `json:"server_time" format:"date-time" example:"2026-09-06T05:12:00Z"`
}

// Envelopes.

// LoginEnvelope wraps a login result.
type LoginEnvelope struct {
	Data LoginResult `json:"data"`
}

// TokensEnvelope wraps a refreshed credential pair.
type TokensEnvelope struct {
	Data Tokens `json:"data"`
}

// ProfileEnvelope wraps the signed in user profile.
type ProfileEnvelope struct {
	Data Profile `json:"data"`
}

// TOTPSetupEnvelope wraps a two factor enrolment.
type TOTPSetupEnvelope struct {
	Data TOTPSetup `json:"data"`
}

// TOTPVerifiedEnvelope wraps a two factor confirmation.
type TOTPVerifiedEnvelope struct {
	Data TOTPVerified `json:"data"`
}

// PINVerifiedEnvelope wraps a PIN verification result.
type PINVerifiedEnvelope struct {
	Data PINVerified `json:"data"`
}

// SessionListEnvelope wraps the active session list.
type SessionListEnvelope struct {
	Data []Session `json:"data"`
	Meta Meta      `json:"meta"`
}

// AppConfigEnvelope wraps the bootstrap configuration.
type AppConfigEnvelope struct {
	Data AppConfig `json:"data"`
}

// MessageEnvelope wraps a generic acknowledgement.
type MessageEnvelope struct {
	Data MessageResponse `json:"data"`
}
