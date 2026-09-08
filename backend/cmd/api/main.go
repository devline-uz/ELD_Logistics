// Command api runs the ONEBOOK ELD HTTP and WebSocket server.
//
//	@title                       ONEBOOK ELD API
//	@version                     1.0
//	@description                 Multi-tenant ELD / fleet management API. Every endpoint below /api/v1 requires a bearer access token unless it is marked `@x-permission public`.
//	@termsOfService              https://onebook-eld.com/terms
//	@contact.name                ONEBOOK ELD Platform Team
//	@contact.email               api@onebook-eld.com
//	@license.name                Proprietary
//	@BasePath                    /api/v1
//	@schemes                     https http
//	@securityDefinitions.apikey  BearerAuth
//	@in                          header
//	@name                        Authorization
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/hibiken/asynq"
	"github.com/redis/go-redis/v9"

	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/config"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/server"
	"github.com/devline/onebook-eld/internal/ws"
)

// version is injected at build time: -ldflags "-X main.version=$(git rev-parse --short HEAD)".
var version = "dev"

const (
	shutdownTimeout   = 15 * time.Second
	readHeaderTimeout = 10 * time.Second
	readTimeout       = 30 * time.Second
	writeTimeout      = 120 * time.Second
	idleTimeout       = 120 * time.Second
)

func main() {
	if err := run(); err != nil {
		slog.Error("api exited with error", "error", err.Error())
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	log := newLogger(cfg)
	slog.SetDefault(log)

	// Only these peers may set X-Forwarded-For / X-Real-IP. Empty (the
	// default) means the transport address is authoritative, so a client
	// cannot pick its own login rate limit bucket or forge an audit_log IP.
	if err := httpx.SetTrustedProxies(cfg.RateLimit.TrustedCIDR); err != nil {
		return err
	}
	if len(cfg.RateLimit.TrustedCIDR) == 0 {
		log.Info("no trusted reverse proxies configured, forwarded-for headers are ignored")
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	pool, err := db.Open(ctx, cfg, log)
	if err != nil {
		return err
	}
	defer pool.Close()

	rdb, err := newRedis(ctx, cfg)
	if err != nil {
		return err
	}
	defer func() { _ = rdb.Close() }()

	hub := ws.NewHub(log)
	defer hub.Close()

	// Every domain publishes through the bridge: it writes to the local hub
	// first and then fans the message out to the other API nodes over Redis
	// pub/sub, so a client attached elsewhere sees the same event.
	bridge := ws.NewBridge(rdb, hub, log)
	go func() {
		if err := bridge.Run(ctx); err != nil && !errors.Is(err, context.Canceled) {
			log.Error("ws fan-out stopped", "error", err.Error())
		}
	}()

	store := cache.NewRedisStore(rdb, "eld")

	// The API only ever enqueues jobs (report exports); the worker process
	// owns the mux, the scheduler and every handler.
	redisOpt, err := asynq.ParseRedisURI(cfg.RedisURL)
	if err != nil {
		return err
	}
	asynqClient := asynq.NewClient(redisOpt)
	defer func() { _ = asynqClient.Close() }()

	sec, err := buildSecurity(cfg, pool, store, log)
	if err != nil {
		return err
	}

	deps := server.Deps{
		Logger:   log,
		DB:       pool,
		Redis:    redisHealth{rdb},
		Verifier: sec.verifier,
		Hub:      hub,
		Version:  version,
		Pool:     pool,
	}

	handler := server.NewRouter(cfg, deps,
		buildModules(cfg, pool, store, sec, hub, bridge, asynqClient, log)...)

	srv := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           handler,
		ReadHeaderTimeout: readHeaderTimeout,
		ReadTimeout:       readTimeout,
		WriteTimeout:      writeTimeout,
		IdleTimeout:       idleTimeout,
		ErrorLog:          slog.NewLogLogger(log.Handler(), slog.LevelError),
	}

	errCh := make(chan error, 1)
	go func() {
		log.Info("http server listening",
			"addr", cfg.HTTPAddr, "env", cfg.AppEnv, "region", cfg.Region, "version", version)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- err
		}
	}()

	select {
	case err := <-errCh:
		return err
	case <-ctx.Done():
		log.Info("shutdown signal received, draining connections")
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		log.Error("graceful shutdown failed", "error", err.Error())
		_ = srv.Close()
		return err
	}

	log.Info("api stopped cleanly")
	return nil
}

func newLogger(cfg *config.Config) *slog.Logger {
	h := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.Level(cfg.SlogLevel()),
	})
	return slog.New(h).With(
		"service", "onebook-eld-api",
		"env", cfg.AppEnv,
		"region", cfg.Region,
		"version", version,
	)
}

func newRedis(ctx context.Context, cfg *config.Config) (*redis.Client, error) {
	opt, err := redis.ParseURL(cfg.RedisURL)
	if err != nil {
		return nil, err
	}
	client := redis.NewClient(opt)

	pingCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := client.Ping(pingCtx).Err(); err != nil {
		_ = client.Close()
		return nil, err
	}
	return client, nil
}

// redisHealth adapts *redis.Client to server.HealthChecker.
type redisHealth struct{ c *redis.Client }

func (r redisHealth) Health(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	return r.c.Ping(ctx).Err()
}
