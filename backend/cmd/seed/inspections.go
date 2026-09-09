package main

import (
	"fmt"
	"time"

	"github.com/google/uuid"
)

// maintenanceSpec is one seeded service plan.
type maintenanceSpec struct {
	name, kind, unit string
	interval         float64
	reminderBefore   float64
	alert            string
	delivery         []string
}

// seededSchedules are the plans every tenant starts with.
var seededSchedules = []maintenanceSpec{
	{"Oil Change", "preventive", "km", 40000, 2500, "notification", []string{"push", "email"}},
	{"Tire Rotation", "preventive", "km", 20000, 1500, "notification", []string{"push"}},
	{"Annual DOT Inspection", "regulatory", "days", 365, 30, "email", []string{"email"}},
	{"Engine Service", "preventive", "engine_hours", 500, 40, "notification", []string{"push"}},
}

// seedInspections writes the DVIR reports and the maintenance plans, due rows
// and completed service records of one tenant.
func (s *seeder) seedInspections(t tenantSpec) {
	companyID := sid("company", t.Key)
	s.exec(`SET LOCAL app.company_id = ` + quoteLiteral(companyID.String()))

	s.seedDvir(t, companyID)
	s.seedMaintenance(t, companyID)
}

// systemDefectType resolves one FMCSA catalogue entry shipped by the
// migrations, so a seeded defect points at a real defect type.
func (s *seeder) systemDefectType(name, category string) uuid.UUID {
	if s.err != nil {
		return uuid.Nil
	}
	var id uuid.UUID
	err := s.tx.QueryRow(s.ctx, `
		SELECT id FROM defect_types
		WHERE company_id IS NULL AND deleted_at IS NULL
		  AND category = $2 AND lower(name) = lower($1)`, name, category).Scan(&id)
	if err != nil {
		s.err = fmt.Errorf("defect type %q: %w", name, err)
	}
	return id
}

// seedDvir writes a pre-trip report per driven unit, one open defect report and
// one full defects -> repaired -> certified chain.
func (s *seeder) seedDvir(t tenantSpec, companyID uuid.UUID) {
	loc := mustLocation(t.Timezone)
	tires := s.systemDefectType("Tires", "truck")
	lights := s.systemDefectType("Lights (Head / Stop)", "truck")
	if s.err != nil {
		return
	}

	mechanic, hasMechanic := accountByRole(t, roleServiceMgr)
	if !hasMechanic {
		mechanic, hasMechanic = accountByRole(t, roleAdministrator)
	}

	for i, d := range t.Drivers {
		if i >= len(t.Units) {
			break
		}
		unit := t.Units[i]
		day := dayStart(s.now, loc, -1)
		trailer := uuidStrings(sid("trailer", t.Key, t.Trailers[i%len(t.Trailers)]))

		// Clean pre-trip for every driver.
		s.dvirReport(t, companyID, dvirInput{
			key: "pre", unitNumber: unit.Number, driver: d.Username, kind: "pre_trip",
			status: "submitted_no_defects", performedAt: at(day, 6, 5),
			trailers: trailer, odometer: int64(180_000_000 + i*23_000_000),
		})

		switch i {
		case 0:
			// Defects found yesterday, repaired by the shop, certified by the
			// driver this morning (§7.2 full chain).
			s.dvirReport(t, companyID, dvirInput{
				key: "post", unitNumber: unit.Number, driver: d.Username, kind: "post_trip",
				status: "certified", performedAt: at(day, 17, 20), trailers: trailer,
				odometer: int64(180_000_000 + i*23_000_000 + 810_000),
				defects: []map[string]any{{
					"defect_type_id": tires.String(), "name": "Tires", "category": "truck",
					"is_critical": true, "note": "left steer tyre below tread limit",
					"photo_keys": []string{fmt.Sprintf("%s/dvir_photo/%s/tire.jpg", t.Key, day.Format("2006/01/02"))},
				}},
				mechanic: mechanic, hasMechanic: hasMechanic,
				repairedAt: at(day, 20, 10), certifiedAt: at(day.AddDate(0, 0, 1), 6, 15),
			})
		case 1:
			// Still waiting for the shop: this is the pending certification queue.
			s.dvirReport(t, companyID, dvirInput{
				key: "post", unitNumber: unit.Number, driver: d.Username, kind: "post_trip",
				status: "submitted_defects_found", performedAt: at(day, 17, 40), trailers: trailer,
				odometer: int64(180_000_000 + i*23_000_000 + 790_000),
				defects: []map[string]any{{
					"defect_type_id": lights.String(), "name": "Lights (Head / Stop)",
					"category": "truck", "is_critical": true,
					"note": "right stop lamp out", "photo_keys": []string{},
				}},
			})
		}
	}
}

// dvirInput carries one seeded inspection report.
type dvirInput struct {
	key, unitNumber, driver, kind, status string
	performedAt                           time.Time
	trailers                              []string
	odometer                              int64
	defects                               []map[string]any
	mechanic                              string
	hasMechanic                           bool
	repairedAt, certifiedAt               time.Time
}

// dvirReport writes one dvir_reports row.
func (s *seeder) dvirReport(t tenantSpec, companyID uuid.UUID, in dvirInput) {
	defects := in.defects
	if defects == nil {
		defects = []map[string]any{}
	}
	payload, err := jsonBytes(defects)
	if err != nil {
		s.err = err
		return
	}

	wp := waypoints[len(in.unitNumber)%len(waypoints)]

	var mechanicID, mechanicNote, mechanicSig, repairedAt, certifiedAt, certifiedBy, certSig any
	if in.hasMechanic && !in.repairedAt.IsZero() {
		mechanicID = userID(t.Key, in.mechanic)
		mechanicNote = "part replaced, road tested"
		mechanicSig = fmt.Sprintf("signatures/%s/mechanic.png", t.Key)
		repairedAt = in.repairedAt
	}
	if !in.certifiedAt.IsZero() {
		certifiedAt = in.certifiedAt
		certifiedBy = driverID(t.Key, in.driver)
		certSig = fmt.Sprintf("signatures/%s/%s.png", t.Key, in.driver)
	}

	s.exec(`
		INSERT INTO dvir_reports (id, company_id, unit_id, driver_id, type, trailer_ids, status, defects,
		                          lat, lng, location_text, odometer_m, engine_hours,
		                          driver_signature_key, mechanic_id, mechanic_note, mechanic_signature_key,
		                          repaired_at, certified_by_driver_id, certified_at,
		                          certification_signature_key, source, performed_at)
		VALUES ($1,$2,$3,$4,$5,$6::uuid[],$7,$8::jsonb,$9,$10,$11,$12,$13::numeric,$14,$15,$16,$17,$18,$19,$20,$21,'app',$22)
		ON CONFLICT (id) DO UPDATE SET
		  status = EXCLUDED.status, defects = EXCLUDED.defects,
		  repaired_at = EXCLUDED.repaired_at, certified_at = EXCLUDED.certified_at`,
		sid("dvir", t.Key, in.unitNumber, in.key), companyID,
		unitID(t.Key, in.unitNumber), driverID(t.Key, in.driver), in.kind, in.trailers,
		in.status, payload, wp.lat, wp.lng, wp.text, in.odometer, 4380.5,
		fmt.Sprintf("signatures/%s/%s.png", t.Key, in.driver),
		mechanicID, mechanicNote, mechanicSig, repairedAt, certifiedBy, certifiedAt, certSig,
		in.performedAt)
}

// seedMaintenance writes the service plans, the per unit due rows and a few
// completed service records with invoices.
func (s *seeder) seedMaintenance(t tenantSpec, companyID uuid.UUID) {
	for si, m := range seededSchedules {
		scheduleID := sid("maintenance_schedule", t.Key, m.name)
		s.exec(`
			INSERT INTO maintenance_schedules (id, company_id, name, type, interval_value, interval_unit,
			                                   reminder_before_value, alert_type, delivery_methods,
			                                   notify_co_driver, notes, status)
			VALUES ($1,$2,$3,$4,$5::numeric,$6,$7::numeric,$8,$9::text[],false,$10,'active')
			ON CONFLICT (id) DO UPDATE SET
			  interval_value = EXCLUDED.interval_value, reminder_before_value = EXCLUDED.reminder_before_value,
			  delivery_methods = EXCLUDED.delivery_methods, status = 'active', deleted_at = NULL`,
			scheduleID, companyID, m.name, m.kind, m.interval, m.unit, m.reminderBefore,
			m.alert, m.delivery, "seeded demo schedule")

		for ui, u := range t.Units {
			// One unit per plan is overdue, the next one is due soon.
			status := "scheduled"
			nextDue := s.now.AddDate(0, 0, 30+ui*4)
			switch (ui + si) % 5 {
			case 0:
				status, nextDue = "due", s.now.AddDate(0, 0, -3)
			case 1:
				nextDue = s.now.AddDate(0, 0, 5)
			}

			scheduleUnitID := sid("maintenance_schedule_unit", t.Key, m.name, u.Number)
			s.exec(`
				INSERT INTO maintenance_schedule_units (id, company_id, schedule_id, unit_id,
				                                        last_service_value, next_due_value, next_due_at,
				                                        last_service_at, status)
				VALUES ($1,$2,$3,$4,$5::numeric,$6::numeric,$7,$8,$9)
				ON CONFLICT (id) DO UPDATE SET
				  next_due_at = EXCLUDED.next_due_at, next_due_value = EXCLUDED.next_due_value,
				  status = EXCLUDED.status, deleted_at = NULL`,
				scheduleUnitID, companyID, scheduleID, unitID(t.Key, u.Number),
				float64(180_000+ui*23_000), float64(180_000+ui*23_000)+m.interval,
				nextDue, s.now.AddDate(0, -2, 0), status)

			if (ui+si)%5 != 0 {
				continue
			}
			s.exec(`
				INSERT INTO maintenance_records (id, company_id, schedule_unit_id, unit_id, status,
				                                 performed_at, invoice_no, vendor, cost, currency,
				                                 odometer_m, engine_hours, invoice_key, notes)
				VALUES ($1,$2,$3,$4,'completed',$5,$6,$7,$8::numeric,$9,$10,$11::numeric,$12,$13)
				ON CONFLICT (id) DO UPDATE SET cost = EXCLUDED.cost, notes = EXCLUDED.notes`,
				sid("maintenance_record", t.Key, m.name, u.Number), companyID, scheduleUnitID,
				unitID(t.Key, u.Number), s.now.AddDate(0, -2, 0),
				fmt.Sprintf("INV-%s-%04d", upperKey(t.Key), si*10+ui+1),
				"Midwest Truck Service", 480.75+float64(si)*95, currencyFor(t.Region),
				int64(180_000_000+ui*23_000_000-4_000_000), 4180.0,
				fmt.Sprintf("invoices/%s/%s-%s.pdf", t.Key, u.Number, m.name),
				"seeded demo service record")
		}
	}
}

// currencyFor is the invoice currency of a tenant's region.
func currencyFor(region string) string {
	if region == "UZ" {
		return "UZS"
	}
	return "USD"
}
