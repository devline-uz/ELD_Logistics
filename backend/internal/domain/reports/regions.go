package reports

import (
	"context"
	"errors"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/geo"
)

// errNoStorage is the deterministic failure of a worker without object storage.
var errNoStorage = errors.New("object storage is not configured, the export cannot be delivered")

// maxSegmentM discards an implausible jump between two consecutive samples.
// At the Q63.1 reporting cadence (30 s or 300 m while driving, 5 min while
// stopped) a legitimate segment never exceeds a few kilometres; anything above
// this is a GPS glitch or a gap, and counting it would inflate the tax report.
const maxSegmentM = 50_000

// regionGridM is the resolution of the in-run region memo. Two samples 500 m
// apart are practically always in the same jurisdiction, and every lookup is a
// PostGIS ST_Contains against the state polygons.
const regionGridM = 500

// AggregateRegionDistance fills `unit_region_distance_daily` for one calendar
// day of one tenant (TZ §14). Distance by Region reads that roll-up, which is
// why the report is immediate: this job carries the cost, the report does not.
//
// The run is idempotent: the day is cleared before it is re-accumulated, so a
// retry can never double count.
func (s *Service) AggregateRegionDistance(ctx context.Context, day time.Time) (int, error) {
	dayStart := time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, time.UTC)
	dayEnd := dayStart.AddDate(0, 0, 1)

	units, err := s.repo.UnitsWithTelemetry(ctx, dayStart, dayEnd)
	if err != nil {
		return 0, err
	}
	var written int
	for _, unitID := range units {
		n, err := s.aggregateUnitDay(ctx, unitID, dayStart, dayEnd)
		if err != nil {
			// One unit must never stop the fleet's roll-up.
			s.log.ErrorContext(ctx, "reports: region roll-up failed for one unit",
				slog.String("unit_id", unitID.String()),
				slog.String("date", dayStart.Format(time.DateOnly)),
				slog.String("error", err.Error()))
			continue
		}
		written += n
	}
	return written, nil
}

// aggregateUnitDay walks one unit's track and books each segment onto the
// region its midpoint falls in.
func (s *Service) aggregateUnitDay(ctx context.Context, unitID uuid.UUID, dayStart, dayEnd time.Time) (int, error) {
	track, err := s.repo.UnitTrack(ctx, unitID, dayStart, dayEnd)
	if err != nil {
		return 0, err
	}
	if len(track) < 2 {
		return 0, nil
	}

	totals := map[string]int64{}
	memo := map[geo.GridCell]string{}
	var prev geo.Point
	var havePrev bool

	for _, p := range track {
		if p.Lat == nil || p.Lng == nil {
			continue
		}
		cur := geo.Point{Lat: *p.Lat, Lng: *p.Lng}
		if !havePrev {
			prev, havePrev = cur, true
			continue
		}
		from := prev
		prev = cur
		distance := geo.DistanceM(from, cur)
		if distance <= 0 || distance > maxSegmentM {
			continue
		}
		// The midpoint decides the jurisdiction: a segment that straddles a
		// border is booked to the side it mostly ran on.
		mid := geo.Point{Lat: (from.Lat + cur.Lat) / 2, Lng: (from.Lng + cur.Lng) / 2}
		code, err := s.regionAt(ctx, memo, mid)
		if err != nil {
			return 0, err
		}
		if code == "" {
			continue
		}
		totals[code] += int64(distance)
	}
	if len(totals) == 0 {
		return 0, nil
	}

	// Clear first: the upsert adds to the stored value, so a rerun of the same
	// day would otherwise double count.
	if err := s.repo.ResetRegionDay(ctx, unitID, dayStart); err != nil {
		return 0, err
	}
	for code, distance := range totals {
		if err := s.repo.AddRegionDistance(ctx, unitID, code, dayStart, distance); err != nil {
			return 0, err
		}
	}
	return len(totals), nil
}

// regionAt resolves the jurisdiction of a point, memoised on a coarse grid so
// one day of telemetry costs a handful of PostGIS lookups instead of thousands.
func (s *Service) regionAt(ctx context.Context, memo map[geo.GridCell]string, at geo.Point) (string, error) {
	cell := geo.Grid(at.Lat, at.Lng, regionGridM)
	if code, ok := memo[cell]; ok {
		return code, nil
	}
	row, err := s.repo.RegionAt(ctx, at.Lat, at.Lng)
	switch {
	case errors.Is(err, pgx.ErrNoRows):
		// Outside every known polygon (offshore, or a country whose regions
		// are not loaded). Remember it so the miss is not paid twice.
		memo[cell] = ""
		return "", nil
	case err != nil:
		return "", err
	}
	memo[cell] = row.Code
	return row.Code, nil
}
