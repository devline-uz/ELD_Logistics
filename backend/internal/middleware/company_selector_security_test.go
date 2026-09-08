package middleware

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/tenant"
)

// captureTenant records the company id and the principal the chain resolved.
func captureTenant(got *uuid.UUID, scope *ScopeFilter) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		*got = tenant.CompanyID(r.Context())
		if scope != nil {
			*scope = FilterFor(mustPrincipal(r.Context()))
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"data":"ok"}`))
	})
}

func mustPrincipal(ctx context.Context) *tenant.Principal {
	p, _ := tenant.PrincipalFrom(ctx)
	return p
}

// verifierFor answers with p for any bearer token.
func verifierFor(p *tenant.Principal) AuthVerifier {
	return VerifierFunc(func(context.Context, string) (*tenant.Principal, error) { return p, nil })
}

func selectorRequest(header string) *http.Request {
	r := httptest.NewRequest(http.MethodGet, "/api/v1/drivers", nil)
	r.Header.Set("Authorization", "Bearer token")
	if header != "" {
		r.Header.Set(HeaderCompanyID, header)
	}
	return r
}

// X-Company-Id is wired into the authenticated chain: a platform administrator
// can reach tenant endpoints with it.
func TestAuthenticateHonoursCompanySelectorForSuperAdmin(t *testing.T) {
	target := uuid.New()
	p := &tenant.Principal{
		UserID: uuid.New(), SessionID: uuid.New(),
		IsSuperAdmin: true, Scope: tenant.ScopeAll,
	}

	var got uuid.UUID
	var scope ScopeFilter
	w := httptest.NewRecorder()
	Authenticate(verifierFor(p))(captureTenant(&got, &scope)).ServeHTTP(w, selectorRequest(target.String()))

	require.Equal(t, http.StatusOK, w.Code)
	require.Equal(t, target, got, "the selected tenant must reach the handler context")
	// The scope filter follows, otherwise every repository query would run on
	// uuid.Nil instead of the selected tenant.
	require.Equal(t, target, scope.CompanyID)
	require.True(t, scope.IsSuperAdmin)
}

// A tenant user must never move sideways into another company.
func TestCompanySelectorRejectsTenantUsers(t *testing.T) {
	own := uuid.New()
	other := uuid.New()
	p := &tenant.Principal{
		UserID: uuid.New(), SessionID: uuid.New(),
		CompanyID: &own, Scope: tenant.ScopeAll,
	}

	var got uuid.UUID
	w := httptest.NewRecorder()
	Authenticate(verifierFor(p))(captureTenant(&got, nil)).ServeHTTP(w, selectorRequest(other.String()))

	require.Equal(t, http.StatusForbidden, w.Code)
	require.Equal(t, apierr.CodeForbidden, errorCode(t, w.Body.Bytes()))
	require.Equal(t, uuid.Nil, got, "the handler must not run")
}

// A super admin that carries a company of its own is still not a platform
// principal for this purpose.
func TestCompanySelectorRejectsSuperAdminWithOwnCompany(t *testing.T) {
	own := uuid.New()
	p := &tenant.Principal{
		UserID: uuid.New(), SessionID: uuid.New(),
		CompanyID: &own, IsSuperAdmin: true, Scope: tenant.ScopeAll,
	}

	var got uuid.UUID
	w := httptest.NewRecorder()
	Authenticate(verifierFor(p))(captureTenant(&got, nil)).ServeHTTP(w, selectorRequest(uuid.NewString()))
	require.Equal(t, http.StatusForbidden, w.Code)
	require.Equal(t, uuid.Nil, got)
}

func TestCompanySelectorRejectsAMalformedHeader(t *testing.T) {
	p := &tenant.Principal{UserID: uuid.New(), SessionID: uuid.New(), IsSuperAdmin: true}

	for _, raw := range []string{"not-a-uuid", "00000000-0000-0000-0000-000000000000", "1 OR 1=1"} {
		var got uuid.UUID
		w := httptest.NewRecorder()
		Authenticate(verifierFor(p))(captureTenant(&got, nil)).ServeHTTP(w, selectorRequest(raw))
		require.Equal(t, http.StatusBadRequest, w.Code, raw)
		require.Equal(t, uuid.Nil, got, raw)
	}
}

// Without the header nothing changes: the principal's own company wins.
func TestCompanySelectorIsInertWithoutTheHeader(t *testing.T) {
	own := uuid.New()
	p := &tenant.Principal{UserID: uuid.New(), SessionID: uuid.New(), CompanyID: &own}

	var got uuid.UUID
	w := httptest.NewRecorder()
	Authenticate(verifierFor(p))(captureTenant(&got, nil)).ServeHTTP(w, selectorRequest(""))
	require.Equal(t, http.StatusOK, w.Code)
	require.Equal(t, own, got)
}

// A platform principal without the header still has no tenant, so RequireCompany
// keeps rejecting it.
func TestSuperAdminWithoutHeaderHasNoTenant(t *testing.T) {
	p := &tenant.Principal{UserID: uuid.New(), SessionID: uuid.New(), IsSuperAdmin: true}

	var got uuid.UUID
	w := httptest.NewRecorder()
	chain := Authenticate(verifierFor(p))(RequireCompany(captureTenant(&got, nil)))
	chain.ServeHTTP(w, selectorRequest(""))
	require.Equal(t, http.StatusForbidden, w.Code)
	require.Equal(t, uuid.Nil, got)
}

// The standalone middleware keeps the same rule for handlers that resolve the
// principal themselves.
func TestStandaloneSelectorStillEnforcesTheRule(t *testing.T) {
	own := uuid.New()
	p := &tenant.Principal{UserID: uuid.New(), SessionID: uuid.New(), CompanyID: &own}

	r := selectorRequest(uuid.NewString())
	r = r.WithContext(tenant.WithPrincipal(r.Context(), p))
	w := httptest.NewRecorder()
	SuperAdminCompanySelector(okHandler()).ServeHTTP(w, r)
	require.Equal(t, http.StatusForbidden, w.Code)
}
