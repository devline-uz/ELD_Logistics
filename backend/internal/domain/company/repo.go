package company

import (
	"context"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
)

// ListBranchesInput is the paginated, sorted branch query.
type ListBranchesInput struct {
	CompanyID uuid.UUID
	Search    *string
	SortBy    string
	SortDir   string
	Limit     int32
	Offset    int32
}

// CreateBranchInput inserts one branch together with its audit trail.
type CreateBranchInput struct {
	CompanyID uuid.UUID
	Name      string
	Address   *string
	Timezone  *string
	Audit     []audit.Entry
}

// UpdateBranchInput patches one branch.
type UpdateBranchInput struct {
	CompanyID uuid.UUID
	ID        uuid.UUID
	Name      *string
	Address   *string
	Timezone  *string
	Audit     []audit.Entry
}

// DeleteBranchInput soft deletes one branch.
type DeleteBranchInput struct {
	CompanyID uuid.UUID
	ID        uuid.UUID
	Audit     []audit.Entry
}

// UpdateCompanyInput patches the tenant profile.
type UpdateCompanyInput struct {
	CompanyID uuid.UUID
	Params    db.UpdateCompanyParams
	Audit     []audit.Entry
}

// CreateHosPolicyInput publishes a new hos_policy_versions row. A nil
// EffectiveFrom means "now" as the database clock sees it.
type CreateHosPolicyInput struct {
	CompanyID     uuid.UUID
	EffectiveFrom *time.Time
	Policy        []byte
	CreatedBy     uuid.UUID
	Audit         []audit.Entry
}

// NotificationSettingInput is one alert type configuration to store.
type NotificationSettingInput struct {
	AlertType      string
	Channels       []string
	RecipientRoles []uuid.UUID
	Enabled        bool
}

// UpsertNotificationsInput writes a batch of alert configurations.
type UpsertNotificationsInput struct {
	CompanyID uuid.UUID
	Settings  []NotificationSettingInput
	Audit     []audit.Entry
}

// HistoryFilter is the audit trail query behind GET /company/history.
type HistoryFilter struct {
	CompanyID uuid.UUID
	TableName *string
	Action    *string
	RecordID  *uuid.UUID
	EditedBy  *uuid.UUID
	From      *time.Time
	To        *time.Time
	Limit     int32
	Offset    int32
}

// Repo is everything the company service needs from storage.
type Repo interface {
	Company(ctx context.Context, companyID uuid.UUID) (db.Company, error)
	UpdateCompany(ctx context.Context, in UpdateCompanyInput) (db.Company, error)

	ListBranches(ctx context.Context, in ListBranchesInput) ([]db.Branch, int64, error)
	GetBranch(ctx context.Context, companyID, id uuid.UUID) (db.Branch, error)
	CreateBranch(ctx context.Context, in CreateBranchInput) (db.Branch, error)
	UpdateBranch(ctx context.Context, in UpdateBranchInput) (db.Branch, error)
	DeleteBranch(ctx context.Context, in DeleteBranchInput) error

	ActiveHosPolicy(ctx context.Context, companyID uuid.UUID) (db.HosPolicyVersion, error)
	CreateHosPolicy(ctx context.Context, in CreateHosPolicyInput) (db.HosPolicyVersion, error)

	NotificationSettings(ctx context.Context, companyID uuid.UUID) ([]db.NotificationSetting, error)
	UpsertNotificationSettings(ctx context.Context, in UpsertNotificationsInput) ([]db.NotificationSetting, error)

	History(ctx context.Context, f HistoryFilter) ([]db.ListCompanyAuditHistoryRow, int64, error)
}

// PgRepo is the pgx/sqlc implementation of Repo. Every statement runs inside a
// transaction scoped with SET LOCAL app.company_id, so RLS is the second line
// of tenant defence and the audit trail is atomic with the change.
type PgRepo struct {
	pool *db.Pool
	rec  audit.Recorder
}

// NewRepo builds the storage adapter.
func NewRepo(pool *db.Pool, rec audit.Recorder) *PgRepo {
	if rec == nil {
		rec = audit.NopRecorder{}
	}
	return &PgRepo{pool: pool, rec: rec}
}

func (r *PgRepo) read(ctx context.Context, companyID uuid.UUID, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error {
		return fn(db.New(tx))
	})
}

func (r *PgRepo) write(ctx context.Context, companyID uuid.UUID, fn func(tx pgx.Tx, q *db.Queries) error) error {
	return r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		return fn(tx, db.New(tx))
	})
}

// record stamps the record id on entries that were built before the row
// existed and writes them inside the caller transaction.
func (r *PgRepo) record(ctx context.Context, tx pgx.Tx, companyID, recordID uuid.UUID, entries []audit.Entry) error {
	if len(entries) == 0 {
		return nil
	}
	out := make([]audit.Entry, 0, len(entries))
	for _, e := range entries {
		if e.RecordID == uuid.Nil {
			e.RecordID = recordID
		}
		if e.CompanyID == uuid.Nil {
			e.CompanyID = companyID
		}
		out = append(out, e)
	}
	return r.rec.RecordTx(ctx, tx, out...)
}

// Company implements Repo.
func (r *PgRepo) Company(ctx context.Context, companyID uuid.UUID) (db.Company, error) {
	var out db.Company
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.GetCompany(ctx, companyID)
		return err
	})
	return out, db.MapError(err, "company")
}

// UpdateCompany implements Repo.
func (r *PgRepo) UpdateCompany(ctx context.Context, in UpdateCompanyInput) (db.Company, error) {
	var out db.Company
	err := r.write(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		var err error
		if out, err = q.UpdateCompany(ctx, in.Params); err != nil {
			return err
		}
		return r.record(ctx, tx, in.CompanyID, out.ID, in.Audit)
	})
	return out, db.MapError(err, "company")
}

// ListBranches implements Repo.
func (r *PgRepo) ListBranches(ctx context.Context, in ListBranchesInput) ([]db.Branch, int64, error) {
	var (
		rows  []db.Branch
		total int64
	)
	err := r.read(ctx, in.CompanyID, func(q *db.Queries) error {
		var err error
		if total, err = q.CountBranches(ctx, db.CountBranchesParams{
			CompanyID: in.CompanyID, Search: in.Search,
		}); err != nil {
			return err
		}
		rows, err = q.ListBranches(ctx, db.ListBranchesParams{
			CompanyID: in.CompanyID,
			Search:    in.Search,
			SortBy:    in.SortBy,
			SortDir:   in.SortDir,
			RowLimit:  in.Limit,
			RowOffset: in.Offset,
		})
		return err
	})
	return rows, total, db.MapError(err, "branch")
}

// GetBranch implements Repo.
func (r *PgRepo) GetBranch(ctx context.Context, companyID, id uuid.UUID) (db.Branch, error) {
	var out db.Branch
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.GetBranch(ctx, db.GetBranchParams{CompanyID: companyID, ID: id})
		return err
	})
	return out, db.MapError(err, "branch")
}

// CreateBranch implements Repo.
func (r *PgRepo) CreateBranch(ctx context.Context, in CreateBranchInput) (db.Branch, error) {
	var out db.Branch
	err := r.write(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		var err error
		if out, err = q.CreateBranch(ctx, db.CreateBranchParams{
			CompanyID: in.CompanyID, Name: in.Name, Address: in.Address, Timezone: in.Timezone,
		}); err != nil {
			return err
		}
		return r.record(ctx, tx, in.CompanyID, out.ID, in.Audit)
	})
	return out, db.MapError(err, "branch")
}

// UpdateBranch implements Repo.
func (r *PgRepo) UpdateBranch(ctx context.Context, in UpdateBranchInput) (db.Branch, error) {
	var out db.Branch
	err := r.write(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		var err error
		if out, err = q.UpdateBranch(ctx, db.UpdateBranchParams{
			CompanyID: in.CompanyID, ID: in.ID,
			Name: in.Name, Address: in.Address, Timezone: in.Timezone,
		}); err != nil {
			return err
		}
		return r.record(ctx, tx, in.CompanyID, out.ID, in.Audit)
	})
	return out, db.MapError(err, "branch")
}

// DeleteBranch implements Repo. A branch that still has users cannot be
// removed; the caller sees 409 RESOURCE_IN_USE.
func (r *PgRepo) DeleteBranch(ctx context.Context, in DeleteBranchInput) error {
	err := r.write(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		if _, err := q.GetBranch(ctx, db.GetBranchParams{CompanyID: in.CompanyID, ID: in.ID}); err != nil {
			return err
		}
		n, err := q.CountBranchUsers(ctx, db.CountBranchUsersParams{
			CompanyID: pgconv.UUID(in.CompanyID), BranchID: pgconv.UUID(in.ID),
		})
		if err != nil {
			return err
		}
		if n > 0 {
			return apierr.New(apierr.CodeInUse, 409, "branch still has assigned users")
		}
		if err := q.SoftDeleteBranch(ctx, db.SoftDeleteBranchParams{CompanyID: in.CompanyID, ID: in.ID}); err != nil {
			return err
		}
		return r.record(ctx, tx, in.CompanyID, in.ID, in.Audit)
	})
	return db.MapError(err, "branch")
}

// ActiveHosPolicy implements Repo.
func (r *PgRepo) ActiveHosPolicy(ctx context.Context, companyID uuid.UUID) (db.HosPolicyVersion, error) {
	var out db.HosPolicyVersion
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.GetActiveHosPolicy(ctx, companyID)
		return err
	})
	return out, db.MapError(err, "hos policy")
}

// CreateHosPolicy implements Repo.
func (r *PgRepo) CreateHosPolicy(ctx context.Context, in CreateHosPolicyInput) (db.HosPolicyVersion, error) {
	var out db.HosPolicyVersion
	err := r.write(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		var err error
		if out, err = q.CreateHosPolicyVersion(ctx, db.CreateHosPolicyVersionParams{
			CompanyID:     in.CompanyID,
			EffectiveFrom: pgconv.TimePtr(in.EffectiveFrom),
			Policy:        in.Policy,
			CreatedBy:     pgconv.UUID(in.CreatedBy),
		}); err != nil {
			return err
		}
		return r.record(ctx, tx, in.CompanyID, out.ID, in.Audit)
	})
	return out, db.MapError(err, "hos policy")
}

// NotificationSettings implements Repo.
func (r *PgRepo) NotificationSettings(ctx context.Context, companyID uuid.UUID) ([]db.NotificationSetting, error) {
	var rows []db.NotificationSetting
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		rows, err = q.ListNotificationSettings(ctx, companyID)
		return err
	})
	return rows, db.MapError(err, "notification settings")
}

// UpsertNotificationSettings implements Repo.
func (r *PgRepo) UpsertNotificationSettings(ctx context.Context, in UpsertNotificationsInput) ([]db.NotificationSetting, error) {
	var rows []db.NotificationSetting
	err := r.write(ctx, in.CompanyID, func(tx pgx.Tx, q *db.Queries) error {
		for _, s := range in.Settings {
			if _, err := q.UpsertNotificationSetting(ctx, db.UpsertNotificationSettingParams{
				CompanyID:      in.CompanyID,
				AlertType:      s.AlertType,
				Channels:       s.Channels,
				RecipientRoles: s.RecipientRoles,
				Enabled:        s.Enabled,
			}); err != nil {
				return err
			}
		}
		if err := r.record(ctx, tx, in.CompanyID, in.CompanyID, in.Audit); err != nil {
			return err
		}
		var err error
		rows, err = q.ListNotificationSettings(ctx, in.CompanyID)
		return err
	})
	return rows, db.MapError(err, "notification settings")
}

// History implements Repo.
func (r *PgRepo) History(ctx context.Context, f HistoryFilter) ([]db.ListCompanyAuditHistoryRow, int64, error) {
	var (
		rows  []db.ListCompanyAuditHistoryRow
		total int64
	)
	companyID := pgconv.UUID(f.CompanyID)
	recordID, editedBy := pgtype.UUID{}, pgtype.UUID{}
	if f.RecordID != nil {
		recordID = pgconv.UUID(*f.RecordID)
	}
	if f.EditedBy != nil {
		editedBy = pgconv.UUID(*f.EditedBy)
	}
	from, to := pgconv.TimePtr(f.From), pgconv.TimePtr(f.To)

	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		if total, err = q.CountCompanyAuditHistory(ctx, db.CountCompanyAuditHistoryParams{
			CompanyID: companyID, TableName: f.TableName, Action: f.Action,
			RecordID: recordID, EditedBy: editedBy, FromTs: from, ToTs: to,
		}); err != nil {
			return err
		}
		rows, err = q.ListCompanyAuditHistory(ctx, db.ListCompanyAuditHistoryParams{
			CompanyID: companyID, TableName: f.TableName, Action: f.Action,
			RecordID: recordID, EditedBy: editedBy, FromTs: from, ToTs: to,
			RowLimit: f.Limit, RowOffset: f.Offset,
		})
		return err
	})
	return rows, total, db.MapError(err, "history")
}
