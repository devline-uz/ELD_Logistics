package main

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	coreauth "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/config"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/auditlog"
	authmod "github.com/devline/onebook-eld/internal/domain/auth"
	"github.com/devline/onebook-eld/internal/domain/chat"
	"github.com/devline/onebook-eld/internal/domain/companies"
	"github.com/devline/onebook-eld/internal/domain/company"
	"github.com/devline/onebook-eld/internal/domain/dashboard"
	"github.com/devline/onebook-eld/internal/domain/drivers"
	"github.com/devline/onebook-eld/internal/domain/duty"
	"github.com/devline/onebook-eld/internal/domain/dvir"
	"github.com/devline/onebook-eld/internal/domain/files"
	"github.com/devline/onebook-eld/internal/domain/fleet"
	"github.com/devline/onebook-eld/internal/domain/logs"
	"github.com/devline/onebook-eld/internal/domain/maintenance"
	"github.com/devline/onebook-eld/internal/domain/notifications"
	"github.com/devline/onebook-eld/internal/domain/reports"
	"github.com/devline/onebook-eld/internal/domain/routes"
	"github.com/devline/onebook-eld/internal/domain/support"
	syncmod "github.com/devline/onebook-eld/internal/domain/sync"
	"github.com/devline/onebook-eld/internal/domain/telemetry"
	"github.com/devline/onebook-eld/internal/domain/tracking"
	"github.com/devline/onebook-eld/internal/domain/users"
	"github.com/devline/onebook-eld/internal/geo"
	"github.com/devline/onebook-eld/internal/jobs"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/server"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/ws"
)

// authTxRunner lets the audit recorder write security events that happen before
// a tenant is known (failed logins, token reuse, platform sessions).
type authTxRunner struct{ pool *db.Pool }

// WithTx implements audit.TxRunner.
func (r authTxRunner) WithTx(ctx context.Context, _ uuid.UUID, fn func(pgx.Tx) error) error {
	return r.pool.WithAuthTx(ctx, fn)
}

// security is the shared authentication layer. Every domain module gates on
// Verifier; Permissions and Revocations are shared so a role or account change
// invalidates the cached grants and the still valid access tokens at once.
type security struct {
	module      *authmod.Module
	verifier    *coreauth.Verifier
	permissions *coreauth.RolePermissionCache
	revocations *coreauth.Revocations
	cipher      *appcrypto.Cipher
	// tokens issues access tokens; the logs module reuses it for the short
	// lived, read only roadside inspection token (Q54).
	tokens *coreauth.TokenService
}

// buildSecurity assembles the security layer.
func buildSecurity(cfg *config.Config, pool *db.Pool, store cache.Store, log *slog.Logger) (security, error) {
	tokens, err := coreauth.NewTokenService(cfg.JWTSecret, cfg.AccessTokenTTL)
	if err != nil {
		return security{}, err
	}
	cipher, err := appcrypto.NewCipherFromString(cfg.EncryptionKey)
	if err != nil {
		return security{}, err
	}

	repo := authmod.NewRepo(pool)
	permissions := coreauth.NewRolePermissionCache(store, repo.RolePermissions, coreauth.RolePermissionCacheTTL)
	revocations := coreauth.NewRevocations(store, cfg.AccessTokenTTL)
	verifier := coreauth.NewVerifier(tokens, permissions, revocations)

	guard := coreauth.NewGuard(store, coreauth.GuardOptions{
		PerIPPerMinute:    cfg.RateLimit.Login,
		PerAccountPerHour: cfg.RateLimit.LoginPerAccountHour,
		Lockout:           time.Duration(cfg.RateLimit.LockoutMinutes) * time.Minute,
	})

	svc := authmod.NewService(authmod.Deps{
		Repo:             repo,
		Tokens:           tokens,
		TOTP:             coreauth.NewTOTPManager(cfg.TOTPIssuer, cipher),
		Guard:            guard,
		Permissions:      permissions,
		Revocations:      revocations,
		Audit:            audit.NewPgRecorder(authTxRunner{pool}, log),
		Store:            store,
		Logger:           log,
		DriverRefreshTTL: cfg.RefreshTTLDriver,
		AdminRefreshTTL:  cfg.RefreshTTLAdmin,
	})

	return security{
		module:      authmod.NewModule(svc, verifier, store, cfg.RateLimit.Login),
		verifier:    verifier,
		permissions: permissions,
		revocations: revocations,
		cipher:      cipher,
		tokens:      tokens,
	}, nil
}

// buildModules constructs every domain module in registration order. The
// order matters only for readability: chi resolves the routes by pattern.
func buildModules(cfg *config.Config, pool *db.Pool, store cache.Store, sec security,
	hub *ws.Hub, bridge *ws.Bridge, asynqClient *asynq.Client, log *slog.Logger) []server.Module {
	// Tenant scoped recorder: every entry is written inside the caller
	// transaction with SET LOCAL app.company_id already applied.
	recorder := audit.NewPgRecorder(pool, log)
	notifier := authmod.LogNotifier{Log: log}
	objStore := newObjectStore(cfg, log)
	geoProvider := geo.New(cfg.Geo, store, http.DefaultClient, log)
	now := time.Now

	// TZ B§15: the admin panel of a lapsed subscription is read only, but the
	// driver app (`self` scope) and the platform owner are never gated — the
	// middleware itself enforces that even if a module below were wrapped by
	// mistake. Read routes (GET/HEAD/OPTIONS) are always a no-op for it.
	subscriptionSource := mw.NewSubscriptionSource(pool, store, 0)
	writeGuard := mw.RequireWritableSubscription(subscriptionSource)

	usersSvc := users.NewService(users.Deps{
		Repo:        users.NewRepo(pool, recorder),
		Permissions: sec.permissions,
		Revocations: sec.revocations,
		Notifier:    notifier,
		Logger:      log,
		Now:         now,
	})

	// Telemetry has no HTTP surface: /sync/push and the device gateway call the
	// service directly (TZ D§2).
	telemetrySvc := telemetry.New(telemetry.Deps{
		Repo:      telemetry.NewRepo(pool, recorder),
		Store:     store,
		Objects:   storage.NewPresignPutter(objStore, http.DefaultClient),
		Publisher: bridge,
		Now:       now,
		Log:       log,
	})

	// Duty owns the duty status write path; sync delegates the event half to it.
	dutyModule := duty.New(duty.Deps{
		Repo:     duty.NewRepo(pool, recorder),
		Verifier: sec.verifier,
		Store:    store,
		Now:      now,
		Log:      log,
	})

	// Logs owns daily logs, certification, the propose/approve edit model, the
	// unidentified driving actions, the canonical violations and the roadside
	// inspection. It reuses the duty service for driver context and the hos
	// policy in force on a day (Q10.1). The report renderer prints with
	// headless Chrome and falls back to HTML when no Chromium is installed, so
	// a roadside inspection never fails on a missing binary.
	logsModule := logs.New(logs.Deps{
		Repo:     logs.NewRepo(pool, recorder),
		Duty:     dutyModule.Service(),
		Verifier: sec.verifier,
		Store:    store,
		Now:      now,
		Log:      log,
		Renderer: logs.ChromeRenderer{Timeout: 30 * time.Second, Fallback: logs.HTMLRenderer{}},
		Files:    storage.NewPresignPutter(objStore, http.DefaultClient),
		Tokens:   sec.tokens,
		Audit:    recorder,
	})

	// Stage 5 — notifications, chat, dashboard and the realtime transport.
	// Every publisher is the Redis bridge, not the bare hub: a client attached
	// to another API node must see the same event (TZ B§3).
	notificationsRepo := notifications.NewRepo(pool, recorder)
	dashboardRepo := dashboard.NewRepo(pool)

	dispatcher := notify.NewDispatcher(notify.Deps{
		Store:     notificationsRepo,
		Senders:   notify.Build(cfg.Notify, log),
		Publisher: bridge,
		Log:       log,
		Now:       now,
	})

	// The WebSocket route is not behind the auth middleware: the handshake
	// carries its own token. Units resolves a unit_ids filter against the
	// tenant so a subscription can never widen past what the caller owns.
	wsModule := ws.New(ws.Deps{
		Hub:            hub,
		Verifier:       sec.verifier,
		Guard:          ws.PermissionGuard{Units: dashboardRepo},
		Log:            log,
		Now:            now,
		AllowedOrigins: cfg.WS.AllowedOrigins,
		PingPeriod:     cfg.WS.PingPeriod,
		PongWait:       cfg.WS.PongWait,
	})

	// Stage 6 — DVIR and maintenance. Both reach the notification fan out
	// through an adapter so the domain packages stay free of internal/notify.
	dvirModule := dvir.New(dvir.Deps{
		Repo:     dvir.NewRepo(pool, recorder),
		Verifier: sec.verifier,
		Alerter:  notify.NewDvirAlerter(dispatcher),
		Renderer: reportRenderer(),
		Store:    store,
		Audit:    recorder,
		Log:      log,
		Now:      now,
	})

	// Stage 7 — the trip planner (Q66-Q68) and the reporting/export pipeline
	// (Q75/TZ §14). The builder is shared with the worker's Runner by both
	// reading through the same Repo; the API only ever queues a job, a worker
	// renders it. The DVIR report needs the DVIR module as a read only lister,
	// otherwise it answers 503 rather than a nil dereference.
	routesModule := routes.New(routes.Deps{
		Repo:     routes.NewRepo(pool, recorder),
		Verifier: sec.verifier,
		Geo:      geoProvider,
		Alerter:  notify.NewRoutesAlerter(dispatcher),
		Store:    store,
		Log:      log,
		Now:      now,
	})

	reportsRepo := reports.NewRepo(pool, recorder)
	reportsBuilder := reports.NewBuilder(reportsRepo, dvirModule.Service(),
		reports.ChromeRenderer{Timeout: 30 * time.Second, Fallback: reports.HTMLRenderer{}}, log, now)
	reportsModule := reports.New(reports.Deps{
		Repo:     reportsRepo,
		Verifier: sec.verifier,
		Files:    objStore,
		Queue:    jobs.ExportEnqueuer{Queue: asynqClient},
		Builder:  reportsBuilder,
		Store:    store,
		Log:      log,
		Now:      now,
	})

	// Stage 8 — the help desk (Q77-Q80) and the read only audit journal
	// (TZ A§17). auditlog never registers a write route, so it is never
	// wrapped by the subscription guard below.
	supportModule := support.New(support.Deps{
		Repo:     support.NewRepo(pool, recorder),
		Verifier: sec.verifier,
		Store:    store,
	})
	auditlogModule := auditlog.New(auditlog.Deps{
		Repo:     auditlog.NewRepo(pool),
		Verifier: sec.verifier,
		Store:    store,
	})

	mods := []server.Module{
		sec.module,
		companies.New(companies.Deps{
			Pool:          pool,
			Audit:         recorder,
			Cache:         store,
			Verifier:      sec.verifier,
			Logger:        log,
			Notifier:      notifier,
			Subscriptions: subscriptionSource,
		}),
		guardWrite(company.New(company.Deps{
			Pool:     pool,
			Audit:    recorder,
			Cache:    store,
			Verifier: sec.verifier,
			Logger:   log,
		}), writeGuard, nil),
		guardWrite(users.NewModule(usersSvc, sec.verifier, store), writeGuard, nil),
		guardWrite(fleet.New(fleet.Deps{
			Repo:     fleet.NewRepo(pool, recorder),
			Verifier: sec.verifier,
			Store:    store,
			Now:      now,
		}), writeGuard, nil),
		guardWrite(drivers.New(drivers.Deps{
			Repo:        drivers.NewRepo(pool, recorder),
			Cipher:      sec.cipher,
			Audit:       recorder,
			Notifier:    notifier,
			Revocations: sec.revocations,
			Verifier:    sec.verifier,
			Logger:      log,
			Now:         now,
		}), writeGuard, nil),
		files.New(files.Deps{
			Repo:      files.NewRepo(pool, recorder),
			Presigner: objStore,
			Cipher:    sec.cipher,
			Audit:     recorder,
			Notifier:  notifier,
			Verifier:  sec.verifier,
			Logger:    log,
			Now:       now,
		}),
		tracking.New(tracking.Deps{
			Repo:     tracking.NewRepo(pool),
			Verifier: sec.verifier,
			Store:    store,
			Now:      now,
		}),
		dutyModule,
		// Only the office side of a log edit (approve/reject) is gated: the
		// driver's own certify and propose-edit paths must never freeze on a
		// lapsed subscription (TZ B§15).
		guardWrite(logsModule, writeGuard,
			guardPatterns("/log-edit-requests/{id}/approve", "/log-edit-requests/{id}/reject")),
		syncmod.New(syncmod.Deps{
			Repo:      syncmod.NewRepo(pool),
			Duty:      dutyModule.Service(),
			Telemetry: telemetrySvc,
			Verifier:  sec.verifier,
			Store:     store,
			Now:       now,
			Log:       log,
		}),
		notifications.New(notifications.Deps{
			Repo:     notificationsRepo,
			Verifier: sec.verifier,
			Store:    store,
		}),
		chat.New(chat.Deps{
			Repo:      chat.NewRepo(pool, recorder),
			Verifier:  sec.verifier,
			Store:     store,
			Publisher: bridge,
			Alerts:    dispatcher,
			Presence:  hub,
			Log:       log,
			Now:       now,
		}),
		dashboard.New(dashboard.Deps{
			Repo:      dashboardRepo,
			Verifier:  sec.verifier,
			Store:     store,
			Publisher: bridge,
			Log:       log,
			Now:       now,
		}),
		// Only the defect type catalogue (admin config) is gated; a driver's
		// own DVIR report, repair and certification never are (TZ B§15).
		guardWrite(dvirModule, writeGuard, guardPrefix("/defect-types")),
		guardWrite(maintenance.New(maintenance.Deps{
			Repo:     maintenance.NewRepo(pool, recorder),
			Verifier: sec.verifier,
			Alerter:  notify.NewMaintenanceAlerter(dispatcher),
			Store:    store,
			Audit:    recorder,
			Log:      log,
			Now:      now,
		}), writeGuard, nil),
		guardWrite(routesModule, writeGuard, nil),
		// Only queuing an export is gated; reading a job's status or download
		// link is not a write and must stay available to a read only tenant.
		guardWrite(reportsModule, writeGuard, guardMethodAndPattern(http.MethodPost, "/export-jobs")),
		guardWrite(supportModule, writeGuard, nil),
		auditlogModule,
	}
	if cfg.WS.Enabled {
		mods = append(mods, wsModule)
	}
	return mods
}

// reportRenderer prints DVIR reports with headless Chrome and degrades to HTML
// when no Chromium is installed, exactly like the daily log renderer, so a
// report never fails on a missing binary.
func reportRenderer() dvir.Renderer {
	return dvir.ChromeRenderer{Timeout: 30 * time.Second, Fallback: dvir.HTMLRenderer{}}
}

// objectStore is the union of capabilities the wiring needs from object
// storage: presigning client uploads (Presigner) and signing the download
// link of a server generated file such as a finished report export
// (storage.Downloader). *storage.S3 and *storage.Fake both satisfy it.
type objectStore interface {
	storage.Presigner
	storage.Downloader
}

// newObjectStore returns the S3 backend when S3_KEY/S3_SECRET are configured.
// Without credentials the process still starts: uploads and download links
// fall back to the in-memory fake so local runs and smoke tests never panic.
// Production misconfiguration is loud in the log rather than fatal at boot.
func newObjectStore(cfg *config.Config, log *slog.Logger) objectStore {
	s3, err := storage.NewS3(cfg.S3, time.Now)
	if err == nil {
		return s3
	}
	log.Warn("object storage is not configured, falling back to the in-memory presigner",
		"error", err.Error(), "bucket", cfg.S3.Bucket)
	fake := storage.NewFake()
	if cfg.S3.PublicURL != "" {
		fake.BaseURL = cfg.S3.PublicURL
	}
	return fake
}
