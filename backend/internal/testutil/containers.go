// Package testutil is the shared integration test harness: docker backed
// Postgres (TimescaleDB + PostGIS) and Redis containers, goose migrations,
// tenant fixtures, an HTTP test client and assertion helpers.
//
// The containers are started once per test binary (sync.Once) and torn down by
// RunMain. Test isolation is per company (company_id), never per schema, so the
// RLS policies are exercised exactly as they are in production and tests can
// run in parallel.
package testutil

import (
	"context"
	"fmt"
	"net/url"
	"os"
	"os/exec"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

// Container images. Overridable so CI can pin a mirror.
const (
	EnvPostgresImage     = "TEST_POSTGRES_IMAGE"
	EnvRedisImage        = "TEST_REDIS_IMAGE"
	defaultPostgresImage = "timescale/timescaledb-ha:pg16"
	defaultRedisImage    = "redis:7-alpine"
)

// Reuse of an already running stack. When these are set no container is
// started, the migrations are applied only when the schema is behind, and
// Shutdown leaves the external services running. See internal/testutil/README.md.
const (
	// EnvDatabaseURL is the superuser DSN of an external Postgres.
	EnvDatabaseURL = "TEST_DATABASE_URL"
	// EnvAppDatabaseURL optionally overrides the eld_app DSN derived from
	// EnvDatabaseURL.
	EnvAppDatabaseURL = "TEST_APP_DATABASE_URL"
	// EnvRedisURL is the redis:// URL of an external Redis.
	EnvRedisURL = "TEST_REDIS_URL"
)

// Postgres credentials inside the container.
const (
	adminUser = "postgres"
	adminPass = "postgres"
	testDB    = "eld_test"

	// AppUser is the NOSUPERUSER / NOBYPASSRLS login role every test pool uses
	// so row level security is really enforced.
	AppUser = "eld_app"
	appPass = "eld_app"
)

const containerStartTimeout = 5 * time.Minute

// dockerSocketPath is the daemon socket path as seen from inside a container.
const dockerSocketPath = "/var/run/docker.sock"

type pgState struct {
	container testcontainers.Container
	adminDSN  string
	appDSN    string
	external  bool
	err       error
}

type redisState struct {
	container testcontainers.Container
	url       string
	external  bool
	err       error
}

var (
	pgOnce  sync.Once
	pgVal   pgState
	rdsOnce sync.Once
	rdsVal  redisState

	dockerOnce     sync.Once
	dockerErr      error
	dockerHostOnce sync.Once
)

// DockerAvailable reports whether a usable docker daemon is reachable.
// testcontainers panics when it cannot locate a daemon, so the probe is
// recovered here and reported as an error the caller can skip on.
func DockerAvailable() error {
	dockerOnce.Do(func() { dockerErr = probeDocker() })
	return dockerErr
}

func probeDocker() (err error) {
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("docker probe panicked: %v", r)
		}
	}()

	resolveDockerHost()

	provider, err := testcontainers.NewDockerProvider()
	if err != nil {
		return err
	}
	defer func() { _ = provider.Close() }()

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	return provider.Health(ctx)
}

// resolveDockerHost fills DOCKER_HOST from the active docker context when it is
// unset. Non default runtimes (colima, rancher, podman) do not listen on
// /var/run/docker.sock, and testcontainers otherwise gives up with
// "rootless Docker not found".
func resolveDockerHost() {
	dockerHostOnce.Do(func() {
		if os.Getenv("DOCKER_HOST") != "" {
			return
		}
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		out, err := exec.CommandContext(ctx, "docker", "context", "inspect",
			"--format", "{{.Endpoints.docker.Host}}").Output()
		if err != nil {
			return
		}
		host := strings.TrimSpace(string(out))
		if !strings.HasPrefix(host, "unix://") && !strings.HasPrefix(host, "tcp://") {
			return
		}
		_ = os.Setenv("DOCKER_HOST", host)

		// Ryuk bind mounts the daemon socket. On colima/rancher the host path
		// (~/.colima/.../docker.sock) does not exist inside the VM, so the
		// mount source must be the in-VM path instead.
		socket := strings.TrimPrefix(host, "unix://")
		if socket != "" && socket != dockerSocketPath &&
			os.Getenv("TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE") == "" {
			_ = os.Setenv("TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE", dockerSocketPath)
		}
	})
}

// SkipIfNoDocker skips t when docker is unreachable or -short was requested.
func SkipIfNoDocker(t testing.TB) {
	t.Helper()
	if testing.Short() {
		t.Skip("short mode: container tests skipped")
	}
	if err := DockerAvailable(); err != nil {
		t.Skipf("docker unavailable: %v", err)
	}
}

// StartPostgres starts (once per test binary) a TimescaleDB/PostGIS container,
// applies db/migrations and provisions the eld_app login role. It returns the
// superuser DSN; use AppDSN for the application (RLS enforced) connection.
func StartPostgres(t testing.TB) string {
	t.Helper()
	if os.Getenv(EnvDatabaseURL) == "" {
		SkipIfNoDocker(t)
	} else if testing.Short() {
		t.Skip("short mode: container tests skipped")
	}

	pgOnce.Do(func() { pgVal = startPostgres() })
	if pgVal.err != nil {
		t.Fatalf("start postgres: %v", pgVal.err)
	}
	return pgVal.adminDSN
}

// AppDSN returns the DSN of the NOSUPERUSER/NOBYPASSRLS application role.
func AppDSN(t testing.TB) string {
	t.Helper()
	StartPostgres(t)
	return pgVal.appDSN
}

func startPostgres() pgState {
	ctx, cancel := context.WithTimeout(context.Background(), containerStartTimeout)
	defer cancel()

	if dsn := os.Getenv(EnvDatabaseURL); dsn != "" {
		return adoptPostgres(ctx, dsn)
	}

	req := testcontainers.ContainerRequest{
		Image:        imageOr(EnvPostgresImage, defaultPostgresImage),
		ExposedPorts: []string{"5432/tcp"},
		Env: map[string]string{
			"POSTGRES_USER":     adminUser,
			"POSTGRES_PASSWORD": adminPass,
			"POSTGRES_DB":       testDB,
		},
		// Durability is irrelevant for throwaway containers.
		Cmd: []string{
			"postgres",
			"-c", "fsync=off",
			"-c", "full_page_writes=off",
			"-c", "synchronous_commit=off",
			"-c", "max_connections=200",
		},
		WaitingFor: wait.ForAll(
			wait.ForListeningPort("5432/tcp"),
			wait.ForLog("database system is ready to accept connections").WithOccurrence(2),
		).WithDeadline(containerStartTimeout),
	}

	c, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	if err != nil {
		return pgState{err: fmt.Errorf("start postgres container: %w", err)}
	}

	host, err := c.Host(ctx)
	if err != nil {
		return pgState{container: c, err: fmt.Errorf("container host: %w", err)}
	}
	port, err := c.MappedPort(ctx, "5432/tcp")
	if err != nil {
		return pgState{container: c, err: fmt.Errorf("mapped port: %w", err)}
	}

	adminDSN := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
		adminUser, adminPass, host, port.Port(), testDB)
	appDSN := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
		AppUser, appPass, host, port.Port(), testDB)

	if err := waitForPostgres(ctx, adminDSN); err != nil {
		return pgState{container: c, err: err}
	}
	if err := applyMigrations(ctx, adminDSN); err != nil {
		return pgState{container: c, err: err}
	}
	if err := provisionAppRole(ctx, adminDSN); err != nil {
		return pgState{container: c, err: err}
	}

	return pgState{container: c, adminDSN: adminDSN, appDSN: appDSN}
}

// StartRedis starts (once per test binary) a Redis container and returns its
// redis:// URL.
func StartRedis(t testing.TB) string {
	t.Helper()
	if os.Getenv(EnvRedisURL) == "" {
		SkipIfNoDocker(t)
	} else if testing.Short() {
		t.Skip("short mode: container tests skipped")
	}

	rdsOnce.Do(func() { rdsVal = startRedis() })
	if rdsVal.err != nil {
		t.Fatalf("start redis: %v", rdsVal.err)
	}
	return rdsVal.url
}

func startRedis() redisState {
	ctx, cancel := context.WithTimeout(context.Background(), containerStartTimeout)
	defer cancel()

	if url := os.Getenv(EnvRedisURL); url != "" {
		return redisState{url: url, external: true}
	}

	req := testcontainers.ContainerRequest{
		Image:        imageOr(EnvRedisImage, defaultRedisImage),
		ExposedPorts: []string{"6379/tcp"},
		Cmd:          []string{"redis-server", "--save", "", "--appendonly", "no"},
		WaitingFor: wait.ForAll(
			wait.ForListeningPort("6379/tcp"),
			wait.ForLog("Ready to accept connections"),
		).WithDeadline(containerStartTimeout),
	}

	c, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	if err != nil {
		return redisState{err: fmt.Errorf("start redis container: %w", err)}
	}

	host, err := c.Host(ctx)
	if err != nil {
		return redisState{container: c, err: fmt.Errorf("container host: %w", err)}
	}
	port, err := c.MappedPort(ctx, "6379/tcp")
	if err != nil {
		return redisState{container: c, err: fmt.Errorf("mapped port: %w", err)}
	}

	return redisState{container: c, url: fmt.Sprintf("redis://%s:%s/0", host, port.Port())}
}

// RunMain wraps testing.M so the shared containers and pools are released when
// the test binary exits. Every package that uses testutil should provide:
//
//	func TestMain(m *testing.M) { testutil.RunMain(m) }
func RunMain(m *testing.M) {
	code := m.Run()
	Shutdown()
	os.Exit(code)
}

// Shutdown closes the shared pools and terminates the shared containers. It is
// safe to call more than once.
func Shutdown() {
	closePools()

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	// Externally provided (TEST_DATABASE_URL / TEST_REDIS_URL) services are
	// owned by whoever started them; never tear those down.
	if !pgVal.external && pgVal.container != nil {
		_ = pgVal.container.Terminate(ctx)
		pgVal.container = nil
	}
	if !rdsVal.external && rdsVal.container != nil {
		_ = rdsVal.container.Terminate(ctx)
		rdsVal.container = nil
	}
}

func imageOr(env, def string) string {
	if v := os.Getenv(env); v != "" {
		return v
	}
	return def
}

// adoptPostgres reuses an already running Postgres given by TEST_DATABASE_URL
// instead of starting a container. Migrations and the eld_app role are applied
// idempotently, so the first test binary pays for them and every later one
// finds the database ready.
func adoptPostgres(ctx context.Context, adminDSN string) pgState {
	st := pgState{adminDSN: adminDSN, external: true}

	appDSN := os.Getenv(EnvAppDatabaseURL)
	if appDSN == "" {
		var err error
		if appDSN, err = appDSNFrom(adminDSN); err != nil {
			st.err = err
			return st
		}
	}
	st.appDSN = appDSN

	if err := waitForPostgres(ctx, adminDSN); err != nil {
		st.err = err
		return st
	}
	if err := applyMigrations(ctx, adminDSN); err != nil {
		st.err = err
		return st
	}
	if err := provisionAppRole(ctx, adminDSN); err != nil {
		st.err = err
		return st
	}
	return st
}

// appDSNFrom rewrites a superuser DSN into the eld_app one, keeping host, port,
// database and query parameters.
func appDSNFrom(adminDSN string) (string, error) {
	u, err := url.Parse(adminDSN)
	if err != nil {
		return "", fmt.Errorf("parse %s: %w", EnvDatabaseURL, err)
	}
	u.User = url.UserPassword(AppUser, appPass)
	return u.String(), nil
}
