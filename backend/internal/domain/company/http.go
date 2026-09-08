package company

import (
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/company/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Deps are the dependencies the company module is wired with. Only Pool is
// mandatory; the rest fall back to safe defaults.
type Deps struct {
	Pool     *db.Pool
	Audit    audit.Recorder
	Cache    cache.Store
	Verifier mw.AuthVerifier
	Logger   *slog.Logger
}

// Module exposes the tenant configuration routes. It implements server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the company module from its infrastructure dependencies.
func New(deps Deps) *Module {
	log := deps.Logger
	if log == nil {
		log = slog.Default()
	}
	svc := NewService(ServiceDeps{
		Repo:   NewRepo(deps.Pool, deps.Audit),
		Logger: log,
	})
	return &Module{svc: svc, verifier: deps.Verifier, store: deps.Cache}
}

// NewWithService builds the module on top of an existing service (tests).
func NewWithService(svc *Service, verifier mw.AuthVerifier, store cache.Store) *Module {
	return &Module{svc: svc, verifier: verifier, store: store}
}

// Sort whitelists.
var branchSortFields = []string{"name", "created_at"}

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Route("/company", func(c chi.Router) {
		c.Use(mw.Authenticate(m.verifier), mw.RequireFullSession, mw.Scope, mw.RequireCompany)
		if m.store != nil {
			c.Use(mw.UserRateLimit(m.store, 600))
		}

		c.With(mw.RequirePermission(auth.PermCompanyRead)).Get("/", m.getCompany)
		c.With(mw.RequirePermission(auth.PermCompanyUpdate)).Patch("/", m.updateCompany)

		c.Route("/branches", func(b chi.Router) {
			b.With(mw.RequirePermission(auth.PermBranchesRead)).Get("/", m.listBranches)
			b.With(mw.RequirePermission(auth.PermBranchesCreate), m.idempotent()).Post("/", m.createBranch)
			b.With(mw.RequirePermission(auth.PermBranchesUpdate)).Patch("/{id}", m.updateBranch)
			b.With(mw.RequirePermission(auth.PermBranchesDelete)).Delete("/{id}", m.deleteBranch)
		})

		c.With(mw.RequirePermission(auth.PermHosPolicyRead)).Get("/hos-policy", m.getHosPolicy)
		c.With(mw.RequirePermission(auth.PermHosPolicyUpdate), m.idempotent()).Post("/hos-policy", m.createHosPolicy)

		c.With(mw.RequirePermission(auth.PermNotifSettingsRead)).Get("/notification-settings", m.getNotificationSettings)
		c.With(mw.RequirePermission(auth.PermNotifSettingsWrite)).Patch("/notification-settings", m.updateNotificationSettings)

		c.With(mw.RequirePermission(auth.PermCompanyHistoryView)).Get("/history", m.history)
	})
}

func (m *Module) idempotent() func(http.Handler) http.Handler {
	if m.store == nil {
		return func(next http.Handler) http.Handler { return next }
	}
	return mw.Idempotency(m.store, false)
}

func metaOf(r *http.Request) RequestMeta {
	return RequestMeta{IP: httpx.ClientIP(r)}
}

// getCompany godoc
//
//	@Summary		Get the company profile
//	@Description	TZ A§1 — the tenant profile plus the region profile (region, unit_system, regulation_profile) and the company level settings document.
//	@Tags			company
//	@Produce		json
//	@Success		200	{object}	dto.CompanyEnvelope
//	@Failure		401	{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403	{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404	{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		429	{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"company.read"
//	@Router			/company [get]
func (m *Module) getCompany(w http.ResponseWriter, r *http.Request) {
	out, err := m.svc.Get(r.Context())
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// updateCompany godoc
//
//	@Summary		Update the company profile
//	@Description	Q0.1/Q0.2 — region, unit_system and regulation_profile drive the labels and the unit conversion in every client. Omitted fields are left unchanged; `settings` replaces the whole settings document.
//	@Tags			company
//	@Accept			json
//	@Produce		json
//	@Param			body	body		dto.CompanyUpdate	true	"Company patch"
//	@Success		200		{object}	dto.CompanyEnvelope
//	@Failure		400		{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404		{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		409		{object}	dto.ErrorResponse	"UNIQUE_VIOLATION"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429		{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"company.update"
//	@Router			/company [patch]
func (m *Module) updateCompany(w http.ResponseWriter, r *http.Request) {
	var in dto.CompanyUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Update(r.Context(), in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// listBranches godoc
//
//	@Summary		List branches
//	@Description	Company locations used as the Sub Admin scope target.
//	@Tags			company
//	@Produce		json
//	@Param			page		query		int		false	"Page number"		default(1)
//	@Param			per_page	query		int		false	"Page size"			default(25)
//	@Param			search		query		string	false	"Name contains"
//	@Param			sort		query		string	false	"Sort field"		Enums(name, created_at)
//	@Param			order		query		string	false	"Sort direction"	Enums(asc, desc)
//	@Success		200			{object}	dto.BranchListEnvelope
//	@Failure		401			{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403			{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		422			{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429			{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"branches.read"
//	@Router			/company/branches [get]
func (m *Module) listBranches(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, branchSortFields, httpx.Sort{Field: "name", Order: "asc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	rows, total, err := m.svc.ListBranches(r.Context(), page, sort, r.URL.Query().Get("search"))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// createBranch godoc
//
//	@Summary		Create a branch
//	@Tags			company
//	@Accept			json
//	@Produce		json
//	@Param			Idempotency-Key	header		string				false	"Repeat safe key"
//	@Param			body			body		dto.BranchCreate	true	"Branch payload"
//	@Success		201				{object}	dto.BranchEnvelope
//	@Failure		400				{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401				{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403				{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		409				{object}	dto.ErrorResponse	"UNIQUE_VIOLATION / IDEMPOTENCY_CONFLICT"
//	@Failure		422				{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429				{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"branches.create"
//	@Router			/company/branches [post]
func (m *Module) createBranch(w http.ResponseWriter, r *http.Request) {
	var in dto.BranchCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateBranch(r.Context(), in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// updateBranch godoc
//
//	@Summary		Update a branch
//	@Description	A branch of another tenant answers 404, never 403.
//	@Tags			company
//	@Accept			json
//	@Produce		json
//	@Param			id		path		string				true	"Branch id"
//	@Param			body	body		dto.BranchUpdate	true	"Branch patch"
//	@Success		200		{object}	dto.BranchEnvelope
//	@Failure		400		{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404		{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		409		{object}	dto.ErrorResponse	"UNIQUE_VIOLATION"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429		{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"branches.update"
//	@Router			/company/branches/{id} [patch]
func (m *Module) updateBranch(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.BranchUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateBranch(r.Context(), id, in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// deleteBranch godoc
//
//	@Summary		Delete a branch
//	@Description	Soft delete. A branch that still has assigned users answers 409 RESOURCE_IN_USE.
//	@Tags			company
//	@Produce		json
//	@Param			id	path	string	true	"Branch id"
//	@Success		204	"No Content"
//	@Failure		401	{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403	{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404	{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		409	{object}	dto.ErrorResponse	"RESOURCE_IN_USE"
//	@Failure		422	{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429	{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"branches.delete"
//	@Router			/company/branches/{id} [delete]
func (m *Module) deleteBranch(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.DeleteBranch(r.Context(), id, metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}
