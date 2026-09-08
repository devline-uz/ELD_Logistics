package users

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
	"github.com/devline/onebook-eld/internal/domain/users/dto"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// ResendInvitation issues a fresh invitation link for an account that has not
// accepted the first one yet.
func (s *Service) ResendInvitation(ctx context.Context, id uuid.UUID, scope mw.ScopeFilter, meta RequestMeta) (*dto.InvitationSent, error) {
	_, current, err := s.load(ctx, id, scope)
	if err != nil {
		return nil, err
	}
	if current.Status != StatusInvited {
		return nil, apierr.New(apierr.CodeInvalidState, http.StatusConflict,
			"the invitation has already been accepted; use reset-password instead")
	}
	return s.issueLink(ctx, current, PurposeInvitation, audit.ActionUpdate, meta)
}

// ResetPassword sends a password reset link. An administrator never sets a
// password on behalf of a user (TZ A§16).
func (s *Service) ResetPassword(ctx context.Context, id uuid.UUID, scope mw.ScopeFilter, meta RequestMeta) (*dto.InvitationSent, error) {
	_, current, err := s.load(ctx, id, scope)
	if err != nil {
		return nil, err
	}
	if current.Status == StatusInactive {
		return nil, apierr.New(apierr.CodeAccountInactive, http.StatusConflict,
			"the account is inactive; activate it first")
	}
	purpose := PurposePasswordReset
	if current.Status == StatusInvited {
		purpose = PurposeInvitation
	}
	return s.issueLink(ctx, current, purpose, audit.ActionPasswordReset, meta)
}

func (s *Service) issueLink(ctx context.Context, current db.GetUserDetailRow, purpose string,
	action audit.Action, meta RequestMeta) (*dto.InvitationSent, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}
	token, err := appcrypto.RandomToken(core.RefreshTokenBytes)
	if err != nil {
		return nil, apierr.Internal(err, "could not create an invitation token")
	}
	channel := resolveChannel("", pgconv.Deref(current.Email), pgconv.Deref(current.Phone))
	expiresAt := s.now().UTC().Add(core.InvitationTTL)

	if err := s.repo.ReissueInvitation(ctx, InvitationInput{
		CompanyID: companyID,
		UserID:    current.ID,
		TokenHash: appcrypto.HashSHA256(token),
		Channel:   channel,
		Purpose:   purpose,
		ExpiresAt: expiresAt,
	}, s.entries("users", current.ID, action, companyID, meta, []audit.Entry{{
		TableName: "users", RecordID: current.ID, Field: "invitation",
		OldValue: nil, NewValue: purpose, Action: action,
	}})); err != nil {
		return nil, db.MapError(err, "invitation")
	}

	s.deliver(ctx, current, channel, purpose, token, expiresAt)
	return &dto.InvitationSent{
		UserID:    current.ID.String(),
		Channel:   channel,
		Purpose:   purpose,
		ExpiresAt: expiresAt,
	}, nil
}
