package fleet

import (
	"context"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/tenant"
)

// ---------------------------------------------------------------- eld devices

// ListDevices implements Repo.
func (r *PgRepo) ListDevices(ctx context.Context, f DeviceFilter) ([]db.FleetListEldDevicesRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.FleetListEldDevicesRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.FleetListEldDevices(ctx, db.FleetListEldDevicesParams{
			CompanyID:      companyID,
			Search:         f.Search,
			Status:         f.Status,
			UnitID:         pgconv.UUIDPtr(f.UnitID),
			ConnectionType: f.ConnectionType,
			Sort:           f.Sort,
			SortOrder:      f.Order,
			Limit:          f.Limit,
			Offset:         f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.FleetCountEldDevices(ctx, db.FleetCountEldDevicesParams{
			CompanyID:      companyID,
			Search:         f.Search,
			Status:         f.Status,
			UnitID:         pgconv.UUIDPtr(f.UnitID),
			ConnectionType: f.ConnectionType,
		})
		return err
	})
	return rows, total, err
}

// GetDevice implements Repo.
func (r *PgRepo) GetDevice(ctx context.Context, id uuid.UUID) (db.FleetGetEldDeviceRow, error) {
	var out db.FleetGetEldDeviceRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.FleetGetEldDevice(ctx, db.FleetGetEldDeviceParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// CreateDevice implements Repo.
func (r *PgRepo) CreateDevice(ctx context.Context, arg db.CreateEldDeviceParams,
	mk func(db.EldDevice) []audit.Entry) (db.FleetGetEldDeviceRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.FleetGetEldDeviceRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		dev, err := q.CreateEldDevice(ctx, arg)
		if err != nil {
			return err
		}
		if arg.UnitID.Valid {
			if _, err := q.AssignEldDeviceToUnit(ctx, db.AssignEldDeviceToUnitParams{
				CompanyID: companyID, EldDeviceID: dev.ID, UnitID: arg.UnitID.Bytes,
			}); err != nil {
				return err
			}
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(dev)...); err != nil {
			return err
		}
		out, err = q.FleetGetEldDevice(ctx, db.FleetGetEldDeviceParams{CompanyID: companyID, ID: dev.ID})
		return err
	})
	return out, err
}

// UpdateDevice implements Repo.
func (r *PgRepo) UpdateDevice(ctx context.Context, arg db.FleetUpdateEldDeviceParams,
	mk func(before, after db.EldDevice) []audit.Entry) (db.FleetGetEldDeviceRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.FleetGetEldDeviceRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetEldDevice(ctx, db.GetEldDeviceParams{CompanyID: companyID, ID: arg.ID})
		if err != nil {
			return err
		}
		after, err := q.FleetUpdateEldDevice(ctx, arg)
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(before, after)...); err != nil {
			return err
		}
		out, err = q.FleetGetEldDevice(ctx, db.FleetGetEldDeviceParams{CompanyID: companyID, ID: arg.ID})
		return err
	})
	return out, err
}

// DeleteDevice implements Repo (soft delete; the open assignment is closed).
func (r *PgRepo) DeleteDevice(ctx context.Context, id uuid.UUID, mk func(db.EldDevice) []audit.Entry) error {
	companyID := tenant.CompanyID(ctx)
	return r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetEldDevice(ctx, db.GetEldDeviceParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		if err := q.UnassignEldDevice(ctx, db.UnassignEldDeviceParams{CompanyID: companyID, ID: id}); err != nil {
			return err
		}
		if err := q.SoftDeleteEldDevice(ctx, db.SoftDeleteEldDeviceParams{CompanyID: companyID, ID: id}); err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(before)...)
	})
}

// AssignDevice implements Repo. A nil UnitID detaches the device.
func (r *PgRepo) AssignDevice(ctx context.Context, in AssignDeviceInput,
	mk func(before db.EldDevice) []audit.Entry) (db.FleetGetEldDeviceRow, error) {
	companyID := tenant.CompanyID(ctx)

	var out db.FleetGetEldDeviceRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetEldDevice(ctx, db.GetEldDeviceParams{CompanyID: companyID, ID: in.DeviceID})
		if err != nil {
			return err
		}
		if in.UnitID == nil {
			err = q.UnassignEldDevice(ctx, db.UnassignEldDeviceParams{CompanyID: companyID, ID: in.DeviceID})
		} else {
			_, err = q.AssignEldDeviceToUnit(ctx, db.AssignEldDeviceToUnitParams{
				CompanyID: companyID, EldDeviceID: in.DeviceID, UnitID: *in.UnitID,
			})
		}
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(before)...); err != nil {
			return err
		}
		out, err = q.FleetGetEldDevice(ctx, db.FleetGetEldDeviceParams{CompanyID: companyID, ID: in.DeviceID})
		return err
	})
	return out, err
}

// ActiveDeviceForUnit implements Repo.
func (r *PgRepo) ActiveDeviceForUnit(ctx context.Context, unitID uuid.UUID) (db.FleetActiveDeviceForUnitRow, error) {
	var out db.FleetActiveDeviceForUnitRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.FleetActiveDeviceForUnit(ctx, db.FleetActiveDeviceForUnitParams{
			CompanyID: tenant.CompanyID(ctx), UnitID: unitID,
		})
		return err
	})
	return out, err
}

// ------------------------------------------- trailers and shipping documents

// ListTrailers implements Repo.
func (r *PgRepo) ListTrailers(ctx context.Context, f CatalogFilter) ([]db.Trailer, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.Trailer
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListTrailers(ctx, db.ListTrailersParams{
			CompanyID: companyID, Column2: f.Search, Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountTrailers(ctx, db.CountTrailersParams{CompanyID: companyID, Column2: f.Search})
		return err
	})
	return rows, total, err
}

// GetTrailer implements Repo.
func (r *PgRepo) GetTrailer(ctx context.Context, id uuid.UUID) (db.Trailer, error) {
	var out db.Trailer
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetTrailer(ctx, db.GetTrailerParams{CompanyID: tenant.CompanyID(ctx), ID: id})
		return err
	})
	return out, err
}

// CreateTrailer implements Repo.
func (r *PgRepo) CreateTrailer(ctx context.Context, arg db.CreateTrailerParams,
	mk func(db.Trailer) []audit.Entry) (db.Trailer, error) {
	arg.CompanyID = tenant.CompanyID(ctx)
	var out db.Trailer
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		var err error
		out, err = q.CreateTrailer(ctx, arg)
		if err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(out)...)
	})
	return out, err
}

// UpdateTrailer implements Repo.
func (r *PgRepo) UpdateTrailer(ctx context.Context, arg db.FleetUpdateTrailerParams,
	mk func(before, after db.Trailer) []audit.Entry) (db.Trailer, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID
	var out db.Trailer
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetTrailer(ctx, db.GetTrailerParams{CompanyID: companyID, ID: arg.ID})
		if err != nil {
			return err
		}
		out, err = q.FleetUpdateTrailer(ctx, arg)
		if err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(before, out)...)
	})
	return out, err
}

// DeleteTrailer implements Repo (soft delete).
func (r *PgRepo) DeleteTrailer(ctx context.Context, id uuid.UUID, mk func(db.Trailer) []audit.Entry) error {
	companyID := tenant.CompanyID(ctx)
	return r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetTrailer(ctx, db.GetTrailerParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		if err := q.SoftDeleteTrailer(ctx, db.SoftDeleteTrailerParams{CompanyID: companyID, ID: id}); err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(before)...)
	})
}

// ListDocs implements Repo.
func (r *PgRepo) ListDocs(ctx context.Context, f CatalogFilter) ([]db.ShippingDocument, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ShippingDocument
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListShippingDocuments(ctx, db.ListShippingDocumentsParams{
			CompanyID: companyID, Column2: f.Search, Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountShippingDocuments(ctx, db.CountShippingDocumentsParams{
			CompanyID: companyID, Column2: f.Search,
		})
		return err
	})
	return rows, total, err
}

// GetDoc implements Repo.
func (r *PgRepo) GetDoc(ctx context.Context, id uuid.UUID) (db.ShippingDocument, error) {
	var out db.ShippingDocument
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetShippingDocument(ctx, db.GetShippingDocumentParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// CreateDoc implements Repo.
func (r *PgRepo) CreateDoc(ctx context.Context, arg db.CreateShippingDocumentParams,
	mk func(db.ShippingDocument) []audit.Entry) (db.ShippingDocument, error) {
	arg.CompanyID = tenant.CompanyID(ctx)
	var out db.ShippingDocument
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		var err error
		out, err = q.CreateShippingDocument(ctx, arg)
		if err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(out)...)
	})
	return out, err
}

// UpdateDoc implements Repo.
func (r *PgRepo) UpdateDoc(ctx context.Context, arg db.FleetUpdateShippingDocumentParams,
	mk func(before, after db.ShippingDocument) []audit.Entry) (db.ShippingDocument, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID
	var out db.ShippingDocument
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetShippingDocument(ctx, db.GetShippingDocumentParams{CompanyID: companyID, ID: arg.ID})
		if err != nil {
			return err
		}
		out, err = q.FleetUpdateShippingDocument(ctx, arg)
		if err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(before, out)...)
	})
	return out, err
}

// DeleteDoc implements Repo (soft delete).
func (r *PgRepo) DeleteDoc(ctx context.Context, id uuid.UUID, mk func(db.ShippingDocument) []audit.Entry) error {
	companyID := tenant.CompanyID(ctx)
	return r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.GetShippingDocument(ctx, db.GetShippingDocumentParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		if err := q.SoftDeleteShippingDocument(ctx, db.SoftDeleteShippingDocumentParams{
			CompanyID: companyID, ID: id,
		}); err != nil {
			return err
		}
		return r.recorder.RecordTx(ctx, tx, mk(before)...)
	})
}
