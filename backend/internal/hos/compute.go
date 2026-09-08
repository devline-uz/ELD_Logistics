package hos

import (
	"fmt"
	"sort"
	"time"
)

// segment is one uninterrupted stretch of a single effective duty status.
type segment struct {
	start   time.Time
	end     time.Time
	status  Status // effective status (PC -> OFF, YM -> ON)
	raw     Status
	special Special
}

func (s segment) dur() time.Duration { return s.end.Sub(s.start) }

func (s segment) isRest() bool { return s.status == StatusOff || s.status == StatusSB }

func (s segment) isDuty() bool { return s.status == StatusOn || s.status == StatusDrive }

// sortedEvents validates, normalizes and sorts a copy of the input. The caller's
// slice is never modified; events may arrive out of order (offline sync).
func sortedEvents(events []Event, p Policy) ([]Event, error) {
	out := make([]Event, 0, len(events))
	for _, e := range events {
		if e.Status != "" && !e.Status.Valid() {
			return nil, fmt.Errorf("%w: %q", ErrUnknownStatus, string(e.Status))
		}
		if !e.Special.Valid() {
			return nil, fmt.Errorf("%w: %q", ErrUnknownSpecial, string(e.Special))
		}
		if !e.affectsDuty() {
			continue
		}
		e.Status, e.Special = normalizeStatus(e.Status, e.Special, p)
		e.Time = e.Time.UTC()
		out = append(out, e)
	}
	sort.SliceStable(out, func(i, j int) bool { return out[i].Time.Before(out[j].Time) })
	return out, nil
}

// walkSegments turns the ordered events into segments ending at end.
func walkSegments(evs []Event, end time.Time) []segment {
	segs := make([]segment, 0, len(evs))
	for i, e := range evs {
		if !e.Time.Before(end) {
			break
		}
		next := end
		if i+1 < len(evs) && evs[i+1].Time.Before(end) {
			next = evs[i+1].Time
		}
		if !next.After(e.Time) {
			continue
		}
		segs = append(segs, segment{
			start: e.Time, end: next,
			status: EffectiveStatus(e.Status, e.Special), raw: e.Status, special: e.Special,
		})
	}
	return segs
}

// observer receives every segment together with the state as it was *before*
// the segment is applied, which is what the violation detector needs.
type observer func(st *state, sg segment)

// state is the HOS state machine. It starts fully rested: with no history the
// driver is assumed to have completed a daily rest.
type state struct {
	p   Policy
	obs observer

	driveSinceRest  time.Duration // Q10.3: reset by daily rest
	driveSinceBreak time.Duration // Q10.4
	breakRun        time.Duration // current run of qualifying statuses

	shiftActive bool
	shiftStart  time.Time
	shiftPaused time.Duration // Q10.6: sleeper split pauses the 14h window

	cycleUsed time.Duration
	cycleFrom time.Time

	rest       RestPeriod
	restActive bool
	sbRun      time.Duration

	pendingLong  RestPeriod
	hasLong      bool
	pendingShort RestPeriod
	hasShort     bool
}

func newState(p Policy, cycleFrom time.Time) *state {
	return &state{p: p, cycleFrom: cycleFrom}
}

// fullReset applies a daily rest (or a qualifying sleeper split pair): the shift
// window and both drive counters start over (Q10.3, Q10.6).
func (st *state) fullReset() {
	st.shiftActive = false
	st.shiftPaused = 0
	st.driveSinceRest = 0
	st.driveSinceBreak = 0
	st.hasLong = false
	st.hasShort = false
}

func (st *state) advance(sg segment) {
	d := sg.dur()
	if d <= 0 {
		return
	}
	// A finished rest run is settled before the segment is observed, so that a
	// sleeper split pair (Q10.6) is already applied when violations are checked.
	if sg.isDuty() && st.restActive {
		st.closeRest()
	}
	if st.obs != nil {
		st.obs(st, sg)
	}
	// Q10.4: any continuous run of qualifying statuses of break_duration_min
	// clears the accumulated driving time.
	if st.p.breakQualifies(sg.status) {
		st.breakRun += d
		if st.breakRun >= st.p.breakLen() {
			st.driveSinceBreak = 0
		}
	} else {
		st.breakRun = 0
	}

	if sg.isRest() {
		st.applyRest(sg, d)
		return
	}
	if !st.shiftActive {
		// Q10.3: the shift window opens at the first ON/DR after a daily rest.
		st.shiftActive = true
		st.shiftStart = sg.start
		st.shiftPaused = 0
	}
	if sg.status == StatusDrive {
		st.driveSinceRest += d
		st.driveSinceBreak += d
	}
	// Q10.5: ON+DR inside the cycle window.
	st.cycleUsed += overlapAfter(sg.start, sg.end, st.cycleFrom)
}

func (st *state) applyRest(sg segment, d time.Duration) {
	if !st.restActive {
		st.restActive = true
		st.rest = RestPeriod{Start: sg.start}
		st.sbRun = 0
	}
	prev := st.rest.Total
	st.rest.End = sg.end
	st.rest.Total += d
	if sg.status == StatusSB {
		st.sbRun += d
	} else {
		st.sbRun = 0
	}
	if st.sbRun > st.rest.LongestSB {
		st.rest.LongestSB = st.sbRun
	}
	// Q10.5: cycle restart on continuous OFF/SB.
	if r, ok := st.p.restartLen(); ok && prev < r && st.rest.Total >= r {
		st.cycleUsed = 0
	}
	// Q10.3: daily rest.
	if prev < st.p.dailyRest() && st.rest.Total >= st.p.dailyRest() {
		st.fullReset()
	}
}

// closeRest evaluates a finished rest run for sleeper split pairing (Q10.6).
func (st *state) closeRest() {
	r := st.rest
	st.restActive = false
	st.rest = RestPeriod{}
	st.sbRun = 0
	if r.IsDailyRest(st.p) {
		return // already handled by applyRest
	}
	long := IsSplitLong(r, st.p)
	if long && st.shiftActive {
		// Q10.6: the long part pauses the 14h window.
		st.shiftPaused += r.Total
	}
	switch {
	case long:
		if st.hasShort && SplitPairQualifies(st.pendingShort, r, st.p) {
			st.fullReset()
			return
		}
		st.pendingLong, st.hasLong = r, true
	case IsSplitShort(r, st.p):
		if st.hasLong && SplitPairQualifies(st.pendingLong, r, st.p) {
			st.fullReset()
			return
		}
		st.pendingShort, st.hasShort = r, true
	}
}

// counters renders the remaining times at instant at.
func (st *state) counters(at time.Time) Counters {
	c := Counters{
		DriveLeft: clamp(st.p.driveLimit() - st.driveSinceRest),
		BreakLeft: clamp(st.p.breakAfter() - st.driveSinceBreak),
		CycleLeft: clamp(st.p.cycleLimit() - st.cycleUsed),
		ShiftLeft: st.p.shiftWindow(),
	}
	if st.shiftActive {
		c.ShiftLeft = clamp(st.p.shiftWindow() - (at.Sub(st.shiftStart) - st.shiftPaused))
	}
	// Q10.9
	c.DrivingTimeLeft = minDur(minDur(c.DriveLeft, c.ShiftLeft), minDur(c.CycleLeft, c.BreakLeft))
	return c
}

// Compute returns the BREAK/DRIVE/SHIFT/CYCLE counters at instant now.
// loc is the home terminal timezone used for the cycle window (Q10.2, Q10.5).
func Compute(events []Event, p Policy, now time.Time, loc *time.Location) (Counters, error) {
	p = p.normalized()
	if loc == nil {
		loc = time.UTC
	}
	evs, err := sortedEvents(events, p)
	if err != nil {
		return Counters{}, err
	}
	st := newState(p, CycleWindowStart(now, p, loc))
	for _, sg := range walkSegments(evs, now.UTC()) {
		st.advance(sg)
	}
	return st.counters(now.UTC()), nil
}

func clamp(d time.Duration) time.Duration {
	if d < 0 {
		return 0
	}
	return d
}

func minDur(a, b time.Duration) time.Duration {
	if a < b {
		return a
	}
	return b
}

// overlapAfter returns the part of [start,end) that lies at or after from.
func overlapAfter(start, end, from time.Time) time.Duration {
	if start.Before(from) {
		start = from
	}
	if !end.After(start) {
		return 0
	}
	return end.Sub(start)
}
