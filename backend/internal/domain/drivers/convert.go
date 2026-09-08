package drivers

import (
	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/drivers/dto"
)

// ---------------------------------------------------------------- pg helpers

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

// maskLicense keeps the last four characters of a licence number, which is all
// the UI needs to recognise a record (TZ B§3.4).
func maskLicense(plain string) string {
	if plain == "" {
		return ""
	}
	r := []rune(plain)
	if len(r) <= 4 {
		return "***"
	}
	return "***" + string(r[len(r)-4:])
}

// ---------------------------------------------------------------- row -> dto

// licenseDecryptor decrypts the stored licence column. It is nil-safe: when
// decryption fails the masked value degrades to "***" rather than leaking the
// ciphertext.
type licenseDecryptor func(enc *string) string

func driverFromDetail(row db.GetDriverDetailRow, decrypt licenseDecryptor) dto.Driver {
	return dto.Driver{
		ID:               row.ID.String(),
		UserID:           row.UserID.String(),
		FirstName:        row.FirstName,
		LastName:         row.LastName,
		Username:         row.Username,
		Email:            pgconv.Deref(row.Email),
		Phone:            pgconv.Deref(row.Phone),
		LicenseNoMasked:  maskLicense(decrypt(row.LicenseNoEnc)),
		LicenseRegion:    pgconv.Deref(row.LicenseRegion),
		HomeTerminal:     pgconv.Deref(row.HomeTerminal),
		City:             pgconv.Deref(row.City),
		State:            pgconv.Deref(row.State),
		Zip:              pgconv.Deref(row.Zip),
		Address1:         pgconv.Deref(row.Address1),
		Address2:         pgconv.Deref(row.Address2),
		Notes:            pgconv.Deref(row.Notes),
		BranchID:         pgconv.UUIDStringOrEmpty(row.BranchID),
		BranchName:       pgconv.Deref(row.BranchName),
		FleetManagerID:   pgconv.UUIDStringOrEmpty(row.FleetManagerID),
		FleetManagerName: joinName(row.FleetManagerFirstName, row.FleetManagerLastName),
		DefaultUnitID:    pgconv.UUIDStringOrEmpty(row.DefaultUnitID),
		DefaultUnit:      pgconv.Deref(row.DefaultUnitNumber),
		Status:           row.Status,
		UserStatus:       row.UserStatus,
		AppVersion:       pgconv.Deref(row.AppVersion),
		ActivatedOn:      pgconv.ToTimePtr(row.ActivatedOn),
		LastLoginAt:      pgconv.ToTimePtr(row.LastLoginAt),
		CreatedAt:        row.CreatedAt.UTC(),
		UpdatedAt:        row.UpdatedAt.UTC(),
	}
}

func driverFromList(row db.ListDriversPageRow, decrypt licenseDecryptor) dto.Driver {
	return driverFromDetail(db.GetDriverDetailRow(row), decrypt)
}

func coDriverFromRow(row db.ListCoDriverDetailsRow) dto.CoDriver {
	return dto.CoDriver{
		DriverID:  row.ID.String(),
		FirstName: row.FirstName,
		LastName:  row.LastName,
		Username:  row.Username,
		Status:    row.Status,
		PairID:    row.PairID.String(),
		PairedAt:  row.PairedAt.UTC(),
	}
}

func activityFromRow(row db.ListDriverActivitiesRow) dto.Activity {
	return dto.Activity{
		ID:         row.ID.String(),
		OccurredAt: row.OccurredAt.UTC(),
		Action:     row.Action,
		Source:     row.TableName,
		Field:      pgconv.Deref(row.Field),
		OldValue:   string(row.OldValue),
		NewValue:   string(row.NewValue),
		ActorID:    pgconv.UUIDStringOrEmpty(row.ActorID),
		UserAgent:  pgconv.Deref(row.UserAgent),
	}
}
