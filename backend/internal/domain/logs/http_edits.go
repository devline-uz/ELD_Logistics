package logs

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// createEditRequest godoc
//
//	@Summary      Propose a log edit
//	@Description  TZ §5.3 / Q17 [MUST] — an administrator never rewrites a driver log directly. The proposal is stored `pending` and the driver approves or rejects it. `note` is mandatory on every change. Q17.1 is enforced already at proposal time: automatically recorded `DR` may not be shortened or re-classified (`DR_IMMUTABLE`), and `intermediate`, `power_on/off` and `malfunction` events are never editable (`EVENT_IMMUTABLE`).
//	@Tags         log-edits
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.LogEditRequestCreate  true  "Proposed changes"
//	@Success      201  {object}  dto.LogEditRequestEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "DR_IMMUTABLE / EVENT_IMMUTABLE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.propose_edit"
//	@Router       /log-edit-requests [post]
func (m *Module) createEditRequest(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	var body dto.LogEditRequestCreate
	if err := httpx.DecodeAndValidate(r, &body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateEditRequest(ctx, CreateEditInput{
		CompanyID: tenant.CompanyID(ctx), RequestedBy: tenant.UserID(ctx), Body: body,
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// listEditRequests godoc
//
//	@Summary      List log edit requests
//	@Description  Q17 — the propose/approve queue. An administrator sees the whole company (or its branch), a Driver (scope `self`) only its own pending edits, which is the mobile "Pending edits" screen.
//	@Tags         log-edits
//	@Produce      json
//	@Param        status     query     string  false  "Status filter"  Enums(pending, approved, rejected)
//	@Param        driver_id  query     string  false  "Driver filter (uuid)"
//	@Param        page       query     int     false  "Page number"                        default(1)
//	@Param        per_page   query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.LogEditRequestListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.read"
//	@Router       /log-edit-requests [get]
func (m *Module) listEditRequests(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	status, err := queryEnum(r, "status", editPending, editApproved, editRejected)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driverID, err := httpx.QueryUUID(r, "driver_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	f := EditRequestFilter{
		CompanyID: tenant.CompanyID(ctx), Status: status, DriverID: driverID,
		Limit: page.Limit(), Offset: page.Offset(),
	}
	scope, _ := mw.ScopeFrom(ctx)
	switch scope.Scope {
	case tenant.ScopeSelf:
		self, err := m.selfDriver(ctx)
		if err != nil {
			httpx.WriteError(w, r, err)
			return
		}
		id := self.DriverID
		f.DriverID = &id
	case tenant.ScopeBranch:
		f.BranchID = scope.BranchID
	}

	rows, total, err := m.svc.EditRequestList(ctx, f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// approveEditRequest godoc
//
//	@Summary      Approve a log edit request
//	@Description  Q17 — only the driver whose log is being changed may approve. The new events are written with `origin=admin_edit`, the original events are kept and flagged with `superseded_by` (nothing is deleted) and a certified day falls back to `needs_recertify` (Q18). For an `unidentified_assign` request the stored driving rows are handed over with `origin=assigned` (§10.4) and the 8 day `unidentified_driving` violation is closed.
//	@Tags         log-edits
//	@Produce      json
//	@Param        id   path      string  true  "Log edit request id (uuid)"
//	@Success      200  {object}  dto.LogEditRequestEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE / DR_IMMUTABLE / EVENT_IMMUTABLE"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.approve_edit"
//	@Router       /log-edit-requests/{id}/approve [post]
func (m *Module) approveEditRequest(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	req, err := m.resolveEditRequest(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.requireOwner(ctx, req.DriverID); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.ApproveEdit(ctx, req, tenant.UserID(ctx))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// rejectEditRequest godoc
//
//	@Summary      Reject a log edit request
//	@Description  Q17 — only the driver may reject, and the reason is mandatory. The log stays exactly as it is and the administrator is told why.
//	@Tags         log-edits
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string             true  "Log edit request id (uuid)"
//	@Param        body  body      dto.LogEditReject  true  "Rejection reason"
//	@Success      200  {object}  dto.LogEditRequestEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.reject_edit"
//	@Router       /log-edit-requests/{id}/reject [post]
func (m *Module) rejectEditRequest(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	req, err := m.resolveEditRequest(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.requireOwner(ctx, req.DriverID); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var body dto.LogEditReject
	if err := httpx.DecodeAndValidate(r, &body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.RejectEdit(ctx, req, tenant.UserID(ctx), body.Reason)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// driverEdit godoc
//
//	@Summary      Driver log edit
//	@Description  Q17 — the driver's own correction. It is applied immediately with `origin=driver_edit`, `note` is mandatory and the original events are kept behind `superseded_by`. Q17.1 still applies: automatically recorded `DR` may not be shortened or turned into another status — the only permitted rewrite is the driver re-labelling it as Personal Conveyance or Yard Move; `intermediate`, `power_on/off` and `malfunction` events are never editable. A certified day falls back to `needs_recertify` (Q18).
//	@Tags         log-edits
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string              true  "Daily log id (uuid)"
//	@Param        body  body      dto.LogEventCreate  true  "Duty status interval"
//	@Success      200  {object}  dto.DailyLogEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "DR_IMMUTABLE / EVENT_IMMUTABLE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.add_event"
//	@Router       /daily-logs/{id}/events [post]
func (m *Module) driverEdit(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	log, err := m.resolveLog(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.requireOwner(ctx, log.DriverID); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var body dto.LogEventCreate
	if err := httpx.DecodeAndValidate(r, &body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.DriverEdit(ctx, log, tenant.UserID(ctx), body)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// resolveEditRequest loads the request of the {id} path parameter and applies
// the caller's scope.
func (m *Module) resolveEditRequest(r *http.Request) (EditRequest, error) {
	ctx := r.Context()
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		return EditRequest{}, err
	}
	req, err := m.svc.EditRequest(ctx, tenant.CompanyID(ctx), id)
	if err != nil {
		return EditRequest{}, err
	}
	f, ok := mw.ScopeFrom(ctx)
	if !ok {
		return EditRequest{}, apierr.Unauthorized("authentication required")
	}
	if !f.AllowsBranch(req.BranchID) || !f.AllowsUser(req.DriverUserID) {
		return EditRequest{}, apierr.NotFound("log edit request")
	}
	return req, nil
}

// queryEnum reads an optional query parameter constrained to a whitelist.
func queryEnum(r *http.Request, key string, allowed ...string) (*string, error) {
	raw := r.URL.Query().Get(key)
	if raw == "" {
		return nil, nil
	}
	for _, a := range allowed {
		if raw == a {
			v := raw
			return &v, nil
		}
	}
	return nil, apierr.Validation("unsupported "+key+" value",
		apierr.FieldError{Field: key, Message: "unsupported value"})
}

var (
	_ dto.LogEditRequestEnvelope
	_ dto.LogEditRequestListEnvelope
)
