// Package hos implements the Hours of Service engine (TZ A§3, A§4, A§12).
//
// The package is pure: stdlib only, no DB/HTTP, no global state and it never
// calls time.Now — the evaluation instant is always a parameter. The same
// algorithm is ported to Dart and both implementations must pass
// testdata/hos-test-vectors.json (Q10.8).
package hos

import (
	"encoding/json"
	"errors"
	"time"
)

// Q4: duty statuses. DR is never selected manually, it is produced by motion.
type Status string

const (
	StatusOff   Status = "OFF"
	StatusSB    Status = "SB"
	StatusDrive Status = "DR"
	StatusOn    Status = "ON"
)

// Valid reports whether s is a known duty status.
func (s Status) Valid() bool {
	return s == StatusOff || s == StatusSB || s == StatusDrive || s == StatusOn
}

// Q4.1/Q4.2: special modes layered on OFF (PC) and ON (YM).
type Special string

const (
	SpecialNone Special = "none"
	SpecialPC   Special = "pc"
	SpecialYM   Special = "ym"
)

// Valid reports whether sp is a known special mode. Empty means none.
func (sp Special) Valid() bool {
	return sp == "" || sp == SpecialNone || sp == SpecialPC || sp == SpecialYM
}

// EventType mirrors the eld event kinds. Only status changes move the duty
// state machine; the other kinds are positional/administrative (Q5.2).
type EventType string

const (
	EventStatusChange  EventType = "status_change"
	EventIntermediate  EventType = "intermediate"
	EventLogin         EventType = "login"
	EventLogout        EventType = "logout"
	EventPowerUp       EventType = "power_up"
	EventPowerDown     EventType = "power_down"
	EventCertification EventType = "certification"
	EventTrailerChange EventType = "trailer_change"
	EventDocChange     EventType = "doc_change"
)

// Event is one duty-status record. Time is always UTC (TZ B§6.1 rule 7).
type Event struct {
	Time    time.Time `json:"time"`
	Status  Status    `json:"status"`
	Special Special   `json:"special,omitempty"`
	Type    EventType `json:"type,omitempty"`
}

// affectsDuty reports whether the event changes the duty state machine.
func (e Event) affectsDuty() bool {
	if e.Status == "" {
		return false
	}
	return e.Type == "" || e.Type == EventStatusChange
}

// WarningThresholds are the "remaining minutes" levels for warnings (Q57.1).
type WarningThresholds struct {
	DriveMin int `json:"drive"`
	ShiftMin int `json:"shift"`
	BreakMin int `json:"break"`
	CycleMin int `json:"cycle"`
}

// Policy is one hos_policy_versions.policy document. All durations are minutes.
type Policy struct {
	DriveLimitMin              int               `json:"drive_limit_min"`
	ShiftWindowMin             int               `json:"shift_window_min"`
	BreakRequiredAfterDriveMin int               `json:"break_required_after_drive_min"`
	BreakDurationMin           int               `json:"break_duration_min"`
	BreakQualifyingStatuses    []Status          `json:"break_qualifying_statuses"`
	DailyRestMin               int               `json:"daily_rest_min"`
	CycleLimitMin              int               `json:"cycle_limit_min"`
	CycleDays                  int               `json:"cycle_days"`
	CycleRestartMin            *int              `json:"cycle_restart_min"`
	SleeperSplitEnabled        bool              `json:"sleeper_split_enabled"`
	SleeperBerthAvailable      bool              `json:"sleeper_berth_available"`
	AllowPC                    bool              `json:"allow_pc"`
	AllowYM                    bool              `json:"allow_ym"`
	YMMaxSpeedKmh              float64           `json:"ym_max_speed_kmh"`
	MotionThresholdKmh         float64           `json:"motion_threshold_kmh"`
	ShortHaulException         bool              `json:"short_haul_exception"`
	AdverseConditionsExtMin    int               `json:"adverse_conditions_extension_min"`
	WarningThresholds          WarningThresholds `json:"warning_thresholds"`
}

// Split pairing constants (Q10.6): 7/3 and 8/2 combinations.
const (
	SplitMinSleeperMin = 420 // long part must be >= 7h of SB
	SplitMinPartnerMin = 120 // short part must be >= 2h of OFF/SB
)

// DefaultPolicy returns the FMCSA 70/8 defaults (TZ A§4.2).
func DefaultPolicy() Policy {
	restart := 2040
	return Policy{
		DriveLimitMin:              660,
		ShiftWindowMin:             840,
		BreakRequiredAfterDriveMin: 480,
		BreakDurationMin:           30,
		BreakQualifyingStatuses:    []Status{StatusOff, StatusSB, StatusOn},
		DailyRestMin:               600,
		CycleLimitMin:              4200,
		CycleDays:                  8,
		CycleRestartMin:            &restart,
		SleeperSplitEnabled:        true,
		SleeperBerthAvailable:      true,
		AllowPC:                    true,
		AllowYM:                    true,
		YMMaxSpeedKmh:              32,
		MotionThresholdKmh:         8,
		ShortHaulException:         false,
		AdverseConditionsExtMin:    120,
		WarningThresholds:          WarningThresholds{DriveMin: 30, ShiftMin: 60, BreakMin: 30, CycleMin: 120},
	}
}

// ParsePolicy decodes a hos_policy_versions.policy JSONB document on top of the
// defaults, so partial documents keep the default values (Q10.1).
func ParsePolicy(data []byte) (Policy, error) {
	p := DefaultPolicy()
	if len(data) == 0 {
		return p, nil
	}
	if err := json.Unmarshal(data, &p); err != nil {
		return DefaultPolicy(), err
	}
	return p.normalized(), nil
}

// normalized fills in unusable zero values with the defaults.
func (p Policy) normalized() Policy {
	d := DefaultPolicy()
	if p.DriveLimitMin <= 0 {
		p.DriveLimitMin = d.DriveLimitMin
	}
	if p.ShiftWindowMin <= 0 {
		p.ShiftWindowMin = d.ShiftWindowMin
	}
	if p.BreakRequiredAfterDriveMin <= 0 {
		p.BreakRequiredAfterDriveMin = d.BreakRequiredAfterDriveMin
	}
	if p.BreakDurationMin <= 0 {
		p.BreakDurationMin = d.BreakDurationMin
	}
	if len(p.BreakQualifyingStatuses) == 0 {
		p.BreakQualifyingStatuses = d.BreakQualifyingStatuses
	}
	if p.DailyRestMin <= 0 {
		p.DailyRestMin = d.DailyRestMin
	}
	if p.CycleLimitMin <= 0 {
		p.CycleLimitMin = d.CycleLimitMin
	}
	if p.CycleDays <= 0 {
		p.CycleDays = d.CycleDays
	}
	return p
}

// breakQualifies reports whether the effective status counts toward a break (Q10.4).
func (p Policy) breakQualifies(s Status) bool {
	for _, q := range p.BreakQualifyingStatuses {
		if q == s {
			return true
		}
	}
	return false
}

func (p Policy) driveLimit() time.Duration  { return minutes(p.DriveLimitMin) }
func (p Policy) shiftWindow() time.Duration { return minutes(p.ShiftWindowMin) }
func (p Policy) breakAfter() time.Duration  { return minutes(p.BreakRequiredAfterDriveMin) }
func (p Policy) breakLen() time.Duration    { return minutes(p.BreakDurationMin) }
func (p Policy) dailyRest() time.Duration   { return minutes(p.DailyRestMin) }
func (p Policy) cycleLimit() time.Duration  { return minutes(p.CycleLimitMin) }

// restartLen returns the 34h restart length; ok is false when restart is disabled.
func (p Policy) restartLen() (time.Duration, bool) {
	if p.CycleRestartMin == nil || *p.CycleRestartMin <= 0 {
		return 0, false
	}
	return minutes(*p.CycleRestartMin), true
}

func minutes(m int) time.Duration { return time.Duration(m) * time.Minute }

// Counters are the remaining times shown by the driver app (TZ A§4.1).
type Counters struct {
	BreakLeft       time.Duration `json:"break_left"`
	DriveLeft       time.Duration `json:"drive_left"`
	ShiftLeft       time.Duration `json:"shift_left"`
	CycleLeft       time.Duration `json:"cycle_left"`
	DrivingTimeLeft time.Duration `json:"driving_time_left"` // Q10.9
}

// DayTotals are the four duty-line totals of one log day (Q10.2).
type DayTotals struct {
	Off   time.Duration `json:"off"`
	SB    time.Duration `json:"sb"`
	Drive time.Duration `json:"drive"`
	On    time.Duration `json:"on"`
}

// Total returns the length of the log day (23h/25h on DST days).
func (t DayTotals) Total() time.Duration { return t.Off + t.SB + t.Drive + t.On }

// Violation types (Q57).
const (
	ViolationDriveLimit        = "drive_limit"
	ViolationShiftLimit        = "shift_limit"
	ViolationBreakRequired     = "break_required"
	ViolationCycleLimit        = "cycle_limit"
	ViolationFormMannerTrailer = "form_manner_trailer"
	ViolationFormMannerDoc     = "form_manner_doc"
)

// Severity levels (Q57).
const (
	SeverityWarning   = "warning"
	SeverityViolation = "violation"
)

// Violation is one warning/violation occurrence. Violations are never deleted,
// they are closed with resolved_at at the storage layer (Q58).
type Violation struct {
	Type     string    `json:"type"`
	Severity string    `json:"severity"`
	At       time.Time `json:"at"`
}

// Engine errors.
var (
	ErrUnknownStatus  = errors.New("hos: unknown duty status")
	ErrUnknownSpecial = errors.New("hos: unknown special mode")
)
