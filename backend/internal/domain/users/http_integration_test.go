//go:build integration

// Integration coverage for the users / roles / permissions module: happy path,
// validation, RBAC, cross-tenant isolation, system role protection, permission
// cache invalidation, session revocation and the absence of PII in responses.
package users_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	authdomain "github.com/devline/onebook-eld/internal/domain/auth"
	"github.com/devline/onebook-eld/internal/domain/users"
	"github.com/devline/onebook-eld/internal/domain/users/dto"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

func TestMain(m *testing.M) { testutil.RunMain(m) }

// harness is one wired module plus the collaborators a test asserts on.
type harness struct {
	srv         *testutil.TestServer
	store       cache.Store
	repo        users.Repo
	permissions *core.RolePermissionCache
	revocations *core.Revocations
	sent        *recordingNotifier
}

// recordingNotifier captures the delivery attempts without leaking the token.
type recordingNotifier struct {
	messages []string
	tokens   []string
}

func (n *recordingNotifier) SendInvitation(_ context.Context, msg authdomain.InvitationMessage) error {
	n.messages = append(n.messages, msg.Purpose)
	n.tokens = append(n.tokens, msg.Token)
	return nil
}

func newHarness(t testing.TB) *harness {
	t.Helper()

	pool := testutil.NewDB(t)
	store := cache.NewMemoryStore()
	repo := users.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger()))

	permissions := core.NewRolePermissionCache(store, repo.RolePermissions, time.Minute)
	revocations := core.NewRevocations(store, time.Minute)
	notifier := &recordingNotifier{}

	svc := users.NewService(users.Deps{
		Repo:        repo,
		Permissions: permissions,
		Revocations: revocations,
		Notifier:    notifier,
		Logger:      testutil.Logger(),
	})

	// The harness registers the principal on the request context before the
	// router runs; the verifier only has to hand it back so the real
	// middleware chain (Authenticate -> RequireCompany -> Scope -> permission)
	// is exercised end to end.
	verifier := mw.VerifierFunc(func(ctx context.Context, _ string) (*tenant.Principal, error) {
		if p, ok := tenant.PrincipalFrom(ctx); ok {
			return p, nil
		}
		return nil, apierr.Unauthorized("unknown test token")
	})

	return &harness{
		srv:         testutil.NewServer(t, users.NewModule(svc, verifier, store)),
		store:       store,
		repo:        repo,
		permissions: permissions,
		revocations: revocations,
		sent:        notifier,
	}
}

// adminPermissions mirrors the seeded Administrator template, which holds the
// whole catalogue. It has to: least privilege forbids granting a permission
// the caller does not hold, so a partial set could neither define a role with
// `units.read` nor put a user into the Administrator template.
func adminPermissions() []string {
	return append([]string(nil), core.AllPermissions...)
}

// systemRoleID returns the seeded, company-less Administrator template.
func systemRoleID(t testing.TB) uuid.UUID {
	t.Helper()
	var id uuid.UUID
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT id FROM roles WHERE company_id IS NULL AND is_system AND lower(name) = 'administrator'`).Scan(&id)
	require.NoError(t, err, "read the Administrator template")
	return id
}

// insertSession creates an active session so revocation can be asserted.
func insertSession(t testing.TB, companyID, userID uuid.UUID, deviceType string) uuid.UUID {
	t.Helper()
	id := uuid.New()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO sessions (id, company_id, user_id, device_type, refresh_token_hash, status, expires_at)
		 VALUES ($1, $2, $3, $4, $5, 'active', now() + interval '7 days')`,
		id, companyID, userID, deviceType, uuid.NewString())
	require.NoError(t, err, "insert session")
	return id
}

func sessionStatus(t testing.TB, id uuid.UUID) string {
	t.Helper()
	var status string
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT status FROM sessions WHERE id = $1`, id).Scan(&status))
	return status
}

func auditCount(t testing.TB, companyID, recordID uuid.UUID) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM audit_log WHERE company_id = $1 AND record_id = $2`, companyID, recordID).Scan(&n))
	return n
}

// ---------------------------------------------------------------- users

func TestCreateUserInvitesAndAudits(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)
	client := h.srv.AsTenant(tn)

	resp := client.Post("/api/v1/users", map[string]any{
		"first_name": "Ada",
		"last_name":  "Lovelace",
		"email":      "ada." + uuid.NewString()[:8] + "@example.test",
		"username":   "ada" + uuid.NewString()[:8],
		"role_id":    tn.Role.ID.String(),
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)
	testutil.RequireNoPII(t, resp.Body)

	var env dto.UserEnvelope
	resp.JSON(&env)
	require.Equal(t, users.StatusInvited, env.Data.Status, "a new account starts as invited")
	require.Equal(t, tn.Role.ID.String(), env.Data.Role.ID)
	require.NotEmpty(t, env.Data.InvitedAt)

	created := uuid.MustParse(env.Data.ID)
	require.Positive(t, auditCount(t, tn.ID(), created), "the creation must be audited")

	// The invitation is delivered out of band; the token never reaches the API.
	require.Equal(t, []string{users.PurposeInvitation}, h.sent.messages)
	require.NotEmpty(t, h.sent.tokens[0])
	require.NotContains(t, string(resp.Body), h.sent.tokens[0])

	var stored int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM invitations WHERE user_id = $1 AND purpose = 'invitation' AND used_at IS NULL`,
		created).Scan(&stored))
	require.Equal(t, 1, stored, "exactly one live invitation")
}

func TestCreateUserRequiresEmailOrPhone(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)

	resp := h.srv.AsTenant(tn).Post("/api/v1/users", map[string]any{
		"first_name": "Ada",
		"last_name":  "Lovelace",
		"username":   "ada" + uuid.NewString()[:8],
		"role_id":    tn.Role.ID.String(),
	})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestCreateUserRejectsAPasswordField(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)

	resp := h.srv.AsTenant(tn).Post("/api/v1/users", map[string]any{
		"first_name": "Ada",
		"last_name":  "Lovelace",
		"email":      "ada." + uuid.NewString()[:8] + "@example.test",
		"username":   "ada" + uuid.NewString()[:8],
		"role_id":    tn.Role.ID.String(),
		"password":   "Str0ngPassphrase",
	})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestListUsersHidesOtherTenantsAndPII(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, adminPermissions()...)

	resp := h.srv.AsTenant(a).Get("/api/v1/users", testutil.Query("per_page", "50"))
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	var env dto.UserListEnvelope
	resp.JSON(&env)
	require.NotEmpty(t, env.Data)
	for _, u := range env.Data {
		require.NotEqual(t, b.User.ID.String(), u.ID, "another tenant leaked into the list")
	}
}

func TestListUsersBranchScopeIsEnforced(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)
	other := testutil.NewBranch(t, tn.ID())
	outsider := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role), testutil.WithBranch(other))

	p := tn.Principal()
	p.Scope = tenant.ScopeBranch
	p.BranchID = tn.User.BranchID

	resp := h.srv.AsPrincipal(p).Get("/api/v1/users", testutil.Query("per_page", "50"))
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env dto.UserListEnvelope
	resp.JSON(&env)
	for _, u := range env.Data {
		require.NotEqual(t, outsider.ID.String(), u.ID, "a branch scoped caller saw another branch")
	}
}

func TestListUsersRejectsUnknownSortField(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)

	resp := h.srv.AsTenant(tn).Get("/api/v1/users", testutil.Query("sort", "password_hash"))
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestUsersRequirePermission(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t) // no permissions at all

	testutil.RequireStatusCode(t, h.srv.AsTenant(tn).Get("/api/v1/users"),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatusCode(t, h.srv.AsTenant(tn).Post("/api/v1/users", map[string]any{}),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatus(t, h.srv.Anonymous().Get("/api/v1/users"), http.StatusUnauthorized)
}

func TestUpdateUserCrossTenantIs404(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, adminPermissions()...)

	resp := h.srv.AsTenant(a).Patch("/api/v1/users/"+b.User.ID.String(), map[string]any{
		"first_name": "Mallory",
	})
	testutil.RequireStatusCode(t, resp, http.StatusNotFound, apierr.CodeNotFound)

	testutil.RequireStatusCode(t, h.srv.AsTenant(a).Delete("/api/v1/users/"+b.User.ID.String()),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestUpdateUserRoleRevokesSessions(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)
	target := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))
	newRole := testutil.NewRole(t, tn.ID(), []string{core.PermUnitsRead})
	session := insertSession(t, tn.ID(), target.ID, tenant.DeviceWeb)

	resp := h.srv.AsTenant(tn).Patch("/api/v1/users/"+target.ID.String(), map[string]any{
		"role_id": newRole.ID.String(),
	})
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	require.Equal(t, "revoked", sessionStatus(t, session), "a role change must drop the sessions")
	revoked, err := h.revocations.IsRevoked(testutil.Ctx(t), session)
	require.NoError(t, err)
	require.True(t, revoked, "the access token deny list must carry the session")
}

func TestDeactivateUserRevokesSessionsAndAudits(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)
	target := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))
	session := insertSession(t, tn.ID(), target.ID, tenant.DevicePhone)

	resp := h.srv.AsTenant(tn).Post("/api/v1/users/"+target.ID.String()+"/deactivate", nil)
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	var env dto.UserEnvelope
	resp.JSON(&env)
	require.Equal(t, users.StatusInactive, env.Data.Status)
	require.Equal(t, "revoked", sessionStatus(t, session), "Q3.1: sessions are revoked")
	require.Positive(t, auditCount(t, tn.ID(), target.ID))

	// The transition is reversible (Q1).
	back := h.srv.AsTenant(tn).Post("/api/v1/users/"+target.ID.String()+"/activate", nil)
	testutil.RequireStatus(t, back, http.StatusOK)
	back.JSON(&env)
	require.Equal(t, users.StatusActive, env.Data.Status)
}

func TestCannotDeleteOrDeactivateYourself(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)

	testutil.RequireStatusCode(t, h.srv.AsTenant(tn).Delete("/api/v1/users/"+tn.User.ID.String()),
		http.StatusConflict, apierr.CodeSelfTargetForbidden)
	testutil.RequireStatusCode(t,
		h.srv.AsTenant(tn).Post("/api/v1/users/"+tn.User.ID.String()+"/deactivate", nil),
		http.StatusConflict, apierr.CodeSelfTargetForbidden)
}

func TestCannotRemoveTheLastAdministrator(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)

	// The only Administrator of the company, managed by a different operator.
	admin := testutil.NewUser(t, tn.ID(), testutil.WithRoleID(systemRoleID(t)))

	testutil.RequireStatusCode(t, h.srv.AsTenant(tn).Delete("/api/v1/users/"+admin.ID.String()),
		http.StatusConflict, apierr.CodeLastAdministrator)
	testutil.RequireStatusCode(t,
		h.srv.AsTenant(tn).Post("/api/v1/users/"+admin.ID.String()+"/deactivate", nil),
		http.StatusConflict, apierr.CodeLastAdministrator)

	// With a second Administrator the first one can be removed.
	testutil.NewUser(t, tn.ID(), testutil.WithRoleID(systemRoleID(t)))
	testutil.RequireStatus(t, h.srv.AsTenant(tn).Delete("/api/v1/users/"+admin.ID.String()),
		http.StatusNoContent)
}

func TestDeleteUserIsSoftAndRevokesSessions(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)
	target := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))
	session := insertSession(t, tn.ID(), target.ID, tenant.DeviceTablet)

	testutil.RequireStatus(t, h.srv.AsTenant(tn).Delete("/api/v1/users/"+target.ID.String()),
		http.StatusNoContent)

	var deletedAt *time.Time
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT deleted_at FROM users WHERE id = $1`, target.ID).Scan(&deletedAt))
	require.NotNil(t, deletedAt, "the row must be soft deleted, not removed")
	require.Equal(t, "revoked", sessionStatus(t, session))

	testutil.RequireStatusCode(t, h.srv.AsTenant(tn).Delete("/api/v1/users/"+target.ID.String()),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestResendInvitationRotatesTheLink(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)
	invited := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role), testutil.WithStatus(users.StatusInvited))

	resp := h.srv.AsTenant(tn).Post("/api/v1/users/"+invited.ID.String()+"/resend-invitation", nil)
	testutil.RequireStatus(t, resp, http.StatusAccepted)
	testutil.RequireNoPII(t, resp.Body)

	var env dto.InvitationEnvelope
	resp.JSON(&env)
	require.Equal(t, users.PurposeInvitation, env.Data.Purpose)
	require.True(t, env.Data.ExpiresAt.After(time.Now().UTC()), "the link must be in the future")

	// An already activated account is rejected: use reset-password instead.
	testutil.RequireStatusCode(t,
		h.srv.AsTenant(tn).Post("/api/v1/users/"+tn.User.ID.String()+"/resend-invitation", nil),
		http.StatusConflict, apierr.CodeInvalidState)
}

func TestResetPasswordSendsALinkAndNeverAToken(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)
	target := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))

	resp := h.srv.AsTenant(tn).Post("/api/v1/users/"+target.ID.String()+"/reset-password", nil)
	testutil.RequireStatus(t, resp, http.StatusAccepted)
	testutil.RequireNoPII(t, resp.Body)

	var env dto.InvitationEnvelope
	resp.JSON(&env)
	require.Equal(t, users.PurposePasswordReset, env.Data.Purpose)

	require.NotEmpty(t, h.sent.tokens)
	require.NotContains(t, string(resp.Body), h.sent.tokens[len(h.sent.tokens)-1])
}

// ---------------------------------------------------------------- roles

func TestRoleLifecycleAndPermissionCacheInvalidation(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)
	client := h.srv.AsTenant(tn)

	create := client.Post("/api/v1/roles", map[string]any{
		"name":        "Yard " + uuid.NewString()[:8],
		"scope":       "company",
		"permissions": []string{core.PermUnitsRead, core.PermDriversRead},
	})
	testutil.RequireStatus(t, create, http.StatusCreated)

	var env dto.RoleEnvelope
	create.JSON(&env)
	roleID := uuid.MustParse(env.Data.ID)
	require.Equal(t, []string{core.PermDriversRead, core.PermUnitsRead}, env.Data.Permissions)
	require.False(t, env.Data.IsSystem)

	// Prime the cache, then narrow the role and make sure the cache followed.
	// The loader reads through RLS, so the tenant has to be on the context.
	ctx := tenant.WithCompanyID(testutil.Ctx(t), tn.ID())
	cached, err := h.permissions.PermissionsForRole(ctx, roleID)
	require.NoError(t, err)
	require.Len(t, cached, 2)

	holder := testutil.NewUser(t, tn.ID(), testutil.WithRoleID(roleID))
	session := insertSession(t, tn.ID(), holder.ID, tenant.DeviceWeb)

	update := client.Patch("/api/v1/roles/"+roleID.String(), map[string]any{
		"permissions": []string{core.PermUnitsRead},
	})
	testutil.RequireStatus(t, update, http.StatusOK)

	cached, err = h.permissions.PermissionsForRole(ctx, roleID)
	require.NoError(t, err)
	require.Equal(t, []string{core.PermUnitsRead}, cached, "the permission cache was not invalidated")
	require.Equal(t, "revoked", sessionStatus(t, session), "holders must lose their sessions")

	// A role with users cannot be deleted.
	testutil.RequireStatusCode(t, client.Delete("/api/v1/roles/"+roleID.String()),
		http.StatusConflict, apierr.CodeRoleInUse)

	_, err = testutil.AdminPool(t).Exec(ctx, `UPDATE users SET deleted_at = now() WHERE id = $1`, holder.ID)
	require.NoError(t, err)
	testutil.RequireStatus(t, client.Delete("/api/v1/roles/"+roleID.String()), http.StatusNoContent)
}

func TestCreateRoleRejectsUnknownPermission(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)

	for _, key := range []string{"units.teleport", "logs.delete", "audit_log.delete"} {
		resp := h.srv.AsTenant(tn).Post("/api/v1/roles", map[string]any{
			"name":        "Bad " + uuid.NewString()[:8],
			"scope":       "company",
			"permissions": []string{core.PermUnitsRead, key},
		})
		testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
	}
}

func TestSystemRolesAreImmutable(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, adminPermissions()...)
	systemID := systemRoleID(t).String()

	testutil.RequireStatusCode(t,
		h.srv.AsTenant(tn).Patch("/api/v1/roles/"+systemID, map[string]any{"name": "Hacked"}),
		http.StatusForbidden, apierr.CodeSystemRoleImmutable)
	testutil.RequireStatusCode(t, h.srv.AsTenant(tn).Delete("/api/v1/roles/"+systemID),
		http.StatusForbidden, apierr.CodeSystemRoleImmutable)
}

func TestListRolesReturnsSystemAndCompanyRoles(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, adminPermissions()...)

	resp := h.srv.AsTenant(a).Get("/api/v1/roles", testutil.Query("per_page", "50"))
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	var env dto.RoleListEnvelope
	resp.JSON(&env)

	sawSystem, sawOwn := false, false
	for _, role := range env.Data {
		require.NotEqual(t, b.Role.ID.String(), role.ID, "another tenant's role leaked")
		if role.IsSystem {
			sawSystem = true
		}
		if role.ID == a.Role.ID.String() {
			sawOwn = true
		}
	}
	require.True(t, sawSystem, "system templates must be listed")
	require.True(t, sawOwn, "the company role must be listed")
}

func TestUpdateRoleCrossTenantIs404(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, adminPermissions()...)

	testutil.RequireStatusCode(t,
		h.srv.AsTenant(a).Patch("/api/v1/roles/"+b.Role.ID.String(), map[string]any{"name": "Mallory"}),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestRolesRequirePermission(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t)

	testutil.RequireStatusCode(t, h.srv.AsTenant(tn).Get("/api/v1/roles"),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatusCode(t, h.srv.AsTenant(tn).Post("/api/v1/roles", map[string]any{}),
		http.StatusForbidden, apierr.CodeForbidden)
}

// ---------------------------------------------------------------- permissions

func TestPermissionsCatalogueRequiresAPermission(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, core.PermPermissionsRead)

	resp := h.srv.AsTenant(tn).Get("/api/v1/permissions")
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env dto.PermissionListEnvelope
	resp.JSON(&env)
	require.NotEmpty(t, env.Data)

	keys := map[string]struct{}{}
	for _, module := range env.Data {
		require.NotEmpty(t, module.Label)
		for _, p := range module.Permissions {
			require.NotEmpty(t, p.Description)
			keys[p.Key] = struct{}{}
		}
	}
	require.Len(t, keys, len(core.AllPermissions))
	for _, forbidden := range []string{"logs.delete", "dvir.delete", "violations.delete", "telemetry.delete", "audit_log.delete"} {
		_, ok := keys[forbidden]
		require.False(t, ok, "Q82.2: %s must not be published", forbidden)
	}

	testutil.RequireStatus(t, h.srv.Anonymous().Get("/api/v1/permissions"), http.StatusUnauthorized)

	// The role editor needs the catalogue, so roles.read opens it too.
	editor := testutil.SeedTenant(t, core.PermRolesRead)
	testutil.RequireStatus(t, h.srv.AsTenant(editor).Get("/api/v1/permissions"), http.StatusOK)

	// Q82: the catalogue describes the whole RBAC surface, so a session that
	// holds neither key (a driver, for example) does not get to enumerate it.
	driver := testutil.SeedTenant(t, core.PermLogsRead)
	testutil.RequireStatusCode(t, h.srv.AsTenant(driver).Get("/api/v1/permissions"),
		http.StatusForbidden, apierr.CodeForbidden)
}

// The notifier must satisfy the delivery contract the auth module defines.
var _ authdomain.Notifier = (*recordingNotifier)(nil)
