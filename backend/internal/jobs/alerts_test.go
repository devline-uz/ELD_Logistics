// Unit coverage of the alert and retention tasks: the hourly fan out maps UTC
// onto each tenant's local schedule, the uncertified log alert addresses the
// driver, the 8 day sweep runs the stage 4 violation writer, and the
// subscription alert fires 14, 3 and 1 day ahead.
package jobs_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/hibiken/asynq"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/jobs"
	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/tenant"
)

var (
	chicago  = uuid.MustParse("11111111-1111-4111-8111-111111111111")
	tashkent = uuid.MustParse("22222222-2222-4222-8222-222222222222")
	driverID = uuid.MustParse("33333333-3333-4333-8333-333333333333")
	userID   = uuid.MustParse("44444444-4444-4444-8444-444444444444")
	adminID  = uuid.MustParse("55555555-5555-4555-8555-555555555555")
)

// directory is an in memory jobs.TenantDirectory.
type directory struct {
	tenants  []jobs.Tenant
	expiring map[string][]jobs.ExpiringCompany
	asked    []string
}

func (d *directory) Tenants(context.Context) ([]jobs.Tenant, error) { return d.tenants, nil }

func (d *directory) ExpiringOn(_ context.Context, day time.Time) ([]jobs.ExpiringCompany, error) {
	key := day.Format("2006-01-02")
	d.asked = append(d.asked, key)
	return d.expiring[key], nil
}

// source is an in memory jobs.AlertSource.
type source struct {
	drivers   []jobs.UncertifiedDriver
	stale     int64
	purged    int64
	purgedFor []uuid.UUID
	before    time.Time
}

func (s *source) UncertifiedLogDrivers(_ context.Context, before time.Time, _ int32) ([]jobs.UncertifiedDriver, error) {
	s.before = before
	return s.drivers, nil
}

func (s *source) StaleUnidentifiedCount(_ context.Context, before time.Time) (int64, error) {
	s.before = before
	return s.stale, nil
}

func (s *source) PurgeChat(ctx context.Context, before time.Time) (int64, error) {
	s.before = before
	s.purgedFor = append(s.purgedFor, tenant.CompanyID(ctx))
	return s.purged, nil
}

// alerts records the dispatched notifications.
type alerts struct {
	sent       []notify.Notification
	broadcasts []notify.Event
}

func (a *alerts) Send(_ context.Context, n notify.Notification) error {
	a.sent = append(a.sent, n)
	return nil
}

func (a *alerts) Broadcast(_ context.Context, ev notify.Event) error {
	a.broadcasts = append(a.broadcasts, ev)
	return nil
}

// queue records the enqueued tasks.
type queue struct{ tasks []*asynq.Task }

func (q *queue) Enqueue(task *asynq.Task, _ ...asynq.Option) (*asynq.TaskInfo, error) {
	q.tasks = append(q.tasks, task)
	return &asynq.TaskInfo{}, nil
}

// syncer stands in for internal/domain/logs.
type syncer struct{ calls []uuid.UUID }

func (s *syncer) SyncUnidentifiedViolations(_ context.Context, companyID uuid.UUID) (int, error) {
	s.calls = append(s.calls, companyID)
	return 0, nil
}

func at(ts string) func() time.Time {
	parsed, err := time.Parse(time.RFC3339, ts)
	if err != nil {
		panic(err)
	}
	return func() time.Time { return parsed }
}

func types(tasks []*asynq.Task) []string {
	out := make([]string, 0, len(tasks))
	for _, t := range tasks {
		out = append(out, t.Type())
	}
	return out
}

// -------------------------------------------------------------------- fan out

func TestFanOutHonoursEachTenantLocalHour(t *testing.T) {
	t.Parallel()
	dir := &directory{tenants: []jobs.Tenant{
		{ID: chicago, Timezone: "America/Chicago"}, // UTC-5 in September
		{ID: tashkent, Timezone: "Asia/Tashkent"},  // UTC+5
	}}
	q := &queue{}
	// 01:00 UTC is 20:00 in Chicago (previous day) and 06:00 in Tashkent.
	h := jobs.HandleFanOutDailyAlerts(jobs.AlertDeps{
		Directory: dir, Queue: q, Now: at("2026-09-07T01:00:00Z"),
	})
	require.NoError(t, h.ProcessTask(context.Background(), jobs.NewFanOutDailyAlertsTask()))
	require.Equal(t, []string{jobs.TypeUncertifiedLogAlert}, types(q.tasks))

	// 02:00 UTC is 07:00 in Tashkent: the 8 day sweep of that tenant only.
	q = &queue{}
	h = jobs.HandleFanOutDailyAlerts(jobs.AlertDeps{
		Directory: dir, Queue: q, Now: at("2026-09-07T02:00:00Z"),
	})
	require.NoError(t, h.ProcessTask(context.Background(), jobs.NewFanOutDailyAlertsTask()))
	require.Equal(t, []string{jobs.TypeUnidentifiedDrivingAlert}, types(q.tasks))

	// 22:00 UTC is 03:00 in Tashkent: the chat retention purge.
	q = &queue{}
	h = jobs.HandleFanOutDailyAlerts(jobs.AlertDeps{
		Directory: dir, Queue: q, Now: at("2026-09-06T22:00:00Z"),
	})
	require.NoError(t, h.ProcessTask(context.Background(), jobs.NewFanOutDailyAlertsTask()))
	require.Equal(t, []string{jobs.TypeChatRetention}, types(q.tasks))

	// 05:00 UTC is 00:00 in Chicago and 10:00 in Tashkent: no tenant slot.
	q = &queue{}
	h = jobs.HandleFanOutDailyAlerts(jobs.AlertDeps{
		Directory: dir, Queue: q, Now: at("2026-09-06T05:00:00Z"),
	})
	require.NoError(t, h.ProcessTask(context.Background(), jobs.NewFanOutDailyAlertsTask()))
	require.Empty(t, q.tasks)
}

func TestScheduleEntriesCoverEveryCron(t *testing.T) {
	t.Parallel()
	entries := jobs.ScheduleEntries()
	require.Len(t, entries, 3)
	seen := map[string]string{}
	for _, e := range entries {
		require.NotEmpty(t, e.Cron)
		require.NotNil(t, e.Task)
		seen[e.Task.Type()] = e.Cron
	}
	// The daily alerts tick hourly so each tenant can be served locally.
	require.Equal(t, jobs.CronFanOutDailyAlerts, seen[jobs.TypeFanOutDailyAlerts])
	require.Equal(t, jobs.CronSubscriptionExpiring, seen[jobs.TypeSubscriptionExpiring])
}

// ------------------------------------------------------------------- handlers

func TestUncertifiedLogAlertAddressesTheDriver(t *testing.T) {
	t.Parallel()
	src := &source{drivers: []jobs.UncertifiedDriver{
		{DriverID: driverID, UserID: userID, Logs: 3},
	}}
	a := &alerts{}
	h := jobs.HandleUncertifiedLogAlert(jobs.AlertDeps{
		Source: src, Alerts: a, Now: at("2026-09-06T18:00:00Z"),
	})
	task, err := jobs.NewUncertifiedLogAlertTask(chicago, "2026-09-06")
	require.NoError(t, err)
	require.NoError(t, h.ProcessTask(context.Background(), task))

	require.Len(t, a.sent, 1)
	require.Equal(t, notify.AlertUncertifiedLog, a.sent[0].AlertType)
	require.Equal(t, userID, a.sent[0].UserID)
	require.Equal(t, chicago, a.sent[0].CompanyID)
	require.Contains(t, a.sent[0].Body, "3")
	// A log counts as uncertified after two days.
	require.Equal(t, "2026-09-04", src.before.Format("2006-01-02"))
}

func TestUnidentifiedAlertRunsTheViolationSync(t *testing.T) {
	t.Parallel()
	src := &source{stale: 4}
	a := &alerts{}
	sync := &syncer{}
	h := jobs.HandleUnidentifiedDrivingAlert(jobs.AlertDeps{
		Source: src, Alerts: a, Unidentified: sync, Now: at("2026-09-06T18:00:00Z"),
	})
	task, err := jobs.NewUnidentifiedDrivingAlertTask(chicago, "2026-09-06")
	require.NoError(t, err)
	require.NoError(t, h.ProcessTask(context.Background(), task))

	require.Equal(t, []uuid.UUID{chicago}, sync.calls)
	require.Len(t, a.broadcasts, 1)
	require.Equal(t, notify.AlertUnidentifiedDriving, a.broadcasts[0].AlertType)
	require.Contains(t, a.broadcasts[0].Body, "4")
	// Q57: the threshold is eight days.
	require.Equal(t, "2026-08-29", src.before.Format("2006-01-02"))
}

func TestUnidentifiedAlertStaysQuietWithoutStaleBlocks(t *testing.T) {
	t.Parallel()
	src := &source{stale: 0}
	a := &alerts{}
	h := jobs.HandleUnidentifiedDrivingAlert(jobs.AlertDeps{
		Source: src, Alerts: a, Now: at("2026-09-06T18:00:00Z"),
	})
	task, err := jobs.NewUnidentifiedDrivingAlertTask(chicago, "2026-09-06")
	require.NoError(t, err)
	require.NoError(t, h.ProcessTask(context.Background(), task))
	require.Empty(t, a.broadcasts)
}

func TestChatRetentionPurgesOneYear(t *testing.T) {
	t.Parallel()
	src := &source{purged: 12}
	h := jobs.HandleChatRetention(jobs.AlertDeps{Source: src, Now: at("2026-09-06T18:00:00Z")})
	task, err := jobs.NewChatRetentionTask(chicago, "2026-09-06")
	require.NoError(t, err)
	require.NoError(t, h.ProcessTask(context.Background(), task))

	require.Equal(t, []uuid.UUID{chicago}, src.purgedFor, "the purge runs inside the tenant context")
	require.Equal(t, "2025-09-06", src.before.Format("2006-01-02"))
}

func TestSubscriptionAlertFiresAtFourteenThreeAndOneDay(t *testing.T) {
	t.Parallel()
	ends := time.Date(2026, 9, 20, 0, 0, 0, 0, time.UTC)
	dir := &directory{expiring: map[string][]jobs.ExpiringCompany{
		"2026-09-20": {{ID: chicago, Name: "Acme Trucking", EndsAt: ends, AdminUserIDs: []uuid.UUID{adminID}}},
	}}
	a := &alerts{}
	h := jobs.HandleSubscriptionExpiring(jobs.AlertDeps{
		Directory: dir, Alerts: a, Now: at("2026-09-06T08:00:00Z"),
	})
	require.NoError(t, h.ProcessTask(context.Background(), jobs.NewSubscriptionExpiringTask()))

	require.Equal(t, []string{"2026-09-20", "2026-09-09", "2026-09-07"}, dir.asked)
	require.Len(t, a.broadcasts, 1)
	ev := a.broadcasts[0]
	require.Equal(t, notify.AlertSubscriptionExpires, ev.AlertType)
	require.Equal(t, []uuid.UUID{adminID}, ev.Users)
	require.Contains(t, ev.Title, "14")
	require.Contains(t, ev.Body, "Acme Trucking")
	require.Equal(t, []int{14, 3, 1}, jobs.SubscriptionWarnDays)
}

func TestMalformedPayloadIsNotRetried(t *testing.T) {
	t.Parallel()
	h := jobs.HandleChatRetention(jobs.AlertDeps{Source: &source{}, Now: time.Now})
	err := h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeChatRetention, []byte("{")))
	require.ErrorIs(t, err, asynq.SkipRetry)

	h = jobs.HandleChatRetention(jobs.AlertDeps{Source: &source{}, Now: time.Now})
	err = h.ProcessTask(context.Background(), asynq.NewTask(jobs.TypeChatRetention, []byte(`{}`)))
	require.ErrorIs(t, err, asynq.SkipRetry)
}

func TestTenantTasksRequireACompany(t *testing.T) {
	t.Parallel()
	_, err := jobs.NewUncertifiedLogAlertTask(uuid.Nil, "2026-09-06")
	require.Error(t, err)
	_, err = jobs.NewChatRetentionTask(uuid.Nil, "2026-09-06")
	require.Error(t, err)
}
