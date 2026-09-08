package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

// AuthVerifier validates a bearer access token and resolves the principal.
// internal/auth provides the real implementation; it must return an *apierr.E
// (401 family) for every rejection.
type AuthVerifier interface {
	VerifyAccessToken(ctx context.Context, token string) (*tenant.Principal, error)
}

// VerifierFunc adapts a function to AuthVerifier.
type VerifierFunc func(ctx context.Context, token string) (*tenant.Principal, error)

// VerifyAccessToken implements AuthVerifier.
func (f VerifierFunc) VerifyAccessToken(ctx context.Context, token string) (*tenant.Principal, error) {
	return f(ctx, token)
}

// Authenticate requires a valid bearer token and puts the principal plus the
// tenant id on the request context.
func Authenticate(v AuthVerifier) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			token, ok := bearerToken(r)
			if !ok {
				httpx.WriteError(w, r, apierr.Unauthorized("missing bearer token"))
				return
			}
			if v == nil {
				httpx.WriteError(w, r, apierr.New(apierr.CodeUnavailable,
					http.StatusServiceUnavailable, "authentication is not configured"))
				return
			}

			principal, err := v.VerifyAccessToken(r.Context(), token)
			if err != nil {
				if _, isAPI := apierr.From(err); !isAPI {
					err = apierr.Wrap(err, apierr.CodeTokenInvalid, http.StatusUnauthorized, "invalid access token")
				}
				httpx.WriteError(w, r, err)
				return
			}
			if principal == nil {
				httpx.WriteError(w, r, apierr.Unauthorized("invalid access token"))
				return
			}

			principal, err = selectCompany(r, principal)
			if err != nil {
				httpx.WriteError(w, r, err)
				return
			}
			next.ServeHTTP(w, r.WithContext(tenant.WithPrincipal(r.Context(), principal)))
		})
	}
}

// OptionalAuthenticate attaches the principal when a valid token is present but
// never rejects the request.
func OptionalAuthenticate(v AuthVerifier) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			token, ok := bearerToken(r)
			if !ok || v == nil {
				next.ServeHTTP(w, r)
				return
			}
			principal, err := v.VerifyAccessToken(r.Context(), token)
			if err != nil || principal == nil {
				next.ServeHTTP(w, r)
				return
			}
			next.ServeHTTP(w, r.WithContext(tenant.WithPrincipal(r.Context(), principal)))
		})
	}
}

// RequirePermission gates a route behind a permission key. It must run after
// Authenticate. Cross-tenant and permission failures return 403; the handler
// layer maps missing resources to 404.
func RequirePermission(key string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			p, ok := tenant.PrincipalFrom(r.Context())
			if !ok {
				httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
				return
			}
			if !p.HasPermission(key) {
				httpx.WriteError(w, r, apierr.Forbidden("permission "+key+" is required"))
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

// RequireAnyPermission passes when the principal holds at least one of keys.
func RequireAnyPermission(keys ...string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			p, ok := tenant.PrincipalFrom(r.Context())
			if !ok {
				httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
				return
			}
			for _, k := range keys {
				if p.HasPermission(k) {
					next.ServeHTTP(w, r)
					return
				}
			}
			httpx.WriteError(w, r, apierr.Forbidden("insufficient permissions"))
		})
	}
}

// RequireSuperAdmin gates platform level routes.
func RequireSuperAdmin(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p, ok := tenant.PrincipalFrom(r.Context())
		if !ok {
			httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
			return
		}
		if !p.IsSuperAdmin {
			httpx.WriteError(w, r, apierr.Forbidden("super admin access is required"))
			return
		}
		next.ServeHTTP(w, r)
	})
}

// RequireCompany rejects requests without an active tenant.
func RequireCompany(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if _, ok := tenant.CompanyIDOK(r.Context()); !ok {
			httpx.WriteError(w, r, apierr.Forbidden("no active company for this session"))
			return
		}
		next.ServeHTTP(w, r)
	})
}

func bearerToken(r *http.Request) (string, bool) {
	h := r.Header.Get("Authorization")
	if h == "" {
		return "", false
	}
	const prefix = "bearer "
	if len(h) <= len(prefix) || !strings.EqualFold(h[:len(prefix)], prefix) {
		return "", false
	}
	token := strings.TrimSpace(h[len(prefix):])
	return token, token != ""
}

// RequireFullSession rejects limited capability tokens (for example the
// totp_setup token handed out to an administrator that has not enrolled in 2FA
// yet). Routes behind RequirePermission are already covered, because a
// restricted principal holds no permission at all.
func RequireFullSession(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p, ok := tenant.PrincipalFrom(r.Context())
		if !ok {
			httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
			return
		}
		if p.IsRestricted() {
			httpx.WriteError(w, r, apierr.New(apierr.CodeTOTPSetupRequired, http.StatusForbidden,
				"two factor enrolment must be completed before using this endpoint"))
			return
		}
		next.ServeHTTP(w, r)
	})
}

// HeaderCompanyID lets a super admin select the tenant it operates on.
const HeaderCompanyID = "X-Company-Id"

// SuperAdminCompanySelector honours X-Company-Id, but only for principals that
// carry no company of their own. A tenant user can never move sideways into
// another company with this header. Authenticate already applies this rule to
// every authenticated route; the standalone middleware stays available for
// handlers that resolve their principal themselves.
func SuperAdminCompanySelector(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p, ok := tenant.PrincipalFrom(r.Context())
		selected, err := selectCompany(r, p)
		if err != nil {
			httpx.WriteError(w, r, err)
			return
		}
		if !ok {
			next.ServeHTTP(w, r)
			return
		}
		next.ServeHTTP(w, r.WithContext(tenant.WithPrincipal(r.Context(), selected)))
	})
}

// selectCompany resolves the principal a request operates as. Without the
// header the caller's own company wins. With it, only a platform administrator
// (IsSuperAdmin and no company of its own) may select a tenant; anybody else
// gets 403 rather than having the header silently ignored.
func selectCompany(r *http.Request, p *tenant.Principal) (*tenant.Principal, error) {
	raw := strings.TrimSpace(r.Header.Get(HeaderCompanyID))
	if raw == "" {
		return p, nil
	}
	if p == nil || !p.IsSuperAdmin || p.CompanyID != nil {
		return nil, apierr.Forbidden("X-Company-Id is reserved for platform administrators")
	}
	companyID, err := uuid.Parse(raw)
	if err != nil || companyID == uuid.Nil {
		return nil, apierr.BadRequest("X-Company-Id must be a uuid")
	}
	// Copying the principal keeps the scope filter, RequireCompany and every
	// repository query on the selected tenant instead of on uuid.Nil.
	selected := *p
	selected.CompanyID = &companyID
	return &selected, nil
}
