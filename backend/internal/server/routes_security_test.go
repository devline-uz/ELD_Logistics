package server

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/config"
)

func testRouter(t *testing.T, mutate func(*config.Config)) http.Handler {
	t.Helper()
	cfg := &config.Config{
		AppEnv:           config.EnvProd,
		Region:           "us-east-1",
		DatabaseURL:      "postgres://u:p@localhost:5432/db",
		JWTSecret:        "0123456789abcdef0123456789abcdef",
		EncryptionKey:    "0123456789abcdef0123456789abcdef",
		AccessTokenTTL:   15 * time.Minute,
		RefreshTTLDriver: 720 * time.Hour,
		RefreshTTLAdmin:  168 * time.Hour,
		CORSOrigins:      []string{"https://app.example.com"},
		Metrics:          config.ExposureConfig{Enabled: true},
		Docs:             config.ExposureConfig{Enabled: true},
	}
	if mutate != nil {
		mutate(cfg)
	}
	return NewRouter(cfg, Deps{Version: "test"})
}

func get(h http.Handler, path, auth string) *httptest.ResponseRecorder {
	r := httptest.NewRequest(http.MethodGet, path, nil)
	r.RemoteAddr = "203.0.113.9:4242"
	if auth != "" {
		r.Header.Set("Authorization", auth)
	}
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	return w
}

// /metrics exposes the endpoint catalogue, the traffic volume and the Go
// runtime; in production it must not answer without a credential.
func TestMetricsRequiresATokenInProduction(t *testing.T) {
	h := testRouter(t, func(c *config.Config) { c.Metrics.Token = "metrics-t0ken" })

	require.Equal(t, http.StatusUnauthorized, get(h, "/metrics", "").Code)
	require.Equal(t, http.StatusUnauthorized, get(h, "/metrics", "Bearer nope").Code)

	ok := get(h, "/metrics", "Bearer metrics-t0ken")
	require.Equal(t, http.StatusOK, ok.Code)
	require.Contains(t, ok.Body.String(), "go_goroutines")
}

func TestMetricsCanBeTurnedOff(t *testing.T) {
	h := testRouter(t, func(c *config.Config) {
		c.Metrics.Enabled = false
		c.Metrics.Token = "metrics-t0ken"
	})
	// Even with the right token: disabled is disabled, and it answers 404.
	require.Equal(t, http.StatusNotFound, get(h, "/metrics", "Bearer metrics-t0ken").Code)
}

func TestMetricsAllowsScrapersByAddress(t *testing.T) {
	h := testRouter(t, func(c *config.Config) { c.Metrics.AllowCIDR = []string{"203.0.113.0/24"} })
	require.Equal(t, http.StatusOK, get(h, "/metrics", "").Code)

	closed := testRouter(t, func(c *config.Config) { c.Metrics.AllowCIDR = []string{"10.0.0.0/8"} })
	require.Equal(t, http.StatusNotFound, get(closed, "/metrics", "").Code)
}

// The swagger UI and the raw spec describe every endpoint and every payload.
func TestDocsAreGatedInProduction(t *testing.T) {
	h := testRouter(t, func(c *config.Config) { c.Docs.Token = "docs-t0ken" })

	for _, path := range []string{"/api/docs/swagger.json", "/api/docs/index.html", "/api/docs/"} {
		require.Equal(t, http.StatusUnauthorized, get(h, path, "").Code, path)
		require.NotEqual(t, http.StatusUnauthorized, get(h, path, "Bearer docs-t0ken").Code, path)
	}

	off := testRouter(t, func(c *config.Config) { c.Docs.Enabled = false })
	require.Equal(t, http.StatusNotFound, get(off, "/api/docs/swagger.json", "").Code)
}

// Development keeps both surfaces reachable so the local workflow is unchanged.
func TestInfraSurfacesStayOpenLocally(t *testing.T) {
	h := testRouter(t, func(c *config.Config) {
		c.AppEnv = config.EnvLocal
		c.CORSOrigins = nil
	})
	require.Equal(t, http.StatusOK, get(h, "/metrics", "").Code)
	require.Equal(t, http.StatusOK, get(h, "/api/docs/swagger.json", "").Code)
}

// The liveness and readiness probes are not credentials protected: an
// orchestrator has to reach them, and they carry no internal detail.
func TestProbesRemainOpen(t *testing.T) {
	h := testRouter(t, func(c *config.Config) {
		c.Metrics.Token = "metrics-t0ken"
		c.Docs.Enabled = false
	})
	require.Equal(t, http.StatusOK, get(h, "/health", "").Code)
	require.Equal(t, http.StatusOK, get(h, "/ready", "").Code)
}
