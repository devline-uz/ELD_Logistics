package files

import (
	"context"
	"errors"
	"regexp"
	"strconv"
	"strings"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/domain/files/dto"
)

// Q18.3 constraints.
var (
	usernameRe = regexp.MustCompile(`^[a-z0-9._]{4,32}$`)
	emailRe    = regexp.MustCompile(`^[^@\s]+@[^@\s.]+\.[^@\s]{2,}$`)
	vinRe      = regexp.MustCompile(`^[A-HJ-NPR-Z0-9]{17}$`)
)

// fuelTypes is the accepted fuel_type whitelist.
var fuelTypes = map[string]struct{}{
	"diesel": {}, "petrol": {}, "gasoline": {}, "cng": {},
	"lpg": {}, "electric": {}, "hybrid": {},
}

// validateDriverRows checks every row of the file, both against the format
// rules and against what already exists in the tenant. It returns the rows
// ready to be written and, if anything failed, the complete error report — the
// caller then writes nothing at all (TZ §18.4).
// driverRowState tracks the cross-row collision state accumulated while
// validateDriverRows walks the sheet.
type driverRowState struct {
	seenUsernames map[string]int
	seenEmails    map[string]int
	usernames     []string
	emails        []string
}

// validateDriverIdentity checks the row-local username/email/contact rules
// and records the values for the tenant collision pass below.
func (s *Service) validateDriverIdentity(rowNo int, row *DriverRow, st *driverRowState) []dto.ImportRowError {
	var errs []dto.ImportRowError
	if row.FirstName == "" {
		errs = append(errs, rowErr(rowNo, "first_name", "required"))
	}
	if row.LastName == "" {
		errs = append(errs, rowErr(rowNo, "last_name", "required"))
	}
	if !usernameRe.MatchString(row.Username) {
		errs = append(errs, rowErr(rowNo, "username", "must be 4-32 characters of [a-z0-9._]"))
	} else if prev, dup := st.seenUsernames[row.Username]; dup {
		errs = append(errs, rowErr(rowNo, "username", "duplicates row "+strconv.Itoa(prev)))
	} else {
		st.seenUsernames[row.Username] = rowNo
		st.usernames = append(st.usernames, row.Username)
	}
	if row.Email != "" && !emailRe.MatchString(row.Email) {
		errs = append(errs, rowErr(rowNo, "email", "must be a valid email"))
	} else if row.Email != "" {
		if prev, dup := st.seenEmails[row.Email]; dup {
			errs = append(errs, rowErr(rowNo, "email", "duplicates row "+strconv.Itoa(prev)))
		} else {
			st.seenEmails[row.Email] = rowNo
			st.emails = append(st.emails, row.Email)
		}
	}
	// Q18.1: the invitation needs an email or a phone number.
	if row.Email == "" && row.Phone == "" {
		errs = append(errs, rowErr(rowNo, "email", "email or phone is required for the invitation"))
	}
	return errs
}

// validateDriverLicense checks and encrypts the license number in place.
func (s *Service) validateDriverLicense(rowNo int, row *DriverRow, licenseNo string) []dto.ImportRowError {
	if licenseNo == "" {
		return []dto.ImportRowError{rowErr(rowNo, "license_no", "required")}
	}
	enc, err := s.encryptLicense(licenseNo)
	if err != nil {
		return []dto.ImportRowError{rowErr(rowNo, "license_no", "could not be encrypted")}
	}
	row.LicenseNoEnc = enc
	return nil
}

// checkExistingDriverIdentities reports the rows whose username/email already
// exist elsewhere in the tenant (TZ §18.4).
func (s *Service) checkExistingDriverIdentities(ctx context.Context, companyID uuid.UUID, st *driverRowState) []dto.ImportRowError {
	var errs []dto.ImportRowError
	if existing, err := s.repo.ExistingUsernames(ctx, companyID, st.usernames); err != nil {
		errs = append(errs, rowErr(0, "username", "could not be verified"))
	} else {
		for _, name := range existing {
			if rowNo, ok := st.seenUsernames[name]; ok {
				errs = append(errs, rowErr(rowNo, "username", "already exists in this company"))
			}
		}
	}
	if existing, err := s.repo.ExistingEmails(ctx, companyID, st.emails); err != nil {
		errs = append(errs, rowErr(0, "email", "could not be verified"))
	} else {
		for _, email := range existing {
			if rowNo, ok := st.seenEmails[email]; ok {
				errs = append(errs, rowErr(rowNo, "email", "already exists in this company"))
			}
		}
	}
	return errs
}

func (s *Service) validateDriverRows(ctx context.Context, companyID uuid.UUID, t table) ([]DriverRow, []dto.ImportRowError) {
	var (
		out       = make([]DriverRow, 0, len(t.rows))
		rowErrors = make([]dto.ImportRowError, 0, len(t.rows))
	)

	idx := map[string]int{}
	for _, c := range driverImportColumns {
		idx[c] = t.index(c)
	}

	st := &driverRowState{
		seenUsernames: map[string]int{},
		seenEmails:    map[string]int{},
		usernames:     make([]string, 0, len(t.rows)),
		emails:        make([]string, 0, len(t.rows)),
	}

	for i, rec := range t.rows {
		// Row 1 is the header, so data starts at 2 — that is what a user sees
		// in Excel.
		rowNo := i + 2
		row := DriverRow{
			Row:           rowNo,
			FirstName:     cell(rec, idx["first_name"]),
			LastName:      cell(rec, idx["last_name"]),
			Username:      strings.ToLower(cell(rec, idx["username"])),
			Phone:         cell(rec, idx["phone"]),
			Email:         strings.ToLower(cell(rec, idx["email"])),
			LicenseRegion: cell(rec, idx["license_region"]),
			HomeTerminal:  cell(rec, idx["home_terminal"]),
		}
		licenseNo := cell(rec, idx["license_no"])

		rowErrors = append(rowErrors, s.validateDriverIdentity(rowNo, &row, st)...)
		rowErrors = append(rowErrors, s.validateDriverLicense(rowNo, &row, licenseNo)...)

		out = append(out, row)
	}

	rowErrors = append(rowErrors, s.checkExistingDriverIdentities(ctx, companyID, st)...)

	if len(rowErrors) > 0 {
		return nil, rowErrors
	}
	return out, nil
}

// validateUnitRows is validateDriverRows for units_import_template.
// unitRowState tracks the cross-row collision state accumulated while
// validateUnitRows walks the sheet.
type unitRowState struct {
	seenNumbers map[string]int
	seenVINs    map[string]int
	numbers     []string
	vins        []string
}

// validateUnitIdentity checks unit_number/make/model/plate/fuel_type — the
// Q18.1 required fields plus the fuel type whitelist.
func validateUnitIdentity(rowNo int, row *UnitRow, st *unitRowState) []dto.ImportRowError {
	var errs []dto.ImportRowError
	// Q18.1: Unit #, Make, Model, License Plate and Fuel Type are required.
	if row.UnitNumber == "" {
		errs = append(errs, rowErr(rowNo, "unit_number", "required"))
	} else {
		key := strings.ToLower(row.UnitNumber)
		if prev, dup := st.seenNumbers[key]; dup {
			errs = append(errs, rowErr(rowNo, "unit_number", "duplicates row "+strconv.Itoa(prev)))
		} else {
			st.seenNumbers[key] = rowNo
			st.numbers = append(st.numbers, key)
		}
	}
	if row.Make == "" {
		errs = append(errs, rowErr(rowNo, "make", "required"))
	}
	if row.Model == "" {
		errs = append(errs, rowErr(rowNo, "model", "required"))
	}
	if row.Plate == "" {
		errs = append(errs, rowErr(rowNo, "plate", "required"))
	}
	if row.FuelType == "" {
		errs = append(errs, rowErr(rowNo, "fuel_type", "required"))
	} else if _, ok := fuelTypes[row.FuelType]; !ok {
		errs = append(errs, rowErr(rowNo, "fuel_type",
			"must be one of: diesel, petrol, gasoline, cng, lpg, electric, hybrid"))
	}
	return errs
}

// validateUnitOptionalFields checks the optional year/VIN/sleeper_berth cells.
func validateUnitOptionalFields(rowNo int, rec []string, idx map[string]int, row *UnitRow, st *unitRowState) []dto.ImportRowError {
	var errs []dto.ImportRowError
	if raw := cell(rec, idx["year"]); raw != "" {
		year, err := strconv.Atoi(raw)
		if err != nil || year < 1900 || year > 2100 {
			errs = append(errs, rowErr(rowNo, "year", "must be a year between 1900 and 2100"))
		} else {
			y := int32(year) //nolint:gosec // G109: year is validated to [1900,2100] above
			row.Year = &y
		}
	}
	if row.VIN != "" {
		if !vinRe.MatchString(row.VIN) {
			errs = append(errs, rowErr(rowNo, "vin", "must be 17 characters (no I, O or Q)"))
		} else if prev, dup := st.seenVINs[row.VIN]; dup {
			errs = append(errs, rowErr(rowNo, "vin", "duplicates row "+strconv.Itoa(prev)))
		} else {
			st.seenVINs[row.VIN] = rowNo
			st.vins = append(st.vins, row.VIN)
		}
	}
	if raw := cell(rec, idx["sleeper_berth"]); raw != "" {
		v, err := parseBool(raw)
		if err != nil {
			errs = append(errs, rowErr(rowNo, "sleeper_berth", "must be true or false"))
		} else {
			row.SleeperBerth = v
		}
	}
	return errs
}

// checkExistingUnitIdentities reports the rows whose unit_number/VIN already
// exist elsewhere in the tenant (TZ §18.4).
func (s *Service) checkExistingUnitIdentities(ctx context.Context, companyID uuid.UUID, st *unitRowState) []dto.ImportRowError {
	var errs []dto.ImportRowError
	if existing, err := s.repo.ExistingUnitNumbers(ctx, companyID, st.numbers); err != nil {
		errs = append(errs, rowErr(0, "unit_number", "could not be verified"))
	} else {
		for _, n := range existing {
			if rowNo, ok := st.seenNumbers[n]; ok {
				errs = append(errs, rowErr(rowNo, "unit_number", "already exists in this company"))
			}
		}
	}
	if existing, err := s.repo.ExistingVINs(ctx, companyID, st.vins); err != nil {
		errs = append(errs, rowErr(0, "vin", "could not be verified"))
	} else {
		for _, v := range existing {
			if rowNo, ok := st.seenVINs[v]; ok {
				errs = append(errs, rowErr(rowNo, "vin", "already exists in this company"))
			}
		}
	}
	return errs
}

func (s *Service) validateUnitRows(ctx context.Context, companyID uuid.UUID, t table) ([]UnitRow, []dto.ImportRowError) {
	var (
		out       = make([]UnitRow, 0, len(t.rows))
		rowErrors = make([]dto.ImportRowError, 0, len(t.rows))
	)

	idx := map[string]int{}
	for _, c := range unitImportColumns {
		idx[c] = t.index(c)
	}

	st := &unitRowState{
		seenNumbers: map[string]int{},
		seenVINs:    map[string]int{},
		numbers:     make([]string, 0, len(t.rows)),
		vins:        make([]string, 0, len(t.rows)),
	}

	for i, rec := range t.rows {
		rowNo := i + 2
		row := UnitRow{
			Row:         rowNo,
			UnitNumber:  cell(rec, idx["unit_number"]),
			Make:        cell(rec, idx["make"]),
			Model:       cell(rec, idx["model"]),
			Plate:       cell(rec, idx["plate"]),
			PlateRegion: cell(rec, idx["plate_region"]),
			VIN:         strings.ToUpper(cell(rec, idx["vin"])),
			FuelType:    strings.ToLower(cell(rec, idx["fuel_type"])),
		}

		rowErrors = append(rowErrors, validateUnitIdentity(rowNo, &row, st)...)
		rowErrors = append(rowErrors, validateUnitOptionalFields(rowNo, rec, idx, &row, st)...)

		out = append(out, row)
	}

	rowErrors = append(rowErrors, s.checkExistingUnitIdentities(ctx, companyID, st)...)

	if len(rowErrors) > 0 {
		return nil, rowErrors
	}
	return out, nil
}

// encryptLicense seals an imported licence number; storing it in clear text is
// never allowed (TZ B§3.4).
func (s *Service) encryptLicense(plain string) (*string, error) {
	if s.cipher == nil {
		return nil, errCryptoNotConfigured
	}
	enc, err := s.cipher.EncryptString(plain)
	if err != nil {
		return nil, err
	}
	return &enc, nil
}

func rowErr(row int, field, message string) dto.ImportRowError {
	return dto.ImportRowError{Row: row, Field: field, Message: message}
}

func parseBool(raw string) (bool, error) {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case "1", "true", "yes", "y", "ha":
		return true, nil
	case "0", "false", "no", "n", "yo'q":
		return false, nil
	default:
		return false, errInvalidBool
	}
}

// Sentinel errors of the row validators.
var (
	errInvalidBool         = errors.New("files: value is not a boolean")
	errCryptoNotConfigured = errors.New("files: cipher is not configured")
)
