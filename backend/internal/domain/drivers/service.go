// Package drivers implements Driver Management: the drivers CRUD, activation,
// the activity feed, symmetric co-driver pairs and invitation resending. It
// implements server.Module.
package drivers

import (
	"context"
	"log/slog"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/db"
	authdomain "github.com/devline/onebook-eld/internal/domain/auth"
	"github.com/devline/onebook-eld/internal/domain/drivers/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Q18.3: username is 4..32 characters of [a-z0-9._].
var usernameRe = regexp.MustCompile(`^[a-z0-9._]{4,32}$`)

// DriverRoleName is the system role every driver account is created with.
const DriverRoleName = "Driver"

// Sortable columns of GET /drivers (whitelist; nothing is concatenated).
var sortFields = []string{"name", "username", "status", "created_at"}

// Deps are the driver service collaborators.
type Deps struct {
	Repo        Repo
	Cipher      *appcrypto.Cipher
	Audit       audit.Recorder
	Notifier    authdomain.Notifier
	Revocations *core.Revocations
	Verifier    mw.AuthVerifier
	Logger      *slog.Logger
	// Now is overridable in tests.
	Now func() time.Time
}

// Service holds the driver business logic. It never touches SQL directly.
type Service struct {
	repo        Repo
	cipher      *appcrypto.Cipher
	recorder    audit.Recorder
	notifier    authdomain.Notifier
	revocations *core.Revocations
	log         *slog.Logger
	now         func() time.Time
}

// NewService wires the driver service.
func NewService(d Deps) *Service {
	s := &Service{
		repo:        d.Repo,
		cipher:      d.Cipher,
		recorder:    d.Audit,
		notifier:    d.Notifier,
		revocations: d.Revocations,
		log:         d.Logger,
		now:         d.Now,
	}
	if s.log == nil {
		s.log = slog.Default()
	}
	if s.recorder == nil {
		s.recorder = audit.NopRecorder{}
	}
	if s.now == nil {
		s.now = time.Now
	}
	return s
}

// RequestMeta carries the transport facts the audit trail records. It is filled
// by the handler, never from the JSON body.
type RequestMeta struct {
	IP        string
	UserAgent string
}

// ListParams is the parsed GET /drivers query.
type ListParams struct {
	Search          string
	Status          string
	BranchID        *uuid.UUID
	FleetManagerID  *uuid.UUID
	IncludeInactive bool
	Sort            httpx.Sort
	Page            httpx.Page
}

// List returns one page of drivers, narrowed by the caller scope.
func (s *Service) List(ctx context.Context, scope mw.ScopeFilter, in ListParams) ([]dto.Driver, httpx.Meta, error) {
	companyID, err := requireCompany(ctx)
	if err != nil {
		return nil, httpx.Meta{}, err
	}
	if in.Status != "" && !isStatus(in.Status) {
		return nil, httpx.Meta{}, apierr.Validation("invalid filter",
			apierr.FieldError{Field: "status", Message: "must be one of: invited, active, inactive"})
	}

	f := ListFilter{
		CompanyID:       companyID,
		Search:          pgconv.NilIfEmpty(strings.TrimSpace(in.Search)),
		Status:          pgconv.NilIfEmpty(in.Status),
		BranchID:        in.BranchID,
		FleetManagerID:  in.FleetManagerID,
		IncludeInactive: in.IncludeInactive,
		SortKey:         sortKey(in.Sort),
		Limit:           in.Page.Limit(),
		Offset:          in.Page.Offset(),
	}
	// A branch scoped principal never sees outside its own branch, whatever
	// branch_id the query asked for.
	if scope.Scope == tenant.ScopeBranch && scope.BranchID != nil {
		f.BranchID = scope.BranchID
	}

	rows, total, err := s.repo.List(ctx, f)
	if err != nil {
		return nil, httpx.Meta{}, db.MapError(err, "driver")
	}

	out := make([]dto.Driver, 0, len(rows))
	for _, row := range rows {
		out = append(out, driverFromList(row, s.decryptLicense))
	}
	return out, in.Page.Meta(total), nil
}

// Get returns one driver. A record of another tenant is reported as 404.
func (s *Service) Get(ctx context.Context, scope mw.ScopeFilter, id uuid.UUID) (*dto.Driver, error) {
	row, err := s.fetch(ctx, scope, id)
	if err != nil {
		return nil, err
	}
	out := driverFromDetail(row, s.decryptLicense)
	return &out, nil
}

// License returns the decrypted licence number. The handler gates it behind
// `drivers.license.view`; it is never part of a list or of the driver payload.
// Every reveal is written to audit_log before the value is returned: the clear
// text itself is never audited, only the fact that it was served.
func (s *Service) License(ctx context.Context, scope mw.ScopeFilter, id uuid.UUID,
	meta RequestMeta) (*dto.DriverLicense, error) {
	row, err := s.fetch(ctx, scope, id)
	if err != nil {
		return nil, err
	}
	plain, err := s.decryptLicenseErr(row.LicenseNoEnc)
	if err != nil {
		return nil, err
	}

	companyID, err := requireCompany(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.recorder.Record(ctx, audit.Entry{
		TableName: "drivers",
		RecordID:  row.ID,
		Field:     "license_no",
		Action:    audit.ActionLicenseReveal,
		NewValue:  map[string]any{"revealed": true, "license_no_masked": maskLicense(plain)},
		CompanyID: companyID,
		IP:        meta.IP,
	}); err != nil {
		// Failing closed: an unrecorded reveal must not happen.
		return nil, apierr.Internal(err, "could not audit the licence reveal")
	}

	return &dto.DriverLicense{
		DriverID:  row.ID.String(),
		LicenseNo: plain,
		Region:    pgconv.Deref(row.LicenseRegion),
	}, nil
}

// Create provisions a driver: a users row with the Driver role and
// status=invited, the drivers row, an optional co-driver pair and an invitation
// link. Q18.1: the request carries no password.
func (s *Service) Create(ctx context.Context, in dto.DriverCreate, meta RequestMeta) (*dto.Driver, error) {
	companyID, err := requireCompany(ctx)
	if err != nil {
		return nil, err
	}
	if err := validateCreate(in); err != nil {
		return nil, err
	}

	role, err := s.repo.RoleByName(ctx, companyID, DriverRoleName)
	if err != nil {
		if db.IsNoRows(err) {
			return nil, apierr.New(apierr.CodeInvalidState, http.StatusConflict,
				"the Driver role is missing for this company")
		}
		return nil, db.MapError(err, "role")
	}

	licenseEnc, err := s.encryptLicense(strings.TrimSpace(in.LicenseNo))
	if err != nil {
		return nil, err
	}

	now := s.now().UTC()
	channel, recipient := invitationChannel(in.Email, in.Phone)
	token, err := appcrypto.RandomToken(core.RefreshTokenBytes)
	if err != nil {
		return nil, apierr.Internal(err, "could not create an invitation token")
	}
	expiresAt := now.Add(core.InvitationTTL)

	var coDriverID *uuid.UUID
	if in.CoDriverID != "" {
		id, perr := uuid.Parse(in.CoDriverID)
		if perr != nil {
			return nil, apierr.Validation("invalid co_driver_id",
				apierr.FieldError{Field: "co_driver_id", Message: "must be a valid uuid"})
		}
		if _, err := s.repo.Get(ctx, companyID, id); err != nil {
			return nil, db.MapError(err, "co-driver")
		}
		coDriverID = &id
	}

	input := CreateInput{
		CompanyID:      companyID,
		RoleID:         role.ID,
		BranchID:       parseOptionalUUID(in.BranchID),
		FirstName:      strings.TrimSpace(in.FirstName),
		LastName:       strings.TrimSpace(in.LastName),
		Username:       strings.ToLower(strings.TrimSpace(in.Username)),
		Email:          pgconv.NilIfEmpty(strings.ToLower(strings.TrimSpace(in.Email))),
		Phone:          pgconv.NilIfEmpty(strings.TrimSpace(in.Phone)),
		LicenseNoEnc:   licenseEnc,
		LicenseRegion:  pgconv.NilIfEmpty(in.LicenseRegion),
		HomeTerminal:   pgconv.NilIfEmpty(in.HomeTerminal),
		City:           pgconv.NilIfEmpty(in.City),
		State:          pgconv.NilIfEmpty(in.State),
		Zip:            pgconv.NilIfEmpty(in.Zip),
		Address1:       pgconv.NilIfEmpty(in.Address1),
		Address2:       pgconv.NilIfEmpty(in.Address2),
		Notes:          pgconv.NilIfEmpty(in.Notes),
		FleetManagerID: parseOptionalUUID(in.FleetManagerID),
		DefaultUnitID:  parseOptionalUUID(in.DefaultUnitID),
		CoDriverID:     coDriverID,
		InvitedAt:      now,
		Invitation: &InvitationInput{
			TokenHash: appcrypto.HashSHA256(token),
			Channel:   channel,
			Purpose:   authdomain.PurposeInvitation,
			ExpiresAt: expiresAt,
		},
	}

	entries := []audit.Entry{{
		TableName: "drivers",
		Field:     "created",
		Action:    audit.ActionCreate,
		NewValue: map[string]any{
			"username":       input.Username,
			"status":         dto.StatusInvited,
			"branch_id":      in.BranchID,
			"home_terminal":  in.HomeTerminal,
			"license_region": in.LicenseRegion,
		},
		CompanyID: companyID,
		IP:        meta.IP,
	}}

	row, err := s.repo.Create(ctx, input, entries)
	if err != nil {
		return nil, db.MapError(err, "driver")
	}

	s.deliverInvitation(ctx, row.UserID, companyID, channel, recipient,
		authdomain.PurposeInvitation, token, expiresAt)

	out := driverFromDetail(row, s.decryptLicense)
	return &out, nil
}

// Update applies a partial change to the driver and its user row.
func (s *Service) Update(
	ctx context.Context, scope mw.ScopeFilter, id uuid.UUID, in dto.DriverUpdate, meta RequestMeta,
) (*dto.Driver, error) {
	current, err := s.fetch(ctx, scope, id)
	if err != nil {
		return nil, err
	}
	companyID := current.CompanyID

	if in.Email != nil && *in.Email == "" && (in.Phone == nil || *in.Phone == "") &&
		pgconv.Deref(current.Phone) == "" {
		return nil, apierr.Validation("a driver needs an email or a phone number",
			apierr.FieldError{Field: "email", Message: "email or phone is required"})
	}

	input := UpdateInput{
		CompanyID:      companyID,
		DriverID:       id,
		UserID:         current.UserID,
		FirstName:      trimPtr(in.FirstName),
		LastName:       trimPtr(in.LastName),
		Email:          lowerPtr(in.Email),
		Phone:          trimPtr(in.Phone),
		LicenseRegion:  in.LicenseRegion,
		HomeTerminal:   in.HomeTerminal,
		City:           in.City,
		State:          in.State,
		Zip:            in.Zip,
		Address1:       in.Address1,
		Address2:       in.Address2,
		Notes:          in.Notes,
		BranchID:       parseOptionalUUIDPtr(in.BranchID),
		FleetManagerID: parseOptionalUUIDPtr(in.FleetManagerID),
		DefaultUnitID:  parseOptionalUUIDPtr(in.DefaultUnitID),
	}

	if in.LicenseNo != nil {
		enc, err := s.encryptLicense(strings.TrimSpace(*in.LicenseNo))
		if err != nil {
			return nil, err
		}
		input.LicenseNoEnc = enc
	}

	before := map[string]any{
		"first_name":       current.FirstName,
		"last_name":        current.LastName,
		"email":            pgconv.Deref(current.Email),
		"phone":            pgconv.Deref(current.Phone),
		"license_no":       maskLicense(s.decryptLicense(current.LicenseNoEnc)),
		"license_region":   pgconv.Deref(current.LicenseRegion),
		"home_terminal":    pgconv.Deref(current.HomeTerminal),
		"city":             pgconv.Deref(current.City),
		"state":            pgconv.Deref(current.State),
		"zip":              pgconv.Deref(current.Zip),
		"address1":         pgconv.Deref(current.Address1),
		"address2":         pgconv.Deref(current.Address2),
		"notes":            pgconv.Deref(current.Notes),
		"branch_id":        pgconv.UUIDStringOrEmpty(current.BranchID),
		"fleet_manager_id": pgconv.UUIDStringOrEmpty(current.FleetManagerID),
		"default_unit_id":  pgconv.UUIDStringOrEmpty(current.DefaultUnitID),
	}
	after := changedFields(before, in)

	entries := audit.Changes("drivers", id, audit.ActionUpdate, before, after)
	for i := range entries {
		entries[i].CompanyID = companyID
		entries[i].IP = meta.IP
	}

	row, err := s.repo.Update(ctx, input, entries)
	if err != nil {
		return nil, db.MapError(err, "driver")
	}
	out := driverFromDetail(row, s.decryptLicense)
	return &out, nil
}
