package reports

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"strconv"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/dvir"
	dvirdto "github.com/devline/onebook-eld/internal/domain/dvir/dto"
	"github.com/devline/onebook-eld/internal/domain/reports/dto"
)

// exportPageSize is how many rows one export pulls per query. Exports are
// bounded by exportMaxRows, so a runaway window cannot exhaust the worker.
const exportPageSize int32 = 500

// exportMaxRows caps one exported document.
const exportMaxRows = 100_000

// DvirLister is the DVIR module surface the DVIR report needs. Q31: the admin
// "Generate Report" builds a document out of the DVIRs that already exist, it
// never creates a new inspection — so this interface is read only by design.
// *dvir.Service satisfies it; wiring injects it so this package keeps no
// dependency on the DVIR storage layer.
type DvirLister interface {
	List(ctx context.Context, f dvir.ReportFilter) ([]dvirdto.DvirReport, int64, error)
}

// Artifact is one rendered export ready to be uploaded.
type Artifact struct {
	// FileName is the suggested download name, extension included.
	FileName string
	// ContentType is the MIME type of Body.
	ContentType string
	// Body is the rendered document.
	Body []byte
}

// Builder turns an export job into a rendered document. It is used by the
// worker only; the HTTP layer never renders inline.
type Builder struct {
	repo     Repo
	dvir     DvirLister
	renderer Renderer
	log      *slog.Logger
	now      func() time.Time
}

// NewBuilder builds the export renderer. A nil renderer falls back to HTML, a
// nil DvirLister disables the DVIR report with a clear error instead of a nil
// dereference.
func NewBuilder(repo Repo, dvirSvc DvirLister, renderer Renderer,
	log *slog.Logger, now func() time.Time) *Builder {
	if renderer == nil {
		renderer = HTMLRenderer{}
	}
	if log == nil {
		log = slog.Default()
	}
	if now == nil {
		now = time.Now
	}
	return &Builder{repo: repo, dvir: dvirSvc, renderer: renderer, log: log, now: now}
}

// Build renders one job. The company context must already be set on ctx.
func (b *Builder) Build(ctx context.Context, job db.ReportExportJob) (Artifact, error) {
	var params dto.ExportParams
	if len(job.Params) > 0 {
		if err := json.Unmarshal(job.Params, &params); err != nil {
			return Artifact{}, apierr.Validation("the stored export params are unreadable")
		}
	}

	if job.Type == dto.TypeRegulator {
		return b.buildRegulator(ctx, params)
	}

	table, slug, err := b.table(ctx, job.Type, params)
	if err != nil {
		return Artifact{}, err
	}
	return b.render(ctx, table, job.Format, slug)
}

// table produces the tabular dataset of one report type together with the file
// name slug it is delivered under.
func (b *Builder) table(ctx context.Context, reportType string, p dto.ExportParams) (Table, string, error) {
	switch reportType {
	case dto.TypeActivity:
		return b.activityTable(ctx, p)
	case dto.TypeDistanceByRegion:
		return b.regionTable(ctx, p)
	case dto.TypeHOS:
		return b.hosTable(ctx, p)
	case dto.TypeDVIR:
		return b.dvirTable(ctx, p)
	default:
		return Table{}, "", apierr.Validation("unknown export type",
			apierr.FieldError{Field: "type", Message: "must be one of: " + joinTypes()})
	}
}

// render turns a table into the requested format.
func (b *Builder) render(ctx context.Context, t Table, format, slug string) (Artifact, error) {
	switch format {
	case dto.FormatCSV:
		body, err := RenderCSV(t)
		if err != nil {
			return Artifact{}, apierr.Internal(err, "failed to render the CSV export")
		}
		return Artifact{FileName: slug + ".csv", ContentType: contentTypeFor(dto.FormatCSV), Body: body}, nil
	case dto.FormatPDF:
		html, err := RenderHTML(t)
		if err != nil {
			return Artifact{}, apierr.Internal(err, "failed to render the report")
		}
		body, contentType, err := b.renderer.Render(ctx, html)
		if err != nil {
			return Artifact{}, apierr.Internal(err, "failed to print the report")
		}
		return Artifact{FileName: slug + extFor(contentType, dto.FormatPDF), ContentType: contentType, Body: body}, nil
	default:
		body, err := RenderXLSX(t)
		if err != nil {
			return Artifact{}, apierr.Internal(err, "failed to render the workbook")
		}
		return Artifact{FileName: slug + ".xlsx", ContentType: contentTypeFor(dto.FormatXLSX), Body: body}, nil
	}
}

// activityTable builds the Q75 odometer report.
func (b *Builder) activityTable(ctx context.Context, p dto.ExportParams) (Table, string, error) {
	from, to, err := ParseWindow(p.From, p.To)
	if err != nil {
		return Table{}, "", err
	}
	subject := p.Subject
	if subject != dto.SubjectDrivers {
		subject = dto.SubjectUnits
	}
	f := ActivityFilter{
		Subject: subject, From: from, To: to.AddDate(0, 0, 1),
		DriverIDs: mustUUIDs(p.DriverIDs), UnitIDs: mustUUIDs(p.UnitIDs),
		BranchID: optUUID(p.BranchID), Limit: exportPageSize,
	}

	t := Table{
		Title:    "Activity report",
		Subtitle: fmt.Sprintf("%s · %s — %s", subject, p.From, p.To),
		Headers:  []string{"Subject", "Name", "Start odometer (m)", "End odometer (m)", "Odometer change (m)"},
	}
	for offset := int32(0); ; offset += exportPageSize {
		f.Offset = offset
		var rows []dto.ActivityRow
		if subject == dto.SubjectDrivers {
			raw, _, err := b.repo.ActivityDrivers(ctx, f)
			if err != nil {
				return Table{}, "", apierr.Internal(err, "failed to read the activity report")
			}
			for _, r := range raw {
				rows = append(rows, activityRow(r.DriverID.String(), dto.SubjectDrivers,
					displayName(r.FirstName, r.LastName), r.StartOdometerM, r.EndOdometerM, r.Samples))
			}
		} else {
			raw, _, err := b.repo.ActivityUnits(ctx, f)
			if err != nil {
				return Table{}, "", apierr.Internal(err, "failed to read the activity report")
			}
			for _, r := range raw {
				rows = append(rows, activityRow(r.UnitID.String(), dto.SubjectUnits,
					r.UnitNumber, r.StartOdometerM, r.EndOdometerM, r.Samples))
			}
		}
		for _, r := range rows {
			t.Rows = append(t.Rows, []string{
				r.SubjectType, r.Name,
				metresRow(r.StartOdometerM), metresRow(r.EndOdometerM), metresRow(r.OdometerChangeM),
			})
		}
		//nolint:gosec // G115: rows is capped at exportPageSize (SQL LIMIT)
		if int32(len(rows)) < exportPageSize || len(t.Rows) >= exportMaxRows {
			break
		}
	}
	return t, fmt.Sprintf("activity-%s-%s-%s", subject, p.From, p.To), nil
}

// regionTable builds the quarterly Distance by Region report out of the daily
// roll-up, so the export is as immediate as the live endpoint.
func (b *Builder) regionTable(ctx context.Context, p dto.ExportParams) (Table, string, error) {
	from, to, err := QuarterRange(p.Quarter, p.Year)
	if err != nil {
		return Table{}, "", err
	}
	mode := p.Mode
	if mode != dto.ModeRegionsOnly {
		mode = dto.ModeRegionsAndUnits
	}
	f := RegionFilter{From: from, To: to, UnitIDs: mustUUIDs(p.UnitIDs), BranchID: optUUID(p.BranchID)}

	t := Table{
		Title:    "Distance by Region",
		Subtitle: fmt.Sprintf("Q%d %d · %s", p.Quarter, p.Year, mode),
	}
	if mode == dto.ModeRegionsOnly {
		rows, err := b.repo.RegionTotals(ctx, f)
		if err != nil {
			return Table{}, "", apierr.Internal(err, "failed to read the distance roll-up")
		}
		t.Headers = []string{"Region", "Name", "Country", "Distance (m)"}
		for _, r := range rows {
			t.Rows = append(t.Rows, []string{r.RegionCode, r.RegionName, r.Country, metresRow(r.DistanceM)})
		}
	} else {
		rows, err := b.repo.RegionByUnit(ctx, f)
		if err != nil {
			return Table{}, "", apierr.Internal(err, "failed to read the distance roll-up")
		}
		t.Headers = []string{"Unit", "Region", "Name", "Country", "Distance (m)"}
		for _, r := range rows {
			t.Rows = append(t.Rows, []string{
				r.UnitNumber, r.RegionCode, r.RegionName, r.Country, metresRow(r.DistanceM),
			})
		}
	}
	return t, fmt.Sprintf("distance-by-region-%d-Q%d", p.Year, p.Quarter), nil
}

// hosTable builds the per driver daily hours of service summary.
func (b *Builder) hosTable(ctx context.Context, p dto.ExportParams) (Table, string, error) {
	from, to, err := ParseWindow(p.From, p.To)
	if err != nil {
		return Table{}, "", err
	}
	f := HosFilter{From: from, To: to, DriverIDs: mustUUIDs(p.DriverIDs),
		BranchID: optUUID(p.BranchID), Limit: exportPageSize}

	t := Table{
		Title:    "HOS summary",
		Subtitle: fmt.Sprintf("%s — %s", p.From, p.To),
		Headers: []string{"Driver", "Date", "Driving (s)", "On duty (s)", "Sleeper (s)",
			"Off duty (s)", "Distance (m)", "Certification", "Violations"},
	}
	for offset := int32(0); ; offset += exportPageSize {
		f.Offset = offset
		rows, _, err := b.repo.HosSummary(ctx, f)
		if err != nil {
			return Table{}, "", apierr.Internal(err, "failed to read the HOS summary")
		}
		for _, r := range rows {
			t.Rows = append(t.Rows, []string{
				displayName(r.FirstName, r.LastName),
				r.LogDate.Time.Format(time.DateOnly),
				strconv.FormatInt(r.DrivingSec, 10), strconv.FormatInt(r.OnDutySec, 10),
				strconv.FormatInt(r.SleeperSec, 10), strconv.FormatInt(r.OffDutySec, 10),
				metresRow(r.DistanceM), r.CertificationStatus,
				strconv.FormatInt(r.Violations, 10),
			})
		}
		//nolint:gosec // G115: rows is capped at exportPageSize (SQL LIMIT)
		if int32(len(rows)) < exportPageSize || len(t.Rows) >= exportMaxRows {
			break
		}
	}
	return t, fmt.Sprintf("hos-summary-%s-%s", p.From, p.To), nil
}

// dvirTable builds the Q31 admin DVIR report: a filtered list of the
// inspections that already exist, never a new one.
func (b *Builder) dvirTable(ctx context.Context, p dto.ExportParams) (Table, string, error) {
	if b.dvir == nil {
		return Table{}, "", apierr.New(apierr.CodeUnavailable, 503,
			"the DVIR module is not wired, the DVIR report cannot be built")
	}
	from, to, err := ParseWindow(p.From, p.To)
	if err != nil {
		return Table{}, "", err
	}
	toEnd := to.AddDate(0, 0, 1)
	f := dvir.ReportFilter{From: &from, To: &toEnd, BranchID: optUUID(p.BranchID), Limit: exportPageSize}
	if ids := mustUUIDs(p.UnitIDs); len(ids) == 1 {
		f.UnitID = &ids[0]
	}
	if ids := mustUUIDs(p.DriverIDs); len(ids) == 1 {
		f.DriverID = &ids[0]
	}

	t := Table{
		Title:    "DVIR report",
		Subtitle: fmt.Sprintf("%s — %s", p.From, p.To),
		Headers: []string{"Performed at", "Unit", "Type", "Status", "Defects",
			"Critical", "Out of service", "Location", "Odometer (m)"},
	}
	for offset := int32(0); ; offset += exportPageSize {
		f.Offset = offset
		rows, _, err := b.dvir.List(ctx, f)
		if err != nil {
			return Table{}, "", err
		}
		for _, r := range rows {
			t.Rows = append(t.Rows, []string{
				r.PerformedAt.UTC().Format(time.RFC3339), r.UnitNumber, r.Type, r.Status,
				strconv.Itoa(len(r.Defects)), boolCell(r.HasCriticalDefect), boolCell(r.OutOfService),
				r.LocationText, optionalMetres(r.OdometerM),
			})
		}
		//nolint:gosec // G115: rows is capped at exportPageSize (SQL LIMIT)
		if int32(len(rows)) < exportPageSize || len(t.Rows) >= exportMaxRows {
			break
		}
	}
	return t, fmt.Sprintf("dvir-%s-%s", p.From, p.To), nil
}

// buildRegulator packs the `generic` profile bundle: one printable document
// and one machine readable CSV of the same HOS window (TZ §14). The FMCSA
// output file and web service are stage two and are refused before a job is
// ever queued.
func (b *Builder) buildRegulator(ctx context.Context, p dto.ExportParams) (Artifact, error) {
	table, slug, err := b.hosTable(ctx, p)
	if err != nil {
		return Artifact{}, err
	}
	table.Title = "Regulator export"
	if p.Comment != "" {
		table.Subtitle += " · " + p.Comment
	}

	csvBody, err := RenderCSV(table)
	if err != nil {
		return Artifact{}, apierr.Internal(err, "failed to render the regulator CSV")
	}
	html, err := RenderHTML(table)
	if err != nil {
		return Artifact{}, apierr.Internal(err, "failed to render the regulator document")
	}
	doc, contentType, err := b.renderer.Render(ctx, html)
	if err != nil {
		return Artifact{}, apierr.Internal(err, "failed to print the regulator document")
	}

	name := "regulator-" + slug
	body, err := RenderZIP([]zipEntry{
		{Name: name + extFor(contentType, dto.FormatPDF), Body: doc},
		{Name: name + ".csv", Body: csvBody},
	})
	if err != nil {
		return Artifact{}, apierr.Internal(err, "failed to pack the regulator bundle")
	}
	return Artifact{FileName: name + ".zip", ContentType: contentTypeFor(dto.FormatZIP), Body: body}, nil
}

// mustUUIDs parses the id filters, silently dropping anything unparseable: the
// request was already validated, and a bad id must narrow nothing.
// optUUID parses the branch the job was frozen with. An unparsable value is
// dropped rather than widened into "no filter" by accident: the caller side
// validates it as a uuid before the job is stored.
func optUUID(in string) *uuid.UUID {
	if in == "" {
		return nil
	}
	id, err := uuid.Parse(in)
	if err != nil {
		return nil
	}
	return &id
}

func mustUUIDs(in []string) []uuid.UUID {
	if len(in) == 0 {
		return nil
	}
	out := make([]uuid.UUID, 0, len(in))
	for _, s := range in {
		if id, err := uuid.Parse(s); err == nil {
			out = append(out, id)
		}
	}
	if len(out) == 0 {
		return nil
	}
	return out
}

func boolCell(v bool) string {
	if v {
		return "yes"
	}
	return "no"
}

func optionalMetres(v *int64) string {
	if v == nil {
		return ""
	}
	return metresRow(*v)
}

func joinTypes() string {
	out := ""
	for i, t := range dto.Types {
		if i > 0 {
			out += ", "
		}
		out += t
	}
	return out
}
