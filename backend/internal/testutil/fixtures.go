package testutil

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"sort"
	"strconv"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
)

// ---------------------------------------------------------------- builders

// NewCompany inserts a companies row.
func NewCompany(t testing.TB, opts ...Option) Company {
	t.Helper()
	name := uniq("Test Co")
	r := apply(row{
		"id":       uuid.New(),
		"name":     name,
		"timezone": "America/Chicago",
	}, opts)
	insert(t, "companies", r)
	return Company{ID: r["id"].(uuid.UUID), Name: r["name"].(string)}
}

// NewBranch inserts a branches row for companyID.
func NewBranch(t testing.TB, companyID uuid.UUID, opts ...Option) Branch {
	t.Helper()
	r := apply(row{
		"id":         uuid.New(),
		"company_id": companyID,
		"name":       uniq("Branch"),
		"timezone":   "America/Chicago",
	}, opts)
	insert(t, "branches", r)
	return Branch{ID: r["id"].(uuid.UUID), CompanyID: companyID, Name: r["name"].(string)}
}

// NewRole inserts a roles row plus its role_permissions rows.
func NewRole(t testing.TB, companyID uuid.UUID, permissions []string, opts ...Option) Role {
	t.Helper()
	r := apply(row{
		"id":         uuid.New(),
		"company_id": companyID,
		"name":       uniq("Role"),
		"scope":      "company",
		"is_system":  false,
	}, opts)
	insert(t, "roles", r)

	id := r["id"].(uuid.UUID)
	for _, key := range permissions {
		_, err := AdminPool(t).Exec(Ctx(t),
			`INSERT INTO role_permissions (role_id, permission_key) VALUES ($1, $2)
			 ON CONFLICT DO NOTHING`, id, key)
		require.NoError(t, err, "grant permission %q", key)
	}

	return Role{
		ID:          id,
		CompanyID:   companyID,
		Name:        r["name"].(string),
		Scope:       r["scope"].(string),
		Permissions: append([]string(nil), permissions...),
	}
}

// NewUser inserts a users row. When no role is supplied through WithRole a
// permissionless role is created for the same company.
func NewUser(t testing.TB, companyID uuid.UUID, opts ...Option) User {
	t.Helper()
	base := row{
		"id":            uuid.New(),
		"company_id":    companyID,
		"first_name":    "Test",
		"last_name":     uniq("User"),
		"username":      strings.ToLower(uniq("user")),
		"password_hash": "$argon2id$test$fixture",
		"status":        "active",
	}
	r := apply(base, opts)
	if _, ok := r["email"]; !ok {
		r["email"] = r["username"].(string) + "@example.test"
	}
	if _, ok := r["role_id"]; !ok {
		r["role_id"] = NewRole(t, companyID, nil).ID
	}
	insert(t, "users", r)

	u := User{
		ID:        r["id"].(uuid.UUID),
		CompanyID: companyID,
		RoleID:    r["role_id"].(uuid.UUID),
		Username:  r["username"].(string),
		Email:     r["email"].(string),
		Status:    r["status"].(string),
		Password:  "Test-Passw0rd!",
	}
	if v, ok := r["branch_id"].(uuid.UUID); ok {
		u.BranchID = &v
	}
	return u
}

// NewDriver inserts a drivers row. When no user is supplied through WithUser a
// user is created for the same company.
func NewDriver(t testing.TB, companyID uuid.UUID, opts ...Option) Driver {
	t.Helper()
	r := apply(row{
		"id":         uuid.New(),
		"company_id": companyID,
		"status":     "active",
	}, opts)
	if _, ok := r["user_id"]; !ok {
		r["user_id"] = NewUser(t, companyID).ID
	}
	insert(t, "drivers", r)
	return Driver{
		ID:        r["id"].(uuid.UUID),
		CompanyID: companyID,
		UserID:    r["user_id"].(uuid.UUID),
		Status:    r["status"].(string),
	}
}

// NewUnit inserts a units row.
func NewUnit(t testing.TB, companyID uuid.UUID, opts ...Option) Unit {
	t.Helper()
	r := apply(row{
		"id":          uuid.New(),
		"company_id":  companyID,
		"unit_number": uniq("UNIT"),
		"status":      "active",
	}, opts)
	insert(t, "units", r)
	u := Unit{
		ID:         r["id"].(uuid.UUID),
		CompanyID:  companyID,
		UnitNumber: r["unit_number"].(string),
		Status:     r["status"].(string),
	}
	if v, ok := r["vin"].(string); ok {
		u.VIN = v
	}
	return u
}

// NewEldDevice inserts an eld_devices row.
func NewEldDevice(t testing.TB, companyID uuid.UUID, opts ...Option) EldDevice {
	t.Helper()
	r := apply(row{
		"id":         uuid.New(),
		"company_id": companyID,
		"vendor":     "TestVendor",
		"serial":     uniq("SN"),
		"status":     "active",
	}, opts)
	insert(t, "eld_devices", r)
	d := EldDevice{
		ID:        r["id"].(uuid.UUID),
		CompanyID: companyID,
		Vendor:    r["vendor"].(string),
		Serial:    r["serial"].(string),
		Status:    r["status"].(string),
	}
	if v, ok := r["unit_id"].(uuid.UUID); ok {
		d.UnitID = &v
	}
	return d
}

// NewTrailer inserts a trailers row.
func NewTrailer(t testing.TB, companyID uuid.UUID, opts ...Option) Trailer {
	t.Helper()
	r := apply(row{
		"id":         uuid.New(),
		"company_id": companyID,
		"number":     uniq("TRL"),
	}, opts)
	insert(t, "trailers", r)
	return Trailer{ID: r["id"].(uuid.UUID), CompanyID: companyID, Number: r["number"].(string)}
}

// NewShippingDocument inserts a shipping_documents row.
func NewShippingDocument(t testing.TB, companyID uuid.UUID, opts ...Option) ShippingDocument {
	t.Helper()
	r := apply(row{
		"id":         uuid.New(),
		"company_id": companyID,
		"number":     uniq("BOL"),
	}, opts)
	insert(t, "shipping_documents", r)
	return ShippingDocument{ID: r["id"].(uuid.UUID), CompanyID: companyID, Number: r["number"].(string)}
}

// NewDutyStatusEvent inserts a duty_status_events row. driver_id stays NULL
// unless WithDriver/WithDriverID is given (NULL means unidentified driving).
func NewDutyStatusEvent(t testing.TB, companyID uuid.UUID, opts ...Option) DutyStatusEvent {
	t.Helper()
	r := apply(row{
		"id":              uuid.New(),
		"company_id":      companyID,
		"event_type":      "duty_status",
		"status":          "DR",
		"special":         "none",
		"event_time":      time.Now().UTC().Truncate(time.Second),
		"time_source":     "server",
		"origin":          "auto",
		"client_event_id": uuid.New(),
	}, opts)
	insert(t, "duty_status_events", r)

	e := DutyStatusEvent{
		ID:            r["id"].(uuid.UUID),
		CompanyID:     companyID,
		EventType:     r["event_type"].(string),
		EventTime:     r["event_time"].(time.Time),
		ClientEventID: r["client_event_id"].(uuid.UUID),
	}
	if v, ok := r["status"].(string); ok {
		e.Status = v
	}
	if v, ok := r["driver_id"].(uuid.UUID); ok {
		e.DriverID = &v
	}
	if v, ok := r["unit_id"].(uuid.UUID); ok {
		e.UnitID = &v
	}
	return e
}

// NewDailyLog inserts a daily_logs row, creating a driver when none is given.
func NewDailyLog(t testing.TB, companyID uuid.UUID, opts ...Option) DailyLog {
	t.Helper()
	r := apply(row{
		"id":                   uuid.New(),
		"company_id":           companyID,
		"log_date":             time.Now().UTC().Truncate(24 * time.Hour),
		"timezone":             "America/Chicago",
		"certification_status": "uncertified",
	}, opts)
	if _, ok := r["driver_id"]; !ok {
		r["driver_id"] = NewDriver(t, companyID).ID
	}
	insert(t, "daily_logs", r)
	return DailyLog{
		ID:                  r["id"].(uuid.UUID),
		CompanyID:           companyID,
		DriverID:            r["driver_id"].(uuid.UUID),
		LogDate:             r["log_date"].(time.Time),
		CertificationStatus: r["certification_status"].(string),
	}
}

// NewDvirReport inserts a dvir_reports row, creating unit and driver when none
// are given.
func NewDvirReport(t testing.TB, companyID uuid.UUID, opts ...Option) DvirReport {
	t.Helper()
	r := apply(row{
		"id":           uuid.New(),
		"company_id":   companyID,
		"type":         "pre_trip",
		"status":       "submitted_no_defects",
		"source":       "app",
		"performed_at": time.Now().UTC().Truncate(time.Second),
	}, opts)
	if _, ok := r["unit_id"]; !ok {
		r["unit_id"] = NewUnit(t, companyID).ID
	}
	if _, ok := r["driver_id"]; !ok {
		r["driver_id"] = NewDriver(t, companyID).ID
	}
	insert(t, "dvir_reports", r)
	return DvirReport{
		ID:          r["id"].(uuid.UUID),
		CompanyID:   companyID,
		UnitID:      r["unit_id"].(uuid.UUID),
		DriverID:    r["driver_id"].(uuid.UUID),
		Type:        r["type"].(string),
		Status:      r["status"].(string),
		PerformedAt: r["performed_at"].(time.Time),
	}
}

// SoftDelete stamps deleted_at on a row; used by the partial unique index tests.
func SoftDelete(t testing.TB, table string, id uuid.UUID) {
	t.Helper()
	require.True(t, safeIdent(table), "unsafe table name %q", table)
	_, err := AdminPool(t).Exec(Ctx(t),
		fmt.Sprintf("UPDATE %s SET deleted_at = now() WHERE id = $1", table), id)
	require.NoError(t, err, "soft delete %s", table)
}

// ---------------------------------------------------------------- internals

// insert writes r into table through the superuser pool (fixtures are "given"
// data and must not be blocked by RLS) and asserts the generated id matches.
func insert(t testing.TB, table string, r row) {
	t.Helper()

	cols := make([]string, 0, len(r))
	for c := range r {
		cols = append(cols, c)
	}
	sort.Strings(cols)

	args := make([]any, 0, len(cols))
	ph := make([]string, 0, len(cols))
	for i, c := range cols {
		ph = append(ph, fmt.Sprintf("$%d", i+1))
		args = append(args, r[c])
	}

	q := fmt.Sprintf("INSERT INTO %s (%s) VALUES (%s)",
		table, strings.Join(cols, ", "), strings.Join(ph, ", "))
	_, err := AdminPool(t).Exec(Ctx(t), q, args...)
	require.NoError(t, err, "insert into %s", table)
}

var seq atomic.Int64

// runID is per process entropy. The shared test stack (make test-env-up) is
// reused by several `go test` processes at once, and seq restarts at zero in
// each of them: without runID two processes that start inside the same
// millisecond generate the same name and collide on companies_name_uniq.
var runID = func() string {
	var b [6]byte
	if _, err := rand.Read(b[:]); err != nil {
		return strconv.FormatInt(time.Now().UnixNano(), 36)
	}
	return hex.EncodeToString(b[:])
}()

func uniq(prefix string) string {
	return fmt.Sprintf("%s-%s-%d", prefix, runID, seq.Add(1))
}
