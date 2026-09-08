//go:build integration

// Package main's integration tests build the exact router main.go serves:
// buildSecurity + buildModules + server.NewRouter, unmodified. That is the
// only way to cover every registered route with the real x-permission gates
// without duplicating ~300 lines of wiring in a test-only package (TZ
// 9-bosqich 3-qism: permission matrix + HTTP contract coverage).
package main

import (
	"testing"

	"github.com/hibiken/asynq"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/server"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
	"github.com/devline/onebook-eld/internal/ws"
)

// TestMain owns the shared containers for this package.
func TestMain(m *testing.M) { testutil.RunMain(m) }

// fullApp is the real HTTP surface (every domain module, real permission
// gates, real RLS backed repositories) fronted by testutil's request client.
// It never mints a token itself: callers use issue() to sign a real access
// token for whatever principal the test needs, exactly like a completed
// login would.
type fullApp struct {
	*testutil.TestServer
	sec security
}

// newFullApp wires the production router against the shared test database.
// Redis backed infrastructure (cache, pub/sub fan-out, the asynq queue) is
// swapped for in-process/local equivalents: contract and permission-matrix
// tests exercise HTTP status codes and RLS, not cross-node delivery.
func newFullApp(t testing.TB) *fullApp {
	t.Helper()

	pool := testutil.NewDB(t)
	cfg := testutil.TestConfig()
	cfg.RedisURL = testutil.StartRedis(t)
	log := testutil.Logger()
	store := cache.NewMemoryStore()

	sec, err := buildSecurity(cfg, pool, store, log)
	require.NoError(t, err, "build security")

	hub := ws.NewHub(log)
	t.Cleanup(hub.Close)
	// A nil redis client keeps the bridge local-hub-only (see ws.NewBridge):
	// exactly what a single node HTTP test needs, no pub/sub required.
	bridge := ws.NewBridge(nil, hub, log)

	redisOpt, err := asynq.ParseRedisURI(cfg.RedisURL)
	require.NoError(t, err, "parse redis uri")
	asynqClient := asynq.NewClient(redisOpt)
	t.Cleanup(func() { _ = asynqClient.Close() })

	mods := buildModules(cfg, pool, store, sec, hub, bridge, asynqClient, log)

	ts := testutil.NewServerWith(t, cfg, server.Deps{Logger: log, Version: "test"}, mods...)
	return &fullApp{TestServer: ts, sec: sec}
}

// issue mints a real, signed access token for p — the same TokenService.Issue
// call a successful /auth/login performs. Permissions are resolved from
// role_permissions live, at verification time, not baked into the token.
func (a *fullApp) issue(t testing.TB, p *tenant.Principal) string {
	t.Helper()
	tok, _, err := a.sec.tokens.Issue(p)
	require.NoError(t, err, "issue access token")
	return tok
}

// bearer is a convenience RequestOption chaining issue().
func (a *fullApp) bearer(t testing.TB, p *tenant.Principal) testutil.RequestOption {
	t.Helper()
	return testutil.BearerToken(a.issue(t, p))
}
