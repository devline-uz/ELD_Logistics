package logs

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// PgRepo is the pgx/sqlc implementation of Repo. Every statement runs inside a
// SET LOCAL app.company_id scope, so RLS is the second line of tenant defence.
type PgRepo struct {
	pool     TxRunner
	recorder audit.Recorder
}

// NewRepo builds the storage adapter.
func NewRepo(pool TxRunner, recorder audit.Recorder) *PgRepo {
	if recorder == nil {
		recorder = audit.NopRecorder{}
	}
	return &PgRepo{pool: pool, recorder: recorder}
}

func (r *PgRepo) read(ctx context.Context, companyID uuid.UUID, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error { return fn(db.New(tx)) })
}

// dayLayout is the calendar day key format.
const dayLayout = "2006-01-02"

// dayUTC drops the location from a local midnight so it lands in a DATE column
// as the same calendar day.
func dayUTC(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
}

func date(t time.Time) pgtype.Date { return pgtype.Date{Time: dayUTC(t), Valid: true} }

func nonNil(ids []uuid.UUID) []uuid.UUID {
	if ids == nil {
		return []uuid.UUID{}
	}
	return ids
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

func fullName(first, last string) string {
	switch {
	case first == "":
		return last
	case last == "":
		return first
	}
	return first + " " + last
}

func optionalName(first, last *string) *string {
	if first == nil && last == nil {
		return nil
	}
	name := fullName(pgconv.Deref(first), pgconv.Deref(last))
	if name == "" {
		return nil
	}
	return &name
}

// DailyLogs implements Repo.
func (r *PgRepo) DailyLogs(ctx context.Context, f DailyLogFilter) ([]DailyLog, int64, error) {
	var (
		out   []DailyLog
		total int64
	)
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		rows, err := q.LogsListDriverDailyLogs(ctx, db.LogsListDriverDailyLogsParams{
			CompanyID: f.CompanyID, DriverID: f.DriverID,
			FromDate: date(f.From), ToDate: date(f.To), Lim: f.Limit, Off: f.Offset,
		})
		if err != nil {
			return err
		}
		out = make([]DailyLog, 0, len(rows))
		for _, row := range rows {
			out = append(out, DailyLog{
				ID: row.ID, CompanyID: row.CompanyID, DriverID: row.DriverID,
				DriverName:   fullName(row.FirstName, row.LastName),
				CoDriverID:   pgconv.ToUUIDPtr(row.CoDriverID),
				CoDriverName: optionalName(row.CoDriverFirstName, row.CoDriverLastName),
				LogDate:      row.LogDate.Time, Timezone: row.Timezone,
				UnitIDs: row.UnitIds, TrailerIDs: row.TrailerIds, ShippingDocIDs: row.ShippingDocIds,
				DistanceM: row.DistanceM, Totals: row.Totals,
				CertificationStatus: row.CertificationStatus,
				SignedAt:            pgconv.ToTimePtr(row.SignedAt),
				SignatureKey:        row.SignatureKey, SignedDeviceID: row.SignedDeviceID, SignedIP: row.SignedIp,
				CreatedAt: row.CreatedAt, UpdatedAt: row.UpdatedAt,
			})
		}
		total, err = q.LogsCountDriverDailyLogs(ctx, db.LogsCountDriverDailyLogsParams{
			CompanyID: f.CompanyID, DriverID: f.DriverID, FromDate: date(f.From), ToDate: date(f.To),
		})
		return err
	})
	return out, total, err
}

// DailyLog implements Repo.
func (r *PgRepo) DailyLog(ctx context.Context, companyID, id uuid.UUID) (DailyLog, error) {
	var out DailyLog
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		row, err := q.LogsGetDailyLog(ctx, db.LogsGetDailyLogParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		out = DailyLog{
			ID: row.ID, CompanyID: row.CompanyID, DriverID: row.DriverID,
			DriverUserID: row.UserID, BranchID: pgconv.ToUUIDPtr(row.BranchID),
			DriverName:   fullName(row.FirstName, row.LastName),
			CoDriverID:   pgconv.ToUUIDPtr(row.CoDriverID),
			CoDriverName: optionalName(row.CoDriverFirstName, row.CoDriverLastName),
			LogDate:      row.LogDate.Time, Timezone: row.Timezone,
			UnitIDs: row.UnitIds, TrailerIDs: row.TrailerIds, ShippingDocIDs: row.ShippingDocIds,
			DistanceM: row.DistanceM, Totals: row.Totals,
			CertificationStatus: row.CertificationStatus,
			SignedAt:            pgconv.ToTimePtr(row.SignedAt),
			SignatureKey:        row.SignatureKey, SignedDeviceID: row.SignedDeviceID, SignedIP: row.SignedIp,
			CarrierName: row.CompanyName, HomeTerminalAddress: row.HomeTerminalAddress,
			RegulationProfile: row.RegulationProfile,
			CreatedAt:         row.CreatedAt, UpdatedAt: row.UpdatedAt,
		}
		return nil
	})
	return out, err
}

// DailyLogFor implements Repo: the log day is created on first touch (Q10.2).
func (r *PgRepo) DailyLogFor(ctx context.Context, companyID, driverID uuid.UUID, day time.Time, tz string) (uuid.UUID, error) {
	var out uuid.UUID
	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		row, err := db.New(tx).GetOrCreateDailyLog(ctx, db.GetOrCreateDailyLogParams{
			CompanyID: companyID, DriverID: driverID, LogDate: date(day), Timezone: tz,
		})
		if err != nil {
			return err
		}
		out = row.ID
		return nil
	})
	return out, err
}

// DayEvents implements Repo. Superseded rows stay in the answer so the log can
// show the ✎ history (Q17.2).
func (r *PgRepo) DayEvents(ctx context.Context, companyID, dailyLogID uuid.UUID) ([]Event, error) {
	var out []Event
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.LogsListDayEvents(ctx, db.LogsListDayEventsParams{
			CompanyID: companyID, DailyLogID: pgconv.UUID(dailyLogID),
		})
		if err != nil {
			return err
		}
		out = make([]Event, 0, len(rows))
		for _, row := range rows {
			out = append(out, Event{
				ID: row.ID, DriverID: pgconv.ToUUIDPtr(row.DriverID), UnitID: pgconv.ToUUIDPtr(row.UnitID),
				UnitNumber: row.UnitNumber, EventType: row.EventType, Status: row.Status,
				Special: row.Special, Origin: row.Origin, EventTime: row.EventTime,
				TimeSource: row.TimeSource, ReceivedAt: row.ReceivedAt,
				Lat: row.Lat, Lng: row.Lng, LocationText: row.LocationText,
				OdometerM: row.OdometerM, EngineHours: numericFloat(row.EngineHours), Notes: row.Notes,
				SupersededBy: pgconv.ToUUIDPtr(row.SupersededBy), Locked: row.Locked,
				DailyLogID: pgconv.ToUUIDPtr(row.DailyLogID),
			})
		}
		return nil
	})
	return out, err
}

// storedEvent maps a plain duty_status_events row.
func storedEvent(row db.DutyStatusEvent) Event {
	return Event{
		ID: row.ID, DriverID: pgconv.ToUUIDPtr(row.DriverID), UnitID: pgconv.ToUUIDPtr(row.UnitID),
		EventType: row.EventType, Status: row.Status, Special: row.Special, Origin: row.Origin,
		EventTime: row.EventTime, TimeSource: row.TimeSource, ReceivedAt: row.ReceivedAt,
		Lat: row.Lat, Lng: row.Lng, LocationText: row.LocationText,
		OdometerM: row.OdometerM, EngineHours: numericFloat(row.EngineHours), Notes: row.Notes,
		SupersededBy: pgconv.ToUUIDPtr(row.SupersededBy), Locked: row.Locked,
		DailyLogID: pgconv.ToUUIDPtr(row.DailyLogID),
	}
}

// DriverEvents implements Repo.
func (r *PgRepo) DriverEvents(ctx context.Context, companyID, driverID uuid.UUID, from, to time.Time) ([]Event, error) {
	var out []Event
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.LogsListDriverEventsBetween(ctx, db.LogsListDriverEventsBetweenParams{
			CompanyID: companyID, DriverID: pgconv.UUID(driverID), FromAt: from.UTC(), ToAt: to.UTC(),
		})
		if err != nil {
			return err
		}
		out = make([]Event, 0, len(rows))
		for _, row := range rows {
			out = append(out, storedEvent(row))
		}
		return nil
	})
	return out, err
}

// UnassignedEvents implements Repo: the raw driving rows behind one
// unidentified block (§10.4).
func (r *PgRepo) UnassignedEvents(ctx context.Context, companyID, unitID uuid.UUID, from, to time.Time) ([]Event, error) {
	var out []Event
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.LogsListUnassignedEventsInRange(ctx, db.LogsListUnassignedEventsInRangeParams{
			CompanyID: companyID, UnitID: pgconv.UUID(unitID), FromAt: from.UTC(), ToAt: to.UTC(),
		})
		if err != nil {
			return err
		}
		out = make([]Event, 0, len(rows))
		for _, row := range rows {
			out = append(out, storedEvent(row))
		}
		return nil
	})
	return out, err
}

// UncertifiedOlderThan implements Repo (Q19.1).
func (r *PgRepo) UncertifiedOlderThan(ctx context.Context, f UncertifiedFilter) ([]UncertifiedDay, int64, error) {
	var (
		out   []UncertifiedDay
		total int64
	)
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		rows, err := q.LogsListUncertifiedOlderThan(ctx, db.LogsListUncertifiedOlderThanParams{
			CompanyID: f.CompanyID, BeforeDate: date(f.Before),
			DriverID: pgconv.UUIDPtr(f.DriverID), BranchID: pgconv.UUIDPtr(f.BranchID),
			Lim: f.Limit, Off: f.Offset,
		})
		if err != nil {
			return err
		}
		out = make([]UncertifiedDay, 0, len(rows))
		for _, row := range rows {
			out = append(out, UncertifiedDay{
				DailyLogID: row.ID, DriverID: row.DriverID,
				DriverName: fullName(row.FirstName, row.LastName),
				LogDate:    row.LogDate.Time, CertificationStatus: row.CertificationStatus,
			})
		}
		total, err = q.LogsCountUncertifiedOlderThan(ctx, db.LogsCountUncertifiedOlderThanParams{
			CompanyID: f.CompanyID, BeforeDate: date(f.Before),
			DriverID: pgconv.UUIDPtr(f.DriverID), BranchID: pgconv.UUIDPtr(f.BranchID),
		})
		return err
	})
	return out, total, err
}

// UncertifiedInWindow implements Repo.
func (r *PgRepo) UncertifiedInWindow(ctx context.Context, companyID, driverID uuid.UUID, from, to time.Time) ([]UncertifiedDay, error) {
	var out []UncertifiedDay
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.LogsListUncertifiedInWindow(ctx, db.LogsListUncertifiedInWindowParams{
			CompanyID: companyID, DriverID: driverID, FromDate: date(from), ToDate: date(to),
		})
		if err != nil {
			return err
		}
		out = make([]UncertifiedDay, 0, len(rows))
		for _, row := range rows {
			out = append(out, UncertifiedDay{
				DailyLogID: row.ID, DriverID: row.DriverID,
				LogDate: row.LogDate.Time, CertificationStatus: row.CertificationStatus,
			})
		}
		return nil
	})
	return out, err
}

// SignatureKey implements Repo: an explicit stored signature or the driver's
// default (Q20-Q24). Q26: the signature always belongs to the signing user.
func (r *PgRepo) SignatureKey(ctx context.Context, companyID, userID uuid.UUID, id *uuid.UUID) (string, error) {
	var out string
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		if id != nil {
			row, err := q.LogsGetSignature(ctx, db.LogsGetSignatureParams{
				CompanyID: companyID, ID: *id, UserID: userID,
			})
			if err != nil {
				return err
			}
			out = row.ImageKeyEnc
			return nil
		}
		row, err := q.LogsGetDefaultSignature(ctx, db.LogsGetDefaultSignatureParams{
			CompanyID: companyID, UserID: userID,
		})
		if err != nil {
			return err
		}
		out = row.ImageKeyEnc
		return nil
	})
	return out, err
}

// Units implements Repo.
func (r *PgRepo) Units(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) ([]UnitRef, error) {
	out := []UnitRef{}
	if len(ids) == 0 {
		return out, nil
	}
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.LogsListUnitNumbersByIDs(ctx, db.LogsListUnitNumbersByIDsParams{
			CompanyID: companyID, Ids: nonNil(ids),
		})
		if err != nil {
			return err
		}
		for _, row := range rows {
			out = append(out, UnitRef{ID: row.ID, UnitNumber: row.UnitNumber, VIN: row.Vin, LicensePlate: row.LicensePlate})
		}
		return nil
	})
	return out, err
}

// Trailers implements Repo.
func (r *PgRepo) Trailers(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) ([]NumberRef, error) {
	out := []NumberRef{}
	if len(ids) == 0 {
		return out, nil
	}
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.LogsListTrailerNumbersByIDs(ctx, db.LogsListTrailerNumbersByIDsParams{
			CompanyID: companyID, Ids: nonNil(ids),
		})
		if err != nil {
			return err
		}
		for _, row := range rows {
			out = append(out, NumberRef{ID: row.ID, Number: row.Number})
		}
		return nil
	})
	return out, err
}

// ShippingDocs implements Repo.
func (r *PgRepo) ShippingDocs(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) ([]NumberRef, error) {
	out := []NumberRef{}
	if len(ids) == 0 {
		return out, nil
	}
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.LogsListShippingDocNumbersByIDs(ctx, db.LogsListShippingDocNumbersByIDsParams{
			CompanyID: companyID, Ids: nonNil(ids),
		})
		if err != nil {
			return err
		}
		for _, row := range rows {
			out = append(out, NumberRef{ID: row.ID, Number: row.Number})
		}
		return nil
	})
	return out, err
}
