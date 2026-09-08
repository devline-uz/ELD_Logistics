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

// Task type names of the reporting workers. They are stable strings: renaming
// one strands the tasks already queued in Redis.
const (
	// TypeReportExport renders one queued export job (Q75).
	TypeReportExport = "reports:export"
	// TypeRegionDistanceDaily fills one day of `unit_region_distance_daily`
	// for one tenant, which is what makes Distance by Region immediate.
	TypeRegionDistanceDaily = "reports:region_distance_daily"
	// TypeFanOutRegionDistanceDaily is the scheduler entry point of the roll-up.
	TypeFanOutRegionDistanceDaily = "reports:fanout_region_distance_daily"
)

// CronRegionDistanceDaily runs the roll-up once a day, after midnight UTC, for
// the day that just closed.
const CronRegionDistanceDaily = "30 1 * * *"

// exportTimeout bounds one rendered export. A quarter of region data or eight
// days of HOS is comfortably inside it; anything slower is a bug, not a
// workload.
const exportTimeout = 10 * time.Minute

// ReportExportPayload is one queued export.
type ReportExportPayload struct {
	// CompanyID scopes the render; row level security refuses cross-tenant
	// reads even if this were wrong.
	CompanyID uuid.UUID `json:"company_id"`
	// JobID is the report_export_jobs row to render.
	JobID uuid.UUID `json:"job_id"`
}

// RegionDistanceDailyPayload is one tenant-day of the region roll-up.
type RegionDistanceDailyPayload struct {
	CompanyID uuid.UUID `json:"company_id"`
	// Date is the calendar day to aggregate; the zero value means yesterday.
	Date string `json:"date,omitempty"`
}

// ExportRunner is the reports worker surface this handler needs. Depending on
// the interface keeps internal/jobs free of the domain package.
type ExportRunner interface {
	Run(ctx context.Context, jobID uuid.UUID) error
}

// RegionAggregator is the reports service surface the roll-up needs.
type RegionAggregator interface {
	AggregateRegionDistance(ctx context.Context, day time.Time) (int, error)
}

// Stage7Deps are the dependencies of the routes and reporting background
// tasks. Companies and Queue are only needed by the periodic fan outs; a
// worker without them still serves the per tenant tasks.
type Stage7Deps struct {
	Routes    GeofenceSweeper
	Exports   ExportRunner
	Regions   RegionAggregator
	Companies CompanyLister
	Queue     Enqueuer
	Log       *slog.Logger
}

// RegisterStage7 wires the trip planner and reporting tasks into the worker mux.
func RegisterStage7(mux *asynq.ServeMux, deps Stage7Deps) {
	if deps.Routes != nil {
		mux.Handle(TypeRoutesGeofenceSweep, HandleRoutesGeofenceSweep(deps.Routes, deps.Log))
	}
	if deps.Exports != nil {
		mux.Handle(TypeReportExport, HandleReportExport(deps.Exports, deps.Log))
	}
	if deps.Regions != nil {
		mux.Handle(TypeRegionDistanceDaily, HandleRegionDistanceDaily(deps.Regions, deps.Log))
	}
	if deps.Companies != nil && deps.Queue != nil {
		if deps.Routes != nil {
			mux.Handle(TypeFanOutRoutesGeofenceSweep,
				handleFanOut(deps.Companies, deps.Queue, deps.Log,
					TypeRoutesGeofenceSweep, NewRoutesGeofenceSweepTask))
		}
		if deps.Regions != nil {
			mux.Handle(TypeFanOutRegionDistanceDaily,
				handleFanOut(deps.Companies, deps.Queue, deps.Log,
					TypeRegionDistanceDaily, newRegionDistanceDailyTaskForYesterday))
		}
	}
}

// NewReportExportTask builds the render task of one export job.
func NewReportExportTask(companyID, jobID uuid.UUID) (*asynq.Task, error) {
	if companyID == uuid.Nil || jobID == uuid.Nil {
		return nil, fmt.Errorf("jobs: %s needs a company id and a job id", TypeReportExport)
	}
	payload, err := json.Marshal(ReportExportPayload{CompanyID: companyID, JobID: jobID})
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeReportExport, payload,
		asynq.Queue(QueueDefault),
		asynq.MaxRetry(3),
		asynq.Timeout(exportTimeout),
		// One job id renders once; a duplicate would upload the same bytes
		// twice and burn the storage quota.
		asynq.TaskID("report-export:"+jobID.String()),
	), nil
}

// NewRegionDistanceDailyTask builds the roll-up task of one tenant-day.
func NewRegionDistanceDailyTask(companyID uuid.UUID, day time.Time) (*asynq.Task, error) {
	if companyID == uuid.Nil {
		return nil, fmt.Errorf("jobs: %s needs a company id", TypeRegionDistanceDaily)
	}
	p := RegionDistanceDailyPayload{CompanyID: companyID}
	if !day.IsZero() {
		p.Date = day.UTC().Format(time.DateOnly)
	}
	payload, err := json.Marshal(p)
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeRegionDistanceDaily, payload,
		asynq.Queue(QueueLow),
		asynq.MaxRetry(3),
		asynq.Timeout(exportTimeout),
		// The roll-up clears the day before re-accumulating it, so a duplicate
		// is harmless; the window only keeps the queue tidy.
		asynq.Unique(time.Hour),
	), nil
}

// newRegionDistanceDailyTaskForYesterday adapts the constructor to the fan out
// signature: the cron tick always means "the day that just closed".
func newRegionDistanceDailyTaskForYesterday(companyID uuid.UUID) (*asynq.Task, error) {
	return NewRegionDistanceDailyTask(companyID, time.Time{})
}

// NewFanOutRegionDistanceDailyTask builds the periodic roll-up fan out.
func NewFanOutRegionDistanceDailyTask() *asynq.Task {
	return asynq.NewTask(TypeFanOutRegionDistanceDaily, nil,
		asynq.Queue(QueueLow), asynq.MaxRetry(1), asynq.Timeout(time.Minute), asynq.Unique(time.Hour))
}

// HandleReportExport builds the Q75 export handler.
func HandleReportExport(runner ExportRunner, log *slog.Logger) asynq.Handler {
	if log == nil {
		log = slog.Default()
	}
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		var p ReportExportPayload
		if err := json.Unmarshal(t.Payload(), &p); err != nil {
			// A malformed payload will never parse; asynq must not retry it.
			return fmt.Errorf("%w: %w", asynq.SkipRetry, err)
		}
		if p.CompanyID == uuid.Nil || p.JobID == uuid.Nil {
			return fmt.Errorf("%w: missing company_id or job_id", asynq.SkipRetry)
		}
		// Every tenant aware call takes company_id from the context, never
		// from a request body; the task payload is the context here.
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)

		if err := runner.Run(ctx, p.JobID); err != nil {
			return err
		}
		log.InfoContext(ctx, "reports: export job processed",
			slog.String("company_id", p.CompanyID.String()),
			slog.String("job_id", p.JobID.String()))
		return nil
	})
}

// HandleRegionDistanceDaily builds the Distance by Region roll-up handler.
func HandleRegionDistanceDaily(svc RegionAggregator, log *slog.Logger) asynq.Handler {
	if log == nil {
		log = slog.Default()
	}
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		var p RegionDistanceDailyPayload
		if err := json.Unmarshal(t.Payload(), &p); err != nil {
			return fmt.Errorf("%w: %w", asynq.SkipRetry, err)
		}
		if p.CompanyID == uuid.Nil {
			return fmt.Errorf("%w: missing company_id", asynq.SkipRetry)
		}
		day := time.Now().UTC().AddDate(0, 0, -1)
		if p.Date != "" {
			parsed, err := time.ParseInLocation(time.DateOnly, p.Date, time.UTC)
			if err != nil {
				return fmt.Errorf("%w: bad date %q", asynq.SkipRetry, p.Date)
			}
			day = parsed
		}
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)

		n, err := svc.AggregateRegionDistance(ctx, day)
		if err != nil {
			return err
		}
		if n > 0 {
			log.InfoContext(ctx, "reports: region distance rolled up",
				slog.String("company_id", p.CompanyID.String()),
				slog.String("date", day.Format(time.DateOnly)),
				slog.Int("rows", n))
		}
		return nil
	})
}

// ExportEnqueuer adapts the asynq client to the reporting module's consumer
// side interface. It satisfies reports.Enqueuer structurally, so the domain
// package never imports asynq and this package never imports the domain.
type ExportEnqueuer struct {
	// Queue is the asynq client (or any Enqueuer) the task is handed to.
	Queue Enqueuer
}

// EnqueueExport queues the render of one export job.
func (e ExportEnqueuer) EnqueueExport(_ context.Context, companyID, jobID uuid.UUID) error {
	if e.Queue == nil {
		return fmt.Errorf("jobs: no queue is configured for %s", TypeReportExport)
	}
	task, err := NewReportExportTask(companyID, jobID)
	if err != nil {
		return err
	}
	_, err = e.Queue.Enqueue(task)
	return err
}
