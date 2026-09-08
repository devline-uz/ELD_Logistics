package maintenance

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/maintenance/dto"
	"github.com/devline/onebook-eld/internal/tenant"
)

// ---------------------------------------------------------------- helpers

// resolveUnits validates the fleet of a schedule and seeds each unit's starting
// reading from telemetry when the caller did not supply one.
func (s *Service) resolveUnits(
	ctx context.Context, in []dto.ScheduleUnitInput, intervalUnit string, intervalValue float64,
) ([]db.AttachUnitToScheduleParams, error) {
	out := make([]db.AttachUnitToScheduleParams, 0, len(in))
	seen := make(map[uuid.UUID]bool, len(in))
	now := s.now().UTC()
	for i, u := range in {
		id, err := uuid.Parse(u.UnitID)
		if err != nil {
			return nil, apierr.Validation("unit_id must be a uuid",
				apierr.FieldError{Field: fieldIndex("units", i, "unit_id"), Message: "must be a uuid"})
		}
		if seen[id] {
			return nil, apierr.Validation("duplicate unit in the schedule",
				apierr.FieldError{Field: fieldIndex("units", i, "unit_id"), Message: "listed twice"})
		}
		seen[id] = true
		if _, err := s.repo.Unit(ctx, id); err != nil {
			return nil, db.MapError(err, "unit")
		}

		p := db.AttachUnitToScheduleParams{CompanyID: tenant.CompanyID(ctx), UnitID: id}
		if intervalUnit == dto.UnitDays {
			p.LastServiceAt = pgtype.Timestamptz{Time: now, Valid: true}
			p.NextDueAt = pgtype.Timestamptz{Time: now.AddDate(0, 0, int(intervalValue)), Valid: true}
			out = append(out, p)
			continue
		}

		last := u.LastServiceValue
		if last == nil {
			if v := s.reading(ctx, id, intervalUnit); v != nil {
				last = v
			}
		}
		if last != nil {
			p.LastServiceValue = floatToNumeric(*last)
			p.NextDueValue = floatToNumeric(*last + intervalValue)
			p.LastServiceAt = pgtype.Timestamptz{Time: now, Valid: true}
		}
		out = append(out, p)
	}
	return out, nil
}

// reading resolves the live telemetry value of a unit in the schedule unit.
func (s *Service) reading(ctx context.Context, unitID uuid.UUID, intervalUnit string) *float64 {
	row, err := s.repo.Reading(ctx, unitID)
	if err != nil {
		return nil
	}
	return currentValue(unitRow{
		IntervalUnit:       intervalUnit,
		OdometerM:          row.OdometerM,
		CurrentEngineHours: row.EngineHours,
	}, s.now().UTC())
}

func strPtr(v string) *string {
	if v == "" {
		return nil
	}
	out := v
	return &out
}

func orDefault(v, def string) string {
	if v == "" {
		return def
	}
	return v
}

func orEmpty(v []string) []string {
	if v == nil {
		return []string{}
	}
	return v
}

func fieldIndex(base string, i int, leaf string) string {
	return base + "[" + itoa(i) + "]." + leaf
}

func itoa(i int) string {
	if i == 0 {
		return "0"
	}
	var buf [12]byte
	pos := len(buf)
	for i > 0 {
		pos--
		buf[pos] = byte('0' + i%10)
		i /= 10
	}
	return string(buf[pos:])
}
