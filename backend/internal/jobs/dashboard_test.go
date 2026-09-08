// Unit coverage of the dashboard push task: payload round trip, tenant
// context propagation, the non retryable failures and the per tenant fan out.
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

type publisherFunc func(ctx context.Context) error

func (f publisherFunc) PublishSummary(ctx context.Context) error { return f(ctx) }

func TestNewDashboardSummaryPublishTask(t *testing.T) {
	companyID := uuid.New()
	task, err := jobs.NewDashboardSummaryPublishTask(companyID)
	require.NoError(t, err)
	require.Equal(t, jobs.TypeDashboardSummaryPublish, task.Type())

	var p jobs.DashboardSummaryPublishPayload
	require.NoError(t, json.Unmarshal(task.Payload(), &p))
	require.Equal(t, companyID, p.CompanyID)

	_, err = jobs.NewDashboardSummaryPublishTask(uuid.Nil)
	require.Error(t, err, "a task without a tenant must never be enqueued")
}

func TestHandleDashboardSummaryPublishCarriesTheTenant(t *testing.T) {
	companyID := uuid.New()
	var seen uuid.UUID

	h := jobs.HandleDashboardSummaryPublish(publisherFunc(func(ctx context.Context) error {
		seen = tenant.CompanyID(ctx)
		return nil
	}), nil)

	task, err := jobs.NewDashboardSummaryPublishTask(companyID)
	require.NoError(t, err)
	require.NoError(t, h.ProcessTask(context.Background(), task))
	require.Equal(t, companyID, seen, "the handler must scope the push to the payload tenant")
}

func TestHandleDashboardSummaryPublishRejectsBadPayload(t *testing.T) {
	h := jobs.HandleDashboardSummaryPublish(publisherFunc(func(context.Context) error {
		t.Fatal("service must not be called")
		return nil
	}), nil)

	err := h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeDashboardSummaryPublish, []byte("{")))
	require.ErrorIs(t, err, asynq.SkipRetry)

	payload, _ := json.Marshal(jobs.DashboardSummaryPublishPayload{})
	err = h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeDashboardSummaryPublish, payload))
	require.ErrorIs(t, err, asynq.SkipRetry)
}

func TestHandleDashboardSummaryPublishPropagatesFailure(t *testing.T) {
	boom := errors.New("boom")
	h := jobs.HandleDashboardSummaryPublish(publisherFunc(func(context.Context) error {
		return boom
	}), nil)

	task, err := jobs.NewDashboardSummaryPublishTask(uuid.New())
	require.NoError(t, err)
	require.ErrorIs(t, h.ProcessTask(context.Background(), task), boom)
}

func TestRegisterDashboardIsSafeWithoutDeps(t *testing.T) {
	require.NotPanics(t, func() {
		jobs.RegisterDashboard(asynq.NewServeMux(), nil, nil, nil, nil)
	})
}

func TestHandleFanOutDashboardSummaryPublishEnqueuesOneTaskPerTenant(t *testing.T) {
	first, second := uuid.New(), uuid.New()
	var enqueued []uuid.UUID

	h := jobs.HandleFanOutDashboardSummaryPublish(
		listerFunc(func(context.Context) ([]uuid.UUID, error) {
			return []uuid.UUID{first, second}, nil
		}),
		enqueuerFunc(func(task *asynq.Task, _ ...asynq.Option) (*asynq.TaskInfo, error) {
			require.Equal(t, jobs.TypeDashboardSummaryPublish, task.Type())
			var p jobs.DashboardSummaryPublishPayload
			require.NoError(t, json.Unmarshal(task.Payload(), &p))
			enqueued = append(enqueued, p.CompanyID)
			return nil, nil
		}), nil)

	require.NoError(t, h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeFanOutDashboardSummaryPublish, nil)))
	require.Equal(t, []uuid.UUID{first, second}, enqueued)
}

func TestHandleFanOutDashboardSummaryPublishFailsWhenNoTenantIsEnqueued(t *testing.T) {
	h := jobs.HandleFanOutDashboardSummaryPublish(
		listerFunc(func(context.Context) ([]uuid.UUID, error) {
			return []uuid.UUID{uuid.New()}, nil
		}),
		enqueuerFunc(func(*asynq.Task, ...asynq.Option) (*asynq.TaskInfo, error) {
			return nil, errors.New("redis is down")
		}), nil)

	require.Error(t, h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeFanOutDashboardSummaryPublish, nil)))
}
