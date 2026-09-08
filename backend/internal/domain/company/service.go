// Package company is the tenant facing configuration module: company profile,
// branches, HOS policy versions, notification settings and the configuration
// audit trail. It implements server.Module.
package company

import (
	"context"
	"log/slog"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/company/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Audited table names.
const (
	tableCompanies      = "companies"
	tableBranches       = "branches"
	tableHosPolicy      = "hos_policy_versions"
	tableNotifSettings  = "notification_settings"
	actionHosPolicy     = audit.Action("hos_policy_change")
	maxNotificationRows = 64
)

// RequestMeta carries the transport facts an audit row records. It is filled
// by the handler from the request, never from the JSON body.
type RequestMeta struct {
	IP string
}

// ServiceDeps are the company service collaborators.
type ServiceDeps struct {
	Repo   Repo
	Logger *slog.Logger
	// Now is overridable in tests.
	Now func() time.Time
}

// Service holds the company business rules. It never touches pgx directly.
type Service struct {
	repo Repo
	log  *slog.Logger
	now  func() time.Time
}

// NewService builds the company service.
func NewService(deps ServiceDeps) *Service {
	log := deps.Logger
	if log == nil {
		log = slog.Default()
	}
	now := deps.Now
	if now == nil {
		now = func() time.Time { return time.Now().UTC() }
	}
	return &Service{repo: deps.Repo, log: log, now: now}
}

func companyOf(ctx context.Context) (uuid.UUID, error) {
	id, ok := tenant.CompanyIDOK(ctx)
	if !ok {
		return uuid.Nil, apierr.Forbidden("no active company for this session")
	}
	return id, nil
}

// Get returns the tenant profile.
func (s *Service) Get(ctx context.Context) (*dto.Company, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}
	row, err := s.repo.Company(ctx, companyID)
	if err != nil {
		return nil, err
	}
	out := ToCompany(row)
	return &out, nil
}

// Update patches the tenant profile and records one audit row per changed
// field.
func (s *Service) Update(ctx context.Context, in dto.CompanyUpdate, meta RequestMeta) (*dto.Company, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}

	before, err := s.repo.Company(ctx, companyID)
	if err != nil {
		return nil, err
	}

	params := db.UpdateCompanyParams{
		ID:                  companyID,
		Name:                trimPtr(in.Name),
		Address:             trimPtr(in.Address),
		HomeTerminalAddress: trimPtr(in.HomeTerminalAddress),
		Timezone:            trimPtr(in.Timezone),
		Email:               lowerPtr(in.Email),
		Phone:               trimPtr(in.Phone),
		RegistrationNo:      trimPtr(in.RegistrationNo),
		LogoKey:             trimPtr(in.LogoKey),
		Region:              trimPtr(in.Region),
		UnitSystem:          trimPtr(in.UnitSystem),
		RegulationProfile:   trimPtr(in.RegulationProfile),
	}
	if params.Timezone != nil {
		if err := validateTimezone("timezone", *params.Timezone); err != nil {
			return nil, err
		}
	}
	if in.Settings != nil {
		raw, err := mergeSettings(before, *in.Settings, params.Region)
		if err != nil {
			return nil, err
		}
		params.Settings = raw
	}

	entries := audit.Changes(tableCompanies, companyID, audit.ActionUpdate,
		companyFields(before), patchFields(params, in.Settings))
	for i := range entries {
		entries[i].IP = meta.IP
	}

	after, err := s.repo.UpdateCompany(ctx, UpdateCompanyInput{
		CompanyID: companyID, Params: params, Audit: entries,
	})
	if err != nil {
		return nil, err
	}
	out := ToCompany(after)
	return &out, nil
}

// ListBranches returns the paginated branch collection.
func (s *Service) ListBranches(ctx context.Context, page httpx.Page, sort httpx.Sort, search string) ([]dto.Branch, int64, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, 0, err
	}
	rows, total, err := s.repo.ListBranches(ctx, ListBranchesInput{
		CompanyID: companyID,
		Search:    optString(search),
		SortBy:    sort.Field,
		SortDir:   sort.Order,
		Limit:     page.Limit(),
		Offset:    page.Offset(),
	})
	if err != nil {
		return nil, 0, err
	}
	out := make([]dto.Branch, 0, len(rows))
	for _, b := range rows {
		out = append(out, toBranch(b))
	}
	return out, total, nil
}

// CreateBranch adds a branch.
func (s *Service) CreateBranch(ctx context.Context, in dto.BranchCreate, meta RequestMeta) (*dto.Branch, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}
	name := strings.TrimSpace(in.Name)
	if name == "" {
		return nil, apierr.Validation("validation failed",
			apierr.FieldError{Field: "name", Message: "required"})
	}
	tz := strings.TrimSpace(in.Timezone)
	if tz != "" {
		if err := validateTimezone("timezone", tz); err != nil {
			return nil, err
		}
	}

	entries := audit.Changes(tableBranches, uuid.Nil, audit.ActionCreate, nil, map[string]any{
		"name":     name,
		"address":  strings.TrimSpace(in.Address),
		"timezone": tz,
	})
	for i := range entries {
		entries[i].IP = meta.IP
	}

	row, err := s.repo.CreateBranch(ctx, CreateBranchInput{
		CompanyID: companyID,
		Name:      name,
		Address:   optString(in.Address),
		Timezone:  optString(tz),
		Audit:     entries,
	})
	if err != nil {
		return nil, err
	}
	out := toBranch(row)
	return &out, nil
}

// UpdateBranch patches a branch. A branch of another tenant answers 404.
func (s *Service) UpdateBranch(ctx context.Context, id uuid.UUID, in dto.BranchUpdate, meta RequestMeta) (*dto.Branch, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}
	before, err := s.repo.GetBranch(ctx, companyID, id)
	if err != nil {
		return nil, err
	}
	if in.Timezone != nil {
		if err := validateTimezone("timezone", strings.TrimSpace(*in.Timezone)); err != nil {
			return nil, err
		}
	}

	after := map[string]any{}
	if in.Name != nil {
		after["name"] = strings.TrimSpace(*in.Name)
	}
	if in.Address != nil {
		after["address"] = strings.TrimSpace(*in.Address)
	}
	if in.Timezone != nil {
		after["timezone"] = strings.TrimSpace(*in.Timezone)
	}
	entries := audit.Changes(tableBranches, id, audit.ActionUpdate, branchFields(before), after)
	for i := range entries {
		entries[i].IP = meta.IP
	}

	row, err := s.repo.UpdateBranch(ctx, UpdateBranchInput{
		CompanyID: companyID, ID: id,
		Name:     trimPtr(in.Name),
		Address:  trimPtr(in.Address),
		Timezone: trimPtr(in.Timezone),
		Audit:    entries,
	})
	if err != nil {
		return nil, err
	}
	out := toBranch(row)
	return &out, nil
}

// DeleteBranch soft deletes a branch.
func (s *Service) DeleteBranch(ctx context.Context, id uuid.UUID, meta RequestMeta) error {
	companyID, err := companyOf(ctx)
	if err != nil {
		return err
	}
	before, err := s.repo.GetBranch(ctx, companyID, id)
	if err != nil {
		return err
	}
	return s.repo.DeleteBranch(ctx, DeleteBranchInput{
		CompanyID: companyID, ID: id,
		Audit: []audit.Entry{{
			TableName: tableBranches,
			RecordID:  id,
			Field:     "deleted_at",
			OldValue:  nil,
			NewValue:  s.now().Format(time.RFC3339),
			Action:    audit.ActionDelete,
			IP:        meta.IP,
			Reason:    "branch " + before.Name + " removed",
		}},
	})
}

func companyFields(c db.Company) map[string]any {
	return map[string]any{
		"name":                  c.Name,
		"address":               pgconv.Deref(c.Address),
		"home_terminal_address": pgconv.Deref(c.HomeTerminalAddress),
		"timezone":              c.Timezone,
		"email":                 pgconv.Deref(c.Email),
		"phone":                 pgconv.Deref(c.Phone),
		"registration_no":       pgconv.Deref(c.RegistrationNo),
		"logo_key":              pgconv.Deref(c.LogoKey),
		"region":                pgconv.Deref(c.Region),
		"unit_system":           c.UnitSystem,
		"regulation_profile":    c.RegulationProfile,
	}
}

func patchFields(p db.UpdateCompanyParams, settings *dto.Settings) map[string]any {
	out := map[string]any{}
	put := func(k string, v *string) {
		if v != nil {
			out[k] = *v
		}
	}
	put("name", p.Name)
	put("address", p.Address)
	put("home_terminal_address", p.HomeTerminalAddress)
	put("timezone", p.Timezone)
	put("email", p.Email)
	put("phone", p.Phone)
	put("registration_no", p.RegistrationNo)
	put("logo_key", p.LogoKey)
	put("region", p.Region)
	put("unit_system", p.UnitSystem)
	put("regulation_profile", p.RegulationProfile)
	if settings != nil {
		out["settings"] = string(p.Settings)
	}
	return out
}

func branchFields(b db.Branch) map[string]any {
	return map[string]any{
		"name":     b.Name,
		"address":  pgconv.Deref(b.Address),
		"timezone": pgconv.Deref(b.Timezone),
	}
}

func trimPtr(v *string) *string {
	if v == nil {
		return nil
	}
	s := strings.TrimSpace(*v)
	return &s
}

func lowerPtr(v *string) *string {
	if v == nil {
		return nil
	}
	s := strings.ToLower(strings.TrimSpace(*v))
	return &s
}

func optString(v string) *string {
	s := strings.TrimSpace(v)
	if s == "" {
		return nil
	}
	return &s
}

// validateTimezone rejects anything the IANA database does not know, so a
// daily log boundary can always be computed (Q10.2).
func validateTimezone(field, tz string) error {
	if tz == "" {
		return apierr.Validation("validation failed",
			apierr.FieldError{Field: field, Message: "required"})
	}
	if _, err := time.LoadLocation(tz); err != nil {
		return apierr.Validation("validation failed",
			apierr.FieldError{Field: field, Message: "must be an IANA time zone, e.g. America/Chicago"})
	}
	return nil
}
