package drivers

import (
	"context"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/db"
	authdomain "github.com/devline/onebook-eld/internal/domain/auth"
	"github.com/devline/onebook-eld/internal/domain/drivers/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Service internals: row fetch, invitation delivery, licence crypto and
// the request-shaping helpers.

// ---------------------------------------------------------------- internals

func (s *Service) fetch(ctx context.Context, scope mw.ScopeFilter, id uuid.UUID) (db.GetDriverDetailRow, error) {
	companyID, err := requireCompany(ctx)
	if err != nil {
		return db.GetDriverDetailRow{}, err
	}
	row, err := s.repo.Get(ctx, companyID, id)
	if err != nil {
		// A record of another tenant must be indistinguishable from a missing
		// one (TZ B§3.5).
		return db.GetDriverDetailRow{}, db.MapError(err, "driver")
	}
	if scope.Scope == tenant.ScopeBranch && scope.BranchID != nil {
		if !row.BranchID.Valid || uuid.UUID(row.BranchID.Bytes) != *scope.BranchID {
			return db.GetDriverDetailRow{}, apierr.NotFound("driver")
		}
	}
	if scope.Scope == tenant.ScopeSelf && scope.SelfUserID != nil && row.UserID != *scope.SelfUserID {
		return db.GetDriverDetailRow{}, apierr.NotFound("driver")
	}
	return row, nil
}

func (s *Service) revokeSessions(ctx context.Context, companyID, userID uuid.UUID, reason string) {
	ids, err := s.repo.RevokeUserSessions(ctx, companyID, userID, reason)
	if err != nil {
		s.log.ErrorContext(ctx, "could not revoke driver sessions",
			"user_id", userID.String(), "error", err.Error())
		return
	}
	if s.revocations == nil || len(ids) == 0 {
		return
	}
	if err := s.revocations.Revoke(ctx, ids...); err != nil {
		s.log.ErrorContext(ctx, "could not add sessions to the deny list",
			"user_id", userID.String(), "error", err.Error())
	}
}

func (s *Service) deliverInvitation(
	ctx context.Context, userID, companyID uuid.UUID, channel, recipient, purpose, token string, expiresAt time.Time,
) {
	if s.notifier == nil || recipient == "" {
		return
	}
	cid := companyID
	if err := s.notifier.SendInvitation(ctx, authdomain.InvitationMessage{
		UserID: userID, CompanyID: &cid, Channel: channel, Recipient: recipient,
		Purpose: purpose, Token: token, ExpiresAt: expiresAt,
	}); err != nil {
		s.log.WarnContext(ctx, "could not deliver an invitation", "error", err.Error())
	}
}

// encryptLicense seals the licence number with AES-256-GCM. Storing it in clear
// text is never allowed (TZ B§3.4), so a missing cipher is a hard failure.
func (s *Service) encryptLicense(plain string) (*string, error) {
	if plain == "" {
		return nil, nil
	}
	if s.cipher == nil {
		return nil, apierr.Internal(appcrypto.ErrNotEnabled, "encryption is not configured")
	}
	enc, err := s.cipher.EncryptString(plain)
	if err != nil {
		return nil, apierr.Internal(err, "could not encrypt the licence number")
	}
	return &enc, nil
}

func (s *Service) decryptLicense(enc *string) string {
	plain, err := s.decryptLicenseErr(enc)
	if err != nil {
		return ""
	}
	return plain
}

func (s *Service) decryptLicenseErr(enc *string) (string, error) {
	if enc == nil || *enc == "" {
		return "", nil
	}
	if s.cipher == nil {
		return "", apierr.Internal(appcrypto.ErrNotEnabled, "encryption is not configured")
	}
	plain, err := s.cipher.DecryptString(*enc)
	if err != nil {
		return "", apierr.Internal(err, "could not read the licence number")
	}
	return plain, nil
}

func requireCompany(ctx context.Context) (uuid.UUID, error) {
	companyID, ok := tenant.CompanyIDOK(ctx)
	if !ok {
		return uuid.Nil, apierr.Forbidden("no active company for this session")
	}
	return companyID, nil
}

func validateCreate(in dto.DriverCreate) error {
	var details []apierr.FieldError
	username := strings.ToLower(strings.TrimSpace(in.Username))
	if !usernameRe.MatchString(username) {
		details = append(details, apierr.FieldError{
			Field: "username", Message: "must be 4-32 characters of [a-z0-9._]",
		})
	}
	// Q18.1: at least one of email / phone, because the invitation is sent
	// over one of them.
	if strings.TrimSpace(in.Email) == "" && strings.TrimSpace(in.Phone) == "" {
		details = append(details, apierr.FieldError{
			Field: "email", Message: "email or phone is required for the invitation",
		})
	}
	if len(details) > 0 {
		return apierr.Validation("validation failed", details...)
	}
	return nil
}

func invitationChannel(email, phone string) (channel, recipient string) {
	if e := strings.TrimSpace(email); e != "" {
		return "email", e
	}
	return "sms", strings.TrimSpace(phone)
}

func isStatus(v string) bool {
	switch v {
	case dto.StatusInvited, dto.StatusActive, dto.StatusInactive:
		return true
	default:
		return false
	}
}

func sortKey(s httpx.Sort) string {
	field := s.Field
	if field == "" {
		field = "name"
	}
	order := s.Order
	if order == "" {
		order = "asc"
	}
	return field + "." + order
}

func parseOptionalUUID(raw string) *uuid.UUID {
	if raw == "" {
		return nil
	}
	id, err := uuid.Parse(raw)
	if err != nil {
		return nil
	}
	return &id
}

func parseOptionalUUIDPtr(raw *string) *uuid.UUID {
	if raw == nil {
		return nil
	}
	return parseOptionalUUID(*raw)
}

func trimPtr(v *string) *string {
	if v == nil {
		return nil
	}
	t := strings.TrimSpace(*v)
	return &t
}

func lowerPtr(v *string) *string {
	if v == nil {
		return nil
	}
	t := strings.ToLower(strings.TrimSpace(*v))
	return &t
}

// changedFields renders the post-image of an update for the audit trail. The
// licence number is only ever recorded masked.
func changedFields(before map[string]any, in dto.DriverUpdate) map[string]any {
	after := make(map[string]any, len(before))
	for k, v := range before {
		after[k] = v
	}
	setIf(after, "first_name", in.FirstName)
	setIf(after, "last_name", in.LastName)
	setIf(after, "email", in.Email)
	setIf(after, "phone", in.Phone)
	setIf(after, "license_region", in.LicenseRegion)
	setIf(after, "home_terminal", in.HomeTerminal)
	setIf(after, "city", in.City)
	setIf(after, "state", in.State)
	setIf(after, "zip", in.Zip)
	setIf(after, "address1", in.Address1)
	setIf(after, "address2", in.Address2)
	setIf(after, "notes", in.Notes)
	setIf(after, "branch_id", in.BranchID)
	setIf(after, "fleet_manager_id", in.FleetManagerID)
	setIf(after, "default_unit_id", in.DefaultUnitID)
	if in.LicenseNo != nil {
		after["license_no"] = maskLicense(*in.LicenseNo)
	}
	return after
}

func setIf(m map[string]any, key string, v *string) {
	if v != nil {
		m[key] = *v
	}
}
