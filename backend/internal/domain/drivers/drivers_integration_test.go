//go:build integration

// Integration coverage of Driver Management: the happy path, validation,
// permission and cross-tenant behaviour, the encrypted licence column, session
// revocation on deactivation and the symmetric co-driver pairs.
package drivers_test

import (
	"context"
	"encoding/json"
	"net/http"
	"regexp"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/domain/drivers"
	"github.com/devline/onebook-eld/internal/domain/drivers/dto"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// driverPermissions is the full permission set of the module.
var driverPermissions = []string{
	core.PermDriversRead, core.PermDriversCreate, core.PermDriversUpdate,
	core.PermDriversDelete, core.PermDriversActivate, core.PermDriversDeactivate,
	core.PermDriversManageCoDrivers, core.PermDriversResetPassword,
	core.PermDriversLicenseView,
}

// ctxVerifier trusts the principal testutil already put on the request context,
// so the module keeps its real middleware chain without minting JWTs.
func ctxVerifier() mw.AuthVerifier {
	return mw.VerifierFunc(func(ctx context.Context, _ string) (*tenant.Principal, error) {
		if p, ok := tenant.PrincipalFrom(ctx); ok {
			return p, nil
		}
		return nil, apierr.Unauthorized("no test principal")
	})
}

func newModule(t *testing.T) *drivers.Module {
	t.Helper()
	pool := testutil.NewDB(t)
	cipher, err := appcrypto.NewCipherFromString(testutil.TestConfig().EncryptionKey)
	require.NoError(t, err)

	recorder := audit.NewPgRecorder(pool, testutil.Logger())
	return drivers.New(drivers.Deps{
		Repo:        drivers.NewRepo(pool, recorder),
		Cipher:      cipher,
		Audit:       recorder,
		Revocations: core.NewRevocations(cache.NewMemoryStore(), core.DefaultAccessTTL),
		Verifier:    ctxVerifier(),
		Logger:      testutil.Logger(),
	})
}

func newServer(t *testing.T) *testutil.TestServer {
	t.Helper()
	return testutil.NewServer(t, newModule(t))
}

func TestCreateDriverHappyPath(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	client := srv.AsTenant(tn)

	username := "drv." + strings.ReplaceAll(uuid.NewString()[:8], "-", "")
	in := dto.DriverCreate{
		FirstName: "John", LastName: "Doe", Username: username,
		Email: username + "@example.com", Phone: "+14155550123",
		LicenseNo: "TX-9930-4821", LicenseRegion: "TX", HomeTerminal: "Dallas Yard",
	}

	resp := client.Post("/api/v1/drivers", in)
	testutil.RequireStatus(t, resp, http.StatusCreated)
	requireNoPII(t, resp.Body)

	var env dto.DriverEnvelope
	resp.JSON(&env)
	require.Equal(t, username, env.Data.Username)
	require.Equal(t, dto.StatusInvited, env.Data.Status)
	require.Equal(t, "invited", env.Data.UserStatus)
	// Only the last four characters of the licence ever reach a client.
	require.Equal(t, "***4821", env.Data.LicenseNoMasked)

	// The users row exists with the Driver role and no password.
	var passwordHash *string
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT u.password_hash FROM users u JOIN drivers d ON d.user_id = u.id WHERE d.id = $1`,
		uuid.MustParse(env.Data.ID)).Scan(&passwordHash)
	require.NoError(t, err)
	require.Nil(t, passwordHash, "Q18.1: a driver never gets a password on create")

	// An invitation was issued.
	require.Equal(t, 1, countInvitations(t, uuid.MustParse(env.Data.UserID)))
}

func TestCreateDriverEncryptsLicenseAtRest(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	client := srv.AsTenant(tn)

	const plain = "TX-9930-4821"
	username := "enc." + strings.ReplaceAll(uuid.NewString()[:8], "-", "")
	resp := client.Post("/api/v1/drivers", dto.DriverCreate{
		FirstName: "Enc", LastName: "Rypted", Username: username,
		Email: username + "@example.com", LicenseNo: plain,
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)

	var env dto.DriverEnvelope
	resp.JSON(&env)

	var stored *string
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT license_no_enc FROM drivers WHERE id = $1`, uuid.MustParse(env.Data.ID)).Scan(&stored)
	require.NoError(t, err)
	require.NotNil(t, stored)
	require.NotContains(t, *stored, plain, "license_no must never be stored in clear text")
	require.NotEqual(t, plain, *stored)

	// The clear value is only served behind drivers.license.view, and it
	// round-trips.
	reveal := client.Get("/api/v1/drivers/" + env.Data.ID + "/license")
	testutil.RequireStatus(t, reveal, http.StatusOK)
	var lic dto.DriverLicenseEnvelope
	reveal.JSON(&lic)
	require.Equal(t, plain, lic.Data.LicenseNo)

	// A reader without drivers.license.view cannot reach it.
	reader := srv.AsPrincipal(principalWith(tn, core.PermDriversRead))
	testutil.RequireStatusCode(t, reader.Get("/api/v1/drivers/"+env.Data.ID+"/license"),
		http.StatusForbidden, apierr.CodeForbidden)
}

func TestCreateDriverValidation(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	client := srv.AsTenant(tn)

	cases := map[string]dto.DriverCreate{
		"username too short": {
			FirstName: "A", LastName: "B", Username: "ab",
			Email: "a@example.com", LicenseNo: "TX-1",
		},
		"username has invalid characters": {
			FirstName: "A", LastName: "B", Username: "John Doe!",
			Email: "a@example.com", LicenseNo: "TX-1",
		},
		"neither email nor phone": {
			FirstName: "A", LastName: "B", Username: "a.valid.name",
			LicenseNo: "TX-1234",
		},
		"license_no missing": {
			FirstName: "A", LastName: "B", Username: "a.valid.name",
			Email: "a@example.com",
		},
	}

	for name, in := range cases {
		t.Run(name, func(t *testing.T) {
			resp := client.Post("/api/v1/drivers", in)
			testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
		})
	}
}

func TestDriverPermissionAndTenantIsolation(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, driverPermissions...)

	// 403: a principal without the permission.
	none := srv.AsPrincipal(principalWith(a))
	testutil.RequireStatusCode(t, none.Get("/api/v1/drivers"), http.StatusForbidden, apierr.CodeForbidden)

	// 401: anonymous.
	testutil.RequireStatusCode(t, srv.Anonymous().Get("/api/v1/drivers"),
		http.StatusUnauthorized, apierr.CodeUnauthorized)

	// 404, never 403: a driver of another tenant does not exist for us.
	client := srv.AsTenant(a)
	other := "/api/v1/drivers/" + b.Driver.ID.String()
	testutil.RequireStatusCode(t, client.Get(other), http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, client.Patch(other, dto.DriverUpdate{}),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, client.Delete(other), http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, client.Post(other+"/deactivate", nil),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, client.Get(other+"/activities"),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestListDriversFiltersAndPagination(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	client := srv.AsTenant(tn)

	// The seeded tenant already has one driver; add two more.
	for i := 0; i < 2; i++ {
		username := "lst." + strings.ReplaceAll(uuid.NewString()[:8], "-", "")
		resp := client.Post("/api/v1/drivers", dto.DriverCreate{
			FirstName: "List", LastName: "Driver", Username: username,
			Email: username + "@example.com", LicenseNo: "TX-0000-111" + string(rune('0'+i)),
		})
		testutil.RequireStatus(t, resp, http.StatusCreated)
	}

	resp := client.Get("/api/v1/drivers", testutil.Query("status", "invited"))
	testutil.RequireStatus(t, resp, http.StatusOK)
	requireNoPII(t, resp.Body)

	var env dto.DriverListEnvelope
	resp.JSON(&env)
	require.Equal(t, int64(2), env.Meta.Total)

	// An unknown status is rejected rather than silently ignored.
	testutil.RequireStatusCode(t, client.Get("/api/v1/drivers", testutil.Query("status", "zombie")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// An unknown sort field is rejected (whitelist).
	testutil.RequireStatusCode(t, client.Get("/api/v1/drivers", testutil.Query("sort", "license_no")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestDeactivateDriverRevokesSessions(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	client := srv.AsTenant(tn)

	sessionID := seedSession(t, tn)

	resp := client.Post("/api/v1/drivers/"+tn.Driver.ID.String()+"/deactivate",
		dto.StatusChange{Reason: "left the company"})
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env dto.DriverEnvelope
	resp.JSON(&env)
	require.Equal(t, dto.StatusInactive, env.Data.Status)
	require.Equal(t, "inactive", env.Data.UserStatus)

	var status string
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT status FROM sessions WHERE id = $1`, sessionID).Scan(&status))
	require.Equal(t, "revoked", status, "an inactive driver keeps no live session")

	// Reactivation puts the driver back.
	back := client.Post("/api/v1/drivers/"+tn.Driver.ID.String()+"/activate", nil)
	testutil.RequireStatus(t, back, http.StatusOK)
	back.JSON(&env)
	require.Equal(t, dto.StatusActive, env.Data.Status)
}

func TestCoDriversAreSymmetric(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	client := srv.AsTenant(tn)

	otherUser := testutil.NewUser(t, tn.Company.ID, testutil.WithRole(tn.Role))
	other := testutil.NewDriver(t, tn.Company.ID, testutil.WithUser(otherUser))

	a := "/api/v1/drivers/" + tn.Driver.ID.String() + "/co-drivers"
	b := "/api/v1/drivers/" + other.ID.String() + "/co-drivers"

	resp := client.Post(a, dto.CoDriverCreate{CoDriverID: other.ID.String()})
	testutil.RequireStatus(t, resp, http.StatusCreated)

	var list dto.CoDriverListEnvelope
	client.Get(a).JSON(&list)
	require.Len(t, list.Data, 1)
	require.Equal(t, other.ID.String(), list.Data[0].DriverID)

	// The pair is stored once but shows on both sides (TZ §1.1).
	client.Get(b).JSON(&list)
	require.Len(t, list.Data, 1)
	require.Equal(t, tn.Driver.ID.String(), list.Data[0].DriverID)

	// Only one row backs the relation.
	require.Equal(t, 1, countDriverPairs(t, tn.Company.ID))

	// Linking again is idempotent, not a 409.
	testutil.RequireStatus(t, client.Post(a, dto.CoDriverCreate{CoDriverID: other.ID.String()}),
		http.StatusCreated)
	require.Equal(t, 1, countDriverPairs(t, tn.Company.ID))

	// A driver cannot be its own co-driver.
	testutil.RequireStatusCode(t, client.Post(a, dto.CoDriverCreate{CoDriverID: tn.Driver.ID.String()}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// Unlinking clears both sides.
	testutil.RequireStatus(t, client.Delete(a+"/"+other.ID.String()), http.StatusNoContent)
	client.Get(b).JSON(&list)
	require.Empty(t, list.Data)
}

func TestUpdateDeleteAndActivities(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	client := srv.AsTenant(tn)

	id := tn.Driver.ID.String()
	notes := "night shifts"
	city := "Dallas"
	patch := client.Patch("/api/v1/drivers/"+id, dto.DriverUpdate{Notes: &notes, City: &city})
	testutil.RequireStatus(t, patch, http.StatusOK)
	requireNoPII(t, patch.Body)

	var env dto.DriverEnvelope
	patch.JSON(&env)
	require.Equal(t, notes, env.Data.Notes)
	require.Equal(t, city, env.Data.City)

	// The change is audited and surfaces in the activity feed.
	feed := client.Get("/api/v1/drivers/" + id + "/activities")
	testutil.RequireStatus(t, feed, http.StatusOK)
	requireNoPII(t, feed.Body)
	var activities dto.ActivityListEnvelope
	feed.JSON(&activities)
	require.NotEmpty(t, activities.Data, "the update must appear in the activity feed")

	// Soft delete keeps the row but hides it from the API.
	testutil.RequireStatus(t, client.Delete("/api/v1/drivers/"+id), http.StatusNoContent)
	testutil.RequireStatusCode(t, client.Get("/api/v1/drivers/"+id), http.StatusNotFound, apierr.CodeNotFound)

	var deletedAt *string
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT deleted_at::text FROM drivers WHERE id = $1`, tn.Driver.ID).Scan(&deletedAt))
	require.NotNil(t, deletedAt, "DELETE is a soft delete")
}

func TestResetPasswordReissuesInvitation(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	client := srv.AsTenant(tn)

	resp := client.Post("/api/v1/drivers/"+tn.Driver.ID.String()+"/reset-password", nil)
	testutil.RequireStatus(t, resp, http.StatusOK)
	requireNoPII(t, resp.Body)

	var env dto.ResetPasswordEnvelope
	resp.JSON(&env)
	require.Contains(t, []string{"email", "sms"}, env.Data.Channel)
	require.Equal(t, 1, countInvitations(t, tn.Driver.UserID))

	// A second call burns the first link and issues exactly one live token.
	testutil.RequireStatus(t, client.Post("/api/v1/drivers/"+tn.Driver.ID.String()+"/reset-password", nil),
		http.StatusOK)
	require.Equal(t, 1, countInvitations(t, tn.Driver.UserID))
}

// ---------------------------------------------------------------- helpers

// requireNoPII asserts the response carries no secret or PII field.
//
// `license_no_masked` is the one deliberate remnant of a PII column: it holds
// at most the last four characters of the licence number. The shared
// testutil.RequireNoPII rejects anything prefixed `license_no_`, so the field
// is verified to really be masked and then dropped before the generic check
// runs over the rest of the body.
func requireNoPII(t *testing.T, body []byte) {
	t.Helper()
	var v any
	require.NoError(t, json.Unmarshal(body, &v))
	stripMasked(t, v)
	rest, err := json.Marshal(v)
	require.NoError(t, err)
	testutil.RequireNoPII(t, rest)
}

var maskedRe = regexp.MustCompile(`^(\*\*\*.{0,4})?$`)

func stripMasked(t *testing.T, v any) {
	switch n := v.(type) {
	case map[string]any:
		if raw, ok := n["license_no_masked"]; ok {
			masked, _ := raw.(string)
			require.Regexp(t, maskedRe, masked, "license_no must only ever be exposed masked")
			delete(n, "license_no_masked")
		}
		for _, child := range n {
			stripMasked(t, child)
		}
	case []any:
		for _, child := range n {
			stripMasked(t, child)
		}
	}
}

// principalWith returns the tenant principal carrying exactly permissions.
func principalWith(tn *testutil.Tenant, permissions ...string) *tenant.Principal {
	p := tn.Principal()
	p.Permissions = permissions
	return p
}

func countInvitations(t *testing.T, userID uuid.UUID) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM invitations WHERE user_id = $1 AND used_at IS NULL AND expires_at > now()`,
		userID).Scan(&n))
	return n
}

func countDriverPairs(t *testing.T, companyID uuid.UUID) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM driver_pairs WHERE company_id = $1 AND deleted_at IS NULL`,
		companyID).Scan(&n))
	return n
}

// seedSession inserts one live session for the tenant driver.
func seedSession(t *testing.T, tn *testutil.Tenant) uuid.UUID {
	t.Helper()
	var id uuid.UUID
	err := testutil.NewDB(t).WithTx(testutil.Ctx(t), tn.Company.ID, func(tx pgx.Tx) error {
		return tx.QueryRow(context.Background(), `
			INSERT INTO sessions (company_id, user_id, device_type, refresh_token_hash, expires_at)
			VALUES ($1, $2, 'phone', $3, now() + interval '30 days')
			RETURNING id`,
			tn.Company.ID, tn.Driver.UserID, uuid.NewString()).Scan(&id)
	})
	require.NoError(t, err)
	return id
}
