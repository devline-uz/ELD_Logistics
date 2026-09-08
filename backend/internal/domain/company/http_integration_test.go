//go:build integration

package company_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/company"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

func TestMain(m *testing.M) { testutil.RunMain(m) }

// ctxVerifier trusts the principal the test harness already put on the request
// context, so the module runs behind the very middleware chain production uses.
func ctxVerifier() mw.AuthVerifier {
	return mw.VerifierFunc(func(ctx context.Context, _ string) (*tenant.Principal, error) {
		if p, ok := tenant.PrincipalFrom(ctx); ok {
			return p, nil
		}
		return nil, apierr.Unauthorized("unknown test token")
	})
}

func newServer(t *testing.T) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	mod := company.New(company.Deps{
		Pool:     pool,
		Audit:    audit.NewPgRecorder(pool, testutil.Logger()),
		Verifier: ctxVerifier(),
		Logger:   testutil.Logger(),
	})
	return testutil.NewServer(t, mod)
}

var allCompanyPerms = []string{
	auth.PermCompanyRead, auth.PermCompanyUpdate,
	auth.PermBranchesRead, auth.PermBranchesCreate, auth.PermBranchesUpdate, auth.PermBranchesDelete,
	auth.PermHosPolicyRead, auth.PermHosPolicyUpdate,
	auth.PermNotifSettingsRead, auth.PermNotifSettingsWrite,
	auth.PermCompanyHistoryView,
}

type dataEnvelope struct {
	Data map[string]any `json:"data"`
}

type listEnvelope struct {
	Data []map[string]any `json:"data"`
	Meta struct {
		Total int64 `json:"total"`
	} `json:"meta"`
}

func TestGetCompanyReturnsTheTenantProfile(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	resp := srv.AsTenant(tn).Get("/api/v1/company")
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	var env dataEnvelope
	resp.JSON(&env)
	require.Equal(t, tn.Company.ID.String(), env.Data["id"])
	settings, ok := env.Data["settings"].(map[string]any)
	require.True(t, ok, "settings must be an object: %s", resp)
	require.NotEmpty(t, settings["quick_notes"], "quick notes fall back to the defaults")
}

func TestGetCompanyRejectsAMissingPermission(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t) // no permissions at all

	resp := srv.AsTenant(tn).Get("/api/v1/company")
	testutil.RequireStatusCode(t, resp, http.StatusForbidden, apierr.CodeForbidden)
}

func TestGetCompanyRejectsAnonymousCallers(t *testing.T) {
	srv := newServer(t)
	resp := srv.Anonymous().Get("/api/v1/company")
	testutil.RequireStatus(t, resp, http.StatusUnauthorized)
}

func TestPatchCompanyUpdatesTheProfileAndWritesAudit(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)
	before := testutil.CountIn(t, "audit_log", tn.Company.ID)

	resp := srv.AsTenant(tn).Patch("/api/v1/company", map[string]any{
		"timezone":    "America/Denver",
		"unit_system": "metric",
		"settings": map[string]any{
			"quick_notes":          []string{"PTI", "Fueling"},
			"fuel_types":           []string{"diesel"},
			"distance_regions_set": "us_states",
		},
	})
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	var env dataEnvelope
	resp.JSON(&env)
	require.Equal(t, "America/Denver", env.Data["timezone"])
	require.Equal(t, "metric", env.Data["unit_system"])

	require.Greater(t, testutil.CountIn(t, "audit_log", tn.Company.ID), before,
		"every write must leave an audit trail")
}

func TestPatchCompanyRejectsAnUnknownTimezone(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	resp := srv.AsTenant(tn).Patch("/api/v1/company", map[string]any{"timezone": "Mars/Olympus"})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestPatchCompanyRejectsAnUnknownRegulationProfile(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	resp := srv.AsTenant(tn).Patch("/api/v1/company", map[string]any{"regulation_profile": "moon_rules"})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestBranchLifecycle(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)
	client := srv.AsTenant(tn)

	created := client.Post("/api/v1/company/branches", map[string]any{
		"name":     "Houston Terminal " + uuid.NewString()[:8],
		"address":  "900 Harbor Rd",
		"timezone": "America/Chicago",
	})
	testutil.RequireStatus(t, created, http.StatusCreated)
	testutil.RequireNoPII(t, created.Body)

	var env dataEnvelope
	created.JSON(&env)
	id, _ := env.Data["id"].(string)
	require.NotEmpty(t, id)

	listed := client.Get("/api/v1/company/branches", testutil.Query("per_page", "50"))
	testutil.RequireStatus(t, listed, http.StatusOK)
	var list listEnvelope
	listed.JSON(&list)
	require.GreaterOrEqual(t, list.Meta.Total, int64(2), "the seeded branch plus the new one")

	patched := client.Patch("/api/v1/company/branches/"+id, map[string]any{"address": "901 Harbor Rd"})
	testutil.RequireStatus(t, patched, http.StatusOK)
	patched.JSON(&env)
	require.Equal(t, "901 Harbor Rd", env.Data["address"])

	deleted := client.Delete("/api/v1/company/branches/" + id)
	testutil.RequireStatus(t, deleted, http.StatusNoContent)

	gone := client.Patch("/api/v1/company/branches/"+id, map[string]any{"address": "x"})
	testutil.RequireStatusCode(t, gone, http.StatusNotFound, apierr.CodeNotFound)
}

func TestBranchOfAnotherTenantIsNotFound(t *testing.T) {
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, allCompanyPerms...)

	// Company A asks for company B's branch: 404, never 403, so the existence
	// of the row is not disclosed across tenants.
	resp := srv.AsTenant(a).Patch("/api/v1/company/branches/"+b.Branch.ID.String(),
		map[string]any{"name": "Stolen"})
	testutil.RequireStatusCode(t, resp, http.StatusNotFound, apierr.CodeNotFound)

	del := srv.AsTenant(a).Delete("/api/v1/company/branches/" + b.Branch.ID.String())
	testutil.RequireStatusCode(t, del, http.StatusNotFound, apierr.CodeNotFound)
}

func TestBranchCreateValidatesTheName(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	resp := srv.AsTenant(tn).Post("/api/v1/company/branches", map[string]any{"name": ""})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestBranchCreateRequiresThePermission(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, auth.PermBranchesRead) // read only

	resp := srv.AsTenant(tn).Post("/api/v1/company/branches", map[string]any{"name": "Nope"})
	testutil.RequireStatusCode(t, resp, http.StatusForbidden, apierr.CodeForbidden)
}

func TestHosPolicyFallsBackToTheFmcsaDefaults(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	resp := srv.AsTenant(tn).Get("/api/v1/company/hos-policy")
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env dataEnvelope
	resp.JSON(&env)
	policy, ok := env.Data["policy"].(map[string]any)
	require.True(t, ok, "policy must be an object: %s", resp)
	require.EqualValues(t, 660, policy["drive_limit_min"])
	require.EqualValues(t, 4200, policy["cycle_limit_min"])
}

// Q10.1: a new version never rewrites history. Publishing a version that only
// becomes effective tomorrow leaves today's effective policy untouched.
func TestHosPolicyVersionIsNotRetroactive(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)
	client := srv.AsTenant(tn)

	// Version 1 is effective immediately.
	first := client.Post("/api/v1/company/hos-policy", map[string]any{
		"policy": map[string]any{"cycle_limit_min": 3600, "cycle_days": 7},
	})
	testutil.RequireStatus(t, first, http.StatusCreated)

	active := client.Get("/api/v1/company/hos-policy")
	testutil.RequireStatus(t, active, http.StatusOK)
	var env dataEnvelope
	active.JSON(&env)
	policy := env.Data["policy"].(map[string]any)
	require.EqualValues(t, 3600, policy["cycle_limit_min"])
	require.EqualValues(t, 7, policy["cycle_days"])
	// Keys left out of the request inherit the previous version.
	require.EqualValues(t, 660, policy["drive_limit_min"])

	// Version 2 only starts tomorrow.
	future := time.Now().UTC().Add(24 * time.Hour).Format(time.RFC3339)
	second := client.Post("/api/v1/company/hos-policy", map[string]any{
		"effective_from": future,
		"policy":         map[string]any{"cycle_limit_min": 4200, "cycle_days": 8},
	})
	testutil.RequireStatus(t, second, http.StatusCreated)

	stillActive := client.Get("/api/v1/company/hos-policy")
	testutil.RequireStatus(t, stillActive, http.StatusOK)
	stillActive.JSON(&env)
	policy = env.Data["policy"].(map[string]any)
	require.EqualValues(t, 3600, policy["cycle_limit_min"],
		"a version effective tomorrow must not change today's policy")
}

func TestHosPolicyRejectsARetroactiveEffectiveFrom(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	past := time.Now().UTC().Add(-48 * time.Hour).Format(time.RFC3339)
	resp := srv.AsTenant(tn).Post("/api/v1/company/hos-policy", map[string]any{
		"effective_from": past,
		"policy":         map[string]any{"drive_limit_min": 600},
	})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestHosPolicyRejectsAnImpossibleDocument(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)
	client := srv.AsTenant(tn)

	for name, policy := range map[string]map[string]any{
		"drive beyond shift":  {"drive_limit_min": 900, "shift_window_min": 840},
		"break beyond drive":  {"break_required_after_drive_min": 800},
		"cycle beyond window": {"cycle_limit_min": 20000, "cycle_days": 8},
		"drive qualifies":     {"break_qualifying_statuses": []string{"OFF", "DR"}},
		"out of range":        {"drive_limit_min": 5},
	} {
		t.Run(name, func(t *testing.T) {
			resp := client.Post("/api/v1/company/hos-policy", map[string]any{"policy": policy})
			testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
		})
	}
}

func TestHosPolicyUpdateRequiresThePermission(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, auth.PermHosPolicyRead)

	resp := srv.AsTenant(tn).Post("/api/v1/company/hos-policy", map[string]any{
		"policy": map[string]any{"drive_limit_min": 600},
	})
	testutil.RequireStatusCode(t, resp, http.StatusForbidden, apierr.CodeForbidden)
}

func TestNotificationSettingsExposeTheSpecificationDefaults(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)
	client := srv.AsTenant(tn)

	resp := client.Get("/api/v1/company/notification-settings")
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	var env struct {
		Data []map[string]any `json:"data"`
	}
	resp.JSON(&env)
	require.Len(t, env.Data, len(company.AlertDefaults))

	byType := map[string]map[string]any{}
	for _, row := range env.Data {
		byType[row["alert_type"].(string)] = row
	}
	require.Contains(t, byType, company.AlertDVIRCritical)
	require.ElementsMatch(t, []any{"push", "email", "sms"}, byType[company.AlertDVIRCritical]["channels"])
}

func TestNotificationSettingsUpdate(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)
	client := srv.AsTenant(tn)

	resp := client.Patch("/api/v1/company/notification-settings", map[string]any{
		"settings": []map[string]any{{
			"alert_type":      company.AlertHosViolation,
			"channels":        []string{"email"},
			"recipient_roles": []string{tn.Role.ID.String()},
			"enabled":         false,
		}},
	})
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env struct {
		Data []map[string]any `json:"data"`
	}
	resp.JSON(&env)
	for _, row := range env.Data {
		if row["alert_type"] == company.AlertHosViolation {
			require.Equal(t, []any{"email"}, row["channels"])
			require.Equal(t, false, row["enabled"])
			require.Equal(t, []any{tn.Role.ID.String()}, row["recipient_roles"])
			return
		}
	}
	t.Fatalf("hos_violation is missing from the response: %s", resp)
}

func TestNotificationSettingsRejectAnUnknownAlertType(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	resp := srv.AsTenant(tn).Patch("/api/v1/company/notification-settings", map[string]any{
		"settings": []map[string]any{{"alert_type": "meteor_strike", "channels": []string{"push"}}},
	})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestNotificationSettingsRejectAnUnknownChannel(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	resp := srv.AsTenant(tn).Patch("/api/v1/company/notification-settings", map[string]any{
		"settings": []map[string]any{{"alert_type": company.AlertChatMessage, "channels": []string{"carrier_pigeon"}}},
	})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestCompanyHistoryShowsTheConfigurationTrail(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)
	client := srv.AsTenant(tn)

	patched := client.Patch("/api/v1/company", map[string]any{"phone": "+15125550199"})
	testutil.RequireStatus(t, patched, http.StatusOK)

	resp := client.Get("/api/v1/company/history",
		testutil.Query("table", "companies"), testutil.Query("per_page", "50"))
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	var list listEnvelope
	resp.JSON(&list)
	require.GreaterOrEqual(t, list.Meta.Total, int64(1))
	require.NotEmpty(t, list.Data)
	require.Equal(t, "companies", list.Data[0]["table_name"])
	require.NotContains(t, list.Data[0], "ip", "the client address is never returned")
}

func TestCompanyHistoryRequiresThePermission(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, auth.PermCompanyRead)

	resp := srv.AsTenant(tn).Get("/api/v1/company/history")
	testutil.RequireStatusCode(t, resp, http.StatusForbidden, apierr.CodeForbidden)
}

func TestCompanyHistoryRejectsABadTimeRange(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	resp := srv.AsTenant(tn).Get("/api/v1/company/history",
		testutil.Query("from", time.Now().UTC().Format(time.RFC3339)),
		testutil.Query("to", time.Now().UTC().Add(-time.Hour).Format(time.RFC3339)))
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestListBranchesRejectsAnUnknownSortField(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allCompanyPerms...)

	resp := srv.AsTenant(tn).Get("/api/v1/company/branches", testutil.Query("sort", "address"))
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}
