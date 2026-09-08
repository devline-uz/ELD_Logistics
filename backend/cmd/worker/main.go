// Command worker runs the asynq background worker and the periodic scheduler.
package main

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"
	"github.com/jackc/pgx/v5"
	"github.com/redis/go-redis/v9"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/config"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/duty"
	"github.com/devline/onebook-eld/internal/domain/dvir"
	"github.com/devline/onebook-eld/internal/domain/logs"
	"github.com/devline/onebook-eld/internal/domain/maintenance"
	"github.com/devline/onebook-eld/internal/domain/notifications"
	"github.com/devline/onebook-eld/internal/domain/reports"
	"github.com/devline/onebook-eld/internal/domain/routes"
	"github.com/devline/onebook-eld/internal/domain/telemetry"
	"github.com/devline/onebook-eld/internal/geo"
	"github.com/devline/onebook-eld/internal/jobs"
	"github.com/devline/onebook-eld/internal/metrics"
	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/storage"
)

var version = "dev"

// Queue names and their relative weights.
const (
	QueueCritical = "critical"
	QueueDefault  = "default"
	QueueLow      = "low"
)

const (
	workerConcurrency = 20
	shutdownTimeout   = 30 * time.Second
)

func main() {
	if err := run(); err != nil {
		slog.Error("worker exited with error", "error", err.Error())
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

	redisOpt, err := redisOptions(cfg.RedisURL)
	if err != nil {
		return err
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

	client := asynq.NewClient(redisOpt)
	defer func() { _ = client.Close() }()

	recorder := audit.NewPgRecorder(pool, log)
	store := cache.NewRedisStore(rdb, "eld")
	now := time.Now

	// The worker copy of the telemetry pipeline has no WebSocket publisher and
	// no object storage: the periodic sweep only demotes stale units.
	telemetrySvc := telemetry.New(telemetry.Deps{
		Repo:  telemetry.NewRepo(pool, recorder),
		Store: store,
		Now:   now,
		Log:   log,
	})

	// Alerts sent from the worker reach the in-app inbox and every configured
	// provider, but not the WebSocket: the hub lives in the API process and the
	// bridge would need a subscriber here. The API republishes on read.
	dispatcher := notify.NewDispatcher(notify.Deps{
		Store:   notifications.NewRepo(pool, recorder),
		Senders: notify.Build(cfg.Notify, log),
		Log:     log,
		Now:     now,
	})
	alertRepo := notifications.NewAlertRepo(pool)

	dutySvc := duty.New(duty.Deps{
		Repo:  duty.NewRepo(pool, recorder),
		Store: store,
		Now:   now,
		Log:   log,
	}).Service()

	logsSvc := logs.New(logs.Deps{
		Repo: logs.NewRepo(pool, recorder),
		Duty: dutySvc,
		Now:  now,
		Log:  log,
	}).Service()

	dvirSvc := dvir.New(dvir.Deps{
		Repo:    dvir.NewRepo(pool, recorder),
		Alerter: notify.NewDvirAlerter(dispatcher),
		Log:     log,
		Now:     now,
	}).Service()

	maintenanceSvc := maintenance.New(maintenance.Deps{
		Repo:    maintenance.NewRepo(pool, recorder),
		Alerter: notify.NewMaintenanceAlerter(dispatcher),
		Log:     log,
		Now:     now,
	}).Service()

	// Stage 7 — the trip planner geofence sweep, the daily Distance by Region
	// roll-up and the export renderer. The worker builds its own Service
	// instances rather than reusing the API's: the two processes never share
	// Go state, only the database and the queue.
	objStore := newObjectStore(cfg, log)
	geoProvider := geo.New(cfg.Geo, store, http.DefaultClient, log)
	routesSvc := routes.NewService(routes.NewRepo(pool, recorder), geoProvider,
		notify.NewRoutesAlerter(dispatcher), log, now)

	reportsRepo := reports.NewRepo(pool, recorder)
	reportsBuilder := reports.NewBuilder(reportsRepo, dvirSvc,
		reports.ChromeRenderer{Timeout: 30 * time.Second, Fallback: reports.HTMLRenderer{}}, log, now)
	reportsSvc := reports.NewService(reportsRepo, objStore, nil, reportsBuilder, log, now)
	reportsRunner := reports.NewRunner(reportsRepo, reportsBuilder,
		storage.NewPresignPutter(objStore, http.DefaultClient), notify.NewReportsAlerter(dispatcher), log, now)

	// Retention (TZ B§15) purges the tables the TimescaleDB policies do not
	// reach: notifications, expired sessions and the report export files past
	// their 24 hour download window. Files is nil until object storage grows a
	// delete operation; the rows are still cleared, only the blobs linger.
	retentionSource := jobs.NewPgRetentionSource(pool)

	mux := asynq.NewServeMux()
	jobs.Register(mux, jobs.Deps{
		Telemetry: telemetrySvc,
		Companies: companyLister{pool},
		Queue:     client,
		Log:       log,
	})
	jobs.RegisterAlerts(mux, jobs.AlertDeps{
		Directory:    alertRepo,
		Source:       alertRepo,
		Alerts:       dispatcher,
		Unidentified: logsSvc,
		Queue:        client,
		Log:          log,
		Now:          now,
	})
	jobs.RegisterStage6(mux, jobs.Stage6Deps{
		Dvir:        dvirSvc,
		Maintenance: maintenanceSvc,
		Companies:   companyLister{pool},
		Queue:       client,
		Log:         log,
	})
	jobs.RegisterStage7(mux, jobs.Stage7Deps{
		Routes:    routesSvc,
		Exports:   reportsRunner,
		Regions:   reportsSvc,
		Companies: companyLister{pool},
		Queue:     client,
		Log:       log,
	})
	jobs.RegisterRetention(mux, jobs.RetentionDeps{
		Source:    retentionSource,
		Files:     newFileRemover(objStore),
		Telemetry: retentionSource,
		Companies: companyLister{pool},
		Queue:     client,
		Log:       log,
		Now:       now,
	})

	// A missing telemetry retention policy is an operational alarm (the
	// migration was not applied), never a reason to refuse to start.
	if err := jobs.CheckTelemetryPolicy(ctx, jobs.RetentionDeps{Telemetry: retentionSource, Log: log}); err != nil {
		log.ErrorContext(ctx, "worker: telemetry retention policy check failed", "error", err.Error())
	}

	inspector := asynq.NewInspector(redisOpt)
	defer func() { _ = inspector.Close() }()
	go metrics.PollQueues(ctx, metrics.NewAsynqQueueSource(inspector), 0, log)

	srv := asynq.NewServer(redisOpt, asynq.Config{
		Concurrency: workerConcurrency,
		Queues: map[string]int{
			QueueCritical: 6,
			QueueDefault:  3,
			QueueLow:      1,
		},
		ShutdownTimeout: shutdownTimeout,
		Logger:          asynqLogger{log},
		ErrorHandler: asynq.ErrorHandlerFunc(func(ctx context.Context, task *asynq.Task, err error) {
			log.ErrorContext(ctx, "task failed", "type", task.Type(), "error", err.Error())
		}),
	})

	scheduler := asynq.NewScheduler(redisOpt, &asynq.SchedulerOpts{
		Location: time.UTC,
		Logger:   asynqLogger{log},
	})
	if err := registerSchedule(scheduler); err != nil {
		return err
	}

	errCh := make(chan error, 2)
	go func() {
		log.Info("asynq worker starting", "concurrency", workerConcurrency, "version", version)
		if err := srv.Run(mux); err != nil {
			errCh <- err
		}
	}()
	go func() {
		log.Info("asynq scheduler starting")
		if err := scheduler.Run(); err != nil {
			errCh <- err
		}
	}()

	select {
	case err := <-errCh:
		return err
	case <-ctx.Done():
		log.Info("shutdown signal received, draining tasks")
	}

	scheduler.Shutdown()
	srv.Shutdown()
	log.Info("worker stopped cleanly")
	return nil
}

// registerSchedule wires periodic tasks (cron expressions are UTC). Every tick
// is tenant free: the fan out handler enqueues one task per company.
func registerSchedule(s *asynq.Scheduler) error {
	entries := jobs.ScheduleEntries()
	entries = append(entries,
		jobs.ScheduleEntry{
			Cron:  jobs.CronDvirCloseOverdue,
			Task:  jobs.NewFanOutDvirCloseOverdueTask(),
			Queue: QueueLow,
		},
		jobs.ScheduleEntry{
			Cron:  jobs.CronMaintenanceReminders,
			Task:  jobs.NewFanOutMaintenanceRemindersTask(),
			Queue: QueueLow,
		},
		jobs.ScheduleEntry{
			Cron:  jobs.CronRoutesGeofenceSweep,
			Task:  jobs.NewFanOutRoutesGeofenceSweepTask(),
			Queue: QueueLow,
		},
		jobs.ScheduleEntry{
			Cron:  jobs.CronRegionDistanceDaily,
			Task:  jobs.NewFanOutRegionDistanceDailyTask(),
			Queue: QueueLow,
		},
	)
	entries = append(entries, jobs.RetentionScheduleEntries()...)
	for _, e := range entries {
		queue := e.Queue
		if queue == "" {
			queue = QueueDefault
		}
		if _, err := s.Register(e.Cron, e.Task, asynq.Queue(queue)); err != nil {
			return fmt.Errorf("schedule %s: %w", e.Task.Type(), err)
		}
	}
	return nil
}

// companyLister reads the active tenants for the periodic fan out. It is a
// platform scoped query, so it runs outside any tenant transaction.
type companyLister struct{ pool *db.Pool }

// maxSweptCompanies bounds the fan out; a larger platform needs a cursor.
const maxSweptCompanies = 1000

// ActiveCompanyIDs implements jobs.CompanyLister.
func (c companyLister) ActiveCompanyIDs(ctx context.Context) ([]uuid.UUID, error) {
	var ids []uuid.UUID
	err := c.pool.WithAuthTx(ctx, func(tx pgx.Tx) error {
		rows, err := db.New(tx).ListCompanies(ctx, db.ListCompaniesParams{
			SortBy: "created_at", SortDir: "asc", RowLimit: maxSweptCompanies,
		})
		if err != nil {
			return err
		}
		ids = make([]uuid.UUID, 0, len(rows))
		for _, row := range rows {
			ids = append(ids, row.ID)
		}
		return nil
	})
	return ids, err
}

// objectStore is the union of capabilities the report renderer needs: signing
// the upload of the rendered document (storage.Putter, through Presigner) and
// the download link the API hands back (storage.Downloader). *storage.S3 and
// *storage.Fake both satisfy it.
type objectStore interface {
	storage.Presigner
	storage.Downloader
}

// newObjectStore returns the S3 backend when S3_KEY/S3_SECRET are configured.
// Without credentials the worker still starts: a rendered export falls back to
// the in-memory fake so local runs never panic; production misconfiguration is
// loud in the log rather than fatal at boot.
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

// newFileRemover turns the object store the report renderer already uses into
// the retention sweep's blob deleter (TZ B§7.2). storage.Fake never gets a
// PresignDelete implementation — it is a local/test fallback — so only a real
// S3 backend gets a Remover; otherwise the sweep still clears the rows and
// leaves the (non-existent, in-memory) blob alone.
func newFileRemover(store objectStore) jobs.FileRemover {
	if s3, ok := store.(*storage.S3); ok {
		return storage.NewPresignRemover(s3, nil)
	}
	return storage.NopRemover{}
}

// newRedis opens the cache client used by the telemetry pipeline.
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

func redisOptions(rawURL string) (asynq.RedisClientOpt, error) {
	opt, err := redis.ParseURL(rawURL)
	if err != nil {
		return asynq.RedisClientOpt{}, err
	}
	return asynq.RedisClientOpt{
		Addr:     opt.Addr,
		Username: opt.Username,
		Password: opt.Password,
		DB:       opt.DB,
	}, nil
}

func newLogger(cfg *config.Config) *slog.Logger {
	h := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.Level(cfg.SlogLevel()),
	})
	return slog.New(h).With(
		"service", "onebook-eld-worker",
		"env", cfg.AppEnv,
		"region", cfg.Region,
		"version", version,
	)
}

// asynqLogger adapts slog to the asynq.Logger interface.
type asynqLogger struct{ l *slog.Logger }

func (a asynqLogger) Debug(args ...any) { a.l.Debug(join(args)) }
func (a asynqLogger) Info(args ...any)  { a.l.Info(join(args)) }
func (a asynqLogger) Warn(args ...any)  { a.l.Warn(join(args)) }
func (a asynqLogger) Error(args ...any) { a.l.Error(join(args)) }
func (a asynqLogger) Fatal(args ...any) { a.l.Error(join(args)); os.Exit(1) }

func join(args []any) string {
	parts := make([]string, 0, len(args))
	for _, a := range args {
		if s, ok := a.(string); ok {
			parts = append(parts, s)
			continue
		}
		parts = append(parts, strings.TrimSpace(fmt.Sprint(a)))
	}
	return strings.Join(parts, " ")
}
