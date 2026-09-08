// Unit coverage of the background task contract: payload round trip, tenant
// context propagation and the non retryable failures.
package jobs_test

import (
	"context"
	"encoding/json"
	"errors"
	"testing"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/jobs"
	"github.com/devline/onebook-eld/internal/tenant"
)

type markerFunc func(ctx context.Context, threshold int32) (int64, error)

func (f markerFunc) MarkStaleOffline(ctx context.Context, threshold int32) (int64, error) {
	return f(ctx, threshold)
}

func TestNewMarkStaleUnitsOfflineTask(t *testing.T) {
	companyID := uuid.New()
	task, err := jobs.NewMarkStaleUnitsOfflineTask(companyID, 5)
	require.NoError(t, err)
	require.Equal(t, jobs.TypeMarkStaleUnitsOffline, task.Type())

	var p jobs.MarkStaleUnitsOfflinePayload
	require.NoError(t, json.Unmarshal(task.Payload(), &p))
	require.Equal(t, companyID, p.CompanyID)
	require.EqualValues(t, 5, p.ThresholdMinutes)

	_, err = jobs.NewMarkStaleUnitsOfflineTask(uuid.Nil, 5)
	require.Error(t, err)
}

func TestHandleMarkStaleUnitsOfflineCarriesTheTenant(t *testing.T) {
	companyID := uuid.New()
	var seen uuid.UUID
	var threshold int32

	h := jobs.HandleMarkStaleUnitsOffline(markerFunc(func(ctx context.Context, th int32) (int64, error) {
		seen = tenant.CompanyID(ctx)
		threshold = th
		return 2, nil
	}), nil)

	task, err := jobs.NewMarkStaleUnitsOfflineTask(companyID, 7)
	require.NoError(t, err)
	require.NoError(t, h.ProcessTask(context.Background(), task))
	require.Equal(t, companyID, seen, "the handler must scope the sweep to the payload tenant")
	require.EqualValues(t, 7, threshold)
}

func TestHandleMarkStaleUnitsOfflineRejectsBadPayload(t *testing.T) {
	h := jobs.HandleMarkStaleUnitsOffline(markerFunc(func(context.Context, int32) (int64, error) {
		t.Fatal("service must not be called")
		return 0, nil
	}), nil)

	err := h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeMarkStaleUnitsOffline, []byte("{")))
	require.ErrorIs(t, err, asynq.SkipRetry)

	payload, _ := json.Marshal(jobs.MarkStaleUnitsOfflinePayload{})
	err = h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeMarkStaleUnitsOffline, payload))
	require.ErrorIs(t, err, asynq.SkipRetry)
}

func TestHandleMarkStaleUnitsOfflinePropagatesFailure(t *testing.T) {
	boom := errors.New("boom")
	h := jobs.HandleMarkStaleUnitsOffline(markerFunc(func(context.Context, int32) (int64, error) {
		return 0, boom
	}), nil)

	task, err := jobs.NewMarkStaleUnitsOfflineTask(uuid.New(), 5)
	require.NoError(t, err)
	require.ErrorIs(t, h.ProcessTask(context.Background(), task), boom)
}

func TestRegisterIsSafeWithoutDeps(t *testing.T) {
	require.NotPanics(t, func() { jobs.Register(asynq.NewServeMux(), jobs.Deps{}) })
}

type listerFunc func(ctx context.Context) ([]uuid.UUID, error)

func (f listerFunc) ActiveCompanyIDs(ctx context.Context) ([]uuid.UUID, error) { return f(ctx) }

type enqueuerFunc func(task *asynq.Task, opts ...asynq.Option) (*asynq.TaskInfo, error)

func (f enqueuerFunc) Enqueue(task *asynq.Task, opts ...asynq.Option) (*asynq.TaskInfo, error) {
	return f(task, opts...)
}

func TestHandleFanOutStaleUnitsOfflineEnqueuesOneTaskPerTenant(t *testing.T) {
	first, second := uuid.New(), uuid.New()
	var enqueued []uuid.UUID

	h := jobs.HandleFanOutStaleUnitsOffline(
		listerFunc(func(context.Context) ([]uuid.UUID, error) {
			return []uuid.UUID{first, second}, nil
		}),
		enqueuerFunc(func(task *asynq.Task, _ ...asynq.Option) (*asynq.TaskInfo, error) {
			require.Equal(t, jobs.TypeMarkStaleUnitsOffline, task.Type())
			var p jobs.MarkStaleUnitsOfflinePayload
			require.NoError(t, json.Unmarshal(task.Payload(), &p))
			enqueued = append(enqueued, p.CompanyID)
			return nil, nil
		}), nil)

	require.NoError(t, h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeFanOutStaleUnitsOffline, nil)))
	require.Equal(t, []uuid.UUID{first, second}, enqueued)
}

func TestHandleFanOutStaleUnitsOfflineFailsWhenNoTenantIsEnqueued(t *testing.T) {
	h := jobs.HandleFanOutStaleUnitsOffline(
		listerFunc(func(context.Context) ([]uuid.UUID, error) {
			return []uuid.UUID{uuid.New()}, nil
		}),
		enqueuerFunc(func(*asynq.Task, ...asynq.Option) (*asynq.TaskInfo, error) {
			return nil, errors.New("redis is down")
		}), nil)

	require.Error(t, h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeFanOutStaleUnitsOffline, nil)))
}
