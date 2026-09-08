package maintenance

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/domain/maintenance/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// getScheduleUnit godoc
//
//	@Summary      Get maintenance schedule unit
//	@Description  One unit's progress against one schedule, with the same computed `current_value` / `remaining` / `overdue` fields as the due list. Cross-tenant ids answer 404, never 403.
//	@Tags         maintenance
//	@Produce      json
//	@Param        id   path      string  true  "Schedule unit id"
//	@Success      200  {object}  dto.ScheduleUnitEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.read"
//	@Router       /maintenance-schedule-units/{id} [get]
func (m *Module) getScheduleUnit(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.ScheduleUnit(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// complete godoc
//
//	@Summary      Complete a maintenance entry
//	@Description  TZ §8 Q41–Q43 — records Invoice #, Vendor, Cost, Date and the invoice file, and writes a `completed` row into `/maintenance-records`. Q42.1: `last_service_value` is set to the odometer / engine hours read **at this moment** from telemetry, the row moves Due → Schedule and gets a fresh `next_due_value = last_service_value + interval_value`; the reminder guard is cleared so the next cycle can announce again. A `days` schedule re-bases `next_due_at` on the completion date instead. A km/mi/engine_hours schedule whose unit never reported telemetry answers 422 `MAINTENANCE_NO_READING`; a row that is already completed or cancelled answers 409 `MAINTENANCE_INVALID_STATE`.
//	@Tags         maintenance
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string             true  "Schedule unit id"
//	@Param        body  body      dto.CompleteInput  true  "Completion payload"
//	@Success      200   {object}  dto.ScheduleUnitEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404   {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409   {object}  dto.ErrorResponse  "MAINTENANCE_INVALID_STATE"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR / MAINTENANCE_NO_READING / TIME_IN_FUTURE"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.complete"
//	@Router       /maintenance-schedule-units/{id}/complete [post]
func (m *Module) complete(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.CompleteInput
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Complete(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// cancel godoc
//
//	@Summary      Cancel a maintenance entry
//	@Description  TZ §8 Q43 — closes the row without any financial field; only `cancelled_reason` is stored, and a `cancelled` row is written to `/maintenance-records`. A row that is already completed or cancelled answers 409 `MAINTENANCE_INVALID_STATE`.
//	@Tags         maintenance
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string           true  "Schedule unit id"
//	@Param        body  body      dto.CancelInput  true  "Cancellation payload"
//	@Success      200   {object}  dto.ScheduleUnitEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404   {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409   {object}  dto.ErrorResponse  "MAINTENANCE_INVALID_STATE"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.cancel"
//	@Router       /maintenance-schedule-units/{id}/cancel [post]
func (m *Module) cancel(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.CancelInput
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Cancel(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// records godoc
//
//	@Summary      List maintenance records
//	@Description  TZ §8 Q32 — the completion and cancellation history, newest first. A `cancelled` row never carries invoice, vendor or cost (Q43). Costs are decimal amounts in `currency`; the odometer stays metres.
//	@Tags         maintenance
//	@Produce      json
//	@Param        unit_id   query     string  false  "Unit filter (uuid)"
//	@Param        status    query     string  false  "Record status"  Enums(completed, cancelled)
//	@Param        from      query     string  false  "Start of the window (RFC3339 UTC)"           example(2026-09-01T00:00:00Z)
//	@Param        to        query     string  false  "End of the window, exclusive (RFC3339 UTC)"  example(2026-09-08T00:00:00Z)
//	@Param        page      query     int     false  "Page number"                        default(1)
//	@Param        per_page  query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.RecordListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "maintenance.read"
//	@Router       /maintenance-records [get]
func (m *Module) records(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f := RecordFilter{Limit: page.Limit(), Offset: page.Offset()}
	if f.UnitID, err = httpx.QueryUUID(r, "unit_id"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.Status, err = queryEnum(r, "status", "completed", "cancelled"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.From, err = httpx.QueryTime(r, "from"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.To, err = httpx.QueryTime(r, "to"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	rows, total, err := m.svc.Records(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}
