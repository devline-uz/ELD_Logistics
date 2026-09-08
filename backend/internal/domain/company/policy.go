package company

import (
	"strconv"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/company/dto"
	"github.com/devline/onebook-eld/internal/hos"
)

// Sane bounds for a hos_policy document. They are deliberately wider than the
// FMCSA defaults so a non US regulation profile can still be expressed, but
// tight enough that a typo cannot disable the compliance engine (Q10.1).
const (
	minDriveLimitMin  = 60
	maxDriveLimitMin  = 1440
	minShiftWindowMin = 60
	maxShiftWindowMin = 1440
	minBreakAfterMin  = 30
	maxBreakAfterMin  = 1440
	minBreakLenMin    = 5
	maxBreakLenMin    = 480
	minDailyRestMin   = 60
	maxDailyRestMin   = 1440
	minCycleLimitMin  = 600
	maxCycleLimitMin  = 20160
	minCycleDays      = 1
	maxCycleDays      = 14
	maxCycleRestart   = 10080
	maxYMSpeedKmh     = 80
	maxMotionKmh      = 50
	maxAdverseExtMin  = 480
	maxWarningMin     = 1440
)

// mergeDriveWindowFields layers the drive/shift/break keys of a partial
// request onto the policy.
func mergeDriveWindowFields(p *hos.Policy, in dto.HosPolicyDocInput) {
	if in.DriveLimitMin != nil {
		p.DriveLimitMin = *in.DriveLimitMin
	}
	if in.ShiftWindowMin != nil {
		p.ShiftWindowMin = *in.ShiftWindowMin
	}
	if in.BreakRequiredAfterDriveMin != nil {
		p.BreakRequiredAfterDriveMin = *in.BreakRequiredAfterDriveMin
	}
	if in.BreakDurationMin != nil {
		p.BreakDurationMin = *in.BreakDurationMin
	}
	if in.BreakQualifyingStatuses != nil {
		statuses := make([]hos.Status, 0, len(in.BreakQualifyingStatuses))
		for _, s := range in.BreakQualifyingStatuses {
			statuses = append(statuses, hos.Status(s))
		}
		p.BreakQualifyingStatuses = statuses
	}
	if in.DailyRestMin != nil {
		p.DailyRestMin = *in.DailyRestMin
	}
}

// mergeCycleAndModeFields layers the cycle/sleeper/PC-YM keys of a partial
// request onto the policy.
func mergeCycleAndModeFields(p *hos.Policy, in dto.HosPolicyDocInput) {
	if in.CycleLimitMin != nil {
		p.CycleLimitMin = *in.CycleLimitMin
	}
	if in.CycleDays != nil {
		p.CycleDays = *in.CycleDays
	}
	if in.CycleRestartMin != nil {
		// 0 disables the 34h restart entirely (Q10.5).
		if *in.CycleRestartMin == 0 {
			p.CycleRestartMin = nil
		} else {
			v := *in.CycleRestartMin
			p.CycleRestartMin = &v
		}
	}
	if in.SleeperSplitEnabled != nil {
		p.SleeperSplitEnabled = *in.SleeperSplitEnabled
	}
	if in.SleeperBerthAvailable != nil {
		p.SleeperBerthAvailable = *in.SleeperBerthAvailable
	}
	if in.AllowPC != nil {
		p.AllowPC = *in.AllowPC
	}
	if in.AllowYM != nil {
		p.AllowYM = *in.AllowYM
	}
	if in.YMMaxSpeedKmh != nil {
		p.YMMaxSpeedKmh = *in.YMMaxSpeedKmh
	}
	if in.MotionThresholdKmh != nil {
		p.MotionThresholdKmh = *in.MotionThresholdKmh
	}
	if in.ShortHaulException != nil {
		p.ShortHaulException = *in.ShortHaulException
	}
	if in.AdverseConditionsExtMin != nil {
		p.AdverseConditionsExtMin = *in.AdverseConditionsExtMin
	}
}

// mergeWarningThresholds layers the optional warning threshold overrides of a
// partial request onto the policy.
func mergeWarningThresholds(p *hos.Policy, in dto.HosPolicyDocInput) {
	w := in.WarningThresholds
	if w == nil {
		return
	}
	if w.Drive != nil {
		p.WarningThresholds.DriveMin = *w.Drive
	}
	if w.Shift != nil {
		p.WarningThresholds.ShiftMin = *w.Shift
	}
	if w.Break != nil {
		p.WarningThresholds.BreakMin = *w.Break
	}
	if w.Cycle != nil {
		p.WarningThresholds.CycleMin = *w.Cycle
	}
}

// mergePolicy layers the partial request on top of the currently effective
// document, so a PATCH-like body never resets an unrelated key.
func mergePolicy(base hos.Policy, in dto.HosPolicyDocInput) hos.Policy {
	p := base
	mergeDriveWindowFields(&p, in)
	mergeCycleAndModeFields(&p, in)
	mergeWarningThresholds(&p, in)
	return p
}

// validatePolicy enforces the per key bounds plus the cross field rules the
// HOS engine relies on. It returns a 422 carrying one detail per bad key.
func validatePolicy(p hos.Policy) error {
	var details []apierr.FieldError
	add := func(field, msg string) {
		details = append(details, apierr.FieldError{Field: "policy." + field, Message: msg})
	}
	between := func(field string, v, lo, hi int) {
		if v < lo || v > hi {
			add(field, rangeMessage(lo, hi))
		}
	}

	between("drive_limit_min", p.DriveLimitMin, minDriveLimitMin, maxDriveLimitMin)
	between("shift_window_min", p.ShiftWindowMin, minShiftWindowMin, maxShiftWindowMin)
	between("break_required_after_drive_min", p.BreakRequiredAfterDriveMin, minBreakAfterMin, maxBreakAfterMin)
	between("break_duration_min", p.BreakDurationMin, minBreakLenMin, maxBreakLenMin)
	between("daily_rest_min", p.DailyRestMin, minDailyRestMin, maxDailyRestMin)
	between("cycle_limit_min", p.CycleLimitMin, minCycleLimitMin, maxCycleLimitMin)
	between("cycle_days", p.CycleDays, minCycleDays, maxCycleDays)
	between("adverse_conditions_extension_min", p.AdverseConditionsExtMin, 0, maxAdverseExtMin)
	between("warning_thresholds.drive", p.WarningThresholds.DriveMin, 0, maxWarningMin)
	between("warning_thresholds.shift", p.WarningThresholds.ShiftMin, 0, maxWarningMin)
	between("warning_thresholds.break", p.WarningThresholds.BreakMin, 0, maxWarningMin)
	between("warning_thresholds.cycle", p.WarningThresholds.CycleMin, 0, maxWarningMin)

	if p.CycleRestartMin != nil && (*p.CycleRestartMin < 0 || *p.CycleRestartMin > maxCycleRestart) {
		add("cycle_restart_min", rangeMessage(0, maxCycleRestart))
	}
	if p.YMMaxSpeedKmh < 0 || p.YMMaxSpeedKmh > maxYMSpeedKmh {
		add("ym_max_speed_kmh", rangeMessage(0, maxYMSpeedKmh))
	}
	if p.MotionThresholdKmh < 0 || p.MotionThresholdKmh > maxMotionKmh {
		add("motion_threshold_kmh", rangeMessage(0, maxMotionKmh))
	}

	if len(p.BreakQualifyingStatuses) == 0 {
		add("break_qualifying_statuses", "must contain at least one duty status")
	}
	seen := map[hos.Status]bool{}
	for _, s := range p.BreakQualifyingStatuses {
		if !s.Valid() {
			add("break_qualifying_statuses", "must be one of: OFF, SB, ON, DR")
			break
		}
		if seen[s] {
			add("break_qualifying_statuses", "must not contain duplicates")
			break
		}
		seen[s] = true
	}
	if seen[hos.StatusDrive] {
		add("break_qualifying_statuses", "DR can never qualify as a break")
	}

	// Cross field rules (Q10.3, Q10.4).
	if p.DriveLimitMin > p.ShiftWindowMin {
		add("drive_limit_min", "must not exceed shift_window_min")
	}
	if p.BreakRequiredAfterDriveMin > p.DriveLimitMin {
		add("break_required_after_drive_min", "must not exceed drive_limit_min")
	}
	if p.DailyRestMin+p.ShiftWindowMin > 24*60 {
		add("daily_rest_min", "daily_rest_min + shift_window_min must not exceed 1440")
	}
	if p.CycleLimitMin > p.CycleDays*24*60 {
		add("cycle_limit_min", "must not exceed cycle_days * 1440")
	}

	if len(details) > 0 {
		return apierr.Validation("hos policy is not valid", details...)
	}
	return nil
}

func rangeMessage(lo, hi int) string {
	return "must be between " + strconv.Itoa(lo) + " and " + strconv.Itoa(hi)
}
