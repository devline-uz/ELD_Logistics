package users

import (
	"strings"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/users/dto"
)

// toUser maps the joined sqlc row onto the wire payload. password_hash,
// totp_secret_enc, pin_hash and recovery_codes are deliberately dropped here:
// the DTO has no field for them.
func toUser(row db.GetUserDetailRow) dto.User {
	out := dto.User{
		ID:        row.ID.String(),
		FirstName: row.FirstName,
		LastName:  row.LastName,
		FullName:  strings.TrimSpace(row.FirstName + " " + row.LastName),
		Email:     row.Email,
		Phone:     row.Phone,
		Username:  row.Username,
		Status:    row.Status,
		Role: dto.UserRole{
			ID:       row.RoleID.String(),
			Name:     row.RoleName,
			Scope:    row.RoleScope,
			IsSystem: row.RoleIsSystem,
		},
		BranchName:  row.BranchName,
		TotpEnabled: row.TotpEnabled,
		InvitedAt:   pgconv.ToTimePtr(row.InvitedAt),
		ActivatedAt: pgconv.ToTimePtr(row.ActivatedAt),
		LastLoginAt: pgconv.ToTimePtr(row.LastLoginAt),
		CreatedAt:   row.CreatedAt.UTC(),
		UpdatedAt:   row.UpdatedAt.UTC(),
	}
	if id := pgconv.ToUUIDPtr(row.BranchID); id != nil {
		v := id.String()
		out.BranchID = &v
	}
	return out
}

// toUserFromList maps a list row by reusing the detail mapping: both queries
// select the same columns.
func toUserFromList(row db.ListUsersRow) dto.User {
	return toUser(db.GetUserDetailRow(row))
}

// toRole maps a role row plus its permission keys onto the wire payload.
func toRole(row db.GetRoleWithUserCountRow, permissions []string) dto.Role {
	if permissions == nil {
		permissions = []string{}
	}
	return dto.Role{
		ID:          row.ID.String(),
		Name:        row.Name,
		Description: row.Description,
		Scope:       row.Scope,
		IsSystem:    row.IsSystem,
		Permissions: permissions,
		UserCount:   row.UserCount,
		CreatedAt:   row.CreatedAt.UTC(),
		UpdatedAt:   row.UpdatedAt.UTC(),
	}
}

// toRoleFromModel maps the plain sqlc model returned by create and update.
func toRoleFromModel(row db.Role, permissions []string, userCount int64) dto.Role {
	return toRole(db.GetRoleWithUserCountRow{
		ID:          row.ID,
		CompanyID:   row.CompanyID,
		Name:        row.Name,
		Description: row.Description,
		Scope:       row.Scope,
		IsSystem:    row.IsSystem,
		CreatedAt:   row.CreatedAt,
		UpdatedAt:   row.UpdatedAt,
		DeletedAt:   row.DeletedAt,
		UserCount:   userCount,
	}, permissions)
}

// userAuditFields is the audited projection of a user row. Values of PII fields
// are redacted by internal/audit before they are stored.
func userAuditFields(row db.GetUserDetailRow) map[string]any {
	return map[string]any{
		"first_name": row.FirstName,
		"last_name":  row.LastName,
		"email":      pgconv.Deref(row.Email),
		"phone":      pgconv.Deref(row.Phone),
		"username":   row.Username,
		"role_id":    row.RoleID.String(),
		"branch_id":  uuidString(pgconv.ToUUIDPtr(row.BranchID)),
		"status":     row.Status,
	}
}

// roleAuditFields is the audited projection of a role row.
func roleAuditFields(name, description, scope string, permissions []string) map[string]any {
	return map[string]any{
		"name":        name,
		"description": description,
		"scope":       scope,
		"permissions": strings.Join(permissions, ","),
	}
}

func uuidString(id *uuid.UUID) string {
	if id == nil {
		return ""
	}
	return id.String()
}
