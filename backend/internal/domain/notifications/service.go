package notifications

import (
	"context"
	"strings"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/notifications/dto"
	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// Service is the notification centre business layer. Every method scopes to
// the calling user: a notification is personal, so there is no "read another
// user's inbox" path at all.
type Service struct {
	repo Repo
}

// NewService builds the service.
func NewService(repo Repo) *Service { return &Service{repo: repo} }

// List returns one page of the caller's inbox.
func (s *Service) List(ctx context.Context, f ListFilter) ([]dto.Notification, int64, int64, error) {
	rows, total, unread, err := s.repo.List(ctx, f)
	if err != nil {
		return nil, 0, 0, err
	}
	out := make([]dto.Notification, 0, len(rows))
	for _, row := range rows {
		out = append(out, toDTO(row))
	}
	return out, total, unread, nil
}

// MarkRead flags one notification as read. An id that belongs to another user
// or another tenant is reported as 404, never as 403.
func (s *Service) MarkRead(ctx context.Context, userID, id uuid.UUID) (dto.ReadResult, error) {
	n, err := s.repo.MarkRead(ctx, userID, id)
	if err != nil {
		return dto.ReadResult{}, err
	}
	unread, err := s.repo.Unread(ctx, userID)
	if err != nil {
		return dto.ReadResult{}, err
	}
	if n == 0 {
		// Already read is idempotent, but a foreign id must not be confirmed.
		// Unread count is still returned so the badge stays correct.
		return dto.ReadResult{Updated: 0, Unread: unread}, nil
	}
	return dto.ReadResult{Updated: n, Unread: unread}, nil
}

// MarkAllRead flags the caller's whole inbox as read.
func (s *Service) MarkAllRead(ctx context.Context, userID uuid.UUID) (dto.ReadResult, error) {
	n, err := s.repo.MarkAllRead(ctx, userID)
	if err != nil {
		return dto.ReadResult{}, err
	}
	return dto.ReadResult{Updated: n, Unread: 0}, nil
}

// RegisterPushToken records (or refreshes) one device push endpoint.
func (s *Service) RegisterPushToken(ctx context.Context, userID uuid.UUID, in dto.PushTokenCreate) (dto.PushToken, error) {
	platform := strings.ToLower(strings.TrimSpace(in.Platform))
	if !notify.IsPlatform(platform) {
		return dto.PushToken{}, apierr.Validation("unsupported platform",
			apierr.FieldError{Field: "platform", Message: "must be one of: android, ios, web"})
	}
	deviceID := strings.TrimSpace(in.DeviceID)
	token := strings.TrimSpace(in.Token)
	if deviceID == "" || token == "" {
		return dto.PushToken{}, apierr.Validation("device_id and token are required",
			apierr.FieldError{Field: "device_id", Message: "required"})
	}
	row, err := s.repo.RegisterPushToken(ctx, PushTokenInput{
		UserID: userID, DeviceID: deviceID, Platform: platform, Token: token,
		AppVersion: pgconv.NilIfEmpty(strings.TrimSpace(in.AppVersion)),
	})
	if err != nil {
		return dto.PushToken{}, err
	}
	return dto.PushToken{
		DeviceID:   row.DeviceID,
		Platform:   row.Platform,
		AppVersion: pgconv.Deref(row.AppVersion),
		LastSeenAt: row.LastSeenAt.UTC(),
	}, nil
}

// toDTO maps the sqlc row onto the wire shape; the sqlc model never leaves
// this package.
func toDTO(row db.Notification) dto.Notification {
	out := dto.Notification{
		ID:        row.ID.String(),
		AlertType: row.AlertType,
		Title:     row.Title,
		Body:      pgconv.Deref(row.Body),
		Channels:  row.Channels,
		Read:      row.ReadAt.Valid,
		ReadAt:    pgconv.ToTimePtr(row.ReadAt),
		SentAt:    pgconv.ToTimePtr(row.SentAt),
		CreatedAt: row.CreatedAt.UTC(),
	}
	out.EntityType = pgconv.Deref(row.EntityType)
	if id := pgconv.ToUUIDPtr(row.EntityID); id != nil {
		out.EntityID = id.String()
	}
	if out.Channels == nil {
		out.Channels = []string{}
	}
	return out
}
