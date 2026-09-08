//go:build integration

// Integration coverage of the notification centre: the personal inbox and its
// filters, the read endpoints, the push token registry (including the handed
// over device rule) and the dispatcher on top of real storage.
package notifications_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/notifications"
	"github.com/devline/onebook-eld/internal/domain/notifications/dto"
	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

func newServer(t testing.TB) (*testutil.TestServer, *notifications.PgRepo) {
	t.Helper()
	pool := testutil.NewDB(t)
	repo := notifications.NewRepo(pool, nil)
	return testutil.NewServer(t, notifications.New(notifications.Deps{
		Repo:     repo,
		Verifier: testutil.ContextVerifier(),
	})), repo
}

func seedNotification(t *testing.T, tn *testutil.Tenant, userID uuid.UUID, alertType string, read bool) uuid.UUID {
	t.Helper()
	var id uuid.UUID
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t), `
		INSERT INTO notifications (company_id, user_id, alert_type, title, body, channels, sent_at, read_at)
		VALUES ($1,$2,$3,'Alert','body',ARRAY['push','in_app'], now(), CASE WHEN $4 THEN now() ELSE NULL END)
		RETURNING id`, tn.ID(), userID, alertType, read).Scan(&id)
	require.NoError(t, err)
	return id
}

func decodeList(t *testing.T, resp *testutil.Response) ([]dto.Notification, dto.ListMeta) {
	t.Helper()
	var body struct {
		Data []dto.Notification `json:"data"`
		Meta dto.ListMeta       `json:"meta"`
	}
	resp.JSON(&body)
	return body.Data, body.Meta
}

// ---------------------------------------------------------------------- inbox

func TestInboxIsPersonalAndFiltered(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, core.PermNotificationsRead)

	seedNotification(t, tn, tn.User.ID, notify.AlertHOSViolation, false)
	seedNotification(t, tn, tn.User.ID, notify.AlertChatMessage, true)
	// Another user's notification must never appear.
	seedNotification(t, tn, tn.Driver.UserID, notify.AlertHOSWarning, false)

	c := srv.AsTenant(tn)
	items, meta := decodeList(t, c.Get("/api/v1/notifications"))
	require.Len(t, items, 2)
	require.EqualValues(t, 2, meta.Total)
	require.EqualValues(t, 1, meta.Unread)

	unread, _ := decodeList(t, c.Get("/api/v1/notifications", testutil.Query("read", "false")))
	require.Len(t, unread, 1)
	require.Equal(t, notify.AlertHOSViolation, unread[0].AlertType)
	require.False(t, unread[0].Read)

	read, _ := decodeList(t, c.Get("/api/v1/notifications", testutil.Query("read", "true")))
	require.Len(t, read, 1)
	require.True(t, read[0].Read)
	require.NotNil(t, read[0].ReadAt)

	byType, _ := decodeList(t, c.Get("/api/v1/notifications",
		testutil.Query("alert_type", notify.AlertChatMessage)))
	require.Len(t, byType, 1)

	testutil.RequireStatusCode(t,
		c.Get("/api/v1/notifications", testutil.Query("alert_type", "made_up")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
	testutil.RequireStatusCode(t,
		c.Get("/api/v1/notifications", testutil.Query("read", "maybe")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestMarkReadIsIdempotentAndScoped(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, core.PermNotificationsRead)
	mine := seedNotification(t, tn, tn.User.ID, notify.AlertHOSWarning, false)
	foreign := seedNotification(t, tn, tn.Driver.UserID, notify.AlertHOSWarning, false)

	c := srv.AsTenant(tn)
	resp := c.Patch("/api/v1/notifications/"+mine.String()+"/read", nil)
	testutil.RequireStatus(t, resp, http.StatusOK)
	var body struct {
		Data dto.ReadResult `json:"data"`
	}
	resp.JSON(&body)
	require.EqualValues(t, 1, body.Data.Updated)
	require.EqualValues(t, 0, body.Data.Unread)

	// A second call changes nothing.
	resp = c.Patch("/api/v1/notifications/"+mine.String()+"/read", nil)
	testutil.RequireStatus(t, resp, http.StatusOK)
	resp.JSON(&body)
	require.EqualValues(t, 0, body.Data.Updated)

	// Another user's notification is not touched.
	resp = c.Patch("/api/v1/notifications/"+foreign.String()+"/read", nil)
	testutil.RequireStatus(t, resp, http.StatusOK)
	resp.JSON(&body)
	require.EqualValues(t, 0, body.Data.Updated)

	testutil.RequireStatusCode(t, c.Patch("/api/v1/notifications/not-a-uuid/read", nil),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestReadAllClearsOnlyTheCallersInbox(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, core.PermNotificationsRead)
	for i := 0; i < 3; i++ {
		seedNotification(t, tn, tn.User.ID, notify.AlertHOSWarning, false)
	}
	seedNotification(t, tn, tn.Driver.UserID, notify.AlertHOSWarning, false)

	resp := srv.AsTenant(tn).Post("/api/v1/notifications/read-all", nil)
	testutil.RequireStatus(t, resp, http.StatusOK)
	var body struct {
		Data dto.ReadResult `json:"data"`
	}
	resp.JSON(&body)
	require.EqualValues(t, 3, body.Data.Updated)
	require.EqualValues(t, 0, body.Data.Unread)

	// The driver's own inbox is untouched.
	driver := srv.AsPrincipal(tn.DriverPrincipal(core.PermNotificationsRead))
	_, meta := decodeList(t, driver.Get("/api/v1/notifications"))
	require.EqualValues(t, 1, meta.Unread)
}

func TestCrossTenantNotificationIsInvisible(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, core.PermNotificationsRead)
	foreign := seedNotification(t, b, b.User.ID, notify.AlertHOSWarning, false)

	c := srv.AsTenant(a)
	items, _ := decodeList(t, c.Get("/api/v1/notifications"))
	require.Empty(t, items)

	resp := c.Patch("/api/v1/notifications/"+foreign.String()+"/read", nil)
	testutil.RequireStatus(t, resp, http.StatusOK)
	var body struct {
		Data dto.ReadResult `json:"data"`
	}
	resp.JSON(&body)
	require.EqualValues(t, 0, body.Data.Updated, "another tenant's row must not be updated")
}

// -------------------------------------------------------------- push tokens

func TestPushTokenRegistrationIsIdempotentPerDevice(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, core.PermNotificationsRead)
	c := srv.AsTenant(tn)

	resp := c.Post("/api/v1/devices/push-token", map[string]any{
		"device_id": "device-1", "platform": "android", "token": "tok-1", "app_version": "1.4.2",
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)
	// The token is a credential: it never comes back.
	require.NotContains(t, resp.String(), "tok-1")

	// The same device refreshes instead of duplicating.
	testutil.RequireStatus(t, c.Post("/api/v1/devices/push-token", map[string]any{
		"device_id": "device-1", "platform": "android", "token": "tok-2",
	}), http.StatusCreated)

	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM device_push_tokens WHERE user_id = $1 AND deleted_at IS NULL`,
		tn.User.ID).Scan(&n))
	require.Equal(t, 1, n)

	testutil.RequireStatusCode(t, c.Post("/api/v1/devices/push-token", map[string]any{
		"device_id": "device-1", "platform": "blackberry", "token": "tok-3",
	}), http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestHandedOverDeviceStopsNotifyingThePreviousOwner(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, core.PermNotificationsRead)
	// The token is unique per run: the revoke runs inside the tenant, so it
	// can only retire registrations of the same company (RLS).
	token := uuid.NewString()

	testutil.RequireStatus(t, srv.AsTenant(tn).Post("/api/v1/devices/push-token", map[string]any{
		"device_id": "shared", "platform": "ios", "token": token,
	}), http.StatusCreated)

	driver := srv.AsPrincipal(tn.DriverPrincipal(core.PermNotificationsRead))
	testutil.RequireStatus(t, driver.Post("/api/v1/devices/push-token", map[string]any{
		"device_id": "shared-2", "platform": "ios", "token": token,
	}), http.StatusCreated)

	var owner uuid.UUID
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT user_id FROM device_push_tokens
		 WHERE company_id = $1 AND token = $2 AND deleted_at IS NULL`,
		tn.ID(), token).Scan(&owner))
	require.Equal(t, tn.Driver.UserID, owner, "only the new owner keeps the token")
}

// -------------------------------------------------------------- dispatcher

func TestDispatcherWritesTheInboxAndResolvesDevices(t *testing.T) {
	t.Parallel()
	srv, repo := newServer(t)
	tn := testutil.SeedTenant(t, core.PermNotificationsRead)

	testutil.RequireStatus(t, srv.AsTenant(tn).Post("/api/v1/devices/push-token", map[string]any{
		"device_id": "d1", "platform": "android", "token": "tok-x",
	}), http.StatusCreated)

	push := &countingSender{channel: notify.ChannelPush}
	disp := notify.NewDispatcher(notify.Deps{
		Store:   repo,
		Senders: notify.NewSenders(nil, push),
		Now:     func() time.Time { return time.Date(2026, 9, 6, 18, 0, 0, 0, time.UTC) },
	})

	ctx := tenant.WithCompanyID(testutil.Ctx(t), tn.ID())
	require.NoError(t, disp.Send(ctx, notify.Notification{
		CompanyID: tn.ID(), UserID: tn.User.ID,
		AlertType: notify.AlertHOSViolation, Title: "11-hour limit exceeded",
	}))

	require.Len(t, push.to, 1)
	require.Len(t, push.to[0].Devices, 1)
	require.Equal(t, "tok-x", push.to[0].Devices[0].Token)

	items, meta := decodeList(t, srv.AsTenant(tn).Get("/api/v1/notifications"))
	require.Len(t, items, 1)
	require.EqualValues(t, 1, meta.Unread)
	require.Equal(t, notify.AlertHOSViolation, items[0].AlertType)
	require.Contains(t, items[0].Channels, notify.ChannelInApp)
	require.Contains(t, items[0].Channels, notify.ChannelPush)
}

func TestDispatcherBroadcastsToARole(t *testing.T) {
	t.Parallel()
	srv, repo := newServer(t)
	tn := testutil.SeedTenant(t, core.PermNotificationsRead)

	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t), `
		INSERT INTO notification_settings (company_id, alert_type, channels, recipient_roles, enabled)
		VALUES ($1, $2, ARRAY['push'], ARRAY[$3::uuid], true)`,
		tn.ID(), notify.AlertUnidentifiedDriving, tn.Role.ID)
	require.NoError(t, err)

	disp := notify.NewDispatcher(notify.Deps{Store: repo, Senders: notify.NewSenders(nil)})
	ctx := tenant.WithCompanyID(testutil.Ctx(t), tn.ID())
	require.NoError(t, disp.Broadcast(ctx, notify.Event{
		CompanyID: tn.ID(), AlertType: notify.AlertUnidentifiedDriving,
		Title: "Unassigned driving needs review",
	}))

	// Both the admin user and the driver user hold the tenant role.
	_, meta := decodeList(t, srv.AsTenant(tn).Get("/api/v1/notifications"))
	require.EqualValues(t, 1, meta.Unread)
	driver := srv.AsPrincipal(tn.DriverPrincipal(core.PermNotificationsRead))
	_, driverMeta := decodeList(t, driver.Get("/api/v1/notifications"))
	require.EqualValues(t, 1, driverMeta.Unread)
}

// countingSender records the recipients it was handed.
type countingSender struct {
	channel string
	to      []notify.Recipient
}

func (s *countingSender) Channel() string { return s.channel }
func (s *countingSender) Send(_ context.Context, to notify.Recipient, _ notify.Notification) error {
	s.to = append(s.to, to)
	return nil
}
