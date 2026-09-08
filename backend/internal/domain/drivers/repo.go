package drivers

import (
	"context"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
)

// ListFilter is the whitelisted filter set of GET /drivers.
type ListFilter struct {
	CompanyID       uuid.UUID
	Search          *string
	Status          *string
	BranchID        *uuid.UUID
	FleetManagerID  *uuid.UUID
	IncludeInactive bool
	SortKey         string
	Limit           int32
	Offset          int32
}

// ExportFilter is the filter set of GET /drivers/export.
type ExportFilter struct {
	CompanyID       uuid.UUID
	Status          *string
	BranchID        *uuid.UUID
	IncludeInactive bool
	Limit           int32
}

// ActivityFilter selects the activity feed of one driver.
type ActivityFilter struct {
	CompanyID uuid.UUID
	DriverID  uuid.UUID
	UserID    uuid.UUID
	Limit     int32
	Offset    int32
}

// InvitationInput is the invitation row created next to a new driver account.
type InvitationInput struct {
	TokenHash string
	Channel   string
	Purpose   string
	ExpiresAt time.Time
}

// CreateInput is everything one POST /drivers writes, in a single transaction:
// the users row (Driver role, status=invited), the drivers row, the optional
// co-driver pair and the invitation.
type CreateInput struct {
	CompanyID      uuid.UUID
	RoleID         uuid.UUID
	BranchID       *uuid.UUID
	FirstName      string
	LastName       string
	Username       string
	Email          *string
	Phone          *string
	LicenseNoEnc   *string
	LicenseRegion  *string
	HomeTerminal   *string
	City           *string
	State          *string
	Zip            *string
	Address1       *string
	Address2       *string
	Notes          *string
	FleetManagerID *uuid.UUID
	DefaultUnitID  *uuid.UUID
	CoDriverID     *uuid.UUID
	Invitation     *InvitationInput
	InvitedAt      time.Time
}

// UpdateInput is the resolved PATCH payload. Nil fields are left untouched.
type UpdateInput struct {
	CompanyID uuid.UUID
	DriverID  uuid.UUID
	UserID    uuid.UUID

	FirstName *string
	LastName  *string
	Email     *string
	Phone     *string

	BranchID       *uuid.UUID
	LicenseNoEnc   *string
	LicenseRegion  *string
	HomeTerminal   *string
	City           *string
	State          *string
	Zip            *string
	Address1       *string
	Address2       *string
	Notes          *string
	FleetManagerID *uuid.UUID
	DefaultUnitID  *uuid.UUID
}

// Repo is everything the driver service needs from storage. Every statement is
// parameterised sqlc output; nothing is concatenated.
type Repo interface {
	List(ctx context.Context, f ListFilter) ([]db.ListDriversPageRow, int64, error)
	Export(ctx context.Context, f ExportFilter) ([]db.ListDriversForExportRow, error)
	Get(ctx context.Context, companyID, id uuid.UUID) (db.GetDriverDetailRow, error)
	CoDrivers(ctx context.Context, companyID, driverID uuid.UUID) ([]db.ListCoDriverDetailsRow, error)
	Activities(ctx context.Context, f ActivityFilter) ([]db.ListDriverActivitiesRow, int64, error)
	RoleByName(ctx context.Context, companyID uuid.UUID, name string) (db.Role, error)
	UserByID(ctx context.Context, companyID, id uuid.UUID) (db.User, error)

	Create(ctx context.Context, in CreateInput, entries []audit.Entry) (db.GetDriverDetailRow, error)
	Update(ctx context.Context, in UpdateInput, entries []audit.Entry) (db.GetDriverDetailRow, error)
	SetStatus(
		ctx context.Context, companyID, driverID, userID uuid.UUID, status string, entries []audit.Entry,
	) (db.GetDriverDetailRow, error)
	SoftDelete(ctx context.Context, companyID, driverID, userID uuid.UUID, entries []audit.Entry) error
	LinkCoDriver(ctx context.Context, companyID, a, b uuid.UUID, entries []audit.Entry) error
	UnlinkCoDriver(ctx context.Context, companyID, a, b uuid.UUID, entries []audit.Entry) error
	ResetInvitation(ctx context.Context, companyID, userID uuid.UUID, in InvitationInput, entries []audit.Entry) error
	RevokeUserSessions(ctx context.Context, companyID, userID uuid.UUID, reason string) ([]uuid.UUID, error)
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

// NewRepo builds the storage adapter. recorder writes the audit trail inside
// the same transaction as the change it describes.
func NewRepo(pool TxRunner, recorder audit.Recorder) *PgRepo {
	if recorder == nil {
		recorder = audit.NopRecorder{}
	}
	return &PgRepo{pool: pool, recorder: recorder}
}

func (r *PgRepo) read(ctx context.Context, companyID uuid.UUID, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error { return fn(db.New(tx)) })
}

func (r *PgRepo) write(ctx context.Context, companyID uuid.UUID, fn func(q *db.Queries, tx pgx.Tx) error) error {
	return r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error { return fn(db.New(tx), tx) })
}

// List implements Repo.
func (r *PgRepo) List(ctx context.Context, f ListFilter) ([]db.ListDriversPageRow, int64, error) {
	var (
		rows  []db.ListDriversPageRow
		total int64
	)
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		rows, err = q.ListDriversPage(ctx, db.ListDriversPageParams{
			CompanyID:       f.CompanyID,
			Search:          f.Search,
			Status:          f.Status,
			BranchID:        pgconv.UUIDPtr(f.BranchID),
			FleetManagerID:  pgconv.UUIDPtr(f.FleetManagerID),
			IncludeInactive: f.IncludeInactive,
			SortKey:         f.SortKey,
			Lim:             f.Limit,
			Off:             f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountDriversPage(ctx, db.CountDriversPageParams{
			CompanyID:       f.CompanyID,
			Search:          f.Search,
			Status:          f.Status,
			BranchID:        pgconv.UUIDPtr(f.BranchID),
			FleetManagerID:  pgconv.UUIDPtr(f.FleetManagerID),
			IncludeInactive: f.IncludeInactive,
		})
		return err
	})
	return rows, total, err
}

// Export implements Repo.
func (r *PgRepo) Export(ctx context.Context, f ExportFilter) ([]db.ListDriversForExportRow, error) {
	var rows []db.ListDriversForExportRow
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		rows, err = q.ListDriversForExport(ctx, db.ListDriversForExportParams{
			CompanyID:       f.CompanyID,
			Status:          f.Status,
			BranchID:        pgconv.UUIDPtr(f.BranchID),
			IncludeInactive: f.IncludeInactive,
			Lim:             f.Limit,
		})
		return err
	})
	return rows, err
}

// Get implements Repo.
func (r *PgRepo) Get(ctx context.Context, companyID, id uuid.UUID) (db.GetDriverDetailRow, error) {
	var row db.GetDriverDetailRow
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		row, err = q.GetDriverDetail(ctx, db.GetDriverDetailParams{CompanyID: companyID, ID: id})
		return err
	})
	return row, err
}

// Activities implements Repo.
func (r *PgRepo) Activities(ctx context.Context, f ActivityFilter) ([]db.ListDriverActivitiesRow, int64, error) {
	var (
		rows  []db.ListDriverActivitiesRow
		total int64
	)
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		rows, err = q.ListDriverActivities(ctx, db.ListDriverActivitiesParams{
			CompanyID: f.CompanyID, DriverID: f.DriverID, UserID: f.UserID,
			Lim: f.Limit, Off: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountDriverActivities(ctx, db.CountDriverActivitiesParams{
			CompanyID: f.CompanyID, DriverID: f.DriverID, UserID: f.UserID,
		})
		return err
	})
	return rows, total, err
}

// RoleByName implements Repo.
func (r *PgRepo) RoleByName(ctx context.Context, companyID uuid.UUID, name string) (db.Role, error) {
	var role db.Role
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		role, err = q.GetRoleByNameForCompany(ctx, db.GetRoleByNameForCompanyParams{
			Name: name, CompanyID: companyID,
		})
		return err
	})
	return role, err
}

// UserByID implements Repo.
func (r *PgRepo) UserByID(ctx context.Context, companyID, id uuid.UUID) (db.User, error) {
	var user db.User
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		user, err = q.GetUser(ctx, db.GetUserParams{CompanyID: pgconv.UUID(companyID), ID: id})
		return err
	})
	return user, err
}

// ResetInvitation implements Repo: the previous link is burned and a fresh one
// is issued in the same transaction.
func (r *PgRepo) ResetInvitation(ctx context.Context, companyID, userID uuid.UUID, in InvitationInput, entries []audit.Entry) error {
	return r.write(ctx, companyID, func(q *db.Queries, tx pgx.Tx) error {
		if err := q.InvalidateUserInvitations(ctx, db.InvalidateUserInvitationsParams{
			UserID: userID, Purpose: in.Purpose,
		}); err != nil {
			return err
		}
		if _, err := q.CreateInvitation(ctx, db.CreateInvitationParams{
			CompanyID: pgconv.UUID(companyID),
			UserID:    userID,
			TokenHash: in.TokenHash,
			Channel:   in.Channel,
			Purpose:   in.Purpose,
			ExpiresAt: in.ExpiresAt,
		}); err != nil {
			return err
		}
		return r.recordTx(ctx, tx, userID, entries)
	})
}

// RevokeUserSessions implements Repo and returns the revoked session ids so the
// service can add them to the access token deny list.
func (r *PgRepo) RevokeUserSessions(ctx context.Context, companyID, userID uuid.UUID, reason string) ([]uuid.UUID, error) {
	var ids []uuid.UUID
	err := r.write(ctx, companyID, func(q *db.Queries, _ pgx.Tx) error {
		var err error
		ids, err = q.RevokeAllUserSessionsReturning(ctx, db.RevokeAllUserSessionsReturningParams{
			UserID: userID, RevokedReason: &reason,
		})
		return err
	})
	return ids, err
}

func (r *PgRepo) recordTx(ctx context.Context, tx pgx.Tx, recordID uuid.UUID, entries []audit.Entry) error {
	if len(entries) == 0 {
		return nil
	}
	filled := make([]audit.Entry, 0, len(entries))
	for _, e := range entries {
		if e.RecordID == uuid.Nil {
			e.RecordID = recordID
		}
		filled = append(filled, e)
	}
	return r.recorder.RecordTx(ctx, tx, filled...)
}
