package logs

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/domain/duty"
	"github.com/devline/onebook-eld/internal/domain/logs/dto"
)

// CertificationWindowDays is the global Q19 constant: the driver's log list and
// the "ready to certify" alerts cover the last 8 days.
const CertificationWindowDays = 8

// InspectionWindowDays is Q53: 7 days plus today.
const InspectionWindowDays = 7

// DutyService is the subset of the duty domain the logs module reuses. It is
// satisfied by *duty.Service; the duty module is never re-implemented here.
type DutyService interface {
	DriverContext(ctx context.Context, companyID, driverID uuid.UUID) (duty.Context, error)
	DriverByUser(ctx context.Context, companyID, userID uuid.UUID) (duty.Context, error)
	Policy(ctx context.Context, companyID uuid.UUID, at time.Time) (duty.PolicyVersion, error)
}

// Service is the daily log, certification, edit, unidentified driving,
// violation and inspection business layer.
type Service struct {
	repo   Repo
	duty   DutyService
	now    func() time.Time
	log    *slog.Logger
	render Renderer
	mailer Mailer
	files  ObjectStore
	tokens TokenIssuer
	audit  audit.Recorder
	// alerter delivers the TZ A§5.3 propose/resolve notifications.
	alerter Alerter
}

// NewService builds the logs service. now is injectable so the home terminal
// day boundary and the certification window are testable.
func NewService(d Deps) *Service {
	s := &Service{
		repo: d.Repo, duty: d.Duty, now: d.Now, log: d.Log,
		render: d.Renderer, mailer: d.Mailer, files: d.Files, tokens: d.Tokens,
		audit: d.Audit, alerter: d.Alerter,
	}
	if s.now == nil {
		s.now = time.Now
	}
	if s.log == nil {
		s.log = slog.Default()
	}
	if s.render == nil {
		s.render = HTMLRenderer{}
	}
	if s.mailer == nil {
		s.mailer = LogMailer{Log: s.log}
	}
	if s.audit == nil {
		s.audit = audit.NopRecorder{}
	}
	if s.alerter == nil {
		s.alerter = NopAlerter{}
	}
	return s
}

// alert fans an event out to the notification module. A delivery failure is
// logged, never surfaced to the caller: the propose/approve write already
// committed and must not roll back because a push notification failed.
func (s *Service) alert(ctx context.Context, kind string, a Alert) {
	if err := s.alerter.Alert(ctx, kind, a); err != nil {
		s.log.ErrorContext(ctx, "logs: alert not delivered",
			slog.String("alert", kind), slog.String("error", err.Error()))
	}
}

// ---------------------------------------------------------------- daily logs

// DriverLogs returns one driver's certification window (Q19).
func (s *Service) DriverLogs(ctx context.Context, f DailyLogFilter) ([]dto.DailyLogSummary, int64, error) {
	rows, total, err := s.repo.DailyLogs(ctx, f)
	if err != nil {
		return nil, 0, apierr.Internal(err, "failed to list daily logs")
	}
	out := make([]dto.DailyLogSummary, 0, len(rows))
	for _, row := range rows {
		out = append(out, summaryDTO(row))
	}
	return out, total, nil
}

// DailyLog resolves one log day, answering 404 for a cross-tenant id.
func (s *Service) DailyLog(ctx context.Context, companyID, id uuid.UUID) (DailyLog, error) {
	row, err := s.repo.DailyLog(ctx, companyID, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return DailyLog{}, apierr.NotFound("daily log")
	}
	if err != nil {
		return DailyLog{}, apierr.Internal(err, "failed to load daily log")
	}
	return row, nil
}

// Detail assembles the log day: events, log form (Q16) and violations.
func (s *Service) Detail(ctx context.Context, log DailyLog) (*dto.DailyLogDetail, error) {
	events, err := s.repo.DayEvents(ctx, log.CompanyID, log.ID)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load log events")
	}
	form, err := s.form(ctx, log)
	if err != nil {
		return nil, err
	}
	violations, err := s.repo.LogViolations(ctx, log.CompanyID, log.ID)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load violations")
	}

	out := &dto.DailyLogDetail{
		DailyLogSummary: summaryDTO(log),
		Form:            form,
		Events:          make([]dto.LogEvent, 0, len(events)),
		Violations:      make([]dto.Violation, 0, len(violations)),
	}
	for _, e := range events {
		out.Events = append(out.Events, eventDTO(e))
	}
	for _, v := range violations {
		out.Violations = append(out.Violations, violationDTO(v))
	}
	return out, nil
}

// form builds the Q16 log header. Distance comes from telemetry and is never
// edited by hand.
func (s *Service) form(ctx context.Context, log DailyLog) (dto.LogForm, error) {
	units, err := s.repo.Units(ctx, log.CompanyID, log.UnitIDs)
	if err != nil {
		return dto.LogForm{}, apierr.Internal(err, "failed to load units")
	}
	trailers, err := s.repo.Trailers(ctx, log.CompanyID, log.TrailerIDs)
	if err != nil {
		return dto.LogForm{}, apierr.Internal(err, "failed to load trailers")
	}
	docs, err := s.repo.ShippingDocs(ctx, log.CompanyID, log.ShippingDocIDs)
	if err != nil {
		return dto.LogForm{}, apierr.Internal(err, "failed to load shipping documents")
	}

	form := dto.LogForm{
		Units:          make([]dto.UnitRef, 0, len(units)),
		DriverName:     log.DriverName,
		CoDriverName:   log.CoDriverName,
		DistanceM:      log.DistanceM,
		Trailers:       make([]dto.NumberRef, 0, len(trailers)),
		ShippingDocs:   make([]dto.NumberRef, 0, len(docs)),
		SignatureKey:   log.SignatureKey,
		SignedAt:       log.SignedAt,
		SignedDeviceID: log.SignedDeviceID,
		SignedIP:       log.SignedIP,
		CarrierName:    log.CarrierName,

		HomeTerminalAddress: log.HomeTerminalAddress,
	}
	for _, u := range units {
		form.Units = append(form.Units, dto.UnitRef{
			ID: u.ID.String(), UnitNumber: u.UnitNumber, VIN: u.VIN, LicensePlate: u.LicensePlate,
		})
	}
	for _, t := range trailers {
		form.Trailers = append(form.Trailers, dto.NumberRef{ID: t.ID.String(), Number: t.Number})
	}
	for _, d := range docs {
		form.ShippingDocs = append(form.ShippingDocs, dto.NumberRef{ID: d.ID.String(), Number: d.Number})
	}
	return form, nil
}

// CertifyInputAPI is the certification request as the handler assembled it.
type CertifyInputAPI struct {
	CompanyID  uuid.UUID
	DailyLogID uuid.UUID
	UserID     uuid.UUID
	Body       dto.CertifyRequest
	IP         string
}

// Certify signs one log day (Q26.1). Q26: only the driver may sign, never an
// administrator on the driver's behalf; the caller enforces the self scope.
func (s *Service) Certify(ctx context.Context, in CertifyInputAPI) (*dto.DailyLogDetail, error) {
	log, err := s.DailyLog(ctx, in.CompanyID, in.DailyLogID)
	if err != nil {
		return nil, err
	}

	key, err := s.signatureKey(ctx, log, in)
	if err != nil {
		return nil, err
	}

	now := s.now().UTC()
	entries := []audit.Entry{{
		TableName: "daily_logs", RecordID: log.ID, Action: audit.ActionCertify,
		Field: "certification_status", NewValue: certCertified,
	}}
	if _, err := s.repo.Certify(ctx, CertifyInput{
		CompanyID: in.CompanyID, DailyLogID: log.ID, DriverID: log.DriverID, UserID: in.UserID,
		SignatureKey: key, DeviceID: in.Body.DeviceID, IP: nilIfEmpty(in.IP),
		SignedAt: now, ClientEventID: uuid.New(),
	}, entries); err != nil {
		return nil, apierr.Internal(err, "failed to certify the daily log")
	}

	fresh, err := s.DailyLog(ctx, in.CompanyID, log.ID)
	if err != nil {
		return nil, err
	}
	// Certification closes `uncertified_log` and turns an empty trailer/doc
	// field from a warning into a violation (Q57).
	if err := s.SyncDayViolations(ctx, fresh); err != nil {
		s.log.WarnContext(ctx, "violation recomputation failed", "error", err)
	}
	return s.Detail(ctx, fresh)
}

// signatureKey resolves the signature source (Q20-Q24). The stored signature
// always belongs to the signing user, so an administrator can never paste
// someone else's image (Q26).
func (s *Service) signatureKey(ctx context.Context, log DailyLog, in CertifyInputAPI) (string, error) {
	if in.Body.SignatureKey != nil && *in.Body.SignatureKey != "" {
		return *in.Body.SignatureKey, nil
	}
	var id *uuid.UUID
	if in.Body.SignatureID != nil && *in.Body.SignatureID != "" {
		parsed, err := uuid.Parse(*in.Body.SignatureID)
		if err != nil {
			return "", apierr.Validation("signature_id must be a uuid",
				apierr.FieldError{Field: "signature_id", Message: apierr.MsgMustBeUUID})
		}
		id = &parsed
	}
	key, err := s.repo.SignatureKey(ctx, log.CompanyID, log.DriverUserID, id)
	if errors.Is(err, pgx.ErrNoRows) {
		// Q25: `Not Ready` means exactly one thing — no signature yet.
		return "", apierr.New(apierr.CodeLogNotReady, 409,
			"no signature available; draw one or store a default signature first")
	}
	if err != nil {
		return "", apierr.Internal(err, "failed to load the signature")
	}
	return key, nil
}

// UncertifiedReport lists the days that fell out of the 8 day window without a
// signature (Q19.1).
func (s *Service) UncertifiedReport(ctx context.Context, f UncertifiedFilter) ([]dto.UncertifiedLog, int64, error) {
	rows, total, err := s.repo.UncertifiedOlderThan(ctx, f)
	if err != nil {
		return nil, 0, apierr.Internal(err, "failed to list uncertified logs")
	}
	out := make([]dto.UncertifiedLog, 0, len(rows))
	for _, row := range rows {
		overdue := int(f.Before.Sub(row.LogDate).Hours() / 24)
		if overdue < 0 {
			overdue = 0
		}
		out = append(out, dto.UncertifiedLog{
			DailyLogID: row.DailyLogID.String(), DriverID: row.DriverID.String(),
			DriverName: row.DriverName, LogDate: dayKeyOf(row.LogDate),
			CertificationStatus: row.CertificationStatus, DaysOverdue: overdue,
		})
	}
	return out, total, nil
}

// ---------------------------------------------------------------- mapping

// storedTotals decodes the daily_logs.totals document.
type storedTotals struct {
	Off   int64 `json:"off"`
	SB    int64 `json:"sb"`
	Drive int64 `json:"dr"`
	On    int64 `json:"on"`
}

func summaryDTO(l DailyLog) dto.DailyLogSummary {
	var t storedTotals
	if len(l.Totals) > 0 {
		_ = json.Unmarshal(l.Totals, &t)
	}
	out := dto.DailyLogSummary{
		ID: l.ID.String(), DriverID: l.DriverID.String(), DriverName: l.DriverName,
		LogDate: dayKeyOf(l.LogDate), Timezone: l.Timezone,
		CertificationStatus: l.CertificationStatus,
		Ready:               l.Certified() && l.SignedAt != nil,
		SignedAt:            l.SignedAt, DistanceM: l.DistanceM,
		Totals:       dto.DayTotals{OffMin: t.Off, SBMin: t.SB, DriveMin: t.Drive, OnMin: t.On},
		UnitIDs:      idStrings(l.UnitIDs),
		CoDriverName: l.CoDriverName,
		UpdatedAt:    l.UpdatedAt,
	}
	return out
}

func eventDTO(e Event) dto.LogEvent {
	out := dto.LogEvent{
		ID: e.ID.String(), EventType: e.EventType, Special: e.Special, Origin: e.Origin,
		EventTime: e.EventTime.UTC(), TimeSource: e.TimeSource, ReceivedAt: e.ReceivedAt.UTC(),
		UnitNumber: e.UnitNumber, Lat: e.Lat, Lng: e.Lng, LocationText: e.LocationText,
		OdometerM: e.OdometerM, EngineHours: e.EngineHours, Notes: e.Notes,
		Edited: e.Origin == originDriverEdit || e.Origin == originAdminEdit,
		Locked: e.Locked,
	}
	if e.Status != nil {
		out.Status = *e.Status
	}
	if e.UnitID != nil {
		v := e.UnitID.String()
		out.UnitID = &v
	}
	if e.SupersededBy != nil {
		v := e.SupersededBy.String()
		out.SupersededBy = &v
	}
	return out
}

func violationDTO(v ViolationRow) dto.Violation {
	out := dto.Violation{
		ID: v.ID.String(), DriverName: v.DriverName, Type: v.Type, Severity: v.Severity,
		OccurredAt: v.OccurredAt.UTC(), ResolvedAt: v.ResolvedAt, ResolvedReason: v.ResolvedReason,
		CreatedAt: v.CreatedAt.UTC(),
	}
	if len(v.Details) > 0 {
		_ = json.Unmarshal(v.Details, &out.Details)
	}
	out.DriverID = idString(v.DriverID)
	out.DailyLogID = idString(v.DailyLogID)
	out.UnitID = idString(v.UnitID)
	out.PolicyVersionID = idString(v.PolicyVersionID)
	if v.LogDate != nil {
		d := dayKeyOf(*v.LogDate)
		out.LogDate = &d
	}
	return out
}

func idString(id *uuid.UUID) *string {
	if id == nil {
		return nil
	}
	s := id.String()
	return &s
}

func idStrings(ids []uuid.UUID) []string {
	out := make([]string, 0, len(ids))
	for _, id := range ids {
		out = append(out, id.String())
	}
	return out
}

func nilIfEmpty(v string) *string {
	if v == "" {
		return nil
	}
	return &v
}

// dayOf resolves the local log day of a stored daily_logs row (Q10.2).
func dayOf(l DailyLog) (time.Time, *time.Location) {
	loc := l.Location()
	return localDay(l.LogDate, loc), loc
}
