package middleware

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/tenant"
)

func okHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"data":"ok"}`))
	})
}

func errorCode(t *testing.T, body []byte) string {
	t.Helper()
	var resp struct {
		Error struct {
			Code string `json:"code"`
		} `json:"error"`
	}
	require.NoError(t, json.Unmarshal(body, &resp))
	return resp.Error.Code
}

func requestWith(p *tenant.Principal) *http.Request {
	r := httptest.NewRequest(http.MethodGet, "/api/v1/units", nil)
	if p != nil {
		r = r.WithContext(tenant.WithPrincipal(r.Context(), p))
	}
	return r
}

func fleetPrincipal(perms ...string) *tenant.Principal {
	companyID := uuid.New()
	return &tenant.Principal{
		UserID: uuid.New(), CompanyID: &companyID, RoleID: uuid.New(),
		Scope: tenant.ScopeAll, SessionID: uuid.New(),
		DeviceType: tenant.DeviceWeb, Permissions: perms,
	}
}

func TestAuthenticateRejectsMissingAndMalformedBearer(t *testing.T) {
	verifier := VerifierFunc(func(context.Context, string) (*tenant.Principal, error) {
		return fleetPrincipal(), nil
	})
	h := Authenticate(verifier)(okHandler())

	for name, header := range map[string]string{
		"missing":     "",
		"wrong type":  "Basic dXNlcjpwYXNz",
		"empty token": "Bearer ",
		"no prefix":   "eyJhbGciOiJIUzI1NiJ9.x.y",
	} {
		r := httptest.NewRequest(http.MethodGet, "/api/v1/units", nil)
		if header != "" {
			r.Header.Set("Authorization", header)
		}
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		require.Equal(t, http.StatusUnauthorized, w.Code, "case %s", name)
	}
}

func TestAuthenticateSurfacesVerifierErrorCode(t *testing.T) {
	verifier := VerifierFunc(func(context.Context, string) (*tenant.Principal, error) {
		return nil, apierr.New(apierr.CodeTokenExpired, http.StatusUnauthorized, "access token expired")
	})
	r := httptest.NewRequest(http.MethodGet, "/api/v1/units", nil)
	r.Header.Set("Authorization", "Bearer whatever")
	w := httptest.NewRecorder()

	Authenticate(verifier)(okHandler()).ServeHTTP(w, r)
	require.Equal(t, http.StatusUnauthorized, w.Code)
	require.Equal(t, apierr.CodeTokenExpired, errorCode(t, w.Body.Bytes()))
}

func TestRequirePermissionDeniesMissingKeyWith403(t *testing.T) {
	h := RequirePermission("units.create")(okHandler())

	w := httptest.NewRecorder()
	h.ServeHTTP(w, requestWith(fleetPrincipal("units.read")))
	require.Equal(t, http.StatusForbidden, w.Code)
	require.Equal(t, apierr.CodeForbidden, errorCode(t, w.Body.Bytes()))

	w = httptest.NewRecorder()
	h.ServeHTTP(w, requestWith(fleetPrincipal("units.read", "units.create")))
	require.Equal(t, http.StatusOK, w.Code)
}

func TestRequirePermissionRequiresAuthentication(t *testing.T) {
	w := httptest.NewRecorder()
	RequirePermission("units.read")(okHandler()).ServeHTTP(w, requestWith(nil))
	require.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestWildcardPermissionIsNotHonouredFromTheCatalogue(t *testing.T) {
	// "*" only ever comes from a super admin principal, never from a role, so a
	// tenant role that somehow stored "units.*" must not pass the gate.
	w := httptest.NewRecorder()
	RequirePermission("units.create")(okHandler()).ServeHTTP(w, requestWith(fleetPrincipal("units.*")))
	require.Equal(t, http.StatusForbidden, w.Code)
}

func TestSuperAdminHoldsEveryPermissionButRestrictedDoesNot(t *testing.T) {
	super := fleetPrincipal()
	super.CompanyID = nil
	super.IsSuperAdmin = true

	w := httptest.NewRecorder()
	RequirePermission("company.update")(okHandler()).ServeHTTP(w, requestWith(super))
	require.Equal(t, http.StatusOK, w.Code)

	super.Restricted = "totp_setup"
	w = httptest.NewRecorder()
	RequirePermission("company.update")(okHandler()).ServeHTTP(w, requestWith(super))
	require.Equal(t, http.StatusForbidden, w.Code,
		"a limited two factor enrolment token must not act as a super admin")
}

func TestRequireFullSessionRejectsLimitedTokens(t *testing.T) {
	p := fleetPrincipal("units.read")
	p.Restricted = "totp_setup"

	w := httptest.NewRecorder()
	RequireFullSession(okHandler()).ServeHTTP(w, requestWith(p))
	require.Equal(t, http.StatusForbidden, w.Code)
	require.Equal(t, apierr.CodeTOTPSetupRequired, errorCode(t, w.Body.Bytes()))

	p.Restricted = ""
	w = httptest.NewRecorder()
	RequireFullSession(okHandler()).ServeHTTP(w, requestWith(p))
	require.Equal(t, http.StatusOK, w.Code)
}

func TestRequireSuperAdminAndRequireCompany(t *testing.T) {
	tenantUser := fleetPrincipal("units.read")

	w := httptest.NewRecorder()
	RequireSuperAdmin(okHandler()).ServeHTTP(w, requestWith(tenantUser))
	require.Equal(t, http.StatusForbidden, w.Code)

	super := fleetPrincipal()
	super.CompanyID = nil
	super.IsSuperAdmin = true
	w = httptest.NewRecorder()
	RequireCompany(okHandler()).ServeHTTP(w, requestWith(super))
	require.Equal(t, http.StatusForbidden, w.Code, "a platform session has no active tenant")

	w = httptest.NewRecorder()
	RequireCompany(okHandler()).ServeHTTP(w, requestWith(tenantUser))
	require.Equal(t, http.StatusOK, w.Code)
}

func TestCompanyHeaderIsRejectedForTenantUsers(t *testing.T) {
	other := uuid.New()
	p := fleetPrincipal("units.read")

	r := requestWith(p)
	r.Header.Set(HeaderCompanyID, other.String())
	w := httptest.NewRecorder()
	SuperAdminCompanySelector(okHandler()).ServeHTTP(w, r)
	require.Equal(t, http.StatusForbidden, w.Code,
		"X-Company-Id must never move a tenant user into another company")

	// A platform principal may select a tenant.
	super := fleetPrincipal()
	super.CompanyID = nil
	super.IsSuperAdmin = true

	var seen uuid.UUID
	probe := http.HandlerFunc(func(_ http.ResponseWriter, req *http.Request) {
		seen = tenant.CompanyID(req.Context())
	})
	r = requestWith(super)
	r.Header.Set(HeaderCompanyID, other.String())
	SuperAdminCompanySelector(probe).ServeHTTP(httptest.NewRecorder(), r)
	require.Equal(t, other, seen)

	// A malformed header is a 400, not a silent fallback to no tenant.
	r = requestWith(super)
	r.Header.Set(HeaderCompanyID, "not-a-uuid")
	w = httptest.NewRecorder()
	SuperAdminCompanySelector(okHandler()).ServeHTTP(w, r)
	require.Equal(t, http.StatusBadRequest, w.Code)
}

func TestScopeFilterIsolatesBranchAndSelfRoles(t *testing.T) {
	branchID := uuid.New()
	companyID := uuid.New()

	branchUser := &tenant.Principal{
		UserID: uuid.New(), CompanyID: &companyID, Scope: tenant.ScopeBranch, BranchID: &branchID,
	}
	f := FilterFor(branchUser)
	require.True(t, f.AllowsCompany(companyID))
	require.False(t, f.AllowsCompany(uuid.New()), "another tenant must never be visible")
	require.True(t, f.AllowsBranch(&branchID))
	other := uuid.New()
	require.False(t, f.AllowsBranch(&other))
	require.False(t, f.AllowsBranch(nil))

	driver := &tenant.Principal{UserID: uuid.New(), CompanyID: &companyID, Scope: tenant.ScopeSelf}
	f = FilterFor(driver)
	require.True(t, f.AllowsUser(driver.UserID))
	require.False(t, f.AllowsUser(uuid.New()), "a driver may only see its own rows")

	admin := &tenant.Principal{UserID: uuid.New(), CompanyID: &companyID, Scope: tenant.ScopeAll}
	f = FilterFor(admin)
	require.True(t, f.AllowsUser(uuid.New()))
	require.True(t, f.AllowsBranch(nil))
	require.False(t, f.AllowsCompany(uuid.New()))
}

func TestScopeMiddlewareRequiresAuthentication(t *testing.T) {
	w := httptest.NewRecorder()
	Scope(okHandler()).ServeHTTP(w, requestWith(nil))
	require.Equal(t, http.StatusUnauthorized, w.Code)

	p := fleetPrincipal("units.read")
	var got ScopeFilter
	probe := http.HandlerFunc(func(_ http.ResponseWriter, req *http.Request) {
		var ok bool
		got, ok = ScopeFrom(req.Context())
		require.True(t, ok)
	})
	Scope(probe).ServeHTTP(httptest.NewRecorder(), requestWith(p))
	require.Equal(t, *p.CompanyID, got.CompanyID)
}
