package main

import (
	"fmt"
	"time"

	"github.com/google/uuid"
)

// violationSpec is one seeded warning/violation attached to a driver day.
type violationSpec struct {
	driverIndex  int
	daysBack     int
	kind         string
	severity     string
	hour         int
	limitMin     int64
	remainingMin int64
	note         string
	resolved     bool
}

// seededViolations covers the catalogue the HOS engine can raise, so the
// violations screen and the dashboard counters have every shape in them.
var seededViolations = []violationSpec{
	{0, 3, "drive_limit", "violation", 18, 660, 0, "driving beyond the 11 hour limit", false},
	{1, 4, "break_required", "warning", 14, 480, 25, "8 hours of driving without a 30 minute break", true},
	{2, 2, "shift_limit", "violation", 21, 840, 0, "on duty beyond the 14 hour window", false},
	{3, 5, "cycle_limit", "warning", 16, 4200, 95, "approaching the 70 hour cycle limit", false},
	{4, 1, "uncertified_log", "warning", 9, 0, 0, "log day is still uncertified", false},
	{5, 6, "form_manner_trailer", "warning", 8, 0, 0, "trailer number missing on the log day", true},
}

// violationKindCatalog keeps the limit/remaining figures generated filler
// violations report consistent with the kind they claim.
var violationKindCatalog = []struct {
	kind, severity, note   string
	limitMin, remainingMin int64
}{
	{"drive_limit", "violation", "driving beyond the 11 hour limit", 660, 0},
	{"break_required", "warning", "8 hours of driving without a 30 minute break", 480, 25},
	{"shift_limit", "violation", "on duty beyond the 14 hour window", 840, 0},
	{"cycle_limit", "warning", "approaching the 70 hour cycle limit", 4200, 95},
	{"uncertified_log", "warning", "log day is still uncertified", 0, 0},
	{"form_manner_trailer", "warning", "trailer number missing on the log day", 0, 0},
}

// fillerViolations spreads the catalogue above across the rest of the fleet
// so the violations screen and its filters page through a realistic count
// instead of just the six hand-picked scenarios in seededViolations.
func fillerViolations(t tenantSpec) []violationSpec {
	limit := len(t.Drivers)
	if len(t.Units) < limit {
		limit = len(t.Units)
	}
	var out []violationSpec
	for i := len(seededViolations); i < limit; i++ {
		k := violationKindCatalog[i%len(violationKindCatalog)]
		out = append(out, violationSpec{
			driverIndex: i, daysBack: 1 + i%(logDays-1), kind: k.kind, severity: k.severity,
			hour: 6 + i%14, limitMin: k.limitMin, remainingMin: k.remainingMin,
			note: k.note, resolved: i%3 == 0,
		})
	}
	return out
}

// seedViolations writes the violation rows for one tenant.
func (s *seeder) seedViolations(t tenantSpec, companyID uuid.UUID, loc *time.Location) {
	policy := sid("hos_policy", t.Key)

	for _, v := range append(append([]violationSpec{}, seededViolations...), fillerViolations(t)...) {
		if v.driverIndex >= len(t.Drivers) || v.driverIndex >= len(t.Units) {
			continue
		}
		d := t.Drivers[v.driverIndex]
		day := dayStart(s.now, loc, -v.daysBack)
		logID := sid("daily_log", t.Key, d.Username, day.Format("2006-01-02"))

		detail, err := jsonBytes(map[string]any{
			"limit_min": v.limitMin, "remaining_min": v.remainingMin, "note": v.note,
		})
		if err != nil {
			s.err = err
			return
		}

		var resolvedAt, resolvedReason, resolvedBy any
		if v.resolved {
			resolvedAt = at(day, v.hour+2, 0)
			resolvedReason = "daily rest completed"
			if username, ok := accountByRole(t, roleSafetyManager); ok {
				resolvedBy = userID(t.Key, username)
			}
		}

		s.exec(`
			INSERT INTO violations (id, company_id, driver_id, unit_id, daily_log_id, type, severity,
			                        occurred_at, details, policy_version_id, resolved_at, resolved_reason, resolved_by)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9::jsonb,$10,$11,$12,$13)
			ON CONFLICT (id) DO UPDATE SET
			  severity = EXCLUDED.severity, details = EXCLUDED.details,
			  resolved_at = EXCLUDED.resolved_at, resolved_reason = EXCLUDED.resolved_reason`,
			sid("violation", t.Key, d.Username, v.kind, fmt.Sprint(v.daysBack)), companyID,
			driverID(t.Key, d.Username), unitID(t.Key, t.Units[v.driverIndex].Number), logID,
			v.kind, v.severity, at(day, v.hour, 0), detail, policy,
			resolvedAt, resolvedReason, resolvedBy)
	}
}

// seedUnidentified writes unassigned driving blocks on the units that carry no
// driver assignment, plus the open `unidentified_driving` violation each one
// raises (§10.4).
func (s *seeder) seedUnidentified(t tenantSpec, companyID uuid.UUID) {
	free := len(t.Units) - len(t.Drivers)
	if free <= 0 {
		return
	}
	loc := mustLocation(t.Timezone)

	for i := 0; i < free; i++ {
		unit := t.Units[len(t.Drivers)+i]
		day := dayStart(s.now, loc, -(i + 1))
		start := at(day, 19, 10)
		end := at(day, 19, 48)
		eventID := sid("unidentified", t.Key, unit.Number, day.Format("2006-01-02"))

		s.exec(`
			INSERT INTO unidentified_events (id, company_id, unit_id, eld_device_id, start_at, end_at,
			                                 distance_m, track_key, status)
			VALUES ($1,$2,$3,NULL,$4,$5,$6,$7,'pending')
			ON CONFLICT (id) DO UPDATE SET
			  end_at = EXCLUDED.end_at, distance_m = EXCLUDED.distance_m`,
			eventID, companyID, unitID(t.Key, unit.Number), start, end, 41_000,
			fmt.Sprintf("tracks/%s/%s.json", t.Key, unit.Number))

		detail, err := jsonBytes(map[string]any{
			"limit_min": 0, "remaining_min": 0,
			"note": "unassigned driving recorded by the ELD",
		})
		if err != nil {
			s.err = err
			return
		}
		s.exec(`
			INSERT INTO violations (id, company_id, driver_id, unit_id, daily_log_id, type, severity,
			                        occurred_at, details, unidentified_event_id)
			VALUES ($1,$2,NULL,$3,NULL,'unidentified_driving','warning',$4,$5::jsonb,$6)
			ON CONFLICT (id) DO UPDATE SET details = EXCLUDED.details`,
			sid("violation_unidentified", t.Key, unit.Number, day.Format("2006-01-02")),
			companyID, unitID(t.Key, unit.Number), start, detail, eventID)
	}
}

// seedEditRequests fills the propose/approve queue with one pending, one
// approved and one rejected admin edit.
func (s *seeder) seedEditRequests(t tenantSpec, companyID uuid.UUID, loc *time.Location) {
	safety, ok := accountByRole(t, roleSafetyManager)
	if !ok {
		safety, ok = accountByRole(t, roleAdministrator)
	}
	if !ok {
		return
	}
	requestedBy := userID(t.Key, safety)

	cases := []struct {
		driverIndex int
		daysBack    int
		status      string
		driverNote  string
	}{
		{0, 2, "pending", ""},
		{1, 3, "approved", ""},
		{2, 4, "rejected", "that block was my co-driver, not me"},
	}

	for _, c := range cases {
		if c.driverIndex >= len(t.Drivers) {
			continue
		}
		d := t.Drivers[c.driverIndex]
		day := dayStart(s.now, loc, -c.daysBack)
		logID := sid("daily_log", t.Key, d.Username, day.Format("2006-01-02"))

		changes, err := jsonBytes([]map[string]any{{
			"from":    at(day, 16, 0),
			"to":      at(day, 17, 0),
			"status":  "ON",
			"special": "none",
			"note":    "loading at the dock, the driver forgot to switch",
		}})
		if err != nil {
			s.err = err
			return
		}

		var resolvedAt, resolvedBy, driverNote any
		if c.status != "pending" {
			resolvedAt = at(day, 20, 30)
			resolvedBy = userID(t.Key, d.Username)
		}
		if c.driverNote != "" {
			driverNote = c.driverNote
		}

		s.exec(`
			INSERT INTO log_edit_requests (id, company_id, driver_id, daily_log_id, requested_by,
			                               status, changes, driver_note, resolved_by, resolved_at, source)
			VALUES ($1,$2,$3,$4,$5,$6,$7::jsonb,$8,$9,$10,'admin_edit')
			ON CONFLICT (id) DO UPDATE SET
			  status = EXCLUDED.status, changes = EXCLUDED.changes,
			  resolved_at = EXCLUDED.resolved_at, resolved_by = EXCLUDED.resolved_by`,
			sid("log_edit", t.Key, d.Username, day.Format("2006-01-02")), companyID,
			driverID(t.Key, d.Username), logID, requestedBy, c.status, changes,
			driverNote, resolvedBy, resolvedAt)
	}
}
