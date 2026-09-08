package drivers

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
)

// CoDrivers implements Repo.
func (r *PgRepo) CoDrivers(ctx context.Context, companyID, driverID uuid.UUID) ([]db.ListCoDriverDetailsRow, error) {
	var rows []db.ListCoDriverDetailsRow
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		var err error
		rows, err = q.ListCoDriverDetails(ctx, db.ListCoDriverDetailsParams{
			DriverID: driverID, CompanyID: companyID,
		})
		return err
	})
	return rows, err
}

// LinkCoDriver implements Repo.
func (r *PgRepo) LinkCoDriver(ctx context.Context, companyID, a, b uuid.UUID, entries []audit.Entry) error {
	return r.write(ctx, companyID, func(q *db.Queries, tx pgx.Tx) error {
		if err := linkPair(ctx, q, companyID, a, b); err != nil {
			return err
		}
		return r.recordTx(ctx, tx, a, entries)
	})
}

// UnlinkCoDriver implements Repo.
func (r *PgRepo) UnlinkCoDriver(ctx context.Context, companyID, a, b uuid.UUID, entries []audit.Entry) error {
	return r.write(ctx, companyID, func(q *db.Queries, tx pgx.Tx) error {
		if err := q.DeleteDriverPair(ctx, db.DeleteDriverPairParams{
			CompanyID: companyID, Column2: a, Column3: b,
		}); err != nil {
			return err
		}
		return r.recordTx(ctx, tx, a, entries)
	})
}

// linkPair inserts the canonical (a<b) pair, restoring a previously unlinked
// row instead of violating the partial unique index.
func linkPair(ctx context.Context, q *db.Queries, companyID, a, b uuid.UUID) error {
	existing, err := q.GetDriverPairAny(ctx, db.GetDriverPairAnyParams{
		CompanyID: companyID, DriverA: a, DriverB: b,
	})
	switch {
	case err == nil && !existing.DeletedAt.Valid:
		return nil
	case err == nil:
		_, err = q.RestoreDriverPair(ctx, db.RestoreDriverPairParams{CompanyID: companyID, ID: existing.ID})
		return err
	case db.IsNoRows(err):
		_, err = q.CreateDriverPair(ctx, db.CreateDriverPairParams{
			CompanyID: companyID, Column2: a, Column3: b,
		})
		return err
	default:
		return err
	}
}
