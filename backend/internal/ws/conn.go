package ws

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Transport tuning (TZ B§3 — ping/pong every 30 s, two missed pongs drop the
// connection).
const (
	// PingPeriod is how often the server pings an idle connection.
	PingPeriod = 30 * time.Second
	// PongWait is the read deadline: two missed pongs plus a small grace.
	PongWait = 2*PingPeriod + 5*time.Second
	// WriteWait bounds a single frame write.
	WriteWait = 10 * time.Second
	// AuthWait is how long an unauthenticated socket may stay open waiting for
	// its `auth` frame.
	AuthWait = 10 * time.Second
	// ReadLimit caps an inbound frame; clients only send small control frames.
	ReadLimit int64 = 32 << 10
	// SendBuffer is the per client outbound queue; a slow consumer is dropped,
	// never allowed to block a publisher.
	SendBuffer = 256
)

// Frame types sent by a client.
const (
	TypeAuth        = "auth"
	TypeSubscribe   = "subscribe"
	TypeUnsubscribe = "unsubscribe"
	TypePing        = "ping"
)

// Frame types sent by the server.
const (
	TypeWelcome      = "welcome"
	TypeSubscribed   = "subscribed"
	TypeUnsubscribed = "unsubscribed"
	TypeEvent        = "event"
	TypeError        = "error"
	TypePong         = "pong"
)

// tokenQueryKeys are query parameters that would smuggle a credential into
// access logs, referrers and proxy caches. Their presence is a hard failure:
// TZ B§3 forbids a token in the URL outright.
var tokenQueryKeys = []string{
	"token", "access_token", "accesstoken", "access-token", "id_token", "refresh_token",
	"jwt", "bearer", "authorization", "auth", "api_key", "apikey", "key", "t",
}

// clientFrame is one inbound message.
type clientFrame struct {
	Type    string          `json:"type"`
	Token   string          `json:"token,omitempty"`
	Channel string          `json:"channel,omitempty"`
	Filter  json.RawMessage `json:"filter,omitempty"`
	Since   *time.Time      `json:"since,omitempty"`
}

// wireFilter is the on-the-wire filter object.
type wireFilter struct {
	UnitIDs   []uuid.UUID `json:"unit_ids"`
	DriverIDs []uuid.UUID `json:"driver_ids"`
	CompanyID *uuid.UUID  `json:"company_id"`
}

// serverFrame is one outbound control or event message.
type serverFrame struct {
	Type    string          `json:"type"`
	Channel string          `json:"channel,omitempty"`
	Event   string          `json:"event,omitempty"`
	Data    json.RawMessage `json:"data,omitempty"`
	Code    string          `json:"code,omitempty"`
	Message string          `json:"message,omitempty"`
	TS      time.Time       `json:"ts"`
	// Replay marks a message delivered by a `since` backfill rather than live.
	Replay bool `json:"replay,omitempty"`
}

// Deps are the WebSocket transport dependencies. Hub and Verifier are
// required; Guard defaults to PermissionGuard and Backfill is optional.
type Deps struct {
	Hub      *Hub
	Verifier mw.AuthVerifier
	Guard    Guard
	Backfill Backfiller
	Log      *slog.Logger
	Now      func() time.Time
	// AllowedOrigins is the browser origin allowlist. Empty means same-origin
	// only; "*" is accepted for development.
	AllowedOrigins []string
	// PingPeriod and PongWait override the keepalive timings. Zero keeps the
	// TZ B§3 defaults (30 s ping, two missed pongs); tests shrink them.
	PingPeriod time.Duration
	PongWait   time.Duration
}

// Module serves GET /api/v1/ws. It implements server.Module.
type Module struct {
	hub        *Hub
	verifier   mw.AuthVerifier
	guard      Guard
	backfill   Backfiller
	log        *slog.Logger
	now        func() time.Time
	upgrader   websocket.Upgrader
	pingPeriod time.Duration
	pongWait   time.Duration
}

// New builds the WebSocket transport module.
func New(deps Deps) *Module {
	m := &Module{
		hub:      deps.Hub,
		verifier: deps.Verifier,
		guard:    deps.Guard,
		backfill: deps.Backfill,
		log:      deps.Log,
		now:      deps.Now,
	}
	if m.log == nil {
		m.log = slog.Default()
	}
	if m.now == nil {
		m.now = time.Now
	}
	if m.guard == nil {
		m.guard = PermissionGuard{}
	}
	m.pingPeriod, m.pongWait = deps.PingPeriod, deps.PongWait
	if m.pingPeriod <= 0 {
		m.pingPeriod = PingPeriod
	}
	if m.pongWait <= 0 {
		m.pongWait = 2*m.pingPeriod + 5*time.Second
	}
	allowed := deps.AllowedOrigins
	m.upgrader = websocket.Upgrader{
		HandshakeTimeout: 10 * time.Second,
		ReadBufferSize:   1 << 12,
		WriteBufferSize:  1 << 12,
		CheckOrigin:      originChecker(allowed),
	}
	return m
}

// RegisterRoutes implements server.Module. The route is not authenticated by
// middleware: the handshake accepts either an Authorization header or a first
// `auth` frame, and middleware cannot express the second form.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Get("/ws", m.serve)
}

// Handler exposes the upgrade handler for tests and custom routers.
func (m *Module) Handler() http.HandlerFunc { return m.serve }

func originChecker(allowed []string) func(*http.Request) bool {
	return func(r *http.Request) bool {
		origin := strings.TrimSpace(r.Header.Get("Origin"))
		if origin == "" {
			// Non browser client (mobile, tablet): no origin to check.
			return true
		}
		for _, a := range allowed {
			if a == "*" || strings.EqualFold(a, origin) {
				return true
			}
		}
		if len(allowed) == 0 {
			// Same origin only.
			return strings.EqualFold(origin, "http://"+r.Host) || strings.EqualFold(origin, "https://"+r.Host)
		}
		return false
	}
}

// serve upgrades the connection and runs the session.
func (m *Module) serve(w http.ResponseWriter, r *http.Request) {
	if m.hub == nil {
		httpx.WriteError(w, r, apierr.New(apierr.CodeUnavailable, http.StatusServiceUnavailable,
			"realtime transport is not configured"))
		return
	}
	// A credential in the query string is rejected before anything else, so it
	// can never be treated as valid by a future refactor.
	q := r.URL.Query()
	for _, k := range tokenQueryKeys {
		if q.Has(k) {
			httpx.WriteError(w, r, apierr.Unauthorized(
				"a token must be sent in the Authorization header or an auth frame, never in the URL"))
			return
		}
	}

	var principal *tenant.Principal
	if token, ok := bearerToken(r); ok {
		p, err := m.verify(r.Context(), token)
		if err != nil {
			httpx.WriteError(w, r, err)
			return
		}
		principal = p
	}

	conn, err := m.upgrader.Upgrade(w, r, nil)
	if err != nil {
		// Upgrade already answered the request.
		return
	}
	m.run(r.Context(), conn, principal)
}

func (m *Module) verify(ctx context.Context, token string) (*tenant.Principal, error) {
	if m.verifier == nil {
		return nil, apierr.New(apierr.CodeUnavailable, http.StatusServiceUnavailable,
			"authentication is not configured")
	}
	p, err := m.verifier.VerifyAccessToken(ctx, token)
	if err != nil {
		if _, isAPI := apierr.From(err); !isAPI {
			err = apierr.Wrap(err, apierr.CodeTokenInvalid, http.StatusUnauthorized, "invalid access token")
		}
		return nil, err
	}
	if p == nil {
		return nil, apierr.Unauthorized("invalid access token")
	}
	if p.IsRestricted() {
		return nil, apierr.New(apierr.CodeTOTPSetupRequired, http.StatusForbidden,
			"two factor enrolment must be completed first")
	}
	if p.CompanyID == nil || *p.CompanyID == uuid.Nil {
		return nil, apierr.Forbidden("no active company for this session")
	}
	return p, nil
}

func bearerToken(r *http.Request) (string, bool) {
	h := r.Header.Get("Authorization")
	const prefix = "bearer "
	if len(h) <= len(prefix) || !strings.EqualFold(h[:len(prefix)], prefix) {
		return "", false
	}
	token := strings.TrimSpace(h[len(prefix):])
	return token, token != ""
}
