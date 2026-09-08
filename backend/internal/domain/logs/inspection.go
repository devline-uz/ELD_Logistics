package logs

import (
	"archive/zip"
	"bytes"
	"context"
	"encoding/csv"
	"fmt"
	"net/http"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/hos"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
)

// RestrictionInspection marks the roadside token: a limited capability
// principal that holds no permission at all, so every gated route rejects it
// and only the read only inspection endpoint accepts it (Q54).
const RestrictionInspection = "inspection"

// InspectionSession mints the short lived, read only roadside token (Q54).
//
// TODO(CR): the TZ D§3 endpoint table lists only /inspection/logs, /email and
// /transfer. `Begin Inspection` (Q54) needs an issuing point, so this module
// adds POST /inspection/begin; the contract table should be amended.
func (s *Service) InspectionSession(ctx context.Context, companyID uuid.UUID, p *tenant.Principal) (*dto.InspectionSession, error) {
	if s.tokens == nil {
		return nil, apierr.New(apierr.CodeUnavailable, http.StatusServiceUnavailable,
			"inspection mode is not configured on this deployment")
	}
	driver, err := s.duty.DriverByUser(ctx, companyID, p.UserID)
	if err != nil {
		return nil, err
	}
	limited := &tenant.Principal{
		UserID: p.UserID, CompanyID: p.CompanyID, RoleID: p.RoleID,
		Scope: tenant.ScopeSelf, BranchID: p.BranchID, SessionID: p.SessionID,
		DeviceType: p.DeviceType, Restricted: RestrictionInspection,
	}
	token, exp, err := s.tokens.Issue(limited)
	if err != nil {
		return nil, apierr.Internal(err, "failed to issue the inspection token")
	}
	return &dto.InspectionSession{
		Token: token, ExpiresAt: exp.UTC(),
		DriverID: driver.DriverID.String(),
	}, nil
}

// InspectionReport assembles the roadside window: 7 days plus today (Q53).
func (s *Service) InspectionReport(ctx context.Context, companyID, driverID uuid.UUID, date *time.Time) (*dto.InspectionReport, error) {
	driver, err := s.duty.DriverContext(ctx, companyID, driverID)
	if err != nil {
		return nil, err
	}
	loc := driver.Location()
	anchor := s.now().In(loc)
	if date != nil {
		anchor = time.Date(date.Year(), date.Month(), date.Day(), 12, 0, 0, 0, loc)
	}
	to := hos.StartOfDay(anchor, loc)
	from := to.AddDate(0, 0, -InspectionWindowDays)

	rows, _, err := s.repo.DailyLogs(ctx, DailyLogFilter{
		CompanyID: companyID, DriverID: driverID, From: from, To: to,
		Limit: InspectionWindowDays + 1, Offset: 0,
	})
	if err != nil {
		return nil, apierr.Internal(err, "failed to load the inspection window")
	}

	out := &dto.InspectionReport{
		DriverID: driverID.String(), Timezone: driver.Timezone,
		From: dayKeyOf(from), To: dayKeyOf(to), GeneratedAt: s.now().UTC(),
		Days: make([]dto.DailyLogDetail, 0, len(rows)),
	}
	for i := len(rows) - 1; i >= 0; i-- {
		full, err := s.DailyLog(ctx, companyID, rows[i].ID)
		if err != nil {
			return nil, err
		}
		if out.CarrierName == "" {
			out.CarrierName = full.CarrierName
			out.HomeTerminalAddress = full.HomeTerminalAddress
			out.RegulationProfile = full.RegulationProfile
			out.DriverName = full.DriverName
		}
		detail, err := s.Detail(ctx, full)
		if err != nil {
			return nil, err
		}
		out.Days = append(out.Days, *detail)
	}
	return out, nil
}

// DayReport wraps a single log day in the report shape so one day can be
// printed on its own (GET /daily-logs/{id}/pdf).
func (s *Service) DayReport(ctx context.Context, log DailyLog) (*dto.InspectionReport, error) {
	detail, err := s.Detail(ctx, log)
	if err != nil {
		return nil, err
	}
	return &dto.InspectionReport{
		DriverID: log.DriverID.String(), DriverName: log.DriverName,
		CarrierName: log.CarrierName, HomeTerminalAddress: log.HomeTerminalAddress,
		Timezone: log.Timezone, RegulationProfile: log.RegulationProfile,
		From: dayKeyOf(log.LogDate), To: dayKeyOf(log.LogDate),
		GeneratedAt: s.now().UTC(), Days: []dto.DailyLogDetail{*detail},
	}, nil
}

// RenderPDF prints a report. When headless Chrome is unavailable the renderer
// degrades to HTML and the content type says so.
func (s *Service) RenderPDF(ctx context.Context, rep *dto.InspectionReport) ([]byte, string, error) {
	html, err := RenderReportHTML(*rep)
	if err != nil {
		return nil, "", apierr.Internal(err, "failed to render the log report")
	}
	body, contentType, err := s.render.Render(ctx, html)
	if err != nil {
		return nil, "", apierr.Internal(err, "failed to print the log report")
	}
	return body, contentType, nil
}

// EmailInspection sends the roadside PDF (Q55).
func (s *Service) EmailInspection(ctx context.Context, companyID, driverID, by uuid.UUID,
	body dto.InspectionEmail,
) error {
	date, err := parseDay(body.Date)
	if err != nil {
		return err
	}
	rep, err := s.InspectionReport(ctx, companyID, driverID, date)
	if err != nil {
		return err
	}
	doc, contentType, err := s.RenderPDF(ctx, rep)
	if err != nil {
		return err
	}

	comment := ""
	if body.Comment != nil {
		comment = *body.Comment
	}
	if err := s.mailer.Send(ctx, Mail{
		To:         body.Email,
		Subject:    fmt.Sprintf("Driver's daily logs %s … %s — %s", rep.From, rep.To, rep.DriverName),
		Body:       comment,
		Attachment: doc, ContentType: contentType,
		Filename: fmt.Sprintf("eld-logs-%s-%s%s", rep.From, rep.To, extFor(contentType)),
	}); err != nil {
		return apierr.Internal(err, "failed to send the inspection report")
	}
	if err := s.audit.Record(ctx, audit.Entry{
		CompanyID: companyID, TableName: "daily_logs", RecordID: driverID,
		Action: audit.ActionExport, Field: "inspection_email", NewValue: rep.From + "/" + rep.To,
		EditedBy: by,
	}); err != nil {
		s.log.WarnContext(ctx, "failed to record the inspection e-mail", "error", err)
	}
	return nil
}

// TransferInspection produces the regulator output file (Q56). The `generic`
// profile ships a CSV + PDF archive.
func (s *Service) TransferInspection(ctx context.Context, companyID, driverID, by uuid.UUID,
	body dto.InspectionTransfer,
) (*dto.InspectionTransferResult, error) {
	date, err := parseDay(body.Date)
	if err != nil {
		return nil, err
	}
	rep, err := s.InspectionReport(ctx, companyID, driverID, date)
	if err != nil {
		return nil, err
	}
	if rep.RegulationProfile == "us_fmcsa" {
		// TODO(stage-7): the FMCSA ELD output file (web service / e-mail
		// transfer, §4.8.2.1) is a separate deliverable; refusing here is
		// better than shipping a non-conforming file.
		return nil, apierr.New(apierr.CodeFeatureDisabled, http.StatusNotImplemented,
			"the FMCSA ELD output file is delivered in stage 7; use regulation_profile=generic")
	}

	doc, contentType, err := s.RenderPDF(ctx, rep)
	if err != nil {
		return nil, err
	}
	archive, err := buildArchive(rep, doc, contentType)
	if err != nil {
		return nil, apierr.Internal(err, "failed to build the transfer archive")
	}

	key := storage.BuildKey(companyID, "inspection",
		fmt.Sprintf("eld-output-%s-%s.zip", rep.From, rep.To), s.now().UTC())
	if s.files != nil {
		if err := s.files.PutObject(ctx, key, archive, "application/zip"); err != nil {
			return nil, apierr.New(apierr.CodeStorageError, http.StatusBadGateway,
				"failed to store the transfer archive")
		}
	}
	if err := s.audit.Record(ctx, audit.Entry{
		CompanyID: companyID, TableName: "daily_logs", RecordID: driverID,
		Action: audit.ActionExport, Field: "file_key", NewValue: key, EditedBy: by,
	}); err != nil {
		s.log.WarnContext(ctx, "failed to record the transfer export", "error", err)
	}
	return &dto.InspectionTransferResult{
		FileKey: key, Format: "csv_pdf_zip", SizeBytes: int64(len(archive)),
		RegulationProfile: rep.RegulationProfile, GeneratedAt: s.now().UTC(),
	}, nil
}

// buildArchive packs the CSV event export next to the printed report.
func buildArchive(rep *dto.InspectionReport, doc []byte, contentType string) ([]byte, error) {
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)

	w, err := zw.Create("events.csv")
	if err != nil {
		return nil, err
	}
	cw := csv.NewWriter(w)
	if err := cw.Write([]string{
		"log_date", "event_time_utc", "event_type", "status", "special", "origin",
		"lat", "lng", "location", "odometer_m", "engine_hours", "notes",
	}); err != nil {
		return nil, err
	}
	for _, day := range rep.Days {
		for _, e := range day.Events {
			if err := cw.Write([]string{
				day.LogDate, e.EventTime.UTC().Format(time.RFC3339), e.EventType, e.Status,
				e.Special, e.Origin, floatOf(e.Lat), floatOf(e.Lng), stringOf(e.LocationText),
				intOf(e.OdometerM), floatOf(e.EngineHours), stringOf(e.Notes),
			}); err != nil {
				return nil, err
			}
		}
	}
	cw.Flush()
	if err := cw.Error(); err != nil {
		return nil, err
	}

	rw, err := zw.Create("logs" + extFor(contentType))
	if err != nil {
		return nil, err
	}
	if _, err := rw.Write(doc); err != nil {
		return nil, err
	}
	if err := zw.Close(); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

func extFor(contentType string) string {
	if contentType == "application/pdf" {
		return ".pdf"
	}
	return ".html"
}

func parseDay(v *string) (*time.Time, error) {
	if v == nil || *v == "" {
		return nil, nil
	}
	d, err := time.Parse(dayLayout, *v)
	if err != nil {
		return nil, apierr.Validation("date must be YYYY-MM-DD",
			apierr.FieldError{Field: "date", Message: "must be YYYY-MM-DD"})
	}
	return &d, nil
}

func stringOf(v *string) string {
	if v == nil {
		return ""
	}
	return *v
}

func floatOf(v *float64) string {
	if v == nil {
		return ""
	}
	return fmt.Sprintf("%g", *v)
}

func intOf(v *int64) string {
	if v == nil {
		return ""
	}
	return fmt.Sprintf("%d", *v)
}
