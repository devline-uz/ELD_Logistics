package testutil

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/config"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/server"
	"github.com/devline/onebook-eld/internal/tenant"
)

// TestServer wraps httptest.Server with tenant aware request helpers. It never
// mints real JWTs: AsPrincipal registers a *tenant.Principal under an opaque
// token and the harness puts it straight on the request context, so tests do
// not depend on internal/auth.
type TestServer struct {
	t      testing.TB
	srv    *httptest.Server
	reg    *principalRegistry
	token  string
	client *http.Client

	// URL is the base URL of the running test server.
	URL string
}

type principalRegistry struct {
	mu sync.RWMutex
	m  map[string]*tenant.Principal
}

func newPrincipalRegistry() *principalRegistry {
	return &principalRegistry{m: make(map[string]*tenant.Principal)}
}

func (r *principalRegistry) add(p *tenant.Principal) string {
	token := "test-" + uuid.NewString()
	r.mu.Lock()
	r.m[token] = p
	r.mu.Unlock()
	return token
}

func (r *principalRegistry) get(token string) (*tenant.Principal, bool) {
	r.mu.RLock()
	p, ok := r.m[token]
	r.mu.RUnlock()
	return p, ok
}

// NewServer builds the real router (global middleware included) with the given
// domain modules and starts it on a random port.
func NewServer(t testing.TB, mods ...server.Module) *TestServer {
	t.Helper()
	return NewServerWith(t, TestConfig(), server.Deps{}, mods...)
}

// NewServerWith is NewServer with explicit config and dependencies. Logger and
// Verifier are filled in when left zero.
func NewServerWith(t testing.TB, cfg *config.Config, deps server.Deps, mods ...server.Module) *TestServer {
	t.Helper()
	if cfg == nil {
		cfg = TestConfig()
	}
	if deps.Logger == nil {
		deps.Logger = Logger()
	}
	if deps.Version == "" {
		deps.Version = "test"
	}

	reg := newPrincipalRegistry()
	if deps.Verifier == nil {
		deps.Verifier = mw.VerifierFunc(func(_ context.Context, token string) (*tenant.Principal, error) {
			p, ok := reg.get(token)
			if !ok {
				return nil, errUnknownTestToken()
			}
			return p, nil
		})
	}

	handler := injectPrincipal(reg)(server.NewRouter(cfg, deps, mods...))
	srv := httptest.NewServer(handler)
	t.Cleanup(srv.Close)

	return &TestServer{
		t:      t,
		srv:    srv,
		reg:    reg,
		client: &http.Client{Timeout: 30 * time.Second},
		URL:    srv.URL,
	}
}

// injectPrincipal puts the registered principal on the context before the
// router runs, so modules that do not mount mw.Authenticate still see it.
func injectPrincipal(reg *principalRegistry) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			raw := r.Header.Get("Authorization")
			if token, ok := strings.CutPrefix(raw, "Bearer "); ok {
				if p, found := reg.get(strings.TrimSpace(token)); found {
					r = r.WithContext(tenant.WithPrincipal(r.Context(), p))
				}
			}
			next.ServeHTTP(w, r)
		})
	}
}

// AsPrincipal returns a view of the same server whose requests carry p. The
// zero/nil principal produces an anonymous client (expects 401).
func (s *TestServer) AsPrincipal(p *tenant.Principal) *TestServer {
	clone := *s
	if p == nil {
		clone.token = ""
		return &clone
	}
	clone.token = s.reg.add(p)
	return &clone
}

// AsTenant is AsPrincipal(tn.Principal()).
func (s *TestServer) AsTenant(tn *Tenant) *TestServer { return s.AsPrincipal(tn.Principal()) }

// Anonymous returns a client without credentials.
func (s *TestServer) Anonymous() *TestServer { return s.AsPrincipal(nil) }

// RequestOption mutates the outgoing request.
type RequestOption func(*http.Request)

// Header sets a request header.
func Header(key, value string) RequestOption {
	return func(r *http.Request) { r.Header.Set(key, value) }
}

// Query appends a query parameter.
func Query(key, value string) RequestOption {
	return func(r *http.Request) {
		q := r.URL.Query()
		q.Add(key, value)
		r.URL.RawQuery = q.Encode()
	}
}

// BearerToken overrides the Authorization header (for 401 tests).
func BearerToken(token string) RequestOption {
	return func(r *http.Request) { r.Header.Set("Authorization", "Bearer "+token) }
}

// Response is a captured HTTP response.
type Response struct {
	t      testing.TB
	Code   int
	Header http.Header
	Body   []byte
}

// Do performs a request against the test server. body may be nil, []byte,
// string or any JSON marshalable value.
func (s *TestServer) Do(method, path string, body any, opts ...RequestOption) *Response {
	s.t.Helper()

	var reader io.Reader
	isJSON := false
	switch v := body.(type) {
	case nil:
	case []byte:
		reader = bytes.NewReader(v)
	case string:
		reader = strings.NewReader(v)
	default:
		buf, err := json.Marshal(v)
		require.NoError(s.t, err, "marshal request body")
		reader = bytes.NewReader(buf)
		isJSON = true
	}

	u, err := url.Parse(s.URL + path)
	require.NoError(s.t, err, "parse path %q", path)

	req, err := http.NewRequest(method, u.String(), reader)
	require.NoError(s.t, err, "build request")
	if isJSON {
		req.Header.Set("Content-Type", "application/json")
	}
	req.Header.Set("Accept", "application/json")
	if s.token != "" {
		req.Header.Set("Authorization", "Bearer "+s.token)
	}
	for _, o := range opts {
		if o != nil {
			o(req)
		}
	}

	resp, err := s.client.Do(req)
	require.NoError(s.t, err, "%s %s", method, path)
	defer func() { _ = resp.Body.Close() }()

	raw, err := io.ReadAll(resp.Body)
	require.NoError(s.t, err, "read response body")

	return &Response{t: s.t, Code: resp.StatusCode, Header: resp.Header, Body: raw}
}

// Convenience verbs.
func (s *TestServer) Get(path string, opts ...RequestOption) *Response {
	s.t.Helper()
	return s.Do(http.MethodGet, path, nil, opts...)
}

func (s *TestServer) Post(path string, body any, opts ...RequestOption) *Response {
	s.t.Helper()
	return s.Do(http.MethodPost, path, body, opts...)
}

func (s *TestServer) Put(path string, body any, opts ...RequestOption) *Response {
	s.t.Helper()
	return s.Do(http.MethodPut, path, body, opts...)
}

func (s *TestServer) Patch(path string, body any, opts ...RequestOption) *Response {
	s.t.Helper()
	return s.Do(http.MethodPatch, path, body, opts...)
}

func (s *TestServer) Delete(path string, opts ...RequestOption) *Response {
	s.t.Helper()
	return s.Do(http.MethodDelete, path, nil, opts...)
}

// JSON decodes the response body into v.
func (r *Response) JSON(v any) {
	r.t.Helper()
	require.NoError(r.t, json.Unmarshal(r.Body, v), "decode response: %s", r.String())
}

// ErrorCode returns error.code from the canonical error envelope, or "".
func (r *Response) ErrorCode() string {
	var env struct {
		Error struct {
			Code string `json:"code"`
		} `json:"error"`
	}
	if err := json.Unmarshal(r.Body, &env); err != nil {
		return ""
	}
	return env.Error.Code
}

// ErrorMessage returns error.message from the canonical error envelope, or "".
func (r *Response) ErrorMessage() string {
	var env struct {
		Error struct {
			Message string `json:"message"`
		} `json:"error"`
	}
	if err := json.Unmarshal(r.Body, &env); err != nil {
		return ""
	}
	return env.Error.Message
}

// String renders the response for assertion messages.
func (r *Response) String() string { return string(r.Body) }

// errUnknownTestToken mirrors what internal/auth returns for a bad token.
func errUnknownTestToken() error {
	return apierr.Unauthorized("unknown test token")
}

// ContextVerifier is the AuthVerifier a module under test wires into its Deps
// when the module mounts mw.Authenticate itself. injectPrincipal has already
// put the registered principal on the context, so the verifier only has to
// hand it back and the real chain (Authenticate -> RequireFullSession ->
// RequireCompany -> Scope -> RequirePermission) runs end to end.
func ContextVerifier() mw.AuthVerifier {
	return mw.VerifierFunc(func(ctx context.Context, _ string) (*tenant.Principal, error) {
		p, ok := tenant.PrincipalFrom(ctx)
		if !ok {
			return nil, errUnknownTestToken()
		}
		return p, nil
	})
}
