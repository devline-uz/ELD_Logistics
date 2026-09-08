package users

import (
	"net/http"
	"strings"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/devline/onebook-eld/internal/domain/users/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// listRoles godoc
//
//	@Summary      List roles
//	@Description  Q81 — the system templates (`is_system: true`, shared by every company) plus the roles this company defined. System roles can be read but never edited or deleted.
//	@Tags         roles
//	@Produce      json
//	@Param        page      query     int     false  "Page number"          default(1)
//	@Param        per_page  query     int     false  "Page size (max 100)"  default(25)
//	@Param        sort      query     string  false  "Sort field"           Enums(name, scope, created_at)
//	@Param        order     query     string  false  "Sort direction"       Enums(asc, desc)
//	@Param        scope     query     string  false  "Scope filter"         Enums(company, branch, self)
//	@Param        is_system query     bool    false  "Only system or only custom roles"
//	@Param        search    query     string  false  "Role name"
//	@Success      200  {object}  dto.RoleListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "roles.read"
//	@Router       /roles [get]
func (m *Module) listRoles(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, roleSortFields, httpx.Sort{Field: "name", Order: "asc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	scope, err := enumQuery(r, "scope", "company", "branch", "self")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	isSystem, err := httpx.QueryBool(r, "is_system")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	items, total, err := m.svc.ListRoles(r.Context(), RoleFilter{
		Search:   pgconv.NilIfEmpty(strings.TrimSpace(r.URL.Query().Get("search"))),
		Scope:    scope,
		IsSystem: isSystem,
		Sort:     sort.Field,
		SortDesc: sort.Order == "desc",
		Limit:    page.Limit(),
		Offset:   page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, items, page.Meta(total))
}

// createRole godoc
//
//	@Summary      Create a role
//	@Description  Q82 — every permission key must exist in GET /permissions; unknown keys and any `delete` key of an audit critical module (logs, dvir, violations, telemetry, audit_log) are rejected with 422.
//	@Tags         roles
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string          false  "Optional idempotency key"
//	@Param        body             body    dto.RoleCreate  true   "Role payload"
//	@Success      201  {object}  dto.RoleEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION — the role name is taken"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR — unknown permission key"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "roles.create"
//	@Router       /roles [post]
func (m *Module) createRole(w http.ResponseWriter, r *http.Request) {
	var in dto.RoleCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateRole(r.Context(), in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// updateRole godoc
//
//	@Summary      Update a role
//	@Description  Q81/B§3.1 — a system role answers 403 SYSTEM_ROLE_IMMUTABLE. Any change invalidates the cached permission set and revokes the sessions of every holder, so a narrowed role takes effect immediately.
//	@Tags         roles
//	@Accept       json
//	@Produce      json
//	@Param        id    path  string          true  "Role id"  format(uuid)
//	@Param        body  body  dto.RoleUpdate  true  "Partial role payload"
//	@Success      200  {object}  dto.RoleEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "SYSTEM_ROLE_IMMUTABLE / FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND — unknown or cross-tenant record"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR — unknown permission key"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "roles.update"
//	@Router       /roles/{id} [patch]
func (m *Module) updateRole(w http.ResponseWriter, r *http.Request) {
	id, err := pathID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.RoleUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateRole(r.Context(), id, in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// deleteRole godoc
//
//	@Summary      Delete a role
//	@Description  Q81 — soft delete. A role that still has users answers 409 ROLE_IN_USE; a system role answers 403 SYSTEM_ROLE_IMMUTABLE.
//	@Tags         roles
//	@Produce      json
//	@Param        id   path  string  true  "Role id"  format(uuid)
//	@Success      204  "No Content"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "SYSTEM_ROLE_IMMUTABLE / FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND — unknown or cross-tenant record"
//	@Failure      409  {object}  dto.ErrorResponse  "ROLE_IN_USE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "roles.delete"
//	@Router       /roles/{id} [delete]
func (m *Module) deleteRole(w http.ResponseWriter, r *http.Request) {
	id, err := pathID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.DeleteRole(r.Context(), id, metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// listPermissions godoc
//
//	@Summary      Permission catalogue
//	@Description  Q82 — every RBAC key grouped by module with its description. Audit critical modules (logs, dvir, violations, telemetry, audit_log) deliberately have no `delete` key (Q82.2). Requires `permissions.read` or `roles.read`.
//	@Tags         roles
//	@Produce      json
//	@Success      200  {object}  dto.PermissionListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "permissions.read"
//	@Router       /permissions [get]
func (m *Module) listPermissions(w http.ResponseWriter, r *http.Request) {
	httpx.WriteData(w, http.StatusOK, m.svc.Permissions(r.Context()))
}
