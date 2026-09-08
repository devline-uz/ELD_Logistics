// Asynchronous export job endpoints (TZ §14 Q75).
package reports

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/domain/reports/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// createExportJob godoc
//
//	@Summary      Queue a report export
//	@Description  Q75 — every export is asynchronous: the job is queued, a worker renders it, the file lands in object storage and the requester is notified. `GET /reports/export-jobs/{id}` then carries a download link that is valid for 24 hours. The regulator export is gated on the tenant's regulation profile: `generic` produces a PDF + CSV archive, every FMCSA profile answers 501 FEATURE_DISABLED until the FMCSA output file and web service ship. Creating and downloading an export are both written to the audit log.
//	@Tags         reports
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string               false  "Replay protection key"
//	@Param        body             body    dto.ExportJobCreate  true   "Export request"
//	@Success      202  {object}  dto.ExportJobEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      409  {object}  dto.ErrorResponse  "IDEMPOTENCY_CONFLICT"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Failure      501  {object}  dto.ErrorResponse  "FEATURE_DISABLED"
//	@Security     BearerAuth
//	@x-permission "reports.export"
//	@Router       /reports/export-jobs [post]
func (m *Module) createExportJob(w http.ResponseWriter, r *http.Request) {
	var in dto.ExportJobCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateExportJob(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusAccepted, out)
}

// getExportJob godoc
//
//	@Summary      Get an export job
//	@Description  Q75 — the job state and, once it is `done`, a presigned `download_url` that expires with the file after 24 hours. An expired job keeps its metadata but no link. A job of another company answers 404, never 403.
//	@Tags         reports
//	@Produce      json
//	@Param        id   path      string  true  "Export job id (uuid)"
//	@Success      200  {object}  dto.ExportJobEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "reports.read"
//	@Router       /reports/export-jobs/{id} [get]
func (m *Module) getExportJob(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.GetExportJob(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// listExportJobs godoc
//
//	@Summary      List export jobs
//	@Description  The requester's export history, newest first. Finished jobs carry a `download_url` while they are inside their 24 hour window (Q75).
//	@Tags         reports
//	@Produce      json
//	@Param        status    query  string  false  "Job status"  Enums(queued, running, done, failed)
//	@Param        type      query  string  false  "Report type"  Enums(distance_by_region, regulator, activity, hos, dvir)
//	@Param        mine      query  bool    false  "Only the jobs this user requested"
//	@Param        page      query  int     false  "Page number"                        default(1)
//	@Param        per_page  query  int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.ExportJobListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "reports.read"
//	@Router       /reports/export-jobs [get]
func (m *Module) listExportJobs(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	status, err := queryEnum(r, "status", dto.StatusQueued, dto.StatusRunning, dto.StatusDone, dto.StatusFailed)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	reportType, err := queryEnum(r, "type", dto.Types...)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	mine, err := httpx.QueryBool(r, "mine")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	f := JobFilter{Status: status, Type: reportType, Limit: page.Limit(), Offset: page.Offset()}
	if mine != nil && *mine {
		id := tenantUserID(r)
		f.RequestedBy = &id
	}

	rows, total, err := m.svc.ListExportJobs(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}
