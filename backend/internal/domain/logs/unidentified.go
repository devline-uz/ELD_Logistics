package logs

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/hos"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Unidentified resolves one unassigned driving block, answering 404 for a
// cross-tenant id.
func (s *Service) Unidentified(ctx context.Context, companyID, id uuid.UUID) (Unidentified, error) {
	row, err := s.repo.Unidentified(ctx, companyID, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return Unidentified{}, apierr.NotFound("unidentified event")
	}
	if err != nil {
		return Unidentified{}, apierr.Internal(err, "failed to load the unidentified driving block")
	}
	return row, nil
}

// AssignUnidentified proposes an unassigned driving block to a driver (§10.4).
// The block does not move until the driver approves the generated edit
// request — the same propose/approve model as §5.3.
func (s *Service) AssignUnidentified(ctx context.Context, companyID, blockID, by uuid.UUID,
	body dto.UnidentifiedAssign,
) (*dto.LogEditRequest, error) {
	block, err := s.Unidentified(ctx, companyID, blockID)
	if err != nil {
		return nil, err
	}
	if block.Status != unidentifiedPending {
		return nil, apierr.Conflict(apierr.CodeAlreadyAssigned, "this driving block has already been handled")
	}
	driverID, err := uuid.Parse(body.DriverID)
	if err != nil {
		return nil, apierr.Validation("driver_id must be a uuid",
			apierr.FieldError{Field: "driver_id", Message: apierr.MsgMustBeUUID})
	}
	driver, err := s.duty.DriverContext(ctx, companyID, driverID)
	if err != nil {
		return nil, err
	}
	// A branch scoped administrator may not hand a block to a driver of
	// another branch; out of scope answers 404, never 403.
	if f, ok := mw.ScopeFrom(ctx); !ok {
		return nil, apierr.Unauthorized("authentication required")
	} else if !f.AllowsBranch(driver.BranchID) || !f.AllowsUser(driver.UserID) {
		return nil, apierr.NotFound("driver")
	}

	logID, day, err := s.logDayFor(ctx, companyID, driver.DriverID, driver.Timezone, block.StartAt)
	if err != nil {
		return nil, err
	}
	from, to := block.Window()
	payload, err := json.Marshal([]dto.LogEditChange{{
		From: from.UTC(), To: to.UTC(), Status: string(hos.StatusDrive),
		Special: string(hos.SpecialNone), Note: body.Note,
	}})
	if err != nil {
		return nil, apierr.Internal(err, "failed to encode the assignment")
	}

	// Q: both writes land in the same transaction (repo_write.go) so a
	// mid-transaction failure never leaves the request `pending` behind a
	// block that never reached `proposed`.
	req, err := s.repo.CreateAssignmentRequest(ctx, EditRequest{
		CompanyID: companyID, DriverID: driver.DriverID, DailyLogID: logID,
		RequestedBy: by, Source: sourceUnidentifiedAssign, Changes: payload,
		UnidentifiedEventID: &block.ID, LogDate: day, Timezone: driver.Timezone,
	}, block.ID, driver.DriverID, by,
		[]audit.Entry{{
			TableName: "log_edit_requests", Action: audit.ActionCreate,
			Field: "unidentified_event_id", NewValue: block.ID.String(), Reason: body.Note,
		}},
		[]audit.Entry{{
			TableName: "unidentified_events", RecordID: block.ID, Action: audit.ActionAssign,
			Field: "status", NewValue: unidentifiedProposed,
		}})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apierr.Conflict(apierr.CodeAlreadyAssigned, "this driving block has already been handled")
		}
		return nil, apierr.Internal(err, "failed to create the assignment request")
	}

	req.Status = editPending
	req.DriverName = driver.DriverID.String()
	fresh, err := s.EditRequest(ctx, companyID, req.ID)
	if err != nil {
		return nil, err
	}
	// TZ A§5.3: the driver learns a change is waiting for its approval.
	s.alert(ctx, AlertLogEditRequested, Alert{
		CompanyID: companyID, DriverID: driver.DriverID, DailyLogID: logID,
		RequestID: req.ID, LogDate: dayKeyOf(day), RequestedBy: by,
		Message: "Admin proposed a change to your log for " + dayKeyOf(day),
	})
	return editRequestDTO(fresh), nil
}

// ClaimUnidentified lets the driver take an unassigned block itself (§10.4).
// The stored rows keep their identity and only gain `origin=assigned`.
func (s *Service) ClaimUnidentified(ctx context.Context, companyID, blockID uuid.UUID,
	driverID, userID uuid.UUID, timezone string,
) (*dto.UnidentifiedEvent, error) {
	block, err := s.Unidentified(ctx, companyID, blockID)
	if err != nil {
		return nil, err
	}
	switch block.Status {
	case unidentifiedPending:
	case unidentifiedProposed:
		if block.AssignedDriverID == nil || *block.AssignedDriverID != driverID {
			return nil, apierr.Conflict(apierr.CodeAlreadyAssigned, "this driving block is proposed to another driver")
		}
	default:
		return nil, apierr.Conflict(apierr.CodeAlreadyAssigned, "this driving block has already been handled")
	}

	logID, day, err := s.logDayFor(ctx, companyID, driverID, timezone, block.StartAt)
	if err != nil {
		return nil, err
	}
	log, err := s.DailyLog(ctx, companyID, logID)
	if err != nil {
		return nil, err
	}

	from, to := block.Window()
	rows, err := s.repo.UnassignedEvents(ctx, companyID, block.UnitID, from, to)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load unassigned events")
	}
	ids := make([]uuid.UUID, 0, len(rows))
	for _, row := range rows {
		ids = append(ids, row.ID)
	}

	if err := s.repo.ApplyEdit(ctx, EditPlan{
		CompanyID: companyID, DriverID: driverID, DailyLogID: logID,
		Timezone: timezone, Day: day, Certified: log.Certified(),
		AssignEventIDs: ids, UnidentifiedID: &block.ID,
	}, []audit.Entry{{
		TableName: "unidentified_events", RecordID: block.ID, Action: audit.ActionAssign,
		Field: "status", NewValue: unidentifiedAssigned,
	}}); err != nil {
		return nil, apierr.Internal(err, "failed to claim the driving block")
	}

	if err := s.repo.ResolveUnidentifiedViolation(ctx, companyID, block.ID,
		ResolutionReason(violationUnidentifiedDrive), &userID); err != nil {
		s.log.WarnContext(ctx, "failed to close the unidentified driving violation", "error", err)
	}
	s.afterEdit(ctx, companyID, logID)

	fresh, err := s.Unidentified(ctx, companyID, block.ID)
	if err != nil {
		return nil, err
	}
	out := unidentifiedDTO(fresh)
	return &out, nil
}

// AnnotateUnidentified leaves the block unassigned with an explanation, for
// example a mechanic's test drive (§10.4).
func (s *Service) AnnotateUnidentified(ctx context.Context, companyID, blockID, by uuid.UUID,
	body dto.UnidentifiedAnnotate,
) (*dto.UnidentifiedEvent, error) {
	block, err := s.Unidentified(ctx, companyID, blockID)
	if err != nil {
		return nil, err
	}
	if block.Status != unidentifiedPending && block.Status != unidentifiedProposed {
		return nil, apierr.Conflict(apierr.CodeInvalidState, "this driving block has already been handled")
	}
	stored, err := s.repo.AnnotateUnidentified(ctx, companyID, blockID, by, body.Annotation,
		[]audit.Entry{{
			TableName: "unidentified_events", RecordID: blockID, Action: audit.ActionUpdate,
			Field: "status", NewValue: unidentifiedAnnotated, Reason: body.Annotation,
		}})
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, apierr.Conflict(apierr.CodeInvalidState, "this driving block has already been handled")
	}
	if err != nil {
		return nil, apierr.Internal(err, "failed to annotate the driving block")
	}
	stored.UnitNumber = block.UnitNumber
	out := unidentifiedDTO(stored)
	return &out, nil
}

// logDayFor resolves (creating on first touch) the driver's log day that holds
// an instant, cut in the home terminal timezone (Q10.2).
func (s *Service) logDayFor(ctx context.Context, companyID, driverID uuid.UUID, timezone string,
	at time.Time,
) (uuid.UUID, time.Time, error) {
	loc, err := time.LoadLocation(timezone)
	if err != nil || loc == nil {
		loc = time.UTC
	}
	day := hos.StartOfDay(at.In(loc), loc)
	id, derr := s.repo.DailyLogFor(ctx, companyID, driverID, day, timezone)
	if derr != nil {
		return uuid.Nil, time.Time{}, apierr.Internal(derr, "failed to resolve the log day")
	}
	return id, day, nil
}

func unidentifiedDTO(u Unidentified) dto.UnidentifiedEvent {
	out := dto.UnidentifiedEvent{
		ID: u.ID.String(), UnitID: u.UnitID.String(), UnitNumber: u.UnitNumber,
		StartAt: u.StartAt.UTC(), EndAt: u.EndAt, DistanceM: u.DistanceM,
		Status: u.Status, Annotation: u.Annotation, CreatedAt: u.CreatedAt.UTC(),
	}
	out.AssignedDriverID = idString(u.AssignedDriverID)
	out.EditRequestID = idString(u.EditRequestID)
	return out
}
