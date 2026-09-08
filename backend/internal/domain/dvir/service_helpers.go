package dvir

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
)

// ---------------------------------------------------------------- helpers

func (s *Service) invalidTransition(from, to string) error {
	return apierr.New(apierr.CodeDVIRInvalidTransition, http.StatusConflict,
		fmt.Sprintf("a DVIR in %q cannot move to %q", from, to))
}

// resolveTrailers validates the trailer ids against the caller tenant.
func (s *Service) resolveTrailers(ctx context.Context, ids []string) ([]uuid.UUID, error) {
	if len(ids) == 0 {
		return []uuid.UUID{}, nil
	}
	parsed := make([]uuid.UUID, 0, len(ids))
	for _, raw := range ids {
		id, err := uuid.Parse(raw)
		if err != nil {
			return nil, apierr.Validation("trailer_ids holds an invalid uuid",
				apierr.FieldError{Field: "trailer_ids", Message: "must be uuids"})
		}
		parsed = append(parsed, id)
	}
	found, err := s.repo.Trailers(ctx, parsed)
	if err != nil {
		return nil, db.MapError(err, "trailer")
	}
	if len(found) != len(parsed) {
		return nil, apierr.NotFound("trailer")
	}
	return parsed, nil
}

// resolveDefects validates the catalogue references and the Q27.1 photo
// ceiling, and reports whether any defect is critical (Q27.2).
func (s *Service) resolveDefects(ctx context.Context, in []dto.DefectInput) ([]dto.Defect, bool, error) {
	if len(in) == 0 {
		return []dto.Defect{}, false, nil
	}
	ids := make([]uuid.UUID, 0, len(in))
	for i, d := range in {
		if len(d.PhotoKeys) > dto.MaxDefectPhotos {
			return nil, false, apierr.Validation("too many photos on one defect",
				apierr.FieldError{
					Field:   fmt.Sprintf("defects[%d].photo_keys", i),
					Message: fmt.Sprintf("at most %d photos", dto.MaxDefectPhotos),
				})
		}
		for j, key := range d.PhotoKeys {
			if err := ownsKey(ctx, fmt.Sprintf("defects[%d].photo_keys[%d]", i, j), key); err != nil {
				return nil, false, err
			}
		}
		id, err := uuid.Parse(d.DefectTypeID)
		if err != nil {
			return nil, false, apierr.Validation("defect_type_id must be a uuid",
				apierr.FieldError{Field: fmt.Sprintf("defects[%d].defect_type_id", i), Message: "must be a uuid"})
		}
		ids = append(ids, id)
	}
	rows, err := s.repo.DefectTypesByIDs(ctx, ids)
	if err != nil {
		return nil, false, db.MapError(err, "defect type")
	}
	byID := make(map[uuid.UUID]db.DefectType, len(rows))
	for _, r := range rows {
		byID[r.ID] = r
	}

	out := make([]dto.Defect, 0, len(in))
	var critical bool
	for i, d := range in {
		id := ids[i]
		t, ok := byID[id]
		if !ok || !t.IsActive {
			return nil, false, apierr.New(apierr.CodeDefectTypeUnknown, http.StatusUnprocessableEntity,
				"unknown or inactive defect type "+d.DefectTypeID)
		}
		critical = critical || t.IsCritical
		keys := d.PhotoKeys
		if keys == nil {
			keys = []string{}
		}
		out = append(out, dto.Defect{
			DefectTypeID: id.String(),
			Name:         t.Name,
			Category:     t.Category,
			IsCritical:   t.IsCritical,
			Note:         d.Note,
			PhotoKeys:    keys,
		})
	}
	return out, critical, nil
}

// notifyCreated raises the Q27.2 critical alert and the Service Manager
// hand-off. A failing notifier never fails the inspection.
func (s *Service) notifyCreated(ctx context.Context, rep dto.DvirReport, critical bool, unitNumber string) {
	if rep.Status != dto.StatusSubmittedDefectsFound {
		return
	}
	names := make([]string, 0, len(rep.Defects))
	for _, d := range rep.Defects {
		names = append(names, d.Name)
	}
	a := Alert{
		CompanyID:  tenant.CompanyID(ctx),
		UnitID:     mustUUID(rep.UnitID),
		UnitNumber: unitNumber,
		DvirID:     mustUUID(rep.ID),
		Defects:    names,
	}
	kind := AlertDefectsFound
	a.Message = "DVIR defects reported"
	if critical {
		kind = AlertCriticalDefect
		a.Message = "critical defect: unit placed out of service"
	}
	s.alert(ctx, kind, a)
}

func (s *Service) alert(ctx context.Context, kind string, a Alert) {
	if err := s.alerter.Alert(ctx, kind, a); err != nil {
		s.log.ErrorContext(ctx, "dvir: alert not delivered",
			slog.String("alert", kind), slog.String("error", err.Error()))
	}
}

// ownsKey rejects an object key that does not belong to the caller's tenant.
// An empty key is optional and passes; a foreign key would otherwise be stored
// and honoured by a later presigned download (TZ B§3.4).
func ownsKey(ctx context.Context, field, key string) error {
	if strings.TrimSpace(key) == "" {
		return nil
	}
	if storage.OwnsKey(tenant.CompanyID(ctx), key) {
		return nil
	}
	return apierr.Validation("the object key does not belong to this company",
		apierr.FieldError{Field: field, Message: "unknown object key"})
}

func strPtr(v string) *string {
	if v == "" {
		return nil
	}
	out := v
	return &out
}

func uuidToPG(id uuid.UUID) pgtype.UUID {
	return pgtype.UUID{Bytes: id, Valid: id != uuid.Nil}
}

func mustUUID(v string) uuid.UUID {
	id, err := uuid.Parse(v)
	if err != nil {
		return uuid.Nil
	}
	return id
}
