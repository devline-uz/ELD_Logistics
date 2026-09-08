package hos

import "time"

// violationOrder keeps the output deterministic across implementations.
var violationOrder = []string{
	ViolationDriveLimit, ViolationShiftLimit, ViolationBreakRequired, ViolationCycleLimit,
}

// collector records at most one entry per type per log day; a violation always
// supersedes the warning of the same type (Q57).
type collector struct {
	p        Policy
	dayStart time.Time
	dayEnd   time.Time
	found    map[string]Violation
}

func newCollector(p Policy, dayStart, dayEnd time.Time) *collector {
	return &collector{p: p, dayStart: dayStart, dayEnd: dayEnd, found: map[string]Violation{}}
}

func (c *collector) add(typ, severity string, at time.Time) {
	if at.Before(c.dayStart) || !at.Before(c.dayEnd) {
		return
	}
	prev, ok := c.found[typ]
	if ok && (prev.Severity == SeverityViolation || severity == prev.Severity) {
		return
	}
	c.found[typ] = Violation{Type: typ, Severity: severity, At: at.UTC()}
}

func (c *collector) result() []Violation {
	out := make([]Violation, 0, len(c.found))
	for _, typ := range violationOrder {
		if v, ok := c.found[typ]; ok {
			out = append(out, v)
		}
	}
	return out
}

// exceedAt returns the instant an accumulator that starts at acc and grows for d
// passes strictly beyond target inside the segment starting at start.
func exceedAt(acc, d time.Duration, start time.Time, target time.Duration) (time.Time, bool) {
	if target < 0 {
		target = 0
	}
	if acc+d <= target {
		return time.Time{}, false
	}
	if acc >= target {
		return start, true
	}
	return start.Add(target - acc), true
}

// reachAt returns the instant the accumulator reaches target (non strict).
func reachAt(acc, d time.Duration, start time.Time, target time.Duration) (time.Time, bool) {
	if target < 0 {
		target = 0
	}
	if acc+d < target {
		return time.Time{}, false
	}
	if acc >= target {
		return start, true
	}
	return start.Add(target - acc), true
}

// track records the warning/violation crossings of one accumulator counter.
func (c *collector) track(typ string, acc, d time.Duration, start time.Time, limit, warn time.Duration, canViolate bool) {
	if canViolate {
		if at, ok := exceedAt(acc, d, start, limit); ok {
			c.add(typ, SeverityViolation, at)
		}
	}
	if at, ok := reachAt(acc, d, start, limit-warn); ok {
		c.add(typ, SeverityWarning, at)
	}
}

// observe inspects one segment before it is applied to the state.
func (c *collector) observe(st *state, sg segment) {
	if !sg.isDuty() {
		return
	}
	d := sg.dur()
	driving := sg.status == StatusDrive
	th := c.p.WarningThresholds

	if driving {
		// Q10.4 + drive_limit: DR beyond 11h / DR beyond 8h without a break.
		c.track(ViolationDriveLimit, st.driveSinceRest, d, sg.start,
			c.p.driveLimit(), minutes(th.DriveMin), true)
		c.track(ViolationBreakRequired, st.driveSinceBreak, d, sg.start,
			c.p.breakAfter(), minutes(th.BreakMin), true)
	}
	// Q10.5: cycle grows on ON and DR, but only driving over the cycle is a violation.
	if cs, ce, ok := overlapRange(sg.start, sg.end, st.cycleFrom); ok {
		c.track(ViolationCycleLimit, st.cycleUsed, ce.Sub(cs), cs,
			c.p.cycleLimit(), minutes(th.CycleMin), driving)
	}
	// Q10.3: the 14h window is wall clock from the shift start; the segment that
	// opens the shift is observed before the state knows about it.
	shiftStart, paused := sg.start, time.Duration(0)
	if st.shiftActive {
		shiftStart, paused = st.shiftStart, st.shiftPaused
	}
	windowEnd := shiftStart.Add(c.p.shiftWindow() + paused)
	if driving && sg.end.After(windowEnd) {
		c.add(ViolationShiftLimit, SeverityViolation, laterOf(sg.start, windowEnd))
	}
	warnAt := windowEnd.Add(-minutes(th.ShiftMin))
	if !sg.end.Before(warnAt) {
		c.add(ViolationShiftLimit, SeverityWarning, laterOf(sg.start, warnAt))
	}
}

func laterOf(a, b time.Time) time.Time {
	if a.After(b) {
		return a
	}
	return b
}

// overlapRange clips [start,end) to the part at or after from.
func overlapRange(start, end, from time.Time) (time.Time, time.Time, bool) {
	if start.Before(from) {
		start = from
	}
	if !end.After(start) {
		return start, end, false
	}
	return start, end, true
}

// Violations evaluates one log day in the home terminal timezone (Q10.2, Q57).
// The whole history is replayed so that counters carry over from previous days;
// a status left open at the end of the day is projected to midnight.
func Violations(events []Event, p Policy, day time.Time, loc *time.Location) []Violation {
	p = p.normalized()
	if loc == nil {
		loc = time.UTC
	}
	evs, err := sortedEvents(events, p)
	if err != nil {
		return nil
	}
	dayStart, dayEnd := DayRange(day, loc)
	c := newCollector(p, dayStart.UTC(), dayEnd.UTC())
	st := newState(p, CycleWindowStart(dayStart, p, loc))
	st.obs = c.observe
	for _, sg := range walkSegments(evs, dayEnd.UTC()) {
		st.advance(sg)
	}
	return c.result()
}

// FormManner reports the form & manner state of a log day (Q57): missing
// trailer or shipping document is a warning while the day is open and becomes a
// violation once the day has been certified.
func FormManner(hasTrailer, hasDoc, certified bool) []Violation {
	severity := SeverityWarning
	if certified {
		severity = SeverityViolation
	}
	out := make([]Violation, 0, 2)
	if !hasTrailer {
		out = append(out, Violation{Type: ViolationFormMannerTrailer, Severity: severity})
	}
	if !hasDoc {
		out = append(out, Violation{Type: ViolationFormMannerDoc, Severity: severity})
	}
	return out
}
