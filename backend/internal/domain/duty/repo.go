package duty

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/hos"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// Context is the driver's sync/HOS context: who they are and which timezone
// their log days are cut in (Q10.2).
type Context struct {
	DriverID      uuid.UUID
	CompanyID     uuid.UUID
	UserID        uuid.UUID
	BranchID      *uuid.UUID
	Status        string
	DefaultUnitID *uuid.UUID
	HomeTerminal  *string
	Timezone      string
	// Settings is the companies.settings document, source of quick_notes.
	Settings []byte
}

// Location resolves the home terminal timezone, falling back to UTC when the
// stored name is unknown to the runtime.
func (c Context) Location() *time.Location {
	loc, err := time.LoadLocation(c.Timezone)
	if err != nil || loc == nil {
		return time.UTC
	}
	return loc
}

// PolicyVersion is one hos_policy_versions row resolved for a given instant.
type PolicyVersion struct {
	// ID is nil when no version exists and the FMCSA defaults are used.
	ID     *uuid.UUID
	Policy hos.Policy
}

// PageFilter selects a page of one driver's duty status events.
type PageFilter struct {
	CompanyID uuid.UUID
	DriverID  uuid.UUID
	From      time.Time
	To        time.Time
	Limit     int32
	Offset    int32
}

// StoredEvent is one duty_status_events row the domain works with. It is the
// repository's own shape: the sqlc model never leaves this file.
type StoredEvent struct {
	ID             uuid.UUID
	ClientEventID  uuid.UUID
	DriverID       *uuid.UUID
	UnitID         *uuid.UUID
	EventType      string
	Status         *string
	Special        string
	Origin         string
	EventTime      time.Time
	TimeSource     string
	TimeUnverified bool
	ClockSkewSec   int32
	Lat            *float64
	Lng            *float64
	LocationText   *string
	GPSAccuracyM   *int32
	OdometerM      *int64
	EngineHours    *float64
	Notes          *string
	TrailerIDs     []uuid.UUID
	ShippingDocIDs []uuid.UUID
	DeviceSeq      *int64
	ReceivedAt     time.Time
	SupersededBy   *uuid.UUID
	Locked         bool
	DailyLogID     *uuid.UUID
}

// HosEvent converts the row into the engine's event shape. Only `duty_status`
// rows move the state machine; every other kind is positional (Q5.2).
func (e StoredEvent) HosEvent() hos.Event {
	ev := hos.Event{Time: e.EventTime.UTC(), Special: hos.Special(e.Special)}
	if e.Status != nil {
		ev.Status = hos.Status(*e.Status)
	}
	if e.EventType == eventDutyStatus {
		ev.Type = hos.EventStatusChange
	} else {
		ev.Type = hos.EventType(e.EventType)
	}
	return ev
}

// WriteEvent is one accepted event ready for storage.
type WriteEvent struct {
	ClientEventID  uuid.UUID
	UnitID         *uuid.UUID
	ELDDeviceID    *uuid.UUID
	EventType      string
	Status         *string
	Special        string
	Origin         string
	EventTime      time.Time
	TimeSource     string
	TimeUnverified bool
	ClockSkewSec   int32
	Lat            *float64
	Lng            *float64
	LocationText   *string
	GPSAccuracyM   *int32
	OdometerM      *int64
	EngineHours    *float64
	Notes          *string
	TrailerIDs     []uuid.UUID
	ShippingDocIDs []uuid.UUID
	DeviceSeq      *int64
	// Supersedes are the stored rows this event wins over (conflict rule 1).
	Supersedes []uuid.UUID
	// SupersededBy is the stored row that beat this event; the loser is still
	// written, flagged (conflict rule 1).
	SupersededBy *uuid.UUID
	// LogDate is the home terminal calendar day the event belongs to (Q10.2).
	LogDate time.Time
}

// WriteInput is one driver's accepted batch, written in a single transaction.
type WriteInput struct {
	CompanyID uuid.UUID
	DriverID  uuid.UUID
	Timezone  string
	Events    []WriteEvent
}

// WriteOutcome reports what the transaction actually did.
type WriteOutcome struct {
	Written int
	// Days are the log days whose totals were recomputed.
	Days []time.Time
}

// Repo is everything the duty service needs from storage.
type Repo interface {
	DriverContext(ctx context.Context, companyID, driverID uuid.UUID) (Context, error)
	DriverByUser(ctx context.Context, companyID, userID uuid.UUID) (Context, error)
	PolicyAt(ctx context.Context, companyID uuid.UUID, at time.Time) (PolicyVersion, error)
	UnitFlags(ctx context.Context, companyID, unitID uuid.UUID) (db.SyncGetUnitFlagsRow, error)

	EventsBetween(ctx context.Context, companyID, driverID uuid.UUID, from, to time.Time) ([]StoredEvent, error)
	EventsPage(ctx context.Context, f PageFilter) ([]StoredEvent, int64, error)

	// KnownClientEventIDs reports which of ids are already stored. The second
	// map value is false when the row belongs to another tenant.
	KnownClientEventIDs(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) (map[uuid.UUID]bool, error)
	// CertifiedDays returns the subset of days already certified (rule 5).
	CertifiedDays(ctx context.Context, companyID, driverID uuid.UUID, days []time.Time) (map[string]bool, error)
	// EventsAtInstants returns the stored duty status events inside [from,to],
	// used to resolve conflict rule 1.
	EventsAtInstants(ctx context.Context, companyID, driverID uuid.UUID, from, to time.Time) ([]StoredEvent, error)

	Write(ctx context.Context, in WriteInput, entries []audit.Entry) (WriteOutcome, error)
}

// TxRunner is the subset of *db.Pool this repository needs.
type TxRunner interface {
	WithTx(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error
	WithConn(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error
}

// PgRepo is the pgx/sqlc implementation of Repo. Every transaction opens with
// SET LOCAL app.company_id, so RLS is the second line of tenant defence.
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

// DriverContext implements Repo.
func (r *PgRepo) DriverContext(ctx context.Context, companyID, driverID uuid.UUID) (Context, error) {
	var out Context
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		row, err := q.SyncGetDriverContext(ctx, db.SyncGetDriverContextParams{CompanyID: companyID, ID: driverID})
		if err != nil {
			return err
		}
		out = Context{
			DriverID: row.ID, CompanyID: row.CompanyID, UserID: row.UserID,
			BranchID: pgconv.ToUUIDPtr(row.BranchID), Status: row.Status,
			DefaultUnitID: pgconv.ToUUIDPtr(row.DefaultUnitID), HomeTerminal: row.HomeTerminal,
			Timezone: row.Timezone, Settings: row.Settings,
		}
		return nil
	})
	return out, err
}

// DriverByUser implements Repo.
func (r *PgRepo) DriverByUser(ctx context.Context, companyID, userID uuid.UUID) (Context, error) {
	var out Context
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		row, err := q.SyncGetDriverByUserID(ctx, db.SyncGetDriverByUserIDParams{CompanyID: companyID, UserID: userID})
		if err != nil {
			return err
		}
		out = Context{
			DriverID: row.ID, CompanyID: row.CompanyID, UserID: row.UserID,
			BranchID: pgconv.ToUUIDPtr(row.BranchID), Status: row.Status,
			DefaultUnitID: pgconv.ToUUIDPtr(row.DefaultUnitID), HomeTerminal: row.HomeTerminal,
			Timezone: row.Timezone, Settings: row.Settings,
		}
		return nil
	})
	return out, err
}

// PolicyAt implements Repo. Q10.1: the version in force on that instant, never
// the newest one, so past days keep the policy they were logged under.
func (r *PgRepo) PolicyAt(ctx context.Context, companyID uuid.UUID, at time.Time) (PolicyVersion, error) {
	out := PolicyVersion{Policy: hos.DefaultPolicy()}
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		row, err := q.SyncGetHosPolicyAt(ctx, db.SyncGetHosPolicyAtParams{CompanyID: companyID, At: at})
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		if err != nil {
			return err
		}
		p, perr := hos.ParsePolicy(row.Policy)
		if perr != nil {
			// A malformed stored policy must not take HOS offline; the
			// defaults apply and the version id is still reported.
			p = hos.DefaultPolicy()
		}
		id := row.ID
		out = PolicyVersion{ID: &id, Policy: p}
		return nil
	})
	return out, err
}

// UnitFlags implements Repo.
func (r *PgRepo) UnitFlags(ctx context.Context, companyID, unitID uuid.UUID) (db.SyncGetUnitFlagsRow, error) {
	var out db.SyncGetUnitFlagsRow
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.SyncGetUnitFlags(ctx, db.SyncGetUnitFlagsParams{CompanyID: companyID, ID: unitID})
		return err
	})
	return out, err
}

// EventsBetween implements Repo.
func (r *PgRepo) EventsBetween(ctx context.Context, companyID, driverID uuid.UUID, from, to time.Time) ([]StoredEvent, error) {
	var out []StoredEvent
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.DutyListDriverEventsBetween(ctx, db.DutyListDriverEventsBetweenParams{
			CompanyID: companyID, DriverID: pgconv.UUID(driverID), FromAt: from, ToAt: to,
		})
		if err != nil {
			return err
		}
		out = make([]StoredEvent, 0, len(rows))
		for _, row := range rows {
			out = append(out, betweenRow(row))
		}
		return nil
	})
	return out, err
}

// EventsPage implements Repo.
func (r *PgRepo) EventsPage(ctx context.Context, f PageFilter) ([]StoredEvent, int64, error) {
	var (
		out   []StoredEvent
		total int64
	)
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		rows, err := q.DutyListDriverEventsPage(ctx, db.DutyListDriverEventsPageParams{
			CompanyID: f.CompanyID, DriverID: pgconv.UUID(f.DriverID),
			FromAt: f.From, ToAt: f.To, Lim: f.Limit, Off: f.Offset,
		})
		if err != nil {
			return err
		}
		out = make([]StoredEvent, 0, len(rows))
		for _, row := range rows {
			out = append(out, pageRow(row))
		}
		total, err = q.DutyCountDriverEventsBetween(ctx, db.DutyCountDriverEventsBetweenParams{
			CompanyID: f.CompanyID, DriverID: pgconv.UUID(f.DriverID), FromAt: f.From, ToAt: f.To,
		})
		return err
	})
	return out, total, err
}

// KnownClientEventIDs implements Repo.
func (r *PgRepo) KnownClientEventIDs(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) (map[uuid.UUID]bool, error) {
	out := make(map[uuid.UUID]bool, len(ids))
	if len(ids) == 0 {
		return out, nil
	}
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.SyncKnownClientEventIDs(ctx, db.SyncKnownClientEventIDsParams{
			CompanyID: companyID, ClientEventIds: ids,
		})
		if err != nil {
			return err
		}
		for _, row := range rows {
			out[row.ClientEventID] = row.SameCompany
		}
		return nil
	})
	return out, err
}

// CertifiedDays implements Repo. The key is the YYYY-MM-DD calendar day.
func (r *PgRepo) CertifiedDays(ctx context.Context, companyID, driverID uuid.UUID, days []time.Time) (map[string]bool, error) {
	out := make(map[string]bool, len(days))
	if len(days) == 0 {
		return out, nil
	}
	dates := make([]pgtype.Date, 0, len(days))
	for _, d := range days {
		dates = append(dates, pgtype.Date{Time: dayUTC(d), Valid: true})
	}
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.SyncListCertifiedLogDates(ctx, db.SyncListCertifiedLogDatesParams{
			CompanyID: companyID, DriverID: driverID, LogDates: dates,
		})
		if err != nil {
			return err
		}
		for _, d := range rows {
			if d.Valid {
				out[d.Time.Format(dayLayout)] = true
			}
		}
		return nil
	})
	return out, err
}

// EventsAtInstants implements Repo.
func (r *PgRepo) EventsAtInstants(ctx context.Context, companyID, driverID uuid.UUID, from, to time.Time) ([]StoredEvent, error) {
	var out []StoredEvent
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.SyncListEventsAtInstants(ctx, db.SyncListEventsAtInstantsParams{
			CompanyID: companyID, DriverID: pgconv.UUID(driverID), FromAt: from, ToAt: to,
		})
		if err != nil {
			return err
		}
		out = make([]StoredEvent, 0, len(rows))
		for _, row := range rows {
			out = append(out, StoredEvent{
				ID: row.ID, ClientEventID: row.ClientEventID, EventTime: row.EventTime,
				TimeSource: row.TimeSource, DeviceSeq: row.DeviceSeq, ReceivedAt: row.ReceivedAt,
			})
		}
		return nil
	})
	return out, err
}
