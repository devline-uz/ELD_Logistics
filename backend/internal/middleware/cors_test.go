package middleware

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

// TestDefaultCORSAllowsTheHeadersClientsActuallySend guards the regression that
// made the admin panel unusable from a browser: the preflight allowlist carried
// "X-Idempotency-Key" while every mutating request sends "Idempotency-Key"
// (HeaderIdempotencyKey, and the documented swagger parameter), so browsers
// dropped the request after a successful preflight.
func TestDefaultCORSAllowsTheHeadersClientsActuallySend(t *testing.T) {
	opts := DefaultCORS([]string{"https://eldadmin.example"}, false)

	allowed := make(map[string]bool, len(opts.AllowedHeaders))
	for _, h := range opts.AllowedHeaders {
		allowed[http.CanonicalHeaderKey(h)] = true
	}

	for _, want := range []string{
		"Authorization", "Content-Type", "Accept",
		HeaderRequestID, HeaderIdempotencyKey, HeaderCompanyID,
	} {
		if !allowed[http.CanonicalHeaderKey(want)] {
			t.Errorf("DefaultCORS does not allow %q; clients send it and browsers would block the request", want)
		}
	}
}

func TestCORSPreflightEchoesAllowedHeaders(t *testing.T) {
	const origin = "https://eldadmin.example"
	handler := CORS(DefaultCORS([]string{origin}, false))(
		http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusOK) }),
	)

	req := httptest.NewRequest(http.MethodOptions, "/api/v1/auth/login", nil)
	req.Header.Set("Origin", origin)
	req.Header.Set("Access-Control-Request-Method", http.MethodPost)
	req.Header.Set("Access-Control-Request-Headers", "content-type, "+HeaderIdempotencyKey)

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusNoContent {
		t.Fatalf("preflight status = %d, want %d", rec.Code, http.StatusNoContent)
	}
	got := rec.Header().Get("Access-Control-Allow-Headers")
	if !strings.Contains(strings.ToLower(got), strings.ToLower(HeaderIdempotencyKey)) {
		t.Errorf("Access-Control-Allow-Headers = %q, missing %q", got, HeaderIdempotencyKey)
	}
	if !strings.Contains(strings.ToLower(got), strings.ToLower(HeaderCompanyID)) {
		t.Errorf("Access-Control-Allow-Headers = %q, missing %q", got, HeaderCompanyID)
	}
}
