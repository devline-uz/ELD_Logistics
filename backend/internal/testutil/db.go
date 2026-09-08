package testutil

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/config"
	"github.com/devline/onebook-eld/internal/db"
)

var (
	appPoolOnce sync.Once
	appPoolVal  *db.Pool
	appPoolErr  error

	adminPoolOnce sync.Once
	adminPoolVal  *pgxpool.Pool
	adminPoolErr  error
)

// Logger returns a slog logger that discards everything; tests stay quiet.
func Logger() *slog.Logger {
	return slog.New(slog.NewJSONHandler(io.Discard, &slog.HandlerOptions{Level: slog.LevelError}))
}

// TestConfig returns a valid config for tests. DatabaseURL/RedisURL are left to
// the caller because they only exist once the containers are up.
func TestConfig() *config.Config {
	return &config.Config{
		AppEnv:           config.EnvLocal,
		Region:           "us-east-1",
		HTTPAddr:         ":0",
		PublicBaseURL:    "http://127.0.0.1",
		LogLevel:         "error",
		JWTSecret:        strings.Repeat("t", 32),
		EncryptionKey:    strings.Repeat("k", 32),
		AccessTokenTTL:   15 * time.Minute,
		RefreshTTLDriver: 720 * time.Hour,
		RefreshTTLAdmin:  168 * time.Hour,
	}
}

// NewDB returns the shared application pool, connected as the NOSUPERUSER /
// NOBYPASSRLS eld_app role. Tests isolate themselves by company_id (see the
// fixture builders), not by schema, so the pool is shared and must not be
// closed by callers; RunMain/Shutdown owns its lifetime.
func NewDB(t testing.TB) *db.Pool {
	t.Helper()
	dsn := AppDSN(t)

	appPoolOnce.Do(func() {
		cfg := TestConfig()
		cfg.DatabaseURL = dsn
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		appPoolVal, appPoolErr = db.Open(ctx, cfg, Logger())
	})
	require.NoError(t, appPoolErr, "open application pool")
	return appPoolVal
}

// AdminPool returns the shared superuser pool. Fixtures use it so seeding is
// never blocked by RLS; assertions about RLS must use NewDB instead.
func AdminPool(t testing.TB) *pgxpool.Pool {
	t.Helper()
	dsn := StartPostgres(t)

	adminPoolOnce.Do(func() {
		cfg, err := pgxpool.ParseConfig(dsn)
		if err != nil {
			adminPoolErr = err
			return
		}
		cfg.MaxConns = 10
		cfg.ConnConfig.RuntimeParams["timezone"] = "UTC"
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		adminPoolVal, adminPoolErr = pgxpool.NewWithConfig(ctx, cfg)
	})
	require.NoError(t, adminPoolErr, "open admin pool")
	return adminPoolVal
}

// Ctx returns a context bound to the test deadline.
func Ctx(t testing.TB) context.Context {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	t.Cleanup(cancel)
	return ctx
}

// Truncate empties the given tables through the superuser pool. Prefer per
// company isolation; this is only for tests that must start from an empty
// table. audit_log cannot be truncated (append-only trigger).
func Truncate(t testing.TB, tables ...string) {
	t.Helper()
	if len(tables) == 0 {
		return
	}
	for _, name := range tables {
		require.True(t, safeIdent(name), "unsafe table name %q", name)
	}
	stmt := fmt.Sprintf("TRUNCATE TABLE %s RESTART IDENTITY CASCADE", strings.Join(tables, ", "))
	_, err := AdminPool(t).Exec(Ctx(t), stmt)
	require.NoError(t, err, "truncate %v", tables)
}

// CountIn returns the row count of table for companyID, read through the
// superuser pool (i.e. ignoring RLS).
func CountIn(t testing.TB, table string, companyID any) int {
	t.Helper()
	require.True(t, safeIdent(table), "unsafe table name %q", table)
	var n int
	err := AdminPool(t).
		QueryRow(Ctx(t), fmt.Sprintf("SELECT count(*) FROM %s WHERE company_id = $1", table), companyID).
		Scan(&n)
	require.NoError(t, err, "count %s", table)
	return n
}

func closePools() {
	if appPoolVal != nil {
		appPoolVal.Close()
		appPoolVal = nil
	}
	if adminPoolVal != nil {
		adminPoolVal.Close()
		adminPoolVal = nil
	}
}

func safeIdent(s string) bool {
	if s == "" {
		return false
	}
	for _, r := range s {
		switch {
		case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9', r == '_':
		default:
			return false
		}
	}
	return true
}
