package auth

import (
	"time"

	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Session lifetime policy (TZ B§3.1, A§20).
const (
	// RefreshTokenBytes is the entropy of an opaque refresh token.
	RefreshTokenBytes = 32
	// DefaultDriverRefreshTTL is the sliding driver refresh window.
	DefaultDriverRefreshTTL = 30 * 24 * time.Hour
	// DefaultAdminRefreshTTL is the fixed office user refresh window.
	DefaultAdminRefreshTTL = 7 * 24 * time.Hour
	// SubscriptionGrace extends a session past subscription_end_at.
	SubscriptionGrace = 7 * 24 * time.Hour
	// InvitationTTL is the lifetime of an invitation / password reset link.
	InvitationTTL = 72 * time.Hour
)

// Session revocation reasons written to sessions.revoked_reason.
const (
	ReasonLogout           = "logout"
	ReasonReplacedDevice   = "replaced_by_new_device"
	ReasonPasswordChange   = "password_change"
	ReasonUserInactive     = "user_inactive"
	ReasonTokenReuse       = "token_reuse"
	ReasonRevokedByUser    = "revoked_by_user"
	ReasonPermissionChange = "permission_change"
	ReasonSubscriptionEnd  = "subscription_ended"
)

// Session statuses mirrored from the sessions.status CHECK constraint.
const (
	SessionActive  = "active"
	SessionPaused  = "paused"
	SessionRevoked = "revoked"
)

// NewRefreshToken returns a fresh opaque refresh token and the SHA-256 hash
// that is the only representation ever persisted.
func NewRefreshToken() (token, hash string, err error) {
	token, err = appcrypto.RandomToken(RefreshTokenBytes)
	if err != nil {
		return "", "", err
	}
	return token, HashRefreshToken(token), nil
}

// HashRefreshToken derives the stored representation of an opaque token.
func HashRefreshToken(token string) string {
	return appcrypto.HashSHA256(token)
}

// RefreshTTL returns the refresh window for a principal scope. Drivers
// (scope=self) slide over 30 days, office users get a fixed 7 day window.
func RefreshTTL(scope tenant.Scope, driverTTL, adminTTL time.Duration) time.Duration {
	if driverTTL <= 0 {
		driverTTL = DefaultDriverRefreshTTL
	}
	if adminTTL <= 0 {
		adminTTL = DefaultAdminRefreshTTL
	}
	if scope == tenant.ScopeSelf {
		return driverTTL
	}
	return adminTTL
}

// IsSliding reports whether the refresh window is extended on every rotation.
// Only drivers get a sliding window (TZ B§3.1).
func IsSliding(scope tenant.Scope) bool {
	return scope == tenant.ScopeSelf
}

// SessionExpiry computes expires_at = min(now+ttl, subscription_end_at + grace).
// subscriptionEnd is nil for platform (super admin) sessions.
func SessionExpiry(now time.Time, ttl time.Duration, subscriptionEnd *time.Time) time.Time {
	exp := now.UTC().Add(ttl)
	if subscriptionEnd == nil {
		return exp
	}
	capped := subscriptionEnd.UTC().Add(SubscriptionGrace)
	if capped.Before(exp) {
		return capped
	}
	return exp
}

// NormalizeDeviceType maps a client supplied device type onto the accepted set.
// Unknown values fall back to web so a malformed client cannot bypass the
// one-session-per-device-type policy by inventing a new bucket.
func NormalizeDeviceType(v string) string {
	switch v {
	case tenant.DeviceWeb, tenant.DevicePhone, tenant.DeviceTablet:
		return v
	default:
		return tenant.DeviceWeb
	}
}
