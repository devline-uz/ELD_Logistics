package company

import (
	"encoding/json"

	"github.com/devline/onebook-eld/internal/hos"
)

// Alert types a company can configure (TZ A§19). The list is closed: an alert
// type outside it is rejected with VALIDATION_ERROR.
const (
	AlertHosWarning          = "hos_warning"
	AlertHosViolation        = "hos_violation"
	AlertRouteAssigned       = "route_assigned"
	AlertRouteCompleted      = "route_completed"
	AlertDVIRDefects         = "dvir_defects"
	AlertDVIRCritical        = "dvir_critical"
	AlertLogEditRequest      = "log_edit_request"
	AlertLogEditResolved     = "log_edit_resolved"
	AlertUncertifiedLog      = "uncertified_log"
	AlertUnidentifiedDriving = "unidentified_driving"
	AlertELDDisconnected     = "eld_disconnected"
	AlertELDMalfunction      = "eld_malfunction"
	AlertMaintenanceUpcoming = "maintenance_upcoming"
	AlertMaintenanceOverdue  = "maintenance_overdue"
	AlertChatMessage         = "chat_message"
	AlertSubscriptionExpires = "subscription_expiring"
)

// Delivery channels (Q89). Telegram is [MAY] but configurable from day one.
const (
	ChannelPush     = "push"
	ChannelEmail    = "email"
	ChannelSMS      = "sms"
	ChannelTelegram = "telegram"
)

// System role names matched against a company's copied role templates below.
const (
	roleFleetManager  = "Fleet Manager"
	roleServiceMgr    = "Service Manager"
	roleSafetyManager = "Safety Manager"
	roleDispatcher    = "Dispatcher"
	roleAdministrator = "Administrator"
)

// AlertDefault is one row of the TZ A§19 table: which channels an alert type
// uses out of the box and which system roles receive it.
type AlertDefault struct {
	AlertType string
	Channels  []string
	// RoleNames are matched against the company's copied system roles; unknown
	// names are skipped.
	RoleNames []string
}

// AlertDefaults is the seed configuration written when a company is created.
// Order is the order GET /company/notification-settings returns.
var AlertDefaults = []AlertDefault{
	{AlertHosWarning, []string{ChannelPush}, []string{roleSafetyManager, roleFleetManager}},
	{AlertHosViolation, []string{ChannelPush, ChannelEmail}, []string{roleSafetyManager, roleFleetManager}},
	{AlertRouteAssigned, []string{ChannelPush}, []string{roleDispatcher}},
	{AlertRouteCompleted, []string{ChannelPush}, []string{roleDispatcher, roleFleetManager}},
	{AlertDVIRDefects, []string{ChannelPush, ChannelEmail}, []string{roleServiceMgr, roleFleetManager}},
	{AlertDVIRCritical, []string{ChannelPush, ChannelEmail, ChannelSMS}, []string{roleServiceMgr, roleFleetManager}},
	{AlertLogEditRequest, []string{ChannelPush}, []string{roleSafetyManager, roleFleetManager}},
	{AlertLogEditResolved, []string{ChannelPush}, []string{roleSafetyManager}},
	{AlertUncertifiedLog, []string{ChannelPush}, []string{roleSafetyManager}},
	{AlertUnidentifiedDriving, []string{ChannelPush, ChannelEmail}, []string{roleAdministrator, roleSafetyManager}},
	{AlertELDDisconnected, []string{ChannelPush}, []string{roleFleetManager}},
	{AlertELDMalfunction, []string{ChannelPush, ChannelEmail}, []string{roleFleetManager, roleServiceMgr}},
	{AlertMaintenanceUpcoming, []string{ChannelPush, ChannelEmail}, []string{roleFleetManager, roleServiceMgr}},
	{AlertMaintenanceOverdue, []string{ChannelPush, ChannelEmail}, []string{roleFleetManager, roleServiceMgr}},
	{AlertChatMessage, []string{ChannelPush}, nil},
	{AlertSubscriptionExpires, []string{ChannelEmail}, []string{roleAdministrator}},
}

// alertOrder maps an alert type to its position in AlertDefaults.
var alertOrder = func() map[string]int {
	m := make(map[string]int, len(AlertDefaults))
	for i, d := range AlertDefaults {
		m[d.AlertType] = i
	}
	return m
}()

// IsAlertType reports whether v is a configurable alert type.
func IsAlertType(v string) bool {
	_, ok := alertOrder[v]
	return ok
}

// IsChannel reports whether v is a known delivery channel.
func IsChannel(v string) bool {
	switch v {
	case ChannelPush, ChannelEmail, ChannelSMS, ChannelTelegram:
		return true
	}
	return false
}

// Distance region catalogues used by the "distance by region" report.
const (
	RegionSetUSStates    = "us_states"
	RegionSetPKProvinces = "pk_provinces"
	RegionSetUZProvinces = "uz_regions"
	RegionSetNone        = "none"
)

// IsRegionSet reports whether v is a known distance region catalogue.
func IsRegionSet(v string) bool {
	switch v {
	case RegionSetUSStates, RegionSetPKProvinces, RegionSetUZProvinces, RegionSetNone:
		return true
	}
	return false
}

// DefaultQuickNotes is the company wide quick note list (Q1.3).
var DefaultQuickNotes = []string{
	"PTI", "Hook", "Pickup", "Drop-off", "Delivery",
	"Inspection", "Check-in", "Fueling", "Check-out", "Break", "Other",
}

// DefaultFuelTypes mirrors the units.fuel_type catalogue.
var DefaultFuelTypes = []string{"diesel", "petrol", "cng", "lpg", "electric", "hybrid"}

// DefaultRegionSet picks the distance catalogue that matches a company region.
func DefaultRegionSet(region string) string {
	switch region {
	case "US":
		return RegionSetUSStates
	case "PK":
		return RegionSetPKProvinces
	case "UZ":
		return RegionSetUZProvinces
	default:
		return RegionSetNone
	}
}

// StoredSettings is the on disk shape of companies.settings.
type StoredSettings struct {
	QuickNotes         []string `json:"quick_notes,omitempty"`
	FuelTypes          []string `json:"fuel_types,omitempty"`
	DistanceRegionsSet string   `json:"distance_regions_set,omitempty"`
}

// DefaultSettings builds the settings document a new company starts with.
func DefaultSettings(region string) StoredSettings {
	return StoredSettings{
		QuickNotes:         append([]string(nil), DefaultQuickNotes...),
		FuelTypes:          append([]string(nil), DefaultFuelTypes...),
		DistanceRegionsSet: DefaultRegionSet(region),
	}
}

// DefaultHosPolicyJSON returns the FMCSA 70/8 policy document (TZ A§4.2) as it
// is stored in hos_policy_versions.policy.
func DefaultHosPolicyJSON() ([]byte, error) {
	return json.Marshal(hos.DefaultPolicy())
}
