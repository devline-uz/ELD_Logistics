package drivers

import (
	"context"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
)

// Create implements Repo.
func (r *PgRepo) Create(ctx context.Context, in CreateInput, entries []audit.Entry) (db.GetDriverDetailRow, error) {
	var out db.GetDriverDetailRow
	err := r.write(ctx, in.CompanyID, func(q *db.Queries, tx pgx.Tx) error {
		user, err := q.CreateUser(ctx, db.CreateUserParams{
			CompanyID: pgconv.UUID(in.CompanyID),
			BranchID:  pgconv.UUIDPtr(in.BranchID),
			FirstName: in.FirstName,
			LastName:  in.LastName,
			Email:     in.Email,
			Phone:     in.Phone,
			Username:  in.Username,
			// Q18.1: no password is ever set here; the invitation does it.
			PasswordHash: nil,
			RoleID:       in.RoleID,
			Status:       "invited",
			InvitedAt:    pgconv.Time(in.InvitedAt),
		})
		if err != nil {
			return err
		}

		driver, err := q.CreateDriver(ctx, db.CreateDriverParams{
			CompanyID:      in.CompanyID,
			UserID:         user.ID,
			BranchID:       pgconv.UUIDPtr(in.BranchID),
			LicenseNoEnc:   in.LicenseNoEnc,
			LicenseRegion:  in.LicenseRegion,
			HomeTerminal:   in.HomeTerminal,
			City:           in.City,
			State:          in.State,
			Zip:            in.Zip,
			Address1:       in.Address1,
			Address2:       in.Address2,
			Notes:          in.Notes,
			FleetManagerID: pgconv.UUIDPtr(in.FleetManagerID),
			DefaultUnitID:  pgconv.UUIDPtr(in.DefaultUnitID),
			Status:         "invited",
			ActivatedOn:    pgtype.Timestamptz{},
		})
		if err != nil {
			return err
		}

		if in.CoDriverID != nil {
			if err := linkPair(ctx, q, in.CompanyID, driver.ID, *in.CoDriverID); err != nil {
				return err
			}
		}

		if in.Invitation != nil {
			if _, err := q.CreateInvitation(ctx, db.CreateInvitationParams{
				CompanyID: pgconv.UUID(in.CompanyID),
				UserID:    user.ID,
				TokenHash: in.Invitation.TokenHash,
				Channel:   in.Invitation.Channel,
				Purpose:   in.Invitation.Purpose,
				ExpiresAt: in.Invitation.ExpiresAt,
			}); err != nil {
				return err
			}
		}

		if err := r.recordTx(ctx, tx, driver.ID, entries); err != nil {
			return err
		}

		out, err = q.GetDriverDetail(ctx, db.GetDriverDetailParams{CompanyID: in.CompanyID, ID: driver.ID})
		return err
	})
	return out, err
}

// Update implements Repo.
func (r *PgRepo) Update(ctx context.Context, in UpdateInput, entries []audit.Entry) (db.GetDriverDetailRow, error) {
	var out db.GetDriverDetailRow
	err := r.write(ctx, in.CompanyID, func(q *db.Queries, tx pgx.Tx) error {
		if in.FirstName != nil || in.LastName != nil || in.Email != nil || in.Phone != nil {
			if _, err := q.UpdateUser(ctx, db.UpdateUserParams{
				CompanyID: in.CompanyID,
				ID:        in.UserID,
				FirstName: in.FirstName,
				LastName:  in.LastName,
				Email:     in.Email,
				Phone:     in.Phone,
			}); err != nil {
				return err
			}
		}

		if _, err := q.UpdateDriverPartial(ctx, db.UpdateDriverPartialParams{
			CompanyID:      in.CompanyID,
			ID:             in.DriverID,
			BranchID:       pgconv.UUIDPtr(in.BranchID),
			LicenseNoEnc:   in.LicenseNoEnc,
			LicenseRegion:  in.LicenseRegion,
			HomeTerminal:   in.HomeTerminal,
			City:           in.City,
			State:          in.State,
			Zip:            in.Zip,
			Address1:       in.Address1,
			Address2:       in.Address2,
			Notes:          in.Notes,
			FleetManagerID: pgconv.UUIDPtr(in.FleetManagerID),
			DefaultUnitID:  pgconv.UUIDPtr(in.DefaultUnitID),
		}); err != nil {
			return err
		}

		if err := r.recordTx(ctx, tx, in.DriverID, entries); err != nil {
			return err
		}

		var err error
		out, err = q.GetDriverDetail(ctx, db.GetDriverDetailParams{CompanyID: in.CompanyID, ID: in.DriverID})
		return err
	})
	return out, err
}

// SetStatus implements Repo. The users row follows the driver row so an
// inactive driver cannot authenticate at all.
func (r *PgRepo) SetStatus(
	ctx context.Context, companyID, driverID, userID uuid.UUID, status string, entries []audit.Entry,
) (db.GetDriverDetailRow, error) {
	var out db.GetDriverDetailRow
	err := r.write(ctx, companyID, func(q *db.Queries, tx pgx.Tx) error {
		if _, err := q.SetDriverStatus(ctx, db.SetDriverStatusParams{
			CompanyID: companyID, ID: driverID, Status: status,
		}); err != nil {
			return err
		}
		userStatus := status
		if status == "active" {
			// A driver that never accepted the invitation stays "invited".
			user, err := q.GetUser(ctx, db.GetUserParams{CompanyID: pgconv.UUID(companyID), ID: userID})
			if err != nil {
				return err
			}
			if user.PasswordHash == nil {
				userStatus = "invited"
			}
		}
		if _, err := q.SetUserStatus(ctx, db.SetUserStatusParams{
			CompanyID: companyID, ID: userID, Status: userStatus,
		}); err != nil {
			return err
		}
		if err := r.recordTx(ctx, tx, driverID, entries); err != nil {
			return err
		}
		var err error
		out, err = q.GetDriverDetail(ctx, db.GetDriverDetailParams{CompanyID: companyID, ID: driverID})
		return err
	})
	return out, err
}

// SoftDelete implements Repo.
func (r *PgRepo) SoftDelete(ctx context.Context, companyID, driverID, userID uuid.UUID, entries []audit.Entry) error {
	return r.write(ctx, companyID, func(q *db.Queries, tx pgx.Tx) error {
		if err := q.SoftDeleteDriver(ctx, db.SoftDeleteDriverParams{CompanyID: companyID, ID: driverID}); err != nil {
			return err
		}
		if err := q.SoftDeleteUser(ctx, db.SoftDeleteUserParams{CompanyID: pgconv.UUID(companyID), ID: userID}); err != nil {
			return err
		}
		return r.recordTx(ctx, tx, driverID, entries)
	})
}
