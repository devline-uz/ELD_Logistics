package users

import (
	"net/http"
	"strings"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/users/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Module wires the users, roles and permissions routes into the /api/v1
// router. It implements server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// NewModule builds the HTTP module. verifier is the same AuthVerifier the rest
// of the API uses; store backs the per user rate limit and the idempotency
// cache.
func NewModule(svc *Service, verifier mw.AuthVerifier, store cache.Store) *Module {
	return &Module{svc: svc, verifier: verifier, store: store}
}

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(priv chi.Router) {
		priv.Use(mw.Authenticate(m.verifier))
		priv.Use(mw.RequireFullSession)
		priv.Use(mw.RequireCompany)
		priv.Use(mw.Scope)
		priv.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))

		priv.Route("/users", func(u chi.Router) {
			u.With(mw.RequirePermission(core.PermUsersRead)).Get("/", m.listUsers)
			u.With(mw.RequirePermission(core.PermUsersCreate), mw.Idempotency(m.store, false)).
				Post("/", m.createUser)
			u.With(mw.RequirePermission(core.PermUsersUpdate)).Patch("/{id}", m.updateUser)
			u.With(mw.RequirePermission(core.PermUsersDelete)).Delete("/{id}", m.deleteUser)
			u.With(mw.RequirePermission(core.PermUsersUpdate)).Post("/{id}/activate", m.activateUser)
			u.With(mw.RequirePermission(core.PermUsersUpdate)).Post("/{id}/deactivate", m.deactivateUser)
			u.With(mw.RequirePermission(core.PermUsersInvite)).Post("/{id}/resend-invitation", m.resendInvitation)
			u.With(mw.RequirePermission(core.PermUsersResetPassword)).Post("/{id}/reset-password", m.resetPassword)
		})

		priv.Route("/roles", func(ro chi.Router) {
			ro.With(mw.RequirePermission(core.PermRolesRead)).Get("/", m.listRoles)
			ro.With(mw.RequirePermission(core.PermRolesCreate), mw.Idempotency(m.store, false)).
				Post("/", m.createRole)
			ro.With(mw.RequirePermission(core.PermRolesUpdate)).Patch("/{id}", m.updateRole)
			ro.With(mw.RequirePermission(core.PermRolesDelete)).Delete("/{id}", m.deleteRole)
		})

		// Static catalogue, but it still describes the whole RBAC surface:
		// either the dedicated key or roles.read (the role editor needs it).
		priv.With(mw.RequireAnyPermission(core.PermPermissionsRead, core.PermRolesRead)).
			Get("/permissions", m.listPermissions)
	})
}

func metaOf(r *http.Request) RequestMeta {
	return RequestMeta{IP: httpx.ClientIP(r), UserAgent: r.UserAgent()}
}

func scopeOf(r *http.Request) mw.ScopeFilter {
	f, _ := mw.ScopeFrom(r.Context())
	return f
}

func pathID(r *http.Request) (uuid.UUID, error) {
	return httpx.URLParamUUID(r, "id")
}

// listUsers godoc
//
//	@Summary      List users
//	@Description  Q1/Q82.1 — a branch scoped caller only ever sees its own branch, whatever `branch_id` says. Never returns a password hash, a TOTP secret or a PIN.
//	@Tags         users
//	@Produce      json
//	@Param        page      query     int     false  "Page number"                   default(1)
//	@Param        per_page  query     int     false  "Page size (max 100)"           default(25)
//	@Param        sort      query     string  false  "Sort field"                    Enums(last_name, first_name, username, email, status, created_at)
//	@Param        order     query     string  false  "Sort direction"                Enums(asc, desc)
//	@Param        status    query     string  false  "Activity filter"               Enums(invited, active, inactive)
//	@Param        role_id   query     string  false  "Role filter"                   format(uuid)
//	@Param        branch_id query     string  false  "Branch filter"                 format(uuid)
//	@Param        search    query     string  false  "Name, username, email or phone"
//	@Success      200  {object}  dto.UserListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "users.read"
//	@Router       /users [get]
func (m *Module) listUsers(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, userSortFields, httpx.Sort{Field: "last_name", Order: "asc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	status, err := enumQuery(r, "status", StatusInvited, StatusActive, StatusInactive)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	roleID, err := httpx.QueryUUID(r, "role_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	branchID, err := httpx.QueryUUID(r, "branch_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	items, total, err := m.svc.ListUsers(r.Context(), UserFilter{
		Search:   pgconv.NilIfEmpty(strings.TrimSpace(r.URL.Query().Get("search"))),
		Status:   status,
		RoleID:   roleID,
		BranchID: branchID,
		Sort:     sort.Field,
		SortDesc: sort.Order == "desc",
		Limit:    page.Limit(),
		Offset:   page.Offset(),
	}, scopeOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, items, page.Meta(total))
}

// createUser godoc
//
//	@Summary      Invite a user
//	@Description  Q81/A§16 — there is no password field: the account is created with status `invited` and a 72 hour invitation link is delivered by email or SMS. Either `email` or `phone` is required.
//	@Tags         users
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string          false  "Optional idempotency key"
//	@Param        body             body    dto.UserCreate  true   "User payload"
//	@Success      201  {object}  dto.UserEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND — unknown role or branch"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION — username or email already used"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "users.create"
//	@Router       /users [post]
func (m *Module) createUser(w http.ResponseWriter, r *http.Request) {
	var in dto.UserCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateUser(r.Context(), in, scopeOf(r), metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// updateUser godoc
//
//	@Summary      Update a user
//	@Description  Q82.1 — changing the role revokes every session of the account so the new permission set applies immediately. Activity state is changed with the activate / deactivate endpoints, not here.
//	@Tags         users
//	@Accept       json
//	@Produce      json
//	@Param        id    path  string          true  "User id"  format(uuid)
//	@Param        body  body  dto.UserUpdate  true  "Partial user payload"
//	@Success      200  {object}  dto.UserEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND — unknown or cross-tenant record"
//	@Failure      409  {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "users.update"
//	@Router       /users/{id} [patch]
func (m *Module) updateUser(w http.ResponseWriter, r *http.Request) {
	id, err := pathID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.UserUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateUser(r.Context(), id, in, scopeOf(r), metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// deleteUser godoc
//
//	@Summary      Delete a user
//	@Description  Q1 — soft delete: `deleted_at` is stamped, related logs and DVIR records are kept. You cannot delete your own account, nor the last active Administrator of the company.
//	@Tags         users
//	@Produce      json
//	@Param        id   path  string  true  "User id"  format(uuid)
//	@Success      204  "No Content"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND — unknown or cross-tenant record"
//	@Failure      409  {object}  dto.ErrorResponse  "SELF_TARGET_FORBIDDEN / LAST_ADMINISTRATOR"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "users.delete"
//	@Router       /users/{id} [delete]
func (m *Module) deleteUser(w http.ResponseWriter, r *http.Request) {
	id, err := pathID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.DeleteUser(r.Context(), id, scopeOf(r), metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// activateUser godoc
//
//	@Summary      Activate a user
//	@Description  Q1 — active ⇄ inactive is reversible. An account that has not accepted its invitation cannot be activated: resend the invitation instead.
//	@Tags         users
//	@Produce      json
//	@Param        id   path  string  true  "User id"  format(uuid)
//	@Success      200  {object}  dto.UserEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND — unknown or cross-tenant record"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "users.update"
//	@Router       /users/{id}/activate [post]
func (m *Module) activateUser(w http.ResponseWriter, r *http.Request) {
	m.setActive(w, r, true)
}

// deactivateUser godoc
//
//	@Summary      Deactivate a user
//	@Description  Q3.1 — an inactive user cannot sign in (403 ACCOUNT_INACTIVE) and every session of the account is revoked immediately. You cannot deactivate yourself or the last active Administrator.
//	@Tags         users
//	@Produce      json
//	@Param        id   path  string  true  "User id"  format(uuid)
//	@Success      200  {object}  dto.UserEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND — unknown or cross-tenant record"
//	@Failure      409  {object}  dto.ErrorResponse  "SELF_TARGET_FORBIDDEN / LAST_ADMINISTRATOR"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "users.update"
//	@Router       /users/{id}/deactivate [post]
func (m *Module) deactivateUser(w http.ResponseWriter, r *http.Request) {
	m.setActive(w, r, false)
}

func (m *Module) setActive(w http.ResponseWriter, r *http.Request, active bool) {
	id, err := pathID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.SetActive(r.Context(), id, active, scopeOf(r), metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// resendInvitation godoc
//
//	@Summary      Resend the invitation link
//	@Description  A§16 — a fresh 72 hour link is issued and the previous one is invalidated. The token itself is delivered out of band and never appears in the response.
//	@Tags         users
//	@Produce      json
//	@Param        id   path  string  true  "User id"  format(uuid)
//	@Success      202  {object}  dto.InvitationEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND — unknown or cross-tenant record"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE — the invitation was already accepted"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "users.invite"
//	@Router       /users/{id}/resend-invitation [post]
func (m *Module) resendInvitation(w http.ResponseWriter, r *http.Request) {
	id, err := pathID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.ResendInvitation(r.Context(), id, scopeOf(r), metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusAccepted, out)
}

// resetPassword godoc
//
//	@Summary      Send a password reset link
//	@Description  A§16 — an administrator never sets a password: this endpoint only re-sends a one time link, exactly like the invitation flow. An inactive account is rejected.
//	@Tags         users
//	@Produce      json
//	@Param        id   path  string  true  "User id"  format(uuid)
//	@Success      202  {object}  dto.InvitationEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND — unknown or cross-tenant record"
//	@Failure      409  {object}  dto.ErrorResponse  "ACCOUNT_INACTIVE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "users.reset_password"
//	@Router       /users/{id}/reset-password [post]
func (m *Module) resetPassword(w http.ResponseWriter, r *http.Request) {
	id, err := pathID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.ResetPassword(r.Context(), id, scopeOf(r), metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusAccepted, out)
}

// enumQuery reads an optional query parameter restricted to a whitelist.
func enumQuery(r *http.Request, key string, allowed ...string) (*string, error) {
	raw := strings.TrimSpace(r.URL.Query().Get(key))
	if raw == "" {
		return nil, nil
	}
	for _, a := range allowed {
		if a == raw {
			return &raw, nil
		}
	}
	return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
		Field: key, Message: "must be one of: " + strings.Join(allowed, ", "),
	})
}
