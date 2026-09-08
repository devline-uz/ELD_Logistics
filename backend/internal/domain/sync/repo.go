package sync

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// PullFilter selects one device's catch-up window.
type PullFilter struct {
	CompanyID uuid.UUID
	DriverID  uuid.UUID
	// UnitIDs are the units whose unidentified driving buffer is offered to
	// this driver (TZ A§10.4).
	UnitIDs []uuid.UUID
	Since   time.Time
	Limit   int32
}

// Repo is the pull side of the sync module. The push side writes through the
// duty and telemetry services, so nothing here mutates.
type Repo interface {
	ChangedEvents(ctx context.Context, f PullFilter) ([]db.SyncListEventsChangedSinceRow, error)
	ChangedDailyLogs(ctx context.Context, f PullFilter) ([]db.SyncListDailyLogsChangedSinceRow, error)
	Unidentified(ctx context.Context, f PullFilter) ([]db.SyncListUnidentifiedForUnitsRow, error)
	Chat(ctx context.Context, f PullFilter) ([]db.SyncListChatSinceRow, error)
	DefectTypes(ctx context.Context, companyID uuid.UUID) ([]db.SyncListDefectTypesRow, error)
	// PendingLogEdits are the proposals waiting for this driver's answer (Q17).
	PendingLogEdits(ctx context.Context, f PullFilter) ([]db.LogsListPendingEditRequestsForDriverRow, error)
}

// TxRunner is the subset of *db.Pool this repository needs.
type TxRunner interface {
	WithConn(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error
}

// PgRepo is the pgx/sqlc implementation of Repo. Every connection opens with
// SET LOCAL app.company_id, so RLS is the second line of tenant defence.
type PgRepo struct {
	pool TxRunner
}

// NewRepo builds the storage adapter.
func NewRepo(pool TxRunner) *PgRepo { return &PgRepo{pool: pool} }

func (r *PgRepo) read(ctx context.Context, companyID uuid.UUID, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error { return fn(db.New(tx)) })
}

// ChangedEvents implements Repo.
func (r *PgRepo) ChangedEvents(ctx context.Context, f PullFilter) ([]db.SyncListEventsChangedSinceRow, error) {
	var out []db.SyncListEventsChangedSinceRow
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		out, err = q.SyncListEventsChangedSince(ctx, db.SyncListEventsChangedSinceParams{
			CompanyID: f.CompanyID, DriverID: pgconv.UUID(f.DriverID), Since: f.Since, Lim: f.Limit,
		})
		return err
	})
	return out, err
}

// ChangedDailyLogs implements Repo.
func (r *PgRepo) ChangedDailyLogs(ctx context.Context, f PullFilter) ([]db.SyncListDailyLogsChangedSinceRow, error) {
	var out []db.SyncListDailyLogsChangedSinceRow
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		out, err = q.SyncListDailyLogsChangedSince(ctx, db.SyncListDailyLogsChangedSinceParams{
			CompanyID: f.CompanyID, DriverID: f.DriverID, Since: f.Since, Lim: f.Limit,
		})
		return err
	})
	return out, err
}

// Unidentified implements Repo.
func (r *PgRepo) Unidentified(ctx context.Context, f PullFilter) ([]db.SyncListUnidentifiedForUnitsRow, error) {
	if len(f.UnitIDs) == 0 {
		return nil, nil
	}
	var out []db.SyncListUnidentifiedForUnitsRow
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		out, err = q.SyncListUnidentifiedForUnits(ctx, db.SyncListUnidentifiedForUnitsParams{
			CompanyID: f.CompanyID, UnitIds: f.UnitIDs, Since: f.Since, Lim: f.Limit,
		})
		return err
	})
	return out, err
}

// Chat implements Repo.
func (r *PgRepo) Chat(ctx context.Context, f PullFilter) ([]db.SyncListChatSinceRow, error) {
	var out []db.SyncListChatSinceRow
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		out, err = q.SyncListChatSince(ctx, db.SyncListChatSinceParams{
			CompanyID: f.CompanyID, DriverID: f.DriverID, Since: f.Since, Lim: f.Limit,
		})
		return err
	})
	return out, err
}

// DefectTypes implements Repo. The catalogue is small and has no cursor: it is
// returned in full on every pull so the offline DVIR form is never stale.
func (r *PgRepo) DefectTypes(ctx context.Context, companyID uuid.UUID) ([]db.SyncListDefectTypesRow, error) {
	var out []db.SyncListDefectTypesRow
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.SyncListDefectTypes(ctx, pgconv.UUID(companyID))
		return err
	})
	return out, err
}

// PendingLogEdits implements Repo (Q17): the propose/approve queue the device
// renders on its "Pending edits" screen.
func (r *PgRepo) PendingLogEdits(ctx context.Context, f PullFilter) ([]db.LogsListPendingEditRequestsForDriverRow, error) {
	var out []db.LogsListPendingEditRequestsForDriverRow
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		out, err = q.LogsListPendingEditRequestsForDriver(ctx, db.LogsListPendingEditRequestsForDriverParams{
			CompanyID: f.CompanyID, DriverID: f.DriverID, Since: f.Since, Lim: f.Limit,
		})
		return err
	})
	return out, err
}
