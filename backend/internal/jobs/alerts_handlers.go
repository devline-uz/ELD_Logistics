// Per tenant alert handlers (TZ A§19): uncertified logs, unidentified driving,
// chat retention and the subscription expiry warnings.
package jobs

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"strconv"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"

	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/tenant"
)

// HandleUncertifiedLogAlert warns each driver that still owes certifications
// (TZ A§19 — once a day, 20:00 Company TZ).
func HandleUncertifiedLogAlert(deps AlertDeps) asynq.Handler {
	deps = deps.withDefaults()
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		p, err := decodeTenant(t)
		if err != nil {
			return err
		}
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)
		// A log is uncertified once it is two days old; the same rule the
		// dashboard card uses.
		before := deps.Now().UTC().AddDate(0, 0, -2)
		rows, err := deps.Source.UncertifiedLogDrivers(ctx, before, maxAlertRows)
		if err != nil {
			return err
		}
		for _, row := range rows {
			driverID := row.DriverID
			body := "You have " + strconv.FormatInt(row.Logs, 10) + " uncertified daily log(s)."
			if err := deps.Alerts.Send(ctx, notify.Notification{
				CompanyID: p.CompanyID, UserID: row.UserID,
				AlertType:  notify.AlertUncertifiedLog,
				Title:      "Certify your logs",
				Body:       body,
				EntityType: "drivers", EntityID: &driverID,
				Data: map[string]string{"logs": strconv.FormatInt(row.Logs, 10)},
			}); err != nil {
				deps.Log.WarnContext(ctx, "alerts: uncertified log alert failed",
					slog.String("company_id", p.CompanyID.String()),
					slog.String("error", err.Error()))
			}
		}
		return nil
	})
}

// HandleUnidentifiedDrivingAlert raises the stored 8 day violations and alerts
// the administrators (Q57).
func HandleUnidentifiedDrivingAlert(deps AlertDeps) asynq.Handler {
	deps = deps.withDefaults()
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		p, err := decodeTenant(t)
		if err != nil {
			return err
		}
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)
		before := deps.Now().UTC().AddDate(0, 0, -UnidentifiedStaleDays)

		if deps.Unidentified != nil {
			// Stage 4 left the violation writer ready but unscheduled; this is
			// where it runs.
			if _, err := deps.Unidentified.SyncUnidentifiedViolations(ctx, p.CompanyID); err != nil {
				return err
			}
		}
		n, err := deps.Source.StaleUnidentifiedCount(ctx, before)
		if err != nil {
			return err
		}
		if n == 0 {
			return nil
		}
		return deps.Alerts.Broadcast(ctx, notify.Event{
			CompanyID: p.CompanyID,
			AlertType: notify.AlertUnidentifiedDriving,
			Title:     "Unassigned driving needs review",
			Body: strconv.FormatInt(n, 10) +
				" driving block(s) have been unassigned for more than 8 days.",
			EntityType: "unidentified_events",
			Data:       map[string]string{"count": strconv.FormatInt(n, 10)},
		})
	})
}

// HandleChatRetention purges chat messages older than one year (§15.4).
func HandleChatRetention(deps AlertDeps) asynq.Handler {
	deps = deps.withDefaults()
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		p, err := decodeTenant(t)
		if err != nil {
			return err
		}
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)
		n, err := deps.Source.PurgeChat(ctx, deps.Now().UTC().Add(-ChatRetention))
		if err != nil {
			return err
		}
		if n > 0 {
			deps.Log.InfoContext(ctx, "chat: retention purge",
				slog.String("company_id", p.CompanyID.String()), slog.Int64("messages", n))
		}
		return nil
	})
}

// HandleSubscriptionExpiring warns the administrators 14, 3 and 1 day before
// the subscription ends (TZ A§19 — email).
func HandleSubscriptionExpiring(deps AlertDeps) asynq.Handler {
	deps = deps.withDefaults()
	return asynq.HandlerFunc(func(ctx context.Context, _ *asynq.Task) error {
		now := deps.Now().UTC()
		var last error
		for _, days := range SubscriptionWarnDays {
			day := now.AddDate(0, 0, days)
			companies, err := deps.Directory.ExpiringOn(ctx, day)
			if err != nil {
				return err
			}
			for _, c := range companies {
				tenantCtx := tenant.WithCompanyID(ctx, c.ID)
				id := c.ID
				if err := deps.Alerts.Broadcast(tenantCtx, notify.Event{
					CompanyID:  c.ID,
					AlertType:  notify.AlertSubscriptionExpires,
					Title:      "Subscription expires in " + strconv.Itoa(days) + " day(s)",
					Body:       "The ONEBOOK ELD subscription of " + c.Name + " ends on " + c.EndsAt.Format("2006-01-02") + ".",
					EntityType: "companies", EntityID: &id,
					Users: c.AdminUserIDs,
					Data:  map[string]string{"days_left": strconv.Itoa(days)},
				}); err != nil {
					last = err
					deps.Log.WarnContext(ctx, "alerts: subscription alert failed",
						slog.String("company_id", c.ID.String()), slog.String("error", err.Error()))
				}
			}
		}
		return last
	})
}

func decodeTenant(t *asynq.Task) (tenantPayload, error) {
	var p tenantPayload
	if err := json.Unmarshal(t.Payload(), &p); err != nil {
		// A malformed payload will never parse; asynq must not retry it.
		return p, fmt.Errorf("%w: %w", asynq.SkipRetry, err)
	}
	if p.CompanyID == uuid.Nil {
		return p, fmt.Errorf("%w: missing company_id", asynq.SkipRetry)
	}
	return p, nil
}
