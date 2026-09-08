package jobs

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"

	"github.com/devline/onebook-eld/internal/notify"
)

// Alert task type names. They are stable strings: renaming one strands the
// tasks already queued in Redis.
const (
	// TypeFanOutDailyAlerts is the hourly tick that turns UTC time into the
	// per tenant local schedule (TZ A§19 — 20:00 Company TZ).
	TypeFanOutDailyAlerts = "alerts:fanout_daily"
	// TypeUncertifiedLogAlert warns drivers about uncertified logs.
	TypeUncertifiedLogAlert = "alerts:uncertified_log"
	// TypeUnidentifiedDrivingAlert raises the 8 day unassigned driving alert.
	TypeUnidentifiedDrivingAlert = "alerts:unidentified_driving"
	// TypeChatRetention purges chat messages older than one year (§15.4).
	TypeChatRetention = "chat:retention"
	// TypeSubscriptionExpiring warns administrators 14, 3 and 1 day ahead.
	TypeSubscriptionExpiring = "alerts:subscription_expiring"
)

// Cron expressions (UTC — the scheduler has no tenant, the fan out applies the
// company timezone).
const (
	// CronFanOutDailyAlerts fires on every full hour so each tenant can be
	// served at its own local hour.
	CronFanOutDailyAlerts = "0 * * * *"
	// CronSubscriptionExpiring runs once a day.
	CronSubscriptionExpiring = "0 8 * * *"
)

// Local hours (company timezone) the daily alerts run at.
const (
	// HourUncertifiedLog is the 20:00 Company TZ slot of TZ A§19.
	HourUncertifiedLog = 20
	// HourUnidentifiedDriving keeps the 8 day sweep off the evening peak.
	HourUnidentifiedDriving = 7
	// HourChatRetention runs the purge in the quiet hours.
	HourChatRetention = 3
)

// Retention and sweep windows.
const (
	// ChatRetention is the one year window of TZ §15.4.
	ChatRetention = 365 * 24 * time.Hour
	// UnidentifiedStaleDays is the 8 day threshold of Q57.
	UnidentifiedStaleDays = 8
	// maxAlertRows bounds one tenant sweep.
	maxAlertRows = 500
	// maxTenants bounds the fan out; a larger platform needs a cursor.
	maxTenants = 1000
)

// SubscriptionWarnDays are the lead times of the subscription alert.
var SubscriptionWarnDays = []int{14, 3, 1}

// Tenant is one company as the cron fan out sees it.
type Tenant struct {
	ID       uuid.UUID
	Timezone string
}

// Location resolves the company timezone, falling back to UTC when the stored
// name is unknown to the runtime.
func (t Tenant) Location() *time.Location {
	loc, err := time.LoadLocation(t.Timezone)
	if err != nil || loc == nil {
		return time.UTC
	}
	return loc
}

// ExpiringCompany is one subscription about to end.
type ExpiringCompany struct {
	ID     uuid.UUID
	Name   string
	EndsAt time.Time
	// AdminUserIDs are the Administrator role holders the alert is addressed to.
	AdminUserIDs []uuid.UUID
}

// UncertifiedDriver is one driver owing certifications.
type UncertifiedDriver struct {
	DriverID uuid.UUID
	UserID   uuid.UUID
	Logs     int64
	Oldest   time.Time
}

// TenantDirectory is the platform scoped read the cron fan out needs.
type TenantDirectory interface {
	Tenants(ctx context.Context) ([]Tenant, error)
	ExpiringOn(ctx context.Context, day time.Time) ([]ExpiringCompany, error)
}

// AlertSource resolves the per tenant payload of the daily alerts. Every method
// takes the tenant from the context, never from an argument.
type AlertSource interface {
	UncertifiedLogDrivers(ctx context.Context, before time.Time, limit int32) ([]UncertifiedDriver, error)
	StaleUnidentifiedCount(ctx context.Context, before time.Time) (int64, error)
	PurgeChat(ctx context.Context, before time.Time) (int64, error)
}

// Alerts is the notification surface: *notify.Dispatcher implements it.
type Alerts interface {
	Send(ctx context.Context, n notify.Notification) error
	Broadcast(ctx context.Context, ev notify.Event) error
}

// UnidentifiedSyncer raises the stored 8 day violations. internal/domain/logs
// implements it.
type UnidentifiedSyncer interface {
	SyncUnidentifiedViolations(ctx context.Context, companyID uuid.UUID) (int, error)
}

// AlertDeps are the dependencies of the alert and retention tasks.
type AlertDeps struct {
	Directory    TenantDirectory
	Source       AlertSource
	Alerts       Alerts
	Unidentified UnidentifiedSyncer
	Queue        Enqueuer
	Log          *slog.Logger
	Now          func() time.Time
}

// tenantPayload is the shared payload of the per tenant alert tasks.
type tenantPayload struct {
	CompanyID uuid.UUID `json:"company_id"`
	// LocalDate is the company local calendar day the task belongs to; it
	// makes the daily uniqueness key explicit.
	LocalDate string `json:"local_date"`
}

func newTenantTask(taskType string, companyID uuid.UUID, localDate string, queue string, ttl time.Duration) (*asynq.Task, error) {
	if companyID == uuid.Nil {
		return nil, fmt.Errorf("jobs: %s needs a company id", taskType)
	}
	payload, err := json.Marshal(tenantPayload{CompanyID: companyID, LocalDate: localDate})
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(taskType, payload,
		asynq.Queue(queue),
		asynq.MaxRetry(3),
		asynq.Timeout(5*time.Minute),
		// One run per tenant per local day: a duplicate hourly tick must not
		// send the alert twice.
		asynq.TaskID(taskType+":"+companyID.String()+":"+localDate),
		asynq.Retention(ttl),
	), nil
}

// NewUncertifiedLogAlertTask builds one tenant's uncertified log alert.
func NewUncertifiedLogAlertTask(companyID uuid.UUID, localDate string) (*asynq.Task, error) {
	return newTenantTask(TypeUncertifiedLogAlert, companyID, localDate, QueueDefault, 24*time.Hour)
}

// NewUnidentifiedDrivingAlertTask builds one tenant's 8 day sweep.
func NewUnidentifiedDrivingAlertTask(companyID uuid.UUID, localDate string) (*asynq.Task, error) {
	return newTenantTask(TypeUnidentifiedDrivingAlert, companyID, localDate, QueueDefault, 24*time.Hour)
}

// NewChatRetentionTask builds one tenant's chat purge.
func NewChatRetentionTask(companyID uuid.UUID, localDate string) (*asynq.Task, error) {
	return newTenantTask(TypeChatRetention, companyID, localDate, QueueLow, 24*time.Hour)
}

// NewFanOutDailyAlertsTask builds the hourly scheduler tick.
func NewFanOutDailyAlertsTask() *asynq.Task {
	return asynq.NewTask(TypeFanOutDailyAlerts, nil,
		asynq.Queue(QueueLow), asynq.MaxRetry(1), asynq.Timeout(time.Minute),
		asynq.Unique(time.Hour))
}

// NewSubscriptionExpiringTask builds the daily subscription sweep.
func NewSubscriptionExpiringTask() *asynq.Task {
	return asynq.NewTask(TypeSubscriptionExpiring, nil,
		asynq.Queue(QueueDefault), asynq.MaxRetry(2), asynq.Timeout(2*time.Minute),
		asynq.Unique(12*time.Hour))
}

// withDefaults fills the optional dependencies so a handler built directly
// (tests, custom wiring) never dereferences a nil logger or clock.
func (d AlertDeps) withDefaults() AlertDeps {
	if d.Log == nil {
		d.Log = slog.Default()
	}
	if d.Now == nil {
		d.Now = time.Now
	}
	return d
}

// RegisterAlerts wires the alert and retention tasks into the worker mux.
func RegisterAlerts(mux *asynq.ServeMux, deps AlertDeps) {
	deps = deps.withDefaults()
	if deps.Directory != nil && deps.Queue != nil {
		mux.Handle(TypeFanOutDailyAlerts, HandleFanOutDailyAlerts(deps))
	}
	if deps.Source != nil && deps.Alerts != nil {
		mux.Handle(TypeUncertifiedLogAlert, HandleUncertifiedLogAlert(deps))
		mux.Handle(TypeUnidentifiedDrivingAlert, HandleUnidentifiedDrivingAlert(deps))
	}
	if deps.Source != nil {
		mux.Handle(TypeChatRetention, HandleChatRetention(deps))
	}
	if deps.Directory != nil && deps.Alerts != nil {
		mux.Handle(TypeSubscriptionExpiring, HandleSubscriptionExpiring(deps))
	}
}

// ScheduleEntries lists the cron entries of this package so cmd/worker
// registers them without duplicating the expressions.
func ScheduleEntries() []ScheduleEntry {
	return []ScheduleEntry{
		{Cron: CronMarkStaleUnitsOffline, Task: NewFanOutStaleUnitsOfflineTask(), Queue: QueueLow},
		{Cron: CronFanOutDailyAlerts, Task: NewFanOutDailyAlertsTask(), Queue: QueueLow},
		{Cron: CronSubscriptionExpiring, Task: NewSubscriptionExpiringTask(), Queue: QueueDefault},
	}
}

// ScheduleEntry is one periodic registration.
type ScheduleEntry struct {
	Cron  string
	Task  *asynq.Task
	Queue string
}
