package drivers

import (
	"net/http"

	"github.com/go-chi/chi/v5"

	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/drivers/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Module wires the driver routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
}

// New builds the driver management module.
func New(d Deps) *Module {
	return &Module{svc: NewService(d), verifier: d.Verifier}
}

// Service exposes the business layer so sibling modules (files import/export)
// can reuse it without importing the repository.
func (m *Module) Service() *Service { return m.svc }

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Route("/drivers", func(d chi.Router) {
		d.Use(mw.Authenticate(m.verifier), mw.RequireFullSession, mw.RequireCompany, mw.Scope)

		d.With(mw.RequirePermission(core.PermDriversRead)).Get("/", m.list)
		d.With(mw.RequirePermission(core.PermDriversCreate)).Post("/", m.create)

		d.Route("/{id}", func(one chi.Router) {
			one.With(mw.RequirePermission(core.PermDriversRead)).Get("/", m.get)
			one.With(mw.RequirePermission(core.PermDriversUpdate)).Patch("/", m.update)
			one.With(mw.RequirePermission(core.PermDriversDelete)).Delete("/", m.remove)
			one.With(mw.RequirePermission(core.PermDriversLicenseView)).Get("/license", m.license)
			one.With(mw.RequirePermission(core.PermDriversActivate)).Post("/activate", m.activate)
			one.With(mw.RequirePermission(core.PermDriversDeactivate)).Post("/deactivate", m.deactivate)
			one.With(mw.RequirePermission(core.PermDriversRead)).Get("/activities", m.activities)
			one.With(mw.RequirePermission(core.PermDriversResetPassword)).Post("/reset-password", m.resetPassword)

			one.Route("/co-drivers", func(co chi.Router) {
				co.With(mw.RequirePermission(core.PermDriversRead)).Get("/", m.listCoDrivers)
				co.With(mw.RequirePermission(core.PermDriversManageCoDrivers)).Post("/", m.addCoDriver)
				co.With(mw.RequirePermission(core.PermDriversManageCoDrivers)).Delete("/", m.removeCoDriverQuery)
				co.With(mw.RequirePermission(core.PermDriversManageCoDrivers)).Delete("/{co_driver_id}", m.removeCoDriver)
			})
		})
	})
}

func metaOf(r *http.Request) RequestMeta {
	return RequestMeta{IP: httpx.ClientIP(r), UserAgent: r.UserAgent()}
}

func scopeOf(r *http.Request) mw.ScopeFilter {
	f, _ := mw.ScopeFrom(r.Context())
	return f
}

// list godoc
//
//	@Summary		List drivers
//	@Description	Q1 — paginated Driver Management list. Filters: status, branch_id, fleet_manager_id, search. `include_inactive=false` hides deactivated drivers. Branch scoped callers only ever see their own branch. `license_no` is never returned in clear text.
//	@Tags			drivers
//	@Produce		json
//	@Param			page				query		int		false	"Page number"					default(1)
//	@Param			per_page			query		int		false	"Rows per page (10/25/50, max 100)"	default(25)
//	@Param			sort				query		string	false	"Sort field"					Enums(name, username, status, created_at)
//	@Param			order				query		string	false	"Sort order"					Enums(asc, desc)
//	@Param			search				query		string	false	"Name, username, email or phone fragment"
//	@Param			status				query		string	false	"Driver status"	Enums(invited, active, inactive)
//	@Param			branch_id			query		string	false	"Branch id (uuid)"
//	@Param			fleet_manager_id	query		string	false	"Fleet manager user id (uuid)"
//	@Param			include_inactive	query		bool	false	"Include deactivated drivers"	default(false)
//	@Success		200					{object}	dto.DriverListEnvelope
//	@Failure		401					{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403					{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		422					{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.read"
//	@Router			/drivers [get]
func (m *Module) list(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, sortFields, httpx.Sort{Field: "name", Order: "asc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	branchID, err := httpx.QueryUUID(r, "branch_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	fleetManagerID, err := httpx.QueryUUID(r, "fleet_manager_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	includeInactive, err := httpx.QueryBool(r, "include_inactive")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	params := ListParams{
		Search:         r.URL.Query().Get("search"),
		Status:         r.URL.Query().Get("status"),
		BranchID:       branchID,
		FleetManagerID: fleetManagerID,
		Sort:           sort,
		Page:           page,
	}
	if includeInactive != nil {
		params.IncludeInactive = *includeInactive
	}

	data, meta, err := m.svc.List(r.Context(), scopeOf(r), params)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, data, meta)
}

// create godoc
//
//	@Summary		Create a driver
//	@Description	Q18.1 — required: first_name, last_name, username (4-32 of [a-z0-9._]), license_no and at least one of email / phone (the invitation is delivered over it). **There is no password field**: a users row is created with the Driver role and status `invited`, and an invitation link is sent. `license_no` is stored AES-256-GCM encrypted and answered masked. Co-driver is optional.
//	@Tags			drivers
//	@Accept			json
//	@Produce		json
//	@Param			body	body		dto.DriverCreate	true	"Driver payload"
//	@Success		201		{object}	dto.DriverEnvelope
//	@Failure		400		{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404		{object}	dto.ErrorResponse	"NOT_FOUND (co-driver of another tenant)"
//	@Failure		409		{object}	dto.ErrorResponse	"UNIQUE_VIOLATION / INVALID_STATE"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.create"
//	@Router			/drivers [post]
func (m *Module) create(w http.ResponseWriter, r *http.Request) {
	var in dto.DriverCreate
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

// get godoc
//
//	@Summary		Get a driver
//	@Description	Cross-tenant reads answer 404, never 403 (TZ B§3.5).
//	@Tags			drivers
//	@Produce		json
//	@Param			id	path		string	true	"Driver id (uuid)"
//	@Success		200	{object}	dto.DriverEnvelope
//	@Failure		401	{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403	{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404	{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422	{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.read"
//	@Router			/drivers/{id} [get]
func (m *Module) get(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Get(r.Context(), scopeOf(r), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// license godoc
//
//	@Summary		Reveal the driver licence number
//	@Description	TZ B§3.4 — `drivers.license_no` is stored AES-256-GCM encrypted. The list and the driver payload only ever carry `license_no_masked`; the clear value is served here and only to a caller holding `drivers.license.view`. Every call is answered from the encrypted column, never from a cache, and every reveal is written to `audit_log` as `license_reveal`.
//	@Tags			drivers
//	@Produce		json
//	@Param			id	path		string	true	"Driver id (uuid)"
//	@Success		200	{object}	dto.DriverLicenseEnvelope
//	@Failure		401	{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403	{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404	{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422	{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.license.view"
//	@Router			/drivers/{id}/license [get]
func (m *Module) license(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.License(r.Context(), scopeOf(r), id, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// update godoc
//
//	@Summary		Update a driver
//	@Description	Partial update; omitted fields stay unchanged. Changing `license_no` re-encrypts the column. `status`, `company_id` and the role can never be set here.
//	@Tags			drivers
//	@Accept			json
//	@Produce		json
//	@Param			id		path		string				true	"Driver id (uuid)"
//	@Param			body	body		dto.DriverUpdate	true	"Fields to change"
//	@Success		200		{object}	dto.DriverEnvelope
//	@Failure		400		{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404		{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		409		{object}	dto.ErrorResponse	"UNIQUE_VIOLATION"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.update"
//	@Router			/drivers/{id} [patch]
func (m *Module) update(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.DriverUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Update(r.Context(), scopeOf(r), id, in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// remove godoc
//
//	@Summary		Delete a driver
//	@Description	Soft delete (`deleted_at`): the drivers row and its user account are archived and every session is revoked. Logs stay untouched.
//	@Tags			drivers
//	@Produce		json
//	@Param			id	path	string	true	"Driver id (uuid)"
//	@Success		204	"No Content"
//	@Failure		401	{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403	{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404	{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		409	{object}	dto.ErrorResponse	"RESOURCE_IN_USE"
//	@Failure		422	{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.delete"
//	@Router			/drivers/{id} [delete]
func (m *Module) remove(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.Delete(r.Context(), scopeOf(r), id, metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// activate godoc
//
//	@Summary		Activate a driver
//	@Description	Q1 — reversible transition back to `active`. A driver that never accepted the invitation keeps user status `invited`.
//	@Tags			drivers
//	@Accept			json
//	@Produce		json
//	@Param			id		path		string				true	"Driver id (uuid)"
//	@Param			body	body		dto.StatusChange	false	"Optional reason for the audit trail"
//	@Success		200		{object}	dto.DriverEnvelope
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404		{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.activate"
//	@Router			/drivers/{id}/activate [post]
func (m *Module) activate(w http.ResponseWriter, r *http.Request) {
	m.setActive(w, r, true)
}

// deactivate godoc
//
//	@Summary		Deactivate a driver
//	@Description	Q1 — an inactive driver cannot sign in (`403 ACCOUNT_INACTIVE`) and **every one of its sessions is revoked immediately**, so already issued access tokens stop working too.
//	@Tags			drivers
//	@Accept			json
//	@Produce		json
//	@Param			id		path		string				true	"Driver id (uuid)"
//	@Param			body	body		dto.StatusChange	false	"Optional reason for the audit trail"
//	@Success		200		{object}	dto.DriverEnvelope
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404		{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.deactivate"
//	@Router			/drivers/{id}/deactivate [post]
func (m *Module) deactivate(w http.ResponseWriter, r *http.Request) {
	m.setActive(w, r, false)
}

func (m *Module) setActive(w http.ResponseWriter, r *http.Request, active bool) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.StatusChange
	if r.ContentLength > 0 {
		if err := httpx.DecodeAndValidate(r, &in); err != nil {
			httpx.WriteError(w, r, err)
			return
		}
	}
	out, err := m.svc.SetActive(r.Context(), scopeOf(r), id, active, in.Reason, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// activities godoc
//
//	@Summary		Driver activity feed
//	@Description	Every audited change of the driver and of its user account, its logins and its session state transitions, newest first. Sourced from `audit_log` and `sessions`.
//	@Tags			drivers
//	@Produce		json
//	@Param			id			path		string	true	"Driver id (uuid)"
//	@Param			page		query		int		false	"Page number"						default(1)
//	@Param			per_page	query		int		false	"Rows per page (10/25/50, max 100)"	default(25)
//	@Success		200			{object}	dto.ActivityListEnvelope
//	@Failure		401			{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403			{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404			{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422			{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.read"
//	@Router			/drivers/{id}/activities [get]
func (m *Module) activities(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	data, meta, err := m.svc.Activities(r.Context(), scopeOf(r), id, page)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, data, meta)
}
