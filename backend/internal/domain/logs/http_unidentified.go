package logs

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

// assignUnidentified godoc
//
//	@Summary      Assign an unidentified driving block
//	@Description  TZ §10.4 — the administrator proposes the block to a driver; it does **not** move yet. A `log_edit_requests` row with `source=unidentified_assign` is created and the block waits in `proposed` until the driver approves it (the same propose/approve model as §5.3). `note` is mandatory. Rejecting the request puts the block back to `pending`. `GET /unidentified-events` itself lives in the tracking module.
//	@Tags         unidentified
//	@Accept       json
//	@Produce      json
//	@Param        id    body      string                  true  "Unidentified event id (uuid)"
//	@Param        body  body      dto.UnidentifiedAssign  true  "Target driver and reason"
//	@Success      201  {object}  dto.LogEditRequestEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "ALREADY_ASSIGNED"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.assign_unidentified"
//	@Router       /unidentified-events/{id}/assign [post]
func (m *Module) assignUnidentified(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var body dto.UnidentifiedAssign
	if err := httpx.DecodeAndValidate(r, &body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.AssignUnidentified(ctx, tenant.CompanyID(ctx), id, tenant.UserID(ctx), body)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// claimUnidentified godoc
//
//	@Summary      Claim an unidentified driving block
//	@Description  TZ §10.4 — the driver takes an unassigned block itself, which needs no second approval. The stored driving rows keep their identity and gain `origin=assigned`; they are attached to the driver's log day, the totals are recomputed, a certified day falls back to `needs_recertify` and the 8 day `unidentified_driving` violation is closed. A block proposed to another driver answers 409.
//	@Tags         unidentified
//	@Produce      json
//	@Param        id   path      string  true  "Unidentified event id (uuid)"
//	@Success      200  {object}  dto.UnidentifiedEventEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "ALREADY_ASSIGNED"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.claim_unidentified"
//	@Router       /unidentified-events/{id}/claim [post]
func (m *Module) claimUnidentified(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	self, err := m.selfDriver(ctx)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.ClaimUnidentified(ctx, tenant.CompanyID(ctx), id,
		self.DriverID, tenant.UserID(ctx), self.Timezone)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// annotateUnidentified godoc
//
//	@Summary      Annotate an unidentified driving block
//	@Description  TZ §10.4 — the administrator leaves the block unassigned with an explanation, for example a mechanic's test drive. The block moves to `annotated` and stops counting towards the 8 day alert. The annotation is mandatory.
//	@Tags         unidentified
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string                    true  "Unidentified event id (uuid)"
//	@Param        body  body      dto.UnidentifiedAnnotate  true  "Explanation"
//	@Success      200  {object}  dto.UnidentifiedEventEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.annotate_unidentified"
//	@Router       /unidentified-events/{id}/annotate [post]
func (m *Module) annotateUnidentified(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var body dto.UnidentifiedAnnotate
	if err := httpx.DecodeAndValidate(r, &body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.AnnotateUnidentified(ctx, tenant.CompanyID(ctx), id, tenant.UserID(ctx), body)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// listViolations godoc
//
//	@Summary      List violations
//	@Description  Q57/Q58 — the canonical violation history. Violations are created on the server only (the mobile app previews them) and are **never deleted**: a closed one keeps `resolved_at` and `resolved_reason` and stays in the list. Q59: the filters are independent of each other. Closing rules: `break_required` after a qualifying break, `drive_limit`/`shift_limit` after a daily rest, `cycle_limit` after a restart or when the day drops out of the cycle window, `form_manner_*` when the field is filled in and the log is certified again, `uncertified_log` on signature and `unidentified_driving` on assignment.
//	@Tags         violations
//	@Produce      json
//	@Param        driver_id  query     string  false  "Driver filter (uuid)"
//	@Param        type       query     string  false  "Violation type"  Enums(form_manner_trailer, form_manner_doc, drive_limit, shift_limit, break_required, cycle_limit, uncertified_log, unidentified_driving, eld_malfunction, missing_dvir)
//	@Param        severity   query     string  false  "Severity"        Enums(warning, violation)
//	@Param        resolved   query     bool    false  "Only resolved (true) or only open (false)"
//	@Param        from       query     string  false  "Occurred from, RFC3339"
//	@Param        to         query     string  false  "Occurred before, RFC3339"
//	@Param        page       query     int     false  "Page number"                        default(1)
//	@Param        per_page   query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.ViolationListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "violations.read"
//	@Router       /violations [get]
func (m *Module) listViolations(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f := ViolationFilter{CompanyID: tenant.CompanyID(ctx), Limit: page.Limit(), Offset: page.Offset()}
	if f.DriverID, err = httpx.QueryUUID(r, "driver_id"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.Type, err = queryEnum(r, "type", violationTypes...); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.Severity, err = queryEnum(r, "severity", "warning", "violation"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.Resolved, err = httpx.QueryBool(r, "resolved"); err != nil {
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
	if err := m.applyScope(r, &f); err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	rows, total, err := m.svc.ViolationList(ctx, f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// getViolation godoc
//
//	@Summary      Violation detail
//	@Description  Q57 — one stored violation with the policy version it was judged under (Q10.1) and, once closed, its `resolved_reason` (Q58). The row is never removed.
//	@Tags         violations
//	@Produce      json
//	@Param        id   path      string  true  "Violation id (uuid)"
//	@Success      200  {object}  dto.ViolationEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "violations.read"
//	@Router       /violations/{id} [get]
func (m *Module) getViolation(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	row, err := m.svc.repo.Violation(ctx, tenant.CompanyID(ctx), id)
	if err != nil {
		httpx.WriteError(w, r, notFoundOr(err, "violation"))
		return
	}
	if err := m.allowViolation(ctx, row); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out := violationDTO(row)
	httpx.WriteData(w, http.StatusOK, out)
}

// violationTypes is the canonical Q57 catalogue used by the filter whitelist.
var violationTypes = []string{
	"form_manner_trailer", "form_manner_doc", "drive_limit", "shift_limit",
	"break_required", "cycle_limit", "uncertified_log", "unidentified_driving",
	"eld_malfunction", "missing_dvir",
}

var (
	_ dto.UnidentifiedEventEnvelope
	_ dto.ViolationListEnvelope
	_ dto.ViolationEnvelope
)
