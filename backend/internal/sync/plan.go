package sync

import (
	"sort"
	"time"
)

// PlanPush turns one push batch into the decision set the domain layer executes.
//
// The rules are applied in a fixed order per event, because the first match is
// the reported outcome:
//  1. payload validation and the event_time window (rule 3),
//  2. idempotency — a client_event_id already stored, or repeated inside the
//     same batch, is `duplicate` and not an error,
//  3. rule 5 — a certified (locked) log day only accepts edit requests,
//  4. rule 1 — the same instant claimed by another device is resolved by
//     time_source priority and device_seq; the loser is still stored.
//
// Rule 1 compares against stored events only: two events at the same instant
// inside one batch come from one device, which is a client bug rather than a
// cross-device race, and the unique client_event_id already separates them.
func PlanPush(b Batch, now time.Time, lk Lookup) (*Plan, error) {
	if err := ValidateBatch(b); err != nil {
		return nil, err
	}

	p := &Plan{
		Integrity:  EvaluateClock(b.Clock, now),
		Events:     make([]Decision, len(b.Events)),
		Normalized: make([]Event, len(b.Events)),
	}

	seen := make(map[string]struct{}, len(b.Events))
	for i, ev := range b.Events {
		p.Events[i], p.Normalized[i] = planEvent(ev, now, p.Integrity, lk, seen)
	}
	p.Telemetry = PlanTelemetry(b.Telemetry, now)
	return p, nil
}

// planEvent decides one event. The returned Event is zero unless the decision
// is `accepted`.
func planEvent(ev Event, now time.Time, in Integrity, lk Lookup, seen map[string]struct{}) (Decision, Event) {
	d := Decision{ClientEventID: ev.ClientEventID}

	if f := ValidateEvent(ev, now); f.failed() {
		d.Result, d.Reason, d.Field = ResultRejected, f.Reason, f.Field
		return d, Event{}
	}
	if _, dup := seen[ev.ClientEventID]; dup || (lk.Known != nil && lk.Known(ev.ClientEventID)) {
		d.Result = ResultDuplicate
		return d, Event{}
	}
	if lk.DayLocked != nil && lk.DayLocked(ev.EventTime) {
		d.Result, d.Reason = ResultRejected, ReasonLogLocked
		return d, Event{}
	}

	norm := NormalizeEvent(ev, in)
	if norm.EventType == EventDutyStatus && lk.Existing != nil {
		c := ResolveConflict(Candidate{
			ClientEventID: norm.ClientEventID,
			EventTime:     norm.EventTime,
			TimeSource:    norm.TimeSource,
			DeviceSeq:     norm.DeviceSeq,
			ReceivedAt:    now,
		}, lk.Existing(norm.EventTime))

		if c.IncomingWins {
			d.Supersedes = c.Supersedes
		} else {
			// Rule 1: the loser is stored, flagged and reported back so the
			// driver app can warn instead of silently dropping the entry.
			d.Reason = ReasonSuperseded
			d.SupersededBy, d.SupersededByID = c.WinnerClientEventID, c.WinnerID
		}
	}

	d.Result = ResultAccepted
	seen[ev.ClientEventID] = struct{}{}
	return d, norm
}

// PlanTelemetry validates and de-duplicates the telemetry half of a batch.
// Rule 4: a repeated (unit_id, ts) sample is ignored, never an error. Samples
// outside the accepted time window are dropped rather than failing the push,
// because a single bad sample must not cost the driver the whole batch.
func PlanTelemetry(points []TelemetryPoint, now time.Time) TelemetryPlan {
	out := TelemetryPlan{Points: make([]TelemetryPoint, 0, len(points))}
	seen := make(map[int64]struct{}, len(points))

	for _, pt := range points {
		if pt.TS.IsZero() || CheckEventTime(pt.TS, now).failed() {
			out.Rejected++
			continue
		}
		if validCoords(pt.Lat, pt.Lng).failed() {
			out.Rejected++
			continue
		}
		if pt.SpeedKmh != nil && (*pt.SpeedKmh < 0 || *pt.SpeedKmh > 400) {
			out.Rejected++
			continue
		}
		key := pt.TS.UTC().Truncate(time.Second).UnixNano()
		if _, dup := seen[key]; dup {
			out.Duplicate++
			continue
		}
		seen[key] = struct{}{}
		out.Points = append(out.Points, pt)
	}

	sort.SliceStable(out.Points, func(i, j int) bool {
		return out.Points[i].TS.Before(out.Points[j].TS)
	})
	return out
}
