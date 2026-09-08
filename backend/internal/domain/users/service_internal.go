package users

import (
	"context"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	authdomain "github.com/devline/onebook-eld/internal/domain/auth"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// load reads the target account and enforces tenancy and branch scope. A row of
// another company, or of another branch for a branch scoped caller, answers 404
// so record ids cannot be probed.
func (s *Service) load(ctx context.Context, id uuid.UUID, scope mw.ScopeFilter) (uuid.UUID, db.GetUserDetailRow, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return uuid.Nil, db.GetUserDetailRow{}, err
	}
	row, err := s.repo.GetUser(ctx, companyID, id)
	if err != nil {
		return uuid.Nil, db.GetUserDetailRow{}, db.MapError(err, "user")
	}
	if !scope.AllowsBranch(pgconv.ToUUIDPtr(row.BranchID)) {
		return uuid.Nil, db.GetUserDetailRow{}, apierr.NotFound("user")
	}
	return companyID, row, nil
}

func (s *Service) guardSelf(ctx context.Context, id uuid.UUID, action string) error {
	if tenant.UserID(ctx) != id {
		return nil
	}
	return apierr.Conflict(apierr.CodeSelfTargetForbidden, "you cannot "+action+" your own account")
}

// guardLastAdministrator blocks the removal of the last active Administrator
// of a company (TZ Q81).
func (s *Service) guardLastAdministrator(ctx context.Context, companyID uuid.UUID, row db.GetUserDetailRow) error {
	if !row.RoleIsSystem || !strings.EqualFold(row.RoleName, administratorRole) || row.Status != StatusActive {
		return nil
	}
	remaining, err := s.repo.CountAdministrators(ctx, companyID, row.ID)
	if err != nil {
		return db.MapError(err, "user")
	}
	if remaining > 0 {
		return nil
	}
	return apierr.Conflict(apierr.CodeLastAdministrator,
		"the last active Administrator of a company cannot be removed")
}

// resolveBranch enforces the branch scope of both the new role and the caller.
func (s *Service) resolveBranch(roleScope string, requested *uuid.UUID, scope mw.ScopeFilter) (*uuid.UUID, error) {
	if scope.Scope == tenant.ScopeBranch && scope.BranchID != nil {
		branch := *scope.BranchID
		if requested != nil && *requested != branch {
			return nil, apierr.Forbidden("a branch scoped user can only manage its own branch")
		}
		return &branch, nil
	}
	if roleScope == string(tenant.ScopeBranch) && requested == nil {
		return nil, apierr.Validation("validation failed", apierr.FieldError{
			Field: "branch_id", Message: "required for a branch scoped role",
		})
	}
	return requested, nil
}

// entries stamps the shared audit facts onto a batch of changes.
func (s *Service) entries(table string, recordID uuid.UUID, action audit.Action,
	companyID uuid.UUID, meta RequestMeta, entries []audit.Entry) []audit.Entry {
	if len(entries) == 0 {
		entries = []audit.Entry{{TableName: table, RecordID: recordID, Field: "record", Action: action}}
	}
	for i := range entries {
		entries[i].CompanyID = companyID
		entries[i].IP = meta.IP
		if entries[i].Action == "" {
			entries[i].Action = action
		}
	}
	return entries
}

// revoke adds revoked sessions to the access token deny list so a deactivated
// account or a narrowed role cannot keep using its unexpired access token.
func (s *Service) revoke(ctx context.Context, sessionIDs []uuid.UUID) {
	if len(sessionIDs) == 0 {
		return
	}
	if err := s.revocations.Revoke(ctx, sessionIDs...); err != nil {
		s.log.WarnContext(ctx, "could not add sessions to the revocation list", "error", err.Error())
	}
}

// deliver hands the link to the notifier. The token never appears in a
// response or in a log line.
func (s *Service) deliver(ctx context.Context, row db.GetUserDetailRow, channel, purpose, token string, expiresAt time.Time) {
	recipient := pgconv.Deref(row.Email)
	if channel != ChannelEmail {
		recipient = pgconv.Deref(row.Phone)
	}
	companyID := pgconv.ToUUIDPtr(row.CompanyID)
	if err := s.notifier.SendInvitation(ctx, authdomain.InvitationMessage{
		UserID:    row.ID,
		CompanyID: companyID,
		Channel:   channel,
		Recipient: recipient,
		Purpose:   purpose,
		Token:     token,
		ExpiresAt: expiresAt,
	}); err != nil {
		s.log.WarnContext(ctx, "could not deliver an invitation link",
			"purpose", purpose, "channel", channel, "error", err.Error())
	}
}

func companyOf(ctx context.Context) (uuid.UUID, error) {
	companyID, ok := tenant.CompanyIDOK(ctx)
	if !ok {
		return uuid.Nil, apierr.Forbidden("no active company for this session")
	}
	return companyID, nil
}

func resolveChannel(requested, email, phone string) string {
	switch requested {
	case ChannelEmail:
		if email != "" {
			return ChannelEmail
		}
	case ChannelSMS, ChannelTelegram:
		if phone != "" {
			return requested
		}
	}
	if email != "" {
		return ChannelEmail
	}
	return ChannelSMS
}

func parseUUIDField(field, raw string) (*uuid.UUID, error) {
	id, err := uuid.Parse(strings.TrimSpace(raw))
	if err != nil {
		return nil, apierr.Validation("validation failed", apierr.FieldError{
			Field: field, Message: "must be a valid uuid",
		})
	}
	return &id, nil
}

func parseOptionalUUID(field, raw string) (*uuid.UUID, error) {
	if strings.TrimSpace(raw) == "" {
		return nil, nil
	}
	return parseUUIDField(field, raw)
}

func trimmedPtr(v string) *string {
	t := strings.TrimSpace(v)
	return &t
}

// applyUserAudit projects the pending update onto the after image so
// audit.Changes only reports fields that really changed.
func applyUserAudit(after map[string]any, in UpdateUserInput) {
	if in.FirstName != nil {
		after["first_name"] = *in.FirstName
	}
	if in.LastName != nil {
		after["last_name"] = *in.LastName
	}
	if in.Email != nil {
		after["email"] = *in.Email
	}
	if in.Phone != nil {
		after["phone"] = *in.Phone
	}
	if in.Username != nil {
		after["username"] = *in.Username
	}
	if in.RoleID != nil {
		after["role_id"] = in.RoleID.String()
	}
	if in.ClearBranch {
		after["branch_id"] = ""
	} else if in.BranchID != nil {
		after["branch_id"] = in.BranchID.String()
	}
}
