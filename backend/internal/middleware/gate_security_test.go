package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
)

func gateRequest(remote, authHeader string) *http.Request {
	r := httptest.NewRequest(http.MethodGet, "/metrics", nil)
	r.RemoteAddr = remote
	if authHeader != "" {
		r.Header.Set("Authorization", authHeader)
	}
	return r
}

func serveGate(opts GateOptions, r *http.Request) *httptest.ResponseRecorder {
	w := httptest.NewRecorder()
	Gate(opts)(okHandler()).ServeHTTP(w, r)
	return w
}

// A disabled surface must not even confirm that it exists.
func TestGateDisabledIsNotFound(t *testing.T) {
	w := serveGate(GateOptions{Name: "metrics", Enabled: false, Token: "t"},
		gateRequest("10.0.0.5:1234", "Bearer t"))
	require.Equal(t, http.StatusNotFound, w.Code)
	require.Equal(t, apierr.CodeNotFound, errorCode(t, w.Body.Bytes()))
}

func TestGateRequiresTheConfiguredToken(t *testing.T) {
	opts := GateOptions{Name: "metrics", Enabled: true, Token: "s3cret-metrics-token"}

	// No credential at all.
	w := serveGate(opts, gateRequest("198.51.100.7:5000", ""))
	require.Equal(t, http.StatusUnauthorized, w.Code)
	require.Contains(t, w.Header().Get("WWW-Authenticate"), "metrics")

	// Wrong credential, including a prefix of the real one.
	for _, bad := range []string{"Bearer wrong", "Bearer s3cret", "Bearer s3cret-metrics-tokenX", "Basic dXNlcjpwYXNz"} {
		badRec := serveGate(opts, gateRequest("198.51.100.7:5000", bad))
		require.Equal(t, http.StatusUnauthorized, badRec.Code, bad)
	}

	// The exact token passes.
	w = serveGate(opts, gateRequest("198.51.100.7:5000", "Bearer s3cret-metrics-token"))
	require.Equal(t, http.StatusOK, w.Code)
}

// The token must never be accepted from the query string: it would end up in
// access logs and referrers.
func TestGateIgnoresATokenInTheQueryString(t *testing.T) {
	r := httptest.NewRequest(http.MethodGet, "/metrics?token=s3cret-metrics-token", nil)
	r.RemoteAddr = "198.51.100.7:5000"
	w := serveGate(GateOptions{Name: "metrics", Enabled: true, Token: "s3cret-metrics-token"}, r)
	require.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestGateAllowsListedSourceNetworks(t *testing.T) {
	opts := GateOptions{Name: "metrics", Enabled: true, AllowCIDR: []string{"10.0.0.0/8", "192.168.1.10"}}

	require.Equal(t, http.StatusOK, serveGate(opts, gateRequest("10.4.2.1:9000", "")).Code)
	require.Equal(t, http.StatusOK, serveGate(opts, gateRequest("192.168.1.10:9000", "")).Code)
	// Outside the allowlist and no token configured: closed.
	require.Equal(t, http.StatusNotFound, serveGate(opts, gateRequest("203.0.113.5:9000", "")).Code)
	require.Equal(t, http.StatusNotFound, serveGate(opts, gateRequest("192.168.1.11:9000", "")).Code)
}

// Without any credential the surface is reachable only when the deployment is
// explicitly a development one (config.Validate enforces the rest).
func TestGateOpenOnlyInDevelopment(t *testing.T) {
	dev := GateOptions{Name: "metrics", Enabled: true, Open: true}
	require.Equal(t, http.StatusOK, serveGate(dev, gateRequest("203.0.113.5:9000", "")).Code)

	prod := GateOptions{Name: "metrics", Enabled: true, Open: false}
	require.Equal(t, http.StatusNotFound, serveGate(prod, gateRequest("203.0.113.5:9000", "")).Code)
}

// A configured token wins over Open: a guarded surface is guarded everywhere.
func TestGateTokenBeatsOpen(t *testing.T) {
	opts := GateOptions{Name: "docs", Enabled: true, Token: "t0ken", Open: true}
	require.Equal(t, http.StatusUnauthorized, serveGate(opts, gateRequest("203.0.113.5:9000", "")).Code)
	require.Equal(t, http.StatusOK, serveGate(opts, gateRequest("203.0.113.5:9000", "Bearer t0ken")).Code)
}
