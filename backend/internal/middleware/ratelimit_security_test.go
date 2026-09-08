package middleware

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

func loginRequestFrom(ip string) *http.Request {
	r := httptest.NewRequest(http.MethodPost, "/api/v1/auth/login", strings.NewReader(`{}`))
	r.RemoteAddr = ip + ":51000"
	return r
}

func TestLoginRateLimitIsFivePerMinutePerIP(t *testing.T) {
	store := cache.NewMemoryStore()
	h := LoginRateLimit(store, 0)(okHandler())

	for i := 0; i < LoginPerIPPerMinute; i++ {
		w := httptest.NewRecorder()
		h.ServeHTTP(w, loginRequestFrom("203.0.113.9"))
		require.Equal(t, http.StatusOK, w.Code, "attempt %d must pass", i+1)
	}

	w := httptest.NewRecorder()
	h.ServeHTTP(w, loginRequestFrom("203.0.113.9"))
	require.Equal(t, http.StatusTooManyRequests, w.Code)
	require.Equal(t, apierr.CodeRateLimited, errorCode(t, w.Body.Bytes()))
	require.NotEmpty(t, w.Header().Get("Retry-After"), "429 must carry Retry-After")

	// Another address has its own budget.
	w = httptest.NewRecorder()
	h.ServeHTTP(w, loginRequestFrom("198.51.100.2"))
	require.Equal(t, http.StatusOK, w.Code)
}

func TestRateLimitWindowIsFixedAndResets(t *testing.T) {
	store := cache.NewMemoryStore()
	now := time.Now()
	store.SetClock(func() time.Time { return now })
	h := LoginRateLimit(store, 0)(okHandler())

	for i := 0; i < LoginPerIPPerMinute+1; i++ {
		h.ServeHTTP(httptest.NewRecorder(), loginRequestFrom("203.0.113.9"))
	}
	w := httptest.NewRecorder()
	h.ServeHTTP(w, loginRequestFrom("203.0.113.9"))
	require.Equal(t, http.StatusTooManyRequests, w.Code)

	now = now.Add(2 * time.Minute)
	w = httptest.NewRecorder()
	h.ServeHTTP(w, loginRequestFrom("203.0.113.9"))
	require.Equal(t, http.StatusOK, w.Code)
}

func TestUserRateLimitBucketsByPrincipal(t *testing.T) {
	store := cache.NewMemoryStore()
	h := UserRateLimit(store, 2)(okHandler())

	a := fleetPrincipal("units.read")
	b := fleetPrincipal("units.read")

	for i := 0; i < 2; i++ {
		w := httptest.NewRecorder()
		h.ServeHTTP(w, requestWith(a))
		require.Equal(t, http.StatusOK, w.Code)
	}
	w := httptest.NewRecorder()
	h.ServeHTTP(w, requestWith(a))
	require.Equal(t, http.StatusTooManyRequests, w.Code)

	// A second user is unaffected: the budget is per user, not global.
	w = httptest.NewRecorder()
	h.ServeHTTP(w, requestWith(b))
	require.Equal(t, http.StatusOK, w.Code)
}

func TestSyncRateLimitBucketsByDevice(t *testing.T) {
	store := cache.NewMemoryStore()
	h := RateLimit(store, RateLimitOptions{
		Name: "sync", Limit: 2, Window: time.Minute, Key: KeyByDevice,
	})(okHandler())

	p := fleetPrincipal("units.read")
	for i := 0; i < 2; i++ {
		h.ServeHTTP(httptest.NewRecorder(), requestWith(p))
	}
	w := httptest.NewRecorder()
	h.ServeHTTP(w, requestWith(p))
	require.Equal(t, http.StatusTooManyRequests, w.Code)

	// The same user on another device keeps its own budget.
	other := *p
	other.SessionID = uuid.New()
	w = httptest.NewRecorder()
	h.ServeHTTP(w, requestWith(&other))
	require.Equal(t, http.StatusOK, w.Code)
}

func TestRateLimitFailsOpenWithoutStore(t *testing.T) {
	h := LoginRateLimit(nil, 0)(okHandler())
	for i := 0; i < 20; i++ {
		w := httptest.NewRecorder()
		h.ServeHTTP(w, loginRequestFrom("203.0.113.9"))
		require.Equal(t, http.StatusOK, w.Code)
	}
}

func TestIdempotencyReplaysTheRecordedResponse(t *testing.T) {
	store := cache.NewMemoryStore()
	calls := 0
	h := Idempotency(store, false)(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		calls++
		w.WriteHeader(http.StatusCreated)
		_, _ = w.Write([]byte(`{"data":{"id":"1"}}`))
	}))

	p := fleetPrincipal("units.create")
	send := func() *httptest.ResponseRecorder {
		r := httptest.NewRequest(http.MethodPost, "/api/v1/units", strings.NewReader(`{}`))
		r = r.WithContext(tenant.WithPrincipal(r.Context(), p))
		r.Header.Set(HeaderIdempotencyKey, "key-1")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		return w
	}

	first := send()
	require.Equal(t, http.StatusCreated, first.Code)
	second := send()
	require.Equal(t, http.StatusCreated, second.Code)
	require.Equal(t, first.Body.String(), second.Body.String())
	require.Equal(t, "true", second.Header().Get("Idempotent-Replay"))
	require.Equal(t, 1, calls, "the handler must run once per Idempotency-Key")
}

func TestIdempotencyKeysAreScopedPerUser(t *testing.T) {
	store := cache.NewMemoryStore()
	h := Idempotency(store, false)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p, _ := tenant.PrincipalFrom(r.Context())
		w.WriteHeader(http.StatusCreated)
		_, _ = w.Write([]byte(`{"user":"` + p.UserID.String() + `"}`))
	}))

	send := func(p *tenant.Principal) *httptest.ResponseRecorder {
		r := httptest.NewRequest(http.MethodPost, "/api/v1/units", strings.NewReader(`{}`))
		r = r.WithContext(tenant.WithPrincipal(r.Context(), p))
		r.Header.Set(HeaderIdempotencyKey, "shared-key")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		return w
	}

	a := fleetPrincipal("units.create")
	b := fleetPrincipal("units.create")
	require.Contains(t, send(a).Body.String(), a.UserID.String())
	require.Contains(t, send(b).Body.String(), b.UserID.String(),
		"one tenant must never replay another tenant's recorded response")
}

func TestIdempotencyDoesNotCacheFailures(t *testing.T) {
	store := cache.NewMemoryStore()
	calls := 0
	h := Idempotency(store, false)(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		calls++
		w.WriteHeader(http.StatusUnprocessableEntity)
		_, _ = w.Write([]byte(`{"error":{"code":"VALIDATION_ERROR"}}`))
	}))

	p := fleetPrincipal("units.create")
	for i := 0; i < 2; i++ {
		r := httptest.NewRequest(http.MethodPost, "/api/v1/units", strings.NewReader(`{}`))
		r = r.WithContext(tenant.WithPrincipal(r.Context(), p))
		r.Header.Set(HeaderIdempotencyKey, "key-2")
		h.ServeHTTP(httptest.NewRecorder(), r)
	}
	require.Equal(t, 2, calls, "a failed request must stay retryable with the same key")
}

func TestIdempotencyKeyCanBeMandatoryAndIsLengthBounded(t *testing.T) {
	store := cache.NewMemoryStore()
	h := Idempotency(store, true)(okHandler())

	r := httptest.NewRequest(http.MethodPost, "/api/v1/sync/push", strings.NewReader(`{}`))
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	require.Equal(t, http.StatusBadRequest, w.Code)

	r = httptest.NewRequest(http.MethodPost, "/api/v1/sync/push", strings.NewReader(`{}`))
	r.Header.Set(HeaderIdempotencyKey, strings.Repeat("k", 200))
	w = httptest.NewRecorder()
	h.ServeHTTP(w, r)
	require.Equal(t, http.StatusBadRequest, w.Code)
}

func TestBodyLimitRejectsOversizedRequests(t *testing.T) {
	h := BodyLimit(16)(okHandler())
	r := httptest.NewRequest(http.MethodPost, "/api/v1/units", strings.NewReader(strings.Repeat("a", 64)))
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	require.Equal(t, http.StatusRequestEntityTooLarge, w.Code)
	require.Equal(t, apierr.CodePayloadTooLarge, errorCode(t, w.Body.Bytes()))
}

func TestSecurityHeadersArePresent(t *testing.T) {
	w := httptest.NewRecorder()
	SecurityHeaders(okHandler()).ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/health", nil))
	require.Equal(t, "nosniff", w.Header().Get("X-Content-Type-Options"))
	require.Equal(t, "DENY", w.Header().Get("X-Frame-Options"))
	require.Equal(t, "no-referrer", w.Header().Get("Referrer-Policy"))
}

// A spoofed X-Forwarded-For must not buy a fresh login budget: without a
// configured reverse proxy allowlist the transport address is authoritative,
// otherwise brute forcing one account only costs one extra header per attempt.
func TestLoginRateLimitCannotBeBypassedWithForwardedFor(t *testing.T) {
	require.NoError(t, httpx.SetTrustedProxies(nil))
	t.Cleanup(func() { require.NoError(t, httpx.SetTrustedProxies(nil)) })

	store := cache.NewMemoryStore()
	h := LoginRateLimit(store, 0)(okHandler())

	for i := 0; i < LoginPerIPPerMinute; i++ {
		w := httptest.NewRecorder()
		h.ServeHTTP(w, loginRequestFrom("203.0.113.9"))
		require.Equal(t, http.StatusOK, w.Code, "attempt %d must pass", i+1)
	}

	for i := 0; i < 10; i++ {
		r := loginRequestFrom("203.0.113.9")
		r.Header.Set("X-Forwarded-For", fmt.Sprintf("198.51.100.%d", i))
		r.Header.Set("X-Real-IP", fmt.Sprintf("198.51.100.%d", i+100))
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		require.Equal(t, http.StatusTooManyRequests, w.Code,
			"a forged forwarded-for header must not reset the per IP budget")
	}
}

// Behind a declared load balancer the per client budget must still work: the
// peer is the proxy, so every client would otherwise share one bucket.
func TestLoginRateLimitUsesForwardedForBehindTrustedProxy(t *testing.T) {
	require.NoError(t, httpx.SetTrustedProxies([]string{"10.0.0.0/8"}))
	t.Cleanup(func() { require.NoError(t, httpx.SetTrustedProxies(nil)) })

	store := cache.NewMemoryStore()
	h := LoginRateLimit(store, 0)(okHandler())

	send := func(client string) int {
		r := httptest.NewRequest(http.MethodPost, "/api/v1/auth/login", strings.NewReader(`{}`))
		r.RemoteAddr = "10.4.5.6:40000"
		r.Header.Set("X-Forwarded-For", client)
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		return w.Code
	}

	for i := 0; i < LoginPerIPPerMinute; i++ {
		require.Equal(t, http.StatusOK, send("203.0.113.5"))
	}
	require.Equal(t, http.StatusTooManyRequests, send("203.0.113.5"))
	require.Equal(t, http.StatusOK, send("203.0.113.6"), "a different client keeps its own budget")
}
