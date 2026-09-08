package drivers

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/drivers/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// listCoDrivers godoc
//
//	@Summary		List co-drivers
//	@Description	TZ §1.1 — the pair is stored once but shown on both sides: if B is a co-driver of A, A also appears in B's list.
//	@Tags			drivers
//	@Produce		json
//	@Param			id	path		string	true	"Driver id (uuid)"
//	@Success		200	{object}	dto.CoDriverListEnvelope
//	@Failure		401	{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403	{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404	{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422	{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.read"
//	@Router			/drivers/{id}/co-drivers [get]
func (m *Module) listCoDrivers(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	data, err := m.svc.CoDrivers(r.Context(), scopeOf(r), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, data, httpx.Meta{Page: 1, PerPage: len(data), Total: int64(len(data))})
}

// addCoDriver godoc
//
//	@Summary		Link a co-driver
//	@Description	Q45 — creates one canonical `driver_pairs` row; the relation is symmetric. Re-linking a previously removed pair restores it instead of failing.
//	@Tags			drivers
//	@Accept			json
//	@Produce		json
//	@Param			id		path		string					true	"Driver id (uuid)"
//	@Param			body	body		dto.CoDriverCreate		true	"Co-driver to link"
//	@Success		201		{object}	dto.CoDriverListEnvelope
//	@Failure		400		{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404		{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		409		{object}	dto.ErrorResponse	"UNIQUE_VIOLATION"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.manage_co_drivers"
//	@Router			/drivers/{id}/co-drivers [post]
func (m *Module) addCoDriver(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.CoDriverCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	data, err := m.svc.AddCoDriver(r.Context(), scopeOf(r), id, in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteJSON(w, http.StatusCreated, httpx.ListEnvelope{
		Data: data,
		Meta: httpx.Meta{Page: 1, PerPage: len(data), Total: int64(len(data))},
	})
}

// removeCoDriver godoc
//
//	@Summary		Unlink a co-driver
//	@Description	Soft deletes the `driver_pairs` row. The link disappears from both drivers.
//	@Tags			drivers
//	@Produce		json
//	@Param			id				path	string	true	"Driver id (uuid)"
//	@Param			co_driver_id	path	string	true	"Co-driver id (uuid)"
//	@Success		204				"No Content"
//	@Failure		401				{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403				{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404				{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422				{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.manage_co_drivers"
//	@Router			/drivers/{id}/co-drivers/{co_driver_id} [delete]
func (m *Module) removeCoDriver(w http.ResponseWriter, r *http.Request) {
	m.unlink(w, r, chi.URLParam(r, "co_driver_id"))
}

// removeCoDriverQuery godoc
//
//	@Summary		Unlink a co-driver (collection form)
//	@Description	TZ D§3 lists `DELETE /drivers/{id}/co-drivers`; the partner is named by the `co_driver_id` query parameter.
//	@Tags			drivers
//	@Produce		json
//	@Param			id				path	string	true	"Driver id (uuid)"
//	@Param			co_driver_id	query	string	true	"Co-driver id (uuid)"
//	@Success		204				"No Content"
//	@Failure		401				{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403				{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		404				{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422				{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.manage_co_drivers"
//	@Router			/drivers/{id}/co-drivers [delete]
func (m *Module) removeCoDriverQuery(w http.ResponseWriter, r *http.Request) {
	m.unlink(w, r, r.URL.Query().Get("co_driver_id"))
}

func (m *Module) unlink(w http.ResponseWriter, r *http.Request, rawOther string) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	other, perr := uuid.Parse(rawOther)
	if perr != nil {
		httpx.WriteError(w, r, apierr.Validation("invalid co_driver_id",
			apierr.FieldError{Field: "co_driver_id", Message: "must be a valid uuid"}))
		return
	}
	if err := m.svc.RemoveCoDriver(r.Context(), scopeOf(r), id, other, metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// resetPassword godoc
//
//	@Summary		Resend the driver invitation
//	@Description	Q18.1 — a driver password is only ever set through an invitation, so "reset password" reissues the link (72 h, delivered by email or SMS). The previous link is burned and every live session is revoked. The token is never returned over the API.
//	@Tags			drivers
//	@Produce		json
//	@Param			id	path		string	true	"Driver id (uuid)"
//	@Success		200	{object}	dto.ResetPasswordEnvelope
//	@Failure		401	{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403	{object}	dto.ErrorResponse	"FORBIDDEN / ACCOUNT_INACTIVE"
//	@Failure		404	{object}	dto.ErrorResponse	"NOT_FOUND"
//	@Failure		422	{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.reset_password"
//	@Router			/drivers/{id}/reset-password [post]
func (m *Module) resetPassword(w http.ResponseWriter, r *http.Request) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.ResetPassword(r.Context(), scopeOf(r), id, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}
