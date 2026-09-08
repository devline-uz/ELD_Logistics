package drivers

import (
	"context"
	"net/http"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/db"
	authdomain "github.com/devline/onebook-eld/internal/domain/auth"
	"github.com/devline/onebook-eld/internal/domain/drivers/dto"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Co-driver pairs, invitation resend and the export projection.

// CoDrivers lists the symmetric co-driver partners of a driver.
func (s *Service) CoDrivers(ctx context.Context, scope mw.ScopeFilter, id uuid.UUID) ([]dto.CoDriver, error) {
	current, err := s.fetch(ctx, scope, id)
	if err != nil {
		return nil, err
	}
	rows, err := s.repo.CoDrivers(ctx, current.CompanyID, id)
	if err != nil {
		return nil, db.MapError(err, "driver")
	}
	out := make([]dto.CoDriver, 0, len(rows))
	for _, row := range rows {
		out = append(out, coDriverFromRow(row))
	}
	return out, nil
}

// AddCoDriver links two drivers. Storage is a single canonical row, so the
// pair shows up on both sides of the relation (TZ §1.1).
func (s *Service) AddCoDriver(
	ctx context.Context, scope mw.ScopeFilter, id uuid.UUID, in dto.CoDriverCreate, meta RequestMeta,
) ([]dto.CoDriver, error) {
	current, err := s.fetch(ctx, scope, id)
	if err != nil {
		return nil, err
	}
	other, err := uuid.Parse(in.CoDriverID)
	if err != nil {
		return nil, apierr.Validation("invalid co_driver_id",
			apierr.FieldError{Field: "co_driver_id", Message: "must be a valid uuid"})
	}
	if other == id {
		return nil, apierr.Validation("a driver cannot be its own co-driver",
			apierr.FieldError{Field: "co_driver_id", Message: "must differ from the driver id"})
	}
	if _, err := s.fetch(ctx, scope, other); err != nil {
		return nil, err
	}

	entries := []audit.Entry{{
		TableName: "driver_pairs",
		RecordID:  id,
		Field:     "co_driver_id",
		NewValue:  other.String(),
		Action:    audit.ActionCreate,
		CompanyID: current.CompanyID,
		IP:        meta.IP,
	}}
	if err := s.repo.LinkCoDriver(ctx, current.CompanyID, id, other, entries); err != nil {
		return nil, db.MapError(err, "co-driver")
	}
	return s.CoDrivers(ctx, scope, id)
}

// RemoveCoDriver unlinks a co-driver pair (soft delete of driver_pairs).
func (s *Service) RemoveCoDriver(ctx context.Context, scope mw.ScopeFilter, id, other uuid.UUID, meta RequestMeta) error {
	current, err := s.fetch(ctx, scope, id)
	if err != nil {
		return err
	}
	if _, err := s.fetch(ctx, scope, other); err != nil {
		return err
	}
	entries := []audit.Entry{{
		TableName: "driver_pairs",
		RecordID:  id,
		Field:     "co_driver_id",
		OldValue:  other.String(),
		Action:    audit.ActionDelete,
		CompanyID: current.CompanyID,
		IP:        meta.IP,
	}}
	if err := s.repo.UnlinkCoDriver(ctx, current.CompanyID, id, other, entries); err != nil {
		return db.MapError(err, "co-driver")
	}
	return nil
}

// ResetPassword reissues the invitation link. Q18.1: a driver password is only
// ever set through an invitation, so "reset password" is "resend invitation".
func (s *Service) ResetPassword(
	ctx context.Context, scope mw.ScopeFilter, id uuid.UUID, meta RequestMeta,
) (*dto.ResetPasswordResult, error) {
	current, err := s.fetch(ctx, scope, id)
	if err != nil {
		return nil, err
	}
	if current.Status == dto.StatusInactive {
		return nil, apierr.New(apierr.CodeAccountInactive, http.StatusForbidden,
			"an inactive driver cannot be invited")
	}

	channel, recipient := invitationChannel(pgconv.Deref(current.Email), pgconv.Deref(current.Phone))
	if recipient == "" {
		return nil, apierr.Validation("the driver has no delivery address",
			apierr.FieldError{Field: "email", Message: "email or phone is required"})
	}

	token, err := appcrypto.RandomToken(core.RefreshTokenBytes)
	if err != nil {
		return nil, apierr.Internal(err, "could not create an invitation token")
	}
	expiresAt := s.now().UTC().Add(core.InvitationTTL)

	entries := []audit.Entry{{
		TableName: "users",
		RecordID:  current.UserID,
		Field:     "invitation",
		NewValue:  map[string]any{"channel": channel, "expires_at": expiresAt},
		Action:    audit.Action("invitation_sent"),
		CompanyID: current.CompanyID,
		IP:        meta.IP,
	}}

	if err := s.repo.ResetInvitation(ctx, current.CompanyID, current.UserID, InvitationInput{
		TokenHash: appcrypto.HashSHA256(token),
		Channel:   channel,
		Purpose:   authdomain.PurposeInvitation,
		ExpiresAt: expiresAt,
	}, entries); err != nil {
		return nil, db.MapError(err, "invitation")
	}

	// A fresh invitation invalidates whatever the account was doing.
	s.revokeSessions(ctx, current.CompanyID, current.UserID, "invitation_reissued")
	s.deliverInvitation(ctx, current.UserID, current.CompanyID, channel, recipient,
		authdomain.PurposeInvitation, token, expiresAt)

	return &dto.ResetPasswordResult{
		DriverID:  id.String(),
		Channel:   channel,
		ExpiresAt: expiresAt,
	}, nil
}

// Export returns the rows GET /drivers/export serialises. It is used by the
// files module, which owns the CSV/XLSX encoding and the export audit entry.
func (s *Service) Export(ctx context.Context, scope mw.ScopeFilter, f ExportFilter) ([]dto.Driver, error) {
	companyID, err := requireCompany(ctx)
	if err != nil {
		return nil, err
	}
	f.CompanyID = companyID
	if scope.Scope == tenant.ScopeBranch && scope.BranchID != nil {
		f.BranchID = scope.BranchID
	}
	rows, err := s.repo.Export(ctx, f)
	if err != nil {
		return nil, db.MapError(err, "driver")
	}
	out := make([]dto.Driver, 0, len(rows))
	for _, row := range rows {
		out = append(out, driverFromDetail(db.GetDriverDetailRow(row), s.decryptLicense))
	}
	return out, nil
}
