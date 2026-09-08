package auth

import (
	"context"
	"net/http"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/auth/dto"
)

// Refresh rotates an opaque refresh token. Reuse of an already rotated token
// revokes the whole session and is audited as token_reuse (TZ B§3.1).
func (s *Service) Refresh(ctx context.Context, in dto.RefreshRequest, meta RequestMeta) (*dto.Tokens, error) {
	now := s.now().UTC()
	hash := core.HashRefreshToken(in.RefreshToken)

	match, err := s.repo.SessionByRefreshHash(ctx, hash)
	if err != nil {
		if db.IsNoRows(err) {
			return nil, apierr.New(apierr.CodeTokenInvalid, http.StatusUnauthorized,
				"the refresh token is not valid")
		}
		return nil, db.MapError(err, "session")
	}
	session := match.Session

	if !match.Current {
		// The token was already rotated: either it leaked or it was replayed.
		// Kill the whole session chain, not just this token.
		s.onTokenReuse(ctx, meta, session)
		return nil, apierr.New(apierr.CodeTokenReused, http.StatusUnauthorized,
			"this refresh token was already used, the session has been revoked")
	}

	switch session.Status {
	case core.SessionPaused:
		return nil, apierr.New(apierr.CodePINRequired, http.StatusUnauthorized,
			"the session is paused, verify your PIN to return to the truck")
	case core.SessionRevoked:
		return nil, apierr.New(apierr.CodeTokenRevoked, http.StatusUnauthorized,
			"the session has been revoked")
	}
	if session.ExpiresAt.UTC().Before(now) {
		return nil, apierr.New(apierr.CodeSessionExpired, http.StatusUnauthorized,
			"the session has expired, sign in again")
	}

	user, err := s.repo.GetUserByID(ctx, session.UserID)
	if err != nil {
		return nil, db.MapError(err, "user")
	}
	if user.Status != "active" || user.DeletedAt.Valid {
		s.revokeAll(ctx, meta, user, core.ReasonUserInactive)
		return nil, apierr.New(apierr.CodeAccountInactive, http.StatusForbidden,
			"this account is inactive, contact your administrator")
	}

	acc, err := s.loadAccount(ctx, user)
	if err != nil {
		return nil, err
	}

	newToken, newHash, err := core.NewRefreshToken()
	if err != nil {
		return nil, apierr.Internal(err, "could not rotate the session")
	}

	// Drivers slide over a 30 day window, office users keep the fixed window
	// they were granted at sign in.
	expiresAt := session.ExpiresAt.UTC()
	if core.IsSliding(acc.scope()) {
		expiresAt = core.SessionExpiry(now,
			core.RefreshTTL(acc.scope(), s.driverTTL, s.adminTTL), subscriptionEnd(acc.company))
	}

	rotated, err := s.repo.RotateSession(ctx, session.ID, newHash, expiresAt, in.AppVersion)
	if err != nil {
		if db.IsNoRows(err) {
			return nil, apierr.New(apierr.CodeTokenRevoked, http.StatusUnauthorized,
				"the session has been revoked")
		}
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

func (s *Service) onTokenReuse(ctx context.Context, meta RequestMeta, session db.Session) {
	if err := s.repo.RevokeSession(ctx, session.ID, core.ReasonTokenReuse); err != nil {
		s.log.WarnContext(ctx, "could not revoke a reused session", "error", err.Error())
	}
	_ = s.revocations.Revoke(ctx, session.ID)

	entry := audit.Entry{
		TableName: "sessions",
		RecordID:  session.ID,
		Field:     "refresh_token_hash",
		NewValue:  "replayed refresh token, session revoked",
		Action:    audit.ActionTokenReuse,
		EditedBy:  session.UserID,
		IP:        meta.IP,
		CreatedAt: s.now().UTC(),
	}
	if companyID := pgconv.ToUUIDPtr(session.CompanyID); companyID != nil {
		entry.CompanyID = *companyID
	}
	if err := s.recorder.Record(ctx, entry); err != nil {
		s.log.WarnContext(ctx, "audit write failed", "action", string(audit.ActionTokenReuse))
	}
}

// Logout ends the current session, or pauses it when the driver leaves the
// truck (the session is then recoverable with a PIN).
func (s *Service) Logout(ctx context.Context, sessionID, userID uuid.UUID, in dto.LogoutRequest, meta RequestMeta) error {
	target := sessionID

	// An explicit refresh token may target the session of another device.
	if in.RefreshToken != "" {
		match, err := s.repo.SessionByRefreshHash(ctx, core.HashRefreshToken(in.RefreshToken))
		if err == nil {
			if match.Session.UserID != userID {
				// Never confirm the existence of somebody else's session.
				return apierr.NotFound("session")
			}
			target = match.Session.ID
		} else if !db.IsNoRows(err) {
			return db.MapError(err, "session")
		}
	}
	if target == uuid.Nil {
		return apierr.Unauthorized("no active session")
	}

	action := audit.ActionLogout
	if in.Pause {
		if err := s.repo.PauseSession(ctx, target); err != nil {
			return db.MapError(err, "session")
		}
		action = audit.ActionSessionPaused
	} else if err := s.repo.RevokeSession(ctx, target, core.ReasonLogout); err != nil {
		return db.MapError(err, "session")
	}
	_ = s.revocations.Revoke(ctx, target)

	user, err := s.repo.GetUserByID(ctx, userID)
	if err == nil {
		s.record(ctx, meta, user, action, "session_id", target.String())
	}
	return nil
}

// ListSessions returns the caller's own non revoked sessions.
func (s *Service) ListSessions(ctx context.Context, userID, currentSessionID uuid.UUID) ([]dto.Session, error) {
	rows, err := s.repo.ListSessionsByUser(ctx, userID)
	if err != nil {
		return nil, db.MapError(err, "session")
	}
	out := make([]dto.Session, 0, len(rows))
	for _, r := range rows {
		out = append(out, sessionDTO(r, r.ID == currentSessionID))
	}
	return out, nil
}

// RevokeSession revokes one of the caller's own sessions. A session that
// belongs to somebody else answers 404, never 403, so the endpoint cannot be
// used to probe for session ids.
func (s *Service) RevokeSession(ctx context.Context, userID, sessionID uuid.UUID, meta RequestMeta) error {
	session, err := s.repo.GetSession(ctx, sessionID)
	if err != nil {
		if db.IsNoRows(err) {
			return apierr.NotFound("session")
		}
		return db.MapError(err, "session")
	}
	if session.UserID != userID {
		return apierr.NotFound("session")
	}
	if err := s.repo.RevokeSession(ctx, sessionID, core.ReasonRevokedByUser); err != nil {
		return db.MapError(err, "session")
	}
	_ = s.revocations.Revoke(ctx, sessionID)

	if user, err := s.repo.GetUserByID(ctx, userID); err == nil {
		s.record(ctx, meta, user, audit.ActionSessionRevoked, "session_id", sessionID.String())
	}
	return nil
}

// Me returns the signed in user profile with its effective permissions.
func (s *Service) Me(ctx context.Context, userID uuid.UUID) (*dto.Profile, error) {
	user, err := s.repo.GetUserByID(ctx, userID)
	if err != nil {
		if db.IsNoRows(err) {
			return nil, apierr.NotFound("user")
		}
		return nil, db.MapError(err, "user")
	}
	acc, err := s.loadAccount(ctx, user)
	if err != nil {
		return nil, err
	}
	p := profileOf(acc)
	return &p, nil
}

func sessionDTO(r db.Session, current bool) dto.Session {
	out := dto.Session{
		ID:         r.ID.String(),
		DeviceType: r.DeviceType,
		DeviceID:   pgconv.Deref(r.DeviceID),
		Status:     r.Status,
		AppVersion: pgconv.Deref(r.AppVersion),
		UserAgent:  pgconv.Deref(r.UserAgent),
		Current:    current,
		CreatedAt:  r.CreatedAt.UTC(),
		LastSeenAt: pgconv.ToTimePtr(r.LastSeenAt),
		ExpiresAt:  r.ExpiresAt.UTC(),
	}
	if r.Ip != nil {
		out.IP = maskAddr(r.Ip.String())
	}
	return out
}

// maskAddr drops the host part of an address so the session list never exposes
// a precise location of another of the user's devices.
func maskAddr(ip string) string {
	if ip == "" {
		return ""
	}
	last := -1
	for i := len(ip) - 1; i >= 0; i-- {
		if ip[i] == '.' || ip[i] == ':' {
			last = i
			break
		}
	}
	if last < 0 {
		return ip
	}
	return ip[:last+1] + "0"
}
