package jobs

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Retention task types. They are stable strings: renaming one strands the
// tasks already queued in Redis.
const (
	// TypeRetentionSweep purges the expired rows of one tenant (TZ B§15).
	TypeRetentionSweep = "retention:sweep"
	// TypeFanOutRetentionSweep is its scheduler entry point.
	TypeFanOutRetentionSweep = "retention:fanout_sweep"
)

// CronRetentionSweep runs the sweep once a day, in the quiet hours. The purge
// is idempotent, so a missed or repeated tick is harmless.
const CronRetentionSweep = "17 4 * * *"

// Retention windows (TZ B§15 and db/migrations/00011_retention.sql).
//
// Raw telemetry (90 days) and the continuous aggregates (3 years) are dropped
// by the TimescaleDB retention policies created in 00011; they are not swept
// here. Chat messages (1 year) are purged by TypeChatRetention in alerts.go.
const (
	// NotificationRetention keeps the in-app notification feed for one year.
	NotificationRetention = 365 * 24 * time.Hour
	// ExportFileRetention deletes a generated export file after 24 hours; the
	// job row itself stays as an audit trail with file_key = NULL.
	ExportFileRetention = 24 * time.Hour
	// TelemetryRawRetention documents the Timescale policy of `telemetry`.
	TelemetryRawRetention = 90 * 24 * time.Hour
)

// ExpiredExport is one export whose file passed its retention window.
type ExpiredExport struct {
	JobID   uuid.UUID
	FileKey string
}

// RetentionSource is the storage surface of the sweep. Every method takes the
// tenant from the context, never from an argument.
type RetentionSource interface {
	// PurgeNotifications deletes notifications created before the cutoff.
	PurgeNotifications(ctx context.Context, before time.Time) (int64, error)
	// PurgeSessions deletes sessions that expired before the cutoff.
	PurgeSessions(ctx context.Context, before time.Time) (int64, error)
	// ExpireReportExports clears the file key of the exports whose retention
	// window passed and returns the object keys to delete from storage.
	ExpireReportExports(ctx context.Context, before time.Time) ([]ExpiredExport, error)
}

// FileRemover deletes the export objects from the storage backend. It is
// optional: without it the rows are still cleared, only the blobs linger
// (TZ B§7.2 — an expired export must leave nothing behind). storage.Remover
// satisfies it: wire `storage.NewPresignRemover(s3, nil)` in production and
// `storage.NopRemover{}` when no object storage is configured.
type FileRemover interface {
	Remove(ctx context.Context, keys ...string) error
}

// TelemetryPolicyChecker reports whether the TimescaleDB retention policy of
// the raw `telemetry` hypertable exists. The sweep only warns: creating a
// policy is a migration, never a runtime side effect.
type TelemetryPolicyChecker interface {
	TelemetryRetentionPolicy(ctx context.Context) (bool, error)
}

// RetentionDeps are the dependencies of the retention tasks. Companies and
// Queue are only needed by the periodic fan out; a worker without them still
// serves the per tenant sweeps.
type RetentionDeps struct {
	Source    RetentionSource
	Files     FileRemover
	Telemetry TelemetryPolicyChecker
	Companies CompanyLister
	Queue     Enqueuer
	Log       *slog.Logger
	Now       func() time.Time
}

func (d RetentionDeps) withDefaults() RetentionDeps {
	if d.Log == nil {
		d.Log = slog.Default()
	}
	if d.Now == nil {
		d.Now = time.Now
	}
	return d
}

// RetentionSweepPayload is one tenant's sweep.
type RetentionSweepPayload struct {
	// CompanyID scopes the sweep; row level security refuses a cross-tenant
	// delete even if this were wrong.
	CompanyID uuid.UUID `json:"company_id"`
}

// NewRetentionSweepTask builds the daily sweep of one tenant.
func NewRetentionSweepTask(companyID uuid.UUID) (*asynq.Task, error) {
	if companyID == uuid.Nil {
		return nil, fmt.Errorf("jobs: %s needs a company id", TypeRetentionSweep)
	}
	payload, err := json.Marshal(RetentionSweepPayload{CompanyID: companyID})
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeRetentionSweep, payload,
		asynq.Queue(QueueLow),
		asynq.MaxRetry(3),
		asynq.Timeout(10*time.Minute),
		// One sweep per tenant per day; a duplicate is harmless but pointless.
		asynq.Unique(12*time.Hour),
	), nil
}

// NewFanOutRetentionSweepTask builds the retention fan out.
func NewFanOutRetentionSweepTask() *asynq.Task {
	return asynq.NewTask(TypeFanOutRetentionSweep, nil,
		asynq.Queue(QueueLow), asynq.MaxRetry(1), asynq.Timeout(2*time.Minute),
		asynq.Unique(12*time.Hour))
}

// RegisterRetention wires the retention tasks into the worker mux.
func RegisterRetention(mux *asynq.ServeMux, deps RetentionDeps) {
	deps = deps.withDefaults()
	if deps.Source != nil {
		mux.Handle(TypeRetentionSweep, HandleRetentionSweep(deps))
	}
	if deps.Companies != nil && deps.Queue != nil {
		mux.Handle(TypeFanOutRetentionSweep,
			handleFanOut(deps.Companies, deps.Queue, deps.Log, TypeRetentionSweep,
				NewRetentionSweepTask))
	}
}

// RetentionScheduleEntries lists the cron entries of the retention sweep so
// cmd/worker registers them without duplicating the expressions.
func RetentionScheduleEntries() []ScheduleEntry {
	return []ScheduleEntry{
		{Cron: CronRetentionSweep, Task: NewFanOutRetentionSweepTask(), Queue: QueueLow},
	}
}

// HandleRetentionSweep purges the expired rows of one tenant. A failure in one
// table is reported but does not abort the remaining ones: partial progress is
// better than none, and the next tick retries whatever is left.
func HandleRetentionSweep(deps RetentionDeps) asynq.Handler {
	deps = deps.withDefaults()
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		var p RetentionSweepPayload
		if err := json.Unmarshal(t.Payload(), &p); err != nil {
			// A malformed payload will never parse; asynq must not retry it.
			return fmt.Errorf("%w: %w", asynq.SkipRetry, err)
		}
		if p.CompanyID == uuid.Nil {
			return fmt.Errorf("%w: missing company_id", asynq.SkipRetry)
		}
		// Every tenant aware call takes company_id from the context, never from
		// a request body; the task payload is the context here.
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)
		now := deps.Now().UTC()
		company := slog.String("company_id", p.CompanyID.String())

		var firstErr error
		note := func(what string, err error) {
			if err == nil {
				return
			}
			if firstErr == nil {
				firstErr = fmt.Errorf("retention %s: %w", what, err)
			}
			deps.Log.ErrorContext(ctx, "retention: sweep step failed",
				company, slog.String("step", what), slog.String("error", err.Error()))
		}

		if n, err := deps.Source.PurgeNotifications(ctx, now.Add(-NotificationRetention)); err != nil {
			note("notifications", err)
		} else if n > 0 {
			deps.Log.InfoContext(ctx, "retention: notifications purged", company, slog.Int64("rows", n))
		}

		if n, err := deps.Source.PurgeSessions(ctx, now); err != nil {
			note("sessions", err)
		} else if n > 0 {
			deps.Log.InfoContext(ctx, "retention: expired sessions purged", company, slog.Int64("rows", n))
		}

		expired, err := deps.Source.ExpireReportExports(ctx, now)
		if err != nil {
			note("report_export_jobs", err)
		} else if len(expired) > 0 {
			deps.Log.InfoContext(ctx, "retention: export files expired",
				company, slog.Int("files", len(expired)))
			if deps.Files != nil {
				keys := make([]string, 0, len(expired))
				for _, e := range expired {
					if e.FileKey != "" {
						keys = append(keys, e.FileKey)
					}
				}
				if len(keys) > 0 {
					note("export objects", deps.Files.Remove(ctx, keys...))
				}
			}
		}

		return firstErr
	})
}

// CheckTelemetryPolicy verifies that the TimescaleDB retention policy of the
// raw telemetry hypertable is installed (90 days, migration 00011). It is
// called once at worker start: a missing policy is an operational alarm, not a
// runtime fix, because creating one is a migration.
func CheckTelemetryPolicy(ctx context.Context, deps RetentionDeps) error {
	deps = deps.withDefaults()
	if deps.Telemetry == nil {
		return nil
	}
	present, err := deps.Telemetry.TelemetryRetentionPolicy(ctx)
	if err != nil {
		return err
	}
	if !present {
		deps.Log.ErrorContext(ctx, "retention: telemetry policy missing",
			slog.String("hypertable", "telemetry"),
			slog.String("expected", TelemetryRawRetention.String()),
			slog.String("fix", "re-apply db/migrations/00011_retention.sql"))
		return fmt.Errorf("jobs: the telemetry retention policy is missing")
	}
	return nil
}

// PgRetentionSource is the pgx/sqlc implementation of RetentionSource and
// TelemetryPolicyChecker. Every statement runs through Pool.WithTx, which sets
// `SET LOCAL app.company_id` so RLS backs the explicit company_id predicates.
type PgRetentionSource struct {
	pool *db.Pool
}

// NewPgRetentionSource builds the storage adapter of the retention sweep.
func NewPgRetentionSource(pool *db.Pool) *PgRetentionSource {
	return &PgRetentionSource{pool: pool}
}

// PurgeNotifications implements RetentionSource.
func (s *PgRetentionSource) PurgeNotifications(ctx context.Context, before time.Time) (int64, error) {
	companyID := tenant.CompanyID(ctx)
	var n int64
	err := s.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		var err error
		n, err = db.New(tx).RetentionDeleteNotifications(ctx, db.RetentionDeleteNotificationsParams{
			CompanyID: companyID, CreatedAt: before.UTC(),
		})
		return err
	})
	return n, err
}

// PurgeSessions implements RetentionSource.
func (s *PgRetentionSource) PurgeSessions(ctx context.Context, before time.Time) (int64, error) {
	companyID := tenant.CompanyID(ctx)
	var n int64
	err := s.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		var err error
		n, err = db.New(tx).RetentionDeleteSessions(ctx, db.RetentionDeleteSessionsParams{
			CompanyID: pgconv.UUID(companyID), ExpiresAt: before.UTC(),
		})
		return err
	})
	return n, err
}

// ExpireReportExports implements RetentionSource.
func (s *PgRetentionSource) ExpireReportExports(ctx context.Context, before time.Time) ([]ExpiredExport, error) {
	companyID := tenant.CompanyID(ctx)
	var out []ExpiredExport
	err := s.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		rows, err := db.New(tx).RetentionExpireReportExports(ctx, db.RetentionExpireReportExportsParams{
			CompanyID: companyID, ExpiresAt: pgconv.Time(before.UTC()),
		})
		if err != nil {
			return err
		}
		out = make([]ExpiredExport, 0, len(rows))
		for _, r := range rows {
			out = append(out, ExpiredExport{JobID: r.ID, FileKey: r.FileKey})
		}
		return nil
	})
	return out, err
}

// telemetryPolicySQL asks the TimescaleDB catalogue whether the raw telemetry
// hypertable still carries its retention policy. `timescaledb_information` is
// not part of the sqlc schema, so this single probe is raw SQL.
const telemetryPolicySQL = `SELECT EXISTS (
  SELECT 1 FROM timescaledb_information.jobs
  WHERE proc_name = 'policy_retention' AND hypertable_name = 'telemetry'
)`

// TelemetryRetentionPolicy implements TelemetryPolicyChecker.
func (s *PgRetentionSource) TelemetryRetentionPolicy(ctx context.Context) (bool, error) {
	var present bool
	err := s.pool.WithConn(ctx, uuid.Nil, func(tx pgx.Tx) error {
		return tx.QueryRow(ctx, telemetryPolicySQL).Scan(&present)
	})
	return present, err
}
