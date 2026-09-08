package dvir

import (
	"context"
	"net/http"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
	"github.com/devline/onebook-eld/internal/tenant"
)

// ---------------------------------------------------------------- defect types

// ListDefectTypes returns a page of the catalogue (Q27.1).
func (s *Service) ListDefectTypes(ctx context.Context, f DefectTypeFilter) ([]dto.DefectType, int64, error) {
	rows, total, err := s.repo.ListDefectTypes(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "defect type")
	}
	out := make([]dto.DefectType, 0, len(rows))
	for _, r := range rows {
		out = append(out, defectTypeFrom(r))
	}
	return out, total, nil
}

// CreateDefectType adds a company level catalogue entry.
func (s *Service) CreateDefectType(ctx context.Context, in dto.DefectTypeCreate) (*dto.DefectType, error) {
	row, err := s.repo.CreateDefectType(ctx, db.CreateDefectTypeParams{
		CompanyID:  uuidToPG(tenant.CompanyID(ctx)),
		Name:       in.Name,
		Category:   in.Category,
		IsCritical: in.IsCritical,
		IsActive:   in.IsActive,
		SortOrder:  in.SortOrder,
	})
	if err != nil {
		return nil, db.MapError(err, "defect type")
	}
	out := defectTypeFrom(row)
	return &out, nil
}

// UpdateDefectType patches a company entry. The shared system defaults are read
// only for every tenant.
func (s *Service) UpdateDefectType(ctx context.Context, id uuid.UUID, in dto.DefectTypeUpdate) (*dto.DefectType, error) {
	current, err := s.repo.GetDefectType(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "defect type")
	}
	if !current.CompanyID.Valid {
		return nil, apierr.New(apierr.CodeDefectTypeSystemLocked, http.StatusConflict,
			"the default catalogue is read only; create a company entry instead")
	}
	row, err := s.repo.UpdateDefectType(ctx, db.UpdateDefectTypeParams{
		CompanyID:  uuidToPG(tenant.CompanyID(ctx)),
		ID:         id,
		Name:       in.Name,
		Category:   in.Category,
		IsCritical: in.IsCritical,
		IsActive:   in.IsActive,
		SortOrder:  in.SortOrder,
	})
	if err != nil {
		return nil, db.MapError(err, "defect type")
	}
	out := defectTypeFrom(row)
	return &out, nil
}
