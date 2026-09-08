package ws_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/ws"
)

// A channel this backfiller does not own must be a no-op and, crucially, must
// never touch the pool: passing a nil pool here proves it, since a query
// attempt would panic.
func TestNotificationsBackfillIgnoresOtherChannels(t *testing.T) {
	t.Parallel()
	b := ws.NewNotificationsBackfiller(nil)
	out, err := b.Backfill(context.Background(), ws.BackfillRequest{
		Channel: ws.ChannelChat, CompanyID: uuid.New(), UserID: uuid.New(), Since: time.Now(),
	})
	require.NoError(t, err)
	require.Nil(t, out)
}
