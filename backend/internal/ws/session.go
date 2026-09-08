package ws

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/tenant"
)

// session is one upgraded connection.
type session struct {
	m      *Module
	conn   *websocket.Conn
	client *Client
	p      *tenant.Principal

	writeMu sync.Mutex
	closed  chan struct{}
	once    sync.Once
}

// run drives one connection until it closes. principal is nil when the client
// still has to authenticate with an `auth` frame.
func (m *Module) run(ctx context.Context, conn *websocket.Conn, principal *tenant.Principal) {
	s := &session{m: m, conn: conn, p: principal, closed: make(chan struct{})}
	defer func() { _ = conn.Close() }()

	conn.SetReadLimit(ReadLimit)
	conn.SetPongHandler(func(string) error {
		return conn.SetReadDeadline(time.Now().Add(m.pongWait))
	})

	if s.p == nil {
		if !s.authenticate(ctx) {
			return
		}
	}
	_ = conn.SetReadDeadline(time.Now().Add(m.pongWait))

	// A non nil (but empty) filter map is what tells the hub "deny until this
	// client has subscribed": transport clients are never implicit listeners.
	s.client = &Client{
		ID:        uuid.New(),
		UserID:    s.p.UserID,
		CompanyID: *s.p.CompanyID,
		Scope:     s.p.Scope,
		BranchID:  s.p.BranchID,
		Send:      make(chan Message, SendBuffer),
		filters:   make(map[string]Filter, len(Channels)),
	}

	m.hub.Register(s.client)
	defer m.hub.Unregister(s.client.ID)

	s.send(serverFrame{Type: TypeWelcome, TS: m.now().UTC()})

	// The context of the upgraded request is cancelled by the server on
	// shutdown; it must take the connection down with it.
	connCtx, cancel := context.WithCancel(context.WithoutCancel(ctx))
	defer cancel()

	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		s.writePump(connCtx)
	}()

	s.readPump(connCtx)
	cancel()
	s.stop()
	wg.Wait()
}

// authenticate waits for the first frame, which must be `auth`.
func (s *session) authenticate(ctx context.Context) bool {
	_ = s.conn.SetReadDeadline(time.Now().Add(AuthWait))
	var f clientFrame
	if err := s.conn.ReadJSON(&f); err != nil {
		s.fail(apierr.Unauthorized("the first frame must be an auth frame"))
		return false
	}
	if f.Type != TypeAuth || f.Token == "" {
		s.fail(apierr.Unauthorized("the first frame must be an auth frame"))
		return false
	}
	p, err := s.m.verify(ctx, f.Token)
	if err != nil {
		s.fail(err)
		return false
	}
	s.p = p
	return true
}

// readPump reads client frames until the connection dies.
func (s *session) readPump(ctx context.Context) {
	for {
		var f clientFrame
		if err := s.conn.ReadJSON(&f); err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseNormalClosure, websocket.CloseGoingAway) {
				s.m.log.DebugContext(ctx, "ws: read closed", slog.String("error", err.Error()))
			}
			return
		}
		_ = s.conn.SetReadDeadline(time.Now().Add(s.m.pongWait))
		s.handle(ctx, f)
	}
}

// writePump owns every write: hub messages, pings and control frames all go
// through send(), which serialises on writeMu.
func (s *session) writePump(ctx context.Context) {
	ticker := time.NewTicker(s.m.pingPeriod)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-s.closed:
			return
		case msg, ok := <-s.client.Send:
			if !ok {
				return
			}
			if !s.send(serverFrame{
				Type: TypeEvent, Channel: msg.Channel, Event: msg.Event,
				Data: msg.Payload, TS: msg.SentAt,
			}) {
				return
			}
		case <-ticker.C:
			s.writeMu.Lock()
			_ = s.conn.SetWriteDeadline(time.Now().Add(WriteWait))
			err := s.conn.WriteMessage(websocket.PingMessage, nil)
			s.writeMu.Unlock()
			if err != nil {
				return
			}
		}
	}
}

// handle dispatches one client frame.
func (s *session) handle(ctx context.Context, f clientFrame) {
	switch f.Type {
	case TypePing:
		s.send(serverFrame{Type: TypePong, TS: s.m.now().UTC()})
	case TypeAuth:
		// Already authenticated; re-auth is not a way to change tenant.
		s.frameError(apierr.Conflict(apierr.CodeConflict, "this connection is already authenticated"), "")
	case TypeSubscribe:
		s.subscribe(ctx, f)
	case TypeUnsubscribe:
		if !IsChannel(f.Channel) {
			s.frameError(apierr.NotFound("channel"), f.Channel)
			return
		}
		s.m.hub.Unsubscribe(s.client.ID, f.Channel)
		s.send(serverFrame{Type: TypeUnsubscribed, Channel: f.Channel, TS: s.m.now().UTC()})
	default:
		s.frameError(apierr.BadRequest("unknown frame type"), f.Channel)
	}
}

// subscribe authorises and records one subscription, then replays `since`.
func (s *session) subscribe(ctx context.Context, f clientFrame) {
	var wf wireFilter
	if len(f.Filter) > 0 {
		if err := json.Unmarshal(f.Filter, &wf); err != nil {
			s.frameError(apierr.Validation("filter must be an object",
				apierr.FieldError{Field: "filter", Message: "invalid"}), f.Channel)
			return
		}
	}
	sub := Subscription{
		Channel: f.Channel,
		Filter:  Filter{UnitIDs: wf.UnitIDs, DriverIDs: wf.DriverIDs},
		Since:   f.Since,
	}
	if wf.CompanyID != nil {
		sub.CompanyID = *wf.CompanyID
	}

	// Every subscribe frame is authorised again — ownership is never inherited
	// from an earlier frame on the same socket.
	if err := s.m.guard.Authorize(ctx, s.p, sub); err != nil {
		s.frameError(err, f.Channel)
		return
	}
	if !s.m.hub.Subscribe(s.client.ID, sub.Channel, sub.Filter) {
		s.frameError(apierr.New(apierr.CodeUnavailable, http.StatusServiceUnavailable,
			"connection is closing"), f.Channel)
		return
	}
	s.send(serverFrame{Type: TypeSubscribed, Channel: sub.Channel, TS: s.m.now().UTC()})
	s.replay(ctx, sub)
}

// replay pushes the events a reconnecting client missed. A missing backfiller
// is not an error: the client simply gets nothing but live traffic.
func (s *session) replay(ctx context.Context, sub Subscription) {
	if sub.Since == nil || s.m.backfill == nil {
		return
	}
	since := sub.Since.UTC()
	now := s.m.now().UTC()
	if since.After(now) {
		s.frameError(apierr.New(apierr.CodeTimeInFuture, http.StatusUnprocessableEntity,
			"since must not be in the future"), sub.Channel)
		return
	}
	if oldest := now.Add(-MaxBackfillWindow); since.Before(oldest) {
		since = oldest
	}
	msgs, err := s.m.backfill.Backfill(ctx, BackfillRequest{
		CompanyID: *s.p.CompanyID,
		UserID:    s.p.UserID,
		Channel:   sub.Channel,
		Since:     since,
		Filter:    sub.Filter,
		Limit:     MaxBackfill,
	})
	if err != nil {
		s.m.log.WarnContext(ctx, "ws: backfill failed",
			slog.String("channel", sub.Channel), slog.String("error", err.Error()))
		return
	}
	for _, msg := range msgs {
		// A backfill is replayed through the same two gates as live traffic:
		// the tenant and the audience. A store that over-returns can therefore
		// not leak another tenant's or another user's events.
		if msg.CompanyID != *s.p.CompanyID || !msg.To.allows(s.client) ||
			!sub.Filter.Matches(msg.Payload) {
			continue
		}
		if !s.send(serverFrame{
			Type: TypeEvent, Channel: msg.Channel, Event: msg.Event,
			Data: msg.Payload, TS: msg.SentAt, Replay: true,
		}) {
			return
		}
	}
}

// send writes one server frame. It reports whether the write succeeded.
func (s *session) send(f serverFrame) bool {
	if f.TS.IsZero() {
		f.TS = s.m.now().UTC()
	}
	buf, err := json.Marshal(f)
	if err != nil {
		return false
	}
	s.writeMu.Lock()
	defer s.writeMu.Unlock()
	_ = s.conn.SetWriteDeadline(time.Now().Add(WriteWait))
	return s.conn.WriteMessage(websocket.TextMessage, buf) == nil
}

// frameError answers one bad frame without dropping the connection.
func (s *session) frameError(err error, channel string) {
	code, msg := apiError(err)
	s.send(serverFrame{Type: TypeError, Channel: channel, Code: code, Message: msg, TS: s.m.now().UTC()})
}

// fail answers a fatal error and closes the socket.
func (s *session) fail(err error) {
	code, msg := apiError(err)
	s.send(serverFrame{Type: TypeError, Code: code, Message: msg, TS: s.m.now().UTC()})
	s.writeMu.Lock()
	_ = s.conn.SetWriteDeadline(time.Now().Add(WriteWait))
	_ = s.conn.WriteMessage(websocket.CloseMessage,
		websocket.FormatCloseMessage(websocket.ClosePolicyViolation, code))
	s.writeMu.Unlock()
}

func (s *session) stop() { s.once.Do(func() { close(s.closed) }) }

// apiError renders an error as a wire code and a safe message.
func apiError(err error) (string, string) {
	var e *apierr.E
	if errors.As(err, &e) {
		return e.Code, e.Message
	}
	return apierr.CodeInternal, "internal server error"
}
