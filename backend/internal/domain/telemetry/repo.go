package telemetry

import (
	"context"
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// insertColumns is the telemetry column list of the batch insert, in order.
var insertColumns = []string{
	"ts", "company_id", "unit_id", "eld_device_id", "driver_id", "lat", "lng",
	"speed_kmh", "heading", "odometer_m", "engine_hours", "fuel_pct",
	"coolant_temp_c", "coolant_level_pct", "oil_level_pct", "battery_pct",
	"battery_voltage_v", "ignition", "source",
}

// insertChunk keeps one multi-row INSERT below the 65535 bind parameter limit
// of the extended protocol: 19 columns x 1000 rows = 19000 parameters.
const insertChunk = 1000

// SegmentApply is a segment together with the storage key of its track, ready
// to be written. The polyline upload happens before the transaction opens, so
// no network call is ever held inside a database transaction.
type SegmentApply struct {
	Segment
	TrackKey *string
	DriverID *uuid.UUID
}

// DeviceHealth is the ELD status update derived from a batch (TZ §10.5).
type DeviceHealth struct {
	DeviceID         uuid.UUID
	LastSeenAt       time.Time
	Status           *string
	MalfunctionCodes []string
	Firmware         *string
}

// IngestInput is one unit's batch, already segmented by the service.
type IngestInput struct {
	UnitID   uuid.UUID
	DeviceID *uuid.UUID
	Source   string
	Points   []Point

	Last         *Point
	OnlineStatus string

	Trips        []SegmentApply
	Unidentified []SegmentApply
	Device       *DeviceHealth
}

// IngestOutcome reports what the transaction actually changed.
type IngestOutcome struct {
	Accepted           int64
	Duplicate          int64
	TripsOpened        int
	TripsClosed        int
	UnidentifiedOpened int
	UnidentifiedClosed int
	LastState          *db.UnitLastState
}

// Repo is everything the telemetry service needs from storage.
type Repo interface {
	// UnitBrief resolves a unit inside the caller tenant; a cross-tenant id
	// answers pgx.ErrNoRows, which the service turns into 404.
	UnitBrief(ctx context.Context, id uuid.UUID) (db.TelemetryGetUnitBriefRow, error)
	// ActiveDevice is the ELD currently wired to the unit.
	ActiveDevice(ctx context.Context, unitID uuid.UUID) (db.TelemetryActiveDeviceForUnitRow, error)
	// State loads the carry-over the segmenter needs.
	State(ctx context.Context, unitID uuid.UUID) (State, error)
	// Ingest writes the batch, the last state, the trip and unidentified
	// boundaries and the ELD health change in one transaction.
	Ingest(ctx context.Context, in IngestInput, mkAudit func(before, after db.EldDevice) []audit.Entry) (IngestOutcome, error)
	// MarkStaleOffline demotes units that stopped reporting (TZ §10.1).
	MarkStaleOffline(ctx context.Context, thresholdMinutes int32) (int64, error)
}

// PgRepo is the pgx/sqlc implementation of Repo. Every statement runs through
// Pool.WithTx / Pool.WithConn, which sets `SET LOCAL app.company_id` so RLS is
// the second line of defence behind the explicit company_id predicates.
type PgRepo struct {
	pool     *db.Pool
	recorder audit.Recorder
}

// NewRepo builds the storage adapter.
func NewRepo(pool *db.Pool, recorder audit.Recorder) *PgRepo {
	if recorder == nil {
		recorder = audit.NopRecorder{}
	}
	return &PgRepo{pool: pool, recorder: recorder}
}

func (r *PgRepo) read(ctx context.Context, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, tenant.CompanyID(ctx), func(tx pgx.Tx) error {
		return fn(db.New(tx))
	})
}

// UnitBrief implements Repo.
func (r *PgRepo) UnitBrief(ctx context.Context, id uuid.UUID) (db.TelemetryGetUnitBriefRow, error) {
	var out db.TelemetryGetUnitBriefRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.TelemetryGetUnitBrief(ctx, db.TelemetryGetUnitBriefParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// ActiveDevice implements Repo.
func (r *PgRepo) ActiveDevice(ctx context.Context, unitID uuid.UUID) (db.TelemetryActiveDeviceForUnitRow, error) {
	var out db.TelemetryActiveDeviceForUnitRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.TelemetryActiveDeviceForUnit(ctx, db.TelemetryActiveDeviceForUnitParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: pgconv.UUID(unitID),
		})
		return err
	})
	return out, err
}

// State implements Repo.
func (r *PgRepo) State(ctx context.Context, unitID uuid.UUID) (State, error) {
	companyID := tenant.CompanyID(ctx)
	var st State
	err := r.read(ctx, func(q *db.Queries) error {
		last, err := q.GetUnitLastState(ctx, db.GetUnitLastStateParams{CompanyID: companyID, UnitID: unitID})
		switch {
		case err == nil && last.Ts.Valid:
			st.Prev = &Point{
				TS:        last.Ts.Time.UTC(),
				Lat:       last.Lat,
				Lng:       last.Lng,
				SpeedKmh:  last.SpeedKmh,
				OdometerM: last.OdometerM,
			}
		case err != nil && !errors.Is(err, pgx.ErrNoRows):
			return err
		}

		if _, err := q.TelemetryOpenTrip(ctx, db.TelemetryOpenTripParams{CompanyID: companyID, UnitID: unitID}); err == nil {
			st.TripOpen = true
		} else if !errors.Is(err, pgx.ErrNoRows) {
			return err
		}

		if _, err := q.TelemetryOpenUnidentifiedEvent(ctx, db.TelemetryOpenUnidentifiedEventParams{
			CompanyID: companyID, UnitID: unitID,
		}); err == nil {
			st.UnidentifiedOpen = true
		} else if !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		return nil
	})
	return st, err
}

// MarkStaleOffline implements Repo.
func (r *PgRepo) MarkStaleOffline(ctx context.Context, thresholdMinutes int32) (int64, error) {
	companyID := tenant.CompanyID(ctx)
	var n int64
	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		var err error
		n, err = db.New(tx).MarkStaleUnitsOffline(ctx, db.MarkStaleUnitsOfflineParams{
			CompanyID: companyID, Column2: thresholdMinutes,
		})
		return err
	})
	return n, err
}

// Ingest implements Repo.
func (r *PgRepo) Ingest(ctx context.Context, in IngestInput,
	mkAudit func(before, after db.EldDevice) []audit.Entry) (IngestOutcome, error) {
	companyID := tenant.CompanyID(ctx)
	var out IngestOutcome

	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		q := db.New(tx)

		accepted, err := insertPoints(ctx, tx, companyID, in)
		if err != nil {
			return err
		}
		out.Accepted = accepted
		out.Duplicate = int64(len(in.Points)) - accepted

		if err := applyTrips(ctx, q, companyID, in, &out); err != nil {
			return err
		}
		if err := applyUnidentified(ctx, q, companyID, in, &out); err != nil {
			return err
		}
		if err := r.applyDeviceHealth(ctx, q, tx, companyID, in, mkAudit); err != nil {
			return err
		}
		return upsertLastState(ctx, q, companyID, in, &out)
	})
	return out, err
}

// insertPoints writes the batch with a chunked multi-row INSERT.
// `(unit_id, ts)` is the primary key, so a repeat is silently ignored
// (ON CONFLICT DO NOTHING) and counted as a duplicate, never as an error.
func insertPoints(ctx context.Context, tx pgx.Tx, companyID uuid.UUID, in IngestInput) (int64, error) {
	var accepted int64
	for start := 0; start < len(in.Points); start += insertChunk {
		end := start + insertChunk
		if end > len(in.Points) {
			end = len(in.Points)
		}
		sql, args := buildInsert(companyID, in, in.Points[start:end])
		tag, err := tx.Exec(ctx, sql, args...)
		if err != nil {
			return 0, err
		}
		accepted += tag.RowsAffected()
	}
	return accepted, nil
}

func buildInsert(companyID uuid.UUID, in IngestInput, points []Point) (string, []any) {
	var b strings.Builder
	b.WriteString("INSERT INTO telemetry (")
	b.WriteString(strings.Join(insertColumns, ", "))
	b.WriteString(") VALUES ")

	args := make([]any, 0, len(points)*len(insertColumns))
	for i, p := range points {
		if i > 0 {
			b.WriteByte(',')
		}
		b.WriteByte('(')
		for c := range insertColumns {
			if c > 0 {
				b.WriteByte(',')
			}
			b.WriteByte('$')
			b.WriteString(strconv.Itoa(len(args) + c + 1))
		}
		b.WriteByte(')')

		source := in.Source
		if p.Source != "" {
			source = p.Source
		}
		args = append(args,
			p.TS.UTC(), companyID, in.UnitID, in.DeviceID, p.DriverID, p.Lat, p.Lng,
			p.SpeedKmh, p.Heading, p.OdometerM, p.EngineHours, p.FuelPct,
			p.CoolantTempC, p.CoolantLevelPct, p.OilLevelPct, p.BatteryPct,
			p.BatteryVoltageV, p.Ignition, source,
		)
	}
	b.WriteString(" ON CONFLICT (unit_id, ts) DO NOTHING")
	return b.String(), args
}

func applyTrips(ctx context.Context, q *db.Queries, companyID uuid.UUID, in IngestInput, out *IngestOutcome) error {
	for _, seg := range in.Trips {
		id, startAt, err := tripID(ctx, q, companyID, in, seg, out)
		if err != nil {
			return err
		}
		if id == uuid.Nil {
			continue
		}
		if !seg.Closed {
			if seg.DistanceM == 0 && seg.MaxSpeedKmh == nil {
				continue
			}
			if _, err := q.TelemetryAccrueTrip(ctx, db.TelemetryAccrueTripParams{
				CompanyID: companyID, ID: id, DistanceM: seg.DistanceM, MaxSpeedKmh: seg.MaxSpeedKmh,
			}); err != nil && !errors.Is(err, pgx.ErrNoRows) {
				return err
			}
			continue
		}
		if _, err := q.TelemetryCloseTrip(ctx, db.TelemetryCloseTripParams{
			CompanyID:   companyID,
			ID:          id,
			EndAt:       pgconv.Time(seg.End),
			EndLat:      seg.EndLat,
			EndLng:      seg.EndLng,
			DistanceM:   seg.DistanceM,
			DurationSec: durationSec(startAt, seg.End),
			MaxSpeedKmh: seg.MaxSpeedKmh,
			PolylineKey: seg.TrackKey,
		}); err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		out.TripsClosed++
	}
	return nil
}

// tripID returns the trip a segment belongs to, creating it when the segment
// opens a new one.
func tripID(ctx context.Context, q *db.Queries, companyID uuid.UUID, in IngestInput,
	seg SegmentApply, out *IngestOutcome) (uuid.UUID, time.Time, error) {
	if seg.Continues {
		open, err := q.TelemetryOpenTrip(ctx, db.TelemetryOpenTripParams{CompanyID: companyID, UnitID: in.UnitID})
		if errors.Is(err, pgx.ErrNoRows) {
			return uuid.Nil, time.Time{}, nil
		}
		if err != nil {
			return uuid.Nil, time.Time{}, err
		}
		return open.ID, open.StartAt, nil
	}
	trip, err := q.CreateTrip(ctx, db.CreateTripParams{
		CompanyID: companyID,
		UnitID:    in.UnitID,
		DriverID:  pgconv.UUIDPtr(seg.DriverID),
		StartAt:   seg.Start,
		StartLat:  seg.StartLat,
		StartLng:  seg.StartLng,
		DistanceM: 0,
	})
	if err != nil {
		return uuid.Nil, time.Time{}, err
	}
	out.TripsOpened++
	return trip.ID, trip.StartAt, nil
}

func applyUnidentified(ctx context.Context, q *db.Queries, companyID uuid.UUID, in IngestInput, out *IngestOutcome) error {
	for _, seg := range in.Unidentified {
		var id uuid.UUID
		if seg.Continues {
			open, err := q.TelemetryOpenUnidentifiedEvent(ctx, db.TelemetryOpenUnidentifiedEventParams{
				CompanyID: companyID, UnitID: in.UnitID,
			})
			if errors.Is(err, pgx.ErrNoRows) {
				continue
			}
			if err != nil {
				return err
			}
			id = open.ID
		} else {
			ev, err := q.CreateUnidentifiedEvent(ctx, db.CreateUnidentifiedEventParams{
				CompanyID:   companyID,
				UnitID:      in.UnitID,
				EldDeviceID: pgconv.UUIDPtr(in.DeviceID),
				StartAt:     seg.Start,
				DistanceM:   0,
				TrackKey:    seg.TrackKey,
			})
			if err != nil {
				return err
			}
			out.UnidentifiedOpened++
			id = ev.ID
		}

		if !seg.Closed {
			if seg.DistanceM == 0 {
				continue
			}
			if _, err := q.TelemetryAccrueUnidentifiedEvent(ctx, db.TelemetryAccrueUnidentifiedEventParams{
				CompanyID: companyID, ID: id, DistanceM: seg.DistanceM,
			}); err != nil && !errors.Is(err, pgx.ErrNoRows) {
				return err
			}
			continue
		}
		if _, err := q.TelemetryCloseUnidentifiedEvent(ctx, db.TelemetryCloseUnidentifiedEventParams{
			CompanyID: companyID, ID: id, EndAt: pgconv.Time(seg.End),
			DistanceM: seg.DistanceM, TrackKey: seg.TrackKey,
		}); err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		out.UnidentifiedClosed++
	}
	return nil
}

// applyDeviceHealth writes the ELD status / malfunction change. Telemetry rows
// themselves are never audited (volume), but an ELD status change is.
func (r *PgRepo) applyDeviceHealth(ctx context.Context, q *db.Queries, tx pgx.Tx, companyID uuid.UUID,
	in IngestInput, mkAudit func(before, after db.EldDevice) []audit.Entry) error {
	h := in.Device
	if h == nil {
		return nil
	}
	before, err := q.GetEldDevice(ctx, db.GetEldDeviceParams{CompanyID: companyID, ID: h.DeviceID})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		return err
	}
	after, err := q.TelemetrySetDeviceHealth(ctx, db.TelemetrySetDeviceHealthParams{
		CompanyID:        companyID,
		ID:               h.DeviceID,
		LastSeenAt:       pgconv.Time(h.LastSeenAt),
		Status:           h.Status,
		MalfunctionCodes: h.MalfunctionCodes,
		Firmware:         h.Firmware,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		return err
	}
	if mkAudit == nil {
		return nil
	}
	return r.recorder.RecordTx(ctx, tx, mkAudit(before, after)...)
}

func upsertLastState(ctx context.Context, q *db.Queries, companyID uuid.UUID, in IngestInput, out *IngestOutcome) error {
	if in.Last == nil {
		return nil
	}
	p := *in.Last
	row, err := q.UpsertUnitLastState(ctx, db.UpsertUnitLastStateParams{
		UnitID:       in.UnitID,
		CompanyID:    companyID,
		Ts:           pgconv.Time(p.TS),
		Lat:          p.Lat,
		Lng:          p.Lng,
		SpeedKmh:     p.SpeedKmh,
		Heading:      p.Heading,
		OdometerM:    p.OdometerM,
		EngineHours:  numeric(p.EngineHours),
		DutyStatus:   pgconv.NilIfEmpty(p.DutyStatus),
		DriverID:     pgconv.UUIDPtr(p.DriverID),
		OnlineStatus: in.OnlineStatus,
	})
	if errors.Is(err, pgx.ErrNoRows) {
		// A newer point already won the row; the batch was late.
		return nil
	}
	if err != nil {
		return err
	}
	out.LastState = &row
	return nil
}

// durationSec is the closed trip length; it always measures from the stored
// trip start, so a trip that spans several batches is not truncated.
func durationSec(startAt, endAt time.Time) *int32 {
	if startAt.IsZero() || endAt.Before(startAt) {
		return nil
	}
	//nolint:gosec // G115: a vehicle trip cannot span the ~68 years needed to overflow int32 seconds
	v := int32(endAt.Sub(startAt) / time.Second)
	return &v
}

// numericFloat reads a numeric(12,2) column back into a float.
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
