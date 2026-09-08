package dvir

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// listDefectTypes godoc
//
//	@Summary      List defect types
//	@Description  Q27.1 — the inspection catalogue. Rows with `is_system=true` are the 61 FMCSA defaults shared by every tenant and are read only; a company adds its own entries alongside them. `is_critical` drives the Q27.2 out of service rule.
//	@Tags         dvir
//	@Produce      json
//	@Param        category     query     string  false  "Catalogue section"  Enums(truck, trailer)
//	@Param        is_active    query     bool    false  "Only active / only inactive entries"
//	@Param        is_critical  query     bool    false  "Only critical / only non critical entries"
//	@Param        page         query     int     false  "Page number"                        default(1)
//	@Param        per_page     query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.DefectTypeListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "defect_types.read"
//	@Router       /defect-types [get]
func (m *Module) listDefectTypes(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	f := DefectTypeFilter{Limit: page.Limit(), Offset: page.Offset()}
	if f.Category, err = queryEnum(r, "category", dto.CategoryTruck, dto.CategoryTrailer); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.IsActive, err = httpx.QueryBool(r, "is_active"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if f.IsCritical, err = httpx.QueryBool(r, "is_critical"); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	rows, total, err := m.svc.ListDefectTypes(r.Context(), f)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}

// createDefectType godoc
//
//	@Summary      Create a defect type
//	@Description  Q27.1 — adds a company level catalogue entry. The name is unique per category inside the company; the shared defaults are untouched.
//	@Tags         dvir
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.DefectTypeCreate  true  "Catalogue entry"
//	@Success      201   {object}  dto.DefectTypeEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      409   {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "defect_types.create"
//	@Router       /defect-types [post]
func (m *Module) createDefectType(w http.ResponseWriter, r *http.Request) {
	var in dto.DefectTypeCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateDefectType(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// updateDefectType godoc
//
//	@Summary      Update a defect type
//	@Description  Q27.1 — patches a company catalogue entry; nil fields are left untouched. The shared system defaults are read only and answer 409 `DEFECT_TYPE_SYSTEM_LOCKED`. Deactivating an entry (`is_active=false`) keeps historic reports intact but removes it from new inspections.
//	@Tags         dvir
//	@Accept       json
//	@Produce      json
//	@Param        id    path      string                true  "Defect type id"
//	@Param        body  body      dto.DefectTypeUpdate  true  "Patch payload"
//	@Success      200   {object}  dto.DefectTypeEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403   {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404   {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409   {object}  dto.ErrorResponse  "DEFECT_TYPE_SYSTEM_LOCKED / UNIQUE_VIOLATION"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "defect_types.update"
//	@Router       /defect-types/{id} [patch]
func (m *Module) updateDefectType(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.DefectTypeUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateDefectType(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}
