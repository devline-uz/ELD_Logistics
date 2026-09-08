package tracking

import (
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/tracking/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// maxUnitIDs bounds the unit_ids filter of the live map.
const maxUnitIDs = 500

// Deps are the tracking module dependencies. Repo and Verifier are required;
// Store only adds the per user rate limit, so tests can wire a minimal module.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	// Store backs the per user rate limit.
	Store cache.Store
	// Now is injectable so the company timezone day boundary is testable.
	Now func() time.Time
}

// Module wires the tracking routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the tracking HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo, deps.Now),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		// Unconditional: a module wired without a verifier must fail closed
		// (mw.Authenticate answers 503), never serve positions unauthenticated.
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		// RequireCompany keeps a company-less principal (platform super admin)
		// out of the tenant endpoints instead of letting it fall through with
		// company_id = uuid.Nil.
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}

		g.With(mw.RequirePermission(auth.PermTrackingViewLive)).Get("/tracking/live", m.live)
		g.With(mw.RequirePermission(auth.PermTrackingViewHistory)).Get("/units/{id}/trips", m.unitTrips)
		g.With(mw.RequirePermission(auth.PermTrackingViewHistory)).Get("/trips/{id}", m.getTrip)
		g.With(mw.RequireAnyPermission(auth.PermLogsAssignUnidentified, auth.PermLogsRead)).
			Get("/unidentified-events", m.listUnidentified)
	})
}

// live godoc
//
//	@Summary      Live tracking map
//	@Description  TZ §10.1 / Q63 — the last known state of every unit, read from `unit_last_state`. `online_status` is Online (telemetry within 5 minutes), Offline, Disconnected (the ELD reported losing the phone link) or Malfunction (the wired ELD carries an active FMCSA Appendix A code, which wins over the connectivity state). A branch scoped principal always sees its own branch only. Distances are metres and speeds km/h; the backend never converts units. The `online_status` filter matches the stored connectivity state, so `malfunction` is not a filter value.
//	@Tags         tracking
//	@Produce      json
//	@Param        page             query     int     false  "Page number"                        default(1)
//	@Param        per_page         query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        unit_ids         query     string  false  "Comma separated unit ids (max 500)"
//	@Param        branch_id        query     string  false  "Branch filter (uuid)"
//	@Param        online_status    query     string  false  "Connectivity filter"  Enums(online, idle, offline, disconnected)
//	@Param        include_inactive query     bool    false  "Include inactive units"
//	@Success      200  {object}  dto.LiveUnitListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "tracking.view_live"
//	@Router       /tracking/live [get]
func (m *Module) live(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	unitIDs, err := queryUUIDList(r, "unit_ids")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	branchID, err := httpx.QueryUUID(r, "branch_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	status, err := queryEnum(r, "online_status", "online", "idle", "offline", "disconnected")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	includeInactive, err := httpx.QueryBool(r, "include_inactive")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	units, total, err := m.svc.Live(r.Context(), LiveFilter{
		UnitIDs:         unitIDs,
		BranchID:        branchID,
		OnlineStatus:    status,
		IncludeInactive: includeInactive != nil && *includeInactive,
		Limit:           page.Limit(),
		Offset:          page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, units, page.Meta(total))
}

// unitTrips godoc
//
//	@Summary      List unit trips of a day
//	@Description  TZ §13 Q64/Q65 — a trip runs from ignition on to ignition off, or ends after a stop of 15 minutes or more. The `date` window is the calendar day in the **company timezone**, converted to UTC; omitting it means today. Cross-tenant and out of scope unit ids answer 404, never 403.
//	@Tags         tracking
//	@Produce      json
//	@Param        id        path      string  true   "Unit id"
//	@Param        date      query     string  false  "Calendar day in the company timezone (YYYY-MM-DD)"  example(2026-09-06)
//	@Param        page      query     int     false  "Page number"                        default(1)
//	@Param        per_page  query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.TripListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "tracking.view_history"
//	@Router       /units/{id}/trips [get]
func (m *Module) unitTrips(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	date, err := httpx.QueryDate(r, "date")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	from, to := m.svc.DayWindow(r.Context(), date)

	trips, total, err := m.svc.Trips(r.Context(), TripFilter{
		UnitID: id, From: from, To: to, Limit: page.Limit(), Offset: page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, trips, page.Meta(total))
}

// getTrip godoc
//
//	@Summary      Get trip
//	@Description  Trip detail with its track. `polyline` is a Google encoded polyline (precision 5) rebuilt from the telemetry of the trip window; `polyline_key` is the object storage key of the copy written when the trip closed, which outlives the telemetry retention window. Pass `include_polyline=false` to skip the rebuild. Cross-tenant and out of scope trip ids answer 404, never 403.
//	@Tags         tracking
//	@Produce      json
//	@Param        id                path      string  true   "Trip id"
//	@Param        include_polyline  query     bool    false  "Rebuild the polyline from telemetry"  default(true)
//	@Success      200  {object}  dto.TripEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "tracking.view_history"
//	@Router       /trips/{id} [get]
func (m *Module) getTrip(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	include, err := httpx.QueryBool(r, "include_polyline")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	trip, err := m.svc.Trip(r.Context(), id, include == nil || *include)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, trip)
}

// listUnidentified godoc
//
//	@Summary      List unidentified driving events
//	@Description  TZ A§10.4 — driving recorded without an identified driver is buffered here (unit, start/end, distance, track). Assigning an event to a driver or claiming it from the mobile app happens through the log edit request flow, not on this endpoint. `pending_days` beyond 8 raises the admin alert.
//	@Tags         tracking
//	@Produce      json
//	@Param        status    query     string  false  "Resolution status"  Enums(pending, assigned, annotated)
//	@Param        unit_id   query     string  false  "Unit filter (uuid)"
//	@Param        from      query     string  false  "Start of the window (RFC3339 UTC)"  example(2026-09-01T00:00:00Z)
//	@Param        to        query     string  false  "End of the window, exclusive (RFC3339 UTC)"  example(2026-09-08T00:00:00Z)
//	@Param        page      query     int     false  "Page number"                        default(1)
//	@Param        per_page  query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.UnidentifiedEventListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.assign_unidentified"
//	@Router       /unidentified-events [get]
func (m *Module) listUnidentified(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	status, err := queryEnum(r, "status",
		dto.UnidentifiedPending, dto.UnidentifiedAssigned, dto.UnidentifiedAnnotated)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	unitID, err := httpx.QueryUUID(r, "unit_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	from, err := httpx.QueryTime(r, "from")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	to, err := httpx.QueryTime(r, "to")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	events, total, err := m.svc.Unidentified(r.Context(), UnidentifiedFilter{
		Status: status, UnitID: unitID, From: from, To: to,
		Limit: page.Limit(), Offset: page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, events, page.Meta(total))
}

// queryEnum reads an optional query parameter constrained to a whitelist.
func queryEnum(r *http.Request, key string, allowed ...string) (*string, error) {
	raw := strings.TrimSpace(r.URL.Query().Get(key))
	if raw == "" {
		return nil, nil
	}
	for _, a := range allowed {
		if raw == a {
			v := raw
			return &v, nil
		}
	}
	return nil, apierr.Validation("unsupported "+key,
		apierr.FieldError{Field: key, Message: "must be one of " + strings.Join(allowed, ", ")})
}

// queryUUIDList reads a comma separated uuid filter.
func queryUUIDList(r *http.Request, key string) ([]uuid.UUID, error) {
	raw := strings.TrimSpace(r.URL.Query().Get(key))
	if raw == "" {
		return nil, nil
	}
	parts := strings.Split(raw, ",")
	if len(parts) > maxUnitIDs {
		return nil, apierr.Validation(key+" holds too many ids",
			apierr.FieldError{Field: key, Message: "at most 500 ids"})
	}
	out := make([]uuid.UUID, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p == "" {
			continue
		}
		id, err := uuid.Parse(p)
		if err != nil {
			return nil, apierr.Validation(key+" holds an invalid uuid",
				apierr.FieldError{Field: key, Message: "must be a comma separated list of uuids"})
		}
		out = append(out, id)
	}
	if len(out) == 0 {
		return nil, nil
	}
	return out, nil
}
