package jobs

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"

	"github.com/devline/onebook-eld/internal/tenant"
)

// Task type names of the trip planner sweep. They are stable strings: renaming
// one strands the tasks already queued in Redis.
const (
	// TypeRoutesGeofenceSweep completes the routes whose unit has sat inside
	// the destination geofence for two minutes (Q66).
	TypeRoutesGeofenceSweep = "routes:geofence_sweep"
	// TypeFanOutRoutesGeofenceSweep is its scheduler entry point.
	TypeFanOutRoutesGeofenceSweep = "routes:fanout_geofence_sweep"
)

// CronRoutesGeofenceSweep runs the geofence sweep every minute. The dwell
// window is two minutes, so a one minute tick can never miss a completion by
// more than one tick.
const CronRoutesGeofenceSweep = "@every 1m"

// RoutesGeofenceSweepPayload is one tenant's geofence sweep.
type RoutesGeofenceSweepPayload struct {
	// CompanyID scopes the sweep; row level security refuses a cross-tenant
	// update even if this were wrong.
	CompanyID uuid.UUID `json:"company_id"`
}

// GeofenceSweeper is the routes service surface this handler needs. Depending
// on the interface keeps internal/jobs free of the domain package.
type GeofenceSweeper interface {
	SweepGeofences(ctx context.Context) (int, error)
}

// NewRoutesGeofenceSweepTask builds the sweep task of one tenant.
func NewRoutesGeofenceSweepTask(companyID uuid.UUID) (*asynq.Task, error) {
	if companyID == uuid.Nil {
		return nil, fmt.Errorf("jobs: %s needs a company id", TypeRoutesGeofenceSweep)
	}
	payload, err := json.Marshal(RoutesGeofenceSweepPayload{CompanyID: companyID})
	if err != nil {
		return nil, err
	}
	return asynq.NewTask(TypeRoutesGeofenceSweep, payload,
		asynq.Queue(QueueLow),
		asynq.MaxRetry(3),
		asynq.Timeout(2*time.Minute),
		// The completion is guarded by `status = 'ongoing'` in SQL, so a
		// duplicate run is harmless; the window only keeps the queue tidy.
		asynq.Unique(time.Minute),
	), nil
}

// NewFanOutRoutesGeofenceSweepTask builds the periodic fan out.
func NewFanOutRoutesGeofenceSweepTask() *asynq.Task {
	return asynq.NewTask(TypeFanOutRoutesGeofenceSweep, nil,
		asynq.Queue(QueueLow), asynq.MaxRetry(1), asynq.Timeout(time.Minute), asynq.Unique(time.Minute))
}

// HandleRoutesGeofenceSweep builds the Q66 completion handler.
func HandleRoutesGeofenceSweep(svc GeofenceSweeper, log *slog.Logger) asynq.Handler {
	if log == nil {
		log = slog.Default()
	}
	return asynq.HandlerFunc(func(ctx context.Context, t *asynq.Task) error {
		var p RoutesGeofenceSweepPayload
		if err := json.Unmarshal(t.Payload(), &p); err != nil {
			// A malformed payload will never parse; asynq must not retry it.
			return fmt.Errorf("%w: %w", asynq.SkipRetry, err)
		}
		if p.CompanyID == uuid.Nil {
			return fmt.Errorf("%w: missing company_id", asynq.SkipRetry)
		}
		ctx = tenant.WithCompanyID(ctx, p.CompanyID)

		n, err := svc.SweepGeofences(ctx)
		if err != nil {
			return err
		}
		if n > 0 {
			log.InfoContext(ctx, "routes: completed at the destination geofence",
				slog.String("company_id", p.CompanyID.String()), slog.Int("routes", n))
		}
		return nil
	})
}
