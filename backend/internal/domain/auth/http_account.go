package auth

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/domain/auth/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// acceptInvitation godoc
//
//	@Summary      Accept an invitation
//	@Description  Q16 — the link is valid for 72 hours and only its SHA-256 hash is stored. Setting the password revokes every existing session of the account.
//	@Tags         auth
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.InvitationAcceptRequest  true  "Invitation token and new password"
//	@Success      204   "No Content"
//	@Failure      401   {object}  dto.ErrorResponse  "INVITATION_INVALID / INVITATION_EXPIRED / INVITATION_USED"
//	@Failure      403   {object}  dto.ErrorResponse  "ACCOUNT_INACTIVE"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR / PASSWORD_WEAK / PIN_INVALID"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@x-permission "public"
//	@Router       /auth/invitation/accept [post]
func (m *Module) acceptInvitation(w http.ResponseWriter, r *http.Request) {
	var in dto.InvitationAcceptRequest
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.AcceptInvitation(r.Context(), in, metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// forgotPassword godoc
//
//	@Summary      Request a password reset link
//	@Description  Q16 — always answers 202 so the endpoint cannot enumerate accounts. A new link invalidates the previous one.
//	@Tags         auth
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.PasswordForgotRequest  true  "Username or email"
//	@Success      202   {object}  dto.MessageEnvelope
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@x-permission "public"
//	@Router       /auth/password/forgot [post]
func (m *Module) forgotPassword(w http.ResponseWriter, r *http.Request) {
	var in dto.PasswordForgotRequest
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.ForgotPassword(r.Context(), in, metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusAccepted, dto.MessageResponse{
		Message: "if the account exists, a reset link has been sent",
	})
}

// resetPassword godoc
//
//	@Summary      Reset the password
//	@Description  Q16 — the token works once. A successful reset revokes every session of the account.
//	@Tags         auth
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.PasswordResetRequest  true  "Reset token and new password"
//	@Success      204   "No Content"
//	@Failure      401   {object}  dto.ErrorResponse  "INVITATION_INVALID / INVITATION_EXPIRED / INVITATION_USED"
//	@Failure      403   {object}  dto.ErrorResponse  "ACCOUNT_INACTIVE"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR / PASSWORD_WEAK"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@x-permission "public"
//	@Router       /auth/password/reset [post]
func (m *Module) resetPassword(w http.ResponseWriter, r *http.Request) {
	var in dto.PasswordResetRequest
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.ResetPassword(r.Context(), in, metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// verifyPIN godoc
//
//	@Summary      Verify the driver PIN
//	@Description  Q16 — Switch driver / Return to truck. `return_to_truck` resumes the paused session. Five consecutive failures lock the PIN for 15 minutes.
//	@Tags         auth
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.PINVerifyRequest  true  "PIN payload"
//	@Success      200   {object}  dto.PINVerifiedEnvelope
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED / PIN_INVALID"
//	@Failure      409   {object}  dto.ErrorResponse  "PIN_NOT_SET"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "PIN_LOCKED"
//	@Security     BearerAuth
//	@x-permission "authenticated"
//	@Router       /auth/pin/verify [post]
func (m *Module) verifyPIN(w http.ResponseWriter, r *http.Request) {
	p, err := principalOf(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.PINVerifyRequest
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.VerifyPIN(r.Context(), p, in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}
