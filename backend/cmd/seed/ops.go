package main

import (
	"fmt"
	"time"

	"github.com/google/uuid"
)

// seedOps writes the dispatch and communication side of the tenant: routes,
// the notification inbox, the driver chat threads, support tickets, feedback,
// finished report exports and a short audit trail.
func (s *seeder) seedOps(t tenantSpec) {
	companyID := sid("company", t.Key)
	s.exec(`SET LOCAL app.company_id = ` + quoteLiteral(companyID.String()))

	s.seedRoutes(t, companyID)
	s.seedNotifications(t, companyID)
	s.seedChat(t, companyID)
	s.seedSupport(t, companyID)
	s.seedReportJobs(t, companyID)
	s.seedAuditTrail(t, companyID)
}

// seedRoutes gives every driver one ongoing route plus the completed and the
// abandoned run behind it.
func (s *seeder) seedRoutes(t tenantSpec, companyID uuid.UUID) {
	dispatcher, ok := accountByRole(t, roleDispatcher)
	if !ok {
		dispatcher, ok = accountByRole(t, roleFleetManager)
	}
	if !ok {
		dispatcher, _ = accountByRole(t, roleAdministrator)
	}
	createdBy := userID(t.Key, dispatcher)

	for i, d := range t.Drivers {
		if i >= len(t.Units) {
			break
		}
		unit := unitID(t.Key, t.Units[i].Number)
		from := waypoints[i%len(waypoints)]
		to := waypoints[(i+3)%len(waypoints)]

		plans := []struct {
			key      string
			sequence int
			status   string
			daysBack int
		}{
			{"current", 1, "ongoing", 0},
			{"done", 2, "completed", 2},
			{"failed", 3, "not_completed", 4},
		}

		for _, p := range plans {
			started := s.now.AddDate(0, 0, -p.daysBack).Add(-6 * time.Hour)

			var completedAt, reason, note, notCompletedBy, entered any
			switch p.status {
			case "completed":
				completedAt = started.Add(9 * time.Hour)
				entered = started.Add(8*time.Hour + 40*time.Minute)
			case "not_completed":
				completedAt = started.Add(4 * time.Hour)
				reason = "breakdown"
				note = "coolant leak, unit towed to the Dallas terminal"
				notCompletedBy = createdBy
			}

			s.exec(`
				INSERT INTO routes (id, company_id, unit_id, driver_id, sequence, origin_text, origin_lat,
				                    origin_lng, dest_text, dest_lat, dest_lng, geofence_m, status,
				                    created_by, started_at, completed_at, not_completed_reason,
				                    not_completed_note, not_completed_by, geofence_entered_at, note, polyline_key)
				VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,300,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21)
				ON CONFLICT (id) DO UPDATE SET
				  status = EXCLUDED.status, completed_at = EXCLUDED.completed_at,
				  not_completed_reason = EXCLUDED.not_completed_reason, deleted_at = NULL`,
				sid("route", t.Key, d.Username, p.key), companyID, unit,
				driverID(t.Key, d.Username), p.sequence,
				from.text, from.lat, from.lng, to.text, to.lat, to.lng,
				p.status, createdBy, started, completedAt, reason, note, notCompletedBy, entered,
				"seeded demo route", fmt.Sprintf("polylines/%s/%s-%s.json", t.Key, d.Username, p.key))
		}
	}
}

// notificationSpec is one seeded inbox row.
type notificationSpec struct {
	role, alertType, title, body, entityType string
	channels                                 []string
	minutesAgo                               int
	read                                     bool
}

// seededNotifications covers the alert types the dashboard groups by.
var seededNotifications = []notificationSpec{
	{roleSafetyManager, "hos_violation", "11 hour driving limit exceeded", "James Carter drove past the 11 hour limit.", "violation", []string{"push", "email"}, 95, false},
	{roleSafetyManager, "uncertified_log", "2 log days are uncertified", "Two drivers have not certified yesterday's log.", "daily_log", []string{"push"}, 240, false},
	{roleFleetManager, "eld_malfunction", "ELD reports a malfunction", "A device reported malfunction codes P and E.", "eld_device", []string{"push", "email"}, 55, false},
	{roleFleetManager, "maintenance_overdue", "Oil Change overdue", "One unit is past its Oil Change interval.", "maintenance_schedule", []string{"push", "email"}, 610, true},
	{roleServiceMgr, "dvir_critical", "Critical DVIR defect", "Tires reported below tread limit on a post trip inspection.", "dvir_report", []string{"push", "email", "sms"}, 780, false},
	{roleDispatcher, "route_completed", "Route completed", "A route reached its destination geofence.", "route", []string{"push"}, 130, true},
	{roleAdministrator, "unidentified_driving", "Unassigned driving detected", "38 minutes of unassigned driving on a unit.", "unidentified_event", []string{"push", "email"}, 300, false},
	{roleAdministrator, "subscription_expiring", "Subscription renews soon", "The current plan renews in 30 days.", "company", []string{"email"}, 1440, true},
}

// seedNotifications fills the office inbox and gives every driver the chat and
// route alerts the mobile app shows.
func (s *seeder) seedNotifications(t tenantSpec, companyID uuid.UUID) {
	for i, n := range seededNotifications {
		username, ok := accountByRole(t, n.role)
		if !ok {
			continue
		}
		var readAt any
		if n.read {
			readAt = s.now.Add(-time.Duration(n.minutesAgo/2) * time.Minute)
		}
		created := s.now.Add(-time.Duration(n.minutesAgo) * time.Minute)

		s.exec(`
			INSERT INTO notifications (id, company_id, user_id, alert_type, title, body, entity_type,
			                           channels, sent_at, delivered_at, read_at, created_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8::text[],$9,$10,$11,$12)
			ON CONFLICT (id) DO UPDATE SET read_at = EXCLUDED.read_at, body = EXCLUDED.body`,
			sid("notification", t.Key, n.role, fmt.Sprint(i)), companyID,
			userID(t.Key, username), n.alertType, n.title, n.body, n.entityType,
			n.channels, created, created.Add(2*time.Second), readAt, created)
	}

	for i, d := range t.Drivers {
		created := s.now.Add(-time.Duration(20+i*17) * time.Minute)
		s.exec(`
			INSERT INTO notifications (id, company_id, user_id, alert_type, title, body, entity_type,
			                           channels, sent_at, delivered_at, created_at)
			VALUES ($1,$2,$3,'route_assigned','New route assigned',$4,'route',$5::text[],$6,$6,$6)
			ON CONFLICT (id) DO NOTHING`,
			sid("notification_driver", t.Key, d.Username), companyID,
			userID(t.Key, d.Username),
			"Dispatch assigned you a new route. Open the app for the details.",
			[]string{"push"}, created)
	}
}

// chatScript is the dispatcher/driver exchange every thread is seeded with.
var chatScript = []struct {
	fromDispatcher bool
	text           string
}{
	{true, "Good morning, your load is ready at dock 4."},
	{false, "Copy that, doing the pre-trip now."},
	{true, "Bill of lading is BOL-90001, take trailer TR-201."},
	{false, "Hooked and rolling, ETA 15:40."},
	{true, "Thanks, watch for construction on I-55 southbound."},
}

// seedChat writes one dispatcher/driver thread per driver.
func (s *seeder) seedChat(t tenantSpec, companyID uuid.UUID) {
	dispatcher, ok := accountByRole(t, roleDispatcher)
	if !ok {
		dispatcher, ok = accountByRole(t, roleFleetManager)
	}
	if !ok {
		return
	}
	office := userID(t.Key, dispatcher)

	for i, d := range t.Drivers {
		for j, m := range chatScript {
			sender := office
			if !m.fromDispatcher {
				sender = userID(t.Key, d.Username)
			}
			sentAt := s.now.Add(-time.Duration(200-j*20+i*7) * time.Minute)

			// The last inbound message of the first thread stays unread so the
			// unread counter is not zero everywhere.
			var readAt any
			if !(i == 0 && j == len(chatScript)-1) {
				readAt = sentAt.Add(90 * time.Second)
			}

			s.exec(`
				INSERT INTO chat_messages (id, company_id, driver_id, sender_id, kind, text,
				                           sent_at, delivered_at, read_at)
				VALUES ($1,$2,$3,$4,'text',$5,$6,$7,$8)
				ON CONFLICT (id) DO UPDATE SET text = EXCLUDED.text, read_at = EXCLUDED.read_at`,
				sid("chat", t.Key, d.Username, fmt.Sprint(j)), companyID,
				driverID(t.Key, d.Username), sender, m.text,
				sentAt, sentAt.Add(3*time.Second), readAt)
		}
	}
}

// seedSupport writes the support desk: three tickets in different states, each
// with a short message thread, plus the app feedback drivers left.
func (s *seeder) seedSupport(t tenantSpec, companyID uuid.UUID) {
	admin, ok := accountByRole(t, roleAdministrator)
	if !ok {
		return
	}
	agent := userID(t.Key, admin)

	tickets := []struct {
		key, subject, description, status string
		driverIndex                       int
		hoursAgo                          int
	}{
		{"eld-pairing", "ELD will not pair over Bluetooth", "The tablet does not find the device after a restart.", "new", 0, 6},
		{"log-edit", "Cannot certify yesterday's log", "Certify button stays disabled on the mobile app.", "in_progress", 1, 30},
		{"fuel-report", "Fuel report shows the wrong region", "Miles driven in Missouri appear under Illinois.", "resolved", 2, 96},
	}

	for _, tk := range tickets {
		if tk.driverIndex >= len(t.Drivers) {
			continue
		}
		d := t.Drivers[tk.driverIndex]
		created := s.now.Add(-time.Duration(tk.hoursAgo) * time.Hour)
		ticketID := sid("ticket", t.Key, tk.key)

		var resolvedAt any
		if tk.status == "resolved" {
			resolvedAt = created.Add(20 * time.Hour)
		}

		s.exec(`
			INSERT INTO support_tickets (id, company_id, driver_id, created_by, subject, description,
			                             contact_on, status, resolved_at, created_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
			ON CONFLICT (id) DO UPDATE SET
			  status = EXCLUDED.status, resolved_at = EXCLUDED.resolved_at, deleted_at = NULL`,
			ticketID, companyID, driverID(t.Key, d.Username), userID(t.Key, d.Username),
			tk.subject, tk.description, d.Phone, tk.status, resolvedAt, created)

		messages := []struct {
			fromDriver bool
			text       string
		}{
			{true, tk.description},
			{false, "Thanks for the report, we are looking into it."},
		}
		for j, m := range messages {
			sender := agent
			if m.fromDriver {
				sender = userID(t.Key, d.Username)
			}
			s.exec(`
				INSERT INTO ticket_messages (id, company_id, ticket_id, sender_id, text, created_at)
				VALUES ($1,$2,$3,$4,$5,$6)
				ON CONFLICT (id) DO UPDATE SET text = EXCLUDED.text`,
				sid("ticket_message", t.Key, tk.key, fmt.Sprint(j)), companyID, ticketID,
				sender, m.text, created.Add(time.Duration(j*35)*time.Minute))
		}
	}

	// One filler ticket per remaining driver so the support desk pages
	// through a realistic count instead of just the three curated cases.
	for i, d := range t.Drivers {
		if i < len(tickets) {
			continue
		}
		fs := fillerTicketSubjects[i%len(fillerTicketSubjects)]
		status := fillerTicketStatuses[i%len(fillerTicketStatuses)]
		created := s.now.Add(-time.Duration(200+i*13) * time.Hour)
		ticketID := sid("ticket_filler", t.Key, d.Username)

		var resolvedAt any
		if status == "resolved" {
			resolvedAt = created.Add(20 * time.Hour)
		}
		s.exec(`
			INSERT INTO support_tickets (id, company_id, driver_id, created_by, subject, description,
			                             contact_on, status, resolved_at, created_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
			ON CONFLICT (id) DO UPDATE SET
			  status = EXCLUDED.status, resolved_at = EXCLUDED.resolved_at, deleted_at = NULL`,
			ticketID, companyID, driverID(t.Key, d.Username), userID(t.Key, d.Username),
			fs.subject, fs.description, d.Phone, status, resolvedAt, created)
		s.exec(`
			INSERT INTO ticket_messages (id, company_id, ticket_id, sender_id, text, created_at)
			VALUES ($1,$2,$3,$4,$5,$6)
			ON CONFLICT (id) DO UPDATE SET text = EXCLUDED.text`,
			sid("ticket_message_filler", t.Key, d.Username), companyID, ticketID,
			userID(t.Key, d.Username), fs.description, created)
	}

	ratings := []struct {
		rating int
		text   string
	}{
		{5, "Certification flow is quick, logs sync even with a weak signal."},
		{4, "Would like the DVIR photo upload to retry on its own."},
		{3, "Map is slow to load on an older tablet."},
		{5, "Chat with dispatch works well."},
		{4, "Route assignment notifications are clear."},
		{2, "App logs me out too often on a spotty connection."},
	}
	for i, d := range t.Drivers {
		f := ratings[i%len(ratings)]
		submitted := s.now.AddDate(0, 0, -(i%28 + 1))
		s.exec(`
			INSERT INTO feedback (id, company_id, driver_id, app_rating, text, submitted_at, created_at)
			VALUES ($1,$2,$3,$4,$5,$6,$6)
			ON CONFLICT (id) DO UPDATE SET app_rating = EXCLUDED.app_rating, text = EXCLUDED.text`,
			sid("feedback", t.Key, fmt.Sprint(i)), companyID,
			driverID(t.Key, d.Username), f.rating, f.text, submitted)
	}
}

// fillerTicketSubjects cycles over generic support requests the filler
// tickets above are given, on top of the three curated scenarios.
var fillerTicketSubjects = []struct{ subject, description string }{
	{"App crashes on log certification", "The app closes when I tap certify."},
	{"GPS position looks wrong", "The map shows me far from my actual location."},
	{"Push notifications delayed", "Route alerts arrive up to an hour late."},
	{"Chat message not delivered", "Dispatch says they never got my message."},
	{"DVIR photo upload fails", "Photo upload spins forever on a weak signal."},
	{"PIN reset needed", "Forgot my PIN after the app update."},
	{"Odometer mismatch", "Trip odometer does not match the dash."},
	{"Sync stuck", "Yesterday's log will not sync to the office."},
	{"Trailer not in list", "The new trailer is missing from the picker."},
	{"Signature will not save", "The signature pad clears itself before saving."},
}

var fillerTicketStatuses = []string{"new", "in_progress", "resolved"}

// fillerReportKinds cycles the export types and formats the report history
// screen is padded out with, beyond the two curated jobs below.
var fillerReportKinds = []struct{ kind, format, contentType string }{
	{"hos_summary", "pdf", "application/pdf"},
	{"distance_by_region", "xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"},
	{"dvir_summary", "csv", "text/csv"},
	{"violations_summary", "csv", "text/csv"},
	{"fuel_tax", "xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"},
	{"uncertified_logs", "pdf", "application/pdf"},
}

// reportJobFillerCount is how many generated exports are added on top of the
// two curated ones, so the report history screen pages through a realistic
// count instead of a couple of rows.
const reportJobFillerCount = 60

// seedReportJobs writes the finished report exports so the downloads list is
// not empty: two curated jobs plus a generated run history.
func (s *seeder) seedReportJobs(t tenantSpec, companyID uuid.UUID) {
	analyst, ok := accountByRole(t, roleDataAnalyst)
	if !ok {
		analyst, ok = accountByRole(t, roleAdministrator)
	}
	if !ok {
		return
	}
	requestedBy := userID(t.Key, analyst)

	jobs := []struct {
		key, kind, format, fileName, contentType string
		hoursAgo                                 int
	}{
		{"hos-summary", "hos_summary", "xlsx", "hos-summary.xlsx",
			"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", 5},
		{"distance-region", "distance_by_region", "csv", "distance-by-region.csv", "text/csv", 26},
	}
	for i := 0; i < reportJobFillerCount; i++ {
		k := fillerReportKinds[i%len(fillerReportKinds)]
		jobs = append(jobs, struct {
			key, kind, format, fileName, contentType string
			hoursAgo                                 int
		}{
			fmt.Sprintf("filler-%d", i), k.kind, k.format,
			fmt.Sprintf("%s-%d.%s", k.kind, i, k.format), k.contentType, 30 + i*9,
		})
	}

	for _, j := range jobs {
		started := s.now.Add(-time.Duration(j.hoursAgo) * time.Hour)
		params, err := jsonBytes(map[string]any{
			"from": s.now.AddDate(0, 0, -7).Format("2006-01-02"),
			"to":   s.now.Format("2006-01-02"),
		})
		if err != nil {
			s.err = err
			return
		}
		s.exec(`
			INSERT INTO report_export_jobs (id, company_id, requested_by, type, format, params, status,
			                                file_key, file_name, file_size_b, content_type,
			                                started_at, finished_at, expires_at, created_at)
			VALUES ($1,$2,$3,$4,$5,$6::jsonb,'done',$7,$8,$9,$10,$11,$12,$13,$11)
			ON CONFLICT (id) DO UPDATE SET status = 'done', expires_at = EXCLUDED.expires_at`,
			sid("report_job", t.Key, j.key), companyID, requestedBy, j.kind, j.format, params,
			fmt.Sprintf("exports/%s/%s.%s", t.Key, j.key, j.format), j.fileName,
			int64(184_320), j.contentType, started, started.Add(40*time.Second),
			started.AddDate(0, 0, 7))
	}
}

// seedAuditTrail writes a short, realistic audit history so the audit screen
// and its filters have data. audit_log is append only, so the rows are written
// once and never rewritten.
func (s *seeder) seedAuditTrail(t tenantSpec, companyID uuid.UUID) {
	admin, ok := accountByRole(t, roleAdministrator)
	if !ok {
		return
	}

	entries := []struct {
		key, table, action, field, oldValue, newValue, actor, reason string
		hoursAgo                                                     int
	}{
		{"company-create", "companies", "create", "name", "", t.Name, admin, "company provisioned", 3600},
		{"admin-login", "users", "login", "status", "", "active", admin, "", 3},
		{"driver-activate", "drivers", "activate", "status", "invited", "active", admin, "onboarding complete", 720},
		{"policy-change", "hos_policy_versions", "hos_policy_change", "cycle_limit_min", "3600", "4200", admin, "switched to the 70/8 cycle", 500},
		{"export", "report_export_jobs", "export", "type", "", "hos_summary", admin, "monthly reporting", 5},
		{"permission-change", "role_permissions", "permission_change", "permission_key", "", "reports.export", admin, "analyst needs exports", 400},
	}

	for _, e := range entries {
		oldValue, err := auditValue(e.oldValue)
		if err != nil {
			s.err = err
			return
		}
		newValue, err := auditValue(e.newValue)
		if err != nil {
			s.err = err
			return
		}
		var reason any
		if e.reason != "" {
			reason = e.reason
		}
		s.exec(`
			INSERT INTO audit_log (id, company_id, table_name, record_id, field, old_value, new_value,
			                       action, edited_by, ip, user_agent, reason, ts)
			VALUES ($1,$2,$3,$4,$5,$6::jsonb,$7::jsonb,$8,$9,$10::inet,$11,$12,$13)
			ON CONFLICT (id) DO NOTHING`,
			sid("audit", t.Key, e.key), companyID, e.table, companyID, e.field,
			oldValue, newValue, e.action, userID(t.Key, e.actor),
			"203.0.113.42", "Mozilla/5.0 (seed)", reason,
			s.now.Add(-time.Duration(e.hoursAgo)*time.Hour))
	}

	// One activation entry per driver, mirroring the real onboarding audit
	// trail, so the audit screen pages through a realistic history instead
	// of the half dozen curated milestones above.
	for i, d := range t.Drivers {
		oldValue, err := auditValue("invited")
		if err != nil {
			s.err = err
			return
		}
		newValue, err := auditValue("active")
		if err != nil {
			s.err = err
			return
		}
		s.exec(`
			INSERT INTO audit_log (id, company_id, table_name, record_id, field, old_value, new_value,
			                       action, edited_by, ip, user_agent, reason, ts)
			VALUES ($1,$2,$3,$4,$5,$6::jsonb,$7::jsonb,$8,$9,$10::inet,$11,$12,$13)
			ON CONFLICT (id) DO NOTHING`,
			sid("audit_driver_activate", t.Key, d.Username), companyID, "drivers",
			driverID(t.Key, d.Username), "status", oldValue, newValue, "activate",
			userID(t.Key, admin), "203.0.113.42", "Mozilla/5.0 (seed)", "onboarding complete",
			s.now.Add(-time.Duration(750+i*3)*time.Hour))
	}
}

// auditValue encodes an audit column value, keeping NULL for an absent one.
func auditValue(v string) (any, error) {
	if v == "" {
		return nil, nil
	}
	return jsonBytes(v)
}
