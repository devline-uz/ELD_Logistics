// Security regression coverage of the dispatcher fan-out. The `notifications`
// WebSocket channel is gated by authentication only — every user of a company
// may subscribe to it — so a notification must be addressed to its owner and
// never broadcast to the tenant.
package notify_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/notify"
)

func TestPublishedNotificationIsAddressedToItsOwner(t *testing.T) {
	t.Parallel()
	f := newFixture(t)

	require.NoError(t, f.disp.Send(context.Background(), notify.Notification{
		CompanyID: companyID, UserID: driverID,
		AlertType: notify.AlertHOSWarning, Title: "Break due in 30 minutes",
	}))

	require.Len(t, f.pub.msgs, 1)
	to := f.pub.msgs[0].To
	require.False(t, to.IsZero(), "an inbox event must not be a company wide broadcast")
	require.NotNil(t, to.UserID)
	require.Equal(t, driverID, *to.UserID)
	require.False(t, to.Office, "a notification has exactly one recipient")
}

// A role addressed event expands into one notification per recipient, and each
// of them must still be addressed individually.
func TestBroadcastAddressesEachRecipientSeparately(t *testing.T) {
	t.Parallel()
	f := newFixture(t)

	require.NoError(t, f.disp.Broadcast(context.Background(), notify.Event{
		CompanyID: companyID, AlertType: notify.AlertDVIRDefects,
		Title: "Defects reported", Users: []uuid.UUID{driverID, adminID},
	}))

	require.NotEmpty(t, f.pub.msgs)
	seen := make(map[uuid.UUID]bool, len(f.pub.msgs))
	for _, m := range f.pub.msgs {
		require.NotNil(t, m.To.UserID, "every fan-out message must name its recipient")
		seen[*m.To.UserID] = true
	}
	require.True(t, seen[driverID])
	require.True(t, seen[adminID])
}
