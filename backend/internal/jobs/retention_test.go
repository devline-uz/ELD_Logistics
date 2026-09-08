package jobs

import (
	"context"
	"encoding/json"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
)

var retentionNow = time.Date(2026, 9, 7, 4, 17, 0, 0, time.UTC)

// fakeRetention records the cutoffs the sweep asks for.
type fakeRetention struct {
	companySeen        uuid.UUID
	notificationCutoff time.Time
	sessionCutoff      time.Time
	exportCutoff       time.Time
	notifications      int64
	sessions           int64
	exports            []ExpiredExport
	notificationsErr   error
	exportsErr         error
}

func (f *fakeRetention) PurgeNotifications(ctx context.Context, before time.Time) (int64, error) {
	f.companySeen = tenant.CompanyID(ctx)
	f.notificationCutoff = before
	return f.notifications, f.notificationsErr
}

func (f *fakeRetention) PurgeSessions(_ context.Context, before time.Time) (int64, error) {
	f.sessionCutoff = before
	return f.sessions, nil
}

func (f *fakeRetention) ExpireReportExports(_ context.Context, before time.Time) ([]ExpiredExport, error) {
	f.exportCutoff = before
	return f.exports, f.exportsErr
}

type fakeRemover struct {
	keys []string
	err  error
}

func (f *fakeRemover) Remove(_ context.Context, keys ...string) error {
	f.keys = append(f.keys, keys...)
	return f.err
}

func runSweep(t testing.TB, deps RetentionDeps, companyID uuid.UUID) error {
	t.Helper()
	payload, err := json.Marshal(RetentionSweepPayload{CompanyID: companyID})
	require.NoError(t, err)
	deps.Now = func() time.Time { return retentionNow }
	return HandleRetentionSweep(deps).ProcessTask(context.Background(),
		asynq.NewTask(TypeRetentionSweep, payload))
}

// The sweep purges every non-Timescale table with the TZ B§15 windows.
func TestRetentionSweepCutoffs(t *testing.T) {
	companyID := uuid.New()
	src := &fakeRetention{
		notifications: 12, sessions: 3,
		exports: []ExpiredExport{
			{JobID: uuid.New(), FileKey: "exports/2026/09/logs.xlsx"},
			{JobID: uuid.New(), FileKey: ""},
		},
	}
	files := &fakeRemover{}

	require.NoError(t, runSweep(t, RetentionDeps{Source: src, Files: files}, companyID))

	// company_id always comes from the payload, never from a caller argument.
	require.Equal(t, companyID, src.companySeen)
	require.True(t, retentionNow.Add(-NotificationRetention).Equal(src.notificationCutoff),
		"notifications are kept for one year")
	require.True(t, retentionNow.Equal(src.sessionCutoff),
		"a session is purged once it is already expired")
	require.True(t, retentionNow.Equal(src.exportCutoff))
	// Only real object keys reach the storage backend.
	require.Equal(t, []string{"exports/2026/09/logs.xlsx"}, files.keys)

	require.Equal(t, 365*24*time.Hour, NotificationRetention)
	require.Equal(t, 24*time.Hour, ExportFileRetention)
	require.Equal(t, 90*24*time.Hour, TelemetryRawRetention)
}

// Without a file remover the rows are still cleared; only the blobs linger.
func TestRetentionSweepWithoutFileRemover(t *testing.T) {
	src := &fakeRetention{exports: []ExpiredExport{{JobID: uuid.New(), FileKey: "exports/a.pdf"}}}
	require.NoError(t, runSweep(t, RetentionDeps{Source: src}, uuid.New()))
}

// One failing table must not abort the others: partial progress beats none.
func TestRetentionSweepContinuesAfterOneFailure(t *testing.T) {
	src := &fakeRetention{notificationsErr: errors.New("boom"), sessions: 2}
	err := runSweep(t, RetentionDeps{Source: src}, uuid.New())
	require.Error(t, err)
	require.False(t, src.sessionCutoff.IsZero(), "the session purge must still have run")
	require.False(t, src.exportCutoff.IsZero(), "the export sweep must still have run")
}

// A malformed payload can never succeed, so asynq must not retry it.
func TestRetentionSweepRejectsBadPayload(t *testing.T) {
	deps := RetentionDeps{Source: &fakeRetention{}, Now: func() time.Time { return retentionNow }}
	handler := HandleRetentionSweep(deps)

	err := handler.ProcessTask(context.Background(), asynq.NewTask(TypeRetentionSweep, []byte("{")))
	require.ErrorIs(t, err, asynq.SkipRetry)

	payload, _ := json.Marshal(RetentionSweepPayload{})
	err = handler.ProcessTask(context.Background(), asynq.NewTask(TypeRetentionSweep, payload))
	require.ErrorIs(t, err, asynq.SkipRetry)
}

func TestNewRetentionSweepTask(t *testing.T) {
	_, err := NewRetentionSweepTask(uuid.Nil)
	require.Error(t, err, "a tenant sweep needs a company id")

	companyID := uuid.New()
	task, err := NewRetentionSweepTask(companyID)
	require.NoError(t, err)
	require.Equal(t, TypeRetentionSweep, task.Type())

	var p RetentionSweepPayload
	require.NoError(t, json.Unmarshal(task.Payload(), &p))
	require.Equal(t, companyID, p.CompanyID)

	entries := RetentionScheduleEntries()
	require.Len(t, entries, 1)
	require.Equal(t, CronRetentionSweep, entries[0].Cron)
	require.Equal(t, TypeFanOutRetentionSweep, entries[0].Task.Type())
	require.Equal(t, QueueLow, entries[0].Queue)
}

// The cron tick carries no tenant, so the fan out enqueues one sweep per
// active company.
func TestRetentionFanOut(t *testing.T) {
	ids := []uuid.UUID{uuid.New(), uuid.New()}
	queue := &recordingQueue{}
	mux := asynq.NewServeMux()
	RegisterRetention(mux, RetentionDeps{
		Source:    &fakeRetention{},
		Companies: companyListerFunc(func(context.Context) ([]uuid.UUID, error) { return ids, nil }),
		Queue:     queue,
	})

	require.NoError(t, mux.ProcessTask(context.Background(), NewFanOutRetentionSweepTask()))
	require.Len(t, queue.tasks, 2)
	for _, task := range queue.tasks {
		require.Equal(t, TypeRetentionSweep, task.Type())
	}
}

// A missing Timescale policy is an operational alarm, never a runtime fix.
func TestCheckTelemetryPolicy(t *testing.T) {
	require.NoError(t, CheckTelemetryPolicy(context.Background(), RetentionDeps{}))

	require.NoError(t, CheckTelemetryPolicy(context.Background(), RetentionDeps{
		Telemetry: telemetryCheckerFunc(func(context.Context) (bool, error) { return true, nil }),
	}))

	err := CheckTelemetryPolicy(context.Background(), RetentionDeps{
		Telemetry: telemetryCheckerFunc(func(context.Context) (bool, error) { return false, nil }),
	})
	require.Error(t, err)
}

type telemetryCheckerFunc func(context.Context) (bool, error)

func (f telemetryCheckerFunc) TelemetryRetentionPolicy(ctx context.Context) (bool, error) {
	return f(ctx)
}

type companyListerFunc func(context.Context) ([]uuid.UUID, error)

func (f companyListerFunc) ActiveCompanyIDs(ctx context.Context) ([]uuid.UUID, error) { return f(ctx) }

type recordingQueue struct {
	tasks []*asynq.Task
}

func (q *recordingQueue) Enqueue(task *asynq.Task, _ ...asynq.Option) (*asynq.TaskInfo, error) {
	q.tasks = append(q.tasks, task)
	return &asynq.TaskInfo{}, nil
}

// The retention sweep must be able to drive the real object storage adapter:
// jobs.FileRemover and storage.Remover are two views of the same contract, and
// a signature drift would silently leave every expired export in the bucket
// (TZ B§7.2).
func TestStorageRemoverSatisfiesTheSweepContract(t *testing.T) {
	var _ FileRemover = storage.NopRemover{}
	var _ FileRemover = (*storage.PresignRemover)(nil)

	fake := storage.NewFake()
	var files FileRemover = fake
	require.NoError(t, fake.PutObject(context.Background(),
		"c1/reports/2026/09/export.csv", []byte("body"), "text/csv"))

	src := &fakeRetention{exports: []ExpiredExport{
		{JobID: uuid.New(), FileKey: "c1/reports/2026/09/export.csv"},
	}}
	require.NoError(t, runSweep(t, RetentionDeps{Source: src, Files: files}, uuid.New()))

	_, ok := fake.Object("c1/reports/2026/09/export.csv")
	require.False(t, ok, "the sweep must delete the blob, not only the file_key")
	require.Equal(t, []string{"c1/reports/2026/09/export.csv"}, fake.Removed())
}
