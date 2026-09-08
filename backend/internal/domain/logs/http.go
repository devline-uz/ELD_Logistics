package logs

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/duty"
	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Deps are the logs module dependencies. Repo, Duty and Verifier are required;
// the rest only widen what the module can do, so a test can wire a minimal
// module and still exercise the whole rule layer.
type Deps struct {
	Repo Repo
	// Duty is the stage 3 duty service; it owns driver context and the hos
	// policy in force on a day (Q10.1).
	Duty     DutyService
	Verifier mw.AuthVerifier
	// Store backs the per user rate limit.
	Store cache.Store
	// Now is injectable so the certification window is testable.
	Now func() time.Time
	Log *slog.Logger
	// Renderer prints the log report; nil degrades to HTML (see HTMLRenderer).
	Renderer Renderer
	// Mailer delivers the roadside report; nil only records the delivery.
	Mailer Mailer
	// Files stores the inspection transfer archive.
	Files ObjectStore
	// Tokens mints the read only roadside token (Q54).
	Tokens TokenIssuer
	// Audit records the export actions; nil disables recording.
	Audit audit.Recorder
	// Alerter delivers the TZ A§5.3 propose/resolve notifications. Nil means
	// no alerts (NopAlerter).
	Alerter Alerter
}

// Module wires the daily log, certification, log edit, unidentified driving,
// violation and inspection routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the logs HTTP module.
func New(d Deps) *Module {
	return &Module{svc: NewService(d), verifier: d.Verifier, store: d.Store}
}

// Service exposes the logs service so /sync/pull can ship the pending edit
// requests without a second repository.
func (m *Module) Service() *Service { return m.svc }

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		// Unconditional: a module wired without a verifier must fail closed
		// (mw.Authenticate answers 503) rather than serve logs unauthenticated.
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}

		g.With(mw.RequirePermission(auth.PermLogsRead)).Get("/drivers/{id}/daily-logs", m.driverLogs)
		g.With(mw.RequirePermission(auth.PermLogsRead)).Get("/daily-logs/{id}", m.dailyLog)
		g.With(mw.RequirePermission(auth.PermLogsExport)).Get("/daily-logs/{id}/pdf", m.dailyLogPDF)
		g.With(mw.RequirePermission(auth.PermLogsCertify)).Post("/daily-logs/{id}/certify", m.certify)
		g.With(mw.RequirePermission(auth.PermLogsAddEvent)).Post("/daily-logs/{id}/events", m.driverEdit)
		g.With(mw.RequirePermission(auth.PermReportsRead)).Get("/reports/uncertified-logs", m.uncertifiedLogs)

		g.With(mw.RequirePermission(auth.PermLogsProposeEdit)).Post("/log-edit-requests", m.createEditRequest)
		g.With(mw.RequirePermission(auth.PermLogsRead)).Get("/log-edit-requests", m.listEditRequests)
		g.With(mw.RequirePermission(auth.PermLogsApproveEdit)).Post("/log-edit-requests/{id}/approve", m.approveEditRequest)
		g.With(mw.RequirePermission(auth.PermLogsRejectEdit)).Post("/log-edit-requests/{id}/reject", m.rejectEditRequest)

		g.With(mw.RequirePermission(auth.PermLogsAssignUnidentified)).Post("/unidentified-events/{id}/assign", m.assignUnidentified)
		g.With(mw.RequirePermission(auth.PermLogsClaimUnidentified)).Post("/unidentified-events/{id}/claim", m.claimUnidentified)
		g.With(mw.RequirePermission(auth.PermLogsAnnotateUnidentifed)).Post("/unidentified-events/{id}/annotate", m.annotateUnidentified)

		g.With(mw.RequirePermission(auth.PermViolationsRead)).Get("/violations", m.listViolations)
		g.With(mw.RequirePermission(auth.PermViolationsRead)).Get("/violations/{id}", m.getViolation)

		g.With(mw.RequirePermission(auth.PermInspectionView)).Post("/inspection/begin", m.beginInspection)
		g.With(mw.RequirePermission(auth.PermInspectionEmail)).Post("/inspection/email", m.inspectionEmail)
		g.With(mw.RequirePermission(auth.PermInspectionTransfer)).Post("/inspection/transfer", m.inspectionTransfer)
	})

	// Q54: the roadside token is a limited capability principal, so this group
	// deliberately skips RequireFullSession. The gate below accepts either the
	// inspection token or a normal principal holding inspection.view; every
	// write endpoint above still rejects the roadside token, because a
	// restricted principal holds no permission at all.
	r.Group(func(g chi.Router) {
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}
		g.With(requireInspectionRead).Get("/inspection/logs", m.inspectionLogs)
	})
}

// requireInspectionRead accepts the read only roadside token or a principal
// that holds inspection.view.
func requireInspectionRead(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p, ok := tenant.PrincipalFrom(r.Context())
		if !ok {
			httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
			return
		}
		if p.Restricted == RestrictionInspection || p.HasPermission(auth.PermInspectionView) {
			next.ServeHTTP(w, r)
			return
		}
		httpx.WriteError(w, r, apierr.Forbidden("permission inspection.view is required"))
	})
}

// ------------------------------------------------------------------ helpers

// allow enforces the branch and self scopes on a resolved driver. A driver the
// caller may not see answers 404, never 403, so the endpoint never confirms the
// existence of a row outside the caller's scope.
func (m *Module) allow(ctx context.Context, branchID *uuid.UUID, userID uuid.UUID) error {
	f, ok := mw.ScopeFrom(ctx)
	if !ok {
		return apierr.Unauthorized("authentication required")
	}
	if !f.AllowsBranch(branchID) || !f.AllowsUser(userID) {
		return apierr.NotFound("daily log")
	}
	return nil
}

// selfDriver resolves the caller's own driver record. Q26: certification and
// the approve/reject answers are always the driver's own act, never an
// administrator's on the driver's behalf.
func (m *Module) selfDriver(ctx context.Context) (duty.Context, error) {
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok {
		return duty.Context{}, apierr.Unauthorized("authentication required")
	}
	return m.svc.duty.DriverByUser(ctx, tenant.CompanyID(ctx), p.UserID)
}

// requireOwner refuses the call unless the caller is the driver that owns the
// row (Q26, Q17: only the driver answers a proposal).
func (m *Module) requireOwner(ctx context.Context, driverID uuid.UUID) error {
	self, err := m.selfDriver(ctx)
	if err != nil {
		return apierr.Forbidden("only the driver of this log may perform this action")
	}
	if self.DriverID != driverID {
		return apierr.Forbidden("only the driver of this log may perform this action")
	}
	return nil
}

// window resolves the [from, to] log day window, defaulting to the Q19 8 day
// certification window.
func (m *Module) window(r *http.Request, loc *time.Location) (time.Time, time.Time, error) {
	to := m.svc.now().In(loc)
	if v, err := httpx.QueryDate(r, "to"); err != nil {
		return time.Time{}, time.Time{}, err
	} else if v != nil {
		to = *v
	}
	from := to.AddDate(0, 0, -(CertificationWindowDays - 1))
	if v, err := httpx.QueryDate(r, "from"); err != nil {
		return time.Time{}, time.Time{}, err
	} else if v != nil {
		from = *v
	}
	if to.Before(from) {
		return time.Time{}, time.Time{}, apierr.Validation("from must not be after to",
			apierr.FieldError{Field: "from", Message: "must not be after to"})
	}
	if to.Sub(from) > 366*24*time.Hour {
		return time.Time{}, time.Time{}, apierr.Validation("the window may not exceed one year",
			apierr.FieldError{Field: "from", Message: "window too wide"})
	}
	return from, to, nil
}

// ------------------------------------------------------------- daily logs

// driverLogs godoc
//
//	@Summary      Driver daily logs
//	@Description  Q19 — the certification window of one driver. The default window is the last 8 days (`certification_window_days`), cut in the home terminal timezone (Q10.2). `certification_status` is `uncertified`, `certified` or `needs_recertify`; `ready` is false while the day still misses its signature (Q25). A Driver (scope `self`) may only read its own logs; another company's driver id answers 404, never 403.
//	@Tags         logs
//	@Produce      json
//	@Param        id        path      string  true   "Driver id (uuid)"
//	@Param        from      query     string  false  "Window start, YYYY-MM-DD (default: 7 days before `to`)"
//	@Param        to        query     string  false  "Window end, YYYY-MM-DD (default: today)"
//	@Param        page      query     int     false  "Page number"                        default(1)
//	@Param        per_page  query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.DailyLogListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.read"
//	@Router       /drivers/{id}/daily-logs [get]
func (m *Module) driverLogs(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	companyID := tenant.CompanyID(ctx)

	driverID, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driver, err := m.svc.duty.DriverContext(ctx, companyID, driverID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.allow(ctx, driver.BranchID, driver.UserID); err != nil {
		httpx.WriteError(w, r, apierr.NotFound("driver"))
		return
	}
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	from, to, err := m.window(r, driver.Location())
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	rows, total, err := m.svc.DriverLogs(ctx, DailyLogFilter{
		CompanyID: companyID, DriverID: driverID, From: from, To: to,
		Limit: page.Limit(), Offset: page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// dailyLog godoc
//
//	@Summary      Daily log detail
//	@Description  Q13/Q16 — one log day with its events and its Log Form: unit(s), driver, co-driver, distance (from telemetry, never edited by hand), trailers, shipping documents and the signature. Superseded events stay in the answer with `superseded_by` so the ✎ edit history is visible (Q17.2). The stored violations of the day are included (Q57, server canonical).
//	@Tags         logs
//	@Produce      json
//	@Param        id   path      string  true  "Daily log id (uuid)"
//	@Success      200  {object}  dto.DailyLogEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.read"
//	@Router       /daily-logs/{id} [get]
func (m *Module) dailyLog(w http.ResponseWriter, r *http.Request) {
	log, err := m.resolveLog(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Detail(r.Context(), log)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// dailyLogPDF godoc
//
//	@Summary      Daily log PDF
//	@Description  Q55 — the printable log: the 24 hour grid, the event list and the Log Form. The document is produced with headless Chrome; on a deployment without a Chromium binary the endpoint degrades to `text/html` with the same content instead of failing a roadside inspection.
//	@Tags         logs
//	@Produce      application/pdf
//	@Param        id   path      string  true  "Daily log id (uuid)"
//	@Success      200  {file}    binary
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Failure      500  {object}  dto.ErrorResponse  "INTERNAL_ERROR"
//	@Security     BearerAuth
//	@x-permission "logs.export"
//	@Router       /daily-logs/{id}/pdf [get]
func (m *Module) dailyLogPDF(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	log, err := m.resolveLog(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	rep, err := m.svc.DayReport(ctx, log)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	body, contentType, err := m.svc.RenderPDF(ctx, rep)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	w.Header().Set("Content-Type", contentType)
	w.Header().Set("Content-Disposition",
		`inline; filename="daily-log-`+rep.From+extFor(contentType)+`"`)
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(body) //nolint:gosec // G705: body/contentType are server-rendered (chromedp), not attacker input; nosniff set above
}

// certify godoc
//
//	@Summary      Certify a daily log
//	@Description  Q26.1 — the driver signs the day: `signed_at`, the signature key, `signed_ip` and `signed_device_id` are stored, a `certification` event is written and the day's events become `locked` (only an approved edit request may move them afterwards). Q26: an administrator never certifies on the driver's behalf, so a caller that is not the owning driver is refused with 403. The signature is taken from `signature_key`, from `signature_id` (a stored signature of the same user) or from the driver's default; without any of them the day is `LOG_NOT_READY` (Q25).
//	@Tags         logs
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string              true  "Daily log id (uuid)"
//	@Param        body  body      dto.CertifyRequest  true  "Signature source"
//	@Success      200  {object}  dto.DailyLogEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "LOG_NOT_READY"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.certify"
//	@Router       /daily-logs/{id}/certify [post]
func (m *Module) certify(w http.ResponseWriter, r *http.Request) {
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
	var body dto.CertifyRequest
	if err := httpx.DecodeAndValidate(r, &body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	out, err := m.svc.Certify(ctx, CertifyInputAPI{
		CompanyID: log.CompanyID, DailyLogID: log.ID,
		UserID: tenant.UserID(ctx), Body: body, IP: httpx.ClientIP(r),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// uncertifiedLogs godoc
//
//	@Summary      Uncertified logs report
//	@Description  Q19.1 — the log days that left the 8 day certification window without a signature. They disappear from the driver's list but stay in this admin alert; `days_overdue` counts the calendar days past the window.
//	@Tags         reports
//	@Produce      json
//	@Param        driver_id  query     string  false  "Driver filter (uuid)"
//	@Param        branch_id  query     string  false  "Branch filter (uuid)"
//	@Param        page       query     int     false  "Page number"                        default(1)
//	@Param        per_page   query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.UncertifiedLogListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "reports.read"
//	@Router       /reports/uncertified-logs [get]
func (m *Module) uncertifiedLogs(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driverID, err := httpx.QueryUUID(r, "driver_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	branchID, err := httpx.QueryUUID(r, "branch_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f := UncertifiedFilter{
		CompanyID: tenant.CompanyID(ctx),
		Before:    m.svc.now().UTC().AddDate(0, 0, -CertificationWindowDays),
		DriverID:  driverID, BranchID: branchID,
		Limit: page.Limit(), Offset: page.Offset(),
	}
	if scope, ok := mw.ScopeFrom(ctx); ok && scope.Scope == tenant.ScopeBranch && scope.BranchID != nil {
		f.BranchID = scope.BranchID
	}

	rows, total, err := m.svc.UncertifiedReport(ctx, f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// resolveLog loads the log day of the {id} path parameter and applies the
// caller's scope.
func (m *Module) resolveLog(r *http.Request) (DailyLog, error) {
	ctx := r.Context()
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		return DailyLog{}, err
	}
	log, err := m.svc.DailyLog(ctx, tenant.CompanyID(ctx), id)
	if err != nil {
		return DailyLog{}, err
	}
	if err := m.allow(ctx, log.BranchID, log.DriverUserID); err != nil {
		return DailyLog{}, err
	}
	return log, nil
}

// The swagger annotations name the response envelopes; the handlers write
// their contents through httpx, so the package is referenced here.
var (
	_ dto.DailyLogListEnvelope
	_ dto.DailyLogEnvelope
	_ dto.UncertifiedLogListEnvelope
)
