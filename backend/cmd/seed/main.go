// Command seed fills a development database with a realistic ONEBOOK ELD
// dataset: two tenants, one account per default role, a fleet, two weeks of
// HOS logs, telemetry, DVIR, maintenance, routes and the surrounding ops data.
//
// It is a development tool. It refuses to run against APP_ENV=prod unless
// -force is given, and it never touches the migration history.
//
//	go run ./cmd/seed -dsn postgres://... -password 'Onebook2026'
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"strings"
	"time"
	_ "time/tzdata" // the seed builds local times for America/Chicago and Asia/Tashkent

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/devline/onebook-eld/internal/auth"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "seed:", err)
		os.Exit(1)
	}
}

func run() error {
	var (
		envFile  = flag.String("env", ".env", "env file read for DATABASE_URL / ENCRYPTION_KEY")
		dsn      = flag.String("dsn", "", "database URL (default: DATABASE_URL)")
		password = flag.String("password", defaultPassword, "password given to every seeded account")
		pin      = flag.String("pin", defaultPIN, "6 digit PIN given to every seeded driver")
		force    = flag.Bool("force", false, "allow the seed to run with APP_ENV=prod")
	)
	flag.Parse()

	if err := loadEnvFile(*envFile); err != nil {
		return fmt.Errorf("read %s: %w", *envFile, err)
	}
	if os.Getenv("APP_ENV") == "prod" && !*force {
		return errors.New("APP_ENV=prod: refusing to seed without -force")
	}
	if *dsn == "" {
		*dsn = os.Getenv("DATABASE_URL")
	}
	if *dsn == "" {
		return errors.New("no database URL: pass -dsn or set DATABASE_URL")
	}
	if err := auth.ValidatePassword(*password); err != nil {
		return fmt.Errorf("password: %w", err)
	}
	if err := auth.ValidatePIN(*pin); err != nil {
		return fmt.Errorf("pin: %w", err)
	}

	cipher, err := appcrypto.NewCipherFromString(os.Getenv("ENCRYPTION_KEY"))
	if err != nil {
		return fmt.Errorf("ENCRYPTION_KEY: %w", err)
	}
	passwordHash, err := auth.HashPassword(*password)
	if err != nil {
		return fmt.Errorf("hash password: %w", err)
	}
	pinHash, err := auth.HashPIN(*pin)
	if err != nil {
		return fmt.Errorf("hash pin: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Minute)
	defer cancel()

	pool, err := pgxpool.New(ctx, *dsn)
	if err != nil {
		return fmt.Errorf("connect: %w", err)
	}
	defer pool.Close()

	tx, err := pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	s := &seeder{
		ctx: ctx, tx: tx, cipher: cipher,
		passwordHash: passwordHash, pinHash: pinHash,
		now: time.Now().UTC().Truncate(time.Minute),
	}
	// The tool connects as the owner/superuser, which bypasses RLS. Setting the
	// scopes anyway keeps it usable from a plain app_role login too.
	s.exec(`SET LOCAL app.auth_stage = 'on'`)
	s.exec(`SET LOCAL app.platform = 'on'`)

	s.seedAll()
	if s.err != nil {
		return s.err
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit: %w", err)
	}

	printCredentials(*password, *pin)
	return nil
}

// seeder carries the transaction and stops at the first failing statement so
// the caller reports the statement that broke instead of a cascade.
type seeder struct {
	ctx    context.Context
	tx     pgx.Tx
	cipher *appcrypto.Cipher

	passwordHash string
	pinHash      string
	now          time.Time

	err error
}

// exec runs one statement unless a previous one already failed.
func (s *seeder) exec(sql string, args ...any) {
	if s.err != nil {
		return
	}
	if _, err := s.tx.Exec(s.ctx, sql, args...); err != nil {
		s.err = fmt.Errorf("%s: %w", label(sql), err)
	}
}

// encrypt seals a value the way the application stores it, so the API can
// decrypt seeded licence numbers and signature keys.
func (s *seeder) encrypt(plain string) string {
	if s.err != nil {
		return ""
	}
	out, err := s.cipher.EncryptString(plain)
	if err != nil {
		s.err = fmt.Errorf("encrypt: %w", err)
		return ""
	}
	return out
}

// label reduces a statement to a short identifier for error messages.
func label(sql string) string {
	fields := strings.Fields(strings.ReplaceAll(sql, "\n", " "))
	if len(fields) > 6 {
		fields = fields[:6]
	}
	return strings.Join(fields, " ")
}
