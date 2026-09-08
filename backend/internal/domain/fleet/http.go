package fleet

import (
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/fleet/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Deps are the fleet module dependencies. Repo and Verifier are required; the
// rest degrade gracefully so tests can wire a minimal module.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	// Store backs the optional Idempotency-Key replay cache on POST routes.
	Store cache.Store
	// Now is injectable so the five minute ELD online window is testable.
	Now func() time.Time
}

// Module wires the fleet routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the fleet HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo, deps.Now),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// Sort whitelists. Anything outside them is rejected with 422.
var (
	unitSorts   = []string{"unit_number", "status", "make", "year", "created_at"}
	deviceSorts = []string{"serial", "vendor", "status", "created_at"}
)

// writeRateLimit is the per user budget of the fleet mutation endpoints.
const writeRateLimit = 120

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		// Unconditional: a module wired without a verifier must fail closed
		// (mw.Authenticate answers 503), never serve fleet data unauthenticated.
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		// RequireCompany keeps a company-less principal (platform super admin)
		// out of the tenant endpoints instead of letting it fall through with
		// company_id = uuid.Nil.
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}

		g.Route("/units", func(u chi.Router) {
			u.With(mw.RequirePermission(auth.PermUnitsRead)).Get("/", m.listUnits)
			u.With(m.writeGuards(auth.PermUnitsCreate)...).Post("/", m.createUnit)
			u.With(mw.RequirePermission(auth.PermUnitsRead)).Get("/{id}", m.getUnit)
			u.With(mw.RequirePermission(auth.PermUnitsUpdate)).Patch("/{id}", m.updateUnit)
			u.With(mw.RequirePermission(auth.PermUnitsDelete)).Delete("/{id}", m.deleteUnit)
			u.With(mw.RequirePermission(auth.PermUnitsActivate)).Post("/{id}/activate", m.activateUnit)
			u.With(mw.RequirePermission(auth.PermUnitsDeactivate)).Post("/{id}/deactivate", m.deactivateUnit)
			u.With(m.writeGuards(auth.PermUnitsAssignDriver)...).Post("/{id}/assign-driver", m.assignDriver)
			u.With(mw.RequirePermission(auth.PermUnitsDiagnostics)).Get("/{id}/diagnostics", m.unitDiagnostics)
			u.With(mw.RequirePermission(auth.PermUnitsRead)).Get("/{id}/history", m.unitHistory)
		})

		g.Route("/eld-devices", func(d chi.Router) {
			d.With(mw.RequirePermission(auth.PermELDDevicesRead)).Get("/", m.listDevices)
			d.With(m.writeGuards(auth.PermELDDevicesCreate)...).Post("/", m.createDevice)
			d.With(mw.RequirePermission(auth.PermELDDevicesRead)).Get("/{id}", m.getDevice)
			d.With(mw.RequirePermission(auth.PermELDDevicesUpdate)).Patch("/{id}", m.updateDevice)
			d.With(mw.RequirePermission(auth.PermELDDevicesDelete)).Delete("/{id}", m.deleteDevice)
			d.With(m.writeGuards(auth.PermELDDevicesAssignUnit)...).Post("/{id}/assign-unit", m.assignDeviceUnit)
		})

		g.Route("/trailers", func(t chi.Router) {
			t.With(mw.RequirePermission(auth.PermTrailersRead)).Get("/", m.listTrailers)
			t.With(m.writeGuards(auth.PermTrailersCreate)...).Post("/", m.createTrailer)
			t.With(mw.RequirePermission(auth.PermTrailersRead)).Get("/{id}", m.getTrailer)
			t.With(mw.RequirePermission(auth.PermTrailersUpdate)).Patch("/{id}", m.updateTrailer)
			t.With(mw.RequirePermission(auth.PermTrailersDelete)).Delete("/{id}", m.deleteTrailer)
		})

		g.Route("/shipping-documents", func(s chi.Router) {
			s.With(mw.RequirePermission(auth.PermShippingDocsRead)).Get("/", m.listDocs)
			s.With(m.writeGuards(auth.PermShippingDocsCreate)...).Post("/", m.createDoc)
			s.With(mw.RequirePermission(auth.PermShippingDocsRead)).Get("/{id}", m.getDoc)
			s.With(mw.RequirePermission(auth.PermShippingDocsUpdate)).Patch("/{id}", m.updateDoc)
			s.With(mw.RequirePermission(auth.PermShippingDocsDelete)).Delete("/{id}", m.deleteDoc)
		})
	})
}

// writeGuards is the middleware chain of a POST route: permission, per user
// rate limit and the optional Idempotency-Key replay cache.
func (m *Module) writeGuards(perm string) []func(http.Handler) http.Handler {
	chain := []func(http.Handler) http.Handler{mw.RequirePermission(perm)}
	if m.store != nil {
		chain = append(chain, mw.UserRateLimit(m.store, writeRateLimit), mw.Idempotency(m.store, false))
	}
	return chain
}

// listUnits godoc
//
//	@Summary      List units
//	@Description  Q1/Q2 — only active units are returned unless `include_inactive=true`. A branch scoped principal always sees its own branch only. `odometer_m` is the last telemetry reading in metres; the backend never converts units.
//	@Tags         units
//	@Produce      json
//	@Param        page             query     int     false  "Page number"                       default(1)
//	@Param        per_page         query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        sort             query     string  false  "Sort field"  Enums(unit_number, status, make, year, created_at)
//	@Param        order            query     string  false  "Sort order"  Enums(asc, desc)
//	@Param        search           query     string  false  "Matches unit_number, vin or license_plate"
//	@Param        status           query     string  false  "Activity status"  Enums(active, inactive)
//	@Param        branch_id        query     string  false  "Branch filter (uuid)"
//	@Param        out_of_service   query     bool    false  "Out of service filter"
//	@Param        include_inactive query     bool    false  "Include inactive units"
//	@Success      200  {object}  dto.UnitListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "units.read"
//	@Router       /units [get]
func (m *Module) listUnits(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, unitSorts, httpx.Sort{Field: "unit_number", Order: "asc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	branchID, err := httpx.QueryUUID(r, "branch_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	oos, err := httpx.QueryBool(r, "out_of_service")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	includeInactive, err := httpx.QueryBool(r, "include_inactive")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	status, err := queryEnum(r, "status", dto.StatusActive, dto.StatusInactive)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	f := UnitFilter{
		Search:       queryText(r, "search"),
		Status:       status,
		BranchID:     branchID,
		OutOfService: oos,
		Sort:         sort.Field,
		Order:        sort.Order,
		Limit:        page.Limit(),
		Offset:       page.Offset(),
	}
	// An explicit status filter implies the caller wants that tab, inactive
	// rows included.
	f.IncludeInactive = (includeInactive != nil && *includeInactive) || status != nil

	units, total, err := m.svc.ListUnits(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, units, page.Meta(total))
}

// createUnit godoc
//
//	@Summary      Create unit
//	@Description  Q18.1 — required: unit_number, make, model, license_plate, fuel_type. VIN is optional and validated as 17 characters when present. `(company_id, unit_number)` and `(company_id, vin)` are unique among rows that are not soft deleted.
//	@Tags         units
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string          false  "Replay protection key"
//	@Param        body             body    dto.UnitCreate  true   "Unit payload"
//	@Success      201  {object}  dto.UnitEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "units.create"
//	@Router       /units [post]
func (m *Module) createUnit(w http.ResponseWriter, r *http.Request) {
	var in dto.UnitCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateUnit(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// getUnit godoc
//
//	@Summary      Get unit
//	@Description  Cross-tenant and out of scope identifiers answer 404, never 403.
//	@Tags         units
//	@Produce      json
//	@Param        id   path      string  true  "Unit id"
//	@Success      200  {object}  dto.UnitEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "units.read"
//	@Router       /units/{id} [get]
func (m *Module) getUnit(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.GetUnit(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// updateUnit godoc
//
//	@Summary      Update unit
//	@Description  Partial update; omitted fields keep their stored value. Renaming into an existing unit_number or vin answers 409.
//	@Tags         units
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string          true  "Unit id"
//	@Param        body  body      dto.UnitUpdate  true  "Fields to change"
//	@Success      200  {object}  dto.UnitEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "units.update"
//	@Router       /units/{id} [patch]
func (m *Module) updateUnit(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.UnitUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateUnit(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// deleteUnit godoc
//
//	@Summary      Delete unit
//	@Description  Q1 — soft delete (`deleted_at`). Related logs, DVIR reports and telemetry are kept; the unit_number and VIN become reusable.
//	@Tags         units
//	@Produce      json
//	@Param        id   path  string  true  "Unit id"
//	@Success      204  "No Content"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "RESOURCE_IN_USE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "units.delete"
//	@Router       /units/{id} [delete]
func (m *Module) deleteUnit(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.DeleteUnit(r.Context(), id); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// queryText returns a trimmed optional query parameter, or nil when absent.
func queryText(r *http.Request, key string) *string {
	v := strings.TrimSpace(r.URL.Query().Get(key))
	if v == "" {
		return nil
	}
	return &v
}

// queryEnum returns a whitelisted optional query parameter.
func queryEnum(r *http.Request, key string, allowed ...string) (*string, error) {
	v := queryText(r, key)
	if v == nil {
		return nil, nil
	}
	for _, a := range allowed {
		if a == *v {
			return v, nil
		}
	}
	return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
		Field: key, Message: "must be one of: " + strings.Join(allowed, ", "),
	})
}

// pathUUID is a small helper shared by the device and catalog handlers.
func pathUUID(r *http.Request) (uuid.UUID, error) { return httpx.URLParamUUID(r, "id") }
