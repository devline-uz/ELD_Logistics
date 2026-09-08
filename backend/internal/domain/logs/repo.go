package logs

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/hos"
)

// Duty status event types that a log edit may never touch (Q17.1).
const (
	eventDutyStatus   = "duty_status"
	eventIntermediate = "intermediate"
	eventPowerOn      = "power_on"
	eventPowerOff     = "power_off"
	eventMalfunction  = "malfunction"
	eventCertify      = "certification"
)

// Event origins (Q13.1).
const (
	originAuto       = "auto"
	originDriver     = "driver"
	originDriverEdit = "driver_edit"
	originAdminEdit  = "admin_edit"
)

// Certification states (Q19).
const certCertified = "certified"

// Edit request states and sources (Q17, §10.4).
const (
	editPending  = "pending"
	editApproved = "approved"
	editRejected = "rejected"

	sourceAdminEdit          = "admin_edit"
	sourceUnidentifiedAssign = "unidentified_assign"
)

// Unidentified driving block states (§10.4).
const (
	unidentifiedPending   = "pending"
	unidentifiedProposed  = "proposed"
	unidentifiedAssigned  = "assigned"
	unidentifiedAnnotated = "annotated"
)

// DailyLog is one daily_logs row plus the names the API needs. The sqlc model
// never leaves the repository.
type DailyLog struct {
	ID           uuid.UUID
	CompanyID    uuid.UUID
	DriverID     uuid.UUID
	DriverUserID uuid.UUID
	BranchID     *uuid.UUID
	DriverName   string
	CoDriverID   *uuid.UUID
	CoDriverName *string

	// LogDate is the home terminal calendar day (Q10.2).
	LogDate  time.Time
	Timezone string

	UnitIDs        []uuid.UUID
	TrailerIDs     []uuid.UUID
	ShippingDocIDs []uuid.UUID
	DistanceM      int64
	Totals         []byte

	CertificationStatus string
	SignedAt            *time.Time
	SignatureKey        *string
	SignedDeviceID      *string
	SignedIP            *string

	CarrierName         string
	HomeTerminalAddress *string
	RegulationProfile   string

	CreatedAt time.Time
	UpdatedAt time.Time
}

// Certified reports whether the day carries a valid signature.
func (l DailyLog) Certified() bool { return l.CertificationStatus == certCertified }

// Location resolves the home terminal timezone, falling back to UTC.
func (l DailyLog) Location() *time.Location {
	loc, err := time.LoadLocation(l.Timezone)
	if err != nil || loc == nil {
		return time.UTC
	}
	return loc
}

// Event is one duty_status_events row of a log day.
type Event struct {
	ID           uuid.UUID
	DriverID     *uuid.UUID
	UnitID       *uuid.UUID
	UnitNumber   *string
	EventType    string
	Status       *string
	Special      string
	Origin       string
	EventTime    time.Time
	TimeSource   string
	ReceivedAt   time.Time
	Lat          *float64
	Lng          *float64
	LocationText *string
	OdometerM    *int64
	EngineHours  *float64
	Notes        *string
	SupersededBy *uuid.UUID
	Locked       bool
	DailyLogID   *uuid.UUID
}

// HosEvent converts the row into the engine's event shape. Only `duty_status`
// rows move the state machine; every other kind is positional.
func (e Event) HosEvent() hos.Event {
	ev := hos.Event{Time: e.EventTime.UTC(), Special: hos.Special(e.Special)}
	if e.Status != nil {
		ev.Status = hos.Status(*e.Status)
	}
	if e.EventType == eventDutyStatus {
		ev.Type = hos.EventStatusChange
	} else {
		ev.Type = hos.EventType(e.EventType)
	}
	return ev
}

// Immutable reports whether the row may never be rewritten by an edit (Q17.1).
func (e Event) Immutable() bool {
	switch e.EventType {
	case eventIntermediate, eventPowerOn, eventPowerOff, eventMalfunction:
		return true
	}
	return false
}

// DailyLogFilter selects a page of one driver's log days.
type DailyLogFilter struct {
	CompanyID uuid.UUID
	DriverID  uuid.UUID
	From      time.Time
	To        time.Time
	Limit     int32
	Offset    int32
}

// UncertifiedFilter selects the admin "uncertified logs" report (Q19.1).
type UncertifiedFilter struct {
	CompanyID uuid.UUID
	// Before is the first day still inside the certification window; every
	// uncertified day strictly before it is overdue.
	Before   time.Time
	DriverID *uuid.UUID
	BranchID *uuid.UUID
	Limit    int32
	Offset   int32
}

// UncertifiedDay is one overdue log day.
type UncertifiedDay struct {
	DailyLogID          uuid.UUID
	DriverID            uuid.UUID
	DriverName          string
	LogDate             time.Time
	CertificationStatus string
}

// CertifyInput is one certification (Q26.1).
type CertifyInput struct {
	CompanyID    uuid.UUID
	DailyLogID   uuid.UUID
	DriverID     uuid.UUID
	UserID       uuid.UUID
	SignatureKey string
	DeviceID     *string
	IP           *string
	SignedAt     time.Time
	// ClientEventID makes the `certification` event idempotent.
	ClientEventID uuid.UUID
}

// PlannedEvent is one event an approved edit writes (Q17).
type PlannedEvent struct {
	Status    string
	Special   string
	EventTime time.Time
	Origin    string
	Note      string
	UnitID    *uuid.UUID
}

// EditGroup is one change turned into storage operations: the boundary events
// to insert and the stored rows the first of them supersedes. Nothing is
// deleted — the original rows stay, flagged (Q17).
type EditGroup struct {
	Boundary  []PlannedEvent
	Supersede []uuid.UUID
}

// EditPlan is a whole edit applied in one transaction.
type EditPlan struct {
	CompanyID  uuid.UUID
	DriverID   uuid.UUID
	DailyLogID uuid.UUID
	Timezone   string
	// Day is the local midnight of the log day being rewritten.
	Day time.Time
	// Certified marks a day that has to fall back to needs_recertify (Q18).
	Certified bool
	Groups    []EditGroup
	// AssignEventIDs are unidentified rows handed to the driver (§10.4).
	AssignEventIDs []uuid.UUID
	// ResolveRequestID closes the originating edit request in the same
	// transaction; nil for a driver self edit.
	ResolveRequestID *uuid.UUID
	ResolveStatus    string
	ResolveBy        uuid.UUID
	ResolveNote      *string
	// UnidentifiedID moves the driving block along with the approval.
	UnidentifiedID *uuid.UUID
}

// EditRequest is one log_edit_requests row plus the joined names.
type EditRequest struct {
	ID                  uuid.UUID
	CompanyID           uuid.UUID
	DriverID            uuid.UUID
	DriverUserID        uuid.UUID
	BranchID            *uuid.UUID
	DriverName          string
	DailyLogID          uuid.UUID
	LogDate             time.Time
	Timezone            string
	RequestedBy         uuid.UUID
	Status              string
	Source              string
	Changes             []byte
	DriverNote          *string
	UnidentifiedEventID *uuid.UUID
	ResolvedAt          *time.Time
	CreatedAt           time.Time
	UpdatedAt           time.Time
}

// EditRequestFilter selects a page of the propose/approve queue.
type EditRequestFilter struct {
	CompanyID uuid.UUID
	Status    *string
	DriverID  *uuid.UUID
	BranchID  *uuid.UUID
	Limit     int32
	Offset    int32
}

// PendingEdit is the compact shape /sync/pull ships to the device.
type PendingEdit struct {
	ID         uuid.UUID
	DailyLogID uuid.UUID
	Status     string
	Source     string
	Changes    []byte
	LogDate    time.Time
	Timezone   string
	CreatedAt  time.Time
	UpdatedAt  time.Time
}

// Unidentified is one unidentified_events row (§10.4).
type Unidentified struct {
	ID               uuid.UUID
	CompanyID        uuid.UUID
	UnitID           uuid.UUID
	UnitNumber       string
	StartAt          time.Time
	EndAt            *time.Time
	DistanceM        int64
	Status           string
	AssignedDriverID *uuid.UUID
	Annotation       *string
	EditRequestID    *uuid.UUID
	CreatedAt        time.Time
}

// Window bounds the driving block; an open block ends at start.
func (u Unidentified) Window() (time.Time, time.Time) {
	if u.EndAt == nil {
		return u.StartAt, u.StartAt
	}
	return u.StartAt, *u.EndAt
}

// ViolationRow is one violations row plus the joined names.
type ViolationRow struct {
	ID              uuid.UUID
	DriverID        *uuid.UUID
	DriverName      *string
	DailyLogID      *uuid.UUID
	LogDate         *time.Time
	UnitID          *uuid.UUID
	BranchID        *uuid.UUID
	Type            string
	Severity        string
	OccurredAt      time.Time
	Details         []byte
	PolicyVersionID *uuid.UUID
	ResolvedAt      *time.Time
	ResolvedReason  *string
	CreatedAt       time.Time
}

// ViolationFilter selects a page of the violation list (Q59: independent
// filters).
type ViolationFilter struct {
	CompanyID uuid.UUID
	DriverID  *uuid.UUID
	BranchID  *uuid.UUID
	Type      *string
	Severity  *string
	Resolved  *bool
	From      *time.Time
	To        *time.Time
	Limit     int32
	Offset    int32
}

// ViolationItem is one computed violation ready for storage.
type ViolationItem struct {
	Type       string
	Severity   string
	OccurredAt time.Time
	Details    []byte
}

// ViolationSync rewrites the open violations of one log day: everything the
// engine still reports is upserted, everything it no longer reports is closed
// with a reason. Nothing is ever deleted (Q58).
type ViolationSync struct {
	CompanyID       uuid.UUID
	DriverID        uuid.UUID
	DailyLogID      uuid.UUID
	UnitID          *uuid.UUID
	PolicyVersionID *uuid.UUID
	Items           []ViolationItem
}

// UnidentifiedViolation raises or closes the 8 day unassigned driving alert.
type UnidentifiedViolation struct {
	CompanyID  uuid.UUID
	EventID    uuid.UUID
	UnitID     *uuid.UUID
	OccurredAt time.Time
	Details    []byte
}

// Repo is everything the logs service needs from storage.
type Repo interface {
	DailyLogs(ctx context.Context, f DailyLogFilter) ([]DailyLog, int64, error)
	DailyLog(ctx context.Context, companyID, id uuid.UUID) (DailyLog, error)
	DailyLogFor(ctx context.Context, companyID, driverID uuid.UUID, day time.Time, tz string) (uuid.UUID, error)
	DayEvents(ctx context.Context, companyID, dailyLogID uuid.UUID) ([]Event, error)
	DriverEvents(ctx context.Context, companyID, driverID uuid.UUID, from, to time.Time) ([]Event, error)
	UnassignedEvents(ctx context.Context, companyID, unitID uuid.UUID, from, to time.Time) ([]Event, error)

	UncertifiedOlderThan(ctx context.Context, f UncertifiedFilter) ([]UncertifiedDay, int64, error)
	UncertifiedInWindow(ctx context.Context, companyID, driverID uuid.UUID, from, to time.Time) ([]UncertifiedDay, error)

	SignatureKey(ctx context.Context, companyID, userID uuid.UUID, id *uuid.UUID) (string, error)
	Units(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) ([]UnitRef, error)
	Trailers(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) ([]NumberRef, error)
	ShippingDocs(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) ([]NumberRef, error)

	Certify(ctx context.Context, in CertifyInput, entries []audit.Entry) (DailyLog, error)
	ApplyEdit(ctx context.Context, plan EditPlan, entries []audit.Entry) error

	CreateEditRequest(ctx context.Context, in EditRequest, entries []audit.Entry) (EditRequest, error)
	// CreateAssignmentRequest implements the §10.4 unidentified assignment
	// proposal atomically: the log_edit_requests row and the
	// unidentified_events status flip both land in one transaction, so a
	// mid-transaction failure never leaves the block `pending` behind an
	// orphaned request, nor a stored request for a block that never moved to
	// `proposed`.
	CreateAssignmentRequest(ctx context.Context, req EditRequest, blockID, driverID, by uuid.UUID,
		requestEntries, proposeEntries []audit.Entry) (EditRequest, error)
	EditRequest(ctx context.Context, companyID, id uuid.UUID) (EditRequest, error)
	EditRequests(ctx context.Context, f EditRequestFilter) ([]EditRequest, int64, error)
	RejectEditRequest(ctx context.Context, companyID, id uuid.UUID, by uuid.UUID, reason string,
		unidentifiedID *uuid.UUID, entries []audit.Entry) (EditRequest, error)
	PendingEditsForDriver(ctx context.Context, companyID, driverID uuid.UUID, since time.Time, limit int32) ([]PendingEdit, error)

	Unidentified(ctx context.Context, companyID, id uuid.UUID) (Unidentified, error)
	AnnotateUnidentified(ctx context.Context, companyID, id, by uuid.UUID, annotation string, entries []audit.Entry) (Unidentified, error)
	StaleUnidentified(ctx context.Context, companyID uuid.UUID, before time.Time) ([]Unidentified, error)

	SyncViolations(ctx context.Context, in ViolationSync) error
	RaiseUnidentifiedViolation(ctx context.Context, in UnidentifiedViolation) error
	ResolveUnidentifiedViolation(ctx context.Context, companyID, eventID uuid.UUID, reason string, by *uuid.UUID) error
	Violations(ctx context.Context, f ViolationFilter) ([]ViolationRow, int64, error)
	Violation(ctx context.Context, companyID, id uuid.UUID) (ViolationRow, error)
	// LogViolations returns every violation of one log day, open or closed.
	LogViolations(ctx context.Context, companyID, dailyLogID uuid.UUID) ([]ViolationRow, error)
}

// UnitRef is a unit as the log form shows it.
type UnitRef struct {
	ID           uuid.UUID
	UnitNumber   string
	VIN          *string
	LicensePlate *string
}

// NumberRef is a trailer or shipping document reference.
type NumberRef struct {
	ID     uuid.UUID
	Number string
}

// TxRunner is the subset of *db.Pool this repository needs.
type TxRunner interface {
	WithTx(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error
	WithConn(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error
}
