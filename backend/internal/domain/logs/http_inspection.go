package logs

import (
	"context"
	"errors"
	"net/http"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// beginInspection godoc
//
//	@Summary      Begin roadside inspection
//	@Description  Q54 — mints a short lived, **read only** token for the inspector. The token is a limited capability principal that holds no permission at all, so it can only reach `GET /inspection/logs`; every write endpoint, including `/inspection/email` and `/inspection/transfer`, refuses it with 403. Its lifetime is the configured access token TTL. NOTE: the TZ D§3 endpoint table does not list this route yet; it is required to issue the roadside token and needs a contract amendment.
//	@Tags         inspection
//	@Produce      json
//	@Success      201  {object}  dto.InspectionSessionEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Failure      503  {object}  dto.ErrorResponse  "SERVICE_UNAVAILABLE"
//	@Security     BearerAuth
//	@x-permission "inspection.view"
//	@Router       /inspection/begin [post]
func (m *Module) beginInspection(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok {
		httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
		return
	}
	out, err := m.svc.InspectionSession(ctx, tenant.CompanyID(ctx), p)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// inspectionLogs godoc
//
//	@Summary      Roadside inspection logs
//	@Description  Q53 — 7 days plus today for one driver: every log day with its events, its Log Form and its violations. The endpoint accepts the read only roadside token issued by `POST /inspection/begin` as well as a normal principal holding `inspection.view`. A roadside token can do nothing else: it holds no permission, so every other route answers 403.
//	@Tags         inspection
//	@Produce      json
//	@Param        driver_id  query     string  false  "Driver id (uuid); a driver always reads its own logs"
//	@Param        date       query     string  false  "Window anchor, YYYY-MM-DD (default: today)"
//	@Success      200  {object}  dto.InspectionReportEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "inspection.view"
//	@Router       /inspection/logs [get]
func (m *Module) inspectionLogs(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	driverID, err := m.inspectionDriver(r, nil)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	date, err := httpx.QueryDate(r, "date")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.InspectionReport(ctx, tenant.CompanyID(ctx), driverID, date)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// inspectionEmail godoc
//
//	@Summary      E-mail the inspection report
//	@Description  Q55 — sends the roadside window (7 days plus today) as a PDF built from the log grid, the event list and the Log Form. The comment is optional. The read only roadside token cannot reach this endpoint: sending is a write action gated by `inspection.email`.
//	@Tags         inspection
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.InspectionEmail  true  "Recipient and window"
//	@Success      202  {object}  dto.MessageEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Failure      500  {object}  dto.ErrorResponse  "INTERNAL_ERROR"
//	@Security     BearerAuth
//	@x-permission "inspection.email"
//	@Router       /inspection/email [post]
func (m *Module) inspectionEmail(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	var body dto.InspectionEmail
	if err := httpx.DecodeAndValidate(r, &body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driverID, err := m.inspectionDriver(r, body.DriverID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.EmailInspection(ctx, tenant.CompanyID(ctx), driverID, tenant.UserID(ctx), body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusAccepted, map[string]string{"message": "inspection report queued"})
}

// inspectionTransfer godoc
//
//	@Summary      Transfer the inspection output file
//	@Description  Q56 — builds the regulator output file for the roadside window. With `regulation_profile=generic` the answer is a ZIP holding the event CSV next to the printed report. `us_fmcsa` needs the FMCSA ELD output file (§4.8.2.1), which is delivered in stage 7 and answers 501 until then. The read only roadside token cannot reach this endpoint.
//	@Tags         inspection
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.InspectionTransfer  true  "Window and comment"
//	@Success      200  {object}  dto.InspectionTransferEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Failure      501  {object}  dto.ErrorResponse  "FEATURE_DISABLED"
//	@Failure      502  {object}  dto.ErrorResponse  "STORAGE_ERROR"
//	@Security     BearerAuth
//	@x-permission "inspection.transfer"
//	@Router       /inspection/transfer [post]
func (m *Module) inspectionTransfer(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	var body dto.InspectionTransfer
	if err := httpx.DecodeAndValidate(r, &body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driverID, err := m.inspectionDriver(r, body.DriverID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.TransferInspection(ctx, tenant.CompanyID(ctx), driverID, tenant.UserID(ctx), body)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// inspectionDriver resolves whose logs are being inspected. A self scoped
// caller (driver or roadside token) always reads its own logs.
func (m *Module) inspectionDriver(r *http.Request, explicit *string) (uuid.UUID, error) {
	ctx := r.Context()
	scope, _ := mw.ScopeFrom(ctx)
	if scope.Scope == tenant.ScopeSelf {
		self, err := m.selfDriver(ctx)
		if err != nil {
			return uuid.Nil, err
		}
		return self.DriverID, nil
	}

	raw := ""
	if explicit != nil {
		raw = *explicit
	}
	if raw == "" {
		raw = r.URL.Query().Get("driver_id")
	}
	if raw == "" {
		return uuid.Nil, apierr.Validation("driver_id is required for this caller",
			apierr.FieldError{Field: "driver_id", Message: "required"})
	}
	id, err := uuid.Parse(raw)
	if err != nil {
		return uuid.Nil, apierr.Validation("driver_id must be a uuid",
			apierr.FieldError{Field: "driver_id", Message: apierr.MsgMustBeUUID})
	}
	driver, err := m.svc.duty.DriverContext(ctx, tenant.CompanyID(ctx), id)
	if err != nil {
		return uuid.Nil, err
	}
	if err := m.allow(ctx, driver.BranchID, driver.UserID); err != nil {
		return uuid.Nil, apierr.NotFound("driver")
	}
	return id, nil
}

// applyScope narrows a violation filter to the caller's visibility. It fails
// closed: a self scoped caller whose driver record cannot be resolved is
// refused instead of falling back to the whole company.
func (m *Module) applyScope(r *http.Request, f *ViolationFilter) error {
	ctx := r.Context()
	scope, ok := mw.ScopeFrom(ctx)
	if !ok {
		return apierr.Unauthorized("authentication required")
	}
	switch scope.Scope {
	case tenant.ScopeSelf:
		self, err := m.selfDriver(ctx)
		if err != nil {
			return err
		}
		id := self.DriverID
		f.DriverID = &id
	case tenant.ScopeBranch:
		f.BranchID = scope.BranchID
	}
	return nil
}

// allowViolation enforces the branch and self scopes on a single stored
// violation. A row the caller may not see answers 404, never 403, so the
// endpoint never confirms that the violation exists.
func (m *Module) allowViolation(ctx context.Context, row ViolationRow) error {
	scope, ok := mw.ScopeFrom(ctx)
	if !ok {
		return apierr.Unauthorized("authentication required")
	}
	if !scope.AllowsBranch(row.BranchID) {
		return apierr.NotFound("violation")
	}
	if scope.Scope != tenant.ScopeSelf {
		return nil
	}
	self, err := m.selfDriver(ctx)
	if err != nil || row.DriverID == nil || *row.DriverID != self.DriverID {
		return apierr.NotFound("violation")
	}
	return nil
}

// notFoundOr maps a missing row onto 404 and everything else onto 500.
func notFoundOr(err error, resource string) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return apierr.NotFound(resource)
	}
	return apierr.Internal(err, "failed to load "+resource)
}

var (
	_ dto.InspectionSessionEnvelope
	_ dto.InspectionReportEnvelope
	_ dto.InspectionTransferEnvelope
	_ dto.MessageEnvelope
)
