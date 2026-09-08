package maintenance

import (
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/maintenance/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Deps are the maintenance module dependencies. Repo and Verifier are required;
// the rest degrade gracefully so tests can wire a minimal module.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	// Alerter receives the Q37/Q38 reminders. Nil means no notifications.
	Alerter Alerter
	// Store backs the per user rate limit.
	Store cache.Store
	// Audit is kept for symmetry with the other modules; the repo writes the
	// entries inside its own transactions.
	Audit audit.Recorder
	Log   *slog.Logger
	// Now is injectable so the day interval maths is testable.
	Now func() time.Time
}

// Module wires the maintenance routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the maintenance HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo, deps.Alerter, deps.Log, deps.Now),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// Service exposes the business layer so internal/jobs can drive the reminder
// sweep without re-building the module.
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

		g.With(mw.RequirePermission(auth.PermMaintenanceRead)).Get("/maintenance-schedules", m.listSchedules)
		g.With(mw.RequirePermission(auth.PermMaintenanceRead)).Get("/maintenance-schedules/{id}", m.getSchedule)
		g.With(mw.RequirePermission(auth.PermMaintenanceCreate)).Post("/maintenance-schedules", m.createSchedule)
		g.With(mw.RequirePermission(auth.PermMaintenanceUpdate)).Patch("/maintenance-schedules/{id}", m.updateSchedule)
		g.With(mw.RequirePermission(auth.PermMaintenanceDelete)).Delete("/maintenance-schedules/{id}", m.deleteSchedule)

		g.With(mw.RequirePermission(auth.PermMaintenanceRead)).Get("/maintenance/due", m.due)
		g.With(mw.RequirePermission(auth.PermMaintenanceRead)).Get("/maintenance-schedule-units/{id}", m.getScheduleUnit)
		g.With(mw.RequirePermission(auth.PermMaintenanceDone)).Post("/maintenance-schedule-units/{id}/complete", m.complete)
		g.With(mw.RequirePermission(auth.PermMaintenanceCancel)).Post("/maintenance-schedule-units/{id}/cancel", m.cancel)
		g.With(mw.RequirePermission(auth.PermMaintenanceRead)).Get("/maintenance-records", m.records)
	})
}

// listSchedules godoc
//
//	@Summary      List maintenance schedules
//	@Description  TZ §8 — the maintenance plans of the tenant. Q33 vocabulary: `interval_value` + `interval_unit` are the maintenance frequency and `reminder_before_value` is how far ahead of the due point the Q37 reminder fires, expressed in the same unit.
//	@Tags         maintenance
//	@Produce      json
//	@Param        status    query     string  false  "Plan status"  Enums(active, inactive)
//	@Param        q         query     string  false  "Name search"  example(oil)
//	@Param        page      query     int     false  "Page number"                        default(1)
//	@Param        per_page  query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.ScheduleListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.read"
//	@Router       /maintenance-schedules [get]
func (m *Module) listSchedules(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f := ScheduleFilter{Limit: page.Limit(), Offset: page.Offset()}
	if f.Status, err = queryEnum(r, "status", dto.ScheduleActive, dto.ScheduleInactive); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f.Query = queryString(r, "q")

	rows, total, err := m.svc.ListSchedules(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// getSchedule godoc
//
//	@Summary      Get maintenance schedule
//	@Description  One maintenance plan with the number of units attached. Cross-tenant ids answer 404, never 403.
//	@Tags         maintenance
//	@Produce      json
//	@Param        id   path      string  true  "Schedule id"
//	@Success      200  {object}  dto.ScheduleEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.read"
//	@Router       /maintenance-schedules/{id} [get]
func (m *Module) getSchedule(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.GetSchedule(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// createSchedule godoc
//
//	@Summary      Create maintenance schedule
//	@Description  TZ §8 Q39/Q40 — one plan can cover many units, and every unit keeps its own `last_service_value` / `next_due_value`. Omitting `last_service_value` on a unit seeds it from the live telemetry reading (odometer for km/mi, engine hours for engine_hours); a `days` interval is seeded from the creation date instead. Q42.1 later resets those values on completion.
//	@Tags         maintenance
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.ScheduleCreate  true  "Schedule payload"
//	@Success      201   {object}  dto.ScheduleEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404   {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409   {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.create"
//	@Router       /maintenance-schedules [post]
func (m *Module) createSchedule(w http.ResponseWriter, r *http.Request) {
	var in dto.ScheduleCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateSchedule(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// updateSchedule godoc
//
//	@Summary      Update maintenance schedule
//	@Description  Patches a plan; nil fields are left untouched. Sending `units` replaces the attached fleet: units that disappear from the list are detached, new ones are seeded like on creation. Existing progress of a unit that stays is preserved.
//	@Tags         maintenance
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string              true  "Schedule id"
//	@Param        body  body      dto.ScheduleUpdate  true  "Patch payload"
//	@Success      200   {object}  dto.ScheduleEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404   {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409   {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.update"
//	@Router       /maintenance-schedules/{id} [patch]
func (m *Module) updateSchedule(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.ScheduleUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateSchedule(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// deleteSchedule godoc
//
//	@Summary      Delete maintenance schedule
//	@Description  Soft delete (`deleted_at`); the completed and cancelled history in `/maintenance-records` is never removed (Q32).
//	@Tags         maintenance
//	@Produce      json
//	@Param        id   path      string  true  "Schedule id"
//	@Success      204  "Deleted"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.delete"
//	@Router       /maintenance-schedules/{id} [delete]
func (m *Module) deleteSchedule(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.DeleteSchedule(r.Context(), id); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// due godoc
//
//	@Summary      Maintenance due list
//	@Description  TZ §8 Q33/Q34 — one row per unit and schedule. `current_value` is read live from telemetry (odometer converted to the schedule unit, or engine hours) and from the calendar for a `days` interval; `remaining = next_due_value - current_value`, and a negative remaining sets `overdue=true` (red in the UI). `reminder_due` marks rows that reached `reminder_before_value`. By default only open rows (`scheduled`, `due`) are returned; pass `status` to inspect a closed one. `current_value` is null when the unit has never reported telemetry.
//	@Tags         maintenance
//	@Produce      json
//	@Param        unit_id      query     string  false  "Unit filter (uuid)"
//	@Param        schedule_id  query     string  false  "Schedule filter (uuid)"
//	@Param        status       query     string  false  "Row status"  Enums(scheduled, due, completed, cancelled)
//	@Param        page         query     int     false  "Page number"                        default(1)
//	@Param        per_page     query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.ScheduleUnitListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.read"
//	@Router       /maintenance/due [get]
func (m *Module) due(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f := UnitFilter{Limit: page.Limit(), Offset: page.Offset()}
	if f.UnitID, err = httpx.QueryUUID(r, "unit_id"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.ScheduleID, err = httpx.QueryUUID(r, "schedule_id"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.Status, err = queryEnum(r, "status", dto.StatusScheduled, dto.StatusDue,
		dto.StatusCompleted, dto.StatusCancelled); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f.OpenOnly = f.Status == nil

	rows, total, err := m.svc.Due(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// ---------------------------------------------------------------- helpers

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

// queryString reads an optional free text filter.
func queryString(r *http.Request, key string) *string {
	raw := strings.TrimSpace(r.URL.Query().Get(key))
	if raw == "" {
		return nil
	}
	return &raw
}
