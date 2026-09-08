package files

import (
	"strconv"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/db"
)

// driverExportRow renders one driver as an export line. The licence number is
// only ever exported masked (TZ B§3.4).
func driverExportRow(row db.ListDriversForExportRow, mask func(*string) string) []string {
	return []string{
		row.ID.String(),
		row.FirstName,
		row.LastName,
		row.Username,
		pgconv.Deref(row.Email),
		pgconv.Deref(row.Phone),
		mask(row.LicenseNoEnc),
		pgconv.Deref(row.LicenseRegion),
		pgconv.Deref(row.HomeTerminal),
		pgconv.Deref(row.City),
		pgconv.Deref(row.State),
		pgconv.Deref(row.Zip),
		pgconv.Deref(row.Address1),
		pgconv.Deref(row.Address2),
		pgconv.Deref(row.BranchName),
		joinName(row.FleetManagerFirstName, row.FleetManagerLastName),
		pgconv.Deref(row.DefaultUnitNumber),
		row.Status,
		formatTime(row.ActivatedOn),
		row.CreatedAt.UTC().Format(time.RFC3339),
	}
}

// unitExportRow renders one unit as an export line.
func unitExportRow(row db.ListUnitsForExportRow) []string {
	return []string{
		row.ID.String(),
		row.UnitNumber,
		pgconv.Deref(row.Make),
		pgconv.Deref(row.Model),
		formatInt32(row.Year),
		pgconv.Deref(row.LicensePlate),
		pgconv.Deref(row.PlateRegion),
		pgconv.Deref(row.Vin),
		pgconv.Deref(row.FuelType),
		strconv.FormatBool(row.SleeperBerth),
		pgconv.Deref(row.BranchName),
		row.Status,
		strconv.FormatBool(row.OutOfService),
		pgconv.Deref(row.Notes),
		formatTime(row.ActivatedOn),
		row.CreatedAt.UTC().Format(time.RFC3339),
	}
}

func joinName(first, last *string) string {
	f, l := pgconv.Deref(first), pgconv.Deref(last)
	switch {
	case f == "" && l == "":
		return ""
	case f == "":
		return l
	case l == "":
		return f
	default:
		return f + " " + l
	}
}

func formatTime(v pgtype.Timestamptz) string {
	if !v.Valid {
		return ""
	}
	return v.Time.UTC().Format(time.RFC3339)
}

func formatInt32(v *int32) string {
	if v == nil {
		return ""
	}
	return strconv.FormatInt(int64(*v), 10)
}
