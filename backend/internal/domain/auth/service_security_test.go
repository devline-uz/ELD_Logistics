package auth

import (
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/pquerna/otp"
	"github.com/pquerna/otp/totp"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/auth/dto"
	"github.com/devline/onebook-eld/internal/tenant"
)

const (
	testPassword = "Str0ngPassphrase"
	testSecret   = "test-secret-at-least-32-bytes-long!!"
	testEncKey   = "0123456789abcdef0123456789abcdef"
)

type harness struct {
	svc   *Service
	repo  *fakeRepo
	store *cache.MemoryStore
	audit *recordingAudit

	company db.Company
	role    db.Role
	user    *db.User
	now     time.Time
}

// recordingAudit captures the audit trail so the tests can assert that the
// security events required by TZ B§3 are actually written.
type recordingAudit struct{ entries []audit.Entry }

func (r *recordingAudit) Record(_ context.Context, entries ...audit.Entry) error {
	r.entries = append(r.entries, entries...)
	return nil
}

func (r *recordingAudit) RecordTx(_ context.Context, _ pgx.Tx, entries ...audit.Entry) error {
	r.entries = append(r.entries, entries...)
	return nil
}

func (r *recordingAudit) has(action audit.Action) bool {
	for _, e := range r.entries {
		if e.Action == action {
			return true
		}
	}
	return false
}

func newHarness(t *testing.T, opts ...func(*harness)) *harness {
	t.Helper()

	h := &harness{now: time.Date(2026, 9, 6, 5, 0, 0, 0, time.UTC)}
	nowFn := func() time.Time { return h.now }

	h.repo = newFakeRepo(nowFn)
	h.store = cache.NewMemoryStore()
	h.store.SetClock(nowFn)
	h.audit = &recordingAudit{}

	companyID := uuid.New()
	subEnd := h.now.Add(365 * 24 * time.Hour)
	h.company = db.Company{
		ID: companyID, Name: "Acme Freight", SubscriptionStatus: "active",
		SubscriptionEndAt: pgtype.Timestamptz{Time: subEnd, Valid: true},
	}
	h.repo.companies[companyID] = h.company

	roleID := uuid.New()
	h.role = db.Role{ID: roleID, Name: "Fleet Manager", Scope: "company",
		CompanyID: pgtype.UUID{Bytes: companyID, Valid: true}}
	h.repo.roles[roleID] = h.role
	h.repo.permissions[roleID] = []string{"units.read", "drivers.read"}

	hash, err := core.HashPassword(testPassword)
	require.NoError(t, err)
	email := "jdoe@example.com"
	userID := uuid.New()
	h.user = &db.User{
		ID: userID, CompanyID: pgtype.UUID{Bytes: companyID, Valid: true},
		FirstName: "John", LastName: "Doe", Username: "jdoe", Email: &email,
		PasswordHash: &hash, RoleID: roleID, Status: "active",
		CreatedAt: h.now, UpdatedAt: h.now,
	}
	h.repo.users[userID] = h.user

	for _, opt := range opts {
		opt(h)
	}

	tokens, err := core.NewTokenService(testSecret, core.DefaultAccessTTL)
	require.NoError(t, err)
	tokens.SetClock(nowFn)
	cipher, err := appcrypto.NewCipherFromString(testEncKey)
	require.NoError(t, err)

	h.svc = NewService(Deps{
		Repo:        h.repo,
		Tokens:      tokens,
		TOTP:        core.NewTOTPManager("ONEBOOK ELD", cipher),
		Guard:       core.NewGuard(h.store, core.GuardOptions{}),
		Permissions: core.NewRolePermissionCache(h.store, h.repo.RolePermissions, time.Minute),
		Revocations: core.NewRevocations(h.store, core.DefaultAccessTTL),
		Audit:       h.audit,
		Store:       h.store,
		Logger:      slog.New(slog.NewJSONHandler(io.Discard, nil)),
		Now:         nowFn,

		// The harness exercises the TZ B§3.4 default; the off switch has its
		// own test (TestAdministratorSkipsEnrolmentWhenNotRequired).
		TOTPEnrolmentRequired: true,
	})
	return h
}

func loginRequest() dto.LoginRequest {
	return dto.LoginRequest{Username: "jdoe", Password: testPassword, DeviceType: "web"}
}

func meta() RequestMeta {
	return RequestMeta{IP: "203.0.113.9", UserAgent: "ONEBOOK-ELD/1.4.2"}
}

// --- login ------------------------------------------------------------------

func TestLoginSuccessIssuesTokensAndAudits(t *testing.T) {
	h := newHarness(t)

	out, err := h.svc.Login(context.Background(), loginRequest(), meta())
	require.NoError(t, err)
	require.NotEmpty(t, out.AccessToken)
	require.NotEmpty(t, out.RefreshToken)
	require.Equal(t, "Bearer", out.TokenType)
	require.False(t, out.ReplacedSession)
	require.False(t, out.RequiresTOTPSetup)
	require.Equal(t, "jdoe", out.User.Username)
	require.True(t, h.audit.has(audit.ActionLogin))

	// The refresh token is opaque: only its SHA-256 hash reaches storage.
	sess, err := h.repo.GetSession(context.Background(), uuid.MustParse(out.SessionID))
	require.NoError(t, err)
	require.Equal(t, appcrypto.HashSHA256(out.RefreshToken), sess.RefreshTokenHash)
	require.NotContains(t, sess.RefreshTokenHash, out.RefreshToken)
}

func TestLoginWithWrongPasswordIsIndistinguishableFromUnknownUser(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	in := loginRequest()
	in.Password = "WrongPassphrase1"
	_, err := h.svc.Login(ctx, in, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeInvalidCredentials))

	unknown := loginRequest()
	unknown.Username = "nobody"
	_, err2 := h.svc.Login(ctx, unknown, meta())
	require.Error(t, err2)
	require.True(t, apierr.Is(err2, apierr.CodeInvalidCredentials))

	e1, _ := apierr.From(err)
	e2, _ := apierr.From(err2)
	require.Equal(t, e1.Message, e2.Message, "the message must not disclose whether the account exists")
	require.True(t, h.audit.has(audit.ActionFailedLogin))
}

func TestLoginLocksAccountAfterRepeatedFailures(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	bad := loginRequest()
	bad.Password = "WrongPassphrase1"

	// The per IP budget is 5/minute, so advance the clock between attempts and
	// exercise the per account lockout (10/hour -> locked_until).
	for i := 0; i < core.LoginMaxPerAccountPerHour; i++ {
		h.now = h.now.Add(90 * time.Second)
		_, err := h.svc.Login(ctx, bad, meta())
		require.Error(t, err)
	}

	require.True(t, h.user.LockedUntil.Valid, "users.locked_until must be set")
	require.True(t, h.user.LockedUntil.Time.After(h.now))
	require.EqualValues(t, core.LoginMaxPerAccountPerHour, h.user.FailedLogins)

	// The correct password is now refused too, until the lockout lapses.
	h.now = h.now.Add(90 * time.Second)
	_, err := h.svc.Login(ctx, loginRequest(), meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeLockedOut))
	require.True(t, h.audit.has(audit.ActionLockout))

	// Both budgets have to lapse: users.locked_until after 15 minutes and the
	// hourly per account counter after an hour.
	h.now = h.now.Add(time.Hour + core.LockoutDuration)
	out, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)
	require.NotEmpty(t, out.AccessToken)
}

func TestLoginRateLimitsPerIP(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()
	bad := loginRequest()
	bad.Password = "WrongPassphrase1"

	for i := 0; i < core.LoginMaxPerIPPerMinute; i++ {
		_, err := h.svc.Login(ctx, bad, meta())
		require.Error(t, err)
		require.True(t, apierr.Is(err, apierr.CodeInvalidCredentials))
	}
	_, err := h.svc.Login(ctx, loginRequest(), meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeRateLimited), "the 6th attempt from one address must be throttled")
}

func TestLoginReplacesSessionOfSameDeviceType(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	first, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	h.now = h.now.Add(time.Minute)
	second, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	require.True(t, second.ReplacedSession)
	require.Equal(t, "revoked", h.repo.sessionStatus(uuid.MustParse(first.SessionID)))
	require.Equal(t, "active", h.repo.sessionStatus(uuid.MustParse(second.SessionID)))

	// The revoked session's access token is denied before it expires.
	revoked, err := h.svc.revocations.IsRevoked(ctx, uuid.MustParse(first.SessionID))
	require.NoError(t, err)
	require.True(t, revoked)

	// A different device type keeps its own slot.
	phone := loginRequest()
	phone.DeviceType = "phone"
	h.now = h.now.Add(time.Minute)
	third, err := h.svc.Login(ctx, phone, meta())
	require.NoError(t, err)
	require.False(t, third.ReplacedSession)
	require.Equal(t, "active", h.repo.sessionStatus(uuid.MustParse(second.SessionID)))
}

func TestLoginRejectsInactiveAccountAndKillsItsSessions(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	first, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	h.user.Status = "inactive"
	h.now = h.now.Add(time.Minute)

	_, err = h.svc.Login(ctx, loginRequest(), meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeAccountInactive))

	e, _ := apierr.From(err)
	require.Equal(t, 403, e.Status())
	require.Equal(t, "revoked", h.repo.sessionStatus(uuid.MustParse(first.SessionID)),
		"an inactive account must not keep a live session")
}

func TestLoginRequiresTOTPWhenEnabled(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	cipher, err := appcrypto.NewCipherFromString(testEncKey)
	require.NoError(t, err)
	enrolment, err := core.NewTOTPManager("ONEBOOK ELD", cipher).Generate("jdoe")
	require.NoError(t, err)
	h.user.TotpSecretEnc = &enrolment.SecretEnc
	h.user.TotpEnabled = true

	_, err = h.svc.Login(ctx, loginRequest(), meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTOTPRequired))

	in := loginRequest()
	in.TOTPCode = "000000"
	_, err = h.svc.Login(ctx, in, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTOTPInvalid))
}

func TestAdministratorWithoutTOTPGetsLimitedTokenOnly(t *testing.T) {
	h := newHarness(t, func(h *harness) {
		h.role.Name = "Administrator"
		h.repo.roles[h.role.ID] = h.role
	})

	out, err := h.svc.Login(context.Background(), loginRequest(), meta())
	require.NoError(t, err)
	require.True(t, out.RequiresTOTPSetup)
	require.NotEmpty(t, out.AccessToken)
	require.Empty(t, out.RefreshToken, "a limited session must not receive a refresh token")

	// The limited token must not carry any permission.
	tokens, err := core.NewTokenService(testSecret, core.DefaultAccessTTL)
	require.NoError(t, err)
	tokens.SetClock(func() time.Time { return h.now })
	claims, err := tokens.Parse(out.AccessToken)
	require.NoError(t, err)
	require.Equal(t, core.RestrictionTOTPSetup, claims.Restricted)
}

func TestAdministratorSkipsEnrolmentWhenNotRequired(t *testing.T) {
	// AUTH_TOTP_ENROLMENT_REQUIRED=false: the role no longer forces enrolment,
	// so an Administrator signs in with a full session. Everything else about
	// the login is unchanged.
	h := newHarness(t, func(h *harness) {
		h.role.Name = "Administrator"
		h.repo.roles[h.role.ID] = h.role
	})
	h.svc.totpEnrolmentForced = false

	out, err := h.svc.Login(context.Background(), loginRequest(), meta())
	require.NoError(t, err)
	require.False(t, out.RequiresTOTPSetup)
	require.NotEmpty(t, out.RefreshToken, "a full session receives a refresh token")

	tokens, err := core.NewTokenService(testSecret, core.DefaultAccessTTL)
	require.NoError(t, err)
	tokens.SetClock(func() time.Time { return h.now })
	claims, err := tokens.Parse(out.AccessToken)
	require.NoError(t, err)
	require.Empty(t, claims.Restricted, "the session must not be restricted")
}

// TestEnrolledAdministratorStillNeedsACodeWhenNotRequired pins the half of the
// gate the switch must NOT touch: an account that already enrolled keeps being
// asked for its code.
func TestEnrolledAdministratorStillNeedsACodeWhenNotRequired(t *testing.T) {
	h := newHarness(t, func(h *harness) {
		h.role.Name = "Administrator"
		h.repo.roles[h.role.ID] = h.role
		h.user.TotpEnabled = true
	})
	h.svc.totpEnrolmentForced = false

	_, err := h.svc.Login(context.Background(), loginRequest(), meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTOTPRequired))
}

func TestLoginRejectsExpiredSubscriptionBeyondGrace(t *testing.T) {
	h := newHarness(t, func(h *harness) {
		end := h.now.Add(-30 * 24 * time.Hour)
		h.company.SubscriptionEndAt = pgtype.Timestamptz{Time: end, Valid: true}
		h.company.SubscriptionStatus = "expired"
		h.repo.companies[h.company.ID] = h.company
	})

	_, err := h.svc.Login(context.Background(), loginRequest(), meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeSubscriptionExpired))
}

func TestLoginInsideGraceIsReadonly(t *testing.T) {
	h := newHarness(t, func(h *harness) {
		end := h.now.Add(-24 * time.Hour)
		h.company.SubscriptionEndAt = pgtype.Timestamptz{Time: end, Valid: true}
		h.company.SubscriptionStatus = "expired"
		h.repo.companies[h.company.ID] = h.company
	})

	out, err := h.svc.Login(context.Background(), loginRequest(), meta())
	require.NoError(t, err)
	require.True(t, out.SubscriptionReadonly)

	// expires_at is capped at subscription_end_at + 7 day grace.
	sess, err := h.repo.GetSession(context.Background(), uuid.MustParse(out.SessionID))
	require.NoError(t, err)
	require.True(t, sess.ExpiresAt.Before(h.now.Add(core.DefaultAdminRefreshTTL)))
}

// --- refresh rotation and reuse ---------------------------------------------

func TestRefreshRotatesTheToken(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	h.now = h.now.Add(time.Minute)
	rotated, err := h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: login.RefreshToken}, meta())
	require.NoError(t, err)
	require.NotEmpty(t, rotated.RefreshToken)
	require.NotEqual(t, login.RefreshToken, rotated.RefreshToken)
	require.NotEmpty(t, rotated.AccessToken)

	// The new token keeps working.
	h.now = h.now.Add(time.Minute)
	again, err := h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: rotated.RefreshToken}, meta())
	require.NoError(t, err)
	require.NotEqual(t, rotated.RefreshToken, again.RefreshToken)
}

func TestRefreshTokenReuseRevokesTheWholeSession(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)
	sessionID := uuid.MustParse(login.SessionID)

	h.now = h.now.Add(time.Minute)
	rotated, err := h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: login.RefreshToken}, meta())
	require.NoError(t, err)

	// Replaying the rotated token is the leak signal.
	_, err = h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: login.RefreshToken}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTokenReused))

	require.Equal(t, "revoked", h.repo.sessionStatus(sessionID),
		"reuse must revoke the whole session, not only the replayed token")
	require.True(t, h.audit.has(audit.ActionTokenReuse), "reuse must be audited as token_reuse")

	revoked, err := h.svc.revocations.IsRevoked(ctx, sessionID)
	require.NoError(t, err)
	require.True(t, revoked, "the still valid access token must be denied immediately")

	// The token that was legitimately issued last is dead too.
	_, err = h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: rotated.RefreshToken}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTokenRevoked))
}

func TestRefreshRejectsUnknownExpiredAndRevokedTokens(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	_, err := h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: "not-a-real-token"}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTokenInvalid))

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	h.now = h.now.Add(core.DefaultAdminRefreshTTL + time.Hour)
	_, err = h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: login.RefreshToken}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeSessionExpired))
}

func TestRefreshOfInactiveUserIsRejected(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)
	h.user.Status = "inactive"

	_, err = h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: login.RefreshToken}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeAccountInactive))
	require.Equal(t, "revoked", h.repo.sessionStatus(uuid.MustParse(login.SessionID)))
}

func TestDriverRefreshWindowSlides(t *testing.T) {
	h := newHarness(t, func(h *harness) {
		h.role.Scope = string(tenant.ScopeSelf)
		h.repo.roles[h.role.ID] = h.role
	})
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)
	first := *login.RefreshExpiresAt

	h.now = h.now.Add(24 * time.Hour)
	rotated, err := h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: login.RefreshToken}, meta())
	require.NoError(t, err)
	require.True(t, rotated.RefreshExpiresAt.After(first), "the driver window must slide on every rotation")
}

// --- logout, pause and session management -----------------------------------

func TestLogoutRevokesTheSession(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)
	sessionID := uuid.MustParse(login.SessionID)

	require.NoError(t, h.svc.Logout(ctx, sessionID, h.user.ID, dto.LogoutRequest{}, meta()))
	require.Equal(t, "revoked", h.repo.sessionStatus(sessionID))
	require.True(t, h.audit.has(audit.ActionLogout))

	_, err = h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: login.RefreshToken}, meta())
	require.Error(t, err)
}

func TestLeaveTruckPausesAndPINResumes(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	pinHash, err := core.HashPIN("483920")
	require.NoError(t, err)
	h.user.PinHash = &pinHash

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)
	sessionID := uuid.MustParse(login.SessionID)

	require.NoError(t, h.svc.Logout(ctx, sessionID, h.user.ID, dto.LogoutRequest{Pause: true}, meta()))
	require.Equal(t, "paused", h.repo.sessionStatus(sessionID))

	// A paused session cannot be refreshed; the PIN must unlock it first.
	_, err = h.svc.Refresh(ctx, dto.RefreshRequest{RefreshToken: login.RefreshToken}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodePINRequired))

	p := &tenant.Principal{UserID: h.user.ID, SessionID: sessionID}
	out, err := h.svc.VerifyPIN(ctx, p, dto.PINVerifyRequest{PIN: "483920", Action: "return_to_truck"}, meta())
	require.NoError(t, err)
	require.True(t, out.Verified)
	require.True(t, out.SessionResumed)
	require.Equal(t, "active", h.repo.sessionStatus(sessionID))
}

func TestPINBruteForceIsLocked(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	pinHash, err := core.HashPIN("483920")
	require.NoError(t, err)
	h.user.PinHash = &pinHash
	p := &tenant.Principal{UserID: h.user.ID, SessionID: uuid.New()}

	for i := 0; i < core.PINMaxAttempts; i++ {
		_, err := h.svc.VerifyPIN(ctx, p, dto.PINVerifyRequest{PIN: "000000"}, meta())
		require.Error(t, err)
		require.True(t, apierr.Is(err, apierr.CodePINInvalid))
	}
	_, err = h.svc.VerifyPIN(ctx, p, dto.PINVerifyRequest{PIN: "483920"}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodePINLocked))
}

func TestRevokeSessionOfAnotherUserAnswers404(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	// A stranger must not be able to probe for, or kill, this session.
	err = h.svc.RevokeSession(ctx, uuid.New(), uuid.MustParse(login.SessionID), meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeNotFound))
	e, _ := apierr.From(err)
	require.Equal(t, 404, e.Status(), "cross-tenant access must be 404, not 403")
	require.Equal(t, "active", h.repo.sessionStatus(uuid.MustParse(login.SessionID)))

	// A non existent id answers the same way.
	err = h.svc.RevokeSession(ctx, h.user.ID, uuid.New(), meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeNotFound))

	require.NoError(t, h.svc.RevokeSession(ctx, h.user.ID, uuid.MustParse(login.SessionID), meta()))
	require.Equal(t, "revoked", h.repo.sessionStatus(uuid.MustParse(login.SessionID)))
	require.True(t, h.audit.has(audit.ActionSessionRevoked))
}

func TestLogoutWithAnotherUsersRefreshTokenAnswers404(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	err = h.svc.Logout(ctx, uuid.New(), uuid.New(),
		dto.LogoutRequest{RefreshToken: login.RefreshToken}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeNotFound))
	require.Equal(t, "active", h.repo.sessionStatus(uuid.MustParse(login.SessionID)))
}

// --- two factor enrolment ----------------------------------------------------

func TestTOTPEnrolmentUpgradesLimitedSession(t *testing.T) {
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
	require.Contains(t, setup.OtpauthURL, "otpauth://totp/")
	require.NotEmpty(t, setup.Secret)

	// The secret is stored encrypted, never in the clear.
	require.NotNil(t, h.user.TotpSecretEnc)
	require.NotContains(t, *h.user.TotpSecretEnc, setup.Secret)
	require.False(t, h.user.TotpEnabled, "2FA stays off until a code is confirmed")

	code := totpCode(t, setup.Secret, h.now)
	out, err := h.svc.VerifyTOTP(ctx, p, dto.TOTPVerifyRequest{Code: code}, meta())
	require.NoError(t, err)
	require.True(t, out.Enabled)
	require.Len(t, out.RecoveryCodes, core.RecoveryCodeCount)
	require.NotNil(t, out.Tokens)
	require.NotEmpty(t, out.Tokens.RefreshToken, "the upgraded session gets its first refresh token")
	require.True(t, h.audit.has(audit.ActionTOTPEnabled))

	// Only the hashes are stored.
	require.Len(t, h.user.RecoveryCodes, core.RecoveryCodeCount)
	for _, plain := range out.RecoveryCodes {
		require.NotContains(t, h.user.RecoveryCodes, plain)
	}

	// A wrong code is rejected.
	_, err = h.svc.VerifyTOTP(ctx, p, dto.TOTPVerifyRequest{Code: "000000"}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeTOTPInvalid))
}

func TestRecoveryCodeWorksOnlyOnce(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()
	p := &tenant.Principal{UserID: h.user.ID, SessionID: uuid.New()}

	setup, err := h.svc.SetupTOTP(ctx, p, meta())
	require.NoError(t, err)
	confirmed, err := h.svc.VerifyTOTP(ctx, p,
		dto.TOTPVerifyRequest{Code: totpCode(t, setup.Secret, h.now)}, meta())
	require.NoError(t, err)

	code := confirmed.RecoveryCodes[0]
	_, err = h.svc.VerifyTOTP(ctx, p, dto.TOTPVerifyRequest{RecoveryCode: code}, meta())
	require.NoError(t, err)

	_, err = h.svc.VerifyTOTP(ctx, p, dto.TOTPVerifyRequest{RecoveryCode: code}, meta())
	require.Error(t, err, "a recovery code must be consumed on first use")
	require.True(t, apierr.Is(err, apierr.CodeTOTPInvalid))
}

// --- invitations and password reset -----------------------------------------

func TestInvitationAcceptSetsPasswordAndRevokesSessions(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	token, err := appcrypto.RandomToken(32)
	require.NoError(t, err)
	companyID := uuid.UUID(h.user.CompanyID.Bytes)
	_, err = h.repo.CreateInvitation(ctx, InvitationInput{
		CompanyID: &companyID, UserID: h.user.ID,
		TokenHash: appcrypto.HashSHA256(token), Channel: "email",
		Purpose: PurposeInvitation, ExpiresAt: h.now.Add(core.InvitationTTL),
	})
	require.NoError(t, err)

	require.NoError(t, h.svc.AcceptInvitation(ctx, dto.InvitationAcceptRequest{
		Token: token, Password: "N3wPassphrase!", PIN: "483920",
	}, meta()))

	ok, err := core.VerifyPassword("N3wPassphrase!", *h.user.PasswordHash)
	require.NoError(t, err)
	require.True(t, ok)
	require.NotNil(t, h.user.PinHash)
	require.NotContains(t, *h.user.PinHash, "483920")

	require.Equal(t, "revoked", h.repo.sessionStatus(uuid.MustParse(login.SessionID)),
		"changing the password must revoke every session")
	require.True(t, h.audit.has(audit.ActionPasswordChange))

	// The token is single use.
	err = h.svc.AcceptInvitation(ctx, dto.InvitationAcceptRequest{
		Token: token, Password: "An0therPassphrase",
	}, meta())
	require.Error(t, err)
}

func TestInvitationRejectsExpiredWeakAndForgedTokens(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()
	companyID := uuid.UUID(h.user.CompanyID.Bytes)

	err := h.svc.AcceptInvitation(ctx, dto.InvitationAcceptRequest{
		Token: "forged", Password: "N3wPassphrase!",
	}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeInvitationInvalid))

	token, err := appcrypto.RandomToken(32)
	require.NoError(t, err)
	_, err = h.repo.CreateInvitation(ctx, InvitationInput{
		CompanyID: &companyID, UserID: h.user.ID,
		TokenHash: appcrypto.HashSHA256(token), Channel: "email",
		Purpose: PurposeInvitation, ExpiresAt: h.now.Add(core.InvitationTTL),
	})
	require.NoError(t, err)

	err = h.svc.AcceptInvitation(ctx, dto.InvitationAcceptRequest{Token: token, Password: "weak"}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodePasswordWeak))

	// 72 hours later the link is dead.
	h.now = h.now.Add(core.InvitationTTL + time.Hour)
	err = h.svc.AcceptInvitation(ctx, dto.InvitationAcceptRequest{
		Token: token, Password: "N3wPassphrase!",
	}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeInvitationExpired))
}

func TestForgotPasswordDoesNotEnumerateAccounts(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	require.NoError(t, h.svc.ForgotPassword(ctx, dto.PasswordForgotRequest{Login: "nobody"}, meta()))
	require.Empty(t, h.repo.invitations, "no token may be created for an unknown account")

	require.NoError(t, h.svc.ForgotPassword(ctx, dto.PasswordForgotRequest{Login: "jdoe"}, meta()))
	require.Len(t, h.repo.invitations, 1)
	for _, inv := range h.repo.invitations {
		require.Equal(t, PurposePasswordReset, inv.Purpose)
		require.Len(t, inv.TokenHash, 64, "only the SHA-256 hash of the token is stored")
	}
}

func TestPasswordResetRevokesEverySession(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	token, err := appcrypto.RandomToken(32)
	require.NoError(t, err)
	companyID := uuid.UUID(h.user.CompanyID.Bytes)
	_, err = h.repo.CreateInvitation(ctx, InvitationInput{
		CompanyID: &companyID, UserID: h.user.ID,
		TokenHash: appcrypto.HashSHA256(token), Channel: "email",
		Purpose: PurposePasswordReset, ExpiresAt: h.now.Add(core.InvitationTTL),
	})
	require.NoError(t, err)

	require.NoError(t, h.svc.ResetPassword(ctx,
		dto.PasswordResetRequest{Token: token, Password: "N3wPassphrase!"}, meta()))
	require.Equal(t, "revoked", h.repo.sessionStatus(uuid.MustParse(login.SessionID)))

	// The reset token cannot be replayed.
	err = h.svc.ResetPassword(ctx,
		dto.PasswordResetRequest{Token: token, Password: "Y3tAnotherPass"}, meta())
	require.Error(t, err)

	// An invitation token cannot be used on the reset endpoint and vice versa.
	other, err := appcrypto.RandomToken(32)
	require.NoError(t, err)
	_, err = h.repo.CreateInvitation(ctx, InvitationInput{
		CompanyID: &companyID, UserID: h.user.ID,
		TokenHash: appcrypto.HashSHA256(other), Channel: "email",
		Purpose: PurposeInvitation, ExpiresAt: h.now.Add(core.InvitationTTL),
	})
	require.NoError(t, err)
	err = h.svc.ResetPassword(ctx,
		dto.PasswordResetRequest{Token: other, Password: "N3wPassphrase!"}, meta())
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeInvitationInvalid))
}

// --- response hygiene --------------------------------------------------------

// forbiddenInResponse are substrings that must never appear in a serialised
// auth payload: credentials at rest, stored hashes and raw PII.
var forbiddenInResponse = []string{
	"password", "password_hash", "pin_hash", "totp_secret", "totp_secret_enc",
	"refresh_token_hash", "recovery_code_hash", "argon2id",
}

func assertNoSecrets(t *testing.T, label string, v any) {
	t.Helper()
	raw, err := json.Marshal(v)
	require.NoError(t, err)
	body := strings.ToLower(string(raw))
	for _, needle := range forbiddenInResponse {
		require.NotContains(t, body, needle, "%s must not expose %q", label, needle)
	}
}

func TestLoginResponseCarriesNoSecretsOrPII(t *testing.T) {
	h := newHarness(t)
	out, err := h.svc.Login(context.Background(), loginRequest(), meta())
	require.NoError(t, err)

	assertNoSecrets(t, "login response", out)
	require.NotContains(t, mustJSON(t, out), testPassword)
	require.NotContains(t, mustJSON(t, out), *h.user.PasswordHash)
}

func TestProfileResponseCarriesNoSecrets(t *testing.T) {
	h := newHarness(t)
	pinHash, err := core.HashPIN("483920")
	require.NoError(t, err)
	h.user.PinHash = &pinHash
	secret := "encrypted-secret"
	h.user.TotpSecretEnc = &secret
	h.user.TotpEnabled = true

	profile, err := h.svc.Me(context.Background(), h.user.ID)
	require.NoError(t, err)

	assertNoSecrets(t, "profile", profile)
	body := mustJSON(t, profile)
	require.NotContains(t, body, pinHash)
	require.NotContains(t, body, secret)
	require.NotContains(t, body, *h.user.PasswordHash)
	require.True(t, profile.PINSet, "the profile reports only that a PIN exists")
	require.True(t, profile.TOTPEnabled)
}

func TestSessionListMasksAddressesAndHidesTokenHashes(t *testing.T) {
	h := newHarness(t)
	ctx := context.Background()

	login, err := h.svc.Login(ctx, loginRequest(), meta())
	require.NoError(t, err)

	sessionID := uuid.MustParse(login.SessionID)
	stored, err := h.repo.GetSession(ctx, sessionID)
	require.NoError(t, err)

	sessions, err := h.svc.ListSessions(ctx, h.user.ID, sessionID)
	require.NoError(t, err)
	require.Len(t, sessions, 1)
	require.True(t, sessions[0].Current)

	body := mustJSON(t, sessions)
	assertNoSecrets(t, "session list", sessions)
	require.NotContains(t, body, stored.RefreshTokenHash)
	require.NotContains(t, body, login.RefreshToken)
}

func TestMaskAddrDropsTheHostPart(t *testing.T) {
	require.Equal(t, "203.0.113.0", maskAddr("203.0.113.42"))
	require.Equal(t, "2001:db8::0", maskAddr("2001:db8::1"))
	require.Equal(t, "", maskAddr(""))
}

func mustJSON(t *testing.T, v any) string {
	t.Helper()
	raw, err := json.Marshal(v)
	require.NoError(t, err)
	return string(raw)
}

// totpCode derives the code an authenticator app would show at t.
func totpCode(t *testing.T, secret string, at time.Time) string {
	t.Helper()
	code, err := totp.GenerateCodeCustom(secret, at.UTC(), totp.ValidateOpts{
		Period:    core.TOTPPeriod,
		Skew:      core.TOTPSkew,
		Digits:    core.TOTPDigits,
		Algorithm: otp.AlgorithmSHA1,
	})
	require.NoError(t, err)
	return code
}
