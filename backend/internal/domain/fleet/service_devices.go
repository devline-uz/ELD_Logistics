package fleet

import (
	"context"
	"net/http"
	"strings"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/fleet/dto"
)

// ListDevices returns one page of ELD devices.
func (s *Service) ListDevices(ctx context.Context, f DeviceFilter) ([]dto.EldDevice, int64, error) {
	rows, total, err := s.repo.ListDevices(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "eld device")
	}
	out := make([]dto.EldDevice, 0, len(rows))
	for _, r := range rows {
		out = append(out, deviceFromList(r))
	}
	return out, total, nil
}

// GetDevice returns one ELD device; a cross-tenant id is a 404.
func (s *Service) GetDevice(ctx context.Context, id uuid.UUID) (*dto.EldDevice, error) {
	row, err := s.repo.GetDevice(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "eld device")
	}
	d := deviceFromRow(row)
	return &d, nil
}

// CreateDevice registers an ELD. The serial is unique per company among rows
// that are not soft deleted.
func (s *Service) CreateDevice(ctx context.Context, in dto.EldDeviceCreate) (*dto.EldDevice, error) {
	unitID, err := s.resolveWirableUnit(ctx, in.UnitID)
	if err != nil {
		return nil, err
	}

	status := in.Status
	if status == "" {
		status = dto.StatusActive
	}
	arg := db.CreateEldDeviceParams{
		UnitID:         pgconv.UUIDPtr(unitID),
		Vendor:         strings.TrimSpace(in.Vendor),
		Model:          pgconv.NilIfEmpty(in.Model),
		Serial:         strings.TrimSpace(in.Serial),
		Firmware:       pgconv.NilIfEmpty(in.Firmware),
		ConnectionType: pgconv.NilIfEmpty(in.ConnectionType),
		SimPresent:     in.SimPresent,
		Status:         status,
		Notes:          pgconv.NilIfEmpty(in.Notes),
	}

	row, err := s.repo.CreateDevice(ctx, arg, func(d db.EldDevice) []audit.Entry {
		return audit.Changes(tableDevices, d.ID, audit.ActionCreate, nil, map[string]any{
			"vendor":          d.Vendor,
			"serial":          d.Serial,
			"model":           pgconv.Deref(d.Model),
			"connection_type": pgconv.Deref(d.ConnectionType),
			"status":          d.Status,
			"unit_id":         uuidText(d.UnitID),
		})
	})
	if err != nil {
		return nil, mapDeviceWrite(err)
	}
	d := deviceFromRow(row)
	return &d, nil
}

// UpdateDevice applies a partial change.
func (s *Service) UpdateDevice(ctx context.Context, id uuid.UUID, in dto.EldDeviceUpdate) (*dto.EldDevice, error) {
	if _, err := s.repo.GetDevice(ctx, id); err != nil {
		return nil, db.MapError(err, "eld device")
	}

	arg := db.FleetUpdateEldDeviceParams{
		ID:             id,
		Vendor:         trimPtr(in.Vendor),
		Model:          in.Model,
		Serial:         trimPtr(in.Serial),
		Firmware:       in.Firmware,
		ConnectionType: in.ConnectionType,
		SimPresent:     in.SimPresent,
		Status:         in.Status,
		Notes:          in.Notes,
	}
	row, err := s.repo.UpdateDevice(ctx, arg, func(before, after db.EldDevice) []audit.Entry {
		return audit.Changes(tableDevices, after.ID, audit.ActionUpdate,
			deviceFields(before), deviceFields(after))
	})
	if err != nil {
		return nil, mapDeviceWrite(err)
	}
	d := deviceFromRow(row)
	return &d, nil
}

// DeleteDevice soft deletes an ELD and closes its open unit assignment.
func (s *Service) DeleteDevice(ctx context.Context, id uuid.UUID) error {
	if _, err := s.repo.GetDevice(ctx, id); err != nil {
		return db.MapError(err, "eld device")
	}
	err := s.repo.DeleteDevice(ctx, id, func(d db.EldDevice) []audit.Entry {
		return audit.Changes(tableDevices, d.ID, audit.ActionDelete,
			map[string]any{"deleted_at": nil}, map[string]any{"deleted_at": "now"})
	})
	return db.MapError(err, "eld device")
}

// AssignDeviceToUnit wires a device to a unit, or detaches it when unit_id is
// null. Q3.1 — an inactive unit takes no ELD, and a unit carries at most one
// active device at a time.
func (s *Service) AssignDeviceToUnit(ctx context.Context, deviceID uuid.UUID, in dto.EldDeviceAssignUnit) (*dto.EldDevice, error) {
	if _, err := s.repo.GetDevice(ctx, deviceID); err != nil {
		return nil, db.MapError(err, "eld device")
	}

	unitID, err := s.resolveWirableUnit(ctx, in.UnitID)
	if err != nil {
		return nil, err
	}
	if unitID != nil {
		if active, err := s.repo.ActiveDeviceForUnit(ctx, *unitID); err == nil && active.ID != deviceID {
			return nil, apierr.New(apierr.CodeAlreadyAssigned, http.StatusConflict,
				"the unit already has an active ELD device")
		} else if err != nil && !db.IsNoRows(err) {
			return nil, db.MapError(err, "unit")
		}
	}

	row, err := s.repo.AssignDevice(ctx, AssignDeviceInput{DeviceID: deviceID, UnitID: unitID},
		func(before db.EldDevice) []audit.Entry {
			return audit.Changes(tableDevices, before.ID, audit.ActionAssign,
				map[string]any{"unit_id": uuidText(before.UnitID)},
				map[string]any{"unit_id": uuidTextPtr(unitID)})
		})
	if err != nil {
		return nil, mapDeviceWrite(err)
	}
	d := deviceFromRow(row)
	return &d, nil
}

// resolveWirableUnit validates the target unit of an ELD wiring request.
func (s *Service) resolveWirableUnit(ctx context.Context, raw *string) (*uuid.UUID, error) {
	if raw == nil || strings.TrimSpace(*raw) == "" {
		return nil, nil
	}
	id, err := parseUUID("unit_id", *raw)
	if err != nil {
		return nil, err
	}
	unit, err := s.repo.GetUnit(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	if err := s.assertScope(ctx, unit.BranchID); err != nil {
		return nil, err
	}
	// Q3.1: an inactive unit must not be connected to an ELD.
	if unit.Status != dto.StatusActive {
		return nil, apierr.New(apierr.CodeInvalidState, http.StatusConflict,
			"an inactive unit cannot be connected to an ELD device")
	}
	return &id, nil
}

func deviceFields(d db.EldDevice) map[string]any {
	return map[string]any{
		"vendor":          d.Vendor,
		"model":           pgconv.Deref(d.Model),
		"serial":          d.Serial,
		"firmware":        pgconv.Deref(d.Firmware),
		"connection_type": pgconv.Deref(d.ConnectionType),
		"sim_present":     d.SimPresent,
		"status":          d.Status,
		"notes":           pgconv.Deref(d.Notes),
		"unit_id":         uuidText(d.UnitID),
	}
}

func mapDeviceWrite(err error) error {
	if db.IsUniqueViolation(err) {
		return apierr.Wrap(err, apierr.CodeUniqueViolation, http.StatusConflict,
			"a device with this serial already exists, or the unit already has an active device")
	}
	return db.MapError(err, "eld device")
}

func uuidTextPtr(id *uuid.UUID) any {
	if id == nil {
		return nil
	}
	return id.String()
}

// ------------------------------------------- trailers and shipping documents

// ListTrailers returns one page of trailers.
func (s *Service) ListTrailers(ctx context.Context, f CatalogFilter) ([]dto.Trailer, int64, error) {
	rows, total, err := s.repo.ListTrailers(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "trailer")
	}
	out := make([]dto.Trailer, 0, len(rows))
	for _, r := range rows {
		out = append(out, trailerFrom(r))
	}
	return out, total, nil
}

// GetTrailer returns one trailer.
func (s *Service) GetTrailer(ctx context.Context, id uuid.UUID) (*dto.Trailer, error) {
	row, err := s.repo.GetTrailer(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "trailer")
	}
	t := trailerFrom(row)
	return &t, nil
}

// CreateTrailer registers a trailer; the number is unique per company.
func (s *Service) CreateTrailer(ctx context.Context, in dto.CatalogCreate) (*dto.Trailer, error) {
	row, err := s.repo.CreateTrailer(ctx, db.CreateTrailerParams{
		Number: strings.TrimSpace(in.Number), Notes: pgconv.NilIfEmpty(in.Notes),
	}, func(t db.Trailer) []audit.Entry {
		return audit.Changes(tableTrailers, t.ID, audit.ActionCreate, nil,
			map[string]any{"number": t.Number, "notes": pgconv.Deref(t.Notes)})
	})
	if err != nil {
		return nil, mapCatalogWrite(err, "trailer")
	}
	t := trailerFrom(row)
	return &t, nil
}

// UpdateTrailer applies a partial change.
func (s *Service) UpdateTrailer(ctx context.Context, id uuid.UUID, in dto.CatalogUpdate) (*dto.Trailer, error) {
	if _, err := s.repo.GetTrailer(ctx, id); err != nil {
		return nil, db.MapError(err, "trailer")
	}
	row, err := s.repo.UpdateTrailer(ctx, db.FleetUpdateTrailerParams{
		ID: id, Number: trimPtr(in.Number), Notes: in.Notes,
	}, func(before, after db.Trailer) []audit.Entry {
		return audit.Changes(tableTrailers, after.ID, audit.ActionUpdate,
			map[string]any{"number": before.Number, "notes": pgconv.Deref(before.Notes)},
			map[string]any{"number": after.Number, "notes": pgconv.Deref(after.Notes)})
	})
	if err != nil {
		return nil, mapCatalogWrite(err, "trailer")
	}
	t := trailerFrom(row)
	return &t, nil
}

// DeleteTrailer soft deletes a trailer.
func (s *Service) DeleteTrailer(ctx context.Context, id uuid.UUID) error {
	if _, err := s.repo.GetTrailer(ctx, id); err != nil {
		return db.MapError(err, "trailer")
	}
	err := s.repo.DeleteTrailer(ctx, id, func(t db.Trailer) []audit.Entry {
		return audit.Changes(tableTrailers, t.ID, audit.ActionDelete,
			map[string]any{"deleted_at": nil}, map[string]any{"deleted_at": "now"})
	})
	return db.MapError(err, "trailer")
}

// ListDocs returns one page of shipping documents.
func (s *Service) ListDocs(ctx context.Context, f CatalogFilter) ([]dto.ShippingDocument, int64, error) {
	rows, total, err := s.repo.ListDocs(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "shipping document")
	}
	out := make([]dto.ShippingDocument, 0, len(rows))
	for _, r := range rows {
		out = append(out, docFrom(r))
	}
	return out, total, nil
}

// GetDoc returns one shipping document.
func (s *Service) GetDoc(ctx context.Context, id uuid.UUID) (*dto.ShippingDocument, error) {
	row, err := s.repo.GetDoc(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "shipping document")
	}
	d := docFrom(row)
	return &d, nil
}

// CreateDoc registers a shipping document; the number is unique per company.
func (s *Service) CreateDoc(ctx context.Context, in dto.CatalogCreate) (*dto.ShippingDocument, error) {
	row, err := s.repo.CreateDoc(ctx, db.CreateShippingDocumentParams{
		Number: strings.TrimSpace(in.Number), Notes: pgconv.NilIfEmpty(in.Notes),
	}, func(d db.ShippingDocument) []audit.Entry {
		return audit.Changes(tableDocs, d.ID, audit.ActionCreate, nil,
			map[string]any{"number": d.Number, "notes": pgconv.Deref(d.Notes)})
	})
	if err != nil {
		return nil, mapCatalogWrite(err, "shipping document")
	}
	d := docFrom(row)
	return &d, nil
}

// UpdateDoc applies a partial change.
func (s *Service) UpdateDoc(ctx context.Context, id uuid.UUID, in dto.CatalogUpdate) (*dto.ShippingDocument, error) {
	if _, err := s.repo.GetDoc(ctx, id); err != nil {
		return nil, db.MapError(err, "shipping document")
	}
	row, err := s.repo.UpdateDoc(ctx, db.FleetUpdateShippingDocumentParams{
		ID: id, Number: trimPtr(in.Number), Notes: in.Notes,
	}, func(before, after db.ShippingDocument) []audit.Entry {
		return audit.Changes(tableDocs, after.ID, audit.ActionUpdate,
			map[string]any{"number": before.Number, "notes": pgconv.Deref(before.Notes)},
			map[string]any{"number": after.Number, "notes": pgconv.Deref(after.Notes)})
	})
	if err != nil {
		return nil, mapCatalogWrite(err, "shipping document")
	}
	d := docFrom(row)
	return &d, nil
}

// DeleteDoc soft deletes a shipping document.
func (s *Service) DeleteDoc(ctx context.Context, id uuid.UUID) error {
	if _, err := s.repo.GetDoc(ctx, id); err != nil {
		return db.MapError(err, "shipping document")
	}
	err := s.repo.DeleteDoc(ctx, id, func(d db.ShippingDocument) []audit.Entry {
		return audit.Changes(tableDocs, d.ID, audit.ActionDelete,
			map[string]any{"deleted_at": nil}, map[string]any{"deleted_at": "now"})
	})
	return db.MapError(err, "shipping document")
}

func mapCatalogWrite(err error, resource string) error {
	if db.IsUniqueViolation(err) {
		return apierr.Wrap(err, apierr.CodeUniqueViolation, http.StatusConflict,
			"a "+resource+" with this number already exists")
	}
	return db.MapError(err, resource)
}
