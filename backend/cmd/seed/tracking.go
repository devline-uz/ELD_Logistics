package main

import (
	"fmt"
	"math"
	"time"

	"github.com/google/uuid"
)

// Telemetry shape: how far back the seeded track reaches and how often the ELD
// reported inside it.
const (
	telemetryHours    = 24
	telemetryInterval = 5 * time.Minute

	// historyDays is how many past days of closed trips and region distance
	// every unit gets.
	historyDays = 7

	// telemetryTrackUnits caps how many units get a full sampled telemetry
	// track. The rest still get a unit_last_state row (so the fleet map and
	// unit list are never empty), just without a dense recent history — the
	// same way a real fleet has units that are not currently reporting.
	telemetryTrackUnits = 40
)

// seedTracking writes the raw telemetry track, the live state of every unit,
// the closed trips behind it and the per region distance the IFTA style report
// reads.
func (s *seeder) seedTracking(t tenantSpec) {
	companyID := sid("company", t.Key)
	s.exec(`SET LOCAL app.company_id = ` + quoteLiteral(companyID.String()))

	// Telemetry timestamps follow the current clock, so a re-run replaces the
	// tenant's track instead of interleaving two of them.
	s.exec(`DELETE FROM telemetry WHERE company_id = $1`, companyID)

	for i, u := range t.Units {
		s.seedUnitTrack(t, companyID, i, u)
	}
	s.seedTrips(t, companyID)
	s.seedRegionDistance(t, companyID)
}

// seedUnitTrack writes one unit's telemetry samples and its last known state.
func (s *seeder) seedUnitTrack(t tenantSpec, companyID uuid.UUID, index int, u unitSpec) {
	unitRef := unitID(t.Key, u.Number)

	var driver any
	if index < len(t.Drivers) {
		driver = driverID(t.Key, t.Drivers[index].Username)
	}
	device := s.deviceForUnit(t, index)

	odometer := int64(180_000_000 + index*23_000_000)
	engineHours := 4200.0 + float64(index)*310

	// The route walks south west from the unit's first waypoint.
	base := waypoints[index%len(waypoints)]
	lat, lng := base.lat, base.lng

	lastTS := s.now
	var lastSpeed float64
	lastHeading := 214.0

	if index < telemetryTrackUnits {
		start := s.now.Add(-telemetryHours * time.Hour).Truncate(telemetryInterval)
		samples := int(telemetryHours * time.Hour / telemetryInterval)
		for i := 0; i < samples; i++ {
			ts := start.Add(time.Duration(i) * telemetryInterval)
			// Units park for the last hour of the track; the rest is driving.
			driving := i < samples-12 && u.Number != lastUnit(t)
			speed := 0.0
			if driving {
				speed = 84 + 12*math.Sin(float64(i)/7)
				lat -= 0.006
				lng -= 0.010
				odometer += int64(speed * 1000 / 12)
				engineHours += 0.08
			}
			heading := 214.0

			s.exec(`
				INSERT INTO telemetry (ts, company_id, unit_id, eld_device_id, driver_id, lat, lng,
				                       speed_kmh, heading, odometer_m, engine_hours, fuel_pct,
				                       coolant_temp_c, coolant_level_pct, oil_level_pct, battery_pct,
				                       battery_voltage_v, ignition, source)
				VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11::numeric,$12,$13,$14,$15,$16,$17,$18,'eld')
				ON CONFLICT (unit_id, ts) DO NOTHING`,
				ts, companyID, unitRef, device, driver, lat, lng, speed, heading,
				odometer, engineHours, 78-float64(i)*0.2, 88.0, 92.0, 95.0, 97.0, 13.8, driving)

			lastTS, lastSpeed, lastHeading = ts, speed, heading
		}
	}

	online := "offline"
	switch {
	case lastSpeed > 0:
		online = "online"
	case index%3 == 1:
		online = "idle"
	case index%5 == 4:
		online = "disconnected"
	}

	s.exec(`
		INSERT INTO unit_last_state (unit_id, company_id, ts, lat, lng, speed_kmh, heading,
		                             odometer_m, engine_hours, duty_status, driver_id, online_status)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9::numeric,$10,$11,$12)
		ON CONFLICT (unit_id) DO UPDATE SET
		  ts = EXCLUDED.ts, lat = EXCLUDED.lat, lng = EXCLUDED.lng,
		  speed_kmh = EXCLUDED.speed_kmh, heading = EXCLUDED.heading,
		  odometer_m = EXCLUDED.odometer_m, engine_hours = EXCLUDED.engine_hours,
		  duty_status = EXCLUDED.duty_status, driver_id = EXCLUDED.driver_id,
		  online_status = EXCLUDED.online_status`,
		unitRef, companyID, lastTS, lat, lng, lastSpeed, lastHeading,
		odometer, engineHours, dutyFor(lastSpeed), driver, online)
}

// lastUnit is the unit number kept parked so the map shows an offline vehicle.
func lastUnit(t tenantSpec) string {
	return t.Units[len(t.Units)-1].Number
}

// dutyFor maps the last reported speed onto a duty status.
func dutyFor(speed float64) string {
	if speed > 0 {
		return "DR"
	}
	return "ON"
}

// seedTrips writes one closed trip per unit for each of the last historyDays.
func (s *seeder) seedTrips(t tenantSpec, companyID uuid.UUID) {
	loc := mustLocation(t.Timezone)

	for i, u := range t.Units {
		var driver any
		if i < len(t.Drivers) {
			driver = driverID(t.Key, t.Drivers[i].Username)
		}
		from := waypoints[i%len(waypoints)]
		to := waypoints[(i+3)%len(waypoints)]

		for back := 1; back <= historyDays; back++ {
			day := dayStart(s.now, loc, -back)
			startAt := at(day, 6, 30)
			endAt := at(day, 16, 0)

			s.exec(`
				INSERT INTO trips (id, company_id, unit_id, driver_id, start_at, end_at,
				                   start_lat, start_lng, end_lat, end_lng,
				                   distance_m, duration_sec, max_speed_kmh, polyline_key)
				VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
				ON CONFLICT (id) DO UPDATE SET
				  end_at = EXCLUDED.end_at, distance_m = EXCLUDED.distance_m`,
				sid("trip", t.Key, u.Number, fmt.Sprint(back)), companyID,
				unitID(t.Key, u.Number), driver, startAt, endAt,
				from.lat, from.lng, to.lat, to.lng,
				810_000, int(endAt.Sub(startAt).Seconds()), 104.5,
				fmt.Sprintf("polylines/%s/%s-%d.json", t.Key, u.Number, back))
		}
	}
}

// regionsFor picks the distance catalogue rows a tenant reports against.
func regionsFor(region string) []string {
	switch region {
	case "US":
		return []string{"US-IL", "US-MO", "US-OK", "US-TX"}
	case "UZ":
		return []string{"UZ-TK", "UZ-SI", "UZ-SA"}
	default:
		return nil
	}
}

// seedRegionDistance fills the per state distance table the region report and
// the IFTA style export read.
func (s *seeder) seedRegionDistance(t tenantSpec, companyID uuid.UUID) {
	codes := regionsFor(t.Region)
	if len(codes) == 0 {
		return
	}
	loc := mustLocation(t.Timezone)

	for i, u := range t.Units {
		for back := 1; back <= historyDays; back++ {
			day := dayStart(s.now, loc, -back)
			for c, code := range codes {
				s.exec(`
					INSERT INTO unit_region_distance_daily (unit_id, region_code, date, company_id, distance_m)
					VALUES ($1,$2,$3::date,$4,$5)
					ON CONFLICT (unit_id, region_code, date) DO UPDATE SET distance_m = EXCLUDED.distance_m`,
					unitID(t.Key, u.Number), code, day.Format("2006-01-02"), companyID,
					int64(120_000+40_000*((i+c+back)%5)))
			}
		}
	}
}
