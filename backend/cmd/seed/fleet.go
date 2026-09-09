package main

import (
	"fmt"
	"time"

	"github.com/google/uuid"
)

// eldVendors cycles over the vendors a seeded device reports.
var eldVendors = []struct{ vendor, model, connection string }{
	{"Geotab", "GO9", "bluetooth"},
	{"PT30", "PT30-ELD", "bluetooth"},
	{"Samsara", "VG34", "cellular"},
}

// seedFleet writes the units, trailers, shipping documents, ELD devices and
// the driver/unit assignments of one tenant.
func (s *seeder) seedFleet(t tenantSpec) {
	companyID := sid("company", t.Key)
	s.exec(`SET LOCAL app.company_id = ` + quoteLiteral(companyID.String()))

	for i, u := range t.Units {
		s.exec(`
			INSERT INTO units (id, company_id, branch_id, unit_number, make, model, year, vin,
			                   license_plate, plate_region, fuel_type, sleeper_berth, gvwr_class,
			                   status, out_of_service, notes, activated_on)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)
			ON CONFLICT (id) DO UPDATE SET
			  make = EXCLUDED.make, model = EXCLUDED.model, vin = EXCLUDED.vin,
			  branch_id = EXCLUDED.branch_id, status = EXCLUDED.status,
			  out_of_service = EXCLUDED.out_of_service, deleted_at = NULL`,
			unitID(t.Key, u.Number), companyID, branchRef(t.Key, u.Branch), u.Number,
			u.Make, u.Model, u.Year, u.VIN, u.Plate, u.PlateRegion, u.Fuel, u.Sleeper,
			u.GVWR, unitStatus(i, len(t.Units)), i%31 == 19,
			"seeded demo unit", s.now.AddDate(0, -4, 0))
	}

	for _, number := range t.Trailers {
		s.exec(`
			INSERT INTO trailers (id, company_id, number, notes)
			VALUES ($1,$2,$3,'seeded demo trailer')
			ON CONFLICT (id) DO UPDATE SET number = EXCLUDED.number, deleted_at = NULL`,
			sid("trailer", t.Key, number), companyID, number)
	}

	for _, number := range t.ShippingDocs {
		s.exec(`
			INSERT INTO shipping_documents (id, company_id, number, notes)
			VALUES ($1,$2,$3,'seeded demo shipping document')
			ON CONFLICT (id) DO UPDATE SET number = EXCLUDED.number, deleted_at = NULL`,
			sid("shipping_document", t.Key, number), companyID, number)
	}

	s.seedDevices(t, companyID)
	s.seedAssignments(t, companyID)
	s.seedDefectTypes(t, companyID)
}

// unitStatus keeps a small slice of a larger fleet inactive so the status
// filter has more than a single row to show.
func unitStatus(index, total int) string {
	if total > 4 && index%20 == 7 {
		return "inactive"
	}
	return "active"
}

// seedDevices attaches one ELD device to every driven unit. A small slice of
// a larger fleet reports a malfunction so the diagnostics view is not empty.
func (s *seeder) seedDevices(t tenantSpec, companyID uuid.UUID) {
	devices := len(t.Drivers)
	if devices > len(t.Units) {
		devices = len(t.Units)
	}
	for i := 0; i < devices; i++ {
		unit := t.Units[i]
		v := eldVendors[i%len(eldVendors)]
		serial := fmt.Sprintf("ELD-%s-%04d", upperKey(t.Key), i+1)

		status, codes := "active", []string{}
		if devices > 3 && i%25 == 11 {
			status, codes = "malfunction", []string{"P", "E"}
		}

		deviceID := sid("eld_device", t.Key, serial)
		s.exec(`
			INSERT INTO eld_devices (id, company_id, unit_id, vendor, model, serial, firmware,
			                         connection_type, sim_present, last_seen_at, malfunction_codes, status, notes)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11::text[],$12,'seeded demo device')
			ON CONFLICT (id) DO UPDATE SET
			  unit_id = EXCLUDED.unit_id, status = EXCLUDED.status,
			  malfunction_codes = EXCLUDED.malfunction_codes,
			  last_seen_at = EXCLUDED.last_seen_at, deleted_at = NULL`,
			deviceID, companyID, unitID(t.Key, unit.Number), v.vendor, v.model, serial,
			"3.14.0", v.connection, v.connection == "cellular",
			s.now.Add(-time.Duration(3*(i+1))*time.Minute), codes, status)

		s.exec(`
			INSERT INTO eld_device_assignments (id, company_id, eld_device_id, unit_id, from_at)
			VALUES ($1,$2,$3,$4,$5)
			ON CONFLICT (id) DO NOTHING`,
			sid("eld_assignment", t.Key, serial), companyID, deviceID,
			unitID(t.Key, unit.Number), s.now.AddDate(0, -4, 0))
	}
}

// seedAssignments pairs every driver with a unit and, where the fleet is large
// enough, records one team (co-driver) pair.
func (s *seeder) seedAssignments(t tenantSpec, companyID uuid.UUID) {
	for i, d := range t.Drivers {
		if i >= len(t.Units) {
			break
		}
		unit := unitID(t.Key, t.Units[i].Number)
		s.exec(`
			INSERT INTO unit_driver_assignments (id, company_id, unit_id, driver_id, role, assigned_at)
			VALUES ($1,$2,$3,$4,'primary',$5)
			ON CONFLICT (id) DO NOTHING`,
			sid("unit_driver", t.Key, d.Username), companyID, unit,
			driverID(t.Key, d.Username), s.now.AddDate(0, -3, 0))

		s.exec(`UPDATE drivers SET default_unit_id = $2 WHERE id = $1`,
			driverID(t.Key, d.Username), unit)
	}

	if len(t.Drivers) < 2 {
		return
	}
	a := driverID(t.Key, t.Drivers[len(t.Drivers)-2].Username)
	b := driverID(t.Key, t.Drivers[len(t.Drivers)-1].Username)
	if a.String() > b.String() {
		a, b = b, a
	}
	s.exec(`
		INSERT INTO driver_pairs (id, company_id, driver_a_id, driver_b_id)
		VALUES ($1,$2,$3,$4)
		ON CONFLICT (id) DO UPDATE SET deleted_at = NULL`,
		sid("driver_pair", t.Key), companyID, a, b)
}

// seedDefectTypes adds two company specific defect types on top of the FMCSA
// catalogue the migrations ship.
func (s *seeder) seedDefectTypes(t tenantSpec, companyID uuid.UUID) {
	custom := []struct {
		name, category string
		critical       bool
		order          int
	}{
		{"Refrigeration Unit", "trailer", true, 100},
		{"Dash Camera", "truck", false, 101},
	}
	for _, c := range custom {
		s.exec(`
			INSERT INTO defect_types (id, company_id, name, category, is_critical, is_active, sort_order)
			VALUES ($1,$2,$3,$4,$5,true,$6)
			ON CONFLICT (id) DO UPDATE SET
			  name = EXCLUDED.name, is_critical = EXCLUDED.is_critical, deleted_at = NULL`,
			sid("defect_type", t.Key, c.name), companyID, c.name, c.category, c.critical, c.order)
	}
}
