// Security regression coverage of the hub audience. Tenant isolation was
// already enforced; these tests pin the second gate: inside one company an
// addressed message (a personal notification, one chat thread) must not reach
// every subscriber that merely holds the channel permission.
package ws_test

import (
	"context"
	"encoding/json"
	"net/http"
	"net/url"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
)

// client registers a subscriber directly on the hub.
func client(t *testing.T, hub *ws.Hub, companyID, userID uuid.UUID, scope tenant.Scope, channel string) *ws.Client {
	t.Helper()
	c := &ws.Client{
		ID: uuid.New(), UserID: userID, CompanyID: companyID, Scope: scope,
		Channels: []string{channel}, Send: make(chan ws.Message, 4),
	}
	hub.Register(c)
	t.Cleanup(func() { hub.Unregister(c.ID) })
	return c
}

func drained(c *ws.Client) []ws.Message {
	out := make([]ws.Message, 0, len(c.Send))
	for {
		select {
		case m := <-c.Send:
			out = append(out, m)
		default:
			return out
		}
	}
}

func TestNotificationReachesOnlyItsOwner(t *testing.T) {
	hub := ws.NewHub(nil)
	owner := uuid.New()
	other := uuid.New()
	mine := client(t, hub, companyA, owner, tenant.ScopeAll, ws.ChannelNotifications)
	theirs := client(t, hub, companyA, other, tenant.ScopeAll, ws.ChannelNotifications)

	require.NoError(t, hub.Publish(context.Background(), ws.Message{
		Channel: ws.ChannelNotifications, Event: "notification",
		CompanyID: companyA, Payload: json.RawMessage(`{"title":"payroll"}`),
		To: ws.Audience{UserID: &owner},
	}))

	require.Len(t, drained(mine), 1)
	require.Empty(t, drained(theirs), "another user's inbox must not be broadcast")
}

func TestChatThreadReachesOnlyItsDriverAndTheOffice(t *testing.T) {
	hub := ws.NewHub(nil)
	driver := uuid.New()
	otherDriver := uuid.New()
	office := uuid.New()

	own := client(t, hub, companyA, driver, tenant.ScopeSelf, ws.ChannelChat)
	foreign := client(t, hub, companyA, otherDriver, tenant.ScopeSelf, ws.ChannelChat)
	dispatch := client(t, hub, companyA, office, tenant.ScopeAll, ws.ChannelChat)
	otherTenant := client(t, hub, companyB, uuid.New(), tenant.ScopeAll, ws.ChannelChat)

	require.NoError(t, hub.Publish(context.Background(), ws.Message{
		Channel: ws.ChannelChat, Event: "chat_message",
		CompanyID: companyA, Payload: json.RawMessage(`{"text":"pick up at dock 4"}`),
		To: ws.Audience{UserID: &driver, Office: true},
	}))

	require.Len(t, drained(own), 1)
	require.Len(t, drained(dispatch), 1)
	require.Empty(t, drained(foreign), "a driver must not read another driver's thread")
	require.Empty(t, drained(otherTenant))
}

func TestAddressedMessageStaysInsideItsBranch(t *testing.T) {
	hub := ws.NewHub(nil)
	branch := uuid.New()
	elsewhere := uuid.New()
	driver := uuid.New()

	inBranch := client(t, hub, companyA, uuid.New(), tenant.ScopeBranch, ws.ChannelChat)
	inBranch.BranchID = &branch
	outBranch := client(t, hub, companyA, uuid.New(), tenant.ScopeBranch, ws.ChannelChat)
	outBranch.BranchID = &elsewhere

	require.NoError(t, hub.Publish(context.Background(), ws.Message{
		Channel: ws.ChannelChat, Event: "chat_message", CompanyID: companyA,
		Payload: json.RawMessage(`{"text":"hi"}`),
		To:      ws.Audience{UserID: &driver, Office: true, BranchID: &branch},
	}))

	require.Len(t, drained(inBranch), 1)
	require.Empty(t, drained(outBranch))
}

func TestBroadcastStillReachesEverySubscriber(t *testing.T) {
	hub := ws.NewHub(nil)
	a := client(t, hub, companyA, uuid.New(), tenant.ScopeAll, ws.ChannelDashboard)
	b := client(t, hub, companyA, uuid.New(), tenant.ScopeSelf, ws.ChannelDashboard)

	require.NoError(t, hub.Publish(context.Background(), ws.Message{
		Channel: ws.ChannelDashboard, Event: "dashboard_summary",
		CompanyID: companyA, Payload: json.RawMessage(`{}`),
	}))

	require.Len(t, drained(a), 1)
	require.Len(t, drained(b), 1)
}

// The bridge must not let one node hand another tenant's traffic to its local
// subscribers: the hub filters on company_id, whatever the envelope claims.
func TestBridgeDeliveryStillHonoursTheTenant(t *testing.T) {
	hub := ws.NewHub(nil)
	c := client(t, hub, companyA, uuid.New(), tenant.ScopeAll, ws.ChannelDashboard)
	bridge := ws.NewBridge(nil, hub, nil)

	require.NoError(t, bridge.Publish(context.Background(), ws.Message{
		Channel: ws.ChannelDashboard, Event: "dashboard_summary",
		CompanyID: companyB, Payload: json.RawMessage(`{}`),
	}))
	require.Empty(t, drained(c))
}

// Every spelling of a credential in the query string is refused before the
// upgrade, so a token can never reach an access log or a referrer header.
func TestEveryTokenQueryKeyIsRejected(t *testing.T) {
	tok := "office"
	h := newHarness(t, verifier{tok: principal(companyA, auth.PermDashboardRead)})

	for _, key := range []string{
		"token", "access_token", "accesstoken", "access-token", "id_token",
		"refresh_token", "jwt", "bearer", "authorization", "auth", "api_key",
		"apikey", "key", "t",
	} {
		t.Run(key, func(t *testing.T) {
			q := url.Values{key: []string{tok}}
			conn, resp, err := websocket.DefaultDialer.Dial(h.url()+"?"+q.Encode(), nil)
			require.Error(t, err, "%s must not be accepted as a credential carrier", key)
			require.Nil(t, conn)
			require.NotNil(t, resp)
			require.Equal(t, http.StatusUnauthorized, resp.StatusCode)
			_ = resp.Body.Close()
		})
	}
}

// A backfill store that over-returns must not become a bypass: the replay is
// filtered by tenant and audience exactly like live traffic.
func TestBackfillDropsForeignAndUnaddressedEvents(t *testing.T) {
	tok := "driver"
	p := principal(companyA, auth.PermChatRead)
	p.Scope = tenant.ScopeSelf
	v := verifier{tok: p}

	stranger := uuid.New()
	past := time.Now().Add(-time.Minute).UTC()
	h := newHarness(t, v, func(d *ws.Deps) {
		d.Backfill = &backfiller{msgs: []ws.Message{
			{Channel: ws.ChannelChat, Event: "chat_message", CompanyID: companyB,
				Payload: json.RawMessage(`{"text":"other tenant"}`), SentAt: past},
			{Channel: ws.ChannelChat, Event: "chat_message", CompanyID: companyA,
				Payload: json.RawMessage(`{"text":"other driver"}`), SentAt: past,
				To: ws.Audience{UserID: &stranger, Office: true}},
			{Channel: ws.ChannelChat, Event: "chat_message", CompanyID: companyA,
				Payload: json.RawMessage(`{"text":"mine"}`), SentAt: past,
				To: ws.Audience{UserID: &p.UserID, Office: true}},
		}}
	})

	conn, resp := h.dial(t, tok)
	defer closeResp(resp)
	require.NotNil(t, conn)
	require.Equal(t, ws.TypeWelcome, readFrame(t, conn).Type)

	since := past.Add(-time.Minute)
	send(t, conn, map[string]any{"type": ws.TypeSubscribe, "channel": ws.ChannelChat, "since": since})
	require.Equal(t, ws.TypeSubscribed, readFrame(t, conn).Type)

	f := readFrame(t, conn)
	require.Equal(t, ws.TypeEvent, f.Type)
	require.True(t, f.Replay)
	require.Contains(t, string(f.Data), "mine")

	// Nothing else may follow: both other events are filtered out.
	_ = conn.SetReadDeadline(time.Now().Add(300 * time.Millisecond))
	_, _, err := conn.ReadMessage()
	require.Error(t, err)
}
