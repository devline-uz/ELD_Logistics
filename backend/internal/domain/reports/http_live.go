// Live report endpoints (TZ §14 Q75): the odometer activity report and the
// quarterly Distance by Region roll-up. Split out of http.go to keep each file
// under the 400 line ceiling of the Go conventions.
package reports

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/reports/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// activity godoc
//
//	@Summary      Activity report
//	@Description  Q75 — Start/End odometer per driver or per unit over a window, with `odometer_change_m = end − start`. The numbers come straight from telemetry, so the report is live. Distances are metres; the backend never converts units. A subject that reported nothing in the window comes back with `has_data = false` and zeroes rather than a misleading negative change.
//	@Tags         reports
//	@Produce      json
//	@Param        subject   query  string  false  "Report axis"  Enums(drivers, units)  default(units)
//	@Param        from      query  string  true   "First day of the window (YYYY-MM-DD)"
//	@Param        to        query  string  true   "Last day of the window, inclusive (YYYY-MM-DD)"
//	@Param        unit_id   query  string  false  "Unit filter (uuid, repeatable)"
//	@Param        driver_id query  string  false  "Driver filter (uuid, repeatable)"
//	@Param        page      query  int     false  "Page number"                        default(1)
//	@Param        per_page  query  int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.ActivityListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "reports.read"
//	@Router       /reports/activity [get]
func (m *Module) activity(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	subject, err := queryEnum(r, "subject", dto.Subjects...)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	from, to, err := ParseWindow(r.URL.Query().Get("from"), r.URL.Query().Get("to"))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if to.Before(from) {
		httpx.WriteError(w, r, apierr.Validation("invalid window",
			apierr.FieldError{Field: "to", Message: "must not be before from"}))
		return
	}
	unitIDs, err := queryUUIDs(r, "unit_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driverIDs, err := queryUUIDs(r, "driver_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	q := ActivityQuery{
		Subject: dto.SubjectUnits, From: from, To: to.AddDate(0, 0, 1),
		UnitIDs: unitIDs, DriverIDs: driverIDs,
		Limit: page.Limit(), Offset: page.Offset(),
	}
	if subject != nil {
		q.Subject = *subject
	}

	rows, total, err := m.svc.Activity(r.Context(), q)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// distanceByRegion godoc
//
//	@Summary      Distance by Region report
//	@Description  TZ §14 — the quarterly per jurisdiction distance (IFTA style). It is served from the daily `unit_region_distance_daily` roll-up, so the answer is immediate; the roll-up itself is filled by a nightly job that intersects the telemetry track with the PostGIS region polygons. `regions_and_units` breaks the distance down per unit, `regions_only` returns one row per region. Distances are metres.
//	@Tags         reports
//	@Produce      json
//	@Param        quarter  query  int     true   "Calendar quarter (1-4)"
//	@Param        year     query  int     true   "Calendar year"
//	@Param        mode     query  string  false  "Breakdown"  Enums(regions_and_units, regions_only)  default(regions_and_units)
//	@Param        unit_id  query  string  false  "Unit filter (uuid, repeatable)"
//	@Success      200  {object}  dto.DistanceByRegionEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "reports.read"
//	@Router       /reports/distance-by-region [get]
func (m *Module) distanceByRegion(w http.ResponseWriter, r *http.Request) {
	quarter, err := queryInt(r, "quarter")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	year, err := queryInt(r, "year")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	mode, err := queryEnum(r, "mode", dto.Modes...)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	unitIDs, err := queryUUIDs(r, "unit_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	selected := dto.ModeRegionsAndUnits
	if mode != nil {
		selected = *mode
	}
	rows, meta, err := m.svc.DistanceByRegion(r.Context(), quarter, year, selected, unitIDs)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, dto.DistanceByRegionEnvelope{Data: rows, Meta: meta})
}
