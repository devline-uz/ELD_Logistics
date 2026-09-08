// Command migrate is a thin goose wrapper over db/migrations.
//
// Usage:
//
//	migrate up | up-by-one | down | status | version | create <name> [sql]
package main

import (
	"context"
	"database/sql"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"time"

	// Registers the pgx stdlib driver used by goose.
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"
)

const (
	defaultDir     = "db/migrations"
	dialect        = "postgres"
	connectTimeout = 15 * time.Second
)

func main() {
	dir := flag.String("dir", envOr("MIGRATIONS_DIR", defaultDir), "migrations directory")
	dsn := flag.String("dsn", os.Getenv("DATABASE_URL"), "database connection string")
	flag.Usage = usage
	flag.Parse()

	args := flag.Args()
	if len(args) == 0 {
		usage()
		os.Exit(2)
	}
	command, rest := args[0], args[1:]

	if err := run(command, rest, *dir, *dsn); err != nil {
		slog.Error("migrate failed", "command", command, "error", err.Error())
		os.Exit(1)
	}
}

func run(command string, args []string, dir, dsn string) error {
	if err := goose.SetDialect(dialect); err != nil {
		return fmt.Errorf("set dialect: %w", err)
	}
	goose.SetTableName("schema_migrations")

	// `create` does not need a database connection.
	if command == "create" {
		if len(args) == 0 {
			return errors.New("create requires a migration name")
		}
		kind := "sql"
		if len(args) > 1 {
			kind = args[1]
		}
		if err := os.MkdirAll(dir, 0o755); err != nil {
			return err
		}
		return goose.Create(nil, dir, args[0], kind)
	}

	if dsn == "" {
		return errors.New("DATABASE_URL is empty (set the env var or pass -dsn)")
	}

	db, err := sql.Open("pgx", dsn)
	if err != nil {
		return fmt.Errorf("open database: %w", err)
	}
	defer func() { _ = db.Close() }()

	ctx, cancel := context.WithTimeout(context.Background(), connectTimeout)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		return fmt.Errorf("ping database: %w", err)
	}

	switch command {
	case "up":
		return goose.Up(db, dir)
	case "up-by-one":
		return goose.UpByOne(db, dir)
	case "up-to":
		v, err := parseVersion(args)
		if err != nil {
			return err
		}
		return goose.UpTo(db, dir, v)
	case "down":
		// Migrations are forward-only in production; `down` exists for local work.
		return goose.Down(db, dir)
	case "down-to":
		v, err := parseVersion(args)
		if err != nil {
			return err
		}
		return goose.DownTo(db, dir, v)
	case "redo":
		return goose.Redo(db, dir)
	case "status":
		return goose.Status(db, dir)
	case "version":
		return goose.Version(db, dir)
	case "reset":
		return goose.Reset(db, dir)
	default:
		usage()
		return fmt.Errorf("unknown command %q", command)
	}
}

func parseVersion(args []string) (int64, error) {
	if len(args) == 0 {
		return 0, errors.New("this command requires a version argument")
	}
	var v int64
	if _, err := fmt.Sscanf(args[0], "%d", &v); err != nil {
		return 0, fmt.Errorf("invalid version %q", args[0])
	}
	return v, nil
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func usage() {
	fmt.Fprint(os.Stderr, `onebook-eld migrate — goose wrapper over db/migrations

Usage: migrate [-dir db/migrations] [-dsn $DATABASE_URL] <command> [args]

Commands:
  up                 apply all pending migrations
  up-by-one          apply the next pending migration
  up-to <version>    apply migrations up to a version
  down               roll back the most recent migration (local only)
  down-to <version>  roll back to a version (local only)
  redo               roll back and re-apply the latest migration
  status             show applied / pending migrations
  version            print the current schema version
  reset              roll back every migration (local only)
  create <name> [sql|go]
                     scaffold a new timestamped migration
`)
}
