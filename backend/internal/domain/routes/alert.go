package routes

import (
	"context"

	"github.com/google/uuid"
)

// Alert kinds raised by this module. They are consumed by the notification
// module during wiring; this package never imports internal/notify.
const (
	// AlertRouteAssigned tells the driver a new leg was planned for them
	// (Q66.1 — push plus "Open in Maps" in the app).
	AlertRouteAssigned = "routes.assigned"
	// AlertRouteReassigned fires when an existing route changes driver.
	AlertRouteReassigned = "routes.reassigned"
	// AlertRouteCompleted reports the geofence completion to dispatch.
	AlertRouteCompleted = "routes.completed"
	// AlertRouteNotCompleted reports the admin closure to the driver.
	AlertRouteNotCompleted = "routes.not_completed"
)

// Alert is the payload handed to the notification module. It carries no PII:
// the destination text is an address the dispatcher typed, never a person.
type Alert struct {
	CompanyID uuid.UUID
	RouteID   uuid.UUID
	UnitID    uuid.UUID
	DriverID  uuid.UUID
	// UnitNumber is the fleet number shown in the notification.
	UnitNumber string
	// OriginText and DestText are the planner addresses.
	OriginText string
	DestText   string
	// Sequence is the position of the route in the unit's queue (Q68).
	Sequence int32
	// Reason is set on AlertRouteNotCompleted.
	Reason string
	// Message is a short human summary.
	Message string
}

// Alerter is the consumer side interface of the notification fan out. The
// concrete implementation is injected at wiring time so this package stays
// independent of internal/notify.
type Alerter interface {
	Alert(ctx context.Context, alertType string, a Alert) error
}

// NopAlerter drops every alert. It is the default when no notifier is wired.
type NopAlerter struct{}

// Alert implements Alerter.
func (NopAlerter) Alert(context.Context, string, Alert) error { return nil }
