package logs

import (
	"context"

	"github.com/google/uuid"
)

// Alert kinds raised by this module. They are consumed by the notification
// module during wiring; this package never imports internal/notify.
const (
	// AlertLogEditRequested tells the driver an administrator proposed a
	// change to one of its log days (TZ A§5.3): "Admin proposed a change to
	// your log for <date>".
	AlertLogEditRequested = "log_edit_request"
	// AlertLogEditResolved tells the administrator that its proposal was
	// approved or rejected by the driver (TZ A§5.3).
	AlertLogEditResolved = "log_edit_resolved"
)

// Alert is the payload handed to the notification module.
type Alert struct {
	CompanyID  uuid.UUID
	DriverID   uuid.UUID
	DailyLogID uuid.UUID
	RequestID  uuid.UUID
	// LogDate is the home terminal calendar day (Q10.2), `YYYY-MM-DD`.
	LogDate string
	// RequestedBy is the admin who proposed the request; set on every alert
	// so a resolved alert can be routed back to its author.
	RequestedBy uuid.UUID
	// Status is empty on a fresh proposal, `approved` or `rejected` once
	// answered.
	Status string
	// Message is a short, PII free human summary.
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
