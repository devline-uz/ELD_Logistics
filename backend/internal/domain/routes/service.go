package routes

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/routes/dto"
	"github.com/devline/onebook-eld/internal/geo"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// auditTable is the audit_log table name of this module.
const auditTable = "routes"

// Service holds the trip planner business rules (Q66–Q68).
type Service struct {
	repo    Repo
	geo     geo.Provider
	alerter Alerter
	log     *slog.Logger
	now     func() time.Time
}

// NewService builds the routes service. A nil geo provider degrades directions
// to an empty answer, a nil alerter drops the driver notifications.
func NewService(repo Repo, provider geo.Provider, alerter Alerter,
	log *slog.Logger, now func() time.Time) *Service {
	if provider == nil {
		provider = geo.NewNop(log)
	}
	if alerter == nil {
		alerter = NopAlerter{}
	}
	if log == nil {
		log = slog.Default()
	}
	if now == nil {
		now = time.Now
	}
	return &Service{repo: repo, geo: provider, alerter: alerter, log: log, now: now}
}

// List returns one page of routes. A `self` scoped caller (the driver app,
// Q66) only ever sees its own legs, whatever `driver_id` the query asks for.
func (s *Service) List(ctx context.Context, f Filter) ([]dto.Route, int64, error) {
	if userID, ok := selfUser(ctx); ok {
		own, err := s.repo.DriverIDForUser(ctx, userID)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				// A self scoped principal without a driver row owns nothing.
				return []dto.Route{}, 0, nil
			}
			return nil, 0, apierr.Internal(err, "failed to resolve the caller")
		}
		f.DriverID = &own
	}
	if branchID, ok := scopeBranch(ctx); ok {
		// Q82 branch scope: a branch manager only ever sees the legs of the
		// drivers domiciled in its own branch, whatever the query asks for.
		f.BranchID = &branchID
	}
	rows, total, err := s.repo.List(ctx, f)
	if err != nil {
		return nil, 0, apierr.Internal(err, "failed to list routes")
	}
	out := make([]dto.Route, 0, len(rows))
	for _, r := range rows {
		out = append(out, toRouteFromList(r))
	}
	return out, total, nil
}

// Get returns one route. A route of another tenant answers 404, never 403.
func (s *Service) Get(ctx context.Context, id uuid.UUID) (*dto.Route, error) {
	row, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, routeErr(err, "failed to load route")
	}
	if err := s.allow(ctx, row.DriverID); err != nil {
		return nil, err
	}
	out := toRoute(row)
	return &out, nil
}

// Create plans a new leg. The route starts `ongoing` (Q66): there is no manual
// start, the geofence sweep is what moves it on.
func (s *Service) Create(ctx context.Context, in dto.RouteCreate) (*dto.Route, error) {
	unitID, err := uuid.Parse(in.UnitID)
	if err != nil {
		return nil, apierr.Validation("invalid unit_id", apierr.FieldError{Field: "unit_id", Message: apierr.MsgMustBeUUID})
	}
	driverID, err := uuid.Parse(in.DriverID)
	if err != nil {
		return nil, apierr.Validation("invalid driver_id", apierr.FieldError{Field: "driver_id", Message: apierr.MsgMustBeUUID})
	}
	unit, err := s.repo.Unit(ctx, unitID)
	if err != nil {
		return nil, unitErr(err)
	}
	driver, err := s.repo.Driver(ctx, driverID)
	if err != nil {
		return nil, driverErr(err)
	}
	if err := s.allowRef(ctx, "unit", pgconv.ToUUIDPtr(unit.BranchID)); err != nil {
		return nil, err
	}
	if err := s.allowRef(ctx, "driver", pgconv.ToUUIDPtr(driver.BranchID)); err != nil {
		return nil, err
	}

	sequence := in.Sequence
	if sequence <= 0 {
		// Q68: several routes may queue on one unit; the next free slot keeps
		// the order the dispatcher planned without them having to count.
		if sequence, err = s.repo.NextSequence(ctx, unitID); err != nil {
			return nil, apierr.Internal(err, "failed to derive the route sequence")
		}
	}
	geofence := in.GeofenceM
	if geofence <= 0 {
		geofence = dto.DefaultGeofenceM
	}

	userID := tenant.UserID(ctx)
	arg := db.CreateRouteParams{
		UnitID:     unitID,
		DriverID:   driverID,
		Sequence:   sequence,
		OriginText: pgconv.NilIfEmpty(in.Origin.Text),
		OriginLat:  &in.Origin.Lat,
		OriginLng:  &in.Origin.Lng,
		DestText:   pgconv.NilIfEmpty(in.Destination.Text),
		DestLat:    &in.Destination.Lat,
		DestLng:    &in.Destination.Lng,
		GeofenceM:  geofence,
		CreatedBy:  pgconv.UUID(userID),
		Note:       pgconv.NilIfEmpty(in.Note),
	}

	row, err := s.repo.Create(ctx, arg, func(r db.Route) []audit.Entry {
		return audit.Changes(auditTable, r.ID, audit.ActionCreate, nil, routeSnapshot(r))
	})
	if err != nil {
		return nil, apierr.Internal(err, "failed to create the route")
	}

	out := toRoute(row)
	s.alert(ctx, AlertRouteAssigned, Alert{
		CompanyID: tenant.CompanyID(ctx), RouteID: row.ID, UnitID: row.UnitID,
		DriverID: row.DriverID, UnitNumber: unit.UnitNumber, Sequence: row.Sequence,
		OriginText: out.Origin.Text, DestText: out.Destination.Text,
		Message: "New route assigned",
	})
	return &out, nil
}

// Update edits an ongoing route. A terminal route is a record, not a draft, so
// it can no longer be changed.
func (s *Service) Update(ctx context.Context, id uuid.UUID, in dto.RouteUpdate) (*dto.Route, error) {
	before, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, routeErr(err, "failed to load route")
	}
	if err := s.allow(ctx, before.DriverID); err != nil {
		return nil, err
	}
	if before.Status != dto.StatusOngoing {
		return nil, apierr.Conflict(apierr.CodeInvalidState, "only an ongoing route can be edited")
	}

	arg := db.UpdateRouteParams{ID: id, Sequence: in.Sequence, GeofenceM: in.GeofenceM, Note: in.Note}
	var newDriver *uuid.UUID
	if in.UnitID != nil {
		unitID, err := uuid.Parse(*in.UnitID)
		if err != nil {
			return nil, apierr.Validation("invalid unit_id", apierr.FieldError{Field: "unit_id", Message: apierr.MsgMustBeUUID})
		}
		unit, err := s.repo.Unit(ctx, unitID)
		if err != nil {
			return nil, unitErr(err)
		}
		if err := s.allowRef(ctx, "unit", pgconv.ToUUIDPtr(unit.BranchID)); err != nil {
			return nil, err
		}
		arg.UnitID = pgconv.UUID(unitID)
	}
	if in.DriverID != nil {
		driverID, err := uuid.Parse(*in.DriverID)
		if err != nil {
			return nil, apierr.Validation("invalid driver_id", apierr.FieldError{Field: "driver_id", Message: apierr.MsgMustBeUUID})
		}
		driver, err := s.repo.Driver(ctx, driverID)
		if err != nil {
			return nil, driverErr(err)
		}
		if err := s.allowRef(ctx, "driver", pgconv.ToUUIDPtr(driver.BranchID)); err != nil {
			return nil, err
		}
		arg.DriverID = pgconv.UUID(driverID)
		if driverID != before.DriverID {
			newDriver = &driverID
		}
	}
	if in.Origin != nil {
		arg.OriginText = pgconv.NilIfEmpty(in.Origin.Text)
		arg.OriginLat, arg.OriginLng = &in.Origin.Lat, &in.Origin.Lng
	}
	if in.Destination != nil {
		arg.DestText = pgconv.NilIfEmpty(in.Destination.Text)
		arg.DestLat, arg.DestLng = &in.Destination.Lat, &in.Destination.Lng
	}

	row, err := s.repo.Update(ctx, arg, func(b, a db.Route) []audit.Entry {
		return audit.Changes(auditTable, a.ID, audit.ActionUpdate, routeSnapshot(b), routeSnapshot(a))
	})
	if err != nil {
		return nil, routeErr(err, "failed to update the route")
	}

	out := toRoute(row)
	if newDriver != nil {
		s.alert(ctx, AlertRouteReassigned, Alert{
			CompanyID: tenant.CompanyID(ctx), RouteID: row.ID, UnitID: row.UnitID,
			DriverID: *newDriver, UnitNumber: row.UnitNumber, Sequence: row.Sequence,
			OriginText: out.Origin.Text, DestText: out.Destination.Text,
			Message: "Route reassigned",
		})
	}
	return &out, nil
}

// Delete soft deletes a route.
func (s *Service) Delete(ctx context.Context, id uuid.UUID) error {
	before, err := s.repo.Get(ctx, id)
	if err != nil {
		return routeErr(err, "failed to load route")
	}
	if err := s.allow(ctx, before.DriverID); err != nil {
		return err
	}
	err = s.repo.Delete(ctx, id, func(r db.Route) []audit.Entry {
		return audit.Changes(auditTable, r.ID, audit.ActionDelete, routeSnapshot(r), nil)
	})
	if err != nil {
		return routeErr(err, "failed to delete the route")
	}
	return nil
}

// NotCompleted closes an ongoing route with a reason from the fixed list
// (Q66). `other` must carry an explanation, otherwise the record is useless.
func (s *Service) NotCompleted(ctx context.Context, id uuid.UUID, in dto.RouteNotCompleted) (*dto.Route, error) {
	if in.Reason == dto.ReasonOther && in.Note == "" {
		return nil, apierr.Validation("a note is required for the `other` reason",
			apierr.FieldError{Field: "note", Message: "required when reason is other"})
	}
	before, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, routeErr(err, "failed to load route")
	}
	if err := s.allow(ctx, before.DriverID); err != nil {
		return nil, err
	}
	if before.Status != dto.StatusOngoing {
		return nil, apierr.Conflict(apierr.CodeInvalidState, "only an ongoing route can be closed as not completed")
	}

	row, err := s.repo.NotCompleted(ctx, db.SetRouteNotCompletedParams{
		ID:                 id,
		NotCompletedReason: &in.Reason,
		NotCompletedNote:   pgconv.NilIfEmpty(in.Note),
		NotCompletedBy:     pgconv.UUID(tenant.UserID(ctx)),
	}, func(b, a db.Route) []audit.Entry {
		return audit.Changes(auditTable, a.ID, audit.ActionUpdate, routeSnapshot(b), routeSnapshot(a))
	})
	if err != nil {
		return nil, routeErr(err, "failed to close the route")
	}

	out := toRoute(row)
	s.alert(ctx, AlertRouteNotCompleted, Alert{
		CompanyID: tenant.CompanyID(ctx), RouteID: row.ID, UnitID: row.UnitID,
		DriverID: row.DriverID, UnitNumber: row.UnitNumber, Sequence: row.Sequence,
		OriginText: out.Origin.Text, DestText: out.Destination.Text,
		Reason: in.Reason, Message: "Route closed as not completed",
	})
	return &out, nil
}

// Directions returns the map provider geometry of one route (Q66.1). The
// answer is cached by internal/geo, so opening the same route repeatedly costs
// one provider call.
func (s *Service) Directions(ctx context.Context, id uuid.UUID) (*dto.Directions, error) {
	row, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, routeErr(err, "failed to load route")
	}
	if err := s.allow(ctx, row.DriverID); err != nil {
		return nil, err
	}
	if row.OriginLat == nil || row.OriginLng == nil || row.DestLat == nil || row.DestLng == nil {
		return nil, apierr.Conflict(apierr.CodeInvalidState, "the route has no origin or destination coordinates")
	}
	from := geo.Point{Lat: *row.OriginLat, Lng: *row.OriginLng}
	to := geo.Point{Lat: *row.DestLat, Lng: *row.DestLng}

	route, err := s.geo.Directions(ctx, from, to)
	if err != nil {
		return nil, apierr.Wrap(err, apierr.CodeUnavailable, http.StatusServiceUnavailable,
			"the map provider is unavailable")
	}
	return &dto.Directions{
		RouteID:     row.ID.String(),
		DistanceM:   route.DistanceM,
		DurationS:   route.DurationS,
		Polyline:    route.Polyline,
		Provider:    route.Provider,
		Origin:      dto.Waypoint{Text: pgconv.Deref(row.OriginText), Lat: row.OriginLat, Lng: row.OriginLng},
		Destination: dto.Waypoint{Text: pgconv.Deref(row.DestText), Lat: row.DestLat, Lng: row.DestLng},
	}, nil
}

// alert hands one notification to the consumer side interface. A notification
// failure never fails the request that produced it.
func (s *Service) alert(ctx context.Context, kind string, a Alert) {
	if err := s.alerter.Alert(ctx, kind, a); err != nil {
		s.log.WarnContext(ctx, "routes: alert not delivered",
			slog.String("kind", kind), slog.String("route_id", a.RouteID.String()),
			slog.String("error", err.Error()))
	}
}

// selfUser returns the caller's user id when the principal is `self` scoped
// (the driver application). Every other scope answers false.
func selfUser(ctx context.Context) (uuid.UUID, bool) {
	f, ok := mw.ScopeFrom(ctx)
	if !ok || f.Scope != tenant.ScopeSelf || f.SelfUserID == nil {
		return uuid.Nil, false
	}
	return *f.SelfUserID, true
}

// scopeBranch returns the branch a `branch` scoped caller is pinned to. Every
// other scope answers false.
func scopeBranch(ctx context.Context) (uuid.UUID, bool) {
	f, ok := mw.ScopeFrom(ctx)
	if !ok || f.Scope != tenant.ScopeBranch || f.BranchID == nil {
		return uuid.Nil, false
	}
	return *f.BranchID, true
}

// allow enforces the `self` and `branch` scopes on one route. A leg that
// belongs to another driver or to another branch answers 404, never 403, so a
// caller cannot probe route ids.
func (s *Service) allow(ctx context.Context, driverID uuid.UUID) error {
	f, ok := mw.ScopeFrom(ctx)
	if !ok {
		return nil
	}
	self := f.Scope == tenant.ScopeSelf && f.SelfUserID != nil
	branch := f.Scope == tenant.ScopeBranch && f.BranchID != nil
	if !self && !branch {
		return nil
	}
	driver, err := s.repo.Driver(ctx, driverID)
	if err != nil {
		return apierr.NotFound("route")
	}
	if !f.AllowsUser(driver.UserID) || !f.AllowsBranch(pgconv.ToUUIDPtr(driver.BranchID)) {
		return apierr.NotFound("route")
	}
	return nil
}

// allowRef rejects a referenced row outside the caller's branch. The answer is
// a 404 on that entity, so a branch manager cannot enumerate another branch's
// fleet by probing ids. A row without a branch is not visible to a branch
// scoped caller either (ScopeFilter.AllowsBranch(nil) is false).
func (s *Service) allowRef(ctx context.Context, entity string, branchID *uuid.UUID) error {
	f, ok := mw.ScopeFrom(ctx)
	if !ok || f.Scope != tenant.ScopeBranch || f.BranchID == nil {
		return nil
	}
	if !f.AllowsBranch(branchID) {
		return apierr.NotFound(entity)
	}
	return nil
}

// routeSnapshot is the audit projection of a route. It carries no coordinates:
// a position is PII and the audit log is read by support staff.
func routeSnapshot(r db.Route) map[string]any {
	return map[string]any{
		"unit_id":              r.UnitID.String(),
		"driver_id":            r.DriverID.String(),
		"sequence":             r.Sequence,
		"origin_text":          pgconv.Deref(r.OriginText),
		"dest_text":            pgconv.Deref(r.DestText),
		"geofence_m":           r.GeofenceM,
		"status":               r.Status,
		"note":                 pgconv.Deref(r.Note),
		"not_completed_reason": pgconv.Deref(r.NotCompletedReason),
	}
}

// routeErr maps a storage error onto the API error. A missing row is always a
// 404, which is also the cross-tenant answer.
func routeErr(err error, msg string) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return apierr.NotFound("route")
	}
	return apierr.Internal(err, msg)
}

func unitErr(err error) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return apierr.NotFound("unit")
	}
	return apierr.Internal(err, "failed to load the unit")
}

func driverErr(err error) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return apierr.NotFound("driver")
	}
	return apierr.Internal(err, "failed to load the driver")
}
