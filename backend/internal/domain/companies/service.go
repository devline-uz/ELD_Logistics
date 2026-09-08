// Package companies is the platform (Super Admin) tenant management module:
// listing, provisioning and billing of companies. It implements server.Module.
package companies

import (
	"context"
	"log/slog"
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
	"github.com/devline/onebook-eld/internal/domain/companies/dto"
	"github.com/devline/onebook-eld/internal/domain/company"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Constants mirrored from the schema and the seed migration.
const (
	tableCompanies    = "companies"
	tableUsers        = "users"
	roleAdministrator = "Administrator"
	statusInvited     = "invited"
	purposeInvitation = "invitation"
	channelEmail      = "email"

	actionSubscription = audit.Action("subscription_change")

	// statusTrial is the default companies.subscription_status of a new tenant.
	statusTrial = "trial"
)

// RequestMeta carries the transport facts an audit row records. It is filled
// by the handler from the request, never from the JSON body.
type RequestMeta struct {
	IP string
}

// SubscriptionInvalidator drops the memoised subscription state of one tenant.
// *middleware.PgSubscriptionSource satisfies it; this package cannot import
// internal/middleware's concrete type without inverting the dependency, so it
// depends on this narrow interface instead.
type SubscriptionInvalidator interface {
	Invalidate(ctx context.Context, companyID uuid.UUID) error
}

// ServiceDeps are the platform company service collaborators.
type ServiceDeps struct {
	Repo     Repo
	Notifier authdomain.Notifier
	Logger   *slog.Logger
	// Subscriptions is optional; nil means the cache simply expires on its
	// own TTL (internal/middleware.DefaultSubscriptionTTL).
	Subscriptions SubscriptionInvalidator
	// Now is overridable in tests.
	Now func() time.Time
}

// Service holds the platform company business rules. It never touches pgx.
type Service struct {
	repo          Repo
	notifier      authdomain.Notifier
	log           *slog.Logger
	subscriptions SubscriptionInvalidator
	now           func() time.Time
}

// NewService builds the platform company service.
func NewService(deps ServiceDeps) *Service {
	log := deps.Logger
	if log == nil {
		log = slog.Default()
	}
	notifier := deps.Notifier
	if notifier == nil {
		notifier = authdomain.LogNotifier{Log: log}
	}
	now := deps.Now
	if now == nil {
		now = func() time.Time { return time.Now().UTC() }
	}
	return &Service{
		repo: deps.Repo, notifier: notifier, log: log,
		subscriptions: deps.Subscriptions, now: now,
	}
}

// invalidateSubscription drops the cached subscription state after this
// service just wrote it. Best effort: a cache miss just means the next read
// hits the database, so a failure here never fails the request.
func (s *Service) invalidateSubscription(ctx context.Context, companyID uuid.UUID) {
	if s.subscriptions == nil {
		return
	}
	if err := s.subscriptions.Invalidate(ctx, companyID); err != nil {
		s.log.WarnContext(ctx, "companies: failed to invalidate the cached subscription state",
			"company_id", companyID, "error", err.Error())
	}
}

// List returns the paginated tenant collection.
func (s *Service) List(ctx context.Context, page httpx.Page, sort httpx.Sort, search, status, region string) ([]dto.Company, int64, error) {
	if status != "" && !isSubscriptionStatus(status) {
		return nil, 0, apierr.Validation("invalid query parameter", apierr.FieldError{
			Field: "status", Message: "must be one of: trial, active, grace, readonly",
		})
	}
	if region != "" && !isRegion(region) {
		return nil, 0, apierr.Validation("invalid query parameter", apierr.FieldError{
			Field: "region", Message: "must be one of: PK, UZ, US, other",
		})
	}

	rows, total, err := s.repo.List(ctx, ListFilter{
		Search:  optStr(search),
		Status:  optStr(status),
		Region:  optStr(region),
		SortBy:  sort.Field,
		SortDir: sort.Order,
		Limit:   page.Limit(),
		Offset:  page.Offset(),
	})
	if err != nil {
		return nil, 0, err
	}
	out := make([]dto.Company, 0, len(rows))
	for _, c := range rows {
		out = append(out, company.ToCompany(c))
	}
	return out, total, nil
}

// Create provisions a tenant: the company row, the FMCSA 70/8 default HOS
// policy version, a copy of the system roles with their permissions, the A§19
// notification defaults, the Administrator account in `invited` state and its
// one time invitation (TZ A§15).
func (s *Service) Create(ctx context.Context, in dto.CompanyCreate, meta RequestMeta) (*dto.CompanyCreated, error) {
	if err := validateTimezone("timezone", strings.TrimSpace(in.Timezone)); err != nil {
		return nil, err
	}

	status := strings.TrimSpace(in.SubscriptionStatus)
	if status == "" {
		status = statusTrial
	}
	now := s.now().UTC()
	if in.SubscriptionEndAt != nil && in.SubscriptionEndAt.Before(now) {
		return nil, apierr.Validation("validation failed", apierr.FieldError{
			Field: "subscription_end_at", Message: "must not be in the past",
		})
	}

	admin, err := normaliseAdmin(in.Administrator)
	if err != nil {
		return nil, err
	}

	policy, pErr := company.DefaultHosPolicyJSON()
	if pErr != nil {
		return nil, apierr.Internal(pErr, "could not encode the default hos policy")
	}
	settings, sErr := defaultSettingsJSON(in.Region)
	if sErr != nil {
		return nil, sErr
	}

	token, tErr := appcrypto.RandomToken(core.RefreshTokenBytes)
	if tErr != nil {
		return nil, apierr.Internal(tErr, "could not create an invitation token")
	}
	expiresAt := now.Add(core.InvitationTTL)

	res, err := s.repo.Provision(ctx, ProvisionInput{
		Company: db.CreateCompanyParams{
			Name:                strings.TrimSpace(in.Name),
			Address:             optStr(in.Address),
			HomeTerminalAddress: optStr(in.HomeTerminalAddress),
			Timezone:            strings.TrimSpace(in.Timezone),
			Email:               optStr(strings.ToLower(in.Email)),
			Phone:               optStr(in.Phone),
			RegistrationNo:      optStr(in.RegistrationNo),
			Region:              optStr(in.Region),
			UnitSystem:          strings.TrimSpace(in.UnitSystem),
			RegulationProfile:   strings.TrimSpace(in.RegulationProfile),
			Plan:                optStr(in.Plan),
		},
		Settings:           settings,
		SubscriptionStatus: status,
		SubscriptionEndAt:  in.SubscriptionEndAt,
		HosPolicy:          policy,
		Admin:              admin.user,
		InvitationHash:     appcrypto.HashSHA256(token),
		InvitationChannel:  admin.channel,
		InvitationExpires:  expiresAt,
		AlertDefaults:      company.AlertDefaults,
		CreatedBy:          tenant.UserID(ctx),
		IP:                 meta.IP,
	})
	if err != nil {
		return nil, err
	}

	// The link leaves the system out of band only: the token is never logged
	// and never returned by the API.
	companyID := res.Company.ID
	recipient := admin.user.Email
	if admin.channel != channelEmail {
		recipient = admin.user.Phone
	}
	if nErr := s.notifier.SendInvitation(ctx, authdomain.InvitationMessage{
		UserID:    res.AdminUserID,
		CompanyID: &companyID,
		Channel:   admin.channel,
		Recipient: recipient,
		Purpose:   purposeInvitation,
		Token:     token,
		ExpiresAt: expiresAt,
	}); nErr != nil {
		s.log.ErrorContext(ctx, "administrator invitation could not be delivered",
			"company_id", companyID.String(), "error", nErr.Error())
	}

	return &dto.CompanyCreated{
		Company:             company.ToCompany(res.Company),
		AdministratorUserID: res.AdminUserID.String(),
		AdministratorRoleID: res.AdminRoleID.String(),
		InvitationExpiresAt: expiresAt,
		InvitationChannel:   admin.channel,
		RolesCreated:        res.RolesCreated,
	}, nil
}

// Update patches a tenant from the platform console.
func (s *Service) Update(ctx context.Context, id uuid.UUID, in dto.CompanyUpdate, meta RequestMeta) (*dto.Company, error) {
	before, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if in.Timezone != nil {
		if err := validateTimezone("timezone", strings.TrimSpace(*in.Timezone)); err != nil {
			return nil, err
		}
	}

	params := db.UpdateCompanyParams{
		ID:                  id,
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
		Plan:                trimPtr(in.Plan),
	}

	entries := audit.Changes(tableCompanies, id, audit.ActionUpdate, companyFields(before), patchFields(params))
	for i := range entries {
		entries[i].IP = meta.IP
	}

	after, err := s.repo.Update(ctx, UpdateInput{ID: id, Params: params, Audit: entries})
	if err != nil {
		return nil, err
	}
	out := company.ToCompany(after)
	return &out, nil
}

// UpdateSubscription moves a tenant between billing states (TZ A§15). MVP
// billing is manual: the platform administrator extends subscription_end_at
// once the invoice is settled.
func (s *Service) UpdateSubscription(ctx context.Context, id uuid.UUID, in dto.SubscriptionUpdate, meta RequestMeta) (*dto.Company, error) {
	before, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if in.Plan == nil && in.Status == nil && in.EndAt == nil && !in.ClearEndAt {
		return nil, apierr.Validation("validation failed", apierr.FieldError{
			Field: "subscription_status", Message: "at least one subscription field is required",
		})
	}
	if in.ClearEndAt && in.EndAt != nil {
		return nil, apierr.Validation("validation failed", apierr.FieldError{
			Field: "clear_end_at", Message: "must not be combined with subscription_end_at",
		})
	}

	params := db.UpdateCompanySubscriptionParams{
		ID:                 id,
		SubscriptionStatus: trimPtr(in.Status),
		Plan:               trimPtr(in.Plan),
		ClearEndAt:         in.ClearEndAt,
		SubscriptionEndAt:  pgconv.TimePtr(in.EndAt),
	}

	after := map[string]any{}
	if in.Status != nil {
		after["subscription_status"] = strings.TrimSpace(*in.Status)
	}
	if in.Plan != nil {
		after["plan"] = strings.TrimSpace(*in.Plan)
	}
	switch {
	case in.ClearEndAt:
		after["subscription_end_at"] = ""
	case in.EndAt != nil:
		after["subscription_end_at"] = in.EndAt.UTC().Format(time.RFC3339)
	}

	entries := audit.Changes(tableCompanies, id, actionSubscription, subscriptionFields(before), after)
	for i := range entries {
		entries[i].IP = meta.IP
	}

	row, err := s.repo.UpdateSubscription(ctx, SubscriptionInput{ID: id, Params: params, Audit: entries})
	if err != nil {
		return nil, err
	}
	s.invalidateSubscription(ctx, id)
	out := company.ToCompany(row)
	return &out, nil
}
