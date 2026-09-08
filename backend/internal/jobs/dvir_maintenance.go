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

// Task type names of the DVIR and maintenance sweeps. They are stable strings:
// renaming one strands the tasks already queued in Redis.
const (
	// TypeDvirCloseOverdue applies the Q30.1 fallback: a DVIR whose defects
	// were never confirmed inside the grace window, or whose unit went
	// inactive, is closed as `closed_no_certification`.
	TypeDvirCloseOverdue = "dvir:close_overdue"
	// TypeFanOutDvirCloseOverdue is its scheduler entry point.
	TypeFanOutDvirCloseOverdue = "dvir:fanout_close_overdue"

	// TypeMaintenanceReminders fires the Q37/Q38 reminders of one tenant.
	TypeMaintenanceReminders = "maintenance:reminders"
	// TypeFanOutMaintenanceReminders is its scheduler entry point.
	TypeFanOutMaintenanceReminders = "maintenance:fanout_reminders"
)

// Cron schedules. Both sweeps are cheap and idempotent, so an hourly tick keeps
// the fallback and the reminders inside the resolution the TZ asks for.
const (
	// CronDvirCloseOverdue runs the Q30.1 fallback once an hour.
	CronDvirCloseOverdue = "@every 1h"
	// CronMaintenanceReminders runs the Q37 reminder sweep once an hour.
	CronMaintenanceReminders = "@every 1h"
)

// DvirCloseOverduePayload is one tenant's DVIR fallback sweep.
type DvirCloseOverduePayload struct {
	// CompanyID scopes the sweep; row level security refuses a cross-tenant
	// update even if this were wrong.
	CompanyID uuid.UUID `json:"company_id"`
	// GraceDays defaults to seven when zero (Q30.1).
	GraceDays int32 `json:"grace_days"`
}

// MaintenanceRemindersPayload is one tenant's reminder sweep.
type MaintenanceRemindersPayload struct {
	CompanyID uuid.UUID `json:"company_id"`
}

// DvirCloser is the DVIR service surface this handler needs. Depending on the
// interface keeps internal/jobs free of the domain package.
type DvirCloser interface {
	CloseOverdue(ctx context.Context, graceDays int32) (int, error)
}

// MaintenanceReminder is the maintenance service surface this handler needs.
type MaintenanceReminder interface {
	SendReminders(ctx context.Context) (int, error)
}

// Stage6Deps are the dependencies of the DVIR and maintenance background tasks.
// Companies and Queue are only needed by the periodic fan outs; a worker
// without them still serves the per tenant sweeps.
type Stage6Deps struct {
	Dvir        DvirCloser
	Maintenance MaintenanceReminder
	Companies   CompanyLister
	Queue       Enqueuer
	Log         *slog.Logger
}

// RegisterStage6 wires the DVIR and maintenance tasks into the worker mux.
func RegisterStage6(mux *asynq.ServeMux, deps Stage6Deps) {
	if deps.Dvir != nil {
		mux.Handle(TypeDvirCloseOverdue, HandleDvirCloseOverdue(deps.Dvir, deps.Log))
	}
	if deps.Maintenance != nil {
		mux.Handle(TypeMaintenanceReminders, HandleMaintenanceReminders(deps.Maintenance, deps.Log))
	}
	if deps.Companies != nil && deps.Queue != nil {
		mux.Handle(TypeFanOutDvirCloseOverdue,
			handleFanOut(deps.Companies, deps.Queue, deps.Log, TypeDvirCloseOverdue, NewDvirCloseOverdueTask))
		mux.Handle(TypeFanOutMaintenanceReminders,
			handleFanOut(deps.Companies, deps.Queue, deps.Log, TypeMaintenanceReminders, NewMaintenanceRemindersTask))
	}
}

// NewDvirCloseOverdueTask builds the periodic DVIR fallback task of one tenant.
func NewDvirCloseOverdueTask(companyID uuid.UUID) (*asynq.Task, error) {
	if companyID == uuid.Nil {
		return nil, fmt.Errorf("jobs: %s needs a company id", TypeDvirCloseOverdue)
	}
	payload, err := json.Marshal(DvirCloseOverduePayload{CompanyID: companyID})
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeDvirCloseOverdue, payload,
		asynq.Queue(QueueLow),
		asynq.MaxRetry(3),
		asynq.Timeout(5*time.Minute),
		asynq.Unique(time.Hour),
	), nil
}

// NewMaintenanceRemindersTask builds the reminder sweep task of one tenant.
func NewMaintenanceRemindersTask(companyID uuid.UUID) (*asynq.Task, error) {
	if companyID == uuid.Nil {
		return nil, fmt.Errorf("jobs: %s needs a company id", TypeMaintenanceReminders)
	}
	payload, err := json.Marshal(MaintenanceRemindersPayload{CompanyID: companyID})
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeMaintenanceReminders, payload,
		asynq.Queue(QueueLow),
		asynq.MaxRetry(3),
		asynq.Timeout(5*time.Minute),
		// The `reminder_sent_at` guard already makes a duplicate run harmless;
		// the uniqueness window only keeps the queue tidy.
		asynq.Unique(time.Hour),
	), nil
}

// NewFanOutDvirCloseOverdueTask builds the DVIR fallback fan out.
func NewFanOutDvirCloseOverdueTask() *asynq.Task {
	return asynq.NewTask(TypeFanOutDvirCloseOverdue, nil,
		asynq.Queue(QueueLow), asynq.MaxRetry(1), asynq.Timeout(time.Minute), asynq.Unique(time.Hour))
}

// NewFanOutMaintenanceRemindersTask builds the reminder fan out.
func NewFanOutMaintenanceRemindersTask() *asynq.Task {
	return asynq.NewTask(TypeFanOutMaintenanceReminders, nil,
		asynq.Queue(QueueLow), asynq.MaxRetry(1), asynq.Timeout(time.Minute), asynq.Unique(time.Hour))
}

// HandleDvirCloseOverdue builds the Q30.1 fallback handler.
func HandleDvirCloseOverdue(svc DvirCloser, log *slog.Logger) asynq.Handler {
	if log == nil {
		log = slog.Default()
	}
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		var p DvirCloseOverduePayload
		if err := json.Unmarshal(t.Payload(), &p); err != nil {
			return fmt.Errorf("%w: %w", asynq.SkipRetry, err)
		}
		if p.CompanyID == uuid.Nil {
			return fmt.Errorf("%w: missing company_id", asynq.SkipRetry)
		}
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)

		n, err := svc.CloseOverdue(ctx, p.GraceDays)
		if err != nil {
			return err
		}
		if n > 0 {
			log.InfoContext(ctx, "dvir: reports closed without certification",
				slog.String("company_id", p.CompanyID.String()), slog.Int("reports", n))
		}
		return nil
	})
}

// HandleMaintenanceReminders builds the Q37/Q38 reminder handler.
func HandleMaintenanceReminders(svc MaintenanceReminder, log *slog.Logger) asynq.Handler {
	if log == nil {
		log = slog.Default()
	}
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		var p MaintenanceRemindersPayload
		if err := json.Unmarshal(t.Payload(), &p); err != nil {
			return fmt.Errorf("%w: %w", asynq.SkipRetry, err)
		}
		if p.CompanyID == uuid.Nil {
			return fmt.Errorf("%w: missing company_id", asynq.SkipRetry)
		}
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)

		n, err := svc.SendReminders(ctx)
		if err != nil {
			return err
		}
		if n > 0 {
			log.InfoContext(ctx, "maintenance: reminders sent",
				slog.String("company_id", p.CompanyID.String()), slog.Int("reminders", n))
		}
		return nil
	})
}

// handleFanOut turns a tenant-less cron tick into one task per active company.
// A tenant that fails to enqueue never blocks the others.
func handleFanOut(companies CompanyLister, queue Enqueuer, log *slog.Logger, taskType string,
	build func(uuid.UUID) (*asynq.Task, error)) asynq.Handler {
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
			task, err := build(id)
			if err == nil {
				_, err = queue.Enqueue(task)
			}
			if err != nil {
				failed++
				log.ErrorContext(ctx, "jobs: tenant sweep not enqueued",
					slog.String("task", taskType), slog.String("company_id", id.String()),
					slog.String("error", err.Error()))
			}
		}
		if failed > 0 && failed == len(ids) {
			return fmt.Errorf("jobs: no tenant sweep could be enqueued for %s (%d tenants)", taskType, failed)
		}
		return nil
	})
}
