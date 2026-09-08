package sync

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/duty"
	logsdto "github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/domain/sync/dto"
	"github.com/devline/onebook-eld/internal/hos"
)

// PullInput is one authenticated /sync/pull call.
type PullInput struct {
	CompanyID uuid.UUID
	UserID    uuid.UUID
	// Since is the cursor from the previous pull; zero means the default
	// 8 day window.
	Since time.Time
	// UnitID is the unit the driver is currently logged into. It selects the
	// unidentified driving buffer to offer (TZ A§10.4).
	UnitID *uuid.UUID
}

// Pull returns everything the device has to catch up on.
//
// The cursor is the newest `updated_at` actually returned, never the server
// clock: a truncated page therefore resumes exactly where it stopped and no row
// can slip through the gap between the query and the response.
func (s *Service) Pull(ctx context.Context, in PullInput) (*dto.PullResponse, error) {
	now := s.now().UTC()
	driver, err := s.dutySvc.DriverByUser(ctx, in.CompanyID, in.UserID)
	if err != nil {
		return nil, err
	}

	since := in.Since.UTC()
	if since.IsZero() {
		since = now.Add(-defaultPullWindow)
	}
	f := PullFilter{
		CompanyID: in.CompanyID,
		DriverID:  driver.DriverID,
		UnitIDs:   pullUnits(in.UnitID, driver.DefaultUnitID),
		Since:     since,
		Limit:     pullLimit,
	}

	out := &dto.PullResponse{
		ServerTime:         now,
		NextSince:          since,
		LogEditRequests:    []dto.LogEditRequest{},
		UnidentifiedEvents: []dto.UnidentifiedEvent{},
		Events:             []dto.DutyStatusEvent{},
		DailyLogs:          []dto.DailyLogSummary{},
		DefectTypes:        []dto.DefectType{},
		QuickNotes:         quickNotes(driver.Settings),
		Chat:               []dto.ChatMessage{},
	}

	cursor := newCursor(since)

	events, err := s.repo.ChangedEvents(ctx, f)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load changed events")
	}
	for _, row := range events {
		out.Events = append(out.Events, changedEventDTO(row))
		cursor.observe(row.UpdatedAt)
	}
	cursor.truncated(len(events), f.Limit)

	logs, err := s.repo.ChangedDailyLogs(ctx, f)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load changed daily logs")
	}
	for _, row := range logs {
		out.DailyLogs = append(out.DailyLogs, dailyLogDTO(row))
		cursor.observe(row.UpdatedAt)
	}
	cursor.truncated(len(logs), f.Limit)

	unidentified, err := s.repo.Unidentified(ctx, f)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load unidentified events")
	}
	for _, row := range unidentified {
		out.UnidentifiedEvents = append(out.UnidentifiedEvents, unidentifiedDTO(row))
		cursor.observe(row.UpdatedAt)
	}
	cursor.truncated(len(unidentified), f.Limit)

	// Q17: the proposals the driver still has to approve or reject.
	edits, err := s.repo.PendingLogEdits(ctx, f)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load pending log edit requests")
	}
	for _, row := range edits {
		out.LogEditRequests = append(out.LogEditRequests, logEditDTO(row))
		cursor.observe(row.UpdatedAt)
	}
	cursor.truncated(len(edits), f.Limit)

	chat, err := s.repo.Chat(ctx, f)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load chat messages")
	}
	for _, row := range chat {
		out.Chat = append(out.Chat, chatDTO(row))
		cursor.observe(row.UpdatedAt)
	}
	cursor.truncated(len(chat), f.Limit)

	defects, err := s.repo.DefectTypes(ctx, in.CompanyID)
	if err != nil {
		return nil, apierr.Internal(err, "failed to load defect types")
	}
	for _, row := range defects {
		out.DefectTypes = append(out.DefectTypes, dto.DefectType{
			ID: row.ID.String(), Name: row.Name, Category: row.Category,
			IsCritical: row.IsCritical, SortOrder: row.SortOrder,
		})
	}

	policy, err := s.dutySvc.Policy(ctx, in.CompanyID, now)
	if err != nil {
		return nil, err
	}
	out.HosPolicy = policyDTO(policy)

	out.NextSince = cursor.next
	out.Truncated = cursor.hitLimit
	return out, nil
}

// pullUnits resolves which units' unidentified driving buffer to offer.
func pullUnits(explicit, fallback *uuid.UUID) []uuid.UUID {
	switch {
	case explicit != nil:
		return []uuid.UUID{*explicit}
	case fallback != nil:
		return []uuid.UUID{*fallback}
	default:
		return nil
	}
}

// cursor tracks the newest updated_at seen across the pull lists.
type cursor struct {
	next     time.Time
	hitLimit bool
}

func newCursor(since time.Time) *cursor { return &cursor{next: since} }

func (c *cursor) observe(at time.Time) {
	if at.After(c.next) {
		c.next = at.UTC()
	}
}

func (c *cursor) truncated(got int, limit int32) {
	if int32(got) >= limit { //nolint:gosec // G115: got is a query result count bounded by the sync page limit
		c.hitLimit = true
	}
}

// quickNotes reads companies.settings.quick_notes, the status note templates
// the driver app offers offline (Q7).
func quickNotes(settings []byte) []string {
	out := []string{}
	if len(settings) == 0 {
		return out
	}
	var doc struct {
		QuickNotes []string `json:"quick_notes"`
	}
	if err := json.Unmarshal(settings, &doc); err != nil {
		return out
	}
	if doc.QuickNotes != nil {
		return doc.QuickNotes
	}
	return out
}

// policyDTO flattens the engine policy into the wire shape the offline HOS
// engine consumes.
func policyDTO(v duty.PolicyVersion) dto.HosPolicy {
	p := v.Policy
	statuses := make([]string, 0, len(p.BreakQualifyingStatuses))
	for _, s := range p.BreakQualifyingStatuses {
		statuses = append(statuses, string(s))
	}
	out := dto.HosPolicy{
		DriveLimitMin:              p.DriveLimitMin,
		ShiftWindowMin:             p.ShiftWindowMin,
		BreakRequiredAfterDriveMin: p.BreakRequiredAfterDriveMin,
		BreakDurationMin:           p.BreakDurationMin,
		BreakQualifyingStatuses:    statuses,
		DailyRestMin:               p.DailyRestMin,
		CycleLimitMin:              p.CycleLimitMin,
		CycleDays:                  p.CycleDays,
		CycleRestartMin:            p.CycleRestartMin,
		SleeperSplitEnabled:        p.SleeperSplitEnabled,
		AllowPC:                    p.AllowPC,
		AllowYM:                    p.AllowYM,
		YMMaxSpeedKmh:              p.YMMaxSpeedKmh,
		MotionThresholdKmh:         p.MotionThresholdKmh,
		ShortHaulException:         p.ShortHaulException,
		AdverseConditionsExtMin:    p.AdverseConditionsExtMin,
		WarnDriveMin:               p.WarningThresholds.DriveMin,
		WarnShiftMin:               p.WarningThresholds.ShiftMin,
		WarnBreakMin:               p.WarningThresholds.BreakMin,
		WarnCycleMin:               p.WarningThresholds.CycleMin,
	}
	if v.ID != nil {
		id := v.ID.String()
		out.VersionID = &id
	}
	return out
}

// dayKeyOf formats a DATE column value as the calendar day it represents.
func dayKeyOf(t time.Time) string { return hos.DayKey(t.UTC(), time.UTC) }

// logEditDTO maps one pending proposal onto the pull payload (Q17).
func logEditDTO(row db.LogsListPendingEditRequestsForDriverRow) dto.LogEditRequest {
	out := dto.LogEditRequest{
		ID: row.ID.String(), DailyLogID: row.DailyLogID.String(),
		LogDate: row.LogDate.Time.Format("2006-01-02"), Timezone: row.Timezone,
		Status: row.Status, Source: row.Source,
		Changes:   []logsdto.LogEditChange{},
		CreatedAt: row.CreatedAt.UTC(), UpdatedAt: row.UpdatedAt.UTC(),
	}
	if len(row.Changes) > 0 {
		_ = json.Unmarshal(row.Changes, &out.Changes)
	}
	if out.Changes == nil {
		out.Changes = []logsdto.LogEditChange{}
	}
	return out
}
