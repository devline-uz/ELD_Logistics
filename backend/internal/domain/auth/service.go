// Package auth is the authentication module: login, refresh token rotation,
// session policy, two factor authentication, PIN, invitations and password
// reset. It implements server.Module.
package auth

import (
	"context"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/auth/dto"
)

// RequestMeta carries the transport facts a session records. It is filled by
// the handler from the request, never from the JSON body.
type RequestMeta struct {
	IP         string
	UserAgent  string
	DeviceID   string
	DeviceType string
	AppVersion string
}

// Notifier delivers invitation and password reset links out of band. The token
// is passed to the implementation only; it is never returned over the API and
// never logged.
type Notifier interface {
	SendInvitation(ctx context.Context, msg InvitationMessage) error
}

// InvitationMessage is one outbound invitation or reset link.
type InvitationMessage struct {
	UserID    uuid.UUID
	CompanyID *uuid.UUID
	Channel   string
	Recipient string
	Purpose   string
	Token     string
	ExpiresAt time.Time
}

// LogNotifier is the bootstrap Notifier: it records that a link was issued
// without ever writing the token or the full recipient to the log.
type LogNotifier struct{ Log *slog.Logger }

// SendInvitation implements Notifier.
func (n LogNotifier) SendInvitation(ctx context.Context, msg InvitationMessage) error {
	log := n.Log
	if log == nil {
		log = slog.Default()
	}
	log.InfoContext(ctx, "invitation link issued",
		"purpose", msg.Purpose, "channel", msg.Channel,
		"user_id", msg.UserID.String(), "expires_at", msg.ExpiresAt)
	return nil
}

// Deps are the auth service collaborators.
type Deps struct {
	Repo        Repo
	Tokens      *core.TokenService
	TOTP        *core.TOTPManager
	Guard       *core.Guard
	Permissions *core.RolePermissionCache
	Revocations *core.Revocations
	Audit       audit.Recorder
	Notifier    Notifier
	Logger      *slog.Logger
	// Store backs the single use TOTP guard and the /app/config cache. A nil
	// store keeps the service working, without either.
	Store cache.Store

	DriverRefreshTTL time.Duration
	AdminRefreshTTL  time.Duration
	// TOTPEnrolmentRequired mirrors config.Config.TOTPEnrolmentRequired: when
	// false, Super Admin and Administrator accounts are no longer forced into
	// the enrolment flow. The zero value is false, so every caller that wants
	// the TZ B§3.4 behaviour must set it explicitly.
	TOTPEnrolmentRequired bool
	// Now is overridable in tests.
	Now func() time.Time
}

// Service holds the auth business logic. It never touches SQL directly.
type Service struct {
	repo        Repo
	tokens      *core.TokenService
	totp        *core.TOTPManager
	guard       *core.Guard
	permissions *core.RolePermissionCache
	revocations *core.Revocations
	recorder    audit.Recorder
	notifier    Notifier
	store       cache.Store
	log         *slog.Logger

	driverTTL           time.Duration
	adminTTL            time.Duration
	totpEnrolmentForced bool
	now                 func() time.Time
}

// NewService wires the auth service.
func NewService(d Deps) *Service {
	s := &Service{
		repo:        d.Repo,
		tokens:      d.Tokens,
		totp:        d.TOTP,
		guard:       d.Guard,
		permissions: d.Permissions,
		revocations: d.Revocations,
		recorder:    d.Audit,
		notifier:    d.Notifier,
		store:       d.Store,
		log:         d.Logger,
		driverTTL:   d.DriverRefreshTTL,
		adminTTL:    d.AdminRefreshTTL,

		totpEnrolmentForced: d.TOTPEnrolmentRequired,

		now: d.Now,
	}
	if s.log == nil {
		s.log = slog.Default()
	}
	if s.recorder == nil {
		s.recorder = audit.NopRecorder{}
	}
	if s.notifier == nil {
		s.notifier = LogNotifier{Log: s.log}
	}
	if s.now == nil {
		s.now = time.Now
	}
	if s.driverTTL <= 0 {
		s.driverTTL = core.DefaultDriverRefreshTTL
	}
	if s.adminTTL <= 0 {
		s.adminTTL = core.DefaultAdminRefreshTTL
	}
	return s
}

// errInvalidCredentials is the single answer to every failed credential check,
// so the API never discloses whether a username exists.
func errInvalidCredentials() error {
	return apierr.New(apierr.CodeInvalidCredentials, http.StatusUnauthorized,
		"invalid username or password")
}

// verifyLoginCredentials enforces the lockout/password/account-status gates
// that must all pass before a session can be opened.
func (s *Service) verifyLoginCredentials(ctx context.Context, meta RequestMeta, user db.User, in dto.LoginRequest, now time.Time) error {
	if lockedUntil := pgconv.ToTimePtr(user.LockedUntil); lockedUntil != nil && lockedUntil.After(now) {
		s.record(ctx, meta, user, audit.ActionFailedLogin, "locked_until", "account is locked")
		return apierr.New(apierr.CodeLockedOut, http.StatusTooManyRequests,
			"account temporarily locked after repeated failed sign in attempts")
	}
	if err := s.guard.CheckAccount(ctx, user.ID); err != nil {
		return err
	}

	if user.PasswordHash == nil || *user.PasswordHash == "" {
		core.VerifyPasswordDummy(in.Password)
		s.record(ctx, meta, user, audit.ActionFailedLogin, "password", "password not set")
		return errInvalidCredentials()
	}
	ok, err := core.VerifyPassword(in.Password, *user.PasswordHash)
	if err != nil || !ok {
		s.onFailedPassword(ctx, meta, user)
		return errInvalidCredentials()
	}

	// Q: an inactive driver must not hold a session at all.
	if user.Status == "inactive" || user.DeletedAt.Valid {
		s.revokeAll(ctx, meta, user, core.ReasonUserInactive)
		return apierr.New(apierr.CodeAccountInactive, http.StatusForbidden,
			"this account is inactive, contact your administrator")
	}
	if user.Status != "active" {
		s.record(ctx, meta, user, audit.ActionFailedLogin, "status", "account is not activated")
		return errInvalidCredentials()
	}
	return nil
}

// twoFactorGate enforces the TOTP requirement of the account's role and
// consumes a supplied code. It returns the restriction placed on the session,
// "" for none.
func (s *Service) twoFactorGate(
	ctx context.Context, meta RequestMeta, user db.User, acc account, in dto.LoginRequest, now time.Time,
) (string, error) {
	switch {
	case user.TotpEnabled:
		if strings.TrimSpace(in.TOTPCode) == "" {
			return "", apierr.New(apierr.CodeTOTPRequired, http.StatusUnauthorized,
				"a two factor code is required")
		}
		valid, err := s.totp.Validate(pgconv.Deref(user.TotpSecretEnc), in.TOTPCode, now)
		if err != nil {
			return "", err
		}
		if !valid || !s.consumeTOTPCode(ctx, user.ID, in.TOTPCode) {
			s.onFailedPassword(ctx, meta, user)
			return "", apierr.New(apierr.CodeTOTPInvalid, http.StatusUnauthorized,
				"the two factor code is not valid")
		}
		return "", nil
	case s.totpEnrolmentForced && core.TOTPRequiredForRole(acc.role.Name, acc.isSuperAdmin):
		// The account may only enrol in 2FA until it is done.
		return core.RestrictionTOTPSetup, nil
	default:
		return "", nil
	}
}

// openLoginSession replaces any same-device sessions and opens the new one,
// returning the ids it revoked so Login can report them.
func (s *Service) openLoginSession(
	ctx context.Context, meta RequestMeta, user db.User, in dto.LoginRequest, acc account, now time.Time,
) (db.Session, []uuid.UUID, string, error) {
	deviceType := core.NormalizeDeviceType(in.DeviceType)

	replaced, err := s.repo.ReplaceDeviceSessions(ctx, user.ID, deviceType, core.ReasonReplacedDevice)
	if err != nil {
		return db.Session{}, nil, "", db.MapError(err, "session")
	}
	if len(replaced) > 0 {
		_ = s.revocations.Revoke(ctx, replaced...)
		s.record(ctx, meta, user, audit.ActionSessionReplaced, "status", "revoked by new sign in")
	}

	refreshToken, refreshHash, err := core.NewRefreshToken()
	if err != nil {
		return db.Session{}, nil, "", apierr.Internal(err, "could not create a session")
	}
	ttl := core.RefreshTTL(acc.scope(), s.driverTTL, s.adminTTL)
	expiresAt := core.SessionExpiry(now, ttl, subscriptionEnd(acc.company))

	session, err := s.repo.CreateSession(ctx, NewSessionInput{
		CompanyID: pgconv.ToUUIDPtr(user.CompanyID), UserID: user.ID,
		DeviceID: in.DeviceID, DeviceType: deviceType, TokenHash: refreshHash,
		ExpiresAt: expiresAt, AppVersion: in.AppVersion,
		IP: meta.IP, UserAgent: meta.UserAgent,
	})
	if err != nil {
		return db.Session{}, nil, "", db.MapError(err, "session")
	}
	return session, replaced, refreshToken, nil
}

// Login authenticates a user and opens a session (TZ B§3.1, A§20).
func (s *Service) Login(ctx context.Context, in dto.LoginRequest, meta RequestMeta) (*dto.LoginResult, error) {
	now := s.now().UTC()

	if err := s.guard.CheckIP(ctx, meta.IP); err != nil {
		return nil, err
	}

	user, err := s.resolveLoginUser(ctx, in, meta)
	if err != nil {
		return nil, err
	}

	if err := s.verifyLoginCredentials(ctx, meta, user, in, now); err != nil {
		return nil, err
	}

	acc, err := s.loadAccount(ctx, user)
	if err != nil {
		return nil, err
	}

	restricted, err := s.twoFactorGate(ctx, meta, user, acc, in, now)
	if err != nil {
		return nil, err
	}

	session, replaced, refreshToken, err := s.openLoginSession(ctx, meta, user, in, acc, now)
	if err != nil {
		return nil, err
	}

	if err := s.repo.MarkLoginSuccess(ctx, user.ID); err != nil {
		s.log.WarnContext(ctx, "could not reset login counters", "error", err.Error())
	}
	s.guard.ResetAccount(ctx, user.ID)
	_ = s.revocations.Clear(ctx, session.ID)

	principal := s.principal(acc, session, restricted)
	accessToken, accessExp, err := s.tokens.Issue(principal)
	if err != nil {
		return nil, apierr.Internal(err, "could not issue an access token")
	}

	s.record(ctx, meta, user, audit.ActionLogin, "session_id", session.ID.String())

	result := &dto.LoginResult{
		Tokens: dto.Tokens{
			AccessToken: accessToken,
			TokenType:   "Bearer",
			ExpiresIn:   int(time.Until(accessExp).Seconds()),
		},
		ReplacedSession:      len(replaced) > 0,
		RequiresTOTPSetup:    restricted == core.RestrictionTOTPSetup,
		SubscriptionReadonly: acc.readonly,
		SessionID:            session.ID.String(),
		User:                 profileOf(acc),
	}
	// A limited session gets no refresh token: it must complete enrolment first.
	if restricted == "" {
		result.RefreshToken = refreshToken
		exp := session.ExpiresAt.UTC()
		result.RefreshExpiresAt = &exp
	}
	return result, nil
}

// resolveLoginUser finds exactly one candidate for the supplied credentials.
func (s *Service) resolveLoginUser(ctx context.Context, in dto.LoginRequest, meta RequestMeta) (db.User, error) {
	login := strings.TrimSpace(in.Username)
	candidates, err := s.repo.FindUsersByLogin(ctx, login)
	if err != nil && !db.IsNoRows(err) {
		return db.User{}, db.MapError(err, "user")
	}

	if in.CompanyID != "" {
		companyID, parseErr := uuid.Parse(in.CompanyID)
		if parseErr != nil {
			return db.User{}, apierr.BadRequest("company_id must be a uuid")
		}
		filtered := candidates[:0:0]
		for _, c := range candidates {
			if id := pgconv.ToUUIDPtr(c.CompanyID); id != nil && *id == companyID {
				filtered = append(filtered, c)
			}
		}
		candidates = filtered
	}

	if len(candidates) != 1 {
		// Unknown or ambiguous: burn the same CPU as a real verification so the
		// response time does not disclose whether the account exists.
		core.VerifyPasswordDummy(in.Password)
		s.recordAnonymousFailure(ctx, meta)
		return db.User{}, errInvalidCredentials()
	}
	return candidates[0], nil
}

func (s *Service) onFailedPassword(ctx context.Context, meta RequestMeta, user db.User) {
	threshold := int32(s.guard.MaxAccountFailures())              //nolint:gosec // G115: internal config, always a small guard count
	lockMinutes := int32(s.guard.LockoutDuration() / time.Minute) //nolint:gosec // G115: internal config, always a small duration
	if _, lockedUntil, err := s.repo.MarkLoginFailure(ctx, user.ID, threshold, lockMinutes); err != nil {
		s.log.WarnContext(ctx, "could not record a login failure", "error", err.Error())
	} else if lockedUntil != nil {
		s.record(ctx, meta, user, audit.ActionLockout, "locked_until", lockedUntil.Format(time.RFC3339))
	}
	if _, locked := s.guard.RecordAccountFailure(ctx, user.ID); locked {
		s.record(ctx, meta, user, audit.ActionLockout, "failed_logins", "hourly budget exhausted")
	}
	s.record(ctx, meta, user, audit.ActionFailedLogin, "password", "invalid credentials")
}

// totpReplayTTL outlives the validation window (one period plus the accepted
// skew), so a code can never be presented twice.
const totpReplayTTL = 90 * time.Second

// consumeTOTPCode burns a freshly validated TOTP code and reports whether this
// was its first use. Without it the same six digits stay valid for the whole
// ~30 s window, so a code observed over the shoulder, in a screenshot or in a
// phishing proxy can be replayed against a second session.
//
// Like every other Redis backed guard in this package, a store outage does not
// lock users out: the code still had to be valid to reach this point.
func (s *Service) consumeTOTPCode(ctx context.Context, userID uuid.UUID, code string) bool {
	code = strings.TrimSpace(code)
	if s.store == nil || code == "" {
		return true
	}
	key := "totp:used:" + userID.String() + ":" + appcrypto.HashSHA256(code)
	fresh, err := s.store.SetNX(ctx, key, "1", totpReplayTTL)
	if err != nil {
		s.log.WarnContext(ctx, "could not record a used two factor code", "error", err.Error())
		return true
	}
	return fresh
}
