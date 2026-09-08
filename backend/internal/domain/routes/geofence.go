package routes

import (
	"context"
	"log/slog"
	"time"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/routes/dto"
	"github.com/devline/onebook-eld/internal/geo"
	"github.com/devline/onebook-eld/internal/tenant"
)

// SweepGeofences completes the routes whose unit has sat inside the
// destination geofence for the dwell window (Q66). It is driven by the
// periodic job in internal/jobs and is safe to run repeatedly: completion is
// guarded by `status = 'ongoing'` in SQL.
//
// Q68: a unit may carry several queued routes, but only the current one — the
// lowest ongoing sequence — is ever checked. The repository query already
// returns one row per unit in that order, so a later leg can never complete
// before the one before it.
func (s *Service) SweepGeofences(ctx context.Context) (int, error) {
	rows, err := s.repo.CurrentForGeofence(ctx)
	if err != nil {
		return 0, err
	}
	now := s.now().UTC()
	var completed int

	for _, r := range rows {
		if r.DestLat == nil || r.DestLng == nil || r.UnitLat == nil || r.UnitLng == nil {
			continue
		}
		distance := geo.DistanceM(
			geo.Point{Lat: *r.DestLat, Lng: *r.DestLng},
			geo.Point{Lat: *r.UnitLat, Lng: *r.UnitLng},
		)
		inside := distance <= float64(r.GeofenceM)

		if !inside {
			// The unit left again: the dwell clock restarts from scratch.
			if r.GeofenceEnteredAt.Valid {
				if err := s.repo.SetGeofenceEnteredAt(ctx, r.ID, nil); err != nil {
					s.logSweep(ctx, r, "failed to clear the geofence dwell", err)
				}
			}
			continue
		}

		if !r.GeofenceEnteredAt.Valid {
			// First sample inside the circle. The dwell starts at the sample's
			// own timestamp, not at the sweep tick, so a unit that reported
			// while the worker was down is not penalised.
			entered := sampleTime(r, now)
			if err := s.repo.SetGeofenceEnteredAt(ctx, r.ID, &entered); err != nil {
				s.logSweep(ctx, r, "failed to start the geofence dwell", err)
			}
			continue
		}

		if now.Sub(r.GeofenceEnteredAt.Time) < dto.DwellSeconds*time.Second {
			continue
		}
		route, err := s.repo.Complete(ctx, r.ID, now, func(x db.Route) []audit.Entry {
			return audit.Changes(auditTable, x.ID, audit.ActionUpdate,
				map[string]any{"status": dto.StatusOngoing},
				map[string]any{"status": dto.StatusCompleted, "completed_by": "geofence"})
		})
		if err != nil {
			s.logSweep(ctx, r, "failed to complete the route", err)
			continue
		}
		completed++
		s.alert(ctx, AlertRouteCompleted, Alert{
			CompanyID: tenant.CompanyID(ctx), RouteID: route.ID, UnitID: route.UnitID,
			DriverID: route.DriverID, Sequence: route.Sequence,
			Message: "Route completed at the destination",
		})
	}
	return completed, nil
}

// sampleTime is the timestamp of the position that put the unit inside the
// geofence, falling back to the sweep tick when the state row carries none.
func sampleTime(r db.ListCurrentRoutesForGeofenceRow, now time.Time) time.Time {
	if r.UnitTs.Valid {
		return r.UnitTs.Time.UTC()
	}
	return now
}

// logSweep reports one route level failure without stopping the sweep. The
// coordinates are never logged: a position is PII.
func (s *Service) logSweep(ctx context.Context, r db.ListCurrentRoutesForGeofenceRow, msg string, err error) {
	s.log.ErrorContext(ctx, "routes: "+msg,
		slog.String("route_id", r.ID.String()),
		slog.String("unit_id", r.UnitID.String()),
		slog.String("error", err.Error()))
}
