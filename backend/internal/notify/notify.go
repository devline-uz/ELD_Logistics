// Package notify is the provider abstraction behind every alert the platform
// sends (TZ A§19 / Q89). The domain layer publishes a Notification; the
// dispatcher resolves the recipients and the channels from the company's
// notification_settings and hands each message to a channel Sender.
//
// A missing provider credential is never fatal: the sender degrades to
// NopSender and logs a warning once, so a development or staging deployment
// boots without FCM, APNs, SMTP or an SMS gateway.
package notify

import (
	"context"

	"github.com/google/uuid"
)

// Alert types (TZ A§19 table). The values are stored in
// notifications.alert_type and notification_settings.alert_type.
const (
	AlertHOSWarning          = "hos_warning"
	AlertHOSViolation        = "hos_violation"
	AlertRouteAssigned       = "route_assigned"
	AlertRouteReassigned     = "route_reassigned"
	AlertRouteCompleted      = "route_completed"
	AlertRouteNotCompleted   = "route_not_completed"
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
	AlertExportReady         = "export_ready"
	AlertExportFailed        = "export_failed"
)

// AllAlertTypes is the complete catalogue; notification_settings rejects
// anything outside it.
var AllAlertTypes = []string{
	AlertHOSWarning, AlertHOSViolation,
	AlertRouteAssigned, AlertRouteReassigned, AlertRouteCompleted, AlertRouteNotCompleted,
	AlertDVIRDefects, AlertDVIRCritical,
	AlertLogEditRequest, AlertLogEditResolved,
	AlertUncertifiedLog, AlertUnidentifiedDriving,
	AlertELDDisconnected, AlertELDMalfunction,
	AlertMaintenanceUpcoming, AlertMaintenanceOverdue,
	AlertChatMessage, AlertSubscriptionExpires,
	AlertExportReady, AlertExportFailed,
}

// IsAlertType reports whether v is a known alert type.
func IsAlertType(v string) bool {
	for _, a := range AllAlertTypes {
		if a == v {
			return true
		}
	}
	return false
}

// Delivery channels (Q89).
const (
	ChannelPush     = "push"
	ChannelEmail    = "email"
	ChannelSMS      = "sms"
	ChannelTelegram = "telegram"
	// ChannelInApp is always written: the notifications table is the in-app
	// inbox and is never optional.
	ChannelInApp = "in_app"
)

// AllChannels is the catalogue accepted by notification_settings.
var AllChannels = []string{ChannelPush, ChannelEmail, ChannelSMS, ChannelTelegram, ChannelInApp}

// IsChannel reports whether v is a known delivery channel.
func IsChannel(v string) bool {
	for _, c := range AllChannels {
		if c == v {
			return true
		}
	}
	return false
}

// Notification is one alert addressed to one user.
type Notification struct {
	// CompanyID is the tenant. The dispatcher fills it from the context when
	// it is zero.
	CompanyID  uuid.UUID
	UserID     uuid.UUID
	AlertType  string
	Title      string
	Body       string
	EntityType string
	EntityID   *uuid.UUID
	// Channels overrides the company settings when non empty. The mandatory
	// channels of a safety alert are added back by the dispatcher.
	Channels []string
	// Data is the push payload; values must stay free of PII.
	Data map[string]string
}

// Notifier sends one notification to one user.
type Notifier interface {
	Send(ctx context.Context, n Notification) error
}

// NopNotifier discards notifications; used by tests and by services that run
// without a dispatcher.
type NopNotifier struct{}

// Send implements Notifier.
func (NopNotifier) Send(context.Context, Notification) error { return nil }

// Event is a role addressed alert: the dispatcher expands it into one
// Notification per recipient using notification_settings.recipient_roles.
type Event struct {
	CompanyID  uuid.UUID
	AlertType  string
	Title      string
	Body       string
	EntityType string
	EntityID   *uuid.UUID
	// Users are recipients that are always included (for example the driver an
	// HOS warning is about), on top of the configured recipient roles.
	Users []uuid.UUID
	Data  map[string]string
}
