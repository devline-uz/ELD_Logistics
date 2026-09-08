package files

// Import template columns (TZ §18.4). The order is the contract: the downloaded
// template and the accepted header are generated from the same slice.
var (
	driverImportColumns = []string{
		"first_name", "last_name", "username", "phone", "email",
		"license_no", "license_region", "home_terminal",
	}
	unitImportColumns = []string{
		"unit_number", "make", "model", "year", "plate",
		"plate_region", "vin", "fuel_type", "sleeper_berth",
	}
)

// Columns that must be present in the uploaded header.
var (
	driverRequiredColumns = []string{"first_name", "last_name", "username", "license_no"}
	unitRequiredColumns   = []string{"unit_number", "make", "model", "plate", "fuel_type"}
)

// Sample rows shipped inside the downloadable templates so the expected format
// is unambiguous.
var (
	driverTemplateSample = []string{
		"John", "Doe", "john.doe", "+14155550123", "john.doe@example.com",
		"TX-9930-4821", "TX", "Dallas Yard",
	}
	unitTemplateSample = []string{
		"1021", "Freightliner", "Cascadia", "2021", "TX-4821",
		"TX", "1FUJGLDR9CLBP8834", "diesel", "true",
	}
)

// Export columns.
var (
	driverExportColumns = []string{
		"id", "first_name", "last_name", "username", "email", "phone",
		"license_no_masked", "license_region", "home_terminal",
		"city", "state", "zip", "address1", "address2",
		"branch", "fleet_manager", "default_unit", "status",
		"activated_on", "created_at",
	}
	unitExportColumns = []string{
		"id", "unit_number", "make", "model", "year", "plate", "plate_region",
		"vin", "fuel_type", "sleeper_berth", "branch", "status",
		"out_of_service", "notes", "activated_on", "created_at",
	}
)

// Template file names.
const (
	driverTemplateName = "drivers_import_template"
	unitTemplateName   = "units_import_template"
)

// buildTemplate renders an import template in the requested format.
func buildTemplate(name string, columns, sample []string, format string) ([]byte, error) {
	rows := [][]string{sample}
	if format == FormatXLSX {
		return renderXLSX(name, columns, rows)
	}
	return renderCSV(columns, rows)
}
