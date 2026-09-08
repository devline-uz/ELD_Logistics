// Daily alert fan out: the hourly UTC tick expanded into per tenant tasks at
// each tenant's own local hour. Split out of alerts.go to keep each file under
// the 400 line ceiling of the Go conventions.
package jobs

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/hibiken/asynq"
)

// HandleFanOutDailyAlerts turns the hourly UTC tick into per tenant tasks at
// the tenant's own local hour. A tenant that fails to enqueue never blocks the
// others.
func HandleFanOutDailyAlerts(deps AlertDeps) asynq.Handler {
	deps = deps.withDefaults()
	return asynq.HandlerFunc(func(ctx context.Context, _ *asynq.Task) error {
		tenants, err := deps.Directory.Tenants(ctx)
		if err != nil {
			return err
		}
		if len(tenants) > maxTenants {
			// The fan out is a single pass with no cursor: past this size one
			// tick can no longer be trusted to reach every tenant inside its
			// local hour. Alert rather than silently drop the tail.
			deps.Log.ErrorContext(ctx, "alerts: daily fan out exceeds its bound",
				slog.Int("tenants", len(tenants)), slog.Int("max", maxTenants))
		}
		now := deps.Now().UTC()
		var failed int
		for _, t := range tenants {
			local := now.In(t.Location())
			day := local.Format("2006-01-02")
			var tasks []*asynq.Task
			switch local.Hour() {
			case HourUncertifiedLog:
				if task, err := NewUncertifiedLogAlertTask(t.ID, day); err == nil {
					tasks = append(tasks, task)
				}
			case HourUnidentifiedDriving:
				if task, err := NewUnidentifiedDrivingAlertTask(t.ID, day); err == nil {
					tasks = append(tasks, task)
				}
			case HourChatRetention:
				if task, err := NewChatRetentionTask(t.ID, day); err == nil {
					tasks = append(tasks, task)
				}
			}
			for _, task := range tasks {
				if _, err := deps.Queue.Enqueue(task); err != nil && !isDuplicate(err) {
					failed++
					deps.Log.ErrorContext(ctx, "alerts: task not enqueued",
						slog.String("type", task.Type()),
						slog.String("company_id", t.ID.String()),
						slog.String("error", err.Error()))
				}
			}
		}
		if failed > 0 && failed == len(tenants) {
			return fmt.Errorf("jobs: no tenant alert could be enqueued (%d tenants)", failed)
		}
		return nil
	})
}

// isDuplicate reports whether asynq refused a task that already exists. The
// daily task id makes a second hourly tick a no-op, not a failure.
func isDuplicate(err error) bool {
	return err != nil && (asynq.ErrTaskIDConflict.Error() == err.Error() ||
		asynq.ErrDuplicateTask.Error() == err.Error())
}
