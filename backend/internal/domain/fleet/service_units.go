package fleet

import (
	"context"
	"net/http"
	"sort"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/fleet/dto"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Audited table names.
const (
	tableUnits       = "units"
	tableDevices     = "eld_devices"
	tableAssignments = "unit_driver_assignments"
	tableTrailers    = "trailers"
	tableDocs        = "shipping_documents"
)

// Service holds the fleet business rules. It never touches pgx directly.
type Service struct {
	repo Repo
	now  func() time.Time
}

// NewService builds the fleet service. now is injectable so the ELD online
// window (TZ §10.1) is testable.
func NewService(repo Repo, now func() time.Time) *Service {
	if now == nil {
		now = func() time.Time { return time.Now().UTC() }
	}
	return &Service{repo: repo, now: now}
}

// ListUnits returns one page of units honouring the caller scope: a branch
// scoped principal only ever sees its own branch.
func (s *Service) ListUnits(ctx context.Context, f UnitFilter) ([]dto.Unit, int64, error) {
	if sc, ok := mw.ScopeFrom(ctx); ok && sc.Scope == tenant.ScopeBranch && sc.BranchID != nil {
		f.BranchID = sc.BranchID
	}
	rows, total, err := s.repo.ListUnits(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "unit")
	}
	out := make([]dto.Unit, 0, len(rows))
	for _, r := range rows {
		out = append(out, unitFromList(r))
	}
	return out, total, nil
}

// GetUnit returns one unit. A cross-tenant or out of scope id is a 404.
func (s *Service) GetUnit(ctx context.Context, id uuid.UUID) (*dto.Unit, error) {
	row, err := s.repo.GetUnit(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	if err := s.assertScope(ctx, row.BranchID); err != nil {
		return nil, err
	}
	u := unitFromRow(row)
	return &u, nil
}

// CreateUnit registers a vehicle (Q18.1). unit_number and vin are unique per
// company among the rows that are not soft deleted.
func (s *Service) CreateUnit(ctx context.Context, in dto.UnitCreate) (*dto.Unit, error) {
	branchID, err := s.resolveBranch(ctx, in.BranchID)
	if err != nil {
		return nil, err
	}
	if err := s.assertScope(ctx, pgconv.UUIDPtr(branchID)); err != nil {
		return nil, err
	}

	var deviceID *uuid.UUID
	if in.EldDeviceID != nil {
		id, err := parseUUID("eld_device_id", *in.EldDeviceID)
		if err != nil {
			return nil, err
		}
		if _, err := s.repo.GetDevice(ctx, id); err != nil {
			return nil, db.MapError(err, "eld device")
		}
		deviceID = &id
	}

	vin := strings.ToUpper(strings.TrimSpace(in.VIN))
	arg := db.CreateUnitParams{
		BranchID:     pgconv.UUIDPtr(branchID),
		UnitNumber:   strings.TrimSpace(in.UnitNumber),
		Make:         pgconv.NilIfEmpty(in.Make),
		Model:        pgconv.NilIfEmpty(in.Model),
		Year:         in.Year,
		Vin:          pgconv.NilIfEmpty(vin),
		LicensePlate: pgconv.NilIfEmpty(in.LicensePlate),
		PlateRegion:  pgconv.NilIfEmpty(in.PlateRegion),
		FuelType:     pgconv.NilIfEmpty(in.FuelType),
		SleeperBerth: in.SleeperBerth,
		GvwrClass:    pgconv.NilIfEmpty(in.GVWRClass),
		Status:       dto.StatusActive,
		Notes:        pgconv.NilIfEmpty(in.Notes),
		ActivatedOn:  pgconv.Time(s.now()),
	}

	row, err := s.repo.CreateUnit(ctx, arg, deviceID, func(u db.Unit) []audit.Entry {
		return audit.Changes(tableUnits, u.ID, audit.ActionCreate, nil, map[string]any{
			"unit_number":   u.UnitNumber,
			"make":          pgconv.Deref(u.Make),
			"model":         pgconv.Deref(u.Model),
			"license_plate": pgconv.Deref(u.LicensePlate),
			"fuel_type":     pgconv.Deref(u.FuelType),
			"vin":           pgconv.Deref(u.Vin),
			"status":        u.Status,
		})
	})
	if err != nil {
		return nil, mapUnitWrite(err)
	}
	u := unitFromRow(row)
	return &u, nil
}

// UpdateUnit applies a partial change (PATCH semantics).
func (s *Service) UpdateUnit(ctx context.Context, id uuid.UUID, in dto.UnitUpdate) (*dto.Unit, error) {
	current, err := s.repo.GetUnit(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	if err := s.assertScope(ctx, current.BranchID); err != nil {
		return nil, err
	}

	branchID, err := s.resolveBranch(ctx, in.BranchID)
	if err != nil {
		return nil, err
	}

	arg := db.FleetUpdateUnitParams{
		ID:           id,
		BranchID:     pgconv.UUIDPtr(branchID),
		UnitNumber:   trimPtr(in.UnitNumber),
		Make:         in.Make,
		Model:        in.Model,
		Year:         in.Year,
		Vin:          upperPtr(in.VIN),
		LicensePlate: in.LicensePlate,
		PlateRegion:  in.PlateRegion,
		FuelType:     in.FuelType,
		SleeperBerth: in.SleeperBerth,
		GvwrClass:    in.GVWRClass,
		Notes:        in.Notes,
		OutOfService: in.OutOfService,
	}

	row, err := s.repo.UpdateUnit(ctx, arg, func(before, after db.Unit) []audit.Entry {
		return audit.Changes(tableUnits, after.ID, audit.ActionUpdate,
			unitFields(before), unitFields(after))
	})
	if err != nil {
		return nil, mapUnitWrite(err)
	}
	u := unitFromRow(row)
	return &u, nil
}

// SetUnitStatus flips a unit between active and inactive (TZ §2, Q3.1).
func (s *Service) SetUnitStatus(ctx context.Context, id uuid.UUID, status string) (*dto.Unit, error) {
	current, err := s.repo.GetUnit(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	if err := s.assertScope(ctx, current.BranchID); err != nil {
		return nil, err
	}
	if current.Status == status {
		u := unitFromRow(current)
		return &u, nil
	}

	row, err := s.repo.SetUnitStatus(ctx, id, status, func(before, after db.Unit) []audit.Entry {
		action := audit.ActionUpdate
		if after.Status == dto.StatusActive {
			action = audit.ActionRestore
		}
		return audit.Changes(tableUnits, after.ID, action,
			map[string]any{"status": before.Status}, map[string]any{"status": after.Status})
	})
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	u := unitFromRow(row)
	return &u, nil
}

// DeleteUnit soft deletes a unit; the number and VIN become reusable because
// both unique indexes are partial on deleted_at IS NULL.
func (s *Service) DeleteUnit(ctx context.Context, id uuid.UUID) error {
	current, err := s.repo.GetUnit(ctx, id)
	if err != nil {
		return db.MapError(err, "unit")
	}
	if err := s.assertScope(ctx, current.BranchID); err != nil {
		return err
	}
	err = s.repo.DeleteUnit(ctx, id, func(u db.Unit) []audit.Entry {
		return audit.Changes(tableUnits, u.ID, audit.ActionDelete,
			map[string]any{"deleted_at": nil}, map[string]any{"deleted_at": "now"})
	})
	return db.MapError(err, "unit")
}

// AssignDriver links a driver to a unit. Q1.1 — a unit holds at most one open
// assignment per role, so the previous holder is closed automatically.
func (s *Service) AssignDriver(ctx context.Context, unitID uuid.UUID, in dto.UnitAssignDriver) (*dto.UnitAssignment, error) {
	unit, err := s.repo.GetUnit(ctx, unitID)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	if err := s.assertScope(ctx, unit.BranchID); err != nil {
		return nil, err
	}
	if unit.Status != dto.StatusActive {
		return nil, apierr.New(apierr.CodeInvalidState, http.StatusConflict,
			"an inactive unit cannot take a driver assignment")
	}

	driverID, err := parseUUID("driver_id", in.DriverID)
	if err != nil {
		return nil, err
	}
	driver, err := s.repo.GetDriver(ctx, driverID)
	if err != nil {
		return nil, db.MapError(err, "driver")
	}
	if driver.Status == dto.StatusInactive {
		return nil, apierr.New(apierr.CodeAccountInactive, http.StatusConflict,
			"an inactive driver cannot be assigned to a unit")
	}

	row, err := s.repo.AssignDriver(ctx, AssignDriverInput{
		UnitID: unitID, DriverID: driverID, Role: in.Role,
	}, func(a db.UnitDriverAssignment) []audit.Entry {
		return audit.Changes(tableAssignments, a.ID, audit.ActionAssign, nil, map[string]any{
			"unit_id":   a.UnitID.String(),
			"driver_id": a.DriverID.String(),
			"role":      a.Role,
		})
	})
	if err != nil {
		return nil, db.MapError(err, "unit assignment")
	}
	a := assignmentFrom(row)
	return &a, nil
}

// Diagnostics reports the ELD state of a unit (TZ §10.1, §10.5).
func (s *Service) Diagnostics(ctx context.Context, unitID uuid.UUID) (*dto.UnitDiagnostics, error) {
	unit, err := s.repo.GetUnit(ctx, unitID)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	if err := s.assertScope(ctx, unit.BranchID); err != nil {
		return nil, err
	}
	row, err := s.repo.UnitDiagnostics(ctx, unitID)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	out := diagnosticsFrom(row, s.now())
	return &out, nil
}

// History merges the audit trail of the unit with its driver assignment
// history into one reverse chronological timeline.
func (s *Service) History(ctx context.Context, f HistoryFilter) ([]dto.UnitHistoryEntry, int64, error) {
	unit, err := s.repo.GetUnit(ctx, f.UnitID)
	if err != nil {
		return nil, 0, db.MapError(err, "unit")
	}
	if err := s.assertScope(ctx, unit.BranchID); err != nil {
		return nil, 0, err
	}

	// Both sources are read from the first row up to the end of the requested
	// page, merged, and only then sliced — otherwise the merge would drop rows.
	window := HistoryFilter{UnitID: f.UnitID, From: f.From, To: f.To, Limit: f.Limit + f.Offset, Offset: 0}

	auditRows, auditTotal, err := s.repo.UnitAudit(ctx, window)
	if err != nil {
		return nil, 0, db.MapError(err, "unit")
	}
	assignRows, assignTotal, err := s.repo.UnitAssignments(ctx, window)
	if err != nil {
		return nil, 0, db.MapError(err, "unit")
	}

	merged := make([]dto.UnitHistoryEntry, 0, len(auditRows)+len(assignRows))
	for _, r := range auditRows {
		merged = append(merged, historyFromAudit(r))
	}
	for _, r := range assignRows {
		merged = append(merged, historyFromAssignment(r))
	}
	sort.SliceStable(merged, func(i, j int) bool { return merged[i].At.After(merged[j].At) })

	total := auditTotal + assignTotal
	start := int(f.Offset)
	if start > len(merged) {
		start = len(merged)
	}
	end := start + int(f.Limit)
	if end > len(merged) {
		end = len(merged)
	}
	return merged[start:end], total, nil
}

// assertScope hides rows outside the caller branch behind a 404, never a 403,
// so the API cannot be used to probe for foreign records.
func (s *Service) assertScope(ctx context.Context, branchID pgtype.UUID) error {
	sc, ok := mw.ScopeFrom(ctx)
	if !ok {
		return nil
	}
	var b *uuid.UUID
	if branchID.Valid {
		id := uuid.UUID(branchID.Bytes)
		b = &id
	}
	if !sc.AllowsBranch(b) {
		return apierr.NotFound("unit")
	}
	return nil
}

func (s *Service) resolveBranch(ctx context.Context, raw *string) (*uuid.UUID, error) {
	if raw == nil || strings.TrimSpace(*raw) == "" {
		return nil, nil
	}
	id, err := parseUUID("branch_id", *raw)
	if err != nil {
		return nil, err
	}
	if _, err := s.repo.GetBranch(ctx, id); err != nil {
		return nil, db.MapError(err, "branch")
	}
	return &id, nil
}

func unitFields(u db.Unit) map[string]any {
	return map[string]any{
		"branch_id":      uuidText(u.BranchID),
		"unit_number":    u.UnitNumber,
		"make":           pgconv.Deref(u.Make),
		"model":          pgconv.Deref(u.Model),
		"year":           u.Year,
		"vin":            pgconv.Deref(u.Vin),
		"license_plate":  pgconv.Deref(u.LicensePlate),
		"plate_region":   pgconv.Deref(u.PlateRegion),
		"fuel_type":      pgconv.Deref(u.FuelType),
		"sleeper_berth":  u.SleeperBerth,
		"gvwr_class":     pgconv.Deref(u.GvwrClass),
		"notes":          pgconv.Deref(u.Notes),
		"out_of_service": u.OutOfService,
		"status":         u.Status,
	}
}

// mapUnitWrite turns the partial unique indexes on (company_id, unit_number)
// and (company_id, vin) into a 409 UNIQUE_VIOLATION.
func mapUnitWrite(err error) error {
	if db.IsUniqueViolation(err) {
		return apierr.Wrap(err, apierr.CodeUniqueViolation, http.StatusConflict,
			"a unit with this unit_number or vin already exists")
	}
	return db.MapError(err, "unit")
}

func parseUUID(field, raw string) (uuid.UUID, error) {
	id, err := uuid.Parse(strings.TrimSpace(raw))
	if err != nil {
		return uuid.Nil, apierr.Validation("invalid identifier", apierr.FieldError{
			Field: field, Message: "must be a valid uuid",
		})
	}
	return id, nil
}

func trimPtr(v *string) *string {
	if v == nil {
		return nil
	}
	t := strings.TrimSpace(*v)
	return &t
}

func upperPtr(v *string) *string {
	if v == nil {
		return nil
	}
	t := strings.ToUpper(strings.TrimSpace(*v))
	return &t
}

func uuidText(v pgtype.UUID) any {
	if !v.Valid {
		return nil
	}
	return uuid.UUID(v.Bytes).String()
}
