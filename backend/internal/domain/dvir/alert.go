package dvir

import (
	"context"

	"github.com/google/uuid"
)

// Alert kinds raised by this module. They are consumed by the notification
// module during wiring; this package never imports internal/notify.
const (
	// AlertCriticalDefect is the Q27.2 immediate alert to admins and the
	// Service Manager: a critical defect put the unit out of service.
	AlertCriticalDefect = "dvir.critical_defect"
	// AlertDefectsFound tells the Service Manager a report waits for repair.
	AlertDefectsFound = "dvir.defects_found"
	// AlertPendingCertification tells the driver a repaired report waits for
	// the "Previous defects repaired?" signature.
	AlertPendingCertification = "dvir.pending_certification"
	// AlertClosedNoCertification reports the Q30.1 fallback outcome.
	AlertClosedNoCertification = "dvir.closed_no_certification"
)

// Alert is the payload handed to the notification module.
type Alert struct {
	CompanyID  uuid.UUID
	DvirID     uuid.UUID
	UnitID     uuid.UUID
	UnitNumber string
	DriverID   uuid.UUID
	// Defects lists the defect names that triggered the alert.
	Defects []string
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
