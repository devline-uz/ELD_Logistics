//go:build integration

// Regression coverage for the fleet route guards: the module must fail closed
// when it is wired without a verifier, and a company-less (platform) principal
// must never fall through the tenant endpoints with company_id = uuid.Nil.
package fleet_test

import (
	"net/http"
	"testing"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/domain/fleet"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// A module built without an AuthVerifier used to skip mw.Authenticate
// entirely, which served every unit, device, trailer and shipping document
// route unauthenticated. It must answer 503, never 200.
func TestFleetWithoutVerifierFailsClosed(t *testing.T) {
	t.Parallel()
	pool := testutil.NewDB(t)
	repo := fleet.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger()))
	srv := testutil.NewServer(t, fleet.New(fleet.Deps{Repo: repo}))

	tn := testutil.SeedTenant(t, allFleetPerms...)
	for _, path := range []string{
		"/api/v1/units", "/api/v1/eld-devices",
		"/api/v1/trailers", "/api/v1/shipping-documents",
	} {
		resp := srv.AsTenant(tn).Get(path)
		if resp.Code == http.StatusOK {
			t.Fatalf("%s served data without a configured verifier", path)
		}
		testutil.RequireStatus(t, resp, http.StatusServiceUnavailable)
	}
}

// A platform principal carries no company: without RequireCompany it reached
// the repositories with company_id = uuid.Nil instead of being turned away.
func TestFleetRejectsCompanyLessPrincipal(t *testing.T) {
	t.Parallel()
	srv := newServer(t)

	platform := &tenant.Principal{
		UserID:       uuid.New(),
		RoleID:       uuid.New(),
		SessionID:    uuid.New(),
		Scope:        tenant.ScopeAll,
		DeviceType:   tenant.DeviceWeb,
		IsSuperAdmin: true,
	}

	for _, path := range []string{
		"/api/v1/units", "/api/v1/eld-devices",
		"/api/v1/trailers", "/api/v1/shipping-documents",
	} {
		testutil.RequireStatus(t, srv.AsPrincipal(platform).Get(path), http.StatusForbidden)
	}

	testutil.RequireStatus(t,
		srv.AsPrincipal(platform).Post("/api/v1/units", validUnit("PLATFORM-1")),
		http.StatusForbidden)
}

// Anonymous traffic must be rejected before any permission check runs.
func TestFleetRejectsAnonymous(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	testutil.RequireStatus(t, srv.Anonymous().Get("/api/v1/units"), http.StatusUnauthorized)
	testutil.RequireStatus(t,
		srv.Anonymous().Post("/api/v1/units", validUnit("ANON-1")), http.StatusUnauthorized)
}
