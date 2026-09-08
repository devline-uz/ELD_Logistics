package dvir

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Deps are the DVIR module dependencies. Repo and Verifier are required; the
// rest degrade gracefully so tests can wire a minimal module.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	// Alerter receives the Q27.2 critical defect signal. Nil means no alerts.
	Alerter Alerter
	// Renderer prints the DVIR PDF; nil falls back to HTML.
	Renderer Renderer
	// Store backs the per user rate limit.
	Store cache.Store
	// Audit is kept for symmetry with the other modules; the repo writes the
	// entries inside its own transactions.
	Audit audit.Recorder
	Log   *slog.Logger
	// Now is injectable so the captured inspection time is testable.
	Now func() time.Time
}

// Module wires the DVIR routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the DVIR HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo, deps.Alerter, deps.Renderer, deps.Log, deps.Now),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// Service exposes the business layer so internal/jobs can drive the Q30.1
// fallback sweep without re-building the module.
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

		g.With(mw.RequirePermission(auth.PermDVIRRead)).Get("/dvir-reports", m.list)
		g.With(mw.RequirePermission(auth.PermDVIRRead)).Get("/dvir-reports/pending-certification", m.pending)
		g.With(mw.RequirePermission(auth.PermDVIRRead)).Get("/dvir-reports/{id}", m.get)
		g.With(mw.RequirePermission(auth.PermDVIRExport)).Get("/dvir-reports/{id}/pdf", m.pdf)
		g.With(mw.RequirePermission(auth.PermDVIRCreate)).Post("/dvir-reports", m.create)
		g.With(mw.RequirePermission(auth.PermDVIRRepair)).Post("/dvir-reports/{id}/repair", m.repair)
		g.With(mw.RequirePermission(auth.PermDVIRCertify)).Post("/dvir-reports/{id}/certify", m.certify)

		g.With(mw.RequirePermission(auth.PermDefectTypesRead)).Get("/defect-types", m.listDefectTypes)
		g.With(mw.RequirePermission(auth.PermDefectTypesCreate)).Post("/defect-types", m.createDefectType)
		g.With(mw.RequirePermission(auth.PermDefectTypesUpdate)).Patch("/defect-types/{id}", m.updateDefectType)
	})
}

// list godoc
//
//	@Summary      List DVIR reports
//	@Description  TZ §7 — inspection reports of the tenant, newest first. `status` follows the §7.2 state machine and `kind` is the derived mobile label of §7.3 (`no_defects`, `defects_not_fixed`, `defects_uncertified`, `defects_fixed`). A self scoped principal (driver) only sees its own reports. Distances are metres; timestamps are ISO 8601 UTC.
//	@Tags         dvir
//	@Produce      json
//	@Param        unit_id    query     string  false  "Unit filter (uuid)"
//	@Param        driver_id  query     string  false  "Driver filter (uuid)"
//	@Param        type       query     string  false  "Inspection type"  Enums(pre_trip, post_trip)
//	@Param        status     query     string  false  "State machine status"  Enums(draft, submitted_no_defects, submitted_defects_found, repaired, certified, closed_no_certification)
//	@Param        from       query     string  false  "Start of the window (RFC3339 UTC)"           example(2026-09-01T00:00:00Z)
//	@Param        to         query     string  false  "End of the window, exclusive (RFC3339 UTC)"  example(2026-09-08T00:00:00Z)
//	@Param        page       query     int     false  "Page number"                        default(1)
//	@Param        per_page   query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.DvirReportListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "dvir.read"
//	@Router       /dvir-reports [get]
func (m *Module) list(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f := ReportFilter{Limit: page.Limit(), Offset: page.Offset()}
	if f.UnitID, err = httpx.QueryUUID(r, "unit_id"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.DriverID, err = httpx.QueryUUID(r, "driver_id"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.Type, err = queryEnum(r, "type", dto.TypePreTrip, dto.TypePostTrip); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.Status, err = queryEnum(r, "status", dto.StatusDraft, dto.StatusSubmittedNoDefects,
		dto.StatusSubmittedDefectsFound, dto.StatusRepaired, dto.StatusCertified,
		dto.StatusClosedNoCertification); err != nil {
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
	// A self scoped principal never widens past its own driver record.
	if self, ok := m.selfDriverID(r); ok {
		f.DriverID = &self
	}
	if scope, ok := mw.ScopeFrom(r.Context()); ok && scope.Scope == tenant.ScopeBranch && scope.BranchID != nil {
		f.BranchID = scope.BranchID
	}

	reports, total, err := m.svc.List(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, reports, page.Meta(total))
}

// get godoc
//
//	@Summary      Get DVIR report
//	@Description  One inspection report with its defects, signatures and repair trail. Cross-tenant and out of scope ids answer 404, never 403.
//	@Tags         dvir
//	@Produce      json
//	@Param        id   path      string  true  "DVIR report id"
//	@Success      200  {object}  dto.DvirReportEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "dvir.read"
//	@Router       /dvir-reports/{id} [get]
func (m *Module) get(w http.ResponseWriter, r *http.Request) {
	rep, err := m.resolve(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, rep)
}

// pending godoc
//
//	@Summary      DVIR reports pending certification
//	@Description  TZ §7.2 — the reports whose defects still wait for the driver's "Previous defects repaired?" signature. The mobile app calls this before a pre-trip DVIR of the same unit. Q30.1: after seven days without a follow-up report, or once the unit goes inactive, a background sweep closes the entry as `closed_no_certification` and it disappears from this list.
//	@Tags         dvir
//	@Produce      json
//	@Param        unit_id  query     string  false  "Unit filter (uuid)"
//	@Success      200  {object}  dto.DvirReportListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "dvir.read"
//	@Router       /dvir-reports/pending-certification [get]
func (m *Module) pending(w http.ResponseWriter, r *http.Request) {
	unitID, err := httpx.QueryUUID(r, "unit_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	reports, err := m.svc.PendingCertification(r.Context(), unitID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, reports, httpx.Meta{Page: 1, PerPage: len(reports), Total: int64(len(reports))})
}

// create godoc
//
//	@Summary      Submit a DVIR report
//	@Description  TZ §7.1 (mobile, driver only). Q31: an administrator never files a DVIR on a driver's behalf, so the caller must own a driver record — anyone else gets 403 `DVIR_ADMIN_CREATE_DENIED`. Q28: time, location, odometer and engine hours are captured server side from telemetry, so the body carries none of them. Q27.1: every defect references the `defect_types` catalogue and carries at most five photos. Q27.2: a defect flagged `is_critical` sets `units.out_of_service` and raises an immediate alert. The stored status is derived, not sent: no defects yields `submitted_no_defects`, any defect yields `submitted_defects_found` (the mobile `in_progress` state never reaches the server, Q30.2).
//	@Tags         dvir
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.DvirCreate  true  "Inspection payload"
//	@Success      201   {object}  dto.DvirReportEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "DVIR_ADMIN_CREATE_DENIED"
//	@Failure      404   {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409   {object}  dto.ErrorResponse  "DVIR_INVALID_TRANSITION"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR / DEFECT_TYPE_UNKNOWN"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "dvir.create"
//	@Router       /dvir-reports [post]
func (m *Module) create(w http.ResponseWriter, r *http.Request) {
	var in dto.DvirCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	rep, err := m.svc.Create(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, rep)
}

// repair godoc
//
//	@Summary      Record a DVIR repair
//	@Description  TZ §7.2 — the Service Manager transition `submitted_defects_found` → `repaired`. Q27: the mechanic signature only exists on this step. An optional invoice (number, vendor, cost, file key) is written to the maintenance history. Any other source status answers 409 `DVIR_INVALID_TRANSITION`.
//	@Tags         dvir
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string          true  "DVIR report id"
//	@Param        body  body      dto.DvirRepair  true  "Repair payload"
//	@Success      200   {object}  dto.DvirReportEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404   {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409   {object}  dto.ErrorResponse  "DVIR_INVALID_TRANSITION"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "dvir.repair"
//	@Router       /dvir-reports/{id}/repair [post]
func (m *Module) repair(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.DvirRepair
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	rep, err := m.svc.Repair(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, rep)
}

// certify godoc
//
//	@Summary      Certify a repaired DVIR
//	@Description  TZ §7.2 — the driver answers "Previous defects repaired?" with a signature, moving `repaired` → `certified`. Q30.1: a different driver of the same tenant is accepted, so the endpoint only requires the caller to own a driver record. Once a critical defect report is certified the unit leaves `out_of_service`. Any other source status answers 409 `DVIR_INVALID_TRANSITION`.
//	@Tags         dvir
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string           true  "DVIR report id"
//	@Param        body  body      dto.DvirCertify  true  "Driver signature"
//	@Success      200   {object}  dto.DvirReportEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "DVIR_ADMIN_CREATE_DENIED"
//	@Failure      404   {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409   {object}  dto.ErrorResponse  "DVIR_INVALID_TRANSITION"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "dvir.certify"
//	@Router       /dvir-reports/{id}/certify [post]
func (m *Module) certify(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.DvirCertify
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	rep, err := m.svc.Certify(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, rep)
}

// pdf godoc
//
//	@Summary      DVIR report PDF
//	@Description  Q31 — the administrator "Generate Report" surface: a printable copy of an existing DVIR, never a new one. The document is printed with headless Chrome; when no Chrome binary is reachable the endpoint degrades to `text/html` instead of failing, so check `Content-Type`. Signature and photo files stay object storage references and are not embedded.
//	@Tags         dvir
//	@Produce      application/pdf
//	@Produce      text/html
//	@Param        id   path      string  true  "DVIR report id"
//	@Success      200  {string}  binary  "Inspection report"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Failure      502  {object}  dto.ErrorResponse  "UPSTREAM_ERROR"
//	@Security     BearerAuth
//	@x-permission "dvir.export"
//	@Router       /dvir-reports/{id}/pdf [get]
func (m *Module) pdf(w http.ResponseWriter, r *http.Request) {
	rep, err := m.resolve(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	body, contentType, err := m.svc.RenderPDF(r.Context(), *rep)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	w.Header().Set("Content-Type", contentType)
	w.Header().Set("Content-Disposition", `inline; filename="dvir-`+rep.ID+ExtFor(contentType)+`"`)
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(body) //nolint:gosec // G705: body/contentType are server-rendered (chromedp), not attacker input; nosniff set above
}
