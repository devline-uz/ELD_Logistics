package auth

import (
	"context"
	"encoding/json"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/domain/auth/dto"
	"github.com/devline/onebook-eld/internal/tenant"
)

// enableTOTP enrols the harness user and returns the encrypted secret.
func enableTOTP(t *testing.T, h *harness) string {
	t.Helper()
	cipher, err := appcrypto.NewCipherFromString(testEncKey)
	require.NoError(t, err)
	enrolment, err := core.NewTOTPManager("ONEBOOK ELD", cipher).Generate("jdoe")
	require.NoError(t, err)
	h.user.TotpSecretEnc = &enrolment.SecretEnc
	h.user.TotpEnabled = true
	return enrolment.Secret
}

// --- TOTP replay -------------------------------------------------------------

// A TOTP code stays arithmetically valid for a whole period (plus skew). Unless
// it is burned on first use, an attacker that observed one code — shoulder
// surfing, a screenshot, a phishing proxy — can open a second session with it.
func TestTOTPCodeIsSingleUseOnLogin(t *testing.T) {
	h := newHarness(t)
	secret := enableTOTP(t, h)
	ctx := context.Background()

	in := loginRequest()
	in.TOTPCode = totpCode(t, secret, h.now)

	first, err := h.svc.Login(ctx, in, meta())
	require.NoError(t, err)
	require.NotEmpty(t, first.AccessToken)

	// Same code, same 30 second window, a second device type so the session
	// policy is not what rejects it.
	replay := loginRequest()
	replay.TOTPCode = in.TOTPCode
	replay.DeviceType = "phone"
	_, err = h.svc.Login(ctx, replay, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTOTPInvalid), "a replayed code must be rejected")
}

// The guard is per user and per code: it must not lock out the next code.
func TestTOTPReplayGuardIsScopedToTheCode(t *testing.T) {
	h := newHarness(t)
	secret := enableTOTP(t, h)
	ctx := context.Background()

	in := loginRequest()
	in.TOTPCode = totpCode(t, secret, h.now)
	_, err := h.svc.Login(ctx, in, meta())
	require.NoError(t, err)

	// One period later the authenticator shows a different code, which must be
	// accepted.
	h.now = h.now.Add(time.Duration(core.TOTPPeriod) * time.Second)
	next := loginRequest()
	next.TOTPCode = totpCode(t, secret, h.now)
	require.NotEqual(t, in.TOTPCode, next.TOTPCode)
	_, err = h.svc.Login(ctx, next, meta())
	require.NoError(t, err)
}

// The same rule applies to the step up endpoint.
func TestVerifyTOTPRejectsAReplayedCode(t *testing.T) {
	h := newHarness(t, func(h *harness) {
		h.role.Name = "Administrator"
		h.repo.roles[h.role.ID] = h.role
	})
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)
	require.True(t, login.RequiresTOTPSetup)

	p := &tenant.Principal{
		UserID: h.user.ID, SessionID: uuid.MustParse(login.SessionID),
		Restricted: core.RestrictionTOTPSetup,
	}
	setup, err := h.svc.SetupTOTP(ctx, p, meta())
	require.NoError(t, err)

	code := totpCode(t, setup.Secret, h.now)
	_, err = h.svc.VerifyTOTP(ctx, p, dto.TOTPVerifyRequest{Code: code}, meta())
	require.NoError(t, err)

	_, err = h.svc.VerifyTOTP(ctx, p, dto.TOTPVerifyRequest{Code: code}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTOTPInvalid))
}

// A burned code must not be replayable against another account.
func TestTOTPReplayGuardIsScopedToTheUser(t *testing.T) {
	h := newHarness(t)
	secret := enableTOTP(t, h)
	ctx := context.Background()

	in := loginRequest()
	in.TOTPCode = totpCode(t, secret, h.now)
	_, err := h.svc.Login(ctx, in, meta())
	require.NoError(t, err)

	// The key is namespaced by user id: another user's entry is untouched.
	other := uuid.New()
	require.True(t, h.svc.consumeTOTPCode(ctx, other, in.TOTPCode))
	require.False(t, h.svc.consumeTOTPCode(ctx, other, in.TOTPCode))
}

// --- one time invitation and reset tokens ------------------------------------

func newInvitation(t *testing.T, h *harness, purpose string) string {
	t.Helper()
	token, err := appcrypto.RandomToken(32)
	require.NoError(t, err)
	companyID := uuid.UUID(h.user.CompanyID.Bytes)
	_, err = h.repo.CreateInvitation(context.Background(), InvitationInput{
		CompanyID: &companyID, UserID: h.user.ID,
		TokenHash: appcrypto.HashSHA256(token), Channel: "email",
		Purpose: purpose, ExpiresAt: h.now.Add(core.InvitationTTL),
	})
	require.NoError(t, err)
	return token
}

// If the invitation cannot be marked used the request must fail: continuing on
// a warning leaves a live link that whoever else holds it can replay.
func TestAcceptInvitationFailsWhenTheTokenCannotBeBurned(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()
	token := newInvitation(t, h, PurposeInvitation)

	h.repo.markUsedErr = errors.New("write failed")
	err := h.svc.AcceptInvitation(ctx, dto.InvitationAcceptRequest{
		Token: token, Password: "N3wPassphrase!",
	}, meta())
	require.Error(t, err)

	// Nothing was written: the account keeps its previous credential.
	ok, verr := core.VerifyPassword("N3wPassphrase!", *h.user.PasswordHash)
	require.NoError(t, verr)
	require.False(t, ok, "the password must not be set when the token cannot be burned")

	// Once storage recovers the very same link still works exactly once.
	h.repo.markUsedErr = nil
	require.NoError(t, h.svc.AcceptInvitation(ctx, dto.InvitationAcceptRequest{
		Token: token, Password: "N3wPassphrase!",
	}, meta()))
	require.Error(t, h.svc.AcceptInvitation(ctx, dto.InvitationAcceptRequest{
		Token: token, Password: "An0therPassphrase",
	}, meta()))
}

func TestResetPasswordFailsWhenTheTokenCannotBeBurned(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()
	token := newInvitation(t, h, PurposePasswordReset)

	h.repo.markUsedErr = errors.New("write failed")
	err := h.svc.ResetPassword(ctx,
		dto.PasswordResetRequest{Token: token, Password: "R3setPassphrase!"}, meta())
	require.Error(t, err)

	ok, verr := core.VerifyPassword("R3setPassphrase!", *h.user.PasswordHash)
	require.NoError(t, verr)
	require.False(t, ok)

	h.repo.markUsedErr = nil
	require.NoError(t, h.svc.ResetPassword(ctx,
		dto.PasswordResetRequest{Token: token, Password: "R3setPassphrase!"}, meta()))
	require.Error(t, h.svc.ResetPassword(ctx,
		dto.PasswordResetRequest{Token: token, Password: "Y3tAnotherPass1"}, meta()))
}

// --- /app/config -------------------------------------------------------------

// The endpoint is public: without a cache every unauthenticated request reads
// system_settings, which makes it a cheap amplification target.
func TestAppConfigIsServedFromCache(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()
	h.repo.settings = map[string][]byte{
		"min_supported_version": []byte(`"1.2.0"`),
		"latest_version":        []byte(`"1.4.2"`),
	}

	first, err := h.svc.AppConfig(ctx)
	require.NoError(t, err)
	require.Equal(t, "1.2.0", first.MinSupportedVersion)
	require.Equal(t, 1, h.repo.settingsReads)

	for i := 0; i < 20; i++ {
		out, err := h.svc.AppConfig(ctx)
		require.NoError(t, err)
		require.Equal(t, "1.4.2", out.LatestVersion)
		// server_time is never stale, even when the payload is cached.
		require.Equal(t, h.now.UTC(), out.ServerTime.UTC())
	}
	require.Equal(t, 1, h.repo.settingsReads, "the table must be read once per TTL")

	// The cache expires, so a version rollout becomes visible.
	h.now = h.now.Add(appConfigCacheTTL + time.Second)
	h.repo.settings["latest_version"] = []byte(`"1.5.0"`)
	out, err := h.svc.AppConfig(ctx)
	require.NoError(t, err)
	require.Equal(t, "1.5.0", out.LatestVersion)
	require.Equal(t, 2, h.repo.settingsReads)
}

// The cached payload must not carry anything a public caller may not see.
func TestAppConfigCacheHoldsNoSecrets(t *testing.T) {
	h := newHarness(t)
	_, err := h.svc.AppConfig(context.Background())
	require.NoError(t, err)

	raw, ok, err := h.store.Get(context.Background(), appConfigCacheKey)
	require.NoError(t, err)
	require.True(t, ok)

	var payload map[string]any
	require.NoError(t, json.Unmarshal([]byte(raw), &payload))
	for _, forbidden := range []string{"password", "secret", "refresh", "jwt", "license", "hash"} {
		require.NotContains(t, raw, forbidden)
	}
	// access_token_ttl_seconds is a public number, not a credential.
	require.NotContains(t, raw, "access_token\":\"")
}
