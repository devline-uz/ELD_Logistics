package duty

import (
	"context"
	"errors"
	"log/slog"
	"sort"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/duty/dto"
	"github.com/devline/onebook-eld/internal/hos"
)

type Service struct {
	repo Repo
	now  func() time.Time
	log  *slog.Logger
}

// NewService builds the duty service. now is injectable so the day boundary
// and the counters are testable.
func NewService(repo Repo, now func() time.Time, log *slog.Logger) *Service {
	s := &Service{repo: repo, now: now, log: log}
	if s.now == nil {
		s.now = time.Now
	}
	if s.log == nil {
		s.log = slog.Default()
	}
	return s
}

// DriverContext resolves one driver, answering 404 for a cross-tenant id.
func (s *Service) DriverContext(ctx context.Context, companyID, driverID uuid.UUID) (Context, error) {
	c, err := s.repo.DriverContext(ctx, companyID, driverID)
	if errors.Is(err, pgx.ErrNoRows) {
		return Context{}, apierr.NotFound("driver")
	}
	if err != nil {
		return Context{}, apierr.Internal(err, "failed to load driver")
	}
	return c, nil
}

// DriverByUser resolves the driver record of an authenticated user. It is the
// entry point of every self scoped mobile call.
func (s *Service) DriverByUser(ctx context.Context, companyID, userID uuid.UUID) (Context, error) {
	c, err := s.repo.DriverByUser(ctx, companyID, userID)
	if errors.Is(err, pgx.ErrNoRows) {
		return Context{}, apierr.Forbidden("the caller is not a driver")
	}
	if err != nil {
		return Context{}, apierr.Internal(err, "failed to load driver")
	}
	return c, nil
}

// Ingest applies the sync rule layer to one driver's events and writes the
// accepted ones.
//
// Order of decision making per event: the pure rules first (validation, rule 3
// time window, idempotency, rule 5 locked day, rule 1 conflict), then the
// server side HOS checks that need the policy in force on that day (Q10.1) and
// the unit's capabilities.
func (s *Service) Events(ctx context.Context, f PageFilter) ([]dto.DutyStatusEvent, int64, error) {
	rows, total, err := s.repo.EventsPage(ctx, f)
	if err != nil {
		return nil, 0, apierr.Internal(err, "failed to list duty status events")
	}
	out := make([]dto.DutyStatusEvent, 0, len(rows))
	for _, row := range rows {
		out = append(out, toEventDTO(row))
	}
	return out, total, nil
}

// Summary computes the HOS state of one log day (Q10.2, Q10.7, Q10.9).
//
// The policy is the version in force on that day, never the newest one, so a
// policy change never rewrites history (Q10.1). Violations are computed and
// returned but not persisted: writing the `violations` table is stage 4.
func (s *Service) Summary(ctx context.Context, companyID, driverID uuid.UUID, date time.Time) (*dto.HosSummary, error) {
	driver, err := s.DriverContext(ctx, companyID, driverID)
	if err != nil {
		return nil, err
	}
	loc := driver.Location()
	dayStart, dayEnd := hos.DayRange(date, loc)

	policy, err := s.repo.PolicyAt(ctx, companyID, dayStart.UTC())
	if err != nil {
		return nil, apierr.Internal(err, "failed to load hos policy")
	}

	// A past day is evaluated at its own midnight; today is evaluated now.
	evalAt := dayEnd.UTC()
	if now := s.now().UTC(); now.Before(evalAt) {
		evalAt = now
	}

	from := dayStart.AddDate(0, 0, -(policy.Policy.CycleDays + hosWindowDays))
	rows, err := s.repo.EventsBetween(ctx, companyID, driverID, from.UTC(), dayEnd.UTC())
	if err != nil {
		return nil, apierr.Internal(err, "failed to load duty status events")
	}
	events := make([]hos.Event, 0, len(rows))
	for _, row := range rows {
		events = append(events, row.HosEvent())
	}

	counters, err := hos.Compute(events, policy.Policy, evalAt, loc)
	if err != nil {
		return nil, apierr.Internal(err, "failed to compute hos counters")
	}
	totals := hos.DayTotalsFor(events, dayStart, loc)

	out := &dto.HosSummary{
		DriverID:    driverID.String(),
		Date:        hos.DayKey(dayStart, loc),
		Timezone:    driver.Timezone,
		EvaluatedAt: evalAt,
		Counters: dto.Counters{
			BreakLeftMin:       minutesOf(counters.BreakLeft),
			DriveLeftMin:       minutesOf(counters.DriveLeft),
			ShiftLeftMin:       minutesOf(counters.ShiftLeft),
			CycleLeftMin:       minutesOf(counters.CycleLeft),
			DrivingTimeLeftMin: minutesOf(counters.DrivingTimeLeft),
		},
		Totals: dto.DayTotals{
			OffMin:   minutesOf(totals.Off),
			SBMin:    minutesOf(totals.SB),
			DriveMin: minutesOf(totals.Drive),
			OnMin:    minutesOf(totals.On),
		},
		Recap:      make([]dto.RecapDay, 0, policy.Policy.CycleDays),
		Violations: make([]dto.Violation, 0, 4),
	}
	if policy.ID != nil {
		id := policy.ID.String()
		out.PolicyVersionID = &id
	}
	for _, r := range hos.Recap(events, policy.Policy, dayStart, loc) {
		out.Recap = append(out.Recap, dto.RecapDay{
			Date:          r.Date,
			OnDutyMin:     minutesOf(r.OnDuty),
			AvailableMin:  minutesOf(r.Available),
			GainedNextMin: minutesOf(r.GainedNext),
		})
	}
	for _, v := range hos.Violations(events, policy.Policy, dayStart, loc) {
		out.Violations = append(out.Violations, dto.Violation{Type: v.Type, Severity: v.Severity, At: v.At})
	}
	sort.SliceStable(out.Violations, func(i, j int) bool {
		return out.Violations[i].At.Before(out.Violations[j].At)
	})
	return out, nil
}

// policyCache memoises one hos policy lookup per calendar day.
type policyCache struct {
	repo      Repo
	companyID uuid.UUID
	byDay     map[string]PolicyVersion
}

func newPolicyCache(repo Repo, companyID uuid.UUID) *policyCache {
	return &policyCache{repo: repo, companyID: companyID, byDay: map[string]PolicyVersion{}}
}

func (c *policyCache) at(ctx context.Context, day time.Time) (PolicyVersion, error) {
	key := day.Format(time.RFC3339)
	if p, ok := c.byDay[key]; ok {
		return p, nil
	}
	p, err := c.repo.PolicyAt(ctx, c.companyID, day.UTC())
	if err != nil {
		return PolicyVersion{}, err
	}
	c.byDay[key] = p
	return p, nil
}

// unitCache memoises the sleeper berth capability of the units in one batch.
type unitCache struct {
	repo      Repo
	companyID uuid.UUID
	byUnit    map[uuid.UUID]bool
}

func newUnitCache(repo Repo, companyID uuid.UUID) *unitCache {
	return &unitCache{repo: repo, companyID: companyID, byUnit: map[uuid.UUID]bool{}}
}

// sleeperBerth reports whether SB is available. An unknown unit answers true so
// a missing unit reference never silently drops a legitimate sleeper entry;
// the foreign key still refuses a bogus unit at write time.
func (c *unitCache) sleeperBerth(ctx context.Context, unitID *uuid.UUID) (bool, error) {
	if unitID == nil {
		return true, nil
	}
	if v, ok := c.byUnit[*unitID]; ok {
		return v, nil
	}
	row, err := c.repo.UnitFlags(ctx, c.companyID, *unitID)
	if errors.Is(err, pgx.ErrNoRows) {
		c.byUnit[*unitID] = true
		return true, nil
	}
	if err != nil {
		return false, err
	}
	c.byUnit[*unitID] = row.SleeperBerth
	return row.SleeperBerth, nil
}

// toEventDTO maps a stored row onto the API shape.
func toEventDTO(row StoredEvent) dto.DutyStatusEvent {
	out := dto.DutyStatusEvent{
		ID:             row.ID.String(),
		ClientEventID:  row.ClientEventID.String(),
		EventType:      row.EventType,
		Special:        row.Special,
		Origin:         row.Origin,
		EventTime:      row.EventTime.UTC(),
		TimeSource:     row.TimeSource,
		TimeUnverified: row.TimeUnverified,
		ClockSkewSec:   row.ClockSkewSec,
		ReceivedAt:     row.ReceivedAt.UTC(),
		Lat:            row.Lat,
		Lng:            row.Lng,
		LocationText:   row.LocationText,
		GPSAccuracyM:   row.GPSAccuracyM,
		OdometerM:      row.OdometerM,
		EngineHours:    row.EngineHours,
		Notes:          row.Notes,
		TrailerIDs:     idStrings(row.TrailerIDs),
		ShippingDocIDs: idStrings(row.ShippingDocIDs),
		DeviceSeq:      row.DeviceSeq,
		Locked:         row.Locked,
	}
	if row.Status != nil {
		out.Status = *row.Status
	}
	out.UnitID = idString(row.UnitID)
	out.SupersededBy = idString(row.SupersededBy)
	out.DailyLogID = idString(row.DailyLogID)
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

// Policy exposes the hos policy in force at an instant, so /sync/pull can ship
// it to the offline engine without a second repository (Q10.1).
func (s *Service) Policy(ctx context.Context, companyID uuid.UUID, at time.Time) (PolicyVersion, error) {
	p, err := s.repo.PolicyAt(ctx, companyID, at)
	if err != nil {
		return PolicyVersion{}, apierr.Internal(err, "failed to load hos policy")
	}
	return p, nil
}
