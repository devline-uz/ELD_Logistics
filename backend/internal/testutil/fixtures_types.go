package testutil

import (
	"time"

	"github.com/google/uuid"
)

// ---------------------------------------------------------------- fixture rows

// Company is a seeded companies row.
type Company struct {
	ID   uuid.UUID
	Name string
}

// Branch is a seeded branches row.
type Branch struct {
	ID        uuid.UUID
	CompanyID uuid.UUID
	Name      string
}

// Role is a seeded roles row together with its permission keys.
type Role struct {
	ID          uuid.UUID
	CompanyID   uuid.UUID
	Name        string
	Scope       string
	Permissions []string
}

// User is a seeded users row. Password is the plaintext the fixture used; the
// stored hash is a placeholder, testutil never depends on internal/auth.
type User struct {
	ID        uuid.UUID
	CompanyID uuid.UUID
	RoleID    uuid.UUID
	BranchID  *uuid.UUID
	Username  string
	Email     string
	Status    string
	Password  string
}

// Driver is a seeded drivers row.
type Driver struct {
	ID        uuid.UUID
	CompanyID uuid.UUID
	UserID    uuid.UUID
	Status    string
}

// Unit is a seeded units row.
type Unit struct {
	ID         uuid.UUID
	CompanyID  uuid.UUID
	UnitNumber string
	VIN        string
	Status     string
}

// EldDevice is a seeded eld_devices row.
type EldDevice struct {
	ID        uuid.UUID
	CompanyID uuid.UUID
	UnitID    *uuid.UUID
	Vendor    string
	Serial    string
	Status    string
}

// Trailer is a seeded trailers row.
type Trailer struct {
	ID        uuid.UUID
	CompanyID uuid.UUID
	Number    string
}

// ShippingDocument is a seeded shipping_documents row.
type ShippingDocument struct {
	ID        uuid.UUID
	CompanyID uuid.UUID
	Number    string
}

// DutyStatusEvent is a seeded duty_status_events row.
type DutyStatusEvent struct {
	ID            uuid.UUID
	CompanyID     uuid.UUID
	DriverID      *uuid.UUID
	UnitID        *uuid.UUID
	EventType     string
	Status        string
	EventTime     time.Time
	ClientEventID uuid.UUID
}

// DailyLog is a seeded daily_logs row.
type DailyLog struct {
	ID                  uuid.UUID
	CompanyID           uuid.UUID
	DriverID            uuid.UUID
	LogDate             time.Time
	CertificationStatus string
}

// DvirReport is a seeded dvir_reports row.
type DvirReport struct {
	ID          uuid.UUID
	CompanyID   uuid.UUID
	UnitID      uuid.UUID
	DriverID    uuid.UUID
	Type        string
	Status      string
	PerformedAt time.Time
}

// ---------------------------------------------------------------- options

type row map[string]any

// Option overrides a column of the row a fixture builder is about to insert.
type Option func(row)

// With sets an arbitrary column. Prefer the named helpers below.
func With(column string, value any) Option { return func(r row) { r[column] = value } }

// Named option helpers.
func WithName(v string) Option             { return With("name", v) }
func WithStatus(v string) Option           { return With("status", v) }
func WithScope(v string) Option            { return With("scope", v) }
func WithNumber(v string) Option           { return With("number", v) }
func WithUnitNumber(v string) Option       { return With("unit_number", v) }
func WithVIN(v string) Option              { return With("vin", v) }
func WithSerial(v string) Option           { return With("serial", v) }
func WithVendor(v string) Option           { return With("vendor", v) }
func WithUsername(v string) Option         { return With("username", v) }
func WithEmail(v string) Option            { return With("email", v) }
func WithEventType(v string) Option        { return With("event_type", v) }
func WithEventTime(v time.Time) Option     { return With("event_time", v.UTC()) }
func WithLogDate(v time.Time) Option       { return With("log_date", v.UTC()) }
func WithPerformedAt(v time.Time) Option   { return With("performed_at", v.UTC()) }
func WithDeletedAt(v time.Time) Option     { return With("deleted_at", v.UTC()) }
func WithClientEventID(v uuid.UUID) Option { return With("client_event_id", v) }
func WithBranch(b Branch) Option           { return With("branch_id", b.ID) }
func WithBranchID(v uuid.UUID) Option      { return With("branch_id", v) }
func WithRole(r Role) Option               { return With("role_id", r.ID) }
func WithRoleID(v uuid.UUID) Option        { return With("role_id", v) }
func WithUser(u User) Option               { return With("user_id", u.ID) }
func WithUserID(v uuid.UUID) Option        { return With("user_id", v) }
func WithDriver(d Driver) Option           { return With("driver_id", d.ID) }
func WithDriverID(v uuid.UUID) Option      { return With("driver_id", v) }
func WithUnit(u Unit) Option               { return With("unit_id", u.ID) }
func WithUnitID(v uuid.UUID) Option        { return With("unit_id", v) }

func apply(r row, opts []Option) row {
	for _, o := range opts {
		if o != nil {
			o(r)
		}
	}
	return r
}
