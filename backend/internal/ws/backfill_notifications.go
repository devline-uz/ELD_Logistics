package ws

import (
	"context"
	"encoding/json"
	"sort"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// notificationCreated mirrors internal/notify.EventNotification field for
// field. It is redeclared here rather than imported: internal/notify already
// imports internal/ws (for Publisher), so the reverse import would cycle.
// Keeping the JSON shape identical means a replayed notification is
// indistinguishable on the wire from one delivered live.
type notificationCreated struct {
	ID         uuid.UUID  `json:"id"`
	UserID     uuid.UUID  `json:"user_id"`
	AlertType  string     `json:"alert_type"`
	Title      string     `json:"title"`
	Body       string     `json:"body,omitempty"`
	EntityType string     `json:"entity_type,omitempty"`
	EntityID   *uuid.UUID `json:"entity_id,omitempty"`
	Channels   []string   `json:"channels"`
	CreatedAt  time.Time  `json:"created_at"`
}

// eventNotificationCreated is the notifications channel event name (must stay
// equal to notify.EventCreated).
const eventNotificationCreated = "notification_created"

// NotificationsBackfiller replays the notifications a reconnecting client
// missed (TZ B§3 — WS `since` backfill). It reads straight off the pool
// instead of depending on internal/domain/notifications, again to avoid the
// notify -> ws -> notifications -> notify import cycle; ListNotifications is
// an existing sqlc query, not a new one.
type NotificationsBackfiller struct {
	pool *db.Pool
}

// NewNotificationsBackfiller builds the notifications channel Backfiller.
func NewNotificationsBackfiller(pool *db.Pool) *NotificationsBackfiller {
	return &NotificationsBackfiller{pool: pool}
}

// Backfill implements Backfiller. A notification is one inbox: only the
// caller's own rows are ever queried, by its own authenticated user id.
func (b *NotificationsBackfiller) Backfill(ctx context.Context, req BackfillRequest) ([]Message, error) {
	if req.Channel != ChannelNotifications {
		return nil, nil
	}
	limit := req.Limit
	if limit <= 0 || limit > MaxBackfill {
		limit = MaxBackfill
	}
	since := req.Since
	if oldest := time.Now().UTC().Add(-MaxBackfillWindow); since.Before(oldest) {
		since = oldest
	}

	var rows []db.Notification
	err := b.pool.WithConn(ctx, req.CompanyID, func(tx pgx.Tx) error {
		var err error
		rows, err = db.New(tx).ListNotifications(ctx, db.ListNotificationsParams{
			CompanyID: req.CompanyID,
			UserID:    req.UserID,
			RowLimit:  int32(limit), //nolint:gosec // G115: limit is capped at MaxBackfill (200)
		})
		return err
	})
	if err != nil {
		return nil, err
	}

	out := make([]Message, 0, len(rows))
	for _, row := range rows {
		if !row.CreatedAt.After(since) {
			continue
		}
		payload, err := json.Marshal(notificationCreated{
			ID: row.ID, UserID: row.UserID, AlertType: row.AlertType, Title: row.Title,
			Body: pgconv.Deref(row.Body), EntityType: pgconv.Deref(row.EntityType),
			EntityID: pgconv.ToUUIDPtr(row.EntityID), Channels: row.Channels,
			CreatedAt: row.CreatedAt.UTC(),
		})
		if err != nil {
			continue
		}
		userID := row.UserID
		out = append(out, Message{
			Channel:   ChannelNotifications,
			Event:     eventNotificationCreated,
			CompanyID: req.CompanyID,
			Payload:   payload,
			SentAt:    row.CreatedAt.UTC(),
			To:        Audience{UserID: &userID},
		})
	}
	sort.Slice(out, func(i, j int) bool { return out[i].SentAt.Before(out[j].SentAt) })
	if len(out) > limit {
		out = out[len(out)-limit:]
	}
	return out, nil
}
