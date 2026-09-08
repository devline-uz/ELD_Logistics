package httpx_test

import (
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/httpx"
)

// resetTrustedProxies restores the fail-closed default after a test.
func resetTrustedProxies(t *testing.T) {
	t.Helper()
	t.Cleanup(func() { require.NoError(t, httpx.SetTrustedProxies(nil)) })
}

// Without a trusted proxy allowlist the forwarded headers are attacker
// controlled: believing them lets one client spread its login attempts over an
// unlimited number of rate limit buckets and forge the IP stored in audit_log.
func TestClientIPIgnoresForwardedHeadersFromUntrustedPeer(t *testing.T) {
	resetTrustedProxies(t)
	require.NoError(t, httpx.SetTrustedProxies(nil))

	r := httptest.NewRequest("POST", "/api/v1/auth/login", nil)
	r.RemoteAddr = "203.0.113.9:44321"
	r.Header.Set("X-Forwarded-For", "1.2.3.4")
	r.Header.Set("X-Real-IP", "5.6.7.8")

	require.Equal(t, "203.0.113.9", httpx.ClientIP(r))
}

// Even a configured proxy allowlist must not help a direct caller.
func TestClientIPIgnoresForwardedHeadersFromNonProxyPeer(t *testing.T) {
	resetTrustedProxies(t)
	require.NoError(t, httpx.SetTrustedProxies([]string{"10.0.0.0/8"}))

	r := httptest.NewRequest("POST", "/api/v1/auth/login", nil)
	r.RemoteAddr = "198.51.100.7:1234"
	r.Header.Set("X-Forwarded-For", "1.2.3.4")

	require.Equal(t, "198.51.100.7", httpx.ClientIP(r))
}

// Behind a declared load balancer the real client address is honoured.
func TestClientIPTrustsForwardedHeaderFromTrustedProxy(t *testing.T) {
	resetTrustedProxies(t)
	require.NoError(t, httpx.SetTrustedProxies([]string{"10.0.0.0/8"}))

	r := httptest.NewRequest("POST", "/api/v1/auth/login", nil)
	r.RemoteAddr = "10.1.2.3:5000"
	r.Header.Set("X-Forwarded-For", "203.0.113.5")

	require.Equal(t, "203.0.113.5", httpx.ClientIP(r))
}

// A client that prepends its own hops must not be able to hide behind them:
// the rightmost non-proxy entry is the address the edge actually saw.
func TestClientIPTakesRightmostUntrustedHop(t *testing.T) {
	resetTrustedProxies(t)
	require.NoError(t, httpx.SetTrustedProxies([]string{"10.0.0.0/8"}))

	r := httptest.NewRequest("POST", "/api/v1/auth/login", nil)
	r.RemoteAddr = "10.1.2.3:5000"
	r.Header.Set("X-Forwarded-For", "1.1.1.1, 2.2.2.2, 203.0.113.5, 10.0.0.9")

	require.Equal(t, "203.0.113.5", httpx.ClientIP(r))
}

// Two spoofing attempts from the same peer must land in the same bucket.
func TestClientIPIsStableAcrossSpoofAttempts(t *testing.T) {
	resetTrustedProxies(t)
	require.NoError(t, httpx.SetTrustedProxies(nil))

	seen := map[string]struct{}{}
	for _, forged := range []string{"1.1.1.1", "2.2.2.2", "3.3.3.3", "not-an-ip"} {
		r := httptest.NewRequest("POST", "/api/v1/auth/login", nil)
		r.RemoteAddr = "203.0.113.9:44321"
		r.Header.Set("X-Forwarded-For", forged)
		seen[httpx.ClientIP(r)] = struct{}{}
	}
	require.Len(t, seen, 1, "a forged header must not create a second rate limit bucket")
}

func TestSetTrustedProxiesRejectsGarbage(t *testing.T) {
	resetTrustedProxies(t)
	require.Error(t, httpx.SetTrustedProxies([]string{"not-a-cidr"}))
	require.Error(t, httpx.SetTrustedProxies([]string{"10.0.0.0/99"}))
	require.NoError(t, httpx.SetTrustedProxies([]string{"10.0.0.1", " 192.168.0.0/16 ", ""}))
}
