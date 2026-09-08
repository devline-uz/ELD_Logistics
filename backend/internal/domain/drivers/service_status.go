package drivers

import (
	"context"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/drivers/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Activation, soft delete and the driver activity feed.

// SetActive activates or deactivates a driver. Q1: an inactive driver cannot
// use the app, so every one of its sessions is revoked immediately.
func (s *Service) SetActive(
	ctx context.Context, scope mw.ScopeFilter, id uuid.UUID, active bool, reason string, meta RequestMeta,
) (*dto.Driver, error) {
	current, err := s.fetch(ctx, scope, id)
	if err != nil {
		return nil, err
	}
	status := dto.StatusInactive
	action := audit.Action("deactivate")
	if active {
		status = dto.StatusActive
		action = audit.Action("activate")
	}

	entries := []audit.Entry{{
		TableName: "drivers",
		RecordID:  id,
		Field:     "status",
		OldValue:  current.Status,
		NewValue:  status,
		Action:    action,
		CompanyID: current.CompanyID,
		IP:        meta.IP,
		Reason:    reason,
	}}

	row, err := s.repo.SetStatus(ctx, current.CompanyID, id, current.UserID, status, entries)
	if err != nil {
		return nil, db.MapError(err, "driver")
	}

	if !active {
		s.revokeSessions(ctx, current.CompanyID, current.UserID, "driver_deactivated")
	}

	out := driverFromDetail(row, s.decryptLicense)
	return &out, nil
}

// Delete soft deletes the driver and its user account, then revokes the
// sessions so the deleted account cannot keep using a live access token.
func (s *Service) Delete(ctx context.Context, scope mw.ScopeFilter, id uuid.UUID, meta RequestMeta) error {
	current, err := s.fetch(ctx, scope, id)
	if err != nil {
		return err
	}
	entries := []audit.Entry{{
		TableName: "drivers",
		RecordID:  id,
		Field:     "deleted_at",
		OldValue:  nil,
		NewValue:  s.now().UTC(),
		Action:    audit.ActionDelete,
		CompanyID: current.CompanyID,
		IP:        meta.IP,
	}}
	if err := s.repo.SoftDelete(ctx, current.CompanyID, id, current.UserID, entries); err != nil {
		return db.MapError(err, "driver")
	}
	s.revokeSessions(ctx, current.CompanyID, current.UserID, "driver_deleted")
	return nil
}

// Activities returns the paginated activity feed of a driver: audit_log entries
// about the driver and its user, plus its session history.
func (s *Service) Activities(ctx context.Context, scope mw.ScopeFilter, id uuid.UUID, page httpx.Page) ([]dto.Activity, httpx.Meta, error) {
	current, err := s.fetch(ctx, scope, id)
	if err != nil {
		return nil, httpx.Meta{}, err
	}
	rows, total, err := s.repo.Activities(ctx, ActivityFilter{
		CompanyID: current.CompanyID,
		DriverID:  id,
		UserID:    current.UserID,
		Limit:     page.Limit(),
		Offset:    page.Offset(),
	})
	if err != nil {
		return nil, httpx.Meta{}, db.MapError(err, "driver")
	}
	out := make([]dto.Activity, 0, len(rows))
	for _, row := range rows {
		out = append(out, activityFromRow(row))
	}
	return out, page.Meta(total), nil
}
