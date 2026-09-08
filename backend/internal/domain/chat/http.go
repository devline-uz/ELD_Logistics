package chat

import (
	"context"
	"log/slog"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/chat/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
)

// Cursor page bounds of the message history.
const (
	defaultHistoryLimit = 50
	maxHistoryLimit     = 200
)

// Deps are the chat module dependencies. Repo and Verifier are required; the
// publisher, the alert dispatcher and presence are optional.
type Deps struct {
	Repo      Repo
	Verifier  mw.AuthVerifier
	Store     cache.Store
	Publisher ws.Publisher
	Alerts    Alerts
	Presence  Presence
	Log       *slog.Logger
	Now       func() time.Time
}

// Module wires the chat routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the chat HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo, deps.Publisher, deps.Alerts, deps.Presence, deps.Log, deps.Now),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// Service exposes the business layer to a composing module.
func (m *Module) Service() *Service { return m.svc }

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}

		g.With(mw.RequirePermission(auth.PermChatRead)).Get("/chat/threads", m.threads)
		g.With(mw.RequirePermission(auth.PermChatRead)).Get("/chat/threads/{driver_id}/messages", m.history)
		g.With(mw.RequirePermission(auth.PermChatSend)).Post("/chat/threads/{driver_id}/messages", m.send)
		g.With(mw.RequirePermission(auth.PermChatRead)).Post("/chat/messages/{id}/read", m.markRead)
	})
}

// threads godoc
//
//	@Summary      List chat threads
//	@Description  TZ §15.4 — the office side receives one thread per driver, newest activity first; drivers that never exchanged a message are included so a conversation can be started. A self scoped principal (driver) always receives exactly one thread, its own "Dispatch" conversation, whatever the query says. A branch scoped principal only sees the drivers of its branch.
//	@Tags         chat
//	@Produce      json
//	@Param        page     query     int   false  "Page number"                        default(1)
//	@Param        per_page query     int   false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        with_messages query bool false  "Only threads that already hold a message"
//	@Success      200  {object}  dto.ThreadListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "chat.read"
//	@Router       /chat/threads [get]
func (m *Module) threads(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok {
		httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
		return
	}
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	// A driver holds exactly one thread; the list endpoint returns it so the
	// mobile client uses the same shape as the web client.
	if p.Scope == tenant.ScopeSelf {
		driver, err := m.svc.DriverOf(ctx, p.UserID)
		if err != nil {
			httpx.WriteError(w, r, err)
			return
		}
		threads, _, err := m.svc.Threads(ctx, ThreadFilter{
			DriverID: &driver.ID, IncludeEmpty: true, Limit: 1, Offset: 0,
		})
		if err != nil {
			httpx.WriteError(w, r, err)
			return
		}
		out := ownThread(threads, driver)
		httpx.WriteList(w, out, httpx.Meta{Page: 1, PerPage: len(out), Total: int64(len(out))})
		return
	}

	f := ThreadFilter{IncludeEmpty: true, Limit: page.Limit(), Offset: page.Offset()}
	if raw := strings.TrimSpace(r.URL.Query().Get("with_messages")); raw != "" {
		v, parseErr := strconv.ParseBool(raw)
		if parseErr != nil {
			httpx.WriteError(w, r, apierr.Validation("invalid filter",
				apierr.FieldError{Field: "with_messages", Message: "must be true or false"}))
			return
		}
		f.IncludeEmpty = !v
	}
	if sf, ok := mw.ScopeFrom(ctx); ok && sf.Scope == tenant.ScopeBranch {
		f.BranchID = sf.BranchID
	}

	threads, total, err := m.svc.Threads(ctx, f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, threads, page.Meta(total))
}

// history godoc
//
//	@Summary      Read a chat thread
//	@Description  TZ §15.4 — cursor pagination, newest message first. Pass `before` (the `meta.next_before` of the previous page) to walk backwards; `meta.has_more` reports whether older messages exist. A driver may only read its own thread; another driver's id answers 404, never 403.
//	@Tags         chat
//	@Produce      json
//	@Param        driver_id  path      string  true   "Driver id"  format(uuid)
//	@Param        before     query     string  false  "Cursor: return messages sent strictly before this instant"  format(date-time)
//	@Param        limit      query     int     false  "Page size (max 200)"  default(50)
//	@Success      200  {object}  dto.MessageListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "chat.read"
//	@Router       /chat/threads/{driver_id}/messages [get]
func (m *Module) history(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	p, driver, err := m.resolveThread(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f := HistoryFilter{DriverID: driver.ID, Limit: defaultHistoryLimit}
	q := r.URL.Query()
	if raw := strings.TrimSpace(q.Get("limit")); raw != "" {
		v, convErr := strconv.Atoi(raw)
		if convErr != nil || v < 1 || v > maxHistoryLimit {
			httpx.WriteError(w, r, apierr.Validation("invalid limit",
				apierr.FieldError{Field: "limit", Message: "must be between 1 and 200"}))
			return
		}
		f.Limit = int32(v) //nolint:gosec // G109: v is validated to [1,maxHistoryLimit] above
	}
	if raw := strings.TrimSpace(q.Get("before")); raw != "" {
		ts, convErr := time.Parse(time.RFC3339, raw)
		if convErr != nil {
			httpx.WriteError(w, r, apierr.Validation("invalid cursor",
				apierr.FieldError{Field: "before", Message: "must be an RFC 3339 timestamp"}))
			return
		}
		utc := ts.UTC()
		f.Before = &utc
	}

	items, meta, err := m.svc.History(ctx, driver, f, p.UserID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, dto.MessageListEnvelope{Data: items, Meta: meta})
}

// send godoc
//
//	@Summary      Send a chat message
//	@Description  TZ §15.4 — text (max 2000 characters), an image or PDF referenced by the `file_key` of POST /files/presign (max 10 MB, enforced at presign time), or a shared location. While the driver is in DR the driver side is blocked and answers 409 `DRIVING_MODE_BLOCKED` (driver distraction policy); the office may still write, and the app shows the message once the driver leaves DR. Delivery is WebSocket `chat` plus a push when the recipient is not connected.
//	@Tags         chat
//	@Accept       json
//	@Produce      json
//	@Param        driver_id  path      string             true  "Driver id"  format(uuid)
//	@Param        body       body      dto.MessageCreate  true  "Message payload"
//	@Success      201  {object}  dto.MessageEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "DRIVING_MODE_BLOCKED"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR / MESSAGE_TOO_LONG"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "chat.send"
//	@Router       /chat/threads/{driver_id}/messages [post]
func (m *Module) send(w http.ResponseWriter, r *http.Request) {
	p, driver, err := m.resolveThread(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.MessageCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	msg, err := m.svc.Send(r.Context(), driver, p.UserID, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, msg)
}

// markRead godoc
//
//	@Summary      Acknowledge a chat message
//	@Description  TZ §15.4 — moves the message to `read`. Only the other side may acknowledge a message: acknowledging your own answers 200 with `updated: 0`. A message of another company answers 404.
//	@Tags         chat
//	@Produce      json
//	@Param        id   path      string  true  "Message id"  format(uuid)
//	@Success      200  {object}  dto.ReadResultEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "chat.read"
//	@Router       /chat/messages/{id}/read [post]
func (m *Module) markRead(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok {
		httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
		return
	}
	id, err := uuid.Parse(chi.URLParam(r, "id"))
	if err != nil {
		httpx.WriteError(w, r, apierr.Validation("invalid id",
			apierr.FieldError{Field: "id", Message: "must be a valid uuid"}))
		return
	}
	// The thread is resolved and scope checked BEFORE the receipt is written:
	// acknowledging a foreign thread must not mutate it, and must not publish a
	// `chat_message_read` event carrying its content.
	driver, err := m.svc.ThreadOf(ctx, id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := allowThread(ctx, driver); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	res, _, err := m.svc.MarkRead(ctx, driver, id, p.UserID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, res)
}

// resolveThread validates the driver_id path parameter against the caller's
// scope. Cross-tenant and out-of-scope ids map to 404, never 403.
func (m *Module) resolveThread(r *http.Request) (*tenant.Principal, Driver, error) {
	ctx := r.Context()
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok {
		return nil, Driver{}, apierr.Unauthorized("authentication required")
	}
	driverID, err := uuid.Parse(chi.URLParam(r, "driver_id"))
	if err != nil {
		return nil, Driver{}, apierr.Validation("invalid driver id",
			apierr.FieldError{Field: "driver_id", Message: "must be a valid uuid"})
	}
	driver, err := m.svc.Thread(ctx, driverID)
	if err != nil {
		return nil, Driver{}, err
	}
	if err := allowThread(ctx, driver); err != nil {
		return nil, Driver{}, err
	}
	return p, driver, nil
}

// allowThread applies the caller's scope to one thread. Out of scope maps to
// 404, never 403, so the existence of another driver's conversation is never
// confirmed.
func allowThread(ctx context.Context, driver Driver) error {
	sf, ok := mw.ScopeFrom(ctx)
	if !ok {
		return nil
	}
	if sf.Scope == tenant.ScopeSelf && !sf.AllowsUser(driver.UserID) {
		return apierr.NotFound("thread")
	}
	if !sf.AllowsBranch(driver.BranchID) {
		return apierr.NotFound("thread")
	}
	return nil
}

// ownThread keeps only the driver's own conversation in the list response.
func ownThread(threads []dto.Thread, driver Driver) []dto.Thread {
	for _, t := range threads {
		if t.DriverID == driver.ID.String() {
			return []dto.Thread{t}
		}
	}
	return []dto.Thread{{
		DriverID:     driver.ID.String(),
		DriverName:   strings.TrimSpace(driver.FirstName + " " + driver.LastName),
		DriverStatus: driver.Status,
	}}
}
