package maintenance

import (
	"context"

	"github.com/google/uuid"
)

// Reminder kinds raised by this module. They are consumed by the notification
// module during wiring; this package never imports internal/notify.
const (
	// ReminderDue is the Q37 "service is coming up" reminder. It fires once per
	// cycle, guarded by `reminder_sent_at`.
	ReminderDue = "maintenance.reminder_due"
	// ReminderOverdue reports a schedule whose remaining value went negative.
	ReminderOverdue = "maintenance.overdue"
)

// Reminder is the payload handed to the notification module.
type Reminder struct {
	CompanyID      uuid.UUID
	ScheduleID     uuid.UUID
	ScheduleUnitID uuid.UUID
	ScheduleName   string
	UnitID         uuid.UUID
	UnitNumber     string
	// AlertType and DeliveryMethods mirror the schedule configuration so the
	// notifier does not have to read it back.
	AlertType       string
	DeliveryMethods []string
	// Recipients are the user ids of the assigned drivers. The co-driver is
	// included only when the schedule sets `notify_co_driver` (Q38).
	Recipients []uuid.UUID
	// Remaining is the distance / hours / days left; negative means overdue.
	Remaining *float64
	Unit      string
	Message   string
}

// Alerter is the consumer side interface of the notification fan out. The
// concrete implementation is injected at wiring time so this package stays
// independent of internal/notify.
type Alerter interface {
	Alert(ctx context.Context, alertType string, r Reminder) error
}

// NopAlerter drops every reminder. It is the default when no notifier is wired.
type NopAlerter struct{}

// Alert implements Alerter.
func (NopAlerter) Alert(context.Context, string, Reminder) error { return nil }
