// Package jobs holds the asynq task types, payloads and handlers of the
// background workers. The queue client and the scheduler are wired in
// cmd/worker; this package stays transport free so every handler is testable
// without Redis.
package jobs

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"

	"github.com/devline/onebook-eld/internal/tenant"
)

// Task type names. They are stable strings: renaming one strands the tasks
// already queued in Redis.
const (
	// TypeMarkStaleUnitsOffline demotes units that stopped reporting telemetry
	// (TZ §10.1 — Online means a sample within the last five minutes).
	TypeMarkStaleUnitsOffline = "telemetry:mark_stale_units_offline"
)

// Queue names, highest priority first.
const (
	QueueDefault = "default"
	QueueLow     = "low"
)

// CronMarkStaleUnitsOffline is the schedule of the offline sweep. It runs every
// minute so the map never shows a stale unit as Online for longer than the
// five minute window plus one tick.
const CronMarkStaleUnitsOffline = "@every 1m"

// MarkStaleUnitsOfflinePayload is one tenant's offline sweep.
type MarkStaleUnitsOfflinePayload struct {
	// CompanyID scopes the sweep; row level security refuses a cross-tenant
	// update even if this were wrong.
	CompanyID uuid.UUID `json:"company_id"`
	// ThresholdMinutes defaults to five when zero.
	ThresholdMinutes int32 `json:"threshold_minutes"`
}

// NewMarkStaleUnitsOfflineTask builds the periodic sweep task of one tenant.
func NewMarkStaleUnitsOfflineTask(companyID uuid.UUID, thresholdMinutes int32) (*asynq.Task, error) {
	if companyID == uuid.Nil {
		return nil, fmt.Errorf("jobs: %s needs a company id", TypeMarkStaleUnitsOffline)
	}
	payload, err := json.Marshal(MarkStaleUnitsOfflinePayload{
		CompanyID: companyID, ThresholdMinutes: thresholdMinutes,
	})
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeMarkStaleUnitsOffline, payload,
		asynq.Queue(QueueLow),
		asynq.MaxRetry(3),
		asynq.Timeout(time.Minute),
		// One sweep per tenant per minute is enough; a duplicate is harmless
		// but pointless.
		asynq.Unique(time.Minute),
	), nil
}

// StaleOfflineMarker is the telemetry service surface this handler needs.
// Depending on the interface keeps internal/jobs free of the domain package.
type StaleOfflineMarker interface {
	MarkStaleOffline(ctx context.Context, thresholdMinutes int32) (int64, error)
}

// Deps are the dependencies of the telemetry background tasks. Companies and
// Queue are only needed by the periodic fan out; a worker without them still
// serves the per tenant sweeps.
type Deps struct {
	Telemetry StaleOfflineMarker
	Companies CompanyLister
	Queue     Enqueuer
	Log       *slog.Logger
}

// Register wires the telemetry tasks into the worker mux.
func Register(mux *asynq.ServeMux, deps Deps) {
	if deps.Telemetry != nil {
		mux.Handle(TypeMarkStaleUnitsOffline, HandleMarkStaleUnitsOffline(deps.Telemetry, deps.Log))
	}
	if deps.Companies != nil && deps.Queue != nil {
		mux.Handle(TypeFanOutStaleUnitsOffline,
			HandleFanOutStaleUnitsOffline(deps.Companies, deps.Queue, deps.Log))
	}
}

// HandleMarkStaleUnitsOffline builds the offline sweep handler.
func HandleMarkStaleUnitsOffline(svc StaleOfflineMarker, log *slog.Logger) asynq.Handler {
	if log == nil {
		log = slog.Default()
	}
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		var p MarkStaleUnitsOfflinePayload
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

		n, err := svc.MarkStaleOffline(ctx, p.ThresholdMinutes)
		if err != nil {
			return err
		}
		if n > 0 {
			log.InfoContext(ctx, "telemetry: units marked offline",
				slog.String("company_id", p.CompanyID.String()), slog.Int64("units", n))
		}
		return nil
	})
}

// TypeFanOutStaleUnitsOffline is the scheduler entry point of the offline
// sweep. The cron tick carries no tenant, so this task lists the active
// companies and enqueues one TypeMarkStaleUnitsOffline task per tenant.
const TypeFanOutStaleUnitsOffline = "telemetry:fanout_stale_units_offline"

// NewFanOutStaleUnitsOfflineTask builds the periodic fan out task.
func NewFanOutStaleUnitsOfflineTask() *asynq.Task {
	return asynq.NewTask(TypeFanOutStaleUnitsOffline, nil,
		asynq.Queue(QueueLow),
		asynq.MaxRetry(1),
		asynq.Timeout(time.Minute),
		// A second tick inside the same minute would only re-enqueue the same
		// per tenant sweeps.
		asynq.Unique(time.Minute),
	)
}

// CompanyLister returns the tenants the periodic sweeps must cover. It is a
// platform scoped read: the fan out itself belongs to no tenant.
type CompanyLister interface {
	ActiveCompanyIDs(ctx context.Context) ([]uuid.UUID, error)
}

// Enqueuer is the subset of *asynq.Client the fan out needs.
type Enqueuer interface {
	Enqueue(task *asynq.Task, opts ...asynq.Option) (*asynq.TaskInfo, error)
}

// HandleFanOutStaleUnitsOffline builds the fan out handler. One tenant that
// fails to enqueue never blocks the others.
func HandleFanOutStaleUnitsOffline(companies CompanyLister, queue Enqueuer, log *slog.Logger) asynq.Handler {
	if log == nil {
		log = slog.Default()
	}
	return asynq.HandlerFunc(func(ctx context.Context, _ *asynq.Task) error {
		ids, err := companies.ActiveCompanyIDs(ctx)
		if err != nil {
			return err
		}
		var failed int
		for _, id := range ids {
			task, err := NewMarkStaleUnitsOfflineTask(id, 0)
			if err == nil {
				_, err = queue.Enqueue(task)
			}
			if err != nil {
				failed++
				log.ErrorContext(ctx, "telemetry: offline sweep not enqueued",
					slog.String("company_id", id.String()), slog.String("error", err.Error()))
			}
		}
		if failed > 0 && failed == len(ids) {
			return fmt.Errorf("jobs: no tenant sweep could be enqueued (%d tenants)", failed)
		}
		return nil
	})
}
