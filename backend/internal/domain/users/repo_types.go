package users

import (
	"context"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
)

// UserFilter is the whitelisted GET /users query. Sort and SortDesc are
// resolved from a whitelist by the handler, never concatenated into SQL.
type UserFilter struct {
	CompanyID uuid.UUID
	Search    *string
	Status    *string
	RoleID    *uuid.UUID
	BranchID  *uuid.UUID
	Sort      string
	SortDesc  bool
	Limit     int32
	Offset    int32
}

// RoleFilter is the whitelisted GET /roles query.
type RoleFilter struct {
	CompanyID uuid.UUID
	Search    *string
	Scope     *string
	IsSystem  *bool
	Sort      string
	SortDesc  bool
	Limit     int32
	Offset    int32
}

// CreateUserInput describes the invited account POST /users creates. There is
// no password: the user sets it from the invitation link.
type CreateUserInput struct {
	CompanyID uuid.UUID
	BranchID  *uuid.UUID
	FirstName string
	LastName  string
	Email     *string
	Phone     *string
	Username  string
	RoleID    uuid.UUID
	InvitedAt time.Time
}

// UpdateUserInput carries the PATCH /users/{id} changes. A nil field is left
// untouched; ClearBranch detaches the user from its branch.
type UpdateUserInput struct {
	CompanyID   uuid.UUID
	ID          uuid.UUID
	FirstName   *string
	LastName    *string
	Email       *string
	Phone       *string
	Username    *string
	RoleID      *uuid.UUID
	BranchID    *uuid.UUID
	ClearBranch bool
	// RevokeSessions is set when the change alters the effective permission
	// set (a role change), so the sessions are dropped in the same transaction.
	RevokeSessions bool
}

// InvitationInput is the invitation or password reset token to store. Only the
// SHA-256 hash of the token ever reaches the database.
type InvitationInput struct {
	CompanyID uuid.UUID
	UserID    uuid.UUID
	TokenHash string
	Channel   string
	Purpose   string
	ExpiresAt time.Time
}

// CreateRoleInput describes POST /roles.
type CreateRoleInput struct {
	CompanyID   uuid.UUID
	Name        string
	Description *string
	Scope       string
	Permissions []string
}

// UpdateRoleInput describes PATCH /roles/{id}. Permissions replaces the whole
// set when non nil.
type UpdateRoleInput struct {
	CompanyID   uuid.UUID
	ID          uuid.UUID
	Name        *string
	Description *string
	Scope       *string
	Permissions []string
}

// Repo is everything the users service needs from storage. Every mutation
// writes its audit entries inside the same transaction as the change.
type Repo interface {
	ListUsers(ctx context.Context, f UserFilter) ([]db.ListUsersRow, int64, error)
	GetUser(ctx context.Context, companyID, id uuid.UUID) (db.GetUserDetailRow, error)
	CountAdministrators(ctx context.Context, companyID, excludeUserID uuid.UUID) (int64, error)

	CreateInvitedUser(ctx context.Context, in CreateUserInput, inv InvitationInput,
		entries func(userID uuid.UUID) []audit.Entry) (db.GetUserDetailRow, error)
	UpdateUser(ctx context.Context, in UpdateUserInput, entries []audit.Entry) (db.GetUserDetailRow, []uuid.UUID, error)
	SetUserStatus(ctx context.Context, companyID, id uuid.UUID, status, reason string,
		entries []audit.Entry) (db.GetUserDetailRow, []uuid.UUID, error)
	SoftDeleteUser(ctx context.Context, companyID, id uuid.UUID, reason string,
		entries []audit.Entry) ([]uuid.UUID, error)
	ReissueInvitation(ctx context.Context, inv InvitationInput, entries []audit.Entry) error

	ListRoles(ctx context.Context, f RoleFilter) ([]db.ListRolesRow, int64, error)
	GetRole(ctx context.Context, companyID, id uuid.UUID) (db.GetRoleWithUserCountRow, error)
	RolePermissions(ctx context.Context, roleID uuid.UUID) ([]string, error)
	PermissionsForRoles(ctx context.Context, roleIDs []uuid.UUID) (map[uuid.UUID][]string, error)
	CountUsersWithRole(ctx context.Context, companyID, roleID uuid.UUID) (int64, error)

	CreateRole(ctx context.Context, in CreateRoleInput,
		entries func(roleID uuid.UUID) []audit.Entry) (db.Role, error)
	UpdateRole(ctx context.Context, in UpdateRoleInput, entries []audit.Entry) (db.Role, error)
	SoftDeleteRole(ctx context.Context, companyID, id uuid.UUID, entries []audit.Entry) error
	RevokeRoleSessions(ctx context.Context, companyID, roleID uuid.UUID, reason string) ([]uuid.UUID, error)
}
