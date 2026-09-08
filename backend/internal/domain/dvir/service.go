package dvir

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
	"github.com/devline/onebook-eld/internal/tenant"
)

// CertificationGraceDays is the Q30.1 fallback window: after this many days
// without a follow-up DVIR the report is closed instead of waiting forever.
const CertificationGraceDays = 7

// pendingCertificationLimit bounds the driver facing pending list.
const pendingCertificationLimit = 50

// closeBatchLimit bounds one fallback sweep.
const closeBatchLimit = 500

// transitions is the DVIR state machine of TZ §7.2. The key is the current
// status, the value the set of statuses reachable from it.
var transitions = map[string]map[string]bool{
	dto.StatusDraft: {
		dto.StatusSubmittedNoDefects:    true,
		dto.StatusSubmittedDefectsFound: true,
	},
	dto.StatusSubmittedDefectsFound: {
		dto.StatusRepaired:              true,
		dto.StatusClosedNoCertification: true,
	},
	dto.StatusRepaired: {
		dto.StatusCertified:             true,
		dto.StatusClosedNoCertification: true,
	},
	dto.StatusSubmittedNoDefects:    {},
	dto.StatusCertified:             {},
	dto.StatusClosedNoCertification: {},
}

// CanTransition reports whether from -> to is a legal DVIR transition.
func CanTransition(from, to string) bool {
	next, ok := transitions[from]
	return ok && next[to]
}

// Service holds the DVIR business rules.
type Service struct {
	repo     Repo
	alerter  Alerter
	renderer Renderer
	log      *slog.Logger
	now      func() time.Time
}

// NewService builds the service. A nil alerter degrades to NopAlerter so the
// module runs before the notification module is wired.
func NewService(repo Repo, alerter Alerter, renderer Renderer, log *slog.Logger, now func() time.Time) *Service {
	if alerter == nil {
		alerter = NopAlerter{}
	}
	if renderer == nil {
		renderer = HTMLRenderer{}
	}
	if log == nil {
		log = slog.Default()
	}
	if now == nil {
		now = time.Now
	}
	return &Service{repo: repo, alerter: alerter, renderer: renderer, log: log, now: now}
}

// SelfDriver resolves the caller's own driver record (Q31 — a DVIR is always
// the driver's own act, never an administrator's on the driver's behalf).
func (s *Service) SelfDriver(ctx context.Context) (db.GetDvirDriverByUserRow, error) {
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok {
		return db.GetDvirDriverByUserRow{}, apierr.Unauthorized("authentication required")
	}
	row, err := s.repo.DriverByUser(ctx, p.UserID)
	if err != nil {
		return db.GetDvirDriverByUserRow{}, apierr.New(apierr.CodeDVIRAdminCreateDenied, http.StatusForbidden,
			"only a driver may submit or certify a DVIR")
	}
	return row, nil
}

// Create stores one submitted inspection (Q28, Q27.1, Q27.2).
func (s *Service) Create(ctx context.Context, in dto.DvirCreate) (*dto.DvirReport, error) {
	driver, err := s.SelfDriver(ctx)
	if err != nil {
		return nil, err
	}
	unitID, err := uuid.Parse(in.UnitID)
	if err != nil {
		return nil, apierr.Validation("unit_id must be a uuid",
			apierr.FieldError{Field: "unit_id", Message: "must be a uuid"})
	}
	unit, err := s.repo.Unit(ctx, unitID)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	trailerIDs, err := s.resolveTrailers(ctx, in.TrailerIDs)
	if err != nil {
		return nil, err
	}
	if err := ownsKey(ctx, "driver_signature_key", in.DriverSignatureKey); err != nil {
		return nil, err
	}
	defects, critical, err := s.resolveDefects(ctx, in.Defects)
	if err != nil {
		return nil, err
	}

	status := dto.StatusSubmittedNoDefects
	if len(defects) > 0 {
		status = dto.StatusSubmittedDefectsFound
	}
	if !CanTransition(dto.StatusDraft, status) {
		return nil, s.invalidTransition(dto.StatusDraft, status)
	}

	payload, err := json.Marshal(defects)
	if err != nil {
		return nil, apierr.Internal(err, "could not encode defects")
	}

	// Q28 — time, location and odometer come from telemetry, never the body.
	params := db.CreateDvirReportParams{
		CompanyID:          tenant.CompanyID(ctx),
		UnitID:             unitID,
		DriverID:           driver.ID,
		Type:               in.Type,
		TrailerIds:         trailerIDs,
		Status:             status,
		Defects:            payload,
		Source:             dto.SourceApp,
		PerformedAt:        s.now().UTC(),
		DriverSignatureKey: strPtr(in.DriverSignatureKey),
	}
	if st, err := s.repo.LastState(ctx, unitID); err == nil {
		params.Lat, params.Lng = st.Lat, st.Lng
		params.OdometerM = st.OdometerM
		params.EngineHours = st.EngineHours
	} else if !errors.Is(err, context.Canceled) {
		s.log.DebugContext(ctx, "dvir: no telemetry state for unit", slog.String("unit_id", unitID.String()))
	}
	if in.Notes != "" {
		params.LocationText = strPtr(in.Notes)
	}

	row, err := s.repo.Create(ctx, CreateInput{Report: params, OutOfService: critical})
	if err != nil {
		return nil, db.MapError(err, "dvir report")
	}
	rep := reportFromDetail(row)
	s.notifyCreated(ctx, rep, critical, unit.UnitNumber)
	return &rep, nil
}

// Get returns one report; a cross-tenant id answers 404.
func (s *Service) Get(ctx context.Context, id uuid.UUID) (*dto.DvirReport, error) {
	row, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "dvir report")
	}
	rep := reportFromDetail(row)
	return &rep, nil
}

// List returns a page of reports.
func (s *Service) List(ctx context.Context, f ReportFilter) ([]dto.DvirReport, int64, error) {
	rows, total, err := s.repo.List(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "dvir report")
	}
	out := make([]dto.DvirReport, 0, len(rows))
	for _, r := range rows {
		out = append(out, reportFromList(r))
	}
	return out, total, nil
}

// PendingCertification lists the reports whose defects still wait for the
// driver's confirmation on the next pre-trip inspection (TZ §7.2).
func (s *Service) PendingCertification(ctx context.Context, unitID *uuid.UUID) ([]dto.DvirReport, error) {
	rows, err := s.repo.PendingCertification(ctx, unitID, pendingCertificationLimit)
	if err != nil {
		return nil, db.MapError(err, "dvir report")
	}
	out := make([]dto.DvirReport, 0, len(rows))
	for _, r := range rows {
		out = append(out, reportFromPending(r))
	}
	return out, nil
}

// Repair applies the Service Manager transition (Q27).
func (s *Service) Repair(ctx context.Context, id uuid.UUID, in dto.DvirRepair) (*dto.DvirReport, error) {
	current, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "dvir report")
	}
	if !CanTransition(current.Status, dto.StatusRepaired) {
		return nil, s.invalidTransition(current.Status, dto.StatusRepaired)
	}

	if err := ownsKey(ctx, "mechanic_signature_key", in.MechanicSignatureKey); err != nil {
		return nil, err
	}
	if err := ownsKey(ctx, "invoice_key", in.InvoiceKey); err != nil {
		return nil, err
	}

	userID := tenant.UserID(ctx)
	params := db.RepairDvirReportParams{
		CompanyID:            tenant.CompanyID(ctx),
		ID:                   id,
		MechanicID:           uuidToPG(userID),
		MechanicNote:         strPtr(in.MechanicNote),
		MechanicSignatureKey: strPtr(in.MechanicSignatureKey),
	}
	input := RepairInput{ID: id, Params: params, EditedBy: userID}
	if in.InvoiceKey != "" || in.InvoiceNo != "" || in.Vendor != "" || in.Cost != nil {
		rec := db.CreateMaintenanceRecordParams{
			CompanyID:   tenant.CompanyID(ctx),
			UnitID:      current.UnitID,
			Status:      "completed",
			PerformedAt: s.now().UTC(),
			Currency:    "USD",
			InvoiceNo:   strPtr(in.InvoiceNo),
			Vendor:      strPtr(in.Vendor),
			InvoiceKey:  strPtr(in.InvoiceKey),
			OdometerM:   current.OdometerM,
			Notes:       strPtr("DVIR repair " + id.String()),
		}
		if in.Cost != nil {
			rec.Cost = floatToNumeric(*in.Cost)
		}
		input.Invoice = &rec
	}

	row, err := s.repo.Repair(ctx, input)
	if err != nil {
		return nil, db.MapError(err, "dvir report")
	}
	rep := reportFromDetail(row)
	s.alert(ctx, AlertPendingCertification, Alert{
		CompanyID: row.CompanyID, DvirID: row.ID, UnitID: row.UnitID,
		UnitNumber: row.UnitNumber, DriverID: row.DriverID,
		Message: "defects repaired, driver confirmation required",
	})
	return &rep, nil
}

// Certify records the driver's "Previous defects repaired?" signature. Q30.1
// accepts a different driver of the same tenant, so the caller only has to be
// a driver.
func (s *Service) Certify(ctx context.Context, id uuid.UUID, in dto.DvirCertify) (*dto.DvirReport, error) {
	driver, err := s.SelfDriver(ctx)
	if err != nil {
		return nil, err
	}
	current, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "dvir report")
	}
	if !CanTransition(current.Status, dto.StatusCertified) {
		return nil, s.invalidTransition(current.Status, dto.StatusCertified)
	}
	if err := ownsKey(ctx, "signature_key", in.SignatureKey); err != nil {
		return nil, err
	}
	row, err := s.repo.Certify(ctx, id, driver.ID, in.SignatureKey)
	if err != nil {
		return nil, db.MapError(err, "dvir report")
	}
	rep := reportFromDetail(row)
	if !rep.HasCriticalDefect {
		return &rep, nil
	}
	// Q27.2 — the unit leaves out of service once the critical defect is
	// repaired and the repair is confirmed by a driver signature.
	if err := s.repo.SetOutOfService(ctx, row.UnitID, false); err != nil {
		s.log.ErrorContext(ctx, "dvir: could not clear out_of_service",
			slog.String("unit_id", row.UnitID.String()), slog.String("error", err.Error()))
	} else {
		rep.OutOfService = false
	}
	return &rep, nil
}

// CloseOverdue is the Q30.1 fallback sweep run by internal/jobs: a report with
// no follow-up DVIR inside the grace window, or one whose unit is no longer
// active, is closed as `closed_no_certification`.
func (s *Service) CloseOverdue(ctx context.Context, graceDays int32) (int, error) {
	if graceDays <= 0 {
		graceDays = CertificationGraceDays
	}
	rows, err := s.repo.CertificationOverdue(ctx, graceDays, closeBatchLimit)
	if err != nil {
		return 0, db.MapError(err, "dvir report")
	}
	var closed int
	for _, row := range rows {
		reason := fmt.Sprintf("no certification within %d days", graceDays)
		if row.UnitStatus != "active" {
			reason = "unit is inactive"
		} else {
			// A follow-up DVIR on the same unit is the driver's implicit answer
			// to "Previous defects repaired?" — the report is still closed, but
			// the reason records that the flow moved on.
			n, err := s.repo.CountReportsAfter(ctx, row.UnitID, row.PerformedAt)
			if err == nil && n > 0 {
				reason = "superseded by a later DVIR"
			}
		}
		if _, err := s.repo.Close(ctx, row.ID, reason); err != nil {
			s.log.ErrorContext(ctx, "dvir: could not close report",
				slog.String("dvir_id", row.ID.String()), slog.String("error", err.Error()))
			continue
		}
		closed++
		s.alert(ctx, AlertClosedNoCertification, Alert{
			CompanyID: row.CompanyID, DvirID: row.ID, UnitID: row.UnitID,
			DriverID: row.DriverID, Message: reason,
		})
	}
	return closed, nil
}
