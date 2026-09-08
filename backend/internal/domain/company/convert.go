package company

import (
	"encoding/json"
	"sort"
	"strings"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/company/dto"
	"github.com/devline/onebook-eld/internal/hos"
)

// parseSettings decodes companies.settings, filling the gaps with the region
// defaults so the client always receives a complete document.
func parseSettings(raw []byte, region string) dto.Settings {
	stored := StoredSettings{}
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &stored)
	}
	def := DefaultSettings(region)
	if len(stored.QuickNotes) == 0 {
		stored.QuickNotes = def.QuickNotes
	}
	if len(stored.FuelTypes) == 0 {
		stored.FuelTypes = def.FuelTypes
	}
	if stored.DistanceRegionsSet == "" {
		stored.DistanceRegionsSet = def.DistanceRegionsSet
	}
	return dto.Settings{
		QuickNotes:         stored.QuickNotes,
		FuelTypes:          stored.FuelTypes,
		DistanceRegionsSet: stored.DistanceRegionsSet,
	}
}

// ToCompany maps the sqlc row onto the wire contract.
func ToCompany(c db.Company) dto.Company {
	region := pgconv.Deref(c.Region)
	return dto.Company{
		ID:                  c.ID.String(),
		Name:                c.Name,
		Address:             pgconv.Deref(c.Address),
		HomeTerminalAddress: pgconv.Deref(c.HomeTerminalAddress),
		Timezone:            c.Timezone,
		Email:               pgconv.Deref(c.Email),
		Phone:               pgconv.Deref(c.Phone),
		RegistrationNo:      pgconv.Deref(c.RegistrationNo),
		LogoKey:             pgconv.Deref(c.LogoKey),
		Region:              region,
		UnitSystem:          c.UnitSystem,
		RegulationProfile:   c.RegulationProfile,
		SubscriptionStatus:  c.SubscriptionStatus,
		SubscriptionEndAt:   pgconv.ToTimePtr(c.SubscriptionEndAt),
		Plan:                pgconv.Deref(c.Plan),
		Settings:            parseSettings(c.Settings, region),
		CreatedAt:           c.CreatedAt.UTC(),
		UpdatedAt:           c.UpdatedAt.UTC(),
	}
}

func toBranch(b db.Branch) dto.Branch {
	return dto.Branch{
		ID:        b.ID.String(),
		Name:      b.Name,
		Address:   pgconv.Deref(b.Address),
		Timezone:  pgconv.Deref(b.Timezone),
		CreatedAt: b.CreatedAt.UTC(),
		UpdatedAt: b.UpdatedAt.UTC(),
	}
}

func policyToDoc(p hos.Policy) dto.HosPolicyDoc {
	statuses := make([]string, 0, len(p.BreakQualifyingStatuses))
	for _, s := range p.BreakQualifyingStatuses {
		statuses = append(statuses, string(s))
	}
	return dto.HosPolicyDoc{
		DriveLimitMin:              p.DriveLimitMin,
		ShiftWindowMin:             p.ShiftWindowMin,
		BreakRequiredAfterDriveMin: p.BreakRequiredAfterDriveMin,
		BreakDurationMin:           p.BreakDurationMin,
		BreakQualifyingStatuses:    statuses,
		DailyRestMin:               p.DailyRestMin,
		CycleLimitMin:              p.CycleLimitMin,
		CycleDays:                  p.CycleDays,
		CycleRestartMin:            p.CycleRestartMin,
		SleeperSplitEnabled:        p.SleeperSplitEnabled,
		SleeperBerthAvailable:      p.SleeperBerthAvailable,
		AllowPC:                    p.AllowPC,
		AllowYM:                    p.AllowYM,
		YMMaxSpeedKmh:              p.YMMaxSpeedKmh,
		MotionThresholdKmh:         p.MotionThresholdKmh,
		ShortHaulException:         p.ShortHaulException,
		AdverseConditionsExtMin:    p.AdverseConditionsExtMin,
		WarningThresholds: dto.WarningThresholds{
			Drive: p.WarningThresholds.DriveMin,
			Shift: p.WarningThresholds.ShiftMin,
			Break: p.WarningThresholds.BreakMin,
			Cycle: p.WarningThresholds.CycleMin,
		},
	}
}

func toHosPolicy(v db.HosPolicyVersion) (dto.HosPolicy, error) {
	p, err := hos.ParsePolicy(v.Policy)
	if err != nil {
		return dto.HosPolicy{}, err
	}
	return dto.HosPolicy{
		ID:            v.ID.String(),
		EffectiveFrom: v.EffectiveFrom.UTC(),
		CreatedBy:     pgconv.UUIDString(v.CreatedBy),
		CreatedAt:     v.CreatedAt.UTC(),
		Policy:        policyToDoc(p),
	}, nil
}

// toNotificationSettings renders the stored rows in the canonical A§19 order
// and fills in any alert type the company has not customised yet.
func toNotificationSettings(rows []db.NotificationSetting) []dto.NotificationSetting {
	byType := make(map[string]db.NotificationSetting, len(rows))
	for _, r := range rows {
		byType[r.AlertType] = r
	}

	out := make([]dto.NotificationSetting, 0, len(AlertDefaults))
	for _, d := range AlertDefaults {
		if row, ok := byType[d.AlertType]; ok {
			out = append(out, dto.NotificationSetting{
				AlertType:      row.AlertType,
				Channels:       stringsOrEmpty(row.Channels),
				RecipientRoles: uuidsToStrings(row.RecipientRoles),
				Enabled:        row.Enabled,
			})
			continue
		}
		out = append(out, dto.NotificationSetting{
			AlertType:      d.AlertType,
			Channels:       append([]string(nil), d.Channels...),
			RecipientRoles: []string{},
			Enabled:        true,
		})
	}

	// Anything stored outside the catalogue is still surfaced, sorted by name,
	// so a forward compatible alert type never disappears silently.
	extra := make([]dto.NotificationSetting, 0)
	for _, r := range rows {
		if IsAlertType(r.AlertType) {
			continue
		}
		extra = append(extra, dto.NotificationSetting{
			AlertType:      r.AlertType,
			Channels:       stringsOrEmpty(r.Channels),
			RecipientRoles: uuidsToStrings(r.RecipientRoles),
			Enabled:        r.Enabled,
		})
	}
	sort.Slice(extra, func(i, j int) bool { return extra[i].AlertType < extra[j].AlertType })
	return append(out, extra...)
}

func stringsOrEmpty(v []string) []string {
	if v == nil {
		return []string{}
	}
	return v
}

func uuidsToStrings(ids []uuid.UUID) []string {
	out := make([]string, 0, len(ids))
	for _, id := range ids {
		out = append(out, id.String())
	}
	return out
}

// toHistoryEntry maps an audit row. The client IP is deliberately dropped: it
// is PII and never leaves the audit table.
func toHistoryEntry(r db.ListCompanyAuditHistoryRow) dto.HistoryEntry {
	name := strings.TrimSpace(pgconv.Deref(r.FirstName) + " " + pgconv.Deref(r.LastName))
	if name == "" {
		name = pgconv.Deref(r.Username)
	}
	return dto.HistoryEntry{
		ID:           r.ID.String(),
		TableName:    r.TableName,
		RecordID:     pgconv.UUIDString(r.RecordID),
		Field:        pgconv.Deref(r.Field),
		OldValue:     decodeJSON(r.OldValue),
		NewValue:     decodeJSON(r.NewValue),
		Action:       r.Action,
		EditedBy:     pgconv.UUIDString(r.EditedBy),
		EditedByName: name,
		Timestamp:    r.Ts.UTC(),
	}
}

func decodeJSON(raw []byte) any {
	if len(raw) == 0 {
		return nil
	}
	var v any
	if err := json.Unmarshal(raw, &v); err != nil {
		return nil
	}
	return v
}
