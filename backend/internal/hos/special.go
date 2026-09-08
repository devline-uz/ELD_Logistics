package hos

// EffectiveStatus maps a raw status plus special mode to the status used by the
// HOS math. Q4.1: PC movement is OFF, not DR. Q4.2: YM is ON.
func EffectiveStatus(s Status, sp Special) Status {
	switch sp {
	case SpecialPC:
		return StatusOff
	case SpecialYM:
		return StatusOn
	}
	return s
}

// CountsAsDriving reports whether the segment consumes the DRIVE counter.
// Q4.1: PC does not. Q4.2: YM does not (it only consumes SHIFT).
func CountsAsDriving(s Status, sp Special) bool {
	return EffectiveStatus(s, sp) == StatusDrive
}

// CountsAsOnDuty reports whether the segment consumes SHIFT and CYCLE (Q10.5).
func CountsAsOnDuty(s Status, sp Special) bool {
	e := EffectiveStatus(s, sp)
	return e == StatusOn || e == StatusDrive
}

// ShouldStartDriving is the auto-DR rule: ECM (or GPS fallback) speed at or
// above motion_threshold_kmh starts driving (Q5).
func ShouldStartDriving(speedKmh float64, p Policy) bool {
	return speedKmh >= p.MotionThresholdKmh
}

// ShouldExitYardMove reports whether yard move must end and switch to DR
// because speed exceeded ym_max_speed_kmh (Q4.2).
func ShouldExitYardMove(speedKmh float64, p Policy) bool {
	return speedKmh > p.YMMaxSpeedKmh
}

// SpecialAllowed reports whether the company policy allows the special mode (Q4).
func SpecialAllowed(sp Special, p Policy) bool {
	switch sp {
	case SpecialPC:
		return p.AllowPC
	case SpecialYM:
		return p.AllowYM
	}
	return true
}

// normalizeStatus applies unit capability rules. Q4.3: without a sleeper berth
// SB cannot be selected, so such records are treated as OFF. Disallowed special
// modes fall back to the plain status.
func normalizeStatus(s Status, sp Special, p Policy) (Status, Special) {
	if sp == "" {
		sp = SpecialNone
	}
	if !SpecialAllowed(sp, p) {
		sp = SpecialNone
	}
	if s == StatusSB && !p.SleeperBerthAvailable {
		s = StatusOff
	}
	return s, sp
}
