package auth

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"strings"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/tenant"
)

const testSecret = "test-secret-at-least-32-bytes-long!!"

func newTokens(t *testing.T) *TokenService {
	t.Helper()
	ts, err := NewTokenService(testSecret, DefaultAccessTTL)
	require.NoError(t, err)
	return ts
}

func samplePrincipal() *tenant.Principal {
	companyID := uuid.New()
	branchID := uuid.New()
	return &tenant.Principal{
		UserID:     uuid.New(),
		CompanyID:  &companyID,
		RoleID:     uuid.New(),
		Scope:      tenant.ScopeBranch,
		BranchID:   &branchID,
		SessionID:  uuid.New(),
		DeviceType: tenant.DevicePhone,
	}
}

func TestNewTokenServiceRejectsWeakSecret(t *testing.T) {
	_, err := NewTokenService("short", time.Minute)
	require.Error(t, err)
	_, err = NewTokenService(strings.Repeat("a", MinSecretLen-1), time.Minute)
	require.Error(t, err)
}

func TestIssueCarriesEveryRequiredClaim(t *testing.T) {
	ts := newTokens(t)
	p := samplePrincipal()

	token, exp, err := ts.Issue(p)
	require.NoError(t, err)
	require.WithinDuration(t, time.Now().Add(DefaultAccessTTL), exp, time.Minute)

	parts := strings.Split(token, ".")
	require.Len(t, parts, 3)
	payload, err := base64.RawURLEncoding.DecodeString(parts[1])
	require.NoError(t, err)

	var claims map[string]any
	require.NoError(t, json.Unmarshal(payload, &claims))
	for _, key := range []string{"sub", "cid", "rid", "scope", "bid", "sid", "dt", "exp", "iat", "jti"} {
		require.Contains(t, claims, key, "claim %q is required by TZ B§3.1", key)
	}
	require.Equal(t, p.UserID.String(), claims["sub"])
	require.Equal(t, p.SessionID.String(), claims["sid"])
}

func TestVerifyRejectsExpiredToken(t *testing.T) {
	ts := newTokens(t)
	past := time.Now().Add(-2 * time.Hour)
	ts.SetClock(func() time.Time { return past })

	token, _, err := ts.Issue(samplePrincipal())
	require.NoError(t, err)

	ts.SetClock(time.Now)
	_, err = ts.Parse(token)
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTokenExpired))
}

func TestVerifyRejectsForgedSignature(t *testing.T) {
	ts := newTokens(t)
	token, _, err := ts.Issue(samplePrincipal())
	require.NoError(t, err)

	// Same payload, signed with another key.
	other, err := NewTokenService("a-completely-different-secret-key-32!", DefaultAccessTTL)
	require.NoError(t, err)
	forged, _, err := other.Issue(samplePrincipal())
	require.NoError(t, err)

	_, err = ts.Parse(forged)
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTokenInvalid))

	// Flipping one signature byte must also fail.
	tampered := token[:len(token)-2] + "AA"
	_, err = ts.Parse(tampered)
	require.Error(t, err)
}

func TestVerifyRejectsAlgNoneAndAlgConfusion(t *testing.T) {
	ts := newTokens(t)
	claims := jwt.MapClaims{
		"sub":   uuid.NewString(),
		"sid":   uuid.NewString(),
		"rid":   uuid.NewString(),
		"scope": "company",
		"iss":   TokenIssuer,
		"aud":   TokenAudience,
		"exp":   time.Now().Add(time.Hour).Unix(),
		"iat":   time.Now().Unix(),
	}

	unsigned, err := jwt.NewWithClaims(jwt.SigningMethodNone, claims).
		SignedString(jwt.UnsafeAllowNoneSignatureType)
	require.NoError(t, err)
	_, err = ts.Parse(unsigned)
	require.Error(t, err, "alg=none must never be accepted")

	hs512, err := jwt.NewWithClaims(jwt.SigningMethodHS512, claims).SignedString([]byte(testSecret))
	require.NoError(t, err)
	_, err = ts.Parse(hs512)
	require.Error(t, err, "only HS256 is accepted")
}

func TestVerifyRejectsForeignIssuerAndAudience(t *testing.T) {
	ts := newTokens(t)
	claims := jwt.MapClaims{
		"sub": uuid.NewString(), "sid": uuid.NewString(), "rid": uuid.NewString(),
		"scope": "company", "iss": "evil", "aud": TokenAudience,
		"exp": time.Now().Add(time.Hour).Unix(), "iat": time.Now().Unix(),
	}
	token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte(testSecret))
	require.NoError(t, err)
	_, err = ts.Parse(token)
	require.Error(t, err)
}

type stubPermissions map[uuid.UUID][]string

func (s stubPermissions) PermissionsForRole(_ context.Context, roleID uuid.UUID) ([]string, error) {
	return s[roleID], nil
}

type stubRevocations map[uuid.UUID]bool

func (s stubRevocations) IsRevoked(_ context.Context, sessionID uuid.UUID) (bool, error) {
	return s[sessionID], nil
}

func TestVerifierBuildsPrincipalAndAppliesRevocation(t *testing.T) {
	ts := newTokens(t)
	p := samplePrincipal()
	perms := stubPermissions{p.RoleID: {"units.read"}}
	revoked := stubRevocations{}

	v := NewVerifier(ts, perms, revoked)
	token, _, err := ts.Issue(p)
	require.NoError(t, err)

	got, err := v.VerifyAccessToken(context.Background(), token)
	require.NoError(t, err)
	require.Equal(t, p.UserID, got.UserID)
	require.Equal(t, p.SessionID, got.SessionID)
	require.Equal(t, tenant.ScopeBranch, got.Scope)
	require.False(t, got.IsSuperAdmin)
	require.True(t, got.HasPermission("units.read"))
	require.False(t, got.HasPermission("units.delete"))

	// Revoking the session must invalidate the still unexpired access token.
	revoked[p.SessionID] = true
	_, err = v.VerifyAccessToken(context.Background(), token)
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTokenRevoked))
}

func TestVerifierTreatsMissingCompanyAsSuperAdmin(t *testing.T) {
	ts := newTokens(t)
	p := samplePrincipal()
	p.CompanyID = nil
	p.BranchID = nil
	p.Scope = tenant.ScopeAll

	v := NewVerifier(ts, stubPermissions{}, nil)
	token, _, err := ts.Issue(p)
	require.NoError(t, err)

	got, err := v.VerifyAccessToken(context.Background(), token)
	require.NoError(t, err)
	require.True(t, got.IsSuperAdmin)
	require.Nil(t, got.CompanyID)
}

func TestRestrictedTokenHoldsNoPermission(t *testing.T) {
	ts := newTokens(t)
	p := samplePrincipal()
	p.Restricted = RestrictionTOTPSetup

	v := NewVerifier(ts, stubPermissions{p.RoleID: {"units.read", "*"}}, nil)
	token, _, err := ts.Issue(p)
	require.NoError(t, err)

	got, err := v.VerifyAccessToken(context.Background(), token)
	require.NoError(t, err)
	require.True(t, got.IsRestricted())
	require.Empty(t, got.Permissions, "a limited token must not carry permissions")
	require.False(t, got.HasPermission("units.read"))

	// Even a super admin restricted token must be powerless.
	got.IsSuperAdmin = true
	require.False(t, got.HasPermission("company.update"))
}

func TestVerifierRejectsGarbage(t *testing.T) {
	v := NewVerifier(newTokens(t), nil, nil)
	for _, token := range []string{"", "abc", "a.b.c", strings.Repeat("x", 500)} {
		_, err := v.VerifyAccessToken(context.Background(), token)
		require.Error(t, err)
	}
}
