package company

import (
	"context"
	"encoding/json"
	"strconv"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/company/dto"
	"github.com/devline/onebook-eld/internal/hos"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

const (
	maxQuickNotes   = 40
	maxFuelTypes    = 24
	maxSettingValue = 64
	// maxPolicyLead caps how far into the future a policy version may start.
	maxPolicyLead = 365 * 24 * time.Hour
	// policySkew tolerates client clock drift on effective_from.
	policySkew = time.Minute
)

// mergeSettings validates the incoming settings document and renders the JSONB
// patch that is merged into companies.settings.
func mergeSettings(before db.Company, in dto.Settings, region *string) ([]byte, error) {
	var details []apierr.FieldError

	notes, err := cleanList(in.QuickNotes, "settings.quick_notes", maxQuickNotes)
	if err != nil {
		details = append(details, err...)
	}
	fuels, err := cleanList(in.FuelTypes, "settings.fuel_types", maxFuelTypes)
	if err != nil {
		details = append(details, err...)
	}

	set := strings.TrimSpace(in.DistanceRegionsSet)
	if set == "" {
		effective := pgconv.Deref(before.Region)
		if region != nil {
			effective = *region
		}
		set = DefaultRegionSet(effective)
	}
	if !IsRegionSet(set) {
		details = append(details, apierr.FieldError{
			Field:   "settings.distance_regions_set",
			Message: "must be one of: us_states, pk_provinces, uz_regions, none",
		})
	}
	if len(details) > 0 {
		return nil, apierr.Validation("validation failed", details...)
	}

	stored := StoredSettings{QuickNotes: notes, FuelTypes: fuels, DistanceRegionsSet: set}
	if stored.QuickNotes == nil {
		stored.QuickNotes = []string{}
	}
	if stored.FuelTypes == nil {
		stored.FuelTypes = []string{}
	}
	raw, mErr := json.Marshal(map[string]any{
		"quick_notes":          stored.QuickNotes,
		"fuel_types":           stored.FuelTypes,
		"distance_regions_set": stored.DistanceRegionsSet,
	})
	if mErr != nil {
		return nil, apierr.Internal(mErr, "could not encode company settings")
	}
	return raw, nil
}

func cleanList(in []string, field string, max int) ([]string, []apierr.FieldError) {
	if in == nil {
		return nil, nil
	}
	if len(in) > max {
		return nil, []apierr.FieldError{{Field: field, Message: "must contain at most " + strconv.Itoa(max) + " entries"}}
	}
	out := make([]string, 0, len(in))
	seen := make(map[string]bool, len(in))
	for _, raw := range in {
		v := strings.TrimSpace(raw)
		if v == "" {
			return nil, []apierr.FieldError{{Field: field, Message: "entries must not be empty"}}
		}
		if len(v) > maxSettingValue {
			return nil, []apierr.FieldError{{Field: field, Message: "entries must be at most 64 characters"}}
		}
		if seen[strings.ToLower(v)] {
			return nil, []apierr.FieldError{{Field: field, Message: "entries must be unique"}}
		}
		seen[strings.ToLower(v)] = true
		out = append(out, v)
	}
	return out, nil
}

// HosPolicy returns the version effective right now. A company that predates
// the policy versioning falls back to the FMCSA 70/8 defaults (TZ A§4.2).
func (s *Service) HosPolicy(ctx context.Context) (*dto.HosPolicy, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}
	row, err := s.repo.ActiveHosPolicy(ctx, companyID)
	if err != nil {
		if apierr.Is(err, apierr.CodeNotFound) {
			return &dto.HosPolicy{
				EffectiveFrom: time.Time{},
				CreatedAt:     time.Time{},
				Policy:        policyToDoc(hos.DefaultPolicy()),
			}, nil
		}
		return nil, err
	}
	out, pErr := toHosPolicy(row)
	if pErr != nil {
		return nil, apierr.Internal(pErr, "stored hos policy is not readable")
	}
	return &out, nil
}

// CreateHosPolicy publishes a new version. Q10.1: existing days keep being
// evaluated with the version that was effective back then, so effective_from
// must not move into the past.
func (s *Service) CreateHosPolicy(ctx context.Context, in dto.HosPolicyCreate, meta RequestMeta) (*dto.HosPolicy, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}

	// A nil effective_from is resolved by the database clock, so a few
	// milliseconds of drift between the API host and Postgres can never leave
	// a brand new version sitting in the future.
	now := s.now().UTC()
	var effective *time.Time
	if in.EffectiveFrom != nil {
		v := in.EffectiveFrom.UTC()
		if v.Before(now.Add(-policySkew)) {
			return nil, apierr.Validation("validation failed", apierr.FieldError{
				Field:   "effective_from",
				Message: "must not be in the past: a policy change is never retroactive",
			})
		}
		if v.After(now.Add(maxPolicyLead)) {
			return nil, apierr.Validation("validation failed", apierr.FieldError{
				Field:   "effective_from",
				Message: "must be at most one year ahead",
			})
		}
		effective = &v
	}

	base := hos.DefaultPolicy()
	if current, cErr := s.repo.ActiveHosPolicy(ctx, companyID); cErr == nil {
		if parsed, pErr := hos.ParsePolicy(current.Policy); pErr == nil {
			base = parsed
		}
	} else if !apierr.Is(cErr, apierr.CodeNotFound) {
		return nil, cErr
	}

	merged := mergePolicy(base, in.Policy)
	if err := validatePolicy(merged); err != nil {
		return nil, err
	}

	raw, mErr := json.Marshal(merged)
	if mErr != nil {
		return nil, apierr.Internal(mErr, "could not encode hos policy")
	}
	beforeRaw, _ := json.Marshal(base)

	row, err := s.repo.CreateHosPolicy(ctx, CreateHosPolicyInput{
		CompanyID:     companyID,
		EffectiveFrom: effective,
		Policy:        raw,
		CreatedBy:     tenant.UserID(ctx),
		Audit: []audit.Entry{{
			TableName: tableHosPolicy,
			Field:     "policy",
			OldValue:  json.RawMessage(beforeRaw),
			NewValue:  json.RawMessage(raw),
			Action:    actionHosPolicy,
			IP:        meta.IP,
			Reason:    effectiveReason(effective),
		}},
	})
	if err != nil {
		return nil, err
	}
	out, pErr := toHosPolicy(row)
	if pErr != nil {
		return nil, apierr.Internal(pErr, "stored hos policy is not readable")
	}
	return &out, nil
}

// NotificationSettings returns the full A§19 configuration, filling in the
// defaults for any alert type the company never touched.
func (s *Service) NotificationSettings(ctx context.Context) ([]dto.NotificationSetting, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}
	rows, err := s.repo.NotificationSettings(ctx, companyID)
	if err != nil {
		return nil, err
	}
	return toNotificationSettings(rows), nil
}

// UpdateNotificationSettings upserts the given alert types and returns the
// full configuration.
func (s *Service) UpdateNotificationSettings(
	ctx context.Context, in dto.NotificationSettingsUpdate, meta RequestMeta,
) ([]dto.NotificationSetting, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, err
	}
	if len(in.Settings) > maxNotificationRows {
		return nil, apierr.Validation("validation failed", apierr.FieldError{
			Field: "settings", Message: "must contain at most 64 entries",
		})
	}

	current, err := s.repo.NotificationSettings(ctx, companyID)
	if err != nil {
		return nil, err
	}
	byType := make(map[string]db.NotificationSetting, len(current))
	for _, r := range current {
		byType[r.AlertType] = r
	}

	var (
		details []apierr.FieldError
		batch   []NotificationSettingInput
		entries []audit.Entry
		seen    = map[string]bool{}
	)
	for i, item := range in.Settings {
		field := "settings[" + strconv.Itoa(i) + "]"
		alert := strings.TrimSpace(item.AlertType)
		if !IsAlertType(alert) {
			details = append(details, apierr.FieldError{Field: field + ".alert_type", Message: "unknown alert type"})
			continue
		}
		if seen[alert] {
			details = append(details, apierr.FieldError{Field: field + ".alert_type", Message: "duplicated alert type"})
			continue
		}
		seen[alert] = true

		channels, chErr := cleanChannels(item.Channels, field+".channels")
		if chErr != nil {
			details = append(details, chErr...)
			continue
		}
		roles, rErr := parseRoleIDs(item.RecipientRoles, field+".recipient_roles")
		if rErr != nil {
			details = append(details, rErr...)
			continue
		}

		enabled := true
		if item.Enabled != nil {
			enabled = *item.Enabled
		}

		prev := byType[alert]
		batch = append(batch, NotificationSettingInput{
			AlertType: alert, Channels: channels, RecipientRoles: roles, Enabled: enabled,
		})
		changes := audit.Changes(tableNotifSettings, companyID, audit.ActionUpdate,
			map[string]any{
				alert + ".channels":        strings.Join(prev.Channels, ","),
				alert + ".recipient_roles": strings.Join(uuidsToStrings(prev.RecipientRoles), ","),
				alert + ".enabled":         prev.Enabled,
			},
			map[string]any{
				alert + ".channels":        strings.Join(channels, ","),
				alert + ".recipient_roles": strings.Join(uuidsToStrings(roles), ","),
				alert + ".enabled":         enabled,
			})
		for j := range changes {
			changes[j].IP = meta.IP
		}
		entries = append(entries, changes...)
	}
	if len(details) > 0 {
		return nil, apierr.Validation("validation failed", details...)
	}

	rows, err := s.repo.UpsertNotificationSettings(ctx, UpsertNotificationsInput{
		CompanyID: companyID, Settings: batch, Audit: entries,
	})
	if err != nil {
		return nil, err
	}
	return toNotificationSettings(rows), nil
}

func cleanChannels(in []string, field string) ([]string, []apierr.FieldError) {
	out := make([]string, 0, len(in))
	seen := map[string]bool{}
	for _, raw := range in {
		v := strings.ToLower(strings.TrimSpace(raw))
		if !IsChannel(v) {
			return nil, []apierr.FieldError{{Field: field, Message: "must be one of: push, email, sms, telegram"}}
		}
		if seen[v] {
			continue
		}
		seen[v] = true
		out = append(out, v)
	}
	return out, nil
}

func parseRoleIDs(in []string, field string) ([]uuid.UUID, []apierr.FieldError) {
	out := make([]uuid.UUID, 0, len(in))
	seen := map[uuid.UUID]bool{}
	for _, raw := range in {
		id, err := uuid.Parse(strings.TrimSpace(raw))
		if err != nil {
			return nil, []apierr.FieldError{{Field: field, Message: "must be a valid uuid"}}
		}
		if seen[id] {
			continue
		}
		seen[id] = true
		out = append(out, id)
	}
	return out, nil
}

// HistoryQuery is the parsed GET /company/history filter.
type HistoryQuery struct {
	Table    string
	Action   string
	RecordID *uuid.UUID
	User     *uuid.UUID
	From     *time.Time
	To       *time.Time
}

// History returns the configuration audit trail of the caller's company.
func (s *Service) History(ctx context.Context, q HistoryQuery, page httpx.Page) ([]dto.HistoryEntry, int64, error) {
	companyID, err := companyOf(ctx)
	if err != nil {
		return nil, 0, err
	}
	if q.From != nil && q.To != nil && q.To.Before(*q.From) {
		return nil, 0, apierr.Validation("validation failed",
			apierr.FieldError{Field: "to", Message: "must not be earlier than from"})
	}

	rows, total, err := s.repo.History(ctx, HistoryFilter{
		CompanyID: companyID,
		TableName: optString(q.Table),
		Action:    optString(q.Action),
		RecordID:  q.RecordID,
		EditedBy:  q.User,
		From:      q.From,
		To:        q.To,
		Limit:     page.Limit(),
		Offset:    page.Offset(),
	})
	if err != nil {
		return nil, 0, err
	}
	out := make([]dto.HistoryEntry, 0, len(rows))
	for _, r := range rows {
		out = append(out, toHistoryEntry(r))
	}
	return out, total, nil
}

// effectiveReason renders the audit reason of a policy version.
func effectiveReason(t *time.Time) string {
	if t == nil {
		return "effective immediately"
	}
	return "effective_from " + t.UTC().Format(time.RFC3339)
}
