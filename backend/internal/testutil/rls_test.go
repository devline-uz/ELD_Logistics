//go:build integration

// These tests exercise the harness itself plus the database guarantees every
// domain test relies on: tenant isolation (RLS), append-only audit_log,
// non-deletable log tables and the soft-delete aware partial unique indexes.
package testutil

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/require"
)

// execTx runs one statement in a tenant scoped transaction and returns its error.
func execTx(t testing.TB, companyID uuid.UUID, sql string, args ...any) error {
	t.Helper()
	pool := NewDB(t)
	return pool.WithTx(Ctx(t), companyID, func(tx pgx.Tx) error {
		_, err := tx.Exec(context.Background(), sql, args...)
		return err
	})
}

// countAs reads a count as the application role scoped to companyID.
func countAs(t testing.TB, companyID uuid.UUID, sql string, args ...any) int {
	t.Helper()
	var n int
	err := NewDB(t).WithConn(Ctx(t), companyID, func(tx pgx.Tx) error {
		return tx.QueryRow(context.Background(), sql, args...).Scan(&n)
	})
	require.NoError(t, err, "count query failed")
	return n
}

func TestRLSHidesOtherTenantRows(t *testing.T) {
	t.Parallel()
	a, b := SeedTwoCompanies(t)

	cases := []struct {
		table string
		mine  uuid.UUID
		other uuid.UUID
	}{
		{"units", a.Unit.ID, b.Unit.ID},
		{"drivers", a.Driver.ID, b.Driver.ID},
		{"duty_status_events", a.Event.ID, b.Event.ID},
		{"daily_logs", a.Log.ID, b.Log.ID},
		{"dvir_reports", a.Dvir.ID, b.Dvir.ID},
		{"trailers", a.Trailer.ID, b.Trailer.ID},
		{"eld_devices", a.Device.ID, b.Device.ID},
	}

	for _, tc := range cases {
		t.Run(tc.table, func(t *testing.T) {
			q := fmt.Sprintf("SELECT count(*) FROM %s WHERE id = $1", tc.table)
			require.Equal(t, 1, countAs(t, a.ID(), q, tc.mine),
				"tenant A must see its own %s row", tc.table)
			require.Equal(t, 0, countAs(t, a.ID(), q, tc.other),
				"tenant A must not see tenant B's %s row", tc.table)
			// Both rows exist; only RLS hides one of them.
			require.Equal(t, 1, countAs(t, b.ID(), q, tc.other),
				"tenant B must see its own %s row", tc.table)
		})
	}
}

func TestRLSWithoutCompanyIDReturnsNothing(t *testing.T) {
	t.Parallel()
	a := SeedTenant(t)

	// uuid.Nil leaves app.company_id unset -> every policy evaluates to false.
	require.Equal(t, 0, countAs(t, uuid.Nil, "SELECT count(*) FROM units WHERE id = $1", a.Unit.ID))
	require.Equal(t, 0, countAs(t, uuid.Nil, "SELECT count(*) FROM drivers"))
	require.Equal(t, 0, countAs(t, uuid.Nil, "SELECT count(*) FROM duty_status_events"))
}

func TestRLSRejectsCrossTenantInsert(t *testing.T) {
	t.Parallel()
	a, b := SeedTwoCompanies(t)

	err := execTx(t, a.ID(),
		`INSERT INTO units (company_id, unit_number) VALUES ($1, $2)`,
		b.ID(), uniq("X"))
	RequirePermissionDenied(t, err)
	require.Contains(t, err.Error(), "row-level security policy")

	err = execTx(t, a.ID(),
		`INSERT INTO duty_status_events (company_id, event_type, status, event_time, client_event_id)
		 VALUES ($1, 'duty_status', 'DR', now(), $2)`, b.ID(), uuid.New())
	RequirePermissionDenied(t, err)
}

func TestRLSCrossTenantUpdateAffectsNoRows(t *testing.T) {
	t.Parallel()
	a, b := SeedTwoCompanies(t)

	var affected int64
	err := NewDB(t).WithTx(Ctx(t), a.ID(), func(tx pgx.Tx) error {
		tag, err := tx.Exec(context.Background(),
			`UPDATE units SET notes = 'hacked' WHERE id = $1`, b.Unit.ID)
		affected = tag.RowsAffected()
		return err
	})
	require.NoError(t, err)
	require.Zero(t, affected, "tenant A must not be able to update tenant B's unit")
}

func TestAuditLogIsAppendOnly(t *testing.T) {
	t.Parallel()
	a := SeedTenant(t)

	require.NoError(t, execTx(t, a.ID(),
		`INSERT INTO audit_log (company_id, table_name, record_id, action, edited_by)
		 VALUES ($1, 'units', $2, 'insert', $3)`, a.ID(), a.Unit.ID, a.User.ID),
		"the application must be able to append audit rows")

	// The application role holds no UPDATE/DELETE grant on audit_log.
	RequirePermissionDenied(t, execTx(t, a.ID(), `UPDATE audit_log SET action = 'update'`))
	RequirePermissionDenied(t, execTx(t, a.ID(), `DELETE FROM audit_log`))

	// Even the superuser is stopped by the append-only trigger.
	_, err := AdminPool(t).Exec(Ctx(t), `UPDATE audit_log SET action = 'update' WHERE company_id = $1`, a.ID())
	RequirePermissionDenied(t, err)
	require.Contains(t, err.Error(), "append-only")

	_, err = AdminPool(t).Exec(Ctx(t), `DELETE FROM audit_log WHERE company_id = $1`, a.ID())
	RequirePermissionDenied(t, err)
}

func TestProtectedTablesRejectDelete(t *testing.T) {
	t.Parallel()
	a := SeedTenant(t)

	tables := []string{
		"duty_status_events", "daily_logs", "violations", "dvir_reports",
		"unidentified_events", "log_edit_requests", "telemetry", "trips",
	}
	for _, table := range tables {
		t.Run(table, func(t *testing.T) {
			err := execTx(t, a.ID(), fmt.Sprintf("DELETE FROM %s", table))
			RequirePermissionDenied(t, err)
			require.Contains(t, err.Error(), "permission denied")
		})
	}
}

func TestSoftDeleteAwarePartialUniqueIndex(t *testing.T) {
	t.Parallel()
	a := SeedTenant(t)
	number := uniq("DUP")

	insertUnit := func() error {
		return execTx(t, a.ID(),
			`INSERT INTO units (company_id, unit_number) VALUES ($1, $2)`, a.ID(), number)
	}

	require.NoError(t, insertUnit(), "first unit_number must be accepted")
	RequirePGError(t, insertUnit(), SQLStateUniqueViolation)

	// After a soft delete the partial index (WHERE deleted_at IS NULL) frees the
	// value again.
	require.NoError(t, execTx(t, a.ID(),
		`UPDATE units SET deleted_at = now() WHERE company_id = $1 AND unit_number = $2`,
		a.ID(), number))
	require.NoError(t, insertUnit(), "unit_number must be reusable after a soft delete")

	require.Equal(t, 1, countAs(t, a.ID(),
		`SELECT count(*) FROM units WHERE unit_number = $1 AND deleted_at IS NULL`, number))
	require.Equal(t, 2, countAs(t, a.ID(),
		`SELECT count(*) FROM units WHERE unit_number = $1`, number))
}

func TestSchemaIsFullyMigrated(t *testing.T) {
	t.Parallel()
	SkipIfNoDocker(t)
	StartPostgres(t)

	var tables, policies int
	require.NoError(t, AdminPool(t).QueryRow(Ctx(t),
		`SELECT count(*) FROM information_schema.tables
		 WHERE table_schema = 'public' AND table_type = 'BASE TABLE'`).Scan(&tables))
	require.NoError(t, AdminPool(t).QueryRow(Ctx(t),
		`SELECT count(*) FROM pg_policies WHERE schemaname = 'public'`).Scan(&policies))

	require.GreaterOrEqual(t, tables, 43, "expected the full schema")
	require.GreaterOrEqual(t, policies, 40, "expected every tenant table to carry an RLS policy")

	// The pool must never run as a role that can bypass RLS.
	var super, bypass bool
	require.NoError(t, NewDB(t).Raw().QueryRow(Ctx(t),
		`SELECT rolsuper, rolbypassrls FROM pg_roles WHERE rolname = current_user`).Scan(&super, &bypass))
	require.False(t, super, "the application role must not be a superuser")
	require.False(t, bypass, "the application role must not have BYPASSRLS")
}

func TestFixturesAndHTTPHarness(t *testing.T) {
	t.Parallel()
	a := SeedTenant(t, "units.read")

	srv := NewServer(t)
	resp := srv.Get("/health")
	RequireStatus(t, resp, 200)
	RequireNoPII(t, resp.Body)

	var health struct {
		Status  string `json:"status"`
		Version string `json:"version"`
	}
	resp.JSON(&health)
	require.Equal(t, "ok", health.Status)

	// Unknown routes use the canonical error envelope.
	RequireErrorCode(t, srv.AsTenant(a).Get("/api/v1/nope"), "NOT_FOUND")

	require.True(t, a.Principal().HasPermission("units.read"))
	require.False(t, a.Principal().HasPermission("units.delete"))
}

func TestRedisContainerIsUsable(t *testing.T) {
	t.Parallel()
	url := StartRedis(t)
	require.NotEmpty(t, url)
	require.Contains(t, url, "redis://")
}

func TestNoPIIDetector(t *testing.T) {
	t.Parallel()
	RequireNoPII(t, []byte(`{"data":{"id":"1","first_name":"A","units":[{"unit_number":"7"}]}}`))

	for _, body := range []string{
		`{"data":{"password":"x"}}`,
		`{"data":{"password_hash":"x"}}`,
		`{"data":{"license_no":"x"}}`,
		`{"data":{"refresh_token":"x"}}`,
		`{"data":[{"nested":{"totp_secret_enc":"x"}}]}`,
	} {
		fake := &fakeT{TB: t}
		RequireNoPII(fake, []byte(body))
		require.True(t, fake.failed, "expected %s to be rejected", body)
	}
}

// fakeT captures a Fatalf instead of failing the surrounding test.
type fakeT struct {
	testing.TB
	failed bool
}

func (f *fakeT) Helper()                     {}
func (f *fakeT) Fatalf(string, ...any)       { f.failed = true }
func (f *fakeT) Errorf(string, ...any)       { f.failed = true }
func (f *fakeT) FailNow()                    { f.failed = true }
func (f *fakeT) Deadline() (time.Time, bool) { return time.Time{}, false }
