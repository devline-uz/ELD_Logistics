package duty

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/hos"
	syncrules "github.com/devline/onebook-eld/internal/sync"
)

// eventDutyStatus is the stored spelling of a duty status change.
const eventDutyStatus = syncrules.EventDutyStatus

// Server side rejection reasons on top of the sync rule layer (TZ A§3, A§4.2).
// They are reported per event in the /sync/push response.
const (
	// ReasonPCNotAllowed — hos_policy.allow_pc is false.
	ReasonPCNotAllowed = "pc_not_allowed"
	// ReasonYMNotAllowed — hos_policy.allow_ym is false.
	ReasonYMNotAllowed = "ym_not_allowed"
	// ReasonSleeperUnavailable — Q4.3, the unit has no sleeper berth.
	ReasonSleeperUnavailable = "sleeper_berth_unavailable"
	// ReasonDriveNotManual — Q4, DR is never selected by hand.
	ReasonDriveNotManual = "drive_not_manual"
)

// Server side coercions. The event is stored, with the corrected status, and
// the reason tells the app what the server changed.
const (
	// ReasonAutoDrive — Q5, motion at or above motion_threshold_kmh.
	ReasonAutoDrive = "auto_drive"
	// ReasonYardMoveEnded — Q4.2, speed above ym_max_speed_kmh ends YM.
	ReasonYardMoveEnded = "yard_move_ended"
)

// tableEvents is the audited table of duty status writes.
const tableEvents = "duty_status_events"

// hosWindowDays is how much history beyond the cycle window is replayed so the
// shift, break and restart detection has context.
const hosWindowDays = 2

// IngestInput is the duty-status half of one /sync/push, for a single driver.
type IngestInput struct {
	CompanyID uuid.UUID
	DriverID  uuid.UUID
	// ActorID is the authenticated user the audit trail is attributed to.
	ActorID uuid.UUID
	// Events are the raw events exactly as the device sent them.
	Events []syncrules.Event
	// Clock is the device clock snapshot of the batch (Q-B1.2).
	Clock syncrules.Clock
	// DefaultUnitID is used when an event does not name a unit.
	DefaultUnitID *uuid.UUID
}

// IngestResult is the per event outcome plus the batch time integrity verdict.
type IngestResult struct {
	Integrity syncrules.Integrity
	// Decisions is aligned by index with IngestInput.Events.
	Decisions []syncrules.Decision
	Written   int
}

// Service holds the duty status write path and the HOS read path. It knows
// nothing about HTTP; /sync/push and the log endpoints both call it.
func (s *Service) Ingest(ctx context.Context, in IngestInput) (*IngestResult, error) {
	now := s.now().UTC()
	driver, err := s.DriverContext(ctx, in.CompanyID, in.DriverID)
	if err != nil {
		return nil, err
	}
	loc := driver.Location()

	lookup, err := s.buildLookup(ctx, in, loc)
	if err != nil {
		return nil, err
	}

	plan, err := syncrules.PlanPush(syncrules.Batch{Clock: in.Clock, Events: in.Events}, now, lookup)
	if err != nil {
		return nil, apierr.New(apierr.CodeBatchTooLarge, 422, err.Error())
	}

	res := &IngestResult{Integrity: plan.Integrity, Decisions: plan.Events}
	write := WriteInput{CompanyID: in.CompanyID, DriverID: in.DriverID, Timezone: driver.Timezone}
	entries := make([]audit.Entry, 0, len(plan.Events))

	policies := newPolicyCache(s.repo, in.CompanyID)
	units := newUnitCache(s.repo, in.CompanyID)

	for i := range plan.Events {
		if !plan.Events[i].Accepted() {
			continue
		}
		ev := plan.Normalized[i]
		day := hos.StartOfDay(ev.EventTime, loc)

		policy, perr := policies.at(ctx, day)
		if perr != nil {
			return nil, apierr.Internal(perr, "failed to load hos policy")
		}
		unitID := resolveUnitID(ev.UnitID, in.DefaultUnitID)
		sleeper, uerr := units.sleeperBerth(ctx, unitID)
		if uerr != nil {
			return nil, apierr.Internal(uerr, "failed to load unit")
		}

		checked, reason, rejected := applyServerChecks(ev, policy.Policy, sleeper)
		if rejected {
			plan.Events[i].Result = syncrules.ResultRejected
			plan.Events[i].Reason = reason
			plan.Events[i].Supersedes = nil
			continue
		}
		if reason != "" {
			plan.Events[i].Reason = reason
		}

		row, berr := buildWriteEvent(checked, unitID, day)
		if berr != nil {
			plan.Events[i].Result = syncrules.ResultRejected
			plan.Events[i].Reason = syncrules.ReasonInvalidPayload
			plan.Events[i].Field = berr.Error()
			continue
		}
		row.Supersedes = parseUUIDs(plan.Events[i].Supersedes)
		if id, perr := uuid.Parse(plan.Events[i].SupersededByID); perr == nil {
			row.SupersededBy = &id
		}
		write.Events = append(write.Events, row)

		entries = append(entries, audit.Entry{
			TableName: tableEvents,
			RecordID:  row.ClientEventID,
			Field:     "status",
			NewValue:  ev.Status,
			Action:    audit.ActionCreate,
			EditedBy:  in.ActorID,
			CompanyID: in.CompanyID,
		})
	}

	if len(write.Events) > 0 {
		out, werr := s.repo.Write(ctx, write, entries)
		if werr != nil {
			return nil, apierr.Internal(werr, "failed to store duty status events")
		}
		res.Written = out.Written
	}
	return res, nil
}

// buildLookup wires the three stored-state callbacks the rule layer needs. All
// three are resolved up front in bulk so one push costs a constant number of
// round trips regardless of the batch size.
func (s *Service) buildLookup(ctx context.Context, in IngestInput, loc *time.Location) (syncrules.Lookup, error) {
	ids := make([]uuid.UUID, 0, len(in.Events))
	days := make([]time.Time, 0, len(in.Events))
	seenDay := make(map[string]struct{}, len(in.Events))
	var minAt, maxAt time.Time

	for _, ev := range in.Events {
		if id, err := uuid.Parse(ev.ClientEventID); err == nil {
			ids = append(ids, id)
		}
		if ev.EventTime.IsZero() {
			continue
		}
		day := hos.StartOfDay(ev.EventTime, loc)
		if key := hos.DayKey(day, loc); !has(seenDay, key) {
			seenDay[key] = struct{}{}
			days = append(days, day)
		}
		if minAt.IsZero() || ev.EventTime.Before(minAt) {
			minAt = ev.EventTime
		}
		if maxAt.IsZero() || ev.EventTime.After(maxAt) {
			maxAt = ev.EventTime
		}
	}

	known, err := s.repo.KnownClientEventIDs(ctx, in.CompanyID, ids)
	if err != nil {
		return syncrules.Lookup{}, apierr.Internal(err, "failed to check event idempotency")
	}
	certified, err := s.repo.CertifiedDays(ctx, in.CompanyID, in.DriverID, days)
	if err != nil {
		return syncrules.Lookup{}, apierr.Internal(err, "failed to check certified days")
	}

	stored := map[int64][]syncrules.Candidate{}
	if !minAt.IsZero() {
		rows, aerr := s.repo.EventsAtInstants(ctx, in.CompanyID, in.DriverID, minAt.UTC(), maxAt.UTC())
		if aerr != nil {
			return syncrules.Lookup{}, apierr.Internal(aerr, "failed to load conflicting events")
		}
		for _, row := range rows {
			key := row.EventTime.UTC().UnixNano()
			stored[key] = append(stored[key], syncrules.Candidate{
				ID:            row.ID.String(),
				ClientEventID: row.ClientEventID.String(),
				EventTime:     row.EventTime,
				TimeSource:    row.TimeSource,
				DeviceSeq:     row.DeviceSeq,
				ReceivedAt:    row.ReceivedAt,
			})
		}
	}

	return syncrules.Lookup{
		Known: func(id string) bool {
			parsed, perr := uuid.Parse(id)
			if perr != nil {
				return false
			}
			_, found := known[parsed]
			return found
		},
		DayLocked: func(t time.Time) bool { return certified[hos.DayKey(t, loc)] },
		Existing:  func(t time.Time) []syncrules.Candidate { return stored[t.UTC().UnixNano()] },
	}, nil
}

func has(m map[string]struct{}, key string) bool {
	_, ok := m[key]
	return ok
}

// applyServerChecks enforces the duty rules the server owns (Q4, Q4.1-Q4.3,
// Q5). It either rejects the event, coerces its status and returns the reason
// for the coercion, or passes it through unchanged.
func applyServerChecks(ev syncrules.Event, p hos.Policy, sleeperBerth bool) (syncrules.Event, string, bool) {
	if ev.EventType != eventDutyStatus {
		return ev, "", false
	}

	switch ev.Special {
	case syncrules.SpecialPC:
		if !p.AllowPC {
			return ev, ReasonPCNotAllowed, true
		}
	case syncrules.SpecialYM:
		if !p.AllowYM {
			return ev, ReasonYMNotAllowed, true
		}
	}
	// Q4.3: without a sleeper berth the SB status does not exist.
	if ev.Status == syncrules.StatusSB && !sleeperBerth {
		return ev, ReasonSleeperUnavailable, true
	}
	// Q4: DR is produced by motion, never chosen in the status modal.
	if ev.Status == syncrules.StatusDrive && isManual(ev.Origin) {
		return ev, ReasonDriveNotManual, true
	}

	if ev.SpeedKmh == nil {
		return ev, "", false
	}
	speed := *ev.SpeedKmh

	// Q4.2: yard move ends above ym_max_speed_kmh and becomes driving.
	if ev.Special == syncrules.SpecialYM && hos.ShouldExitYardMove(speed, p) {
		ev.Special = syncrules.SpecialNone
		ev.Status = syncrules.StatusDrive
		ev.Origin = syncrules.OriginAuto
		return ev, ReasonYardMoveEnded, false
	}
	// Q5: motion at or above the threshold is driving. Personal conveyance is
	// exempt: movement under PC is not DR (Q4.1).
	if ev.Special == syncrules.SpecialNone && ev.Status != syncrules.StatusDrive &&
		hos.ShouldStartDriving(speed, p) {
		ev.Status = syncrules.StatusDrive
		ev.Origin = syncrules.OriginAuto
		return ev, ReasonAutoDrive, false
	}
	return ev, "", false
}

// isManual reports whether the origin means a human picked the status.
func isManual(origin string) bool {
	switch origin {
	case syncrules.OriginDriver, syncrules.OriginDriverEdit,
		syncrules.OriginAdminEdit, syncrules.OriginManualNoELD:
		return true
	}
	return false
}

// resolveUnitID falls back to the driver's default unit when the event carries
// no unit of its own.
func resolveUnitID(raw string, fallback *uuid.UUID) *uuid.UUID {
	if raw != "" {
		if id, err := uuid.Parse(raw); err == nil {
			return &id
		}
	}
	return fallback
}

// buildWriteEvent converts a validated rule-layer event into a storable row.
func buildWriteEvent(ev syncrules.Event, unitID *uuid.UUID, day time.Time) (WriteEvent, error) {
	clientID, err := uuid.Parse(ev.ClientEventID)
	if err != nil {
		return WriteEvent{}, errors.New("client_event_id")
	}
	trailers, err := parseIDs(ev.TrailerIDs)
	if err != nil {
		return WriteEvent{}, errors.New("trailer_ids")
	}
	docs, err := parseIDs(ev.ShippingDocIDs)
	if err != nil {
		return WriteEvent{}, errors.New("shipping_doc_ids")
	}

	row := WriteEvent{
		ClientEventID:  clientID,
		UnitID:         unitID,
		EventType:      ev.EventType,
		Special:        ev.Special,
		Origin:         ev.Origin,
		EventTime:      ev.EventTime.UTC(),
		TimeSource:     ev.TimeSource,
		TimeUnverified: ev.TimeUnverified,
		ClockSkewSec:   int32(ev.ClockSkewSec), //nolint:gosec // G115: seconds between two validated timestamps, far below int32 range
		Lat:            ev.Lat,
		Lng:            ev.Lng,
		GPSAccuracyM:   ev.GPSAccuracyM,
		OdometerM:      ev.OdometerM,
		EngineHours:    ev.EngineHours,
		TrailerIDs:     trailers,
		ShippingDocIDs: docs,
		DeviceSeq:      ev.DeviceSeq,
		LogDate:        day,
	}
	if ev.Status != "" {
		status := ev.Status
		row.Status = &status
	}
	if ev.Notes != "" {
		notes := ev.Notes
		row.Notes = &notes
	}
	if ev.LocationText != "" {
		text := ev.LocationText
		row.LocationText = &text
	}
	if ev.ELDDeviceID != "" {
		if id, perr := uuid.Parse(ev.ELDDeviceID); perr == nil {
			row.ELDDeviceID = &id
		}
	}
	return row, nil
}

func parseIDs(raw []string) ([]uuid.UUID, error) {
	out := make([]uuid.UUID, 0, len(raw))
	for _, v := range raw {
		id, err := uuid.Parse(v)
		if err != nil {
			return nil, err
		}
		out = append(out, id)
	}
	return out, nil
}

// parseUUIDs drops unparsable ids instead of failing: they can only come from
// the database, so an unusable one means nothing to supersede.
func parseUUIDs(raw []string) []uuid.UUID {
	out := make([]uuid.UUID, 0, len(raw))
	for _, v := range raw {
		if id, err := uuid.Parse(v); err == nil {
			out = append(out, id)
		}
	}
	return out
}

// Events returns one page of a driver's duty status events.
