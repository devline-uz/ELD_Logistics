package files

import (
	"context"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
)

// DriverRow is one validated row of drivers_import_template.
type DriverRow struct {
	Row           int
	FirstName     string
	LastName      string
	Username      string
	Phone         string
	Email         string
	LicenseNoEnc  *string
	LicenseRegion string
	HomeTerminal  string
}

// UnitRow is one validated row of units_import_template.
type UnitRow struct {
	Row          int
	UnitNumber   string
	Make         string
	Model        string
	Year         *int32
	Plate        string
	PlateRegion  string
	VIN          string
	FuelType     string
	SleeperBerth bool
}

// DriverInvitation is the invitation issued next to an imported driver.
type DriverInvitation struct {
	TokenHash string
	Channel   string
	Recipient string
	Purpose   string
	ExpiresAt time.Time
}

// ImportedDriver reports one created account so the service can deliver its
// invitation after the transaction has committed.
type ImportedDriver struct {
	UserID    uuid.UUID
	DriverID  uuid.UUID
	Channel   string
	Recipient string
	Token     string
	ExpiresAt time.Time
}

// ExportFilter narrows an export to a status / branch subset.
type ExportFilter struct {
	CompanyID       uuid.UUID
	Status          *string
	BranchID        *uuid.UUID
	IncludeInactive bool
	Limit           int32
}

// Repo is everything the files module needs from storage.
type Repo interface {
	RoleByName(ctx context.Context, companyID uuid.UUID, name string) (db.Role, error)
	ExistingUsernames(ctx context.Context, companyID uuid.UUID, usernames []string) ([]string, error)
	ExistingEmails(ctx context.Context, companyID uuid.UUID, emails []string) ([]string, error)
	ExistingUnitNumbers(ctx context.Context, companyID uuid.UUID, numbers []string) ([]string, error)
	ExistingVINs(ctx context.Context, companyID uuid.UUID, vins []string) ([]string, error)

	// ImportDrivers writes every row or none of them (TZ §18.4).
	ImportDrivers(
		ctx context.Context, companyID, roleID uuid.UUID, rows []DriverRow, invites []DriverInvitation, entries []audit.Entry,
	) ([]ImportedDriver, error)
	ImportUnits(ctx context.Context, companyID uuid.UUID, rows []UnitRow, entries []audit.Entry) (int, error)

	ExportDrivers(ctx context.Context, f ExportFilter) ([]db.ListDriversForExportRow, error)
	ExportUnits(ctx context.Context, f ExportFilter) ([]db.ListUnitsForExportRow, error)
}

// TxRunner is the subset of *db.Pool this repository needs.
type TxRunner interface {
	WithTx(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error
	WithConn(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error
}

// PgRepo is the pgx/sqlc implementation of Repo.
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

// ExistingUsernames implements Repo.
func (r *PgRepo) ExistingUsernames(ctx context.Context, companyID uuid.UUID, usernames []string) ([]string, error) {
	if len(usernames) == 0 {
		return nil, nil
	}
	var out []string
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.FindExistingUsernames(ctx, db.FindExistingUsernamesParams{
			CompanyID: companyID, Usernames: usernames,
		})
		return err
	})
	return out, err
}

// ExistingEmails implements Repo.
func (r *PgRepo) ExistingEmails(ctx context.Context, companyID uuid.UUID, emails []string) ([]string, error) {
	if len(emails) == 0 {
		return nil, nil
	}
	var out []string
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.FindExistingEmails(ctx, db.FindExistingEmailsParams{
			CompanyID: companyID, Emails: emails,
		})
		return err
	})
	return out, err
}

// ExistingUnitNumbers implements Repo.
func (r *PgRepo) ExistingUnitNumbers(ctx context.Context, companyID uuid.UUID, numbers []string) ([]string, error) {
	if len(numbers) == 0 {
		return nil, nil
	}
	var out []string
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.FindExistingUnitNumbers(ctx, db.FindExistingUnitNumbersParams{
			CompanyID: companyID, UnitNumbers: numbers,
		})
		return err
	})
	return out, err
}

// ExistingVINs implements Repo.
func (r *PgRepo) ExistingVINs(ctx context.Context, companyID uuid.UUID, vins []string) ([]string, error) {
	if len(vins) == 0 {
		return nil, nil
	}
	var out []string
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		out, err = q.FindExistingVINs(ctx, db.FindExistingVINsParams{
			CompanyID: companyID, Vins: vins,
		})
		return err
	})
	return out, err
}

// ImportDrivers implements Repo. Everything happens in one transaction, so a
// failure on the last row rolls the whole file back.
func (r *PgRepo) ImportDrivers(
	ctx context.Context, companyID, roleID uuid.UUID, rows []DriverRow, invites []DriverInvitation, entries []audit.Entry,
) ([]ImportedDriver, error) {
	created := make([]ImportedDriver, 0, len(rows))
	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		now := time.Now().UTC()
		created = created[:0]

		for i, row := range rows {
			user, err := q.CreateUser(ctx, db.CreateUserParams{
				CompanyID:    pgtype.UUID{Bytes: companyID, Valid: true},
				FirstName:    row.FirstName,
				LastName:     row.LastName,
				Email:        pgconv.NilIfEmpty(row.Email),
				Phone:        pgconv.NilIfEmpty(row.Phone),
				Username:     row.Username,
				PasswordHash: nil,
				RoleID:       roleID,
				Status:       "invited",
				InvitedAt:    pgtype.Timestamptz{Time: now, Valid: true},
			})
			if err != nil {
				return err
			}

			driver, err := q.CreateDriver(ctx, db.CreateDriverParams{
				CompanyID:     companyID,
				UserID:        user.ID,
				LicenseNoEnc:  row.LicenseNoEnc,
				LicenseRegion: pgconv.NilIfEmpty(row.LicenseRegion),
				HomeTerminal:  pgconv.NilIfEmpty(row.HomeTerminal),
				Status:        "invited",
			})
			if err != nil {
				return err
			}

			if i < len(invites) {
				inv := invites[i]
				if _, err := q.CreateInvitation(ctx, db.CreateInvitationParams{
					CompanyID: pgtype.UUID{Bytes: companyID, Valid: true},
					UserID:    user.ID,
					TokenHash: inv.TokenHash,
					Channel:   inv.Channel,
					Purpose:   inv.Purpose,
					ExpiresAt: inv.ExpiresAt,
				}); err != nil {
					return err
				}
				created = append(created, ImportedDriver{
					UserID: user.ID, DriverID: driver.ID,
					Channel: inv.Channel, Recipient: inv.Recipient, ExpiresAt: inv.ExpiresAt,
				})
				continue
			}
			created = append(created, ImportedDriver{UserID: user.ID, DriverID: driver.ID})
		}

		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	if err != nil {
		return nil, err
	}
	return created, nil
}

// ImportUnits implements Repo, all-or-nothing in a single transaction.
func (r *PgRepo) ImportUnits(ctx context.Context, companyID uuid.UUID, rows []UnitRow, entries []audit.Entry) (int, error) {
	count := 0
	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		count = 0
		for _, row := range rows {
			if _, err := q.CreateUnit(ctx, db.CreateUnitParams{
				CompanyID:    companyID,
				UnitNumber:   row.UnitNumber,
				Make:         pgconv.NilIfEmpty(row.Make),
				Model:        pgconv.NilIfEmpty(row.Model),
				Year:         row.Year,
				Vin:          pgconv.NilIfEmpty(row.VIN),
				LicensePlate: pgconv.NilIfEmpty(row.Plate),
				PlateRegion:  pgconv.NilIfEmpty(row.PlateRegion),
				FuelType:     pgconv.NilIfEmpty(row.FuelType),
				SleeperBerth: row.SleeperBerth,
				Status:       "active",
			}); err != nil {
				return err
			}
			count++
		}
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	if err != nil {
		return 0, err
	}
	return count, nil
}

// ExportDrivers implements Repo.
func (r *PgRepo) ExportDrivers(ctx context.Context, f ExportFilter) ([]db.ListDriversForExportRow, error) {
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

// ExportUnits implements Repo.
func (r *PgRepo) ExportUnits(ctx context.Context, f ExportFilter) ([]db.ListUnitsForExportRow, error) {
	var rows []db.ListUnitsForExportRow
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		var err error
		rows, err = q.ListUnitsForExport(ctx, db.ListUnitsForExportParams{
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
