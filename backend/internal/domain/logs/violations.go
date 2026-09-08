package logs

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/hos"
)

// Violation types the server owns on top of the pure HOS engine (Q57).
const (
	violationUncertifiedLog     = "uncertified_log"
	violationUnidentifiedDrive  = "unidentified_driving"
	violationFormMannerTrailer  = hos.ViolationFormMannerTrailer
	violationFormMannerDocument = hos.ViolationFormMannerDoc
)

// ResolutionReason is the Q58 closing rule of each violation type. A violation
// is never deleted: it is stamped with resolved_at plus this reason and stays
// in the history.
func ResolutionReason(typ string) string {
	switch typ {
	case hos.ViolationBreakRequired:
		return "qualifying break taken"
	case hos.ViolationDriveLimit, hos.ViolationShiftLimit:
		return "daily rest completed"
	case hos.ViolationCycleLimit:
		return "cycle restart completed or the day dropped out of the cycle window"
	case violationFormMannerTrailer, violationFormMannerDocument:
		return "field completed and the log re-certified"
	case violationUncertifiedLog:
		return "log certified"
	case violationUnidentifiedDrive:
		return "driving block assigned"
	}
	return "no longer reported by the HOS engine"
}

// SyncDayViolations recomputes and persists the violations of one log day.
// The server is canonical (Q57): the mobile app only previews them.
//
// The policy used is the version in force on that day (Q10.1), so a policy
// change never rewrites the history of a closed day.
func (s *Service) SyncDayViolations(ctx context.Context, log DailyLog) error {
	day, loc := dayOf(log)
	dayStart, dayEnd := hos.DayRange(day, loc)

	policy, err := s.duty.Policy(ctx, log.CompanyID, dayStart.UTC())
	if err != nil {
		return err
	}

	from := dayStart.AddDate(0, 0, -(policy.Policy.CycleDays + totalsLookbackDays))
	rows, err := s.repo.DriverEvents(ctx, log.CompanyID, log.DriverID, from.UTC(), dayEnd.UTC())
	if err != nil {
		return apierr.Internal(err, "failed to load duty status events")
	}
	events := make([]hos.Event, 0, len(rows))
	for _, row := range rows {
		events = append(events, row.HosEvent())
	}

	items := make([]ViolationItem, 0, 8)
	for _, v := range hos.Violations(events, policy.Policy, day, loc) {
		items = append(items, ViolationItem{
			Type: v.Type, Severity: v.Severity, OccurredAt: v.At,
			Details: details(dto.ViolationDetails{
				LimitMin: limitFor(v.Type, policy.Policy),
				Note:     "computed by the HOS engine for " + dayKeyOf(log.LogDate),
			}),
		})
	}

	// Q57 form & manner: an empty trailer or document field is a warning while
	// the day is open and a violation once it has been certified.
	fmAt := dayEnd.Add(-time.Second).UTC()
	if log.SignedAt != nil {
		fmAt = log.SignedAt.UTC()
	}
	for _, v := range hos.FormManner(len(log.TrailerIDs) > 0, len(log.ShippingDocIDs) > 0, log.Certified()) {
		items = append(items, ViolationItem{
			Type: v.Type, Severity: v.Severity, OccurredAt: fmAt,
			Details: details(dto.ViolationDetails{Note: "log form field is empty"}),
		})
	}

	uncertified, err := s.uncertifiedViolation(ctx, log, dayEnd)
	if err != nil {
		return err
	}
	if uncertified != nil {
		items = append(items, *uncertified)
	}

	var unitID *uuid.UUID
	if len(log.UnitIDs) > 0 {
		id := log.UnitIDs[0]
		unitID = &id
	}
	if err := s.repo.SyncViolations(ctx, ViolationSync{
		CompanyID: log.CompanyID, DriverID: log.DriverID, DailyLogID: log.ID,
		UnitID: unitID, PolicyVersionID: policy.ID, Items: items,
	}); err != nil {
		return apierr.Internal(err, "failed to persist violations")
	}
	return nil
}

// uncertifiedViolation raises Q57's `uncertified_log`: one uncertified day is a
// warning, two or more inside the certification window are a violation. A day
// that has not ended yet cannot be late.
func (s *Service) uncertifiedViolation(ctx context.Context, log DailyLog, dayEnd time.Time) (*ViolationItem, error) {
	if log.Certified() || !dayEnd.UTC().Before(s.now().UTC()) {
		return nil, nil
	}
	day, _ := dayOf(log)
	rows, err := s.repo.UncertifiedInWindow(ctx, log.CompanyID, log.DriverID,
		day.AddDate(0, 0, -(CertificationWindowDays-1)), day)
	if err != nil {
		return nil, apierr.Internal(err, "failed to count uncertified days")
	}
	severity := hos.SeverityWarning
	if len(rows) >= 2 {
		severity = hos.SeverityViolation
	}
	return &ViolationItem{
		Type: violationUncertifiedLog, Severity: severity, OccurredAt: dayEnd.UTC(),
		Details: details(dto.ViolationDetails{
			DaysUncertified: len(rows),
			Note:            "the log day was not certified",
		}),
	}, nil
}

// SyncUnidentifiedViolations raises the 8 day unassigned driving alert for the
// whole company (Q57 `unidentified_driving`).
func (s *Service) SyncUnidentifiedViolations(ctx context.Context, companyID uuid.UUID) (int, error) {
	before := s.now().UTC().AddDate(0, 0, -CertificationWindowDays)
	rows, err := s.repo.StaleUnidentified(ctx, companyID, before)
	if err != nil {
		return 0, apierr.Internal(err, "failed to load unidentified driving blocks")
	}
	for _, row := range rows {
		unit := row.UnitID
		if err := s.repo.RaiseUnidentifiedViolation(ctx, UnidentifiedViolation{
			CompanyID: companyID, EventID: row.ID, UnitID: &unit, OccurredAt: row.StartAt,
			Details: details(dto.ViolationDetails{
				Note: "driving block unassigned for more than 8 days",
			}),
		}); err != nil {
			return 0, apierr.Internal(err, "failed to raise the unidentified driving violation")
		}
	}
	return len(rows), nil
}

// ViolationList returns a page of the stored violations (Q59: the filters are
// independent of each other).
func (s *Service) ViolationList(ctx context.Context, f ViolationFilter) ([]dto.Violation, int64, error) {
	rows, total, err := s.repo.Violations(ctx, f)
	if err != nil {
		return nil, 0, apierr.Internal(err, "failed to list violations")
	}
	out := make([]dto.Violation, 0, len(rows))
	for _, row := range rows {
		out = append(out, violationDTO(row))
	}
	return out, total, nil
}

// limitFor reports the policy limit a violation type was measured against.
func limitFor(typ string, p hos.Policy) int64 {
	switch typ {
	case hos.ViolationDriveLimit:
		return int64(p.DriveLimitMin)
	case hos.ViolationShiftLimit:
		return int64(p.ShiftWindowMin)
	case hos.ViolationBreakRequired:
		return int64(p.BreakRequiredAfterDriveMin)
	case hos.ViolationCycleLimit:
		return int64(p.CycleLimitMin)
	}
	return 0
}

func details(d dto.ViolationDetails) []byte {
	payload, err := json.Marshal(d)
	if err != nil {
		return []byte(`{}`)
	}
	return payload
}
