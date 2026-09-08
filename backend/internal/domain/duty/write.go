package duty

import (
	"context"
	"encoding/json"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/hos"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// Write implements Repo: one transaction per driver batch. Each event is
// upserted on client_event_id (idempotent), attached to its home terminal log
// day, the losers of conflict rule 1 are stamped, and every touched day gets
// its `totals` recomputed from the stored events (Q10.2).
func (r *PgRepo) Write(ctx context.Context, in WriteInput, entries []audit.Entry) (WriteOutcome, error) {
	var out WriteOutcome
	loc, err := time.LoadLocation(in.Timezone)
	if err != nil || loc == nil {
		loc = time.UTC
	}

	err = r.pool.WithTx(ctx, in.CompanyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		days := make(map[string]dayRef, len(in.Events))

		for _, ev := range in.Events {
			logID, derr := dailyLogID(ctx, q, in, ev, days, loc)
			if derr != nil {
				return derr
			}
			row, uerr := q.UpsertDutyStatusEvent(ctx, upsertParams(in, ev, logID))
			if uerr != nil {
				return uerr
			}
			out.Written++

			if len(ev.Supersedes) > 0 {
				if serr := q.SyncSupersedeEvents(ctx, db.SyncSupersedeEventsParams{
					CompanyID: in.CompanyID, Ids: ev.Supersedes, SupersededBy: pgconv.UUID(row.ID),
				}); serr != nil {
					return serr
				}
			}
			if ev.SupersededBy != nil {
				if serr := q.SyncSupersedeEvents(ctx, db.SyncSupersedeEventsParams{
					CompanyID: in.CompanyID, Ids: []uuid.UUID{row.ID},
					SupersededBy: pgconv.UUIDPtr(ev.SupersededBy),
				}); serr != nil {
					return serr
				}
			}
		}

		for _, ref := range days {
			if terr := recomputeTotals(ctx, q, in.CompanyID, in.DriverID, ref, loc); terr != nil {
				return terr
			}
			out.Days = append(out.Days, ref.day)
		}
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	return out, err
}

// dayRef is the resolved daily_logs row of one calendar day.
type dayRef struct {
	id  uuid.UUID
	day time.Time
}

// dailyLogID resolves (and creates on first touch) the log day of one event.
func dailyLogID(ctx context.Context, q *db.Queries, in WriteInput, ev WriteEvent,
	days map[string]dayRef, loc *time.Location,
) (uuid.UUID, error) {
	key := hos.DayKey(ev.LogDate, loc)
	if ref, ok := days[key]; ok {
		return ref.id, nil
	}
	log, err := q.GetOrCreateDailyLog(ctx, db.GetOrCreateDailyLogParams{
		CompanyID: in.CompanyID,
		DriverID:  in.DriverID,
		LogDate:   pgtype.Date{Time: dayUTC(hos.StartOfDay(ev.LogDate, loc)), Valid: true},
		Timezone:  in.Timezone,
	})
	if err != nil {
		return uuid.Nil, err
	}
	days[key] = dayRef{id: log.ID, day: hos.StartOfDay(ev.LogDate, loc)}
	return log.ID, nil
}

// recomputeTotals rewrites daily_logs.totals from the stored events of that
// day using hos.DayTotalsFor. The whole cycle window is replayed so a status
// left open on a previous day carries into this one.
func recomputeTotals(ctx context.Context, q *db.Queries, companyID, driverID uuid.UUID,
	ref dayRef, loc *time.Location,
) error {
	_, end := hos.DayRange(ref.day, loc)
	rows, err := q.DutyListDriverEventsBetween(ctx, db.DutyListDriverEventsBetweenParams{
		CompanyID: companyID,
		DriverID:  pgconv.UUID(driverID),
		FromAt:    ref.day.AddDate(0, 0, -totalsLookbackDays).UTC(),
		ToAt:      end.UTC(),
	})
	if err != nil {
		return err
	}

	events := make([]hos.Event, 0, len(rows))
	units := make([]uuid.UUID, 0, 4)
	seenUnit := make(map[uuid.UUID]struct{}, 4)
	for _, row := range rows {
		se := betweenRow(row)
		events = append(events, se.HosEvent())
		if se.UnitID != nil && row.EventTime.Before(end) && !row.EventTime.Before(ref.day) {
			if _, dup := seenUnit[*se.UnitID]; !dup {
				seenUnit[*se.UnitID] = struct{}{}
				units = append(units, *se.UnitID)
			}
		}
	}

	totals := hos.DayTotalsFor(events, ref.day, loc)
	payload, err := json.Marshal(map[string]int64{
		"off": minutesOf(totals.Off),
		"sb":  minutesOf(totals.SB),
		"dr":  minutesOf(totals.Drive),
		"on":  minutesOf(totals.On),
	})
	if err != nil {
		return err
	}
	return q.DutySetDailyLogTotals(ctx, db.DutySetDailyLogTotalsParams{
		CompanyID: companyID, ID: ref.id, Totals: payload, UnitIds: units,
	})
}

// totalsLookbackDays is how far back the totals recomputation replays so an
// overnight status is carried into the day being rewritten.
const totalsLookbackDays = 2

// dayLayout is the calendar day key format.
const dayLayout = "2006-01-02"

// dayUTC drops the location from a local midnight so it lands in a DATE column
// as the same calendar day.
func dayUTC(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
}

func minutesOf(d time.Duration) int64 { return int64(d / time.Minute) }

func upsertParams(in WriteInput, ev WriteEvent, logID uuid.UUID) db.UpsertDutyStatusEventParams {
	return db.UpsertDutyStatusEventParams{
		CompanyID:      in.CompanyID,
		DriverID:       pgconv.UUID(in.DriverID),
		UnitID:         pgconv.UUIDPtr(ev.UnitID),
		EldDeviceID:    pgconv.UUIDPtr(ev.ELDDeviceID),
		EventType:      ev.EventType,
		Status:         ev.Status,
		Special:        ev.Special,
		EventTime:      ev.EventTime.UTC(),
		TimeSource:     ev.TimeSource,
		TimeUnverified: ev.TimeUnverified,
		ClockSkewSec:   ev.ClockSkewSec,
		Origin:         ev.Origin,
		Lat:            ev.Lat,
		Lng:            ev.Lng,
		LocationText:   ev.LocationText,
		GpsAccuracyM:   ev.GPSAccuracyM,
		OdometerM:      ev.OdometerM,
		EngineHours:    numeric(ev.EngineHours),
		Notes:          ev.Notes,
		TrailerIds:     nonNil(ev.TrailerIDs),
		ShippingDocIds: nonNil(ev.ShippingDocIDs),
		ClientEventID:  ev.ClientEventID,
		DeviceSeq:      ev.DeviceSeq,
		DailyLogID:     pgconv.UUID(logID),
	}
}

func nonNil(ids []uuid.UUID) []uuid.UUID {
	if ids == nil {
		return []uuid.UUID{}
	}
	return ids
}

// numeric converts an optional float to the numeric(12,2) column type.
func numeric(v *float64) pgtype.Numeric {
	var n pgtype.Numeric
	if v == nil {
		return n
	}
	if err := n.Scan(strconv.FormatFloat(*v, 'f', 2, 64)); err != nil {
		return pgtype.Numeric{}
	}
	return n
}

// numericFloat reads a numeric(12,2) column back into a float.
func numericFloat(n pgtype.Numeric) *float64 {
	if !n.Valid {
		return nil
	}
	v, err := n.Float64Value()
	if err != nil || !v.Valid {
		return nil
	}
	out := v.Float64
	return &out
}

// betweenRow maps the full-window query row onto StoredEvent.
func betweenRow(row db.DutyListDriverEventsBetweenRow) StoredEvent {
	return StoredEvent{
		ID: row.ID, ClientEventID: row.ClientEventID,
		DriverID: pgconv.ToUUIDPtr(row.DriverID), UnitID: pgconv.ToUUIDPtr(row.UnitID),
		EventType: row.EventType, Status: row.Status, Special: row.Special, Origin: row.Origin,
		EventTime: row.EventTime, TimeSource: row.TimeSource,
		TimeUnverified: row.TimeUnverified, ClockSkewSec: row.ClockSkewSec,
		Lat: row.Lat, Lng: row.Lng, LocationText: row.LocationText,
		GPSAccuracyM: row.GpsAccuracyM, OdometerM: row.OdometerM,
		EngineHours: numericFloat(row.EngineHours), Notes: row.Notes,
		TrailerIDs: row.TrailerIds, ShippingDocIDs: row.ShippingDocIds,
		DeviceSeq: row.DeviceSeq, ReceivedAt: row.ReceivedAt,
		SupersededBy: pgconv.ToUUIDPtr(row.SupersededBy), Locked: row.Locked,
		DailyLogID: pgconv.ToUUIDPtr(row.DailyLogID),
	}
}

// pageRow maps the paginated query row onto StoredEvent.
func pageRow(row db.DutyListDriverEventsPageRow) StoredEvent {
	return betweenRow(db.DutyListDriverEventsBetweenRow(row))
}
