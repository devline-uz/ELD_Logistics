package reports

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/reports/dto"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
)

// auditTable is the audit_log table name of the export jobs.
const auditTable = "report_export_jobs"

// profileGeneric is the only regulation profile whose regulator export is
// implemented in this stage; `us_fmcsa` needs the FMCSA output file and web
// service, which is stage two of the TZ.
const profileGeneric = "generic"

// Enqueuer hands a queued export job to the worker. It is the consumer side
// interface of internal/jobs, so this package never imports asynq.
type Enqueuer interface {
	EnqueueExport(ctx context.Context, companyID, jobID uuid.UUID) error
}

// NopEnqueuer drops the hand-off. A job created with it stays `queued` until a
// worker picks it up by other means; it is the default in tests.
type NopEnqueuer struct{}

// EnqueueExport implements Enqueuer.
func (NopEnqueuer) EnqueueExport(context.Context, uuid.UUID, uuid.UUID) error { return nil }

// Service holds the reporting business rules (TZ §14).
type Service struct {
	repo    Repo
	files   storage.Downloader
	queue   Enqueuer
	log     *slog.Logger
	now     func() time.Time
	builder *Builder
}

// NewService builds the reporting service.
func NewService(repo Repo, files storage.Downloader, queue Enqueuer, builder *Builder,
	log *slog.Logger, now func() time.Time) *Service {
	if queue == nil {
		queue = NopEnqueuer{}
	}
	if log == nil {
		log = slog.Default()
	}
	if now == nil {
		now = time.Now
	}
	return &Service{repo: repo, files: files, queue: queue, builder: builder, log: log, now: now}
}

// ActivityQuery is the resolved GET /reports/activity request.
type ActivityQuery struct {
	// Subject is "drivers" or "units".
	Subject string
	// From is inclusive, To is exclusive.
	From, To  time.Time
	DriverIDs []uuid.UUID
	UnitIDs   []uuid.UUID
	Limit     int32
	Offset    int32
}

// Activity answers the odometer activity report (Q75). It is live: the
// odometer extremes come straight from telemetry, no roll-up is involved.
func (s *Service) Activity(ctx context.Context, q ActivityQuery) ([]dto.ActivityRow, int64, error) {
	f := ActivityFilter{
		Subject: q.Subject, From: q.From, To: q.To,
		DriverIDs: q.DriverIDs, UnitIDs: q.UnitIDs, Limit: q.Limit, Offset: q.Offset,
	}
	if branchID, ok := scopeBranch(ctx); ok {
		f.BranchID = &branchID
	}
	if q.Subject == dto.SubjectDrivers {
		rows, total, err := s.repo.ActivityDrivers(ctx, f)
		if err != nil {
			return nil, 0, apierr.Internal(err, "failed to build the activity report")
		}
		out := make([]dto.ActivityRow, 0, len(rows))
		for _, r := range rows {
			out = append(out, activityRow(r.DriverID.String(), dto.SubjectDrivers,
				displayName(r.FirstName, r.LastName), r.StartOdometerM, r.EndOdometerM, r.Samples))
		}
		return out, total, nil
	}

	rows, total, err := s.repo.ActivityUnits(ctx, f)
	if err != nil {
		return nil, 0, apierr.Internal(err, "failed to build the activity report")
	}
	out := make([]dto.ActivityRow, 0, len(rows))
	for _, r := range rows {
		out = append(out, activityRow(r.UnitID.String(), dto.SubjectUnits,
			r.UnitNumber, r.StartOdometerM, r.EndOdometerM, r.Samples))
	}
	return out, total, nil
}

// activityRow applies Q75: Odometer Change = End − Start. A subject that
// reported nothing keeps three zeros and `has_data = false` instead of a
// misleading negative change.
func activityRow(id, subject, name string, start, end, samples int64) dto.ActivityRow {
	row := dto.ActivityRow{
		SubjectID: id, SubjectType: subject, Name: name, HasData: samples > 0,
	}
	if row.HasData {
		row.StartOdometerM = start
		row.EndOdometerM = end
		row.OdometerChangeM = end - start
	}
	return row
}

// DistanceByRegion answers the quarterly distance report. It reads the daily
// roll-up (`unit_region_distance_daily`), so the answer is immediate: the
// "ready in up to five days" caveat of v1 is gone.
func (s *Service) DistanceByRegion(ctx context.Context, quarter, year int, mode string,
	unitIDs []uuid.UUID) ([]dto.RegionDistanceRow, dto.DistanceByRegionMeta, error) {
	from, to, err := QuarterRange(quarter, year)
	if err != nil {
		return nil, dto.DistanceByRegionMeta{}, err
	}
	f := RegionFilter{From: from, To: to, UnitIDs: unitIDs}
	if branchID, ok := scopeBranch(ctx); ok {
		f.BranchID = &branchID
	}
	meta := dto.DistanceByRegionMeta{
		Quarter: quarter, Year: year, Mode: mode,
		From: from.Format(time.DateOnly), To: to.Format(time.DateOnly),
	}

	var out []dto.RegionDistanceRow
	if mode == dto.ModeRegionsOnly {
		rows, err := s.repo.RegionTotals(ctx, f)
		if err != nil {
			return nil, meta, apierr.Internal(err, "failed to build the distance by region report")
		}
		out = make([]dto.RegionDistanceRow, 0, len(rows))
		for _, r := range rows {
			out = append(out, dto.RegionDistanceRow{
				RegionCode: r.RegionCode, RegionName: r.RegionName,
				Country: r.Country, DistanceM: r.DistanceM,
			})
		}
	} else {
		rows, err := s.repo.RegionByUnit(ctx, f)
		if err != nil {
			return nil, meta, apierr.Internal(err, "failed to build the distance by region report")
		}
		out = make([]dto.RegionDistanceRow, 0, len(rows))
		for _, r := range rows {
			out = append(out, dto.RegionDistanceRow{
				RegionCode: r.RegionCode, RegionName: r.RegionName, Country: r.Country,
				UnitID: r.UnitID.String(), UnitNumber: r.UnitNumber, DistanceM: r.DistanceM,
			})
		}
	}
	for _, r := range out {
		meta.TotalDistanceM += r.DistanceM
	}
	return out, meta, nil
}

// QuarterRange returns the inclusive first and last day of a calendar quarter.
func QuarterRange(quarter, year int) (time.Time, time.Time, error) {
	if quarter < 1 || quarter > 4 {
		return time.Time{}, time.Time{}, apierr.Validation("invalid quarter",
			apierr.FieldError{Field: "quarter", Message: "must be between 1 and 4"})
	}
	if year < 2000 || year > 2100 {
		return time.Time{}, time.Time{}, apierr.Validation("invalid year",
			apierr.FieldError{Field: "year", Message: "must be between 2000 and 2100"})
	}
	startMonth := time.Month((quarter-1)*3 + 1)
	from := time.Date(year, startMonth, 1, 0, 0, 0, 0, time.UTC)
	to := from.AddDate(0, 3, 0).AddDate(0, 0, -1)
	return from, to, nil
}

// CreateExportJob queues one asynchronous export (Q75). The regulator export
// is gated on the tenant's regulation profile: `us_fmcsa` needs the FMCSA
// output file and web service, which is stage two.
func (s *Service) CreateExportJob(ctx context.Context, in dto.ExportJobCreate) (*dto.ExportJob, error) {
	if in.Type == dto.TypeRegulator {
		company, err := s.repo.Company(ctx)
		if err != nil {
			return nil, apierr.Internal(err, "failed to load the company")
		}
		if company.RegulationProfile != profileGeneric {
			return nil, apierr.New(apierr.CodeFeatureDisabled, http.StatusNotImplemented,
				"the regulator export is only available on the `generic` regulation profile in this release")
		}
	}
	if err := validateParams(in); err != nil {
		return nil, err
	}
	format := in.Format
	if format == "" {
		format = defaultFormat(in.Type)
	}
	if in.Type == dto.TypeRegulator {
		// The regulator bundle is always a PDF plus a CSV in one archive.
		format = dto.FormatZIP
	}

	if branchID, ok := scopeBranch(ctx); ok {
		// The worker renders the job without a request scope, so the caller's
		// branch is frozen into the params here. A branch scoped requester can
		// never widen it: the value is overwritten, not merged.
		in.Params.BranchID = branchID.String()
	}
	params, err := json.Marshal(in.Params)
	if err != nil {
		return nil, apierr.Validation("invalid params")
	}
	userID := tenant.UserID(ctx)

	job, err := s.repo.CreateJob(ctx, db.CreateReportExportJobParams{
		RequestedBy: userID, Type: in.Type, Format: format, Params: params,
	}, func(j db.ReportExportJob) []audit.Entry {
		// Every export is auditable: who asked for what, and later who could
		// download it (TZ D§6 — export is an audited action).
		return audit.Changes(auditTable, j.ID, audit.ActionExport, nil, map[string]any{
			"type": j.Type, "format": j.Format, "status": j.Status,
		})
	})
	if err != nil {
		return nil, apierr.Internal(err, "failed to queue the export")
	}

	if err := s.queue.EnqueueExport(ctx, job.CompanyID, job.ID); err != nil {
		// The row is the source of truth; a lost hand-off is recoverable by
		// the sweeper, so the caller still gets its job back.
		s.log.ErrorContext(ctx, "reports: export job not enqueued",
			slog.String("job_id", job.ID.String()), slog.String("error", err.Error()))
	}
	out := s.toJob(ctx, job)
	return &out, nil
}

// GetExportJob returns one job together with a fresh download link while the
// job is done and inside its 24 hour window.
func (s *Service) GetExportJob(ctx context.Context, id uuid.UUID) (*dto.ExportJob, error) {
	job, err := s.repo.GetJob(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apierr.NotFound("export job")
		}
		return nil, apierr.Internal(err, "failed to load the export job")
	}
	if !s.ownsJob(ctx, job.RequestedBy) {
		// A rendered export is a company wide document; a branch or self
		// scoped caller may only download the ones it asked for. 404, not 403,
		// so job ids stay unguessable.
		return nil, apierr.NotFound("export job")
	}
	out := s.toJob(ctx, job)
	return &out, nil
}

// ownsJob reports whether the caller may read an export requested by userID.
// Company scoped callers see every job of their tenant.
func (s *Service) ownsJob(ctx context.Context, requestedBy uuid.UUID) bool {
	if userID, ok := scopeSelfUser(ctx); ok {
		return requestedBy == userID
	}
	if _, ok := scopeBranch(ctx); ok {
		return requestedBy == tenant.UserID(ctx)
	}
	return true
}

// ListExportJobs returns one page of export jobs.
func (s *Service) ListExportJobs(ctx context.Context, f JobFilter) ([]dto.ExportJob, int64, error) {
	if userID, ok := scopeSelfUser(ctx); ok {
		f.RequestedBy = &userID
	} else if _, ok := scopeBranch(ctx); ok {
		own := tenant.UserID(ctx)
		f.RequestedBy = &own
	}
	rows, total, err := s.repo.ListJobs(ctx, f)
	if err != nil {
		return nil, 0, apierr.Internal(err, "failed to list export jobs")
	}
	out := make([]dto.ExportJob, 0, len(rows))
	for _, j := range rows {
		out = append(out, s.toJob(ctx, j))
	}
	return out, total, nil
}

// validateParams rejects a job whose window makes no sense for its type before
// a worker wastes a slot on it.
func validateParams(in dto.ExportJobCreate) error {
	p := in.Params
	switch in.Type {
	case dto.TypeDistanceByRegion:
		if p.Quarter < 1 || p.Quarter > 4 || p.Year == 0 {
			return apierr.Validation("distance_by_region needs a quarter and a year",
				apierr.FieldError{Field: "params.quarter", Message: "must be between 1 and 4"},
				apierr.FieldError{Field: "params.year", Message: "required"})
		}
	default:
		from, to, err := ParseWindow(p.From, p.To)
		if err != nil {
			return err
		}
		if to.Before(from) {
			return apierr.Validation("invalid window",
				apierr.FieldError{Field: "params.to", Message: "must not be before params.from"})
		}
	}
	return nil
}

// ParseWindow parses the inclusive `from`/`to` date pair of an export.
func ParseWindow(from, to string) (time.Time, time.Time, error) {
	if from == "" || to == "" {
		return time.Time{}, time.Time{}, apierr.Validation("the export needs a window",
			apierr.FieldError{Field: "params.from", Message: "required (YYYY-MM-DD)"},
			apierr.FieldError{Field: "params.to", Message: "required (YYYY-MM-DD)"})
	}
	f, err := time.ParseInLocation(time.DateOnly, from, time.UTC)
	if err != nil {
		return time.Time{}, time.Time{}, apierr.Validation("invalid from",
			apierr.FieldError{Field: "params.from", Message: "must be YYYY-MM-DD"})
	}
	t, err := time.ParseInLocation(time.DateOnly, to, time.UTC)
	if err != nil {
		return time.Time{}, time.Time{}, apierr.Validation("invalid to",
			apierr.FieldError{Field: "params.to", Message: "must be YYYY-MM-DD"})
	}
	return f, t, nil
}

// defaultFormat is the output a report type is normally asked for.
func defaultFormat(reportType string) string {
	switch reportType {
	case dto.TypeRegulator:
		return dto.FormatZIP
	case dto.TypeDVIR:
		return dto.FormatPDF
	default:
		return dto.FormatXLSX
	}
}

// toJob maps the stored job onto the wire type, signing a download link when
// one is due.
func (s *Service) toJob(ctx context.Context, j db.ReportExportJob) dto.ExportJob {
	out := dto.ExportJob{
		ID: j.ID.String(), Type: j.Type, Format: j.Format, Status: j.Status,
		RequestedBy: j.RequestedBy.String(), CreatedAt: j.CreatedAt,
	}
	if j.Error != nil {
		out.Error = *j.Error
	}
	if j.FileName != nil {
		out.FileName = *j.FileName
	}
	if j.FileSizeB != nil {
		out.FileSizeB = *j.FileSizeB
	}
	if j.ExpiresAt.Valid {
		t := j.ExpiresAt.Time.UTC()
		out.ExpiresAt = &t
	}
	if j.StartedAt.Valid {
		t := j.StartedAt.Time.UTC()
		out.StartedAt = &t
	}
	if j.FinishedAt.Valid {
		t := j.FinishedAt.Time.UTC()
		out.FinishedAt = &t
	}
	_ = json.Unmarshal(j.Params, &out.Params)

	out.DownloadURL = s.downloadURL(ctx, j)
	return out
}

// downloadURL signs the link of a finished export. The link never outlives the
// job's own expiry, so a shared URL dies with the file (Q75 — 24 hours).
func (s *Service) downloadURL(ctx context.Context, j db.ReportExportJob) string {
	if s.files == nil || j.Status != dto.StatusDone || j.FileKey == nil || *j.FileKey == "" {
		return ""
	}
	// Defence in depth: the row is already company scoped, but a signature is
	// irrevocable, so the stored key is re-checked against the caller's tenant
	// prefix before it is ever signed (TZ B§3.4).
	companyID := tenant.CompanyID(ctx)
	if !storage.OwnsKey(companyID, *j.FileKey) || j.CompanyID != companyID {
		s.log.ErrorContext(ctx, "reports: refusing to sign a foreign export key",
			slog.String("job_id", j.ID.String()))
		return ""
	}
	ttl := dto.DownloadTTL
	if j.ExpiresAt.Valid {
		// Q75: the link never outlives the file, and it is never signed for
		// longer than the 24 hour window even if the row says otherwise.
		ttl = min(time.Until(j.ExpiresAt.Time), dto.DownloadTTL)
		if ttl <= 0 {
			return ""
		}
	}
	link, err := s.files.PresignGet(ctx, *j.FileKey, ttl)
	if err != nil {
		s.log.WarnContext(ctx, "reports: download link not signed",
			slog.String("job_id", j.ID.String()), slog.String("error", err.Error()))
		return ""
	}
	return link.URL
}

// displayName builds a person label out of the two name columns.
func displayName(first, last string) string {
	return fmt.Sprintf("%s %s", first, last)
}
