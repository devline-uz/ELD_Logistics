package tracking

import (
	"time"

	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/telemetry"
	"github.com/devline/onebook-eld/internal/domain/tracking/dto"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// liveUnitFrom maps one live row onto the wire shape.
//
// TZ §10.1 — `malfunction` is not stored on unit_last_state: it is derived here
// from the wired ELD, so eld_devices stays the single source of truth for
// device health and the two can never disagree. `idle` is an internal
// connectivity nuance that the admin map reports as Online.
func liveUnitFrom(r db.TrackingListLiveUnitsRow) dto.LiveUnit {
	out := dto.LiveUnit{
		UnitID:           r.UnitID.String(),
		UnitNumber:       r.UnitNumber,
		BranchID:         pgconv.UUIDString(r.BranchID),
		BranchName:       pgconv.Deref(r.BranchName),
		OutOfService:     r.OutOfService,
		OnlineStatus:     onlineStatus(r),
		Lat:              r.Lat,
		Lng:              r.Lng,
		SpeedKmh:         r.SpeedKmh,
		HeadingDeg:       r.Heading,
		OdometerM:        r.OdometerM,
		DutyStatus:       pgconv.Deref(r.DutyStatus),
		EldDeviceID:      pgconv.UUIDString(r.EldDeviceID),
		EldDeviceSerial:  pgconv.Deref(r.EldDeviceSerial),
		MalfunctionCodes: emptySlice(r.MalfunctionCodes),
	}
	out.LastSeenAt = pgconv.ToTimePtr(r.Ts)
	if v, ok := numericFloat(r.EngineHours); ok {
		out.EngineHours = &v
	}
	if id := pgconv.UUIDString(r.DriverID); id != nil {
		out.Driver = &dto.DriverBrief{
			ID:        *id,
			FirstName: pgconv.Deref(r.FirstName),
			LastName:  pgconv.Deref(r.LastName),
		}
	}
	return out
}

// onlineStatus resolves the four admin states of TZ §10.1.
func onlineStatus(r db.TrackingListLiveUnitsRow) string {
	if len(r.MalfunctionCodes) > 0 ||
		(r.EldDeviceStatus != nil && *r.EldDeviceStatus == telemetry.StatusMalfunction) {
		return dto.OnlineStatusMalfunction
	}
	switch r.OnlineStatus {
	case telemetry.StatusDisconnected:
		return dto.OnlineStatusDisconnected
	case telemetry.StatusOnline, telemetry.StatusIdle:
		return dto.OnlineStatusOnline
	default:
		return dto.OnlineStatusOffline
	}
}

// tripFrom maps a list row onto the wire shape.
func tripFrom(r db.TrackingListUnitTripsRow) dto.Trip {
	t := dto.Trip{
		ID:          r.ID.String(),
		UnitID:      r.UnitID.String(),
		UnitNumber:  r.UnitNumber,
		StartAt:     r.StartAt.UTC(),
		EndAt:       pgconv.ToTimePtr(r.EndAt),
		StartLat:    r.StartLat,
		StartLng:    r.StartLng,
		EndLat:      r.EndLat,
		EndLng:      r.EndLng,
		DistanceM:   r.DistanceM,
		DurationSec: r.DurationSec,
		MaxSpeedKmh: r.MaxSpeedKmh,
		Open:        !r.EndAt.Valid,
	}
	if id := pgconv.UUIDString(r.DriverID); id != nil {
		t.Driver = &dto.DriverBrief{
			ID:        *id,
			FirstName: pgconv.Deref(r.FirstName),
			LastName:  pgconv.Deref(r.LastName),
		}
	}
	return t
}

// tripDetailFrom maps the single trip row onto the wire shape.
func tripDetailFrom(r db.TrackingGetTripRow) dto.TripDetail {
	list := db.TrackingListUnitTripsRow(r)
	return dto.TripDetail{Trip: tripFrom(list), PolylineKey: r.PolylineKey}
}

// unidentifiedFrom maps one buffered event onto the wire shape.
func unidentifiedFrom(r db.TrackingListUnidentifiedEventsRow, now time.Time) dto.UnidentifiedEvent {
	e := dto.UnidentifiedEvent{
		ID:               r.ID.String(),
		UnitID:           r.UnitID.String(),
		UnitNumber:       r.UnitNumber,
		StartAt:          r.StartAt.UTC(),
		EndAt:            pgconv.ToTimePtr(r.EndAt),
		DistanceM:        r.DistanceM,
		TrackKey:         r.TrackKey,
		Status:           r.Status,
		AssignedDriverID: pgconv.UUIDString(r.AssignedDriverID),
		Annotation:       pgconv.Deref(r.Annotation),
		ResolvedAt:       pgconv.ToTimePtr(r.ResolvedAt),
		CreatedAt:        r.CreatedAt.UTC(),
	}
	if r.Status == dto.UnidentifiedPending {
		e.PendingDays = int(now.UTC().Sub(r.StartAt.UTC()) / (24 * time.Hour))
	}
	return e
}

func numericFloat(n pgtype.Numeric) (float64, bool) {
	if !n.Valid {
		return 0, false
	}
	v, err := n.Float64Value()
	if err != nil || !v.Valid {
		return 0, false
	}
	return v.Float64, true
}

func emptySlice(v []string) []string {
	if v == nil {
		return []string{}
	}
	return v
}
