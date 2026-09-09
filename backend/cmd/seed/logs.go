package main

import (
	"fmt"
	"time"

	"github.com/google/uuid"
)

// logDays is how many past days of duty status history every driver gets.
const logDays = 14

// segment is one duty status interval of the seeded day pattern, expressed in
// the driver's local wall clock.
type segment struct {
	hour, minute int
	status       string
	eventType    string
	note         string
}

// dayPattern is a compliant 11 hour driving day: pre-trip, two driving blocks
// split by the 30 minute break, post-trip and the daily rest.
var dayPattern = []segment{
	{0, 0, "OFF", "duty_status", "daily rest"},
	{6, 0, "ON", "duty_status", "PTI"},
	{6, 30, "DR", "duty_status", "departed terminal"},
	{11, 0, "OFF", "duty_status", "30 minute break"},
	{11, 30, "DR", "duty_status", "en route"},
	{16, 0, "ON", "duty_status", "post trip and paperwork"},
	{17, 0, "OFF", "duty_status", "off duty"},
}

// waypoints are the location texts the seeded events cycle through.
var waypoints = []struct {
	text string
	lat  float64
	lng  float64
}{
	{"3 mi N of Chicago, IL", 41.9200, -87.6500},
	{"7 mi SW of Joliet, IL", 41.4900, -88.1200},
	{"4 mi S of Bloomington, IL", 40.4300, -88.9900},
	{"2 mi E of Springfield, IL", 39.7900, -89.6200},
	{"5 mi W of St. Louis, MO", 38.6100, -90.2600},
	{"6 mi N of Springfield, MO", 37.2800, -93.2800},
	{"3 mi S of Tulsa, OK", 36.1100, -95.9400},
	{"4 mi N of Dallas, TX", 32.8500, -96.8000},
}

// seedLogs writes daily_logs, duty_status_events, violations, unidentified
// driving blocks and the propose/approve edit queue for one tenant.
func (s *seeder) seedLogs(t tenantSpec) {
	companyID := sid("company", t.Key)
	loc := mustLocation(t.Timezone)
	s.exec(`SET LOCAL app.company_id = ` + quoteLiteral(companyID.String()))

	for di, d := range t.Drivers {
		if di >= len(t.Units) {
			break
		}
		unit := t.Units[di]
		for back := logDays; back >= 0; back-- {
			s.seedLogDay(t, companyID, loc, di, d, unit, back)
		}
	}

	s.seedUnidentified(t, companyID)
	s.seedViolations(t, companyID, loc)
	s.seedEditRequests(t, companyID, loc)
}

// seedLogDay writes one driver day: the log header, its duty status events and
// the certification of every day that is already closed.
func (s *seeder) seedLogDay(
	t tenantSpec, companyID uuid.UUID, loc *time.Location,
	driverIndex int, d driverSpec, unit unitSpec, back int,
) {
	day := dayStart(s.now, loc, -back)
	logID := sid("daily_log", t.Key, d.Username, day.Format("2006-01-02"))
	drvID := driverID(t.Key, d.Username)
	unitRef := unitID(t.Key, unit.Number)

	cut := day.AddDate(0, 0, 1)
	if back == 0 {
		cut = s.now
	}

	totals, distance := dayTotals(day, cut)
	totalsJSON, err := jsonBytes(totals)
	if err != nil {
		s.err = err
		return
	}

	// The last two days stay open so the certification queue is not empty.
	certification, signedAt, signedBy := "certified", any(at(day, 20, 0)), any(userID(t.Key, d.Username))
	if back <= 1 {
		certification, signedAt, signedBy = "uncertified", nil, nil
	}
	if back == 3 && driverIndex == 0 {
		certification, signedAt, signedBy = "needs_recertify", nil, nil
	}

	trailers := uuidStrings(sid("trailer", t.Key, t.Trailers[driverIndex%len(t.Trailers)]))
	docs := uuidStrings(sid("shipping_document", t.Key, t.ShippingDocs[driverIndex%len(t.ShippingDocs)]))

	var coDriver any
	if len(t.Drivers) >= 2 && driverIndex == len(t.Drivers)-1 {
		coDriver = driverID(t.Key, t.Drivers[len(t.Drivers)-2].Username)
	}

	s.exec(`
		INSERT INTO daily_logs (id, company_id, driver_id, log_date, timezone, unit_ids, co_driver_id,
		                        distance_m, trailer_ids, shipping_doc_ids, totals,
		                        certification_status, signed_at, signature_key, signed_device_id, signed_by, signed_ip)
		VALUES ($1,$2,$3,$4::date,$5,$6::uuid[],$7,$8,$9::uuid[],$10::uuid[],$11::jsonb,$12,$13,$14,$15,$16,$17::inet)
		ON CONFLICT (id) DO UPDATE SET
		  totals = EXCLUDED.totals, distance_m = EXCLUDED.distance_m,
		  certification_status = EXCLUDED.certification_status, signed_at = EXCLUDED.signed_at`,
		logID, companyID, drvID, day.Format("2006-01-02"), t.Timezone,
		uuidStrings(unitRef), coDriver, distance, trailers, docs, totalsJSON,
		certification, signedAt, signatureKeyFor(certification, t.Key, d.Username),
		deviceIDFor(certification, d.Username), signedBy, ipFor(certification))

	s.seedDayEvents(t, companyID, logID, drvID, unitRef, driverIndex, day, cut)
}

// signatureKeyFor returns the stored signature of a certified day.
func signatureKeyFor(certification, tenantKey, username string) any {
	if certification != "certified" {
		return nil
	}
	return fmt.Sprintf("signatures/%s/%s.png", tenantKey, username)
}

// deviceIDFor returns the device that signed a certified day.
func deviceIDFor(certification, username string) any {
	if certification != "certified" {
		return nil
	}
	return "phone-" + username
}

// ipFor returns the address a certification was signed from.
func ipFor(certification string) any {
	if certification != "certified" {
		return nil
	}
	return "203.0.113.42"
}

// dayTotals walks the day pattern up to cut and returns the per status minutes
// together with the distance driven, in metres.
func dayTotals(day, cut time.Time) (map[string]int, int64) {
	totals := map[string]int{"off": 0, "sb": 0, "dr": 0, "on": 0}
	end := day.AddDate(0, 0, 1)
	if cut.Before(end) {
		end = cut
	}
	for i, seg := range dayPattern {
		from := at(day, seg.hour, seg.minute)
		if !from.Before(end) {
			break
		}
		to := end
		if i+1 < len(dayPattern) {
			if next := at(day, dayPattern[i+1].hour, dayPattern[i+1].minute); next.Before(to) {
				to = next
			}
		}
		minutes := int(to.Sub(from) / time.Minute)
		switch seg.status {
		case "OFF":
			totals["off"] += minutes
		case "SB":
			totals["sb"] += minutes
		case "DR":
			totals["dr"] += minutes
		case "ON":
			totals["on"] += minutes
		}
	}
	// 90 km/h average over the driving minutes.
	return totals, int64(totals["dr"]) * 1500
}

// seedDayEvents writes the ELD event stream of one log day: login, engine on,
// the duty status changes, engine off and logout.
func (s *seeder) seedDayEvents(
	t tenantSpec, companyID, logID, drvID, unitRef uuid.UUID,
	driverIndex int, day, cut time.Time,
) {
	device := s.deviceForUnit(t, driverIndex)
	odometerBase := int64(180_000_000 + driverIndex*23_000_000)
	engineBase := 4200.0 + float64(driverIndex)*310

	type row struct {
		at        time.Time
		eventType string
		status    any
		note      string
	}
	rows := []row{{at(day, 5, 55), "login", nil, "driver signed in"}}
	rows = append(rows, row{at(day, 5, 58), "engine_on", nil, "ignition on"})
	for _, seg := range dayPattern {
		rows = append(rows, row{at(day, seg.hour, seg.minute), seg.eventType, seg.status, seg.note})
	}
	rows = append(rows,
		row{at(day, 17, 2), "engine_off", nil, "ignition off"},
		row{at(day, 17, 5), "logout", nil, "driver signed out"})

	for i, r := range rows {
		if !r.at.Before(cut) {
			break
		}
		wp := waypoints[(driverIndex+i)%len(waypoints)]
		odometer := odometerBase + int64(i)*12_000
		clientEvent := sid("duty_event", t.Key, logID.String(), fmt.Sprint(i))

		s.exec(`
			INSERT INTO duty_status_events (id, company_id, driver_id, unit_id, eld_device_id, event_type,
			                                status, special, event_time, time_source, origin,
			                                lat, lng, location_text, gps_accuracy_m, odometer_m, engine_hours,
			                                notes, client_event_id, device_seq, daily_log_id, locked)
			VALUES ($1,$2,$3,$4,$5,$6,$7,'none',$8,'eld_rtc','auto',$9,$10,$11,$12,$13,$14::numeric,$15,$16,$17,$18,$19)
			ON CONFLICT (id) DO UPDATE SET
			  event_time = EXCLUDED.event_time, status = EXCLUDED.status,
			  odometer_m = EXCLUDED.odometer_m, daily_log_id = EXCLUDED.daily_log_id`,
			clientEvent, companyID, drvID, unitRef, device, r.eventType, r.status,
			r.at, wp.lat, wp.lng, wp.text, 8, odometer,
			engineBase+float64(i)*0.4, r.note, clientEvent, int64(i+1), logID,
			!cut.After(s.now.AddDate(0, 0, -1)))
	}
}

// deviceForUnit returns the ELD device bound to the driver's unit, or nil when
// the fleet has fewer devices than drivers.
func (s *seeder) deviceForUnit(t tenantSpec, driverIndex int) any {
	devices := len(t.Drivers)
	if devices > len(t.Units) {
		devices = len(t.Units)
	}
	if driverIndex >= devices {
		return nil
	}
	serial := fmt.Sprintf("ELD-%s-%04d", upperKey(t.Key), driverIndex+1)
	return sid("eld_device", t.Key, serial)
}
