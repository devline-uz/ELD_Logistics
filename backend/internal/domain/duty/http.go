package duty

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/duty/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// maxEventRange bounds the duty status event window so one request cannot ask
// for an unbounded history.
const maxEventRange = 62 * 24 * time.Hour

// Deps are the duty module dependencies. Repo and Verifier are required; Store
// only adds the per user rate limit, so tests can wire a minimal module.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	// Store backs the per user rate limit.
	Store cache.Store
	// Now is injectable so the home terminal day boundary is testable.
	Now func() time.Time
	Log *slog.Logger
}

// Module wires the duty status and HOS routes into the /api/v1 router. It
// implements server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the duty HTTP module.
func New(d Deps) *Module {
	return &Module{
		svc:      NewService(d.Repo, d.Now, d.Log),
		verifier: d.Verifier,
		store:    d.Store,
	}
}

// Service exposes the duty service so /sync/push can write events through it.
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

		g.With(mw.RequirePermission(auth.PermLogsRead)).
			Get("/drivers/{id}/duty-status-events", m.events)
		g.With(mw.RequirePermission(auth.PermLogsRead)).
			Get("/drivers/{id}/hos-summary", m.hosSummary)
	})
}

// events godoc
//
//	@Summary      List duty status events
//	@Description  TZ A§3 — the driver's duty status events inside [from, to). Superseded events (conflict rule 1) are hidden; the surviving row carries `superseded_by` on the loser instead. Times are UTC and the window may not exceed 62 days. A Driver (scope `self`) may only read its own events; another company's driver id answers 404, never 403.
//	@Tags         logs
//	@Produce      json
//	@Param        id        path      string  true   "Driver id (uuid)"
//	@Param        from      query     string  false  "Window start, RFC3339 (default: 8 days ago)"
//	@Param        to        query     string  false  "Window end, RFC3339 (default: now)"
//	@Param        page      query     int     false  "Page number"                        default(1)
//	@Param        per_page  query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.DutyStatusEventListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.read"
//	@Router       /drivers/{id}/duty-status-events [get]
func (m *Module) events(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	companyID := tenant.CompanyID(ctx)

	driverID, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driver, err := m.svc.DriverContext(ctx, companyID, driverID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.allow(ctx, driver); err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	from, to, err := m.window(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	rows, total, err := m.svc.Events(ctx, PageFilter{
		CompanyID: companyID, DriverID: driverID,
		From: from, To: to, Limit: page.Limit(), Offset: page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// hosSummary godoc
//
//	@Summary      Driver HOS summary
//	@Description  TZ A§4 — the BREAK/DRIVE/SHIFT/CYCLE counters, the four duty-line totals of the log day, the cycle recap (Q10.7) and the computed warnings/violations. The log day is the home terminal 00:00-24:00 window (Q10.2) and the policy is the `hos_policy_versions` row in force on that day, so a policy change never rewrites history (Q10.1). Violations are reported here but only persisted from stage 4 on — the server stays canonical. A Driver (scope `self`) may only read its own summary.
//	@Tags         logs
//	@Produce      json
//	@Param        id    path      string  true   "Driver id (uuid)"
//	@Param        date  query     string  false  "Log day, YYYY-MM-DD in the home terminal timezone (default: today)"
//	@Success      200  {object}  dto.HosSummaryEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.read"
//	@Router       /drivers/{id}/hos-summary [get]
func (m *Module) hosSummary(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	companyID := tenant.CompanyID(ctx)

	driverID, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driver, err := m.svc.DriverContext(ctx, companyID, driverID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.allow(ctx, driver); err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	date, err := httpx.QueryDate(r, "date")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	// The default day is "today" in the driver's home terminal timezone.
	day := m.svc.now().In(driver.Location())
	if date != nil {
		day = time.Date(date.Year(), date.Month(), date.Day(), 12, 0, 0, 0, driver.Location())
	}

	out, err := m.svc.Summary(ctx, companyID, driverID, day)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// allow enforces the branch and self scopes on a resolved driver. A driver that
// the caller may not see answers 404, so the endpoint never confirms the
// existence of a row outside the caller's scope.
func (m *Module) allow(ctx context.Context, driver Context) error {
	f, ok := mw.ScopeFrom(ctx)
	if !ok {
		return apierr.Unauthorized("authentication required")
	}
	if !f.AllowsBranch(driver.BranchID) || !f.AllowsUser(driver.UserID) {
		return apierr.NotFound("driver")
	}
	return nil
}

// window resolves the [from, to) event window and enforces its ceiling.
func (m *Module) window(r *http.Request) (time.Time, time.Time, error) {
	now := m.svc.now().UTC()
	from, err := httpx.QueryTime(r, "from")
	if err != nil {
		return time.Time{}, time.Time{}, err
	}
	to, err := httpx.QueryTime(r, "to")
	if err != nil {
		return time.Time{}, time.Time{}, err
	}

	end := now
	if to != nil {
		end = to.UTC()
	}
	start := end.AddDate(0, 0, -8)
	if from != nil {
		start = from.UTC()
	}
	if !start.Before(end) {
		return time.Time{}, time.Time{}, apierr.Validation("from must be before to",
			apierr.FieldError{Field: "from", Message: "must be before to"})
	}
	if end.Sub(start) > maxEventRange {
		return time.Time{}, time.Time{}, apierr.Validation("the window may not exceed 62 days",
			apierr.FieldError{Field: "from", Message: "window too wide"})
	}
	return start, end, nil
}

// The swagger annotations above name the response envelopes; the handlers
// write their contents through httpx, so the package is referenced here.
var (
	_ dto.DutyStatusEventListEnvelope
	_ dto.HosSummaryEnvelope
)
