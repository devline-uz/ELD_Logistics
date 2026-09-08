package companies

import (
	"encoding/json"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/companies/dto"
	"github.com/devline/onebook-eld/internal/domain/company"
)

// adminInvite is the validated Administrator payload.
type adminInvite struct {
	user    AdminUser
	channel string
}

// normaliseAdmin trims, defaults and validates the Administrator payload. The
// username falls back to the local part of the email address; an SMS or
// Telegram invitation requires a phone number.
func normaliseAdmin(in dto.AdministratorInvite) (adminInvite, error) {
	var details []apierr.FieldError

	email := strings.ToLower(strings.TrimSpace(in.Email))
	phone := strings.TrimSpace(in.Phone)
	username := strings.ToLower(strings.TrimSpace(in.Username))
	if username == "" {
		if at := strings.IndexByte(email, '@'); at > 0 {
			username = email[:at]
		}
	}
	if username == "" {
		details = append(details, apierr.FieldError{
			Field: "administrator.username", Message: "required",
		})
	}
	if len(username) > 128 {
		details = append(details, apierr.FieldError{
			Field: "administrator.username", Message: "must be at most 128",
		})
	}

	channel := strings.TrimSpace(in.Channel)
	if channel == "" {
		channel = channelEmail
	}
	if channel != channelEmail && phone == "" {
		details = append(details, apierr.FieldError{
			Field: "administrator.phone", Message: "required for a non email invitation channel",
		})
	}

	if len(details) > 0 {
		return adminInvite{}, apierr.Validation("validation failed", details...)
	}
	return adminInvite{
		user: AdminUser{
			FirstName: strings.TrimSpace(in.FirstName),
			LastName:  strings.TrimSpace(in.LastName),
			Email:     email,
			Phone:     phone,
			Username:  username,
		},
		channel: channel,
	}, nil
}

// defaultSettingsJSON renders the settings document a new tenant starts with.
func defaultSettingsJSON(region string) ([]byte, error) {
	raw, err := json.Marshal(company.DefaultSettings(strings.TrimSpace(region)))
	if err != nil {
		return nil, apierr.Internal(err, "could not encode the default company settings")
	}
	return raw, nil
}

// validateTimezone rejects anything the IANA database does not know, so a
// daily log boundary can always be computed (Q10.2).
func validateTimezone(field, tz string) error {
	if tz == "" {
		return apierr.Validation("validation failed",
			apierr.FieldError{Field: field, Message: "required"})
	}
	if _, err := time.LoadLocation(tz); err != nil {
		return apierr.Validation("validation failed",
			apierr.FieldError{Field: field, Message: "must be an IANA time zone, e.g. America/Chicago"})
	}
	return nil
}

func isSubscriptionStatus(v string) bool {
	switch v {
	case "trial", "active", "grace", "readonly":
		return true
	}
	return false
}

func isRegion(v string) bool {
	switch v {
	case "PK", "UZ", "US", "other":
		return true
	}
	return false
}

func companyFields(c db.Company) map[string]any {
	return map[string]any{
		"name":                  c.Name,
		"address":               derefString(c.Address),
		"home_terminal_address": derefString(c.HomeTerminalAddress),
		"timezone":              c.Timezone,
		"email":                 derefString(c.Email),
		"phone":                 derefString(c.Phone),
		"registration_no":       derefString(c.RegistrationNo),
		"logo_key":              derefString(c.LogoKey),
		"region":                derefString(c.Region),
		"unit_system":           c.UnitSystem,
		"regulation_profile":    c.RegulationProfile,
		"plan":                  derefString(c.Plan),
	}
}

func subscriptionFields(c db.Company) map[string]any {
	end := ""
	if c.SubscriptionEndAt.Valid {
		end = c.SubscriptionEndAt.Time.UTC().Format(time.RFC3339)
	}
	return map[string]any{
		"subscription_status": c.SubscriptionStatus,
		"subscription_end_at": end,
		"plan":                derefString(c.Plan),
	}
}

func patchFields(p db.UpdateCompanyParams) map[string]any {
	out := map[string]any{}
	put := func(k string, v *string) {
		if v != nil {
			out[k] = *v
		}
	}
	put("name", p.Name)
	put("address", p.Address)
	put("home_terminal_address", p.HomeTerminalAddress)
	put("timezone", p.Timezone)
	put("email", p.Email)
	put("phone", p.Phone)
	put("registration_no", p.RegistrationNo)
	put("logo_key", p.LogoKey)
	put("region", p.Region)
	put("unit_system", p.UnitSystem)
	put("regulation_profile", p.RegulationProfile)
	put("plan", p.Plan)
	return out
}

func derefString(v *string) string {
	if v == nil {
		return ""
	}
	return *v
}

func trimPtr(v *string) *string {
	if v == nil {
		return nil
	}
	s := strings.TrimSpace(*v)
	return &s
}

func lowerPtr(v *string) *string {
	if v == nil {
		return nil
	}
	s := strings.ToLower(strings.TrimSpace(*v))
	return &s
}
