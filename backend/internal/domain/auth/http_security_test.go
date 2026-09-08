package auth

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/auth/dto"
)

// newTestServer mounts the real module on a chi router with the real verifier,
// so the tests exercise the same middleware chain production uses.
func newTestServer(t *testing.T, h *harness) *httptest.Server {
	t.Helper()

	tokens, err := core.NewTokenService(testSecret, core.DefaultAccessTTL)
	require.NoError(t, err)
	tokens.SetClock(func() time.Time { return h.now })

	verifier := core.NewVerifier(tokens,
		core.NewRolePermissionCache(h.store, h.repo.RolePermissions, time.Minute),
		core.NewRevocations(h.store, core.DefaultAccessTTL))

	r := chi.NewRouter()
	r.Route("/api/v1", func(api chi.Router) {
		NewModule(h.svc, verifier, h.store, 0).RegisterRoutes(api)
	})

	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)
	return srv
}

func do(t *testing.T, srv *httptest.Server, method, path, token string, body any) (int, []byte) {
	t.Helper()
	var rdr io.Reader
	if body != nil {
		raw, err := json.Marshal(body)
		require.NoError(t, err)
		rdr = bytes.NewReader(raw)
	}
	req, err := http.NewRequest(method, srv.URL+path, rdr)
	require.NoError(t, err)
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := srv.Client().Do(req)
	require.NoError(t, err)
	defer func() { _ = resp.Body.Close() }()
	out, err := io.ReadAll(resp.Body)
	require.NoError(t, err)
	return resp.StatusCode, out
}

func apiErrorCode(t *testing.T, body []byte) string {
	t.Helper()
	var resp struct {
		Error struct {
			Code string `json:"code"`
		} `json:"error"`
	}
	require.NoError(t, json.Unmarshal(body, &resp))
	return resp.Error.Code
}

func TestProtectedRoutesRejectAnonymousCallers(t *testing.T) {
	srv := newTestServer(t, newHarness(t))

	for _, tc := range []struct {
		method, path string
	}{
		{http.MethodGet, "/api/v1/me"},
		{http.MethodGet, "/api/v1/auth/sessions"},
		{http.MethodDelete, "/api/v1/auth/sessions/" + uuid.NewString()},
		{http.MethodPost, "/api/v1/auth/logout"},
		{http.MethodPost, "/api/v1/auth/pin/verify"},
		{http.MethodPost, "/api/v1/auth/2fa/setup"},
	} {
		status, body := do(t, srv, tc.method, tc.path, "", nil)
		require.Equal(t, http.StatusUnauthorized, status, "%s %s must require a token", tc.method, tc.path)
		require.NotEmpty(t, apiErrorCode(t, body))
	}
}

func TestPublicRoutesNeedNoToken(t *testing.T) {
	h := newHarness(t)
	h.repo.settings["min_supported_version"] = []byte(`"1.2.0"`)
	h.repo.settings["force_update"] = []byte(`true`)
	h.repo.settings["feature_flags"] = []byte(`{"chat":true,"dvir":false}`)
	srv := newTestServer(t, h)

	status, body := do(t, srv, http.MethodGet, "/api/v1/app/config", "", nil)
	require.Equal(t, http.StatusOK, status)

	var envelope struct{ Data dto.AppConfig }
	require.NoError(t, json.Unmarshal(body, &envelope))
	require.Equal(t, "1.2.0", envelope.Data.MinSupportedVersion)
	require.True(t, envelope.Data.ForceUpdate)
	require.True(t, envelope.Data.FeatureFlags["chat"])
	require.False(t, envelope.Data.FeatureFlags["dvir"])
}

func TestLoginEndpointValidatesInput(t *testing.T) {
	srv := newTestServer(t, newHarness(t))

	status, body := do(t, srv, http.MethodPost, "/api/v1/auth/login", "",
		map[string]any{"username": "jdoe"})
	require.Equal(t, http.StatusUnprocessableEntity, status)
	require.Equal(t, "VALIDATION_ERROR", apiErrorCode(t, body))

	// An invented device type is refused by the schema, so it cannot open a
	// fourth concurrent session slot.
	status, _ = do(t, srv, http.MethodPost, "/api/v1/auth/login", "",
		map[string]any{"username": "jdoe", "password": testPassword, "device_type": "watch"})
	require.Equal(t, http.StatusUnprocessableEntity, status)
}

func TestLoginResponseOverTheWireLeaksNothing(t *testing.T) {
	h := newHarness(t)
	srv := newTestServer(t, h)

	status, body := do(t, srv, http.MethodPost, "/api/v1/auth/login", "", loginRequest())
	require.Equal(t, http.StatusOK, status)

	lower := strings.ToLower(string(body))
	for _, needle := range forbiddenInResponse {
		require.NotContains(t, lower, needle)
	}
	require.NotContains(t, string(body), testPassword)
	require.NotContains(t, string(body), *h.user.PasswordHash)
	require.NotContains(t, string(body), "jdoe@example.com\",\"password")
}

func TestFullSessionGatesRejectLimitedTokens(t *testing.T) {
	h := newHarness(t, func(h *harness) {
		h.role.Name = "Administrator"
		h.repo.roles[h.role.ID] = h.role
	})
	srv := newTestServer(t, h)

	status, body := do(t, srv, http.MethodPost, "/api/v1/auth/login", "", loginRequest())
	require.Equal(t, http.StatusOK, status)

	var envelope struct{ Data dto.LoginResult }
	require.NoError(t, json.Unmarshal(body, &envelope))
	require.True(t, envelope.Data.RequiresTOTPSetup)
	limited := envelope.Data.AccessToken

	// The limited token may only reach the enrolment endpoints.
	status, body = do(t, srv, http.MethodGet, "/api/v1/me", limited, nil)
	require.Equal(t, http.StatusForbidden, status)
	require.Equal(t, "TOTP_SETUP_REQUIRED", apiErrorCode(t, body))

	status, _ = do(t, srv, http.MethodGet, "/api/v1/auth/sessions", limited, nil)
	require.Equal(t, http.StatusForbidden, status)

	status, _ = do(t, srv, http.MethodPost, "/api/v1/auth/2fa/setup", limited, nil)
	require.Equal(t, http.StatusOK, status)
}

func TestSessionEndpointsAreScopedToTheCaller(t *testing.T) {
	h := newHarness(t)
	srv := newTestServer(t, h)

	status, body := do(t, srv, http.MethodPost, "/api/v1/auth/login", "", loginRequest())
	require.Equal(t, http.StatusOK, status)
	var envelope struct{ Data dto.LoginResult }
	require.NoError(t, json.Unmarshal(body, &envelope))
	token := envelope.Data.AccessToken

	status, body = do(t, srv, http.MethodGet, "/api/v1/auth/sessions", token, nil)
	require.Equal(t, http.StatusOK, status)
	var list struct{ Data []dto.Session }
	require.NoError(t, json.Unmarshal(body, &list))
	require.Len(t, list.Data, 1)
	require.True(t, list.Data[0].Current)

	// A session id that is not ours answers 404, never 403.
	status, body = do(t, srv, http.MethodDelete, "/api/v1/auth/sessions/"+uuid.NewString(), token, nil)
	require.Equal(t, http.StatusNotFound, status)
	require.Equal(t, "NOT_FOUND", apiErrorCode(t, body))

	// A malformed id is a client error, not a lookup.
	status, _ = do(t, srv, http.MethodDelete, "/api/v1/auth/sessions/not-a-uuid", token, nil)
	require.GreaterOrEqual(t, status, http.StatusBadRequest)

	status, _ = do(t, srv, http.MethodDelete, "/api/v1/auth/sessions/"+envelope.Data.SessionID, token, nil)
	require.Equal(t, http.StatusNoContent, status)

	// The revoked session's access token is refused immediately afterwards.
	status, body = do(t, srv, http.MethodGet, "/api/v1/me", token, nil)
	require.Equal(t, http.StatusUnauthorized, status)
	require.Equal(t, "TOKEN_REVOKED", apiErrorCode(t, body))
}

func TestForgotPasswordAlwaysAnswers202(t *testing.T) {
	srv := newTestServer(t, newHarness(t))

	for _, login := range []string{"jdoe", "does-not-exist"} {
		status, _ := do(t, srv, http.MethodPost, "/api/v1/auth/password/forgot", "",
			dto.PasswordForgotRequest{Login: login})
		require.Equal(t, http.StatusAccepted, status,
			"the answer must be identical for known and unknown accounts")
	}
}

// /app/config is public and touches system_settings, so it needs a budget of
// its own: without one it is a free amplification target.
func TestAppConfigIsRateLimitedPerAddress(t *testing.T) {
	h := newHarness(t)
	srv := newTestServer(t, h)

	for i := 0; i < AppConfigPerIPPerMinute; i++ {
		status, _ := do(t, srv, http.MethodGet, "/api/v1/app/config", "", nil)
		require.Equal(t, http.StatusOK, status, "request %d must still pass", i+1)
	}

	status, body := do(t, srv, http.MethodGet, "/api/v1/app/config", "", nil)
	require.Equal(t, http.StatusTooManyRequests, status)
	require.Equal(t, apierr.CodeRateLimited, apiErrorCode(t, body))

	// The budget is not shared with the credential endpoints.
	status, _ = do(t, srv, http.MethodPost, "/api/v1/auth/login", "",
		map[string]any{"username": "jdoe", "password": testPassword, "device_type": "web"})
	require.NotEqual(t, http.StatusTooManyRequests, status)
}
