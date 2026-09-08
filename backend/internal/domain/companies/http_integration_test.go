//go:build integration

package companies_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/domain/companies"
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
	mod := companies.New(companies.Deps{
		Pool:     pool,
		Audit:    audit.NewPgRecorder(pool, testutil.Logger()),
		Verifier: ctxVerifier(),
		Logger:   testutil.Logger(),
	})
	return testutil.NewServer(t, mod)
}

// superAdmin inserts a platform user (company_id IS NULL) and returns the
// principal for it. audit_log.edited_by is a foreign key, so the row has to
// exist for real.
func superAdmin(t *testing.T) *tenant.Principal {
	t.Helper()
	id := uuid.New()
	var roleID uuid.UUID
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT id FROM roles WHERE company_id IS NULL AND name = 'Administrator' LIMIT 1`).Scan(&roleID))

	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO users (id, company_id, first_name, last_name, username, role_id, status)
		VALUES ($1, NULL, 'Super', 'Admin', $2, $3, 'active')`,
		id, "super-"+id.String()[:8], roleID)
	require.NoError(t, err, "seed the platform user")

	return &tenant.Principal{
		UserID:       id,
		RoleID:       roleID,
		Scope:        tenant.ScopeAll,
		SessionID:    uuid.New(),
		DeviceType:   tenant.DeviceWeb,
		IsSuperAdmin: true,
	}
}

type createdEnvelope struct {
	Data struct {
		Company             map[string]any `json:"company"`
		AdministratorUserID string         `json:"administrator_user_id"`
		AdministratorRoleID string         `json:"administrator_role_id"`
		InvitationExpiresAt time.Time      `json:"invitation_expires_at"`
		InvitationChannel   string         `json:"invitation_channel"`
		RolesCreated        int            `json:"roles_created"`
	} `json:"data"`
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

func createPayload() map[string]any {
	suffix := uuid.NewString()[:8]
	return map[string]any{
		"name":                "Onebook " + suffix,
		"address":             "1200 Industrial Rd",
		"timezone":            "America/Chicago",
		"region":              "US",
		"unit_system":         "imperial",
		"regulation_profile":  "us_fmcsa",
		"plan":                "fleet_50",
		"subscription_status": "trial",
		"administrator": map[string]any{
			"first_name": "Jane",
			"last_name":  "Doe",
			"email":      "jane." + suffix + "@onebook.example",
		},
	}
}

func TestCreateCompanyProvisionsTheWholeTenant(t *testing.T) {
	srv := newServer(t)
	client := srv.AsPrincipal(superAdmin(t))

	resp := client.Post("/api/v1/companies", createPayload())
	testutil.RequireStatus(t, resp, http.StatusCreated)
	testutil.RequireNoPII(t, resp.Body)

	var env createdEnvelope
	resp.JSON(&env)

	companyID, err := uuid.Parse(env.Data.Company["id"].(string))
	require.NoError(t, err)
	require.NotEmpty(t, env.Data.AdministratorUserID)
	require.Equal(t, "email", env.Data.InvitationChannel)
	require.Greater(t, env.Data.RolesCreated, 0)
	require.WithinDuration(t, time.Now().UTC().Add(72*time.Hour), env.Data.InvitationExpiresAt, time.Minute)

	// The FMCSA 70/8 default policy version.
	require.Equal(t, 1, testutil.CountIn(t, "hos_policy_versions", companyID))
	// The system role templates were copied with their permissions.
	require.Equal(t, env.Data.RolesCreated, testutil.CountIn(t, "roles", companyID))
	// One notification_settings row per A§19 alert type.
	require.Equal(t, len(company.AlertDefaults), testutil.CountIn(t, "notification_settings", companyID))
	// The Administrator lands in `invited` state with an invitation row.
	require.Equal(t, 1, testutil.CountIn(t, "users", companyID))
	require.Equal(t, 1, testutil.CountIn(t, "invitations", companyID))
	// The whole provisioning is audited.
	require.Greater(t, testutil.CountIn(t, "audit_log", companyID), 0)

	var status string
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT status FROM users WHERE company_id = $1`, companyID).Scan(&status))
	require.Equal(t, "invited", status)

	var permCount int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM role_permissions rp
		 JOIN roles r ON r.id = rp.role_id WHERE r.company_id = $1`, companyID).Scan(&permCount))
	require.Greater(t, permCount, 0, "the copied roles keep their permission set")
}

func TestCreateCompanyRejectsADuplicateName(t *testing.T) {
	srv := newServer(t)
	client := srv.AsPrincipal(superAdmin(t))

	payload := createPayload()
	testutil.RequireStatus(t, client.Post("/api/v1/companies", payload), http.StatusCreated)

	second := createPayload()
	second["name"] = payload["name"]
	resp := client.Post("/api/v1/companies", second)
	testutil.RequireStatusCode(t, resp, http.StatusConflict, apierr.CodeUniqueViolation)
}

func TestCreateCompanyValidatesThePayload(t *testing.T) {
	srv := newServer(t)
	client := srv.AsPrincipal(superAdmin(t))

	for name, mutate := range map[string]func(map[string]any){
		"missing name":      func(p map[string]any) { delete(p, "name") },
		"unknown region":    func(p map[string]any) { p["region"] = "MARS" },
		"unknown timezone":  func(p map[string]any) { p["timezone"] = "Mars/Olympus" },
		"unknown unit":      func(p map[string]any) { p["unit_system"] = "furlongs" },
		"no administrator":  func(p map[string]any) { delete(p, "administrator") },
		"bad administrator": func(p map[string]any) { p["administrator"] = map[string]any{"first_name": "A"} },
		"past subscription": func(p map[string]any) { p["subscription_end_at"] = "2001-01-01T00:00:00Z" },
		"unknown status":    func(p map[string]any) { p["subscription_status"] = "free_forever" },
	} {
		t.Run(name, func(t *testing.T) {
			payload := createPayload()
			mutate(payload)
			resp := client.Post("/api/v1/companies", payload)
			testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
		})
	}
}

func TestListCompaniesFiltersAndPaginates(t *testing.T) {
	srv := newServer(t)
	client := srv.AsPrincipal(superAdmin(t))

	payload := createPayload()
	testutil.RequireStatus(t, client.Post("/api/v1/companies", payload), http.StatusCreated)

	resp := client.Get("/api/v1/companies",
		testutil.Query("search", payload["name"].(string)),
		testutil.Query("status", "trial"),
		testutil.Query("region", "US"),
		testutil.Query("sort", "created_at"),
		testutil.Query("order", "desc"))
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	var list listEnvelope
	resp.JSON(&list)
	require.Equal(t, int64(1), list.Meta.Total)
	require.Equal(t, payload["name"], list.Data[0]["name"])
}

func TestListCompaniesRejectsAnUnknownFilter(t *testing.T) {
	srv := newServer(t)
	client := srv.AsPrincipal(superAdmin(t))

	testutil.RequireStatusCode(t, client.Get("/api/v1/companies", testutil.Query("status", "free")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
	testutil.RequireStatusCode(t, client.Get("/api/v1/companies", testutil.Query("sort", "secret")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

// A tenant principal, however privileged inside its own company, is never a
// platform administrator.
func TestPlatformRoutesRejectATenantPrincipal(t *testing.T) {
	srv := newServer(t)
	tn := testutil.SeedTenant(t, testutil.PermissionKeys(t)...)
	client := srv.AsTenant(tn)

	testutil.RequireStatusCode(t, client.Get("/api/v1/companies"), http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatusCode(t, client.Post("/api/v1/companies", createPayload()),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatusCode(t, client.Patch("/api/v1/companies/"+tn.Company.ID.String(), map[string]any{"name": "x"}),
		http.StatusForbidden, apierr.CodeForbidden)
}

func TestPlatformRoutesRejectAnonymousCallers(t *testing.T) {
	srv := newServer(t)
	testutil.RequireStatus(t, srv.Anonymous().Get("/api/v1/companies"), http.StatusUnauthorized)
}

func TestUpdateCompany(t *testing.T) {
	srv := newServer(t)
	client := srv.AsPrincipal(superAdmin(t))

	created := client.Post("/api/v1/companies", createPayload())
	testutil.RequireStatus(t, created, http.StatusCreated)
	var env createdEnvelope
	created.JSON(&env)
	id := env.Data.Company["id"].(string)
	companyID := uuid.MustParse(id)
	before := testutil.CountIn(t, "audit_log", companyID)

	resp := client.Patch("/api/v1/companies/"+id, map[string]any{
		"region":             "PK",
		"unit_system":        "metric",
		"regulation_profile": "generic",
	})
	testutil.RequireStatus(t, resp, http.StatusOK)

	var out dataEnvelope
	resp.JSON(&out)
	require.Equal(t, "PK", out.Data["region"])
	require.Equal(t, "metric", out.Data["unit_system"])
	require.Equal(t, "generic", out.Data["regulation_profile"])
	require.Greater(t, testutil.CountIn(t, "audit_log", companyID), before)
}

func TestUpdateUnknownCompanyIsNotFound(t *testing.T) {
	srv := newServer(t)
	client := srv.AsPrincipal(superAdmin(t))

	resp := client.Patch("/api/v1/companies/"+uuid.NewString(), map[string]any{"name": "Ghost"})
	testutil.RequireStatusCode(t, resp, http.StatusNotFound, apierr.CodeNotFound)

	sub := client.Patch("/api/v1/companies/"+uuid.NewString()+"/subscription",
		map[string]any{"subscription_status": "active"})
	testutil.RequireStatusCode(t, sub, http.StatusNotFound, apierr.CodeNotFound)
}

func TestUpdateSubscription(t *testing.T) {
	srv := newServer(t)
	client := srv.AsPrincipal(superAdmin(t))

	created := client.Post("/api/v1/companies", createPayload())
	testutil.RequireStatus(t, created, http.StatusCreated)
	var env createdEnvelope
	created.JSON(&env)
	id := env.Data.Company["id"].(string)

	endAt := time.Now().UTC().Add(90 * 24 * time.Hour).Truncate(time.Second)
	resp := client.Patch("/api/v1/companies/"+id+"/subscription", map[string]any{
		"subscription_status": "active",
		"subscription_end_at": endAt.Format(time.RFC3339),
		"plan":                "fleet_100",
	})
	testutil.RequireStatus(t, resp, http.StatusOK)

	var out dataEnvelope
	resp.JSON(&out)
	require.Equal(t, "active", out.Data["subscription_status"])
	require.Equal(t, "fleet_100", out.Data["plan"])
	require.NotEmpty(t, out.Data["subscription_end_at"])

	// A readonly tenant keeps its data, the admin panel just freezes.
	frozen := client.Patch("/api/v1/companies/"+id+"/subscription",
		map[string]any{"subscription_status": "readonly"})
	testutil.RequireStatus(t, frozen, http.StatusOK)
	frozen.JSON(&out)
	require.Equal(t, "readonly", out.Data["subscription_status"])
}

func TestUpdateSubscriptionValidatesThePayload(t *testing.T) {
	srv := newServer(t)
	client := srv.AsPrincipal(superAdmin(t))

	created := client.Post("/api/v1/companies", createPayload())
	testutil.RequireStatus(t, created, http.StatusCreated)
	var env createdEnvelope
	created.JSON(&env)
	id := env.Data.Company["id"].(string)

	empty := client.Patch("/api/v1/companies/"+id+"/subscription", map[string]any{})
	testutil.RequireStatusCode(t, empty, http.StatusUnprocessableEntity, apierr.CodeValidationError)

	bad := client.Patch("/api/v1/companies/"+id+"/subscription",
		map[string]any{"subscription_status": "cancelled"})
	testutil.RequireStatusCode(t, bad, http.StatusUnprocessableEntity, apierr.CodeValidationError)

	conflict := client.Patch("/api/v1/companies/"+id+"/subscription", map[string]any{
		"clear_end_at":        true,
		"subscription_end_at": time.Now().UTC().Add(time.Hour).Format(time.RFC3339),
	})
	testutil.RequireStatusCode(t, conflict, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}
