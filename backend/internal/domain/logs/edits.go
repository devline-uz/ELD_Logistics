package logs

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"sort"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/hos"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// maxChangesPerRequest bounds one proposal so a single call cannot rewrite a
// whole week of driving.
const maxChangesPerRequest = 50

// CreateEditInput is one admin proposal (Q17).
type CreateEditInput struct {
	CompanyID   uuid.UUID
	RequestedBy uuid.UUID
	Body        dto.LogEditRequestCreate
}

// CreateEditRequest stores an admin proposal. The admin never writes the log
// directly: the driver approves or rejects it (TZ §5.3, [MUST]).
func (s *Service) CreateEditRequest(ctx context.Context, in CreateEditInput) (*dto.LogEditRequest, error) {
	driverID, err := uuid.Parse(in.Body.DriverID)
	if err != nil {
		return nil, apierr.Validation("driver_id must be a uuid",
			apierr.FieldError{Field: "driver_id", Message: apierr.MsgMustBeUUID})
	}
	logID, err := uuid.Parse(in.Body.DailyLogID)
	if err != nil {
		return nil, apierr.Validation("daily_log_id must be a uuid",
			apierr.FieldError{Field: "daily_log_id", Message: apierr.MsgMustBeUUID})
	}
	if len(in.Body.Changes) > maxChangesPerRequest {
		return nil, apierr.Validation("too many changes in one request",
			apierr.FieldError{Field: "changes", Message: "at most 50 entries"})
	}

	log, err := s.DailyLog(ctx, in.CompanyID, logID)
	if err != nil {
		return nil, err
	}
	if log.DriverID != driverID {
		return nil, apierr.NotFound("daily log")
	}
	// A proposal is a write against someone's log day, so the caller's branch
	// and self scopes apply exactly as on the read path: a Driver may only
	// propose on its own log, a branch scoped admin only inside its branch.
	// Out of scope answers 404, never 403.
	if err := allowLog(ctx, log); err != nil {
		return nil, err
	}

	events, err := s.repo.DayEvents(ctx, in.CompanyID, log.ID)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load log events")
	}
	// Fail fast: a proposal that the driver could never approve is refused now.
	if _, err := buildGroups(log, events, in.Body.Changes, originAdminEdit); err != nil {
		return nil, err
	}

	payload, err := json.Marshal(in.Body.Changes)
	if err != nil {
		return nil, apierr.Internal(err, "failed to encode the proposed changes")
	}

	req := EditRequest{
		CompanyID: in.CompanyID, DriverID: driverID, DailyLogID: log.ID,
		RequestedBy: in.RequestedBy, Source: sourceAdminEdit, Changes: payload,
		LogDate: log.LogDate, Timezone: log.Timezone, DriverName: log.DriverName,
	}
	stored, err := s.repo.CreateEditRequest(ctx, req, []audit.Entry{{
		TableName: "log_edit_requests", Action: audit.ActionCreate,
		Field: "changes", NewValue: string(payload),
	}})
	if err != nil {
		return nil, apierr.Internal(err, "failed to create the log edit request")
	}
	stored.Status = editPending
	// TZ A§5.3: the driver learns a change is waiting for its approval.
	s.alert(ctx, AlertLogEditRequested, Alert{
		CompanyID: in.CompanyID, DriverID: driverID, DailyLogID: log.ID,
		RequestID: stored.ID, LogDate: dayKeyOf(log.LogDate), RequestedBy: in.RequestedBy,
		Message: "Admin proposed a change to your log for " + dayKeyOf(log.LogDate),
	})
	return editRequestDTO(stored), nil
}

// EditRequestList returns a page of the propose/approve queue.
func (s *Service) EditRequestList(ctx context.Context, f EditRequestFilter) ([]dto.LogEditRequest, int64, error) {
	rows, total, err := s.repo.EditRequests(ctx, f)
	if err != nil {
		return nil, 0, apierr.Internal(err, "failed to list log edit requests")
	}
	out := make([]dto.LogEditRequest, 0, len(rows))
	for _, row := range rows {
		out = append(out, *editRequestDTO(row))
	}
	return out, total, nil
}

// EditRequest resolves one request, answering 404 for a cross-tenant id.
func (s *Service) EditRequest(ctx context.Context, companyID, id uuid.UUID) (EditRequest, error) {
	row, err := s.repo.EditRequest(ctx, companyID, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return EditRequest{}, apierr.NotFound("log edit request")
	}
	if err != nil {
		return EditRequest{}, apierr.Internal(err, "failed to load the log edit request")
	}
	return row, nil
}

// ApproveEdit applies a pending proposal (Q17). The new events carry
// `origin=admin_edit`, the originals stay behind `superseded_by` and the day
// falls back to `needs_recertify` (Q18).
func (s *Service) ApproveEdit(ctx context.Context, req EditRequest, by uuid.UUID) (*dto.LogEditRequest, error) {
	if req.Status != editPending {
		return nil, apierr.Conflict(apierr.CodeInvalidState, "this request has already been answered")
	}
	log, err := s.DailyLog(ctx, req.CompanyID, req.DailyLogID)
	if err != nil {
		return nil, err
	}

	plan := EditPlan{
		CompanyID: req.CompanyID, DriverID: req.DriverID, DailyLogID: log.ID,
		Timezone: log.Timezone, Day: log.LogDate, Certified: log.Certified(),
		ResolveRequestID: &req.ID, ResolveStatus: editApproved, ResolveBy: by,
	}

	if req.Source == sourceUnidentifiedAssign && req.UnidentifiedEventID != nil {
		ids, err := s.unassignedEventIDs(ctx, req.CompanyID, *req.UnidentifiedEventID)
		if err != nil {
			return nil, err
		}
		plan.AssignEventIDs = ids
		plan.UnidentifiedID = req.UnidentifiedEventID
	} else {
		var changes []dto.LogEditChange
		if err := json.Unmarshal(req.Changes, &changes); err != nil {
			return nil, apierr.Internal(err, "failed to decode the proposed changes")
		}
		events, err := s.repo.DayEvents(ctx, req.CompanyID, log.ID)
		if err != nil {
			return nil, apierr.Internal(err, "failed to load log events")
		}
		groups, err := buildGroups(log, events, changes, originAdminEdit)
		if err != nil {
			return nil, err
		}
		plan.Groups = groups
	}

	if err := s.repo.ApplyEdit(ctx, plan, []audit.Entry{{
		TableName: "log_edit_requests", RecordID: req.ID, Action: audit.ActionApprove,
		Field: "status", NewValue: editApproved,
	}}); err != nil {
		return nil, apierr.Internal(err, "failed to apply the log edit request")
	}

	s.afterEdit(ctx, req.CompanyID, log.ID)
	if req.UnidentifiedEventID != nil {
		if err := s.repo.ResolveUnidentifiedViolation(ctx, req.CompanyID, *req.UnidentifiedEventID,
			ResolutionReason(violationUnidentifiedDrive), &by); err != nil {
			s.log.WarnContext(ctx, "failed to close the unidentified driving violation", "error", err)
		}
	}

	fresh, err := s.EditRequest(ctx, req.CompanyID, req.ID)
	if err != nil {
		return nil, err
	}
	// TZ A§5.3: the requesting admin learns the proposal was answered.
	s.alert(ctx, AlertLogEditResolved, Alert{
		CompanyID: req.CompanyID, DriverID: req.DriverID, DailyLogID: req.DailyLogID,
		RequestID: req.ID, LogDate: dayKeyOf(req.LogDate), RequestedBy: req.RequestedBy,
		Status: editApproved, Message: "Log edit request for " + dayKeyOf(req.LogDate) + " was approved",
	})
	return editRequestDTO(fresh), nil
}

// RejectEdit refuses a proposal; the log is untouched and the admin is told why.
func (s *Service) RejectEdit(ctx context.Context, req EditRequest, by uuid.UUID, reason string) (*dto.LogEditRequest, error) {
	if req.Status != editPending {
		return nil, apierr.Conflict(apierr.CodeInvalidState, "this request has already been answered")
	}
	stored, err := s.repo.RejectEditRequest(ctx, req.CompanyID, req.ID, by, reason,
		req.UnidentifiedEventID, []audit.Entry{{
			TableName: "log_edit_requests", RecordID: req.ID, Action: audit.ActionReject,
			Field: "status", NewValue: editRejected, Reason: reason,
		}})
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, apierr.Conflict(apierr.CodeInvalidState, "this request has already been answered")
	}
	if err != nil {
		return nil, apierr.Internal(err, "failed to reject the log edit request")
	}
	stored.DriverName = req.DriverName
	stored.LogDate = req.LogDate
	stored.Timezone = req.Timezone
	// TZ A§5.3: the requesting admin learns the proposal was answered.
	s.alert(ctx, AlertLogEditResolved, Alert{
		CompanyID: req.CompanyID, DriverID: req.DriverID, DailyLogID: req.DailyLogID,
		RequestID: req.ID, LogDate: dayKeyOf(req.LogDate), RequestedBy: req.RequestedBy,
		Status: editRejected, Message: "Log edit request for " + dayKeyOf(req.LogDate) + " was rejected: " + reason,
	})
	return editRequestDTO(stored), nil
}

// DriverEdit is the driver's own correction (Q17): applied immediately, note
// mandatory, the original events kept.
func (s *Service) DriverEdit(ctx context.Context, log DailyLog, by uuid.UUID, body dto.LogEventCreate) (*dto.DailyLogDetail, error) {
	change := dto.LogEditChange{
		From: body.From, To: body.To, Status: body.Status, Special: body.Special, Note: body.Note,
	}
	events, err := s.repo.DayEvents(ctx, log.CompanyID, log.ID)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load log events")
	}
	groups, err := buildGroups(log, events, []dto.LogEditChange{change}, originDriverEdit)
	if err != nil {
		return nil, err
	}
	if body.UnitID != nil {
		unitID, perr := uuid.Parse(*body.UnitID)
		if perr != nil {
			return nil, apierr.Validation("unit_id must be a uuid",
				apierr.FieldError{Field: "unit_id", Message: apierr.MsgMustBeUUID})
		}
		for gi := range groups {
			for bi := range groups[gi].Boundary {
				groups[gi].Boundary[bi].UnitID = &unitID
			}
		}
	}

	payload, _ := json.Marshal([]dto.LogEditChange{change})
	if err := s.repo.ApplyEdit(ctx, EditPlan{
		CompanyID: log.CompanyID, DriverID: log.DriverID, DailyLogID: log.ID,
		Timezone: log.Timezone, Day: log.LogDate, Certified: log.Certified(), Groups: groups,
	}, []audit.Entry{{
		TableName: "duty_status_events", RecordID: log.ID, Action: audit.ActionCreate,
		Field: "driver_edit", NewValue: string(payload), Reason: body.Note,
	}}); err != nil {
		return nil, apierr.Internal(err, "failed to apply the driver edit")
	}

	s.afterEdit(ctx, log.CompanyID, log.ID)
	fresh, err := s.DailyLog(ctx, log.CompanyID, log.ID)
	if err != nil {
		return nil, err
	}
	return s.Detail(ctx, fresh)
}

// afterEdit recomputes the canonical violations of a rewritten day.
func (s *Service) afterEdit(ctx context.Context, companyID, dailyLogID uuid.UUID) {
	fresh, err := s.repo.DailyLog(ctx, companyID, dailyLogID)
	if err != nil {
		s.log.WarnContext(ctx, "violation recomputation skipped", "error", err)
		return
	}
	if err := s.SyncDayViolations(ctx, fresh); err != nil {
		s.log.WarnContext(ctx, "violation recomputation failed", "error", err)
	}
}

// unassignedEventIDs collects the raw driving rows behind one unidentified
// block so an approval can hand them over with `origin=assigned` (§10.4).
func (s *Service) unassignedEventIDs(ctx context.Context, companyID, blockID uuid.UUID) ([]uuid.UUID, error) {
	block, err := s.repo.Unidentified(ctx, companyID, blockID)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, apierr.NotFound("unidentified event")
	}
	if err != nil {
		return nil, apierr.Internal(err, "failed to load the unidentified driving block")
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
	return ids, nil
}

// ------------------------------------------------------------- edit planner

// segment is one duty status interval rebuilt from the stored events.
type segment struct {
	start   time.Time
	end     time.Time
	status  string
	special string
	origin  string
}

// timeline rebuilds the day's duty status intervals from the surviving events.
func timeline(events []Event, dayStart, dayEnd time.Time) []segment {
	live := make([]Event, 0, len(events))
	for _, e := range events {
		if e.SupersededBy != nil || e.EventType != eventDutyStatus || e.Status == nil {
			continue
		}
		live = append(live, e)
	}
	sort.SliceStable(live, func(i, j int) bool { return live[i].EventTime.Before(live[j].EventTime) })

	out := make([]segment, 0, len(live))
	for i, e := range live {
		end := dayEnd
		if i+1 < len(live) {
			end = live[i+1].EventTime
		}
		start := e.EventTime
		if start.Before(dayStart) {
			start = dayStart
		}
		if !start.Before(end) {
			continue
		}
		out = append(out, segment{
			start: start.UTC(), end: end.UTC(),
			status: *e.Status, special: e.Special, origin: e.Origin,
		})
	}
	return out
}

// statusAt reports the duty status in force at an instant.
func statusAt(segs []segment, at time.Time) (string, string, bool) {
	for _, sg := range segs {
		if !at.Before(sg.start) && at.Before(sg.end) {
			return sg.status, sg.special, true
		}
	}
	return "", "", false
}

// buildGroups turns the proposed changes into storage operations and enforces
// the Q17.1 prohibitions.
func buildGroups(log DailyLog, events []Event, changes []dto.LogEditChange, origin string) ([]EditGroup, error) {
	if len(changes) == 0 {
		return nil, apierr.Validation("at least one change is required",
			apierr.FieldError{Field: "changes", Message: "required"})
	}
	day, loc := dayOf(log)
	dayStart, dayEnd := hos.DayRange(day, loc)
	segs := timeline(events, dayStart.UTC(), dayEnd.UTC())

	out := make([]EditGroup, 0, len(changes))
	for i, ch := range changes {
		from, to := ch.From.UTC(), ch.To.UTC()
		if !from.Before(to) {
			return nil, apierr.Validation("from must be before to",
				apierr.FieldError{Field: field(i, "from"), Message: "must be before to"})
		}
		if from.Before(dayStart.UTC()) || to.After(dayEnd.UTC()) {
			return nil, apierr.Validation("the change must stay inside the log day",
				apierr.FieldError{Field: field(i, "from"), Message: "outside the log day"})
		}
		if ch.Note == "" {
			// Q17: an edit without a reason is never accepted.
			return nil, apierr.Validation("note is required for every change",
				apierr.FieldError{Field: field(i, "note"), Message: "required"})
		}
		special := ch.Special
		if special == "" {
			special = string(hos.SpecialNone)
		}
		if err := checkImmutability(events, segs, from, to, special, origin); err != nil {
			return nil, err
		}

		group := EditGroup{Boundary: []PlannedEvent{{
			Status: ch.Status, Special: special, EventTime: from, Origin: origin, Note: ch.Note,
		}}}
		for _, e := range events {
			if e.SupersededBy != nil || e.EventType != eventDutyStatus {
				continue
			}
			t := e.EventTime.UTC()
			if !t.Before(from) && t.Before(to) {
				group.Supersede = append(group.Supersede, e.ID)
			}
		}
		// Bound the edit: restore whatever the timeline said at `to`.
		if prev, prevSpecial, ok := statusAt(segs, to); ok && (prev != ch.Status || prevSpecial != special) {
			group.Boundary = append(group.Boundary, PlannedEvent{
				Status: prev, Special: prevSpecial, EventTime: to, Origin: origin,
				Note: "restored after edit: " + ch.Note,
			})
		}
		out = append(out, group)
	}
	return out, nil
}

// checkImmutability enforces Q17.1: automatically recorded driving may never be
// shortened or re-classified — only the driver may re-label it as PC or YM —
// and intermediate/power/malfunction events are never editable.
func checkImmutability(events []Event, segs []segment, from, to time.Time,
	special, origin string,
) error {
	for _, e := range events {
		if e.SupersededBy != nil || !e.Immutable() {
			continue
		}
		t := e.EventTime.UTC()
		if !t.Before(from) && t.Before(to) {
			return apierr.New(apierr.CodeEventImmutable, http.StatusConflict,
				"intermediate, power and malfunction events cannot be edited")
		}
	}

	for _, sg := range segs {
		if sg.status != string(hos.StatusDrive) || sg.origin != originAuto {
			continue
		}
		if !sg.start.Before(to) || !from.Before(sg.end) {
			continue
		}
		// The only permitted rewrite of automatic driving: the driver marking
		// it as Personal Conveyance or Yard Move, with a reason.
		if origin == originDriverEdit &&
			(special == string(hos.SpecialPC) || special == string(hos.SpecialYM)) {
			continue
		}
		return apierr.New(apierr.CodeDRImmutable, http.StatusConflict,
			"automatically recorded driving time cannot be shortened or re-classified; "+
				"only the driver may re-label it as PC or YM")
	}
	return nil
}

func field(i int, name string) string {
	return "changes[" + itoa(i) + "]." + name
}

func itoa(i int) string {
	if i == 0 {
		return "0"
	}
	var buf [8]byte
	pos := len(buf)
	for i > 0 {
		pos--
		buf[pos] = byte('0' + i%10)
		i /= 10
	}
	return string(buf[pos:])
}

// editRequestDTO maps a stored request onto the API shape.
func editRequestDTO(r EditRequest) *dto.LogEditRequest {
	out := &dto.LogEditRequest{
		ID: r.ID.String(), DriverID: r.DriverID.String(), DriverName: r.DriverName,
		DailyLogID: r.DailyLogID.String(), LogDate: dayKeyOf(r.LogDate), Timezone: r.Timezone,
		Status: r.Status, Source: r.Source, RequestedBy: r.RequestedBy.String(),
		DriverNote: r.DriverNote, ResolvedAt: r.ResolvedAt,
		CreatedAt: r.CreatedAt.UTC(), UpdatedAt: r.UpdatedAt.UTC(),
		Changes: []dto.LogEditChange{},
	}
	if len(r.Changes) > 0 {
		_ = json.Unmarshal(r.Changes, &out.Changes)
	}
	if out.Changes == nil {
		out.Changes = []dto.LogEditChange{}
	}
	out.UnidentifiedEventID = idString(r.UnidentifiedEventID)
	return out
}

// allowLog enforces the caller's branch and self scope on a resolved log day.
func allowLog(ctx context.Context, log DailyLog) error {
	f, ok := mw.ScopeFrom(ctx)
	if !ok {
		return apierr.Unauthorized("authentication required")
	}
	if !f.AllowsBranch(log.BranchID) || !f.AllowsUser(log.DriverUserID) {
		return apierr.NotFound("daily log")
	}
	return nil
}
