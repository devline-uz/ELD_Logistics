package testutil

import (
	"context"
	"database/sql"
	"fmt"
	"math"
	"path/filepath"
	"runtime"
	"time"

	// Registers the pgx stdlib driver goose runs on.
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"
)

// gooseTable mirrors cmd/migrate so a container migrated here looks identical
// to a locally migrated database.
const gooseTable = "schema_migrations"

// ProjectRoot returns the absolute path of backend/ (the Go module root),
// resolved from this file's location rather than the working directory.
func ProjectRoot() string {
	_, file, _, ok := runtime.Caller(0)
	if !ok {
		panic("testutil: cannot resolve project root")
	}
	// <root>/internal/testutil/migrate.go -> <root>
	return filepath.Clean(filepath.Join(filepath.Dir(file), "..", ".."))
}

// MigrationsDir returns the absolute path of backend/db/migrations.
func MigrationsDir() string {
	return filepath.Join(ProjectRoot(), "db", "migrations")
}

// waitForPostgres polls until the server accepts queries.
func waitForPostgres(ctx context.Context, dsn string) error {
	deadline := time.Now().Add(2 * time.Minute)
	var lastErr error
	for time.Now().Before(deadline) {
		if ctx.Err() != nil {
			return ctx.Err()
		}
		sqlDB, err := sql.Open("pgx", dsn)
		if err != nil {
			lastErr = err
		} else {
			pingCtx, cancel := context.WithTimeout(ctx, 3*time.Second)
			lastErr = sqlDB.PingContext(pingCtx)
			cancel()
			_ = sqlDB.Close()
			if lastErr == nil {
				return nil
			}
		}
		time.Sleep(250 * time.Millisecond)
	}
	return fmt.Errorf("postgres never became ready: %w", lastErr)
}

// migrateLockKey serialises the migrate/provision step across the test binaries
// that share one database (go test ./... runs packages in parallel).
const migrateLockKey int64 = 0x656C645F74657374 // "eld_test"

// applyMigrations brings dsn up to the latest goose migration in db/migrations.
// It is a no-op when the schema is already current, which is what makes a
// shared TEST_DATABASE_URL cheap: only the first test binary pays for the 18
// migrations, the rest just read schema_migrations.
func applyMigrations(ctx context.Context, dsn string) error {
	sqlDB, err := sql.Open("pgx", dsn)
	if err != nil {
		return fmt.Errorf("open migration connection: %w", err)
	}
	defer func() { _ = sqlDB.Close() }()

	goose.SetTableName(gooseTable)
	goose.SetLogger(goose.NopLogger())
	if err := goose.SetDialect("postgres"); err != nil {
		return fmt.Errorf("goose dialect: %w", err)
	}

	ctx, cancel := context.WithTimeout(ctx, 5*time.Minute)
	defer cancel()

	return withMigrateLock(ctx, sqlDB, func() error {
		current, err := schemaVersion(ctx, sqlDB)
		if err != nil {
			return err
		}
		latest, err := latestMigrationVersion()
		if err != nil {
			return err
		}
		if current >= latest {
			return nil // already migrated by another test binary
		}
		if err := goose.UpContext(ctx, sqlDB, MigrationsDir()); err != nil {
			return fmt.Errorf("goose up: %w", err)
		}
		return nil
	})
}

// withMigrateLock runs fn while holding a session level advisory lock.
func withMigrateLock(ctx context.Context, sqlDB *sql.DB, fn func() error) error {
	conn, err := sqlDB.Conn(ctx)
	if err != nil {
		return fmt.Errorf("migration lock connection: %w", err)
	}
	defer func() { _ = conn.Close() }()

	if _, err := conn.ExecContext(ctx, "SELECT pg_advisory_lock($1)", migrateLockKey); err != nil {
		return fmt.Errorf("acquire migration lock: %w", err)
	}
	defer func() {
		_, _ = conn.ExecContext(context.WithoutCancel(ctx), "SELECT pg_advisory_unlock($1)", migrateLockKey)
	}()

	return fn()
}

// schemaVersion returns the highest applied goose version, or 0 when the
// bookkeeping table does not exist yet.
func schemaVersion(ctx context.Context, sqlDB *sql.DB) (int64, error) {
	var exists bool
	if err := sqlDB.QueryRowContext(ctx,
		`SELECT to_regclass('public.`+gooseTable+`') IS NOT NULL`).Scan(&exists); err != nil {
		return 0, fmt.Errorf("probe %s: %w", gooseTable, err)
	}
	if !exists {
		return 0, nil
	}

	var version sql.NullInt64
	if err := sqlDB.QueryRowContext(ctx,
		`SELECT max(version_id) FROM `+gooseTable+` WHERE is_applied`).Scan(&version); err != nil {
		return 0, fmt.Errorf("read %s: %w", gooseTable, err)
	}
	return version.Int64, nil
}

// latestMigrationVersion is the version of the newest file in db/migrations.
func latestMigrationVersion() (int64, error) {
	migrations, err := goose.CollectMigrations(MigrationsDir(), 0, math.MaxInt64)
	if err != nil {
		return 0, fmt.Errorf("collect migrations: %w", err)
	}
	last, err := migrations.Last()
	if err != nil {
		return 0, fmt.Errorf("latest migration: %w", err)
	}
	return last.Version, nil
}

// provisionAppRole creates the login role the application uses. It is a member
// of app_role (granted by 00010_rls.sql) and is explicitly NOSUPERUSER and
// NOBYPASSRLS so integration tests exercise the real RLS policies.
//
// WITH INHERIT TRUE is required on PG16: the membership would otherwise inherit
// the NOINHERIT default and the role would hold no table privileges.
const provisionAppRoleSQL = `
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '` + AppUser + `') THEN
    CREATE ROLE ` + AppUser + ` LOGIN PASSWORD '` + appPass + `';
  END IF;
END;
$$;
ALTER ROLE ` + AppUser + ` NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION INHERIT NOBYPASSRLS;
GRANT app_role TO ` + AppUser + ` WITH INHERIT TRUE;
GRANT USAGE ON SCHEMA public TO ` + AppUser + `;
`

func provisionAppRole(ctx context.Context, adminDSN string) error {
	sqlDB, err := sql.Open("pgx", adminDSN)
	if err != nil {
		return fmt.Errorf("open admin connection: %w", err)
	}
	defer func() { _ = sqlDB.Close() }()

	// On a reused database the role already exists with the right grants;
	// re-running the DDL would only race with the other test binaries.
	ready, err := appRoleReady(ctx, sqlDB)
	if err != nil {
		return err
	}
	if !ready {
		err = withMigrateLock(ctx, sqlDB, func() error {
			if _, err := sqlDB.ExecContext(ctx, provisionAppRoleSQL); err != nil {
				return fmt.Errorf("provision %s role: %w", AppUser, err)
			}
			return nil
		})
		if err != nil {
			return err
		}
	}
	return assertNoBypassRLS(ctx, sqlDB)
}

// appRoleReady reports whether AppUser already exists with the expected flags
// and app_role membership, so the provisioning DDL can be skipped.
func appRoleReady(ctx context.Context, sqlDB *sql.DB) (bool, error) {
	const q = `
SELECT EXISTS (
  SELECT 1
  FROM pg_roles r
  JOIN pg_auth_members m ON m.member = r.oid
  JOIN pg_roles g ON g.oid = m.roleid AND g.rolname = 'app_role'
  WHERE r.rolname = $1
    AND r.rolcanlogin
    AND NOT r.rolsuper
    AND NOT r.rolbypassrls
    AND r.rolinherit
)`
	var ok bool
	if err := sqlDB.QueryRowContext(ctx, q, AppUser).Scan(&ok); err != nil {
		return false, fmt.Errorf("inspect %s role: %w", AppUser, err)
	}
	return ok, nil
}

func assertNoBypassRLS(ctx context.Context, sqlDB *sql.DB) error {
	var super, bypass, inherit bool
	err := sqlDB.QueryRowContext(ctx,
		`SELECT rolsuper, rolbypassrls, rolinherit FROM pg_roles WHERE rolname = $1`, AppUser).
		Scan(&super, &bypass, &inherit)
	if err != nil {
		return fmt.Errorf("inspect %s role: %w", AppUser, err)
	}
	if super || bypass || !inherit {
		return fmt.Errorf("%s must be NOSUPERUSER/NOBYPASSRLS/INHERIT (got super=%t bypass=%t inherit=%t)",
			AppUser, super, bypass, inherit)
	}
	return nil
}
