package notifications

import (
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/notifications/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Deps are the notification module dependencies. Repo and Verifier are
// required; Store only adds the per user rate limit.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	Store    cache.Store
}

// Module wires the notification routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the notification HTTP module.
func New(deps Deps) *Module {
	return &Module{svc: NewService(deps.Repo), verifier: deps.Verifier, store: deps.Store}
}

// Service exposes the business layer so a composing module can reuse it.
func (m *Module) Service() *Service { return m.svc }

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		// Unconditional: a module wired without a verifier must fail closed.
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}

		g.With(mw.RequirePermission(auth.PermNotificationsRead)).Get("/notifications", m.list)
		g.With(mw.RequirePermission(auth.PermNotificationsRead)).Patch("/notifications/{id}/read", m.markRead)
		g.With(mw.RequirePermission(auth.PermNotificationsRead)).Post("/notifications/read-all", m.markAllRead)
		g.With(mw.RequirePermission(auth.PermNotificationsRead)).Post("/devices/push-token", m.registerToken)
	})
}

// list godoc
//
//	@Summary      List notifications
//	@Description  TZ A§19 / Q87 — the caller's own inbox, newest first. The inbox is personal: there is no way to read another user's notifications. `read` filters on the read state (`true` = read only, `false` = unread only) and `alert_type` on one alert family. `meta.unread` is the badge counter and ignores both filters.
//	@Tags         notifications
//	@Produce      json
//	@Param        page       query     int     false  "Page number"                        default(1)
//	@Param        per_page   query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        read       query     bool    false  "Read state filter"
//	@Param        alert_type query     string  false  "Alert type filter"  Enums(hos_warning, hos_violation, route_assigned, route_completed, dvir_defects, dvir_critical, log_edit_request, log_edit_resolved, uncertified_log, unidentified_driving, eld_disconnected, eld_malfunction, maintenance_upcoming, maintenance_overdue, chat_message, subscription_expiring)
//	@Success      200  {object}  dto.NotificationListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "notifications.read"
//	@Router       /notifications [get]
func (m *Module) list(w http.ResponseWriter, r *http.Request) {
	p, ok := tenant.PrincipalFrom(r.Context())
	if !ok {
		httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
		return
	}
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f := ListFilter{UserID: p.UserID, Limit: page.Limit(), Offset: page.Offset()}

	if raw := strings.TrimSpace(r.URL.Query().Get("read")); raw != "" {
		switch strings.ToLower(raw) {
		case "true":
			v := false // unread == false -> read only
			f.Unread = &v
		case "false":
			v := true
			f.Unread = &v
		default:
			httpx.WriteError(w, r, apierr.Validation("invalid filter",
				apierr.FieldError{Field: "read", Message: "must be true or false"}))
			return
		}
	}
	if raw := strings.TrimSpace(r.URL.Query().Get("alert_type")); raw != "" {
		if !notify.IsAlertType(raw) {
			httpx.WriteError(w, r, apierr.Validation("invalid filter",
				apierr.FieldError{Field: "alert_type", Message: "unknown alert type"}))
			return
		}
		f.AlertType = &raw
	}

	items, total, unread, err := m.svc.List(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, dto.NotificationListEnvelope{
		Data: items,
		Meta: dto.ListMeta{Page: page.Page, PerPage: page.PerPage, Total: total, Unread: unread},
	})
}

// markRead godoc
//
//	@Summary      Mark a notification read
//	@Description  Q88 — idempotent: a notification that is already read answers 200 with `updated: 0`. A notification of another user or another company answers 404, never 403.
//	@Tags         notifications
//	@Produce      json
//	@Param        id   path      string  true  "Notification id"  format(uuid)
//	@Success      200  {object}  dto.ReadResultEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "notifications.read"
//	@Router       /notifications/{id}/read [patch]
func (m *Module) markRead(w http.ResponseWriter, r *http.Request) {
	p, ok := tenant.PrincipalFrom(r.Context())
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
	res, err := m.svc.MarkRead(r.Context(), p.UserID, id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, res)
}

// markAllRead godoc
//
//	@Summary      Mark every notification read
//	@Description  Q88 — clears the badge for the calling user only.
//	@Tags         notifications
//	@Produce      json
//	@Success      200  {object}  dto.ReadResultEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "notifications.read"
//	@Router       /notifications/read-all [post]
func (m *Module) markAllRead(w http.ResponseWriter, r *http.Request) {
	p, ok := tenant.PrincipalFrom(r.Context())
	if !ok {
		httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
		return
	}
	res, err := m.svc.MarkAllRead(r.Context(), p.UserID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, res)
}

// registerToken godoc
//
//	@Summary      Register a push token
//	@Description  Q89 — registers the FCM (android/web) or APNs (ios) token of one installation, keyed by `device_id`, so a reinstall refreshes instead of duplicating. Registering a token that is already bound to another user retires the old registration: a handed over phone must not keep receiving the previous owner's alerts. The token itself is a credential and is never returned by any endpoint.
//	@Tags         notifications
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.PushTokenCreate  true  "Device registration"
//	@Success      201   {object}  dto.PushTokenEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "notifications.read"
//	@Router       /devices/push-token [post]
func (m *Module) registerToken(w http.ResponseWriter, r *http.Request) {
	p, ok := tenant.PrincipalFrom(r.Context())
	if !ok {
		httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
		return
	}
	var in dto.PushTokenCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.RegisterPushToken(r.Context(), p.UserID, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}
