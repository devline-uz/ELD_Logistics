package hos

import "time"

// StartOfDay returns local midnight of t's calendar day (Q10.2). Events are
// stored in UTC, the log day is always the home terminal 00:00-24:00 window.
func StartOfDay(t time.Time, loc *time.Location) time.Time {
	if loc == nil {
		loc = time.UTC
	}
	lt := t.In(loc)
	return time.Date(lt.Year(), lt.Month(), lt.Day(), 0, 0, 0, 0, loc)
}

// DayRange returns [start, end) of the log day containing day. On DST days the
// range is 23h or 25h long, which is intentional (Q10.2).
func DayRange(day time.Time, loc *time.Location) (time.Time, time.Time) {
	start := StartOfDay(day, loc)
	return start, StartOfDay(start.AddDate(0, 0, 1), loc)
}

// DayKey formats the log day as YYYY-MM-DD in loc.
func DayKey(day time.Time, loc *time.Location) string {
	return StartOfDay(day, loc).Format("2006-01-02")
}

// daySegments covers [from,to) completely. The status before the first known
// event is assumed OFF, and the status open at from (or at to) is carried on.
func daySegments(evs []Event, from, to time.Time) []segment {
	st, sp := StatusOff, SpecialNone
	i := 0
	for ; i < len(evs) && !evs[i].Time.After(from); i++ {
		st, sp = evs[i].Status, evs[i].Special
	}
	segs := make([]segment, 0, len(evs)+1)
	cur := segment{start: from, status: EffectiveStatus(st, sp), raw: st, special: sp}
	for ; i < len(evs) && evs[i].Time.Before(to); i++ {
		e := evs[i]
		if e.Time.After(cur.start) {
			cur.end = e.Time
			segs = append(segs, cur)
		}
		cur = segment{start: e.Time, status: EffectiveStatus(e.Status, e.Special), raw: e.Status, special: e.Special}
	}
	cur.end = to
	if cur.end.After(cur.start) {
		segs = append(segs, cur)
	}
	return segs
}

// DayTotalsFor sums the four duty lines of one log day using the default policy.
func DayTotalsFor(events []Event, day time.Time, loc *time.Location) DayTotals {
	return DayTotalsWith(events, DefaultPolicy(), day, loc)
}

// DayTotalsWith sums the four duty lines of one log day (Q10.2). PC time lands
// on the OFF line and YM time on the ON line (Q4.1, Q4.2). A status that is
// still open at midnight continues into the next day.
func DayTotalsWith(events []Event, p Policy, day time.Time, loc *time.Location) DayTotals {
	p = p.normalized()
	if loc == nil {
		loc = time.UTC
	}
	evs, err := sortedEvents(events, p)
	if err != nil {
		return DayTotals{}
	}
	from, to := DayRange(day, loc)
	var t DayTotals
	for _, sg := range daySegments(evs, from.UTC(), to.UTC()) {
		d := sg.dur()
		switch sg.status {
		case StatusOff:
			t.Off += d
		case StatusSB:
			t.SB += d
		case StatusDrive:
			t.Drive += d
		case StatusOn:
			t.On += d
		}
	}
	return t
}
