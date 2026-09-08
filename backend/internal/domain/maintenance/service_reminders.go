package maintenance

import (
	"context"
	"log/slog"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/maintenance/dto"
)

// ---------------------------------------------------------------- reminders

// SendReminders is the Q37/Q38 sweep driven by internal/jobs. A schedule unit
// whose remaining value reached `reminder_before_value` is announced once; the
// `reminder_sent_at` stamp is the guard, so a second run is a no-op. Rows past
// their due point are also flipped to `due`.
func (s *Service) SendReminders(ctx context.Context) (int, error) {
	rows, err := s.repo.ListForReminder(ctx, reminderBatchLimit)
	if err != nil {
		return 0, db.MapError(err, "maintenance schedule")
	}
	now := s.now().UTC()
	var sent int
	for _, raw := range rows {
		r := rowFromReminder(raw)
		view := scheduleUnitFrom(r, now)
		if !view.ReminderDue {
			continue
		}
		if view.Overdue || view.ReminderDue {
			if _, err := s.repo.MarkDue(ctx, r.ID); err != nil {
				s.log.ErrorContext(ctx, "maintenance: could not flag due",
					slog.String("schedule_unit_id", r.ID.String()), slog.String("error", err.Error()))
			}
		}
		// Claim the reminder first: only the winner of the guarded update
		// notifies, so a concurrent worker never doubles the message (Q37).
		n, err := s.repo.MarkReminderSent(ctx, r.ID)
		if err != nil {
			s.log.ErrorContext(ctx, "maintenance: could not claim reminder",
				slog.String("schedule_unit_id", r.ID.String()), slog.String("error", err.Error()))
			continue
		}
		if n == 0 {
			continue
		}
		s.notifyReminder(ctx, r, view)
		sent++
	}
	return sent, nil
}

func (s *Service) notifyReminder(ctx context.Context, r unitRow, view dto.ScheduleUnit) {
	recipients := s.recipients(ctx, r)
	kind := ReminderDue
	msg := "maintenance due soon"
	if view.Overdue {
		kind = ReminderOverdue
		msg = "maintenance overdue"
	}
	rem := Reminder{
		CompanyID:       r.CompanyID,
		ScheduleID:      r.ScheduleID,
		ScheduleUnitID:  r.ID,
		ScheduleName:    r.ScheduleName,
		UnitID:          r.UnitID,
		UnitNumber:      r.UnitNumber,
		AlertType:       r.AlertType,
		DeliveryMethods: r.DeliveryMethods,
		Recipients:      recipients,
		Remaining:       view.Remaining,
		Unit:            r.IntervalUnit,
		Message:         msg,
	}
	if err := s.alerter.Alert(ctx, kind, rem); err != nil {
		s.log.ErrorContext(ctx, "maintenance: reminder not delivered",
			slog.String("schedule_unit_id", r.ID.String()), slog.String("error", err.Error()))
	}
}

// recipients resolves the drivers to notify. Q38: the co-driver is included
// only when the schedule asks for it.
func (s *Service) recipients(ctx context.Context, r unitRow) []uuid.UUID {
	rows, err := s.repo.UnitDrivers(ctx, r.UnitID)
	if err != nil {
		return nil
	}
	out := make([]uuid.UUID, 0, len(rows))
	for _, d := range rows {
		if d.Role == "co" && !r.NotifyCoDriver {
			continue
		}
		out = append(out, d.UserID)
	}
	return out
}
