// Package db owns the pgx connection pool and the tenant aware transaction
// helpers. sqlc generated code lands in this same package; the hand written
// identifiers here are prefixed to avoid collisions with generated names.
package db

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/devline/onebook-eld/internal/config"
)

// Pool wraps *pgxpool.Pool with tenant scoped execution helpers.
type Pool struct {
	pool *pgxpool.Pool
	log  *slog.Logger
}

// Pool defaults; overridable through the DATABASE_URL query string.
const (
	defaultMaxConns          = 20
	defaultMinConns          = 2
	defaultMaxConnLifetime   = time.Hour
	defaultMaxConnIdleTime   = 30 * time.Minute
	defaultHealthCheckPeriod = time.Minute
	defaultConnectTimeout    = 10 * time.Second
)

// Open creates and verifies a pgx connection pool.
func Open(ctx context.Context, cfg *config.Config, log *slog.Logger) (*Pool, error) {
	if log == nil {
		log = slog.Default()
	}

	pcfg, err := pgxpool.ParseConfig(cfg.DatabaseURL)
	if err != nil {
		return nil, fmt.Errorf("parse DATABASE_URL: %w", err)
	}
	if pcfg.MaxConns == 0 {
		pcfg.MaxConns = defaultMaxConns
	}
	if pcfg.MinConns == 0 {
		pcfg.MinConns = defaultMinConns
	}
	pcfg.MaxConnLifetime = defaultMaxConnLifetime
	pcfg.MaxConnIdleTime = defaultMaxConnIdleTime
	pcfg.HealthCheckPeriod = defaultHealthCheckPeriod
	pcfg.ConnConfig.ConnectTimeout = defaultConnectTimeout
	pcfg.ConnConfig.RuntimeParams["application_name"] = "onebook-eld"
	pcfg.ConnConfig.RuntimeParams["timezone"] = "UTC"

	pool, err := pgxpool.NewWithConfig(ctx, pcfg)
	if err != nil {
		return nil, fmt.Errorf("create pool: %w", err)
	}

	pingCtx, cancel := context.WithTimeout(ctx, defaultConnectTimeout)
	defer cancel()
	if err := pool.Ping(pingCtx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("ping database: %w", err)
	}

	return &Pool{pool: pool, log: log}, nil
}

// Raw exposes the underlying pgxpool for sqlc generated queries.
func (p *Pool) Raw() *pgxpool.Pool { return p.pool }

// Close releases every pooled connection.
func (p *Pool) Close() {
	if p != nil && p.pool != nil {
		p.pool.Close()
	}
}

// Health pings the database.
func (p *Pool) Health(ctx context.Context) error {
	if p == nil || p.pool == nil {
		return errors.New("db: pool is not initialised")
	}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	return p.pool.Ping(ctx)
}

// Stat returns pool statistics for the metrics endpoint.
func (p *Pool) Stat() (acquired, idle, total int32) {
	if p == nil || p.pool == nil {
		return 0, 0, 0
	}
	s := p.pool.Stat()
	return s.AcquiredConns(), s.IdleConns(), s.TotalConns()
}

// setLocalCompany scopes a transaction to a tenant. RLS policies read
// current_setting('app.company_id') as the second line of defence.
const setLocalCompany = `SELECT set_config('app.company_id', $1, true)`

// WithTx runs fn inside a transaction scoped to companyID via
// SET LOCAL app.company_id. The transaction is committed when fn returns nil
// and rolled back otherwise (including on panic, which is re-raised).
func (p *Pool) WithTx(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error {
	if p == nil || p.pool == nil {
		return errors.New("db: pool is not initialised")
	}

	tx, err := p.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}

	committed := false
	defer func() {
		if committed {
			return
		}
		if rbErr := tx.Rollback(ctx); rbErr != nil && !errors.Is(rbErr, pgx.ErrTxClosed) {
			p.log.ErrorContext(ctx, "tx rollback failed", "error", rbErr.Error())
		}
	}()

	if companyID != uuid.Nil {
		if _, err := tx.Exec(ctx, setLocalCompany, companyID.String()); err != nil {
			return fmt.Errorf("set app.company_id: %w", err)
		}
	}

	if err := fn(tx); err != nil {
		return err
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit tx: %w", err)
	}
	committed = true
	return nil
}

// WithConn runs fn on a single pooled connection scoped to companyID. Use it
// for reads; SET LOCAL requires a transaction, so a read only transaction is
// used to keep the tenant setting bound to the statement scope.
func (p *Pool) WithConn(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error {
	if p == nil || p.pool == nil {
		return errors.New("db: pool is not initialised")
	}

	tx, err := p.pool.BeginTx(ctx, pgx.TxOptions{AccessMode: pgx.ReadOnly})
	if err != nil {
		return fmt.Errorf("begin read tx: %w", err)
	}
	defer func() {
		if rbErr := tx.Rollback(ctx); rbErr != nil && !errors.Is(rbErr, pgx.ErrTxClosed) {
			p.log.ErrorContext(ctx, "read tx rollback failed", "error", rbErr.Error())
		}
	}()

	if companyID != uuid.Nil {
		if _, err := tx.Exec(ctx, setLocalCompany, companyID.String()); err != nil {
			return fmt.Errorf("set app.company_id: %w", err)
		}
	}

	return fn(tx)
}

// setLocalAuthStage opens the pre-authentication window. The RLS policies
// named auth_stage (migration 00013) accept rows only while it is set, and
// SET LOCAL scopes it to the surrounding transaction.
const setLocalAuthStage = `SELECT set_config('app.auth_stage', 'on', true)`

// WithAuthTx runs fn in a transaction that may read the rows authentication
// needs before a tenant is known: the users row behind a username, the session
// behind a refresh token hash, the invitation behind a token hash and the
// company subscription. Only internal/domain/auth may call it.
func (p *Pool) WithAuthTx(ctx context.Context, fn func(pgx.Tx) error) error {
	if p == nil || p.pool == nil {
		return errors.New("db: pool is not initialised")
	}

	tx, err := p.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("begin auth tx: %w", err)
	}

	committed := false
	defer func() {
		if committed {
			return
		}
		if rbErr := tx.Rollback(ctx); rbErr != nil && !errors.Is(rbErr, pgx.ErrTxClosed) {
			p.log.ErrorContext(ctx, "auth tx rollback failed", "error", rbErr.Error())
		}
	}()

	if _, err := tx.Exec(ctx, setLocalAuthStage); err != nil {
		return fmt.Errorf("set app.auth_stage: %w", err)
	}

	if err := fn(tx); err != nil {
		return err
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit auth tx: %w", err)
	}
	committed = true
	return nil
}
