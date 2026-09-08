// Unit coverage of the WebSocket transport: both authentication forms, the
// hard ban on a token in the URL, the per subscribe ownership check, the
// keepalive timeout and the `since` backfill. No infrastructure is needed:
// the hub, the guard and the backfiller are all in process.
package ws_test

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
)

var (
	companyA = uuid.MustParse("11111111-1111-4111-8111-111111111111")
	companyB = uuid.MustParse("22222222-2222-4222-8222-222222222222")
	unitA    = uuid.MustParse("33333333-3333-4333-8333-333333333333")
	unitB    = uuid.MustParse("44444444-4444-4444-8444-444444444444")
)

// principal builds a tenant principal for the fake verifier.
func principal(companyID uuid.UUID, perms ...string) *tenant.Principal {
	return &tenant.Principal{
		UserID: uuid.New(), CompanyID: &companyID, RoleID: uuid.New(),
		Scope: tenant.ScopeAll, SessionID: uuid.New(), DeviceType: tenant.DeviceWeb,
		Permissions: perms,
	}
}

// verifier resolves opaque test tokens to principals.
type verifier map[string]*tenant.Principal

func (v verifier) VerifyAccessToken(_ context.Context, token string) (*tenant.Principal, error) {
	p, ok := v[token]
	if !ok {
		return nil, apierr.Unauthorized("invalid access token")
	}
	return p, nil
}

// unitOwner answers the tracking filter ownership question.
type unitOwner map[uuid.UUID]uuid.UUID // unit -> company

func (o unitOwner) OwnsUnits(_ context.Context, companyID uuid.UUID, ids []uuid.UUID) error {
	for _, id := range ids {
		if owner, ok := o[id]; !ok || owner != companyID {
			return apierr.NotFound("unit")
		}
	}
	return nil
}

// backfiller replays a fixed set of messages.
type backfiller struct {
	msgs []ws.Message
	last ws.BackfillRequest
}

func (b *backfiller) Backfill(_ context.Context, req ws.BackfillRequest) ([]ws.Message, error) {
	b.last = req
	out := make([]ws.Message, 0, len(b.msgs))
	for _, m := range b.msgs {
		if m.Channel == req.Channel && !m.SentAt.Before(req.Since) {
			out = append(out, m)
		}
	}
	return out, nil
}

type harness struct {
	srv  *httptest.Server
	hub  *ws.Hub
	fill *backfiller
}

func newHarness(t *testing.T, v verifier, opts ...func(*ws.Deps)) *harness {
	t.Helper()
	hub := ws.NewHub(nil)
	fill := &backfiller{}
	deps := ws.Deps{
		Hub:            hub,
		Verifier:       v,
		Guard:          ws.PermissionGuard{Units: unitOwner{unitA: companyA, unitB: companyB}},
		Backfill:       fill,
		AllowedOrigins: []string{"*"},
	}
	for _, o := range opts {
		o(&deps)
	}
	mod := ws.New(deps)

	r := chi.NewRouter()
	r.Route("/api/v1", func(api chi.Router) { mod.RegisterRoutes(api) })
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)
	return &harness{srv: srv, hub: hub, fill: fill}
}

func (h *harness) url() string {
	return "ws" + strings.TrimPrefix(h.srv.URL, "http") + "/api/v1/ws"
}

// dial opens a socket, optionally with an Authorization header.
func (h *harness) dial(t *testing.T, token string) (*websocket.Conn, *http.Response) {
	t.Helper()
	header := http.Header{}
	if token != "" {
		header.Set("Authorization", "Bearer "+token)
	}
	conn, resp, err := websocket.DefaultDialer.Dial(h.url(), header)
	if err != nil {
		return nil, resp
	}
	t.Cleanup(func() { _ = conn.Close() })
	return conn, resp
}

// closeResp releases the handshake response body; gorilla always leaves it
// as an in-memory NopCloser, but callers must still close it explicitly.
func closeResp(resp *http.Response) {
	if resp != nil {
		_ = resp.Body.Close()
	}
}

// frame is the server side wire shape.
type frame struct {
	Type    string          `json:"type"`
	Channel string          `json:"channel"`
	Event   string          `json:"event"`
	Data    json.RawMessage `json:"data"`
	Code    string          `json:"code"`
	Message string          `json:"message"`
	TS      time.Time       `json:"ts"`
	Replay  bool            `json:"replay"`
}

func readFrame(t *testing.T, conn *websocket.Conn) frame {
	t.Helper()
	require.NoError(t, conn.SetReadDeadline(time.Now().Add(3*time.Second)))
	var f frame
	require.NoError(t, conn.ReadJSON(&f))
	return f
}

func send(t *testing.T, conn *websocket.Conn, v any) {
	t.Helper()
	require.NoError(t, conn.SetWriteDeadline(time.Now().Add(3*time.Second)))
	require.NoError(t, conn.WriteJSON(v))
}

// ------------------------------------------------------------- authentication

func TestAuthorizationHeaderAuthenticates(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"good": principal(companyA, auth.PermTrackingViewLive)})

	conn, resp := h.dial(t, "good")
	defer closeResp(resp)
	require.NotNil(t, conn)
	require.Equal(t, "welcome", readFrame(t, conn).Type)
}

func TestAuthFrameAuthenticates(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"good": principal(companyA, auth.PermTrackingViewLive)})

	conn, resp := h.dial(t, "")
	defer closeResp(resp)
	require.NotNil(t, conn)
	send(t, conn, map[string]string{"type": "auth", "token": "good"})
	require.Equal(t, "welcome", readFrame(t, conn).Type)
}

func TestTokenInQueryIsRejected(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"good": principal(companyA)})

	// TZ B§3: a credential in the URL is a hard failure, even a valid one.
	for _, key := range []string{"token", "access_token", "jwt", "authorization", "api_key"} {
		conn, resp, err := websocket.DefaultDialer.Dial(h.url()+"?"+key+"=good", nil)
		require.Error(t, err, "query parameter %q must not be accepted", key)
		require.Nil(t, conn)
		require.NotNil(t, resp)
		require.Equal(t, http.StatusUnauthorized, resp.StatusCode)
		_ = resp.Body.Close()
	}
}

func TestBadTokenIsRejectedBeforeUpgrade(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{})

	conn, resp := h.dial(t, "nope")
	defer closeResp(resp)
	require.Nil(t, conn)
	require.NotNil(t, resp)
	require.Equal(t, http.StatusUnauthorized, resp.StatusCode)
}

func TestFirstFrameMustBeAuth(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"good": principal(companyA)})

	conn, resp := h.dial(t, "")
	defer closeResp(resp)
	require.NotNil(t, conn)
	send(t, conn, map[string]string{"type": "subscribe", "channel": "notifications"})

	f := readFrame(t, conn)
	require.Equal(t, "error", f.Type)
	require.Equal(t, apierr.CodeUnauthorized, f.Code)
}

// --------------------------------------------------------------- subscriptions

func TestSubscribeRequiresChannelPermission(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"tok": principal(companyA, auth.PermNotificationsRead)})

	conn, resp := h.dial(t, "tok")
	defer closeResp(resp)
	require.Equal(t, "welcome", readFrame(t, conn).Type)

	// notifications only needs authentication.
	send(t, conn, map[string]string{"type": "subscribe", "channel": "notifications"})
	require.Equal(t, "subscribed", readFrame(t, conn).Type)

	// tracking needs tracking.view_live, which this principal lacks.
	send(t, conn, map[string]string{"type": "subscribe", "channel": "tracking"})
	f := readFrame(t, conn)
	require.Equal(t, "error", f.Type)
	require.Equal(t, apierr.CodeForbidden, f.Code)

	send(t, conn, map[string]string{"type": "subscribe", "channel": "nope"})
	require.Equal(t, apierr.CodeNotFound, readFrame(t, conn).Code)
}

func TestSubscribeRejectsAnotherTenant(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"tok": principal(companyA, auth.PermTrackingViewLive)})

	conn, resp := h.dial(t, "tok")
	defer closeResp(resp)
	require.Equal(t, "welcome", readFrame(t, conn).Type)

	// Naming another company in the filter is forbidden ...
	send(t, conn, map[string]any{
		"type": "subscribe", "channel": "tracking",
		"filter": map[string]any{"company_id": companyB.String()},
	})
	f := readFrame(t, conn)
	require.Equal(t, "error", f.Type)
	require.Equal(t, apierr.CodeForbidden, f.Code)

	// ... and so is a unit of another company (404, never 403: the existence
	// of a foreign unit is not confirmed).
	send(t, conn, map[string]any{
		"type": "subscribe", "channel": "tracking",
		"filter": map[string]any{"unit_ids": []string{unitB.String()}},
	})
	require.Equal(t, apierr.CodeNotFound, readFrame(t, conn).Code)
}

func TestPublishReachesOnlySubscribersOfTheSameCompany(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{
		"a": principal(companyA, auth.PermTrackingViewLive),
		"b": principal(companyB, auth.PermTrackingViewLive),
	})

	connA, respA := h.dial(t, "a")
	defer closeResp(respA)
	require.Equal(t, "welcome", readFrame(t, connA).Type)
	send(t, connA, map[string]any{
		"type": "subscribe", "channel": "tracking",
		"filter": map[string]any{"unit_ids": []string{unitA.String()}},
	})
	require.Equal(t, "subscribed", readFrame(t, connA).Type)

	connB, respB := h.dial(t, "b")
	defer closeResp(respB)
	require.Equal(t, "welcome", readFrame(t, connB).Type)
	send(t, connB, map[string]string{"type": "subscribe", "channel": "tracking"})
	require.Equal(t, "subscribed", readFrame(t, connB).Type)

	// A message of company B never reaches the client of company A.
	payload := json.RawMessage(`{"unit_id":"` + unitB.String() + `"}`)
	require.NoError(t, h.hub.Publish(context.Background(), ws.Message{
		Channel: ws.ChannelTracking, Event: "unit_last_state",
		CompanyID: companyB, Payload: payload,
	}))
	f := readFrame(t, connB)
	require.Equal(t, "event", f.Type)
	require.Equal(t, ws.ChannelTracking, f.Channel)

	// The filter of client A drops a unit it did not ask for.
	require.NoError(t, h.hub.Publish(context.Background(), ws.Message{
		Channel: ws.ChannelTracking, Event: "unit_last_state", CompanyID: companyA,
		Payload: json.RawMessage(`{"unit_id":"` + uuid.NewString() + `"}`),
	}))
	require.NoError(t, h.hub.Publish(context.Background(), ws.Message{
		Channel: ws.ChannelTracking, Event: "unit_last_state", CompanyID: companyA,
		Payload: json.RawMessage(`{"unit_id":"` + unitA.String() + `"}`),
	}))
	f = readFrame(t, connA)
	require.Equal(t, "event", f.Type)
	require.Contains(t, string(f.Data), unitA.String())
}

func TestUnsubscribeStopsDelivery(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"a": principal(companyA, auth.PermNotificationsRead)})

	conn, resp := h.dial(t, "a")
	defer closeResp(resp)
	require.Equal(t, "welcome", readFrame(t, conn).Type)
	send(t, conn, map[string]string{"type": "subscribe", "channel": "notifications"})
	require.Equal(t, "subscribed", readFrame(t, conn).Type)
	send(t, conn, map[string]string{"type": "unsubscribe", "channel": "notifications"})
	require.Equal(t, "unsubscribed", readFrame(t, conn).Type)

	require.NoError(t, h.hub.Publish(context.Background(), ws.Message{
		Channel: ws.ChannelNotifications, Event: "notification_created",
		CompanyID: companyA, Payload: json.RawMessage(`{}`),
	}))
	// Nothing must arrive; a pong answer proves the socket is still alive.
	send(t, conn, map[string]string{"type": "ping"})
	require.Equal(t, "pong", readFrame(t, conn).Type)
}

// ------------------------------------------------------------------- backfill

func TestSinceReplaysMissedEvents(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"a": principal(companyA, auth.PermChatRead)})
	since := time.Date(2026, 9, 6, 17, 55, 0, 0, time.UTC)
	h.fill.msgs = []ws.Message{
		{Channel: ws.ChannelChat, Event: "chat_message", CompanyID: companyA,
			Payload: json.RawMessage(`{"id":"old"}`), SentAt: since.Add(-time.Hour)},
		{Channel: ws.ChannelChat, Event: "chat_message", CompanyID: companyA,
			Payload: json.RawMessage(`{"id":"new"}`), SentAt: since.Add(time.Minute)},
	}

	conn, resp := h.dial(t, "a")
	defer closeResp(resp)
	require.Equal(t, "welcome", readFrame(t, conn).Type)
	send(t, conn, map[string]any{
		"type": "subscribe", "channel": "chat", "since": since.Format(time.RFC3339),
	})
	require.Equal(t, "subscribed", readFrame(t, conn).Type)

	f := readFrame(t, conn)
	require.Equal(t, "event", f.Type)
	require.True(t, f.Replay, "a replayed frame must be marked")
	require.Contains(t, string(f.Data), `"new"`)
	require.Equal(t, since, h.fill.last.Since)
	require.Equal(t, ws.MaxBackfill, h.fill.last.Limit)
}

func TestSinceInTheFutureIsRejected(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"a": principal(companyA, auth.PermChatRead)})

	conn, resp := h.dial(t, "a")
	defer closeResp(resp)
	require.Equal(t, "welcome", readFrame(t, conn).Type)
	send(t, conn, map[string]any{
		"type": "subscribe", "channel": "chat",
		"since": time.Now().Add(time.Hour).UTC().Format(time.RFC3339),
	})
	require.Equal(t, "subscribed", readFrame(t, conn).Type)
	f := readFrame(t, conn)
	require.Equal(t, "error", f.Type)
	require.Equal(t, apierr.CodeTimeInFuture, f.Code)
}

func TestSinceIsClampedToTheBackfillWindow(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"a": principal(companyA, auth.PermChatRead)})

	conn, resp := h.dial(t, "a")
	defer closeResp(resp)
	require.Equal(t, "welcome", readFrame(t, conn).Type)
	send(t, conn, map[string]any{
		"type": "subscribe", "channel": "chat",
		"since": time.Now().Add(-72 * time.Hour).UTC().Format(time.RFC3339),
	})
	require.Equal(t, "subscribed", readFrame(t, conn).Type)
	send(t, conn, map[string]string{"type": "ping"})
	require.Equal(t, "pong", readFrame(t, conn).Type)

	require.WithinDuration(t, time.Now().Add(-ws.MaxBackfillWindow), h.fill.last.Since, time.Minute)
}

// ------------------------------------------------------------------ keepalive

func TestMissedPongsCloseTheConnection(t *testing.T) {
	t.Parallel()
	h := newHarness(t, verifier{"a": principal(companyA)}, func(d *ws.Deps) {
		d.PingPeriod = 50 * time.Millisecond
		d.PongWait = 150 * time.Millisecond // two missed pongs
	})

	conn, resp := h.dial(t, "a")
	defer closeResp(resp)
	require.Equal(t, "welcome", readFrame(t, conn).Type)
	// Suppress the automatic pong so the server sees a silent peer.
	conn.SetPingHandler(func(string) error { return nil })

	require.NoError(t, conn.SetReadDeadline(time.Now().Add(3*time.Second)))
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		if _, _, err := conn.ReadMessage(); err != nil {
			return // the server dropped the silent client, as required
		}
	}
	t.Fatal("a client that never answers a ping must be disconnected")
}

func TestKeepaliveDefaultsFollowTheSecurityBaseline(t *testing.T) {
	t.Parallel()
	// TZ B§3: ping every 30 s, disconnect after two missed pongs.
	require.Equal(t, 30*time.Second, ws.PingPeriod)
	require.GreaterOrEqual(t, ws.PongWait, 2*ws.PingPeriod)
}

func TestHubPresenceTracksConnectedUsers(t *testing.T) {
	t.Parallel()
	p := principal(companyA, auth.PermChatRead)
	h := newHarness(t, verifier{"a": p})

	require.False(t, h.hub.IsOnline(companyA, p.UserID))
	conn, resp := h.dial(t, "a")
	defer closeResp(resp)
	require.Equal(t, "welcome", readFrame(t, conn).Type)
	require.True(t, h.hub.IsOnline(companyA, p.UserID))
	require.False(t, h.hub.IsOnline(companyB, p.UserID))
}
