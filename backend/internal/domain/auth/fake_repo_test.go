package auth

import (
	"context"
	"strings"
	"sync"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/db"
)

// fakeRepo is an in-memory Repo. It mirrors the semantics of the sqlc queries
// closely enough for the security regressions: refresh rotation keeps the
// previous hash, revocation is terminal and every lookup is scoped by id.
type fakeRepo struct {
	mu sync.Mutex

	users       map[uuid.UUID]*db.User
	roles       map[uuid.UUID]db.Role
	permissions map[uuid.UUID][]string
	companies   map[uuid.UUID]db.Company
	sessions    map[uuid.UUID]*db.Session
	prevHash    map[uuid.UUID]string
	invitations map[uuid.UUID]*db.Invitation
	settings    map[string][]byte

	// markUsedErr makes MarkInvitationUsed fail, which is how the one time
	// token guard is exercised.
	markUsedErr error
	// settingsReads counts SystemSettings calls so the /app/config cache can
	// be asserted.
	settingsReads int

	now func() time.Time
}

func newFakeRepo(now func() time.Time) *fakeRepo {
	return &fakeRepo{
		users:       map[uuid.UUID]*db.User{},
		roles:       map[uuid.UUID]db.Role{},
		permissions: map[uuid.UUID][]string{},
		companies:   map[uuid.UUID]db.Company{},
		sessions:    map[uuid.UUID]*db.Session{},
		prevHash:    map[uuid.UUID]string{},
		invitations: map[uuid.UUID]*db.Invitation{},
		settings:    map[string][]byte{},
		now:         now,
	}
}

func (f *fakeRepo) FindUsersByLogin(_ context.Context, login string) ([]db.User, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []db.User
	for _, u := range f.users {
		if u.DeletedAt.Valid {
			continue
		}
		if strings.EqualFold(u.Username, login) ||
			(u.Email != nil && strings.EqualFold(*u.Email, login)) {
			out = append(out, *u)
		}
	}
	return out, nil
}

func (f *fakeRepo) GetUserByID(_ context.Context, id uuid.UUID) (db.User, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	u, ok := f.users[id]
	if !ok {
		return db.User{}, pgx.ErrNoRows
	}
	return *u, nil
}

func (f *fakeRepo) GetRoleByID(_ context.Context, id uuid.UUID) (db.Role, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	r, ok := f.roles[id]
	if !ok {
		return db.Role{}, pgx.ErrNoRows
	}
	return r, nil
}

func (f *fakeRepo) RolePermissions(_ context.Context, roleID uuid.UUID) ([]string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]string(nil), f.permissions[roleID]...), nil
}

func (f *fakeRepo) GetCompany(_ context.Context, id uuid.UUID) (db.Company, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	c, ok := f.companies[id]
	if !ok {
		return db.Company{}, pgx.ErrNoRows
	}
	return c, nil
}

func (f *fakeRepo) MarkLoginSuccess(_ context.Context, userID uuid.UUID) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if u, ok := f.users[userID]; ok {
		u.FailedLogins = 0
		u.LockedUntil = pgtype.Timestamptz{}
		u.LastLoginAt = pgtype.Timestamptz{Time: f.now(), Valid: true}
	}
	return nil
}

func (f *fakeRepo) MarkLoginFailure(_ context.Context, userID uuid.UUID, threshold, lockMinutes int32) (int32, *time.Time, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	u, ok := f.users[userID]
	if !ok {
		return 0, nil, pgx.ErrNoRows
	}
	u.FailedLogins++
	if u.FailedLogins >= threshold {
		until := f.now().Add(time.Duration(lockMinutes) * time.Minute)
		u.LockedUntil = pgtype.Timestamptz{Time: until, Valid: true}
		return u.FailedLogins, &until, nil
	}
	return u.FailedLogins, nil, nil
}

func (f *fakeRepo) CreateSession(_ context.Context, in NewSessionInput) (db.Session, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	s := &db.Session{
		ID:               uuid.New(),
		CompanyID:        pgconv.UUIDPtr(in.CompanyID),
		UserID:           in.UserID,
		DeviceType:       in.DeviceType,
		RefreshTokenHash: in.TokenHash,
		Status:           "active",
		ExpiresAt:        in.ExpiresAt,
		CreatedAt:        f.now(),
		UpdatedAt:        f.now(),
	}
	if in.DeviceID != "" {
		s.DeviceID = &in.DeviceID
	}
	f.sessions[s.ID] = s
	return *s, nil
}

func (f *fakeRepo) ReplaceDeviceSessions(_ context.Context, userID uuid.UUID, deviceType, reason string) ([]uuid.UUID, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var ids []uuid.UUID
	for _, s := range f.sessions {
		if s.UserID == userID && s.DeviceType == deviceType && s.Status != "revoked" {
			s.Status = "revoked"
			s.RevokedReason = &reason
			ids = append(ids, s.ID)
		}
	}
	return ids, nil
}

func (f *fakeRepo) SessionByRefreshHash(_ context.Context, hash string) (SessionMatch, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, s := range f.sessions {
		if s.RefreshTokenHash == hash {
			return SessionMatch{Session: *s, Current: true}, nil
		}
	}
	for id, prev := range f.prevHash {
		if prev == hash {
			return SessionMatch{Session: *f.sessions[id], Current: false}, nil
		}
	}
	return SessionMatch{}, pgx.ErrNoRows
}

func (f *fakeRepo) RotateSession(_ context.Context, id uuid.UUID, newHash string, expiresAt time.Time, appVersion string) (db.Session, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	s, ok := f.sessions[id]
	if !ok || s.Status != "active" {
		return db.Session{}, pgx.ErrNoRows
	}
	f.prevHash[id] = s.RefreshTokenHash
	s.RefreshTokenHash = newHash
	s.ExpiresAt = expiresAt
	s.LastSeenAt = pgtype.Timestamptz{Time: f.now(), Valid: true}
	if appVersion != "" {
		s.AppVersion = &appVersion
	}
	return *s, nil
}

func (f *fakeRepo) RevokeSession(_ context.Context, id uuid.UUID, reason string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.sessions[id]; ok {
		s.Status = "revoked"
		s.RevokedReason = &reason
	}
	return nil
}

func (f *fakeRepo) RevokeAllUserSessions(_ context.Context, userID uuid.UUID, reason string) ([]uuid.UUID, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var ids []uuid.UUID
	for _, s := range f.sessions {
		if s.UserID == userID && s.Status != "revoked" {
			s.Status = "revoked"
			s.RevokedReason = &reason
			ids = append(ids, s.ID)
		}
	}
	return ids, nil
}

func (f *fakeRepo) PauseSession(_ context.Context, id uuid.UUID) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.sessions[id]; ok && s.Status == "active" {
		s.Status = "paused"
	}
	return nil
}

func (f *fakeRepo) ResumeSession(_ context.Context, id uuid.UUID) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.sessions[id]; ok && s.Status == "paused" {
		s.Status = "active"
	}
	return nil
}

func (f *fakeRepo) GetSession(_ context.Context, id uuid.UUID) (db.Session, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	s, ok := f.sessions[id]
	if !ok {
		return db.Session{}, pgx.ErrNoRows
	}
	return *s, nil
}

func (f *fakeRepo) ListSessionsByUser(_ context.Context, userID uuid.UUID) ([]db.Session, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := []db.Session{}
	for _, s := range f.sessions {
		if s.UserID == userID && s.Status != "revoked" {
			out = append(out, *s)
		}
	}
	return out, nil
}

func (f *fakeRepo) SetUserPassword(_ context.Context, userID uuid.UUID, hash string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if u, ok := f.users[userID]; ok {
		u.PasswordHash = &hash
		u.Status = "active"
		u.FailedLogins = 0
		u.LockedUntil = pgtype.Timestamptz{}
	}
	return nil
}

func (f *fakeRepo) SetUserPIN(_ context.Context, userID uuid.UUID, hash string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if u, ok := f.users[userID]; ok {
		u.PinHash = &hash
	}
	return nil
}

func (f *fakeRepo) SetUserTOTP(_ context.Context, userID uuid.UUID, secretEnc string, enabled bool, recovery []string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if u, ok := f.users[userID]; ok {
		u.TotpSecretEnc = &secretEnc
		u.TotpEnabled = enabled
		u.RecoveryCodes = recovery
	}
	return nil
}

func (f *fakeRepo) CreateInvitation(_ context.Context, in InvitationInput) (db.Invitation, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	inv := &db.Invitation{
		ID: uuid.New(), CompanyID: pgconv.UUIDPtr(in.CompanyID), UserID: in.UserID,
		TokenHash: in.TokenHash, Channel: in.Channel, Purpose: in.Purpose,
		ExpiresAt: in.ExpiresAt, CreatedAt: f.now(), UpdatedAt: f.now(),
	}
	f.invitations[inv.ID] = inv
	return *inv, nil
}

func (f *fakeRepo) InvitationByTokenHash(_ context.Context, hash string) (db.Invitation, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, inv := range f.invitations {
		if inv.TokenHash == hash {
			return *inv, nil
		}
	}
	return db.Invitation{}, pgx.ErrNoRows
}

func (f *fakeRepo) MarkInvitationUsed(_ context.Context, id uuid.UUID) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.markUsedErr != nil {
		return f.markUsedErr
	}
	if inv, ok := f.invitations[id]; ok && !inv.UsedAt.Valid {
		inv.UsedAt = pgtype.Timestamptz{Time: f.now(), Valid: true}
	}
	return nil
}

func (f *fakeRepo) InvalidateUserInvitations(_ context.Context, userID uuid.UUID, purpose string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, inv := range f.invitations {
		if inv.UserID == userID && inv.Purpose == purpose && !inv.UsedAt.Valid {
			inv.UsedAt = pgtype.Timestamptz{Time: f.now(), Valid: true}
		}
	}
	return nil
}

func (f *fakeRepo) SystemSettings(context.Context) (map[string][]byte, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.settingsReads++
	out := map[string][]byte{}
	for k, v := range f.settings {
		out[k] = v
	}
	return out, nil
}

func (f *fakeRepo) sessionStatus(id uuid.UUID) string {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.sessions[id]; ok {
		return s.Status
	}
	return ""
}

var _ Repo = (*fakeRepo)(nil)
