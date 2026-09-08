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

// Task type names of the dashboard push. They are stable strings: renaming
// one strands the tasks already queued in Redis.
const (
	// TypeDashboardSummaryPublish pushes one tenant's dashboard summary onto
	// the WebSocket `dashboard` channel, replacing the client's 60s poll with
	// a live update.
	TypeDashboardSummaryPublish = "dashboard:publish_summary"
	// TypeFanOutDashboardSummaryPublish is its scheduler entry point.
	TypeFanOutDashboardSummaryPublish = "dashboard:fanout_publish_summary"
)

// CronDashboardSummaryPublish runs the push every 30s: half of the 60s
// polling budget the NFR replaces, so a client is never more than one tick
// behind what polling used to give it. The summary is a handful of indexed
// aggregate reads per tenant (KPI + today's routes), cheap enough for that
// cadence; Unique below still collapses a tick that overruns into the next.
const CronDashboardSummaryPublish = "@every 30s"

// DashboardSummaryPublishPayload is one tenant's push.
type DashboardSummaryPublishPayload struct {
	// CompanyID scopes the push; row level security refuses a cross-tenant
	// read even if this were wrong.
	CompanyID uuid.UUID `json:"company_id"`
}

// DashboardPublisher is the dashboard service surface this handler needs:
// build the current summary and hand it to the WebSocket channel for the
// tenant carried on ctx. It is intentionally the only call this package
// depends on, so internal/jobs never imports internal/domain/dashboard or its
// DTOs; the worker wiring adapts *dashboard.Service (Summary + Publish) to
// this interface.
//
// dashboard.Service.Publish addresses no BranchID in the WebSocket Audience
// (see internal/ws Audience) — its message is always a company wide
// broadcast to every `dashboard.read` holder. Handing it a branch filtered
// summary would therefore leak another branch's KPIs to a branch scoped
// subscriber, so this job always asks for the whole-company summary
// (branch_id nil); it does not fan out per branch.
type DashboardPublisher interface {
	PublishSummary(ctx context.Context) error
}

// NewDashboardSummaryPublishTask builds one tenant's push task.
func NewDashboardSummaryPublishTask(companyID uuid.UUID) (*asynq.Task, error) {
	if companyID == uuid.Nil {
		return nil, fmt.Errorf("jobs: %s needs a company id", TypeDashboardSummaryPublish)
	}
	payload, err := json.Marshal(DashboardSummaryPublishPayload{CompanyID: companyID})
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeDashboardSummaryPublish, payload,
		asynq.Queue(QueueLow),
		asynq.MaxRetry(1),
		asynq.Timeout(30*time.Second),
		// A push still in flight when the next tick fires is simply skipped:
		// the summary is a point in time read, never worth doubling up.
		asynq.Unique(25*time.Second),
	), nil
}

// NewFanOutDashboardSummaryPublishTask builds the periodic fan out task.
func NewFanOutDashboardSummaryPublishTask() *asynq.Task {
	return asynq.NewTask(TypeFanOutDashboardSummaryPublish, nil,
		asynq.Queue(QueueLow), asynq.MaxRetry(1), asynq.Timeout(30*time.Second), asynq.Unique(25*time.Second))
}

// RegisterDashboard wires the dashboard push tasks into the worker mux.
// Companies and Queue are only needed by the periodic fan out; a worker
// without them still serves the per tenant push.
func RegisterDashboard(mux *asynq.ServeMux, publisher DashboardPublisher, companies CompanyLister, queue Enqueuer, log *slog.Logger) {
	if publisher != nil {
		mux.Handle(TypeDashboardSummaryPublish, HandleDashboardSummaryPublish(publisher, log))
	}
	if companies != nil && queue != nil {
		mux.Handle(TypeFanOutDashboardSummaryPublish, HandleFanOutDashboardSummaryPublish(companies, queue, log))
	}
}

// HandleDashboardSummaryPublish builds the per tenant push handler.
func HandleDashboardSummaryPublish(svc DashboardPublisher, log *slog.Logger) asynq.Handler {
	if log == nil {
		log = slog.Default()
	}
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		var p DashboardSummaryPublishPayload
		if err := json.Unmarshal(t.Payload(), &p); err != nil {
			// A malformed payload will never parse; asynq must not retry it.
			return fmt.Errorf("%w: %w", asynq.SkipRetry, err)
		}
		if p.CompanyID == uuid.Nil {
			return fmt.Errorf("%w: missing company_id", asynq.SkipRetry)
		}
		// Every tenant aware call takes company_id from the context, never
		// from a request body; the task payload is the context here.
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)

		if err := svc.PublishSummary(ctx); err != nil {
			log.WarnContext(ctx, "dashboard: summary push failed",
				slog.String("company_id", p.CompanyID.String()), slog.String("error", err.Error()))
			return err
		}
		return nil
	})
}

// HandleFanOutDashboardSummaryPublish builds the fan out handler. The cron
// tick carries no tenant, so this lists the active companies and enqueues one
// TypeDashboardSummaryPublish task per tenant; one tenant that fails to
// enqueue never blocks the others.
func HandleFanOutDashboardSummaryPublish(companies CompanyLister, queue Enqueuer, log *slog.Logger) asynq.Handler {
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
			task, err := NewDashboardSummaryPublishTask(id)
			if err == nil {
				_, err = queue.Enqueue(task)
			}
			if err != nil {
				failed++
				log.ErrorContext(ctx, "dashboard: summary push not enqueued",
					slog.String("company_id", id.String()), slog.String("error", err.Error()))
			}
		}
		if failed > 0 && failed == len(ids) {
			return fmt.Errorf("jobs: no dashboard summary push could be enqueued (%d tenants)", failed)
		}
		return nil
	})
}
