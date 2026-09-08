package companies

import (
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/db"
	authdomain "github.com/devline/onebook-eld/internal/domain/auth"
	"github.com/devline/onebook-eld/internal/domain/companies/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Deps are the dependencies the platform company module is wired with. Only
// Pool is mandatory; the rest fall back to safe defaults.
type Deps struct {
	Pool     *db.Pool
	Audit    audit.Recorder
	Cache    cache.Store
	Verifier mw.AuthVerifier
	Logger   *slog.Logger
	// Notifier delivers the Administrator invitation link out of band. The
	// bootstrap implementation only records that a link was issued.
	Notifier authdomain.Notifier
	// Subscriptions drops the cached subscription state right after this
	// module writes it, so RequireWritableSubscription (internal/middleware)
	// never enforces a stale answer for up to DefaultSubscriptionTTL.
	Subscriptions SubscriptionInvalidator
}

// Module exposes the Super Admin company routes. It implements server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the platform company module from its infrastructure dependencies.
func New(deps Deps) *Module {
	log := deps.Logger
	if log == nil {
		log = slog.Default()
	}
	svc := NewService(ServiceDeps{
		Repo:          NewRepo(deps.Pool, deps.Audit),
		Notifier:      deps.Notifier,
		Logger:        log,
		Subscriptions: deps.Subscriptions,
	})
	return &Module{svc: svc, verifier: deps.Verifier, store: deps.Cache}
}

// NewWithService builds the module on top of an existing service (tests).
func NewWithService(svc *Service, verifier mw.AuthVerifier, store cache.Store) *Module {
	return &Module{svc: svc, verifier: verifier, store: store}
}

// companySortFields is the sort whitelist of GET /companies.
var companySortFields = []string{"name", "created_at", "subscription_end_at"}

// RegisterRoutes implements server.Module. Every route is platform level:
// a tenant principal never reaches them.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Route("/companies", func(c chi.Router) {
		c.Use(mw.Authenticate(m.verifier), mw.RequireFullSession, mw.RequireSuperAdmin)
		if m.store != nil {
			c.Use(mw.UserRateLimit(m.store, 600))
		}

		c.Get("/", m.list)
		c.With(m.idempotent()).Post("/", m.create)
		c.Patch("/{id}", m.update)
		c.Patch("/{id}/subscription", m.updateSubscription)
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

// list godoc
//
//	@Summary		List companies
//	@Description	TZ A§15 — the platform tenant list. Super Admin only: a company scoped principal receives 403.
//	@Tags			companies
//	@Produce		json
//	@Param			page		query		int		false	"Page number"		default(1)
//	@Param			per_page	query		int		false	"Page size"			default(25)
//	@Param			search		query		string	false	"Name contains"
//	@Param			status		query		string	false	"Subscription status"	Enums(trial, active, grace, readonly)
//	@Param			region		query		string	false	"Region profile"		Enums(PK, UZ, US, other)
//	@Param			sort		query		string	false	"Sort field"			Enums(name, created_at, subscription_end_at)
//	@Param			order		query		string	false	"Sort direction"		Enums(asc, desc)
//	@Success		200			{object}	dto.AdminCompanyListEnvelope
//	@Failure		401			{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403			{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		422			{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429			{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"super_admin"
//	@Router			/companies [get]
func (m *Module) list(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, companySortFields, httpx.Sort{Field: "name", Order: "asc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	q := r.URL.Query()
	rows, total, err := m.svc.List(r.Context(), page, sort,
		q.Get("search"), q.Get("status"), q.Get("region"))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// create godoc
//
//	@Summary		Create a company
//	@Description	TZ A§15 — provisions the tenant in one transaction: the company row, the FMCSA 70/8 default `hos_policy_versions` entry, a copy of the system roles with their permissions, the A§19 notification defaults, the Administrator account in `invited` state and its 72 h invitation. The invitation token is delivered out of band and never returned.
//	@Tags			companies
//	@Accept			json
//	@Produce		json
//	@Param			Idempotency-Key	header		string				false	"Repeat safe key"
//	@Param			body			body		dto.CompanyCreate	true	"Company payload"
//	@Success		201				{object}	dto.CompanyCreatedEnvelope
//	@Failure		400				{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401				{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403				{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		409				{object}	dto.ErrorResponse	"UNIQUE_VIOLATION / IDEMPOTENCY_CONFLICT"
//	@Failure		422				{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429				{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"super_admin"
//	@Router			/companies [post]
func (m *Module) create(w http.ResponseWriter, r *http.Request) {
	var in dto.CompanyCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Create(r.Context(), in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// update godoc
//
//	@Summary		Update a company
//	@Description	Partial update from the platform console. An unknown or soft deleted company answers 404.
//	@Tags			companies
//	@Accept			json
//	@Produce		json
//	@Param			id		path		string				true	"Company id"
//	@Param			body	body		dto.CompanyUpdate	true	"Company patch"
//	@Success		200		{object}	dto.AdminCompanyEnvelope
//	@Failure		400		{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404		{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		409		{object}	dto.ErrorResponse	"UNIQUE_VIOLATION"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429		{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"super_admin"
//	@Router			/companies/{id} [patch]
func (m *Module) update(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.CompanyUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Update(r.Context(), id, in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// updateSubscription godoc
//
//	@Summary		Update a company subscription
//	@Description	TZ A§15 — MVP billing is manual: the platform administrator extends `subscription_end_at` once the invoice is settled. `grace` covers the 7 days after the period ends, `readonly` freezes the admin panel while the driver app keeps recording HOS.
//	@Tags			companies
//	@Accept			json
//	@Produce		json
//	@Param			id		path		string					true	"Company id"
//	@Param			body	body		dto.SubscriptionUpdate	true	"Subscription patch"
//	@Success		200		{object}	dto.AdminCompanyEnvelope
//	@Failure		400		{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404		{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429		{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"super_admin"
//	@Router			/companies/{id}/subscription [patch]
func (m *Module) updateSubscription(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.SubscriptionUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateSubscription(r.Context(), id, in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}
