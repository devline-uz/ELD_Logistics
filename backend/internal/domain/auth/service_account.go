package auth

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/auth/dto"
	"github.com/devline/onebook-eld/internal/tenant"
)

// SetupTOTP starts two factor enrolment. The shared secret is stored
// AES-256-GCM encrypted and 2FA stays disabled until VerifyTOTP confirms it.
func (s *Service) SetupTOTP(ctx context.Context, p *tenant.Principal, meta RequestMeta) (*dto.TOTPSetup, error) {
	user, err := s.repo.GetUserByID(ctx, p.UserID)
	if err != nil {
		return nil, db.MapError(err, "user")
	}
	if user.TotpEnabled {
		return nil, apierr.Conflict(apierr.CodeTOTPAlreadySetUp,
			"two factor authentication is already enabled")
	}

	account := user.Username
	if user.Email != nil && *user.Email != "" {
		account = *user.Email
	}
	enrolment, err := s.totp.Generate(account)
	if err != nil {
		return nil, err
	}
	if err := s.repo.SetUserTOTP(ctx, user.ID, enrolment.SecretEnc, false, []string{}); err != nil {
		return nil, db.MapError(err, "user")
	}

	return &dto.TOTPSetup{
		OtpauthURL: enrolment.URL,
		Secret:     enrolment.Secret,
		Issuer:     "ONEBOOK ELD",
		Digits:     int(core.TOTPDigits),
		Period:     core.TOTPPeriod,
	}, nil
}

// VerifyTOTP confirms an enrolment or validates a step up challenge. Confirming
// an enrolment returns the ten single use recovery codes exactly once and, when
// the caller held a limited token, upgrades it to a full session.
func (s *Service) VerifyTOTP(
	ctx context.Context, p *tenant.Principal, in dto.TOTPVerifyRequest, meta RequestMeta,
) (*dto.TOTPVerified, error) {
	now := s.now().UTC()

	user, err := s.repo.GetUserByID(ctx, p.UserID)
	if err != nil {
		return nil, db.MapError(err, "user")
	}
	secretEnc := pgconv.Deref(user.TotpSecretEnc)
	if secretEnc == "" {
		return nil, apierr.New(apierr.CodeTOTPSetupRequired, http.StatusForbidden,
			"start the two factor enrolment first")
	}

	recovery := append([]string(nil), user.RecoveryCodes...)
	verified := false

	if code := strings.TrimSpace(in.Code); code != "" {
		ok, err := s.totp.Validate(secretEnc, code, now)
		if err != nil {
			return nil, err
		}
		// Q3.4: a code is single use, replaying it inside the same window is
		// as invalid as a wrong code.
		verified = ok && s.consumeTOTPCode(ctx, user.ID, code)
	} else if rc := strings.TrimSpace(in.RecoveryCode); rc != "" && user.TotpEnabled {
		if idx, ok := core.MatchRecoveryCode(rc, recovery); ok {
			recovery = core.RemoveRecoveryCode(recovery, idx)
			verified = true
			if err := s.repo.SetUserTOTP(ctx, user.ID, secretEnc, true, recovery); err != nil {
				return nil, db.MapError(err, "user")
			}
		}
	}

	if !verified {
		s.record(ctx, meta, user, audit.ActionFailedLogin, "totp", "invalid two factor code")
		return nil, apierr.New(apierr.CodeTOTPInvalid, http.StatusUnauthorized,
			"the two factor code is not valid")
	}

	out := &dto.TOTPVerified{Enabled: true, RecoveryCodes: []string{}}

	if !user.TotpEnabled {
		plain, hashes, err := core.GenerateRecoveryCodes()
		if err != nil {
			return nil, apierr.Internal(err, "could not create recovery codes")
		}
		if err := s.repo.SetUserTOTP(ctx, user.ID, secretEnc, true, hashes); err != nil {
			return nil, db.MapError(err, "user")
		}
		out.RecoveryCodes = plain
		s.record(ctx, meta, user, audit.ActionTOTPEnabled, "totp_enabled", "true")
	} else {
		s.record(ctx, meta, user, audit.ActionTOTPVerified, "totp", "verified")
	}

	// Upgrade the limited enrolment token into a full session.
	if p.IsRestricted() {
		tokens, err := s.upgradeSession(ctx, user, p.SessionID)
		if err != nil {
			return nil, err
		}
		out.Tokens = tokens
	}
	return out, nil
}

// upgradeSession issues the first real refresh token for a session that was
// created in the limited 2FA enrolment state.
func (s *Service) upgradeSession(ctx context.Context, user db.User, sessionID uuid.UUID) (*dto.Tokens, error) {
	session, err := s.repo.GetSession(ctx, sessionID)
	if err != nil {
		return nil, db.MapError(err, "session")
	}
	if session.UserID != user.ID || session.Status != core.SessionActive {
		return nil, apierr.New(apierr.CodeTokenRevoked, http.StatusUnauthorized, "the session is no longer active")
	}

	acc, err := s.loadAccount(ctx, user)
	if err != nil {
		return nil, err
	}
	newToken, newHash, err := core.NewRefreshToken()
	if err != nil {
		return nil, apierr.Internal(err, "could not create a session")
	}
	rotated, err := s.repo.RotateSession(ctx, session.ID, newHash, session.ExpiresAt.UTC(), "")
	if err != nil {
		return nil, db.MapError(err, "session")
	}

	accessToken, accessExp, err := s.tokens.Issue(s.principal(acc, rotated, ""))
	if err != nil {
		return nil, apierr.Internal(err, "could not issue an access token")
	}
	exp := rotated.ExpiresAt.UTC()
	return &dto.Tokens{
		AccessToken:      accessToken,
		TokenType:        "Bearer",
		ExpiresIn:        int(time.Until(accessExp).Seconds()),
		RefreshToken:     newToken,
		RefreshExpiresAt: &exp,
	}, nil
}

// VerifyPIN authorises Switch driver / Return to truck (TZ A§16).
func (s *Service) VerifyPIN(ctx context.Context, p *tenant.Principal, in dto.PINVerifyRequest, meta RequestMeta) (*dto.PINVerified, error) {
	user, err := s.repo.GetUserByID(ctx, p.UserID)
	if err != nil {
		return nil, db.MapError(err, "user")
	}
	if user.PinHash == nil || *user.PinHash == "" {
		return nil, apierr.Conflict(apierr.CodePINNotSet, "no PIN is configured for this account")
	}
	if err := s.guard.CheckPIN(ctx, user.ID); err != nil {
		return nil, err
	}

	ok, err := core.VerifyPIN(in.PIN, *user.PinHash)
	if err != nil || !ok {
		s.guard.RecordPINFailure(ctx, user.ID)
		s.record(ctx, meta, user, audit.ActionPINFailed, "pin", "invalid PIN")
		return nil, apierr.New(apierr.CodePINInvalid, http.StatusUnauthorized, "the PIN is not valid")
	}
	s.guard.ResetPIN(ctx, user.ID)

	out := &dto.PINVerified{Verified: true, Action: in.Action}
	if in.Action == "return_to_truck" && p.SessionID != uuid.Nil {
		if err := s.repo.ResumeSession(ctx, p.SessionID); err != nil {
			return nil, db.MapError(err, "session")
		}
		_ = s.revocations.Clear(ctx, p.SessionID)
		out.SessionResumed = true
		s.record(ctx, meta, user, audit.ActionSessionResumed, "status", "active")
	}
	s.record(ctx, meta, user, audit.ActionPINVerified, "pin", "verified")
	return out, nil
}

// AcceptInvitation consumes a one time invitation token and sets the first
// password. Every existing session of the account is revoked afterwards.
func (s *Service) AcceptInvitation(ctx context.Context, in dto.InvitationAcceptRequest, meta RequestMeta) error {
	if err := core.ValidatePassword(in.Password); err != nil {
		return err
	}
	invitation, user, err := s.consumeToken(ctx, in.Token, PurposeInvitation)
	if err != nil {
		return err
	}

	hash, err := core.HashPassword(in.Password)
	if err != nil {
		return apierr.Internal(err, "could not set the password")
	}
	// The one time token is burned before anything is written. A token that
	// survives a failed accept can be replayed by whoever else holds the link,
	// so the request is rejected instead of continuing on a warning.
	if err := s.repo.MarkInvitationUsed(ctx, invitation.ID); err != nil {
		return db.MapError(err, "invitation")
	}
	if err := s.repo.SetUserPassword(ctx, user.ID, hash); err != nil {
		return db.MapError(err, "user")
	}
	if in.PIN != "" {
		pinHash, err := core.HashPIN(in.PIN)
		if err != nil {
			return err
		}
		if err := s.repo.SetUserPIN(ctx, user.ID, pinHash); err != nil {
			return db.MapError(err, "user")
		}
		s.record(ctx, meta, user, audit.ActionPINSet, "pin_hash", "set")
	}

	if err := s.repo.InvalidateUserInvitations(ctx, user.ID, PurposeInvitation); err != nil {
		s.log.WarnContext(ctx, "could not invalidate the remaining invitations", "error", err.Error())
	}

	s.revokeAll(ctx, meta, user, core.ReasonPasswordChange)
	s.record(ctx, meta, user, audit.ActionInviteAccepted, "status", "active")
	s.record(ctx, meta, user, audit.ActionPasswordChange, "password_hash", "set")
	return nil
}

// ForgotPassword issues a single use reset token. The response is identical
// whether or not the account exists, so the endpoint cannot enumerate users.
func (s *Service) ForgotPassword(ctx context.Context, in dto.PasswordForgotRequest, meta RequestMeta) error {
	login := strings.TrimSpace(in.Login)
	candidates, err := s.repo.FindUsersByLogin(ctx, login)
	if err != nil && !db.IsNoRows(err) {
		return db.MapError(err, "user")
	}
	if len(candidates) != 1 {
		return nil
	}
	user := candidates[0]
	if user.Status == "inactive" || user.DeletedAt.Valid {
		return nil
	}

	token, err := appcrypto.RandomToken(core.RefreshTokenBytes)
	if err != nil {
		return apierr.Internal(err, "could not create a reset token")
	}
	expiresAt := s.now().UTC().Add(core.InvitationTTL)

	// A new link invalidates the previous one.
	_ = s.repo.InvalidateUserInvitations(ctx, user.ID, PurposePasswordReset)

	channel := "email"
	recipient := pgconv.Deref(user.Email)
	if recipient == "" {
		channel = "sms"
		recipient = pgconv.Deref(user.Phone)
	}

	if _, err := s.repo.CreateInvitation(ctx, InvitationInput{
		CompanyID: pgconv.ToUUIDPtr(user.CompanyID), UserID: user.ID,
		TokenHash: appcrypto.HashSHA256(token), Channel: channel,
		Purpose: PurposePasswordReset, ExpiresAt: expiresAt,
	}); err != nil {
		return db.MapError(err, "invitation")
	}

	if err := s.notifier.SendInvitation(ctx, InvitationMessage{
		UserID: user.ID, CompanyID: pgconv.ToUUIDPtr(user.CompanyID), Channel: channel,
		Recipient: recipient, Purpose: PurposePasswordReset, Token: token, ExpiresAt: expiresAt,
	}); err != nil {
		s.log.WarnContext(ctx, "could not deliver a reset link", "error", err.Error())
	}
	return nil
}

// ResetPassword consumes a reset token, sets the new password and revokes every
// session of the account (TZ B§3.1).
func (s *Service) ResetPassword(ctx context.Context, in dto.PasswordResetRequest, meta RequestMeta) error {
	if err := core.ValidatePassword(in.Password); err != nil {
		return err
	}
	invitation, user, err := s.consumeToken(ctx, in.Token, PurposePasswordReset)
	if err != nil {
		return err
	}

	hash, err := core.HashPassword(in.Password)
	if err != nil {
		return apierr.Internal(err, "could not set the password")
	}
	// Same rule as AcceptInvitation: burn the reset token first, fail the
	// request if it cannot be burned.
	if err := s.repo.MarkInvitationUsed(ctx, invitation.ID); err != nil {
		return db.MapError(err, "invitation")
	}
	if err := s.repo.SetUserPassword(ctx, user.ID, hash); err != nil {
		return db.MapError(err, "user")
	}
	if err := s.repo.InvalidateUserInvitations(ctx, user.ID, PurposePasswordReset); err != nil {
		s.log.WarnContext(ctx, "could not invalidate the remaining reset links", "error", err.Error())
	}

	s.revokeAll(ctx, meta, user, core.ReasonPasswordChange)
	s.record(ctx, meta, user, audit.ActionPasswordChange, "password_hash", "reset")
	return nil
}

// consumeToken resolves a one time token to its invitation and user. Only the
// SHA-256 hash of the token ever reaches the database.
func (s *Service) consumeToken(ctx context.Context, token, purpose string) (db.Invitation, db.User, error) {
	invitation, err := s.repo.InvitationByTokenHash(ctx, appcrypto.HashSHA256(strings.TrimSpace(token)))
	if err != nil {
		if db.IsNoRows(err) {
			return db.Invitation{}, db.User{}, apierr.New(apierr.CodeInvitationInvalid,
				http.StatusUnauthorized, "the link is invalid or has expired")
		}
		return db.Invitation{}, db.User{}, db.MapError(err, "invitation")
	}
	if invitation.Purpose != purpose {
		return db.Invitation{}, db.User{}, apierr.New(apierr.CodeInvitationInvalid,
			http.StatusUnauthorized, "the link is invalid or has expired")
	}
	if invitation.ExpiresAt.UTC().Before(s.now().UTC()) {
		return db.Invitation{}, db.User{}, apierr.New(apierr.CodeInvitationExpired,
			http.StatusUnauthorized, "the link has expired, request a new one")
	}
	if invitation.UsedAt.Valid {
		return db.Invitation{}, db.User{}, apierr.New(apierr.CodeInvitationUsed,
			http.StatusUnauthorized, "the link has already been used")
	}

	user, err := s.repo.GetUserByID(ctx, invitation.UserID)
	if err != nil {
		return db.Invitation{}, db.User{}, db.MapError(err, "user")
	}
	if user.DeletedAt.Valid || user.Status == "inactive" {
		return db.Invitation{}, db.User{}, apierr.New(apierr.CodeAccountInactive,
			http.StatusForbidden, "this account is inactive, contact your administrator")
	}
	return invitation, user, nil
}

// AppConfig returns the client bootstrap payload from system_settings.
func (s *Service) AppConfig(ctx context.Context) (*dto.AppConfig, error) {
	// The endpoint is public and every mobile start hits it, so the row set is
	// served from a short lived cache instead of reading system_settings on
	// each request. server_time is refreshed after the cache read.
	if cached, ok := s.cachedAppConfig(ctx); ok {
		cached.ServerTime = s.now().UTC()
		cached.AccessTokenTTLSeconds = int(s.tokens.TTL().Seconds())
		return cached, nil
	}

	out := &dto.AppConfig{
		MinSupportedVersion:   "1.0.0",
		LatestVersion:         "1.0.0",
		FeatureFlags:          map[string]bool{},
		AccessTokenTTLSeconds: int(s.tokens.TTL().Seconds()),
		ServerTime:            s.now().UTC(),
	}

	settings, err := s.repo.SystemSettings(ctx)
	if err != nil {
		// The bootstrap endpoint must not fail when the table is unreachable.
		s.log.WarnContext(ctx, "could not read system settings", "error", err.Error())
		return out, nil
	}

	decodeSetting(settings, "min_supported_version", &out.MinSupportedVersion)
	decodeSetting(settings, "latest_version", &out.LatestVersion)
	decodeSetting(settings, "force_update", &out.ForceUpdate)
	decodeSetting(settings, "feature_flags", &out.FeatureFlags)
	decodeSetting(settings, "support_email", &out.SupportEmail)
	if out.FeatureFlags == nil {
		out.FeatureFlags = map[string]bool{}
	}
	s.storeAppConfig(ctx, out)
	return out, nil
}

// appConfigCacheKey is global: /app/config carries no tenant data.
const appConfigCacheKey = "appconfig:v1"

// appConfigCacheTTL keeps a version rollout visible within a minute.
const appConfigCacheTTL = 45 * time.Second

func (s *Service) cachedAppConfig(ctx context.Context) (*dto.AppConfig, bool) {
	if s.store == nil {
		return nil, false
	}
	raw, ok, err := s.store.Get(ctx, appConfigCacheKey)
	if err != nil || !ok {
		return nil, false
	}
	var out dto.AppConfig
	if json.Unmarshal([]byte(raw), &out) != nil {
		return nil, false
	}
	if out.FeatureFlags == nil {
		out.FeatureFlags = map[string]bool{}
	}
	return &out, true
}

func (s *Service) storeAppConfig(ctx context.Context, cfg *dto.AppConfig) {
	if s.store == nil {
		return
	}
	raw, err := json.Marshal(cfg)
	if err != nil {
		return
	}
	if err := s.store.Set(ctx, appConfigCacheKey, string(raw), appConfigCacheTTL); err != nil {
		s.log.WarnContext(ctx, "could not cache the app config", "error", err.Error())
	}
}

func decodeSetting[T any](settings map[string][]byte, key string, dst *T) {
	raw, ok := settings[key]
	if !ok || len(raw) == 0 {
		return
	}
	var v T
	if err := json.Unmarshal(raw, &v); err == nil {
		*dst = v
	}
}
