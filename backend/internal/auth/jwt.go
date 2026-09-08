package auth

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Access token defaults (TZ B§3.1).
const (
	// DefaultAccessTTL is the access token lifetime.
	DefaultAccessTTL = 15 * time.Minute
	// TokenIssuer identifies the issuing service in the iss claim.
	TokenIssuer = "onebook-eld"
	// TokenAudience identifies the accepted audience in the aud claim.
	TokenAudience = "onebook-eld-api" //nolint:gosec // G101: JWT audience label, not a credential value
	// MinSecretLen is the minimum accepted HMAC key length.
	MinSecretLen = 32
	// allowedClockSkew tolerates small clock drift between nodes.
	allowedClockSkew = 30 * time.Second
)

// Restriction values carried in the "lim" claim.
const (
	// RestrictionTOTPSetup lets the holder only enrol in 2FA.
	RestrictionTOTPSetup = "totp_setup"
)

// Claims is the access token payload (TZ B§3.1).
type Claims struct {
	jwt.RegisteredClaims
	CompanyID  string `json:"cid,omitempty"`
	RoleID     string `json:"rid"`
	Scope      string `json:"scope"`
	BranchID   string `json:"bid,omitempty"`
	SessionID  string `json:"sid"`
	DeviceType string `json:"dt"`
	Restricted string `json:"lim,omitempty"`
}

// TokenService issues and parses HS256 access tokens.
type TokenService struct {
	secret []byte
	ttl    time.Duration
	now    func() time.Time
}

// NewTokenService builds a TokenService. The secret comes from configuration
// (JWT_SECRET) and is never hardcoded.
func NewTokenService(secret string, ttl time.Duration) (*TokenService, error) {
	if len(secret) < MinSecretLen {
		return nil, fmt.Errorf("auth: jwt secret must be at least %d bytes", MinSecretLen)
	}
	if ttl <= 0 {
		ttl = DefaultAccessTTL
	}
	return &TokenService{secret: []byte(secret), ttl: ttl, now: time.Now}, nil
}

// TTL returns the configured access token lifetime.
func (t *TokenService) TTL() time.Duration { return t.ttl }

// SetClock overrides the time source; tests only.
func (t *TokenService) SetClock(now func() time.Time) { t.now = now }

// Issue mints an access token for the principal and returns it together with
// its expiry.
func (t *TokenService) Issue(p *tenant.Principal) (string, time.Time, error) {
	if p == nil {
		return "", time.Time{}, errors.New("auth: nil principal")
	}
	now := t.now().UTC()
	exp := now.Add(t.ttl)

	claims := Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   p.UserID.String(),
			Issuer:    TokenIssuer,
			Audience:  jwt.ClaimStrings{TokenAudience},
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now.Add(-allowedClockSkew)),
			ExpiresAt: jwt.NewNumericDate(exp),
			ID:        uuid.NewString(),
		},
		RoleID:     p.RoleID.String(),
		Scope:      string(p.Scope),
		SessionID:  p.SessionID.String(),
		DeviceType: p.DeviceType,
		Restricted: p.Restricted,
	}
	if p.CompanyID != nil {
		claims.CompanyID = p.CompanyID.String()
	}
	if p.BranchID != nil {
		claims.BranchID = p.BranchID.String()
	}

	signed, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(t.secret)
	if err != nil {
		return "", time.Time{}, fmt.Errorf("auth: sign access token: %w", err)
	}
	return signed, exp, nil
}

// Parse validates the signature, the algorithm and the temporal claims.
func (t *TokenService) Parse(token string) (*Claims, error) {
	var claims Claims
	parser := jwt.NewParser(
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}),
		jwt.WithIssuer(TokenIssuer),
		jwt.WithAudience(TokenAudience),
		jwt.WithLeeway(allowedClockSkew),
		jwt.WithExpirationRequired(),
		jwt.WithTimeFunc(func() time.Time { return t.now() }),
	)
	if _, err := parser.ParseWithClaims(token, &claims, func(*jwt.Token) (any, error) {
		return t.secret, nil
	}); err != nil {
		switch {
		case errors.Is(err, jwt.ErrTokenExpired):
			return nil, apierr.New(apierr.CodeTokenExpired, http.StatusUnauthorized, "access token expired")
		default:
			return nil, apierr.New(apierr.CodeTokenInvalid, http.StatusUnauthorized, "invalid access token")
		}
	}
	return &claims, nil
}

// PermissionSource resolves the permission keys granted to a role. The
// implementation is cached in Redis (TTL 5 minutes, invalidated on role change).
type PermissionSource interface {
	PermissionsForRole(ctx context.Context, roleID uuid.UUID) ([]string, error)
}

// RevocationStore reports sessions revoked before their access token expired
// (logout, Leave Truck, password change, permission change, token reuse).
type RevocationStore interface {
	IsRevoked(ctx context.Context, sessionID uuid.UUID) (bool, error)
}

// Verifier implements middleware.AuthVerifier on top of TokenService.
type Verifier struct {
	tokens      *TokenService
	permissions PermissionSource
	revocations RevocationStore
}

// NewVerifier wires the verifier. permissions and revocations may be nil, in
// which case the principal carries no permissions and revocation is not
// short-circuited before the token expires.
func NewVerifier(tokens *TokenService, perms PermissionSource, rev RevocationStore) *Verifier {
	return &Verifier{tokens: tokens, permissions: perms, revocations: rev}
}

// VerifyAccessToken validates the bearer token and builds the principal.
func (v *Verifier) VerifyAccessToken(ctx context.Context, token string) (*tenant.Principal, error) {
	if v == nil || v.tokens == nil {
		return nil, apierr.New(apierr.CodeUnavailable, http.StatusServiceUnavailable,
			"authentication is not configured")
	}

	claims, err := v.tokens.Parse(token)
	if err != nil {
		return nil, err
	}

	userID, err := uuid.Parse(claims.Subject)
	if err != nil {
		return nil, apierr.New(apierr.CodeTokenInvalid, http.StatusUnauthorized, "invalid access token")
	}
	sessionID, err := uuid.Parse(claims.SessionID)
	if err != nil {
		return nil, apierr.New(apierr.CodeTokenInvalid, http.StatusUnauthorized, "invalid access token")
	}
	roleID, err := uuid.Parse(claims.RoleID)
	if err != nil {
		return nil, apierr.New(apierr.CodeTokenInvalid, http.StatusUnauthorized, "invalid access token")
	}

	p := &tenant.Principal{
		UserID:     userID,
		RoleID:     roleID,
		Scope:      tenant.Scope(claims.Scope),
		SessionID:  sessionID,
		DeviceType: claims.DeviceType,
		Restricted: claims.Restricted,
	}
	if claims.CompanyID != "" {
		companyID, err := uuid.Parse(claims.CompanyID)
		if err != nil {
			return nil, apierr.New(apierr.CodeTokenInvalid, http.StatusUnauthorized, "invalid access token")
		}
		p.CompanyID = &companyID
	} else {
		p.IsSuperAdmin = true
	}
	if claims.BranchID != "" {
		branchID, err := uuid.Parse(claims.BranchID)
		if err != nil {
			return nil, apierr.New(apierr.CodeTokenInvalid, http.StatusUnauthorized, "invalid access token")
		}
		p.BranchID = &branchID
	}

	if v.revocations != nil {
		revoked, err := v.revocations.IsRevoked(ctx, sessionID)
		if err != nil {
			return nil, apierr.Internal(err, "could not verify the session")
		}
		if revoked {
			return nil, apierr.New(apierr.CodeTokenRevoked, http.StatusUnauthorized, "session has been revoked")
		}
	}

	// A restricted token grants no permission at all; skip the lookup entirely.
	if p.Restricted == "" && v.permissions != nil {
		perms, err := v.permissions.PermissionsForRole(ctx, roleID)
		if err != nil {
			return nil, apierr.Internal(err, "could not resolve permissions")
		}
		p.Permissions = perms
	}

	return p, nil
}
