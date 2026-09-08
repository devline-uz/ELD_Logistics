package reports

import (
	"context"
	"log/slog"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/reports/dto"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Alert kinds raised by this module. They are consumed by the notification
// module during wiring; this package never imports internal/notify.
const (
	// AlertExportReady tells the requester the download is available (Q75).
	AlertExportReady = "reports.export_ready"
	// AlertExportFailed reports a failed export to its requester.
	AlertExportFailed = "reports.export_failed"
)

// Alert is the payload handed to the notification module. It carries no report
// content, only the identity of the job.
type Alert struct {
	CompanyID uuid.UUID
	JobID     uuid.UUID
	// UserID is the requester that must be notified.
	UserID uuid.UUID
	// Type and Format describe the export.
	Type   string
	Format string
	// FileName is the suggested download name.
	FileName string
	// ExpiresAt is when the download link stops working.
	ExpiresAt time.Time
	// Reason is set on AlertExportFailed.
	Reason string
	// Message is a short human summary.
	Message string
}

// Alerter is the consumer side interface of the notification fan out. The
// concrete implementation is injected at wiring time so this package stays
// independent of internal/notify.
type Alerter interface {
	Alert(ctx context.Context, alertType string, a Alert) error
}

// NopAlerter drops every alert. It is the default when no notifier is wired.
type NopAlerter struct{}

// Alert implements Alerter.
func (NopAlerter) Alert(context.Context, string, Alert) error { return nil }

// exportKeyKind is the object storage prefix of the rendered exports.
const exportKeyKind = "reports"

// Runner executes one queued export end to end. It lives on the worker side:
// the API only ever queues jobs.
type Runner struct {
	repo    Repo
	builder *Builder
	files   storage.Putter
	alerter Alerter
	log     *slog.Logger
	now     func() time.Time
}

// NewRunner builds the worker side export executor.
func NewRunner(repo Repo, builder *Builder, files storage.Putter, alerter Alerter,
	log *slog.Logger, now func() time.Time) *Runner {
	if alerter == nil {
		alerter = NopAlerter{}
	}
	if log == nil {
		log = slog.Default()
	}
	if now == nil {
		now = time.Now
	}
	return &Runner{repo: repo, builder: builder, files: files, alerter: alerter, log: log, now: now}
}

// Run renders, uploads and finalises one export job. The company context must
// already be set on ctx.
//
// A deterministic failure (a bad window, an unknown type) marks the job
// `failed` and returns nil: retrying it would fail identically. A transient
// failure (object storage down) leaves the job `running` and returns the error
// so the queue retries it.
func (r *Runner) Run(ctx context.Context, jobID uuid.UUID) error {
	job, err := r.repo.StartJob(ctx, jobID)
	if err != nil {
		// The row is gone or already terminal; there is nothing left to do.
		r.log.WarnContext(ctx, "reports: export job not startable",
			slog.String("job_id", jobID.String()), slog.String("error", err.Error()))
		return nil
	}

	artifact, err := r.builder.Build(ctx, job)
	if err != nil {
		r.fail(ctx, job, err)
		return nil
	}

	if r.files == nil {
		r.fail(ctx, job, errNoStorage)
		return nil
	}
	now := r.now().UTC()
	key := storage.BuildKey(job.CompanyID, exportKeyKind, artifact.FileName, now)
	if err := r.files.PutObject(ctx, key, artifact.Body, artifact.ContentType); err != nil {
		// Transient: the queue must retry rather than burn the job.
		r.log.ErrorContext(ctx, "reports: export upload failed",
			slog.String("job_id", job.ID.String()), slog.String("error", err.Error()))
		return err
	}

	// Q75: the download link is valid for 24 hours.
	expiresAt := now.Add(dto.DownloadTTL)
	size := int64(len(artifact.Body))
	done, err := r.repo.FinishJob(ctx, db.FinishReportExportJobParams{
		ID:          job.ID,
		Format:      job.Format,
		FileKey:     &key,
		FileName:    &artifact.FileName,
		FileSizeB:   &size,
		ContentType: &artifact.ContentType,
		ExpiresAt:   pgconv.Time(expiresAt),
	}, func(j db.ReportExportJob) []audit.Entry {
		// Who exported what is an audited fact, not a log line.
		return audit.Changes(auditTable, j.ID, audit.ActionExport, nil, map[string]any{
			"type": j.Type, "format": j.Format, "status": j.Status,
			"file_name": artifact.FileName, "file_size_b": size,
			"expires_at": expiresAt.Format(time.RFC3339),
		})
	})
	if err != nil {
		return err
	}

	r.alert(ctx, AlertExportReady, Alert{
		CompanyID: done.CompanyID, JobID: done.ID, UserID: done.RequestedBy,
		Type: done.Type, Format: done.Format, FileName: artifact.FileName,
		ExpiresAt: expiresAt, Message: "Your export is ready",
	})
	return nil
}

// fail marks a job failed and notifies its requester.
func (r *Runner) fail(ctx context.Context, job db.ReportExportJob, cause error) {
	reason := cause.Error()
	if _, err := r.repo.FailJob(ctx, job.ID, reason); err != nil {
		r.log.ErrorContext(ctx, "reports: export job not marked failed",
			slog.String("job_id", job.ID.String()), slog.String("error", err.Error()))
	}
	r.alert(ctx, AlertExportFailed, Alert{
		CompanyID: job.CompanyID, JobID: job.ID, UserID: job.RequestedBy,
		Type: job.Type, Format: job.Format, Reason: reason,
		Message: "Your export could not be produced",
	})
}

// alert hands one notification to the consumer side interface. A notification
// failure never fails the job that produced it.
func (r *Runner) alert(ctx context.Context, kind string, a Alert) {
	if a.CompanyID == uuid.Nil {
		a.CompanyID = tenant.CompanyID(ctx)
	}
	if err := r.alerter.Alert(ctx, kind, a); err != nil {
		r.log.WarnContext(ctx, "reports: alert not delivered",
			slog.String("kind", kind), slog.String("job_id", a.JobID.String()),
			slog.String("error", err.Error()))
	}
}
