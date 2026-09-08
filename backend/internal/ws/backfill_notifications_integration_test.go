//go:build integration

// Integration coverage of NotificationsBackfiller: it reads through the real
// pool (ListNotifications, an existing sqlc query), so the `since` cutoff and
// the one-inbox-per-user isolation need a database.
package ws_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/testutil"
	"github.com/devline/onebook-eld/internal/ws"
)

func TestMain(m *testing.M) { testutil.RunMain(m) }

// createNotification returns the id and the database's own created_at, so a
// test can pivot `since` on the server clock instead of racing the Go
// process clock against a container's.
func createNotification(t *testing.T, pool *db.Pool, companyID, userID uuid.UUID, title string) (uuid.UUID, time.Time) {
	t.Helper()
	var row db.Notification
	err := pool.WithTx(context.Background(), companyID, func(tx pgx.Tx) error {
		var err error
		row, err = db.New(tx).CreateNotification(context.Background(), db.CreateNotificationParams{
			CompanyID: companyID, UserID: userID, AlertType: "chat_message", Title: title,
			Channels: []string{"in_app"}, SentAt: pgtype.Timestamptz{Time: time.Now().UTC(), Valid: true},
		})
		return err
	})
	require.NoError(t, err)
	return row.ID, row.CreatedAt
}

// A reconnect only ever replays the caller's own inbox: an older notification
// stays out (before `since`), a different user's notification in the same
// tenant stays out (one inbox per user), and everything is scoped to the
// tenant the request named.
func TestNotificationsBackfillReturnsOnlyOwnNotificationsAfterSince(t *testing.T) {
	t.Parallel()
	pool := testutil.NewDB(t)
	tn := testutil.SeedTenant(t)

	_, since := createNotification(t, pool, tn.ID(), tn.User.ID, "old, before since")
	time.Sleep(5 * time.Millisecond) // keep the next rows' created_at strictly later

	wantID, _ := createNotification(t, pool, tn.ID(), tn.User.ID, "new, after since")
	createNotification(t, pool, tn.ID(), tn.Driver.UserID, "new, but another user's inbox")

	b := ws.NewNotificationsBackfiller(pool)
	out, err := b.Backfill(context.Background(), ws.BackfillRequest{
		CompanyID: tn.ID(), UserID: tn.User.ID, Channel: ws.ChannelNotifications,
		Since: since, Limit: ws.MaxBackfill,
	})
	require.NoError(t, err)
	require.Len(t, out, 1, "the old and the other user's notification must not be replayed")

	msg := out[0]
	require.Equal(t, ws.ChannelNotifications, msg.Channel)
	require.Equal(t, tn.ID(), msg.CompanyID)
	require.NotNil(t, msg.To.UserID)
	require.Equal(t, tn.User.ID, *msg.To.UserID)

	var payload struct {
		ID    uuid.UUID `json:"id"`
		Title string    `json:"title"`
	}
	require.NoError(t, json.Unmarshal(msg.Payload, &payload))
	require.Equal(t, wantID, payload.ID)
}

// A notification of another tenant must never be reachable even by a request
// that otherwise looks legitimate.
func TestNotificationsBackfillNeverCrossesTenants(t *testing.T) {
	t.Parallel()
	pool := testutil.NewDB(t)
	a, b := testutil.SeedTwoCompanies(t)
	since := time.Now().UTC().Add(-time.Hour)

	_, _ = createNotification(t, pool, b.ID(), b.User.ID, "b's own notification")

	bf := ws.NewNotificationsBackfiller(pool)
	out, err := bf.Backfill(context.Background(), ws.BackfillRequest{
		CompanyID: a.ID(), UserID: b.User.ID, Channel: ws.ChannelNotifications,
		Since: since, Limit: ws.MaxBackfill,
	})
	require.NoError(t, err)
	require.Empty(t, out, "a's tenant scope must not surface b's notification even for the same user id shape")
}
