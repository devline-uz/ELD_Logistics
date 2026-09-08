package hos

import "time"

// CycleWindowStart is local midnight of the first day of the rolling cycle
// window that ends on at's log day: cycle_days days including today (Q10.5).
func CycleWindowStart(at time.Time, p Policy, loc *time.Location) time.Time {
	p = p.normalized()
	return StartOfDay(at, loc).AddDate(0, 0, -(p.CycleDays - 1))
}

// CycleUsedAt returns the ON+DR total inside the cycle window at instant at.
// A continuous OFF/SB of cycle_restart_min resets it to zero (Q10.5).
func CycleUsedAt(events []Event, p Policy, at time.Time, loc *time.Location) (time.Duration, error) {
	p = p.normalized()
	if loc == nil {
		loc = time.UTC
	}
	evs, err := sortedEvents(events, p)
	if err != nil {
		return 0, err
	}
	return cycleUsedBetween(evs, p, CycleWindowStart(at, p, loc), at), nil
}

// cycleUsedBetween replays the events up to until with an explicit window start.
func cycleUsedBetween(evs []Event, p Policy, cycleFrom, until time.Time) time.Duration {
	st := newState(p, cycleFrom)
	for _, sg := range walkSegments(evs, until.UTC()) {
		st.advance(sg)
	}
	return st.cycleUsed
}

// LastRestartEnd returns the end of the last completed cycle restart before at
// (continuous OFF/SB of cycle_restart_min). ok is false when there is none or
// when the policy disables restarts (Q10.5).
func LastRestartEnd(events []Event, p Policy, at time.Time, loc *time.Location) (time.Time, bool) {
	p = p.normalized()
	restart, enabled := p.restartLen()
	if !enabled {
		return time.Time{}, false
	}
	evs, err := sortedEvents(events, p)
	if err != nil {
		return time.Time{}, false
	}
	var (
		runStart time.Time
		running  bool
		found    time.Time
		ok       bool
	)
	for _, sg := range walkSegments(evs, at.UTC()) {
		if sg.isRest() {
			if !running {
				running, runStart = true, sg.start
			}
			if sg.end.Sub(runStart) >= restart {
				found, ok = sg.end, true
			}
			continue
		}
		running = false
	}
	return found, ok
}

// RecapDay is one row of the cycle recap table (Q10.7).
type RecapDay struct {
	Date       string        `json:"date"`
	OnDuty     time.Duration `json:"on_duty"`     // ON+DR logged that day
	Available  time.Duration `json:"available"`   // cycle_limit - used at end of that day
	GainedNext time.Duration `json:"gained_next"` // hours coming back the next day
}

// Recap returns cycle_days rows ending on day, oldest first (Q10.7).
// available[d] = cycle_limit - sum(ON+DR of the cycle window ending on d);
// gained_next[d] = ON+DR of the day that drops out of the window tomorrow,
// i.e. the day (cycle_days-1) days before d.
func Recap(events []Event, p Policy, day time.Time, loc *time.Location) []RecapDay {
	p = p.normalized()
	if loc == nil {
		loc = time.UTC
	}
	evs, err := sortedEvents(events, p)
	if err != nil {
		return nil
	}
	last := StartOfDay(day, loc)
	rows := make([]RecapDay, 0, p.CycleDays)
	for i := p.CycleDays - 1; i >= 0; i-- {
		d := last.AddDate(0, 0, -i)
		_, end := DayRange(d, loc)
		totals := DayTotalsWith(events, p, d, loc)
		used := cycleUsedBetween(evs, p, CycleWindowStart(d, p, loc), end)
		dropped := DayTotalsWith(events, p, d.AddDate(0, 0, -(p.CycleDays-1)), loc)
		rows = append(rows, RecapDay{
			Date:       DayKey(d, loc),
			OnDuty:     totals.On + totals.Drive,
			Available:  clamp(p.cycleLimit() - used),
			GainedNext: dropped.On + dropped.Drive,
		})
	}
	return rows
}
