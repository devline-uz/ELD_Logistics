package hos

import "time"

// RestPeriod is one continuous run of OFF/SB segments (PC counts as OFF).
type RestPeriod struct {
	Start     time.Time     `json:"start"`
	End       time.Time     `json:"end"`
	Total     time.Duration `json:"total"`
	LongestSB time.Duration `json:"longest_sb"` // longest uninterrupted SB run inside
}

// IsDailyRest reports whether the rest alone resets SHIFT and DRIVE (Q10.3).
func (r RestPeriod) IsDailyRest(p Policy) bool { return r.Total >= p.dailyRest() }

// splitEnabled reports whether sleeper split may be applied at all (Q4.3, Q10.6).
func splitEnabled(p Policy) bool { return p.SleeperSplitEnabled && p.SleeperBerthAvailable }

// IsSplitLong reports whether the rest can act as the long part of a sleeper
// split: at least 7h of uninterrupted sleeper berth (Q10.6).
func IsSplitLong(r RestPeriod, p Policy) bool {
	if !splitEnabled(p) {
		return false
	}
	return r.LongestSB >= minutes(SplitMinSleeperMin)
}

// IsSplitShort reports whether the rest can act as the short part: at least 2h
// of OFF/SB but less than a full daily rest (Q10.6).
func IsSplitShort(r RestPeriod, p Policy) bool {
	if !splitEnabled(p) {
		return false
	}
	return r.Total >= minutes(SplitMinPartnerMin) && r.Total < p.dailyRest()
}

// SplitPairQualifies reports whether two rest periods together are equivalent to
// a daily rest: total >= daily_rest_min, one part >= 7h SB, the other >= 2h.
// This covers the 7/3 and 8/2 combinations (Q10.6). Order does not matter.
func SplitPairQualifies(a, b RestPeriod, p Policy) bool {
	if !splitEnabled(p) {
		return false
	}
	if a.Total < minutes(SplitMinPartnerMin) || b.Total < minutes(SplitMinPartnerMin) {
		return false
	}
	if a.Total+b.Total < p.dailyRest() {
		return false
	}
	return a.LongestSB >= minutes(SplitMinSleeperMin) || b.LongestSB >= minutes(SplitMinSleeperMin)
}
