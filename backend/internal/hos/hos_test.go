package hos

import (
	"encoding/json"
	"os"
	"testing"
	"time"
)

type expectViolation struct {
	Type     string `json:"type"`
	Severity string `json:"severity"`
}

type vector struct {
	Name     string          `json:"name"`
	Policy   json.RawMessage `json:"policy"`
	Timezone string          `json:"timezone"`
	Now      time.Time       `json:"now"`
	Day      string          `json:"day"`
	Events   []Event         `json:"events"`
	Expect   struct {
		Counters   map[string]int    `json:"counters"`
		Totals     map[string]int    `json:"totals"`
		Violations []expectViolation `json:"violations"`
	} `json:"expect"`
}

type vectorFile struct {
	Version int      `json:"version"`
	Vectors []vector `json:"vectors"`
}

func loadVectors(t *testing.T) vectorFile {
	t.Helper()
	raw, err := os.ReadFile("testdata/hos-test-vectors.json")
	if err != nil {
		t.Fatalf("read vectors: %v", err)
	}
	var f vectorFile
	if err := json.Unmarshal(raw, &f); err != nil {
		t.Fatalf("parse vectors: %v", err)
	}
	if len(f.Vectors) < 32 {
		t.Fatalf("need at least 32 golden vectors, got %d", len(f.Vectors))
	}
	return f
}

func mins(d time.Duration) int { return int(d / time.Minute) }

// TestGoldenVectors is the contract shared with the Dart port (Q10.8).
func TestGoldenVectors(t *testing.T) {
	f := loadVectors(t)
	seen := map[string]bool{}
	for _, v := range f.Vectors {
		if seen[v.Name] {
			t.Fatalf("duplicate vector name %q", v.Name)
		}
		seen[v.Name] = true
		t.Run(v.Name, func(t *testing.T) {
			loc, err := time.LoadLocation(v.Timezone)
			if err != nil {
				t.Fatalf("timezone %q: %v", v.Timezone, err)
			}
			p, err := ParsePolicy(v.Policy)
			if err != nil {
				t.Fatalf("policy: %v", err)
			}
			day := v.Now
			if v.Day != "" {
				day, err = time.ParseInLocation("2006-01-02", v.Day, loc)
				if err != nil {
					t.Fatalf("day %q: %v", v.Day, err)
				}
			}
			before := len(v.Events)

			got, err := Compute(v.Events, p, v.Now, loc)
			if err != nil {
				t.Fatalf("Compute: %v", err)
			}
			checkInt(t, "break_left_min", mins(got.BreakLeft), v.Expect.Counters["break_left_min"])
			checkInt(t, "drive_left_min", mins(got.DriveLeft), v.Expect.Counters["drive_left_min"])
			checkInt(t, "shift_left_min", mins(got.ShiftLeft), v.Expect.Counters["shift_left_min"])
			checkInt(t, "cycle_left_min", mins(got.CycleLeft), v.Expect.Counters["cycle_left_min"])
			if want, ok := v.Expect.Counters["driving_time_left_min"]; ok {
				checkInt(t, "driving_time_left_min", mins(got.DrivingTimeLeft), want)
			}

			totals := DayTotalsWith(v.Events, p, day, loc)
			checkInt(t, "off_min", mins(totals.Off), v.Expect.Totals["off_min"])
			checkInt(t, "sb_min", mins(totals.SB), v.Expect.Totals["sb_min"])
			checkInt(t, "drive_min", mins(totals.Drive), v.Expect.Totals["drive_min"])
			checkInt(t, "on_min", mins(totals.On), v.Expect.Totals["on_min"])

			from, to := DayRange(day, loc)
			if want, got := to.Sub(from), totals.Total(); want != got {
				t.Errorf("totals sum to %v, log day is %v", got, want)
			}

			vio := Violations(v.Events, p, day, loc)
			if len(vio) != len(v.Expect.Violations) {
				t.Fatalf("violations = %v, want %v", vio, v.Expect.Violations)
			}
			for i, w := range v.Expect.Violations {
				if vio[i].Type != w.Type || vio[i].Severity != w.Severity {
					t.Errorf("violation[%d] = %s/%s, want %s/%s", i, vio[i].Type, vio[i].Severity, w.Type, w.Severity)
				}
				if vio[i].At.IsZero() {
					t.Errorf("violation[%d] has no timestamp", i)
				}
			}
			if len(v.Events) != before {
				t.Errorf("input slice was modified")
			}
		})
	}
}

func checkInt(t *testing.T, name string, got, want int) {
	t.Helper()
	if got != want {
		t.Errorf("%s = %d, want %d", name, got, want)
	}
}

func at(s string) time.Time {
	ts, err := time.Parse(time.RFC3339, s)
	if err != nil {
		panic(err)
	}
	return ts
}

func chicago(t *testing.T) *time.Location {
	t.Helper()
	loc, err := time.LoadLocation("America/Chicago")
	if err != nil {
		t.Fatalf("load location: %v", err)
	}
	return loc
}

// Q10.6
func TestSplitSleeper(t *testing.T) {
	p := DefaultPolicy()
	long7 := RestPeriod{Total: 7 * time.Hour, LongestSB: 7 * time.Hour}
	long8 := RestPeriod{Total: 8 * time.Hour, LongestSB: 8 * time.Hour}
	short3 := RestPeriod{Total: 3 * time.Hour}
	short2 := RestPeriod{Total: 2 * time.Hour}
	short1 := RestPeriod{Total: time.Hour}
	weak6 := RestPeriod{Total: 6 * time.Hour, LongestSB: 6 * time.Hour}

	cases := []struct {
		name string
		a, b RestPeriod
		p    Policy
		want bool
	}{
		{"7/3", long7, short3, p, true},
		{"3/7 order does not matter", short3, long7, p, true},
		{"8/2", long8, short2, p, true},
		{"7/2 too short in total", long7, short2, p, false},
		{"6/3 sleeper part too short", weak6, short3, p, false},
		{"8/1 partner too short", long8, short1, p, false},
		{"disabled by policy", long7, short3, withSplit(p, false), false},
		{"no sleeper berth", long7, short3, withBerth(p, false), false},
	}
	for _, c := range cases {
		if got := SplitPairQualifies(c.a, c.b, c.p); got != c.want {
			t.Errorf("%s: SplitPairQualifies = %v, want %v", c.name, got, c.want)
		}
	}

	// A qualifying 7/3 pair resets DRIVE like a daily rest.
	loc := chicago(t)
	events := []Event{
		{Time: at("2026-01-15T08:00:00Z"), Status: StatusDrive},
		{Time: at("2026-01-15T14:00:00Z"), Status: StatusSB},
		{Time: at("2026-01-15T21:00:00Z"), Status: StatusDrive},
		{Time: at("2026-01-16T01:00:00Z"), Status: StatusOff},
		{Time: at("2026-01-16T04:00:00Z"), Status: StatusOn},
	}
	c, err := Compute(events, DefaultPolicy(), at("2026-01-16T05:00:00Z"), loc)
	if err != nil {
		t.Fatalf("Compute: %v", err)
	}
	if mins(c.DriveLeft) != 660 {
		t.Errorf("drive left after 7/3 split = %d, want 660", mins(c.DriveLeft))
	}
	if mins(c.ShiftLeft) != 780 {
		t.Errorf("shift left after 7/3 split = %d, want 780", mins(c.ShiftLeft))
	}

	// The same pattern with a 6h sleeper part does not qualify.
	events[1].Time = at("2026-01-15T15:00:00Z")
	c, err = Compute(events, DefaultPolicy(), at("2026-01-16T05:00:00Z"), loc)
	if err != nil {
		t.Fatalf("Compute: %v", err)
	}
	if mins(c.DriveLeft) == 660 {
		t.Error("invalid 6/3 split must not reset the drive counter")
	}
}

func withSplit(p Policy, v bool) Policy { p.SleeperSplitEnabled = v; return p }
func withBerth(p Policy, v bool) Policy { p.SleeperBerthAvailable = v; return p }

// Q10.5
func TestCycleRestart(t *testing.T) {
	loc := chicago(t)
	events := []Event{
		{Time: at("2026-01-12T12:00:00Z"), Status: StatusDrive},
		{Time: at("2026-01-12T20:00:00Z"), Status: StatusOff},
		{Time: at("2026-01-14T06:00:00Z"), Status: StatusOn},
		{Time: at("2026-01-14T08:00:00Z"), Status: StatusOff},
	}
	used, err := CycleUsedAt(events, DefaultPolicy(), at("2026-01-14T08:00:00Z"), loc)
	if err != nil {
		t.Fatalf("CycleUsedAt: %v", err)
	}
	if mins(used) != 120 {
		t.Errorf("cycle used after 34h restart = %d, want 120", mins(used))
	}
	end, ok := LastRestartEnd(events, DefaultPolicy(), at("2026-01-14T08:00:00Z"), loc)
	if !ok || !end.Equal(at("2026-01-14T06:00:00Z")) {
		t.Errorf("LastRestartEnd = %v/%v, want 2026-01-14T06:00:00Z", end, ok)
	}

	// cycle_restart_min = null disables the restart.
	p := DefaultPolicy()
	p.CycleRestartMin = nil
	used, err = CycleUsedAt(events, p, at("2026-01-14T08:00:00Z"), loc)
	if err != nil {
		t.Fatalf("CycleUsedAt: %v", err)
	}
	if mins(used) != 600 {
		t.Errorf("cycle used without restart = %d, want 600", mins(used))
	}
	if _, ok := LastRestartEnd(events, p, at("2026-01-14T08:00:00Z"), loc); ok {
		t.Error("LastRestartEnd must report none when restart is disabled")
	}
}

// Q10.2
func TestDayBoundaryTZ(t *testing.T) {
	chi := chicago(t)
	kar, err := time.LoadLocation("Asia/Karachi")
	if err != nil {
		t.Fatalf("load location: %v", err)
	}
	cases := []struct {
		name    string
		loc     *time.Location
		day     time.Time
		start   string
		lengthM int
	}{
		{"chicago winter", chi, at("2026-01-15T12:00:00Z"), "2026-01-15T06:00:00Z", 1440},
		{"chicago dst start", chi, at("2026-03-08T12:00:00Z"), "2026-03-08T06:00:00Z", 1380},
		{"chicago dst end", chi, at("2026-11-01T12:00:00Z"), "2026-11-01T05:00:00Z", 1500},
		{"karachi", kar, at("2026-09-06T11:00:00Z"), "2026-09-05T19:00:00Z", 1440},
	}
	for _, c := range cases {
		from, to := DayRange(c.day, c.loc)
		if !from.Equal(at(c.start)) {
			t.Errorf("%s: day start = %v, want %v", c.name, from.UTC(), c.start)
		}
		if got := mins(to.Sub(from)); got != c.lengthM {
			t.Errorf("%s: day length = %d, want %d", c.name, got, c.lengthM)
		}
	}

	// The same UTC events land on different log days depending on the terminal TZ.
	events := []Event{
		{Time: at("2026-09-06T02:00:00Z"), Status: StatusOn},
		{Time: at("2026-09-06T03:00:00Z"), Status: StatusDrive},
		{Time: at("2026-09-06T11:00:00Z"), Status: StatusOff},
	}
	if got := mins(DayTotalsFor(events, at("2026-09-06T11:00:00Z"), kar).Drive); got != 480 {
		t.Errorf("karachi drive = %d, want 480", got)
	}
	if got := mins(DayTotalsFor(events, at("2026-09-06T11:00:00Z"), chi).Drive); got != 360 {
		t.Errorf("chicago drive = %d, want 360", got)
	}
}

// Q10.7
func TestRecap(t *testing.T) {
	loc := chicago(t)
	var events []Event
	for d := 8; d <= 15; d++ {
		events = append(events,
			Event{Time: time.Date(2026, 1, d, 13, 0, 0, 0, time.UTC), Status: StatusOn},
			Event{Time: time.Date(2026, 1, d, 23, 0, 0, 0, time.UTC), Status: StatusOff})
	}
	rows := Recap(events, DefaultPolicy(), at("2026-01-15T23:00:00Z"), loc)
	if len(rows) != 8 {
		t.Fatalf("recap rows = %d, want 8", len(rows))
	}
	if rows[0].Date != "2026-01-08" || rows[7].Date != "2026-01-15" {
		t.Fatalf("recap range = %s..%s", rows[0].Date, rows[7].Date)
	}
	if mins(rows[7].OnDuty) != 600 {
		t.Errorf("last day on duty = %d, want 600", mins(rows[7].OnDuty))
	}
	if mins(rows[0].Available) != 3600 {
		t.Errorf("first day available = %d, want 3600", mins(rows[0].Available))
	}
	if mins(rows[4].Available) != 1200 {
		t.Errorf("2026-01-12 available = %d, want 1200", mins(rows[4].Available))
	}
	if mins(rows[7].Available) != 0 {
		t.Errorf("last day available = %d, want 0", mins(rows[7].Available))
	}
	if mins(rows[7].GainedNext) != 600 {
		t.Errorf("hours returning tomorrow = %d, want 600", mins(rows[7].GainedNext))
	}
	if mins(rows[0].GainedNext) != 0 {
		t.Errorf("first day gained_next = %d, want 0", mins(rows[0].GainedNext))
	}
}

// Q57: form & manner
func TestFormManner(t *testing.T) {
	if got := FormManner(true, true, true); len(got) != 0 {
		t.Errorf("complete log must be clean, got %v", got)
	}
	open := FormManner(false, false, false)
	if len(open) != 2 || open[0].Severity != SeverityWarning || open[1].Severity != SeverityWarning {
		t.Fatalf("open day = %v, want two warnings", open)
	}
	if open[0].Type != ViolationFormMannerTrailer || open[1].Type != ViolationFormMannerDoc {
		t.Errorf("unexpected types %v", open)
	}
	certified := FormManner(true, false, true)
	if len(certified) != 1 || certified[0].Type != ViolationFormMannerDoc || certified[0].Severity != SeverityViolation {
		t.Errorf("certified day = %v, want doc violation", certified)
	}
}

// Q4.1, Q4.2, Q5
func TestSpecialModes(t *testing.T) {
	p := DefaultPolicy()
	if !ShouldStartDriving(8, p) || ShouldStartDriving(7.9, p) {
		t.Error("auto DR must start at motion_threshold_kmh")
	}
	if !ShouldExitYardMove(32.1, p) || ShouldExitYardMove(32, p) {
		t.Error("yard move must end above ym_max_speed_kmh")
	}
	if EffectiveStatus(StatusOff, SpecialPC) != StatusOff || CountsAsDriving(StatusOff, SpecialPC) {
		t.Error("PC must never count as driving")
	}
	if EffectiveStatus(StatusOn, SpecialYM) != StatusOn || CountsAsDriving(StatusOn, SpecialYM) {
		t.Error("YM must count as on duty, not driving")
	}
	if !CountsAsOnDuty(StatusOn, SpecialYM) {
		t.Error("YM must consume the shift window")
	}
	p.AllowPC = false
	if SpecialAllowed(SpecialPC, p) {
		t.Error("PC must follow allow_pc")
	}
}

func TestPolicyParsing(t *testing.T) {
	p, err := ParsePolicy([]byte(`{"drive_limit_min":600,"cycle_restart_min":null,"warning_thresholds":{"drive":15,"shift":30,"break":20,"cycle":60}}`))
	if err != nil {
		t.Fatalf("ParsePolicy: %v", err)
	}
	if p.DriveLimitMin != 600 {
		t.Errorf("drive_limit_min = %d", p.DriveLimitMin)
	}
	if p.CycleRestartMin != nil {
		t.Error("cycle_restart_min null must disable the restart")
	}
	if p.CycleLimitMin != 4200 || p.CycleDays != 8 {
		t.Error("missing keys must fall back to the defaults")
	}
	if p.WarningThresholds.DriveMin != 15 {
		t.Errorf("warning thresholds not parsed: %+v", p.WarningThresholds)
	}
	if _, err := ParsePolicy([]byte(`{`)); err == nil {
		t.Error("broken JSON must fail")
	}
}

func TestComputeRejectsUnknownStatus(t *testing.T) {
	events := []Event{{Time: at("2026-01-15T12:00:00Z"), Status: Status("XX")}}
	if _, err := Compute(events, DefaultPolicy(), at("2026-01-15T13:00:00Z"), time.UTC); err == nil {
		t.Error("unknown status must be rejected")
	}
	events = []Event{{Time: at("2026-01-15T12:00:00Z"), Status: StatusOn, Special: Special("teleport")}}
	if _, err := Compute(events, DefaultPolicy(), at("2026-01-15T13:00:00Z"), time.UTC); err == nil {
		t.Error("unknown special must be rejected")
	}
}

// Events arrive out of order after an offline sync; the input must not change.
func TestOutOfOrderEventsAreNotMutated(t *testing.T) {
	loc := chicago(t)
	events := []Event{
		{Time: at("2026-01-15T20:00:00Z"), Status: StatusOff},
		{Time: at("2026-01-15T12:00:00Z"), Status: StatusDrive},
		{Time: at("2026-01-14T22:00:00Z"), Status: StatusOff},
	}
	snapshot := append([]Event(nil), events...)
	got, err := Compute(events, DefaultPolicy(), at("2026-01-15T20:00:00Z"), loc)
	if err != nil {
		t.Fatalf("Compute: %v", err)
	}
	if mins(got.DriveLeft) != 180 {
		t.Errorf("drive left = %d, want 180", mins(got.DriveLeft))
	}
	for i := range events {
		if events[i] != snapshot[i] {
			t.Fatalf("input event %d was modified", i)
		}
	}
}
