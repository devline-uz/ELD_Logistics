package fleet

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/fleet/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// activateUnit godoc
//
//	@Summary      Activate unit
//	@Description  Q1 — the active ⇄ inactive transition is reversible and audited.
//	@Tags         units
//	@Produce      json
//	@Param        id   path      string  true  "Unit id"
//	@Success      200  {object}  dto.UnitEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "units.activate"
//	@Router       /units/{id}/activate [post]
func (m *Module) activateUnit(w http.ResponseWriter, r *http.Request) {
	m.setStatus(w, r, dto.StatusActive)
}

// deactivateUnit godoc
//
//	@Summary      Deactivate unit
//	@Description  Q3.1 — an inactive unit accepts no ELD connection and no driver assignment.
//	@Tags         units
//	@Produce      json
//	@Param        id   path      string  true  "Unit id"
//	@Success      200  {object}  dto.UnitEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "units.deactivate"
//	@Router       /units/{id}/deactivate [post]
func (m *Module) deactivateUnit(w http.ResponseWriter, r *http.Request) {
	m.setStatus(w, r, dto.StatusInactive)
}

func (m *Module) setStatus(w http.ResponseWriter, r *http.Request, status string) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.SetUnitStatus(r.Context(), id, status)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// assignDriver godoc
//
//	@Summary      Assign a driver to a unit
//	@Description  Q1.1 — a unit holds one open assignment per role, so assigning a new `primary` closes the previous one. An inactive unit or driver answers 409.
//	@Tags         units
//	@Accept       json
//	@Produce      json
//	@Param        id               path    string                true   "Unit id"
//	@Param        Idempotency-Key  header  string                false  "Replay protection key"
//	@Param        body             body    dto.UnitAssignDriver  true   "Driver and role"
//	@Success      201  {object}  dto.UnitAssignmentEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE / ACCOUNT_INACTIVE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "units.assign_driver"
//	@Router       /units/{id}/assign-driver [post]
func (m *Module) assignDriver(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.UnitAssignDriver
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.AssignDriver(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// unitDiagnostics godoc
//
//	@Summary      Unit ELD diagnostics
//	@Description  TZ §10.1/§10.5 — `connection_state` is Online when telemetry is younger than five minutes, Offline when it is older, Disconnected when the device reported the link is down and Malfunction when any FMCSA code (P/E/T/L/R/S/O) is raised. Telemetry values are raw: distance in metres, speed in km/h.
//	@Tags         units
//	@Produce      json
//	@Param        id   path      string  true  "Unit id"
//	@Success      200  {object}  dto.UnitDiagnosticsEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "units.diagnostics"
//	@Router       /units/{id}/diagnostics [get]
func (m *Module) unitDiagnostics(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Diagnostics(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// unitHistory godoc
//
//	@Summary      Unit history
//	@Description  Q3 — the audit_log entries of the unit merged with its driver assignment history, newest first.
//	@Tags         units
//	@Produce      json
//	@Param        id        path   string  true   "Unit id"
//	@Param        from      query  string  false  "Inclusive lower bound (RFC3339 UTC)"
//	@Param        to        query  string  false  "Exclusive upper bound (RFC3339 UTC)"
//	@Param        page      query  int     false  "Page number"  default(1)
//	@Param        per_page  query  int     false  "Rows per page"  default(25)
//	@Success      200  {object}  dto.UnitHistoryEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "units.read"
//	@Router       /units/{id}/history [get]
func (m *Module) unitHistory(w http.ResponseWriter, r *http.Request) {
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
	if from != nil && to != nil && to.Before(*from) {
		httpx.WriteError(w, r, apierr.Validation("invalid range", apierr.FieldError{
			Field: "to", Message: "must not be before from",
		}))
		return
	}

	entries, total, err := m.svc.History(r.Context(), HistoryFilter{
		UnitID: id, From: from, To: to, Limit: page.Limit(), Offset: page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, entries, page.Meta(total))
}
