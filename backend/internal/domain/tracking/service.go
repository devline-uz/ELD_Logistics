package tracking

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/telemetry"
	"github.com/devline/onebook-eld/internal/domain/tracking/dto"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// maxPolylinePoints caps the track rebuilt for one trip detail response.
const maxPolylinePoints = 20000

// defaultTimezone matches companies.timezone's column default.
const defaultTimezone = "America/Chicago"

// Service is the read side of tracking: live map, trip history and the
// unidentified driving buffer.
type Service struct {
	repo Repo
	now  func() time.Time
}

// NewService builds the service.
func NewService(repo Repo, now func() time.Time) *Service {
	if now == nil {
		now = time.Now
	}
	return &Service{repo: repo, now: now}
}

// Live returns the live map rows of the caller tenant. A branch scoped
// principal is silently narrowed to its own branch.
func (s *Service) Live(ctx context.Context, f LiveFilter) ([]dto.LiveUnit, int64, error) {
	if sc, ok := mw.ScopeFrom(ctx); ok && sc.Scope == tenant.ScopeBranch && sc.BranchID != nil {
		f.BranchID = sc.BranchID
	}
	rows, total, err := s.repo.ListLive(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "unit")
	}
	out := make([]dto.LiveUnit, 0, len(rows))
	for _, r := range rows {
		out = append(out, liveUnitFrom(r))
	}
	return out, total, nil
}

// DayWindow converts a calendar date into the UTC half-open interval of that
// day in the company timezone (TZ §13 Q64/Q65 — "vaqt Company TZ bilan").
// A nil date means today in the company timezone.
func (s *Service) DayWindow(ctx context.Context, date *time.Time) (time.Time, time.Time) {
	loc := s.location(ctx)
	day := s.now().In(loc)
	if date != nil {
		day = date.In(time.UTC)
		day = time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, loc)
	}
	start := time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, loc)
	return start.UTC(), start.AddDate(0, 0, 1).UTC()
}

// location resolves the company timezone, falling back to the column default
// when the stored name is unknown to the runtime tzdata.
func (s *Service) location(ctx context.Context) *time.Location {
	name, err := s.repo.CompanyTimezone(ctx)
	if err != nil || name == "" {
		name = defaultTimezone
	}
	loc, err := time.LoadLocation(name)
	if err != nil {
		if loc, err = time.LoadLocation(defaultTimezone); err != nil {
			return time.UTC
		}
	}
	return loc
}

// Trips lists one unit's trips inside a company timezone day.
func (s *Service) Trips(ctx context.Context, f TripFilter) ([]dto.Trip, int64, error) {
	unit, err := s.repo.UnitBrief(ctx, f.UnitID)
	if err != nil {
		return nil, 0, db.MapError(err, "unit")
	}
	if err := s.assertScope(ctx, unit.BranchID); err != nil {
		return nil, 0, err
	}
	rows, total, err := s.repo.ListTrips(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "trip")
	}
	out := make([]dto.Trip, 0, len(rows))
	for _, r := range rows {
		out = append(out, tripFrom(r))
	}
	return out, total, nil
}

// Trip returns one trip with its track. The polyline is rebuilt from the
// telemetry of the trip window; `polyline_key` points at the copy stored in
// object storage when the trip was closed.
func (s *Service) Trip(ctx context.Context, id uuid.UUID, includePolyline bool) (*dto.TripDetail, error) {
	row, err := s.repo.GetTrip(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "trip")
	}
	if err := s.assertScope(ctx, row.BranchID); err != nil {
		return nil, err
	}
	out := tripDetailFrom(row)
	if !includePolyline {
		return &out, nil
	}

	end := s.now().UTC()
	if row.EndAt.Valid {
		end = row.EndAt.Time.UTC()
	}
	points, err := s.repo.TripPoints(ctx, row.UnitID, row.StartAt.UTC(), end, maxPolylinePoints)
	if err != nil {
		return nil, db.MapError(err, "trip")
	}
	track := make([]telemetry.Point, 0, len(points))
	for _, p := range points {
		track = append(track, telemetry.Point{TS: p.Ts.UTC(), Lat: p.Lat, Lng: p.Lng})
	}
	out.Polyline = telemetry.EncodePolyline(track)
	out.PointCount = len(track)
	return &out, nil
}

// Unidentified lists the buffered driver-less driving intervals (TZ A§10.4).
// Assignment and claim live in the log edit request flow, not here.
func (s *Service) Unidentified(ctx context.Context, f UnidentifiedFilter) ([]dto.UnidentifiedEvent, int64, error) {
	if sc, ok := mw.ScopeFrom(ctx); ok && sc.Scope == tenant.ScopeBranch && sc.BranchID != nil {
		f.BranchID = sc.BranchID
	}
	rows, total, err := s.repo.ListUnidentified(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "unidentified event")
	}
	now := s.now()
	out := make([]dto.UnidentifiedEvent, 0, len(rows))
	for _, r := range rows {
		out = append(out, unidentifiedFrom(r, now))
	}
	return out, total, nil
}

// assertScope hides rows outside the caller branch behind a 404, never a 403,
// so an out of scope identifier is indistinguishable from a missing one.
func (s *Service) assertScope(ctx context.Context, branchID pgtype.UUID) error {
	sc, ok := mw.ScopeFrom(ctx)
	if !ok || sc.Scope != tenant.ScopeBranch {
		return nil
	}
	var b *uuid.UUID
	if branchID.Valid {
		id := uuid.UUID(branchID.Bytes)
		b = &id
	}
	if !sc.AllowsBranch(b) {
		return apierr.NotFound("unit")
	}
	return nil
}
