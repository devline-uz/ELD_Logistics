package auth

import (
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/auth/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Module wires the auth routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc            *Service
	verifier       mw.AuthVerifier
	store          cache.Store
	loginPerMinute int
}

// NewModule builds the HTTP module. verifier is the same AuthVerifier the rest
// of the API uses; store backs the login rate limits. loginPerMinute is
// cfg.RateLimit.Login (TZ B§3.2); pass 0 to use the package default.
func NewModule(svc *Service, verifier mw.AuthVerifier, store cache.Store, loginPerMinute int) *Module {
	return &Module{svc: svc, verifier: verifier, store: store, loginPerMinute: loginPerMinute}
}

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Route("/auth", func(a chi.Router) {
		// Unauthenticated credential endpoints. Each carries its own budget so
		// a flood on one cannot exhaust the others (TZ B§3.2).
		a.With(mw.LoginRateLimit(m.store, m.loginPerMinute)).Post("/login", m.login)
		a.With(m.limit("refresh", 30)).Post("/refresh", m.refresh)
		a.With(m.limit("invite", 10)).Post("/invitation/accept", m.acceptInvitation)
		a.With(m.limit("forgot", 5)).Post("/password/forgot", m.forgotPassword)
		a.With(m.limit("reset", 10)).Post("/password/reset", m.resetPassword)

		a.Group(func(priv chi.Router) {
			priv.Use(mw.Authenticate(m.verifier))
			// A limited (2FA enrolment) token may only reach these two.
			priv.Post("/logout", m.logout)
			priv.Post("/2fa/setup", m.setupTOTP)
			priv.Post("/2fa/verify", m.verifyTOTP)

			priv.Group(func(full chi.Router) {
				full.Use(mw.RequireFullSession)
				full.Post("/pin/verify", m.verifyPIN)
				full.Get("/sessions", m.listSessions)
				full.Delete("/sessions/{id}", m.revokeSession)
			})
		})
	})

	// Public and hit on every client start: budget it per address so it
	// cannot be used to hammer system_settings.
	r.With(m.limit("app_config", AppConfigPerIPPerMinute)).Get("/app/config", m.appConfig)
	r.With(mw.Authenticate(m.verifier), mw.RequireFullSession).Get("/me", m.me)
}

// AppConfigPerIPPerMinute budgets the public bootstrap endpoint.
const AppConfigPerIPPerMinute = 60

func (m *Module) limit(name string, perMinute int) func(http.Handler) http.Handler {
	return mw.RateLimit(m.store, mw.RateLimitOptions{
		Name: name, Limit: perMinute, Window: time.Minute, Key: mw.KeyByIP,
	})
}

func metaOf(r *http.Request) RequestMeta {
	return RequestMeta{
		IP:        httpx.ClientIP(r),
		UserAgent: r.UserAgent(),
	}
}

func principalOf(r *http.Request) (*tenant.Principal, error) {
	p, ok := tenant.PrincipalFrom(r.Context())
	if !ok {
		return nil, apierr.Unauthorized("authentication required")
	}
	return p, nil
}

// login godoc
//
//	@Summary      Sign in
//	@Description  Q20 — one session per device_type: signing in on the same device type revokes the previous session and answers `replaced_session: true`. Super Admin and Administrator accounts without 2FA receive a limited token and `requires_totp_setup: true`.
//	@Tags         auth
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.LoginRequest  true  "Credentials"
//	@Success      200   {object}  dto.LoginEnvelope
//	@Failure      400   {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401   {object}  dto.ErrorResponse  "INVALID_CREDENTIALS / TOTP_REQUIRED / TOTP_INVALID"
//	@Failure      403   {object}  dto.ErrorResponse  "ACCOUNT_INACTIVE / SUBSCRIPTION_EXPIRED"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED / LOCKED_OUT"
//	@x-permission "public"
//	@Router       /auth/login [post]
func (m *Module) login(w http.ResponseWriter, r *http.Request) {
	var in dto.LoginRequest
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Login(r.Context(), in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// refresh godoc
//
//	@Summary      Rotate the refresh token
//	@Description  Q3.1 — every refresh returns a new opaque token and invalidates the old one. Replaying a rotated token revokes the whole session and is audited as `token_reuse`.
//	@Tags         auth
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.RefreshRequest  true  "Refresh token"
//	@Success      200   {object}  dto.TokensEnvelope
//	@Failure      401   {object}  dto.ErrorResponse  "TOKEN_INVALID / TOKEN_REUSED / TOKEN_REVOKED / SESSION_EXPIRED / PIN_REQUIRED"
//	@Failure      403   {object}  dto.ErrorResponse  "ACCOUNT_INACTIVE"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429   {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@x-permission "public"
//	@Router       /auth/refresh [post]
func (m *Module) refresh(w http.ResponseWriter, r *http.Request) {
	var in dto.RefreshRequest
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Refresh(r.Context(), in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// logout godoc
//
//	@Summary      Sign out or pause the session
//	@Description  Q3.1 — `pause: true` is Leave Truck: the session becomes `paused` and is resumed with POST /auth/pin/verify.
//	@Tags         auth
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.LogoutRequest  false  "Logout options"
//	@Success      204   "No Content"
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      404   {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "authenticated"
//	@Router       /auth/logout [post]
func (m *Module) logout(w http.ResponseWriter, r *http.Request) {
	p, err := principalOf(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.LogoutRequest
	if r.ContentLength > 0 {
		if err := httpx.DecodeAndValidate(r, &in); err != nil {
			httpx.WriteError(w, r, err)
			return
		}
	}
	if err := m.svc.Logout(r.Context(), p.SessionID, p.UserID, in, metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// setupTOTP godoc
//
//	@Summary      Start two factor enrolment
//	@Description  Q3.4 — mandatory for Super Admin and Administrator. The shared secret is stored AES-256-GCM encrypted and is only enabled once POST /auth/2fa/verify succeeds.
//	@Tags         auth
//	@Produce      json
//	@Success      200  {object}  dto.TOTPSetupEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      409  {object}  dto.ErrorResponse  "TOTP_ALREADY_ENABLED"
//	@Security     BearerAuth
//	@x-permission "authenticated"
//	@Router       /auth/2fa/setup [post]
func (m *Module) setupTOTP(w http.ResponseWriter, r *http.Request) {
	p, err := principalOf(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.SetupTOTP(r.Context(), p, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// verifyTOTP godoc
//
//	@Summary      Confirm a two factor code
//	@Description  Q3.4 — confirming an enrolment returns the ten single use recovery codes exactly once and upgrades a limited token into a full session.
//	@Tags         auth
//	@Accept       json
//	@Produce      json
//	@Param        body  body      dto.TOTPVerifyRequest  true  "TOTP or recovery code"
//	@Success      200   {object}  dto.TOTPVerifiedEnvelope
//	@Failure      401   {object}  dto.ErrorResponse  "UNAUTHORIZED / TOTP_INVALID"
//	@Failure      403   {object}  dto.ErrorResponse  "TOTP_SETUP_REQUIRED"
//	@Failure      422   {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "authenticated"
//	@Router       /auth/2fa/verify [post]
func (m *Module) verifyTOTP(w http.ResponseWriter, r *http.Request) {
	p, err := principalOf(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.TOTPVerifyRequest
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.VerifyTOTP(r.Context(), p, in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// listSessions godoc
//
//	@Summary      List my sessions
//	@Description  Q20 — the caller's own non revoked sessions, one per device type. Addresses are truncated.
//	@Tags         auth
//	@Produce      json
//	@Success      200  {object}  dto.SessionListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Security     BearerAuth
//	@x-permission "authenticated"
//	@Router       /auth/sessions [get]
func (m *Module) listSessions(w http.ResponseWriter, r *http.Request) {
	p, err := principalOf(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sessions, err := m.svc.ListSessions(r.Context(), p.UserID, p.SessionID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, sessions, dto.Meta{Page: 1, PerPage: len(sessions), Total: int64(len(sessions))})
}

// revokeSession godoc
//
//	@Summary      Revoke one of my sessions
//	@Description  Q20 — a session belonging to another user answers 404, never 403, so session ids cannot be probed.
//	@Tags         auth
//	@Produce      json
//	@Param        id   path      string  true  "Session id"  format(uuid)
//	@Success      204  "No Content"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "authenticated"
//	@Router       /auth/sessions/{id} [delete]
func (m *Module) revokeSession(w http.ResponseWriter, r *http.Request) {
	p, err := principalOf(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	if err := m.svc.RevokeSession(r.Context(), p.UserID, id, metaOf(r)); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteNoContent(w)
}

// me godoc
//
//	@Summary      Current user
//	@Description  Q82 — the signed in profile with its effective permission keys and scope. Never returns a password hash, a TOTP secret or a token.
//	@Tags         app
//	@Produce      json
//	@Success      200  {object}  dto.ProfileEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Security     BearerAuth
//	@x-permission "authenticated"
//	@Router       /me [get]
func (m *Module) me(w http.ResponseWriter, r *http.Request) {
	p, err := principalOf(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	profile, err := m.svc.Me(r.Context(), p.UserID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, profile)
}

// appConfig godoc
//
//	@Summary      Client bootstrap configuration
//	@Description  Versioning gate for the mobile client: `min_supported_version`, `latest_version`, `force_update` and the deployment feature flags. Public, but rate limited to 60 requests per minute per address and served from a 45 second cache.
//	@Tags         app
//	@Produce      json
//	@Success      200  {object}  dto.AppConfigEnvelope
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@x-permission "public"
//	@Router       /app/config [get]
func (m *Module) appConfig(w http.ResponseWriter, r *http.Request) {
	out, err := m.svc.AppConfig(r.Context())
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}
