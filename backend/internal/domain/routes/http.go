package routes

import (
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/routes/dto"
	"github.com/devline/onebook-eld/internal/geo"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Deps are the routes module dependencies. Repo and Verifier are required; the
// rest degrade gracefully so tests can wire a minimal module.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	// Geo draws the route line; nil falls back to the nop provider.
	Geo geo.Provider
	// Alerter notifies the driver about a new leg; nil drops the alerts.
	Alerter Alerter
	// Store backs the per user rate limit and the Idempotency-Key replay cache.
	Store cache.Store
	Log   *slog.Logger
	// Now is injectable so the two minute dwell window is testable.
	Now func() time.Time
}

// Module wires the trip planner routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the routes HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo, deps.Geo, deps.Alerter, deps.Log, deps.Now),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// Service exposes the business layer so the background sweep can be wired
// without building a second service instance.
func (m *Module) Service() *Service { return m.svc }

// routeSorts is the sort whitelist of GET /routes.
var routeSorts = []string{"created_at", "sequence", "status"}

// writeRateLimit is the per user budget of the mutation endpoints.
const writeRateLimit = 120

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		// Unconditional: a module wired without a verifier must fail closed
		// (mw.Authenticate answers 503), never serve planner data
		// unauthenticated.
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}

		g.Route("/routes", func(rt chi.Router) {
			rt.With(mw.RequirePermission(auth.PermRoutesRead)).Get("/", m.list)
			rt.With(m.writeGuards(auth.PermRoutesCreate)...).Post("/", m.create)
			rt.With(mw.RequirePermission(auth.PermRoutesRead)).Get("/{id}", m.get)
			rt.With(mw.RequirePermission(auth.PermRoutesUpdate)).Patch("/{id}", m.update)
			rt.With(mw.RequirePermission(auth.PermRoutesDelete)).Delete("/{id}", m.remove)
			rt.With(m.writeGuards(auth.PermRoutesComplete)...).Post("/{id}/not-completed", m.notCompleted)
			rt.With(mw.RequirePermission(auth.PermRoutesRead)).Get("/{id}/directions", m.directions)
		})
	})
}

// writeGuards is the middleware chain of a POST route: permission, per user
// rate limit and the optional Idempotency-Key replay cache.
func (m *Module) writeGuards(perm string) []func(http.Handler) http.Handler {
	chain := []func(http.Handler) http.Handler{mw.RequirePermission(perm)}
	if m.store != nil {
		chain = append(chain, mw.UserRateLimit(m.store, writeRateLimit), mw.Idempotency(m.store, false))
	}
	return chain
}

// list godoc
//
//	@Summary      List routes
//	@Description  Q66–Q68 — the trip planner queue. A route is created `ongoing` and leaves that state either through the destination geofence (`completed`) or through an admin closure (`not_completed`). Several routes may queue on one unit; `sequence` orders them and only the lowest ongoing sequence is the current one.
//	@Tags         routes
//	@Produce      json
//	@Param        page      query  int     false  "Page number"                       default(1)
//	@Param        per_page  query  int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        sort      query  string  false  "Sort field"  Enums(created_at, sequence, status)
//	@Param        order     query  string  false  "Sort order"  Enums(asc, desc)
//	@Param        status    query  string  false  "Route status"  Enums(ongoing, completed, not_completed, cancelled)
//	@Param        unit_id   query  string  false  "Unit filter (uuid)"
//	@Param        driver_id query  string  false  "Driver filter (uuid)"
//	@Success      200  {object}  dto.RouteListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "routes.read"
//	@Router       /routes [get]
func (m *Module) list(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, routeSorts, httpx.Sort{Field: "created_at", Order: "desc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	status, err := queryEnum(r, "status", dto.Statuses...)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	unitID, err := httpx.QueryUUID(r, "unit_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driverID, err := httpx.QueryUUID(r, "driver_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	items, total, err := m.svc.List(r.Context(), Filter{
		Status: status, UnitID: unitID, DriverID: driverID,
		Sort: sort.Field, Order: sort.Order,
		Limit: page.Limit(), Offset: page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, items, page.Meta(total))
}

// create godoc
//
//	@Summary      Create route
//	@Description  Q66 — the route is created `ongoing`; there is no manual start. `geofence_m` defaults to 300 m and is the radius that completes the route once the unit has stayed inside it for two minutes. `sequence` defaults to the next free slot of the unit (Q68). The assigned driver receives a push notification (Q66.1). A unit or driver of another company answers 404.
//	@Tags         routes
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string           false  "Replay protection key"
//	@Param        body             body    dto.RouteCreate  true   "Route payload"
//	@Success      201  {object}  dto.RouteEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "IDEMPOTENCY_CONFLICT"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "routes.create"
//	@Router       /routes [post]
func (m *Module) create(w http.ResponseWriter, r *http.Request) {
	var in dto.RouteCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Create(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// get godoc
//
//	@Summary      Get route
//	@Description  Q66 — one trip planner entry. A route of another company answers 404, never 403.
//	@Tags         routes
//	@Produce      json
//	@Param        id   path      string  true  "Route id (uuid)"
//	@Success      200  {object}  dto.RouteEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "routes.read"
//	@Router       /routes/{id} [get]
func (m *Module) get(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Get(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// update godoc
//
//	@Summary      Update route
//	@Description  Q66 — only an `ongoing` route can be edited; a terminal route is a record and answers 409 INVALID_STATE. Changing `driver_id` re-notifies the new driver.
//	@Tags         routes
//	@Accept       json
//	@Produce      json
//	@Param        id    path  string           true  "Route id (uuid)"
//	@Param        body  body  dto.RouteUpdate  true  "Partial route payload"
//	@Success      200  {object}  dto.RouteEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "routes.update"
//	@Router       /routes/{id} [patch]
func (m *Module) update(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.RouteUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Update(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// remove godoc
//
//	@Summary      Delete route
//	@Description  Soft delete (`deleted_at`); the row stays for the audit trail.
//	@Tags         routes
//	@Param        id   path  string  true  "Route id (uuid)"
//	@Success      204  "No Content"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "routes.delete"
//	@Router       /routes/{id} [delete]
func (m *Module) remove(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.Delete(r.Context(), id); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// notCompleted godoc
//
//	@Summary      Close route as not completed
//	@Description  Q66 — the admin closure of an ongoing route. `reason` comes from the fixed list; `other` requires a note. A route that is not `ongoing` answers 409 INVALID_STATE.
//	@Tags         routes
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string                 false  "Replay protection key"
//	@Param        id               path    string                 true   "Route id (uuid)"
//	@Param        body             body    dto.RouteNotCompleted  true   "Closure payload"
//	@Success      200  {object}  dto.RouteEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "routes.complete"
//	@Router       /routes/{id}/not-completed [post]
func (m *Module) notCompleted(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.RouteNotCompleted
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.NotCompleted(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// directions godoc
//
//	@Summary      Get route directions
//	@Description  Q66.1 — the driving geometry between origin and destination, taken from the configured map provider (TZ B§7.3). The answer is cached per origin/destination pair, so repeated opens cost no provider call. When no provider is configured the payload comes back empty with `provider = nop` instead of failing.
//	@Tags         routes
//	@Produce      json
//	@Param        id   path      string  true  "Route id (uuid)"
//	@Success      200  {object}  dto.DirectionsEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Failure      503  {object}  dto.ErrorResponse  "SERVICE_UNAVAILABLE"
//	@Security     BearerAuth
//	@x-permission "routes.read"
//	@Router       /routes/{id}/directions [get]
func (m *Module) directions(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Directions(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// queryEnum returns a whitelisted optional query parameter.
func queryEnum(r *http.Request, key string, allowed ...string) (*string, error) {
	v := strings.TrimSpace(r.URL.Query().Get(key))
	if v == "" {
		return nil, nil
	}
	for _, a := range allowed {
		if a == v {
			return &v, nil
		}
	}
	return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
		Field: key, Message: "must be one of: " + strings.Join(allowed, ", "),
	})
}

// swaggerRefs keeps the envelope types referenced by the annotations reachable
// for swag's type walker.
var _ = []any{
	dto.RouteEnvelope{}, dto.RouteListEnvelope{}, dto.DirectionsEnvelope{},
	dto.ErrorResponse{}, uuid.Nil,
}
