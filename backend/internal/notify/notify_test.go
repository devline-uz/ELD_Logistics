// Unit coverage of the dispatcher: channel resolution from
// notification_settings, the TZ A§19 defaults, the rule that hos_* and eld_*
// push cannot be switched off, recipient expansion and the WebSocket fan-out.
package notify_test

import (
	"context"
	"errors"
	"sort"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/ws"
)

var (
	companyID = uuid.MustParse("11111111-1111-4111-8111-111111111111")
	driverID  = uuid.MustParse("22222222-2222-4222-8222-222222222222")
	adminID   = uuid.MustParse("33333333-3333-4333-8333-333333333333")
	roleID    = uuid.MustParse("44444444-4444-4444-8444-444444444444")
)

// store is an in memory notify.Store.
type store struct {
	settings map[string]notify.Setting
	users    map[uuid.UUID]notify.Recipient
	byRole   map[uuid.UUID][]uuid.UUID
	records  []notify.Record
	failNext error
}

func newStore() *store {
	return &store{
		settings: map[string]notify.Setting{},
		users: map[uuid.UUID]notify.Recipient{
			driverID: {UserID: driverID, Email: "driver@example.test", Phone: "+15550100",
				Devices: []notify.Device{{Platform: notify.PlatformAndroid, Token: "tok-a", DeviceID: "d1"}}},
			adminID: {UserID: adminID, Email: "admin@example.test"},
		},
		byRole: map[uuid.UUID][]uuid.UUID{roleID: {adminID}},
	}
}

func (s *store) Setting(_ context.Context, _ uuid.UUID, alertType string) (notify.Setting, error) {
	if s.failNext != nil {
		err := s.failNext
		s.failNext = nil
		return notify.Setting{}, err
	}
	return s.settings[alertType], nil
}

func (s *store) RecipientsByRoles(_ context.Context, _ uuid.UUID, roleIDs []uuid.UUID) ([]notify.Recipient, error) {
	out := []notify.Recipient{}
	for _, r := range roleIDs {
		for _, u := range s.byRole[r] {
			out = append(out, s.users[u])
		}
	}
	return out, nil
}

func (s *store) Recipients(_ context.Context, _ uuid.UUID, userIDs []uuid.UUID) ([]notify.Recipient, error) {
	out := []notify.Recipient{}
	for _, id := range userIDs {
		if u, ok := s.users[id]; ok {
			out = append(out, u)
		}
	}
	return out, nil
}

func (s *store) Insert(_ context.Context, rec notify.Record) (uuid.UUID, error) {
	s.records = append(s.records, rec)
	return uuid.New(), nil
}

// recorder is a Sender that remembers what it was asked to deliver.
type recorder struct {
	channel string
	sent    []notify.Notification
	to      []notify.Recipient
	err     error
}

func (r *recorder) Channel() string { return r.channel }
func (r *recorder) Send(_ context.Context, to notify.Recipient, n notify.Notification) error {
	r.sent = append(r.sent, n)
	r.to = append(r.to, to)
	return r.err
}

// capture is a ws.Publisher that keeps every message.
type capture struct{ msgs []ws.Message }

func (c *capture) Publish(_ context.Context, m ws.Message) error {
	c.msgs = append(c.msgs, m)
	return nil
}

type fixture struct {
	store *store
	push  *recorder
	email *recorder
	sms   *recorder
	pub   *capture
	disp  *notify.Dispatcher
}

func newFixture(t *testing.T) *fixture {
	t.Helper()
	f := &fixture{
		store: newStore(),
		push:  &recorder{channel: notify.ChannelPush},
		email: &recorder{channel: notify.ChannelEmail},
		sms:   &recorder{channel: notify.ChannelSMS},
		pub:   &capture{},
	}
	f.disp = notify.NewDispatcher(notify.Deps{
		Store:     f.store,
		Senders:   notify.NewSenders(nil, f.push, f.email, f.sms),
		Publisher: f.pub,
		Now:       func() time.Time { return time.Date(2026, 9, 6, 18, 5, 0, 0, time.UTC) },
	})
	return f
}

// ------------------------------------------------------------------- defaults

func TestDefaultChannelsFollowTheAlertTable(t *testing.T) {
	t.Parallel()
	// TZ A§19: hos_violation is Push+Email, dvir_critical adds SMS,
	// subscription_expiring is Email only.
	require.Equal(t, []string{notify.ChannelPush, notify.ChannelEmail},
		notify.DefaultChannels(notify.AlertHOSViolation))
	require.Equal(t, []string{notify.ChannelPush, notify.ChannelEmail, notify.ChannelSMS},
		notify.DefaultChannels(notify.AlertDVIRCritical))
	require.Equal(t, []string{notify.ChannelEmail},
		notify.DefaultChannels(notify.AlertSubscriptionExpires))
}

func TestResolveChannelsAlwaysAddsTheInbox(t *testing.T) {
	t.Parallel()
	got := notify.ResolveChannels(notify.AlertRouteAssigned, []string{notify.ChannelEmail})
	require.Equal(t, []string{notify.ChannelEmail, notify.ChannelInApp}, got)

	// Unknown channel names are dropped rather than stored.
	got = notify.ResolveChannels(notify.AlertRouteAssigned, []string{"carrier-pigeon"})
	require.Equal(t, []string{notify.ChannelInApp}, got)
}

func TestSafetyAlertsAlwaysKeepPush(t *testing.T) {
	t.Parallel()
	// Q89: a user may mute anything except the hos_* and eld_* families.
	for _, alert := range []string{
		notify.AlertHOSWarning, notify.AlertHOSViolation,
		notify.AlertELDDisconnected, notify.AlertELDMalfunction,
	} {
		require.True(t, notify.IsMandatoryPush(alert), alert)
		require.Contains(t, notify.ResolveChannels(alert, []string{notify.ChannelEmail}),
			notify.ChannelPush, alert)
	}
	require.False(t, notify.IsMandatoryPush(notify.AlertChatMessage))
	require.NotContains(t, notify.ResolveChannels(notify.AlertChatMessage, []string{notify.ChannelEmail}),
		notify.ChannelPush)
}

// ------------------------------------------------------------------- delivery

func TestSendUsesTheCompanySettings(t *testing.T) {
	t.Parallel()
	f := newFixture(t)
	f.store.settings[notify.AlertRouteAssigned] = notify.Setting{
		Channels: []string{notify.ChannelEmail, notify.ChannelSMS}, Enabled: true, Found: true,
	}

	require.NoError(t, f.disp.Send(context.Background(), notify.Notification{
		CompanyID: companyID, UserID: driverID,
		AlertType: notify.AlertRouteAssigned, Title: "Route assigned",
	}))

	require.Len(t, f.store.records, 1)
	require.Equal(t, []string{notify.ChannelEmail, notify.ChannelSMS, notify.ChannelInApp},
		f.store.records[0].Channels)
	require.Len(t, f.email.sent, 1)
	require.Len(t, f.sms.sent, 1)
	require.Empty(t, f.push.sent, "push is not configured for this alert")
}

func TestDisabledAlertIsNotSent(t *testing.T) {
	t.Parallel()
	f := newFixture(t)
	f.store.settings[notify.AlertRouteCompleted] = notify.Setting{
		Channels: []string{notify.ChannelPush}, Enabled: false, Found: true,
	}

	require.NoError(t, f.disp.Send(context.Background(), notify.Notification{
		CompanyID: companyID, UserID: driverID,
		AlertType: notify.AlertRouteCompleted, Title: "Route completed",
	}))
	require.Empty(t, f.store.records)
	require.Empty(t, f.push.sent)
	require.Empty(t, f.pub.msgs)
}

func TestSafetyAlertSurvivesADisabledSetting(t *testing.T) {
	t.Parallel()
	f := newFixture(t)
	// The company tried to switch the HOS violation alert off entirely.
	f.store.settings[notify.AlertHOSViolation] = notify.Setting{
		Channels: []string{}, Enabled: false, Found: true,
	}

	require.NoError(t, f.disp.Send(context.Background(), notify.Notification{
		CompanyID: companyID, UserID: driverID,
		AlertType: notify.AlertHOSViolation, Title: "11-hour limit exceeded",
	}))

	require.Len(t, f.store.records, 1, "a safety alert is always recorded")
	require.Contains(t, f.store.records[0].Channels, notify.ChannelPush)
	require.Len(t, f.push.sent, 1)
	require.Equal(t, "tok-a", f.push.to[0].Devices[0].Token)
}

func TestSendPublishesOnTheNotificationsChannel(t *testing.T) {
	t.Parallel()
	f := newFixture(t)

	require.NoError(t, f.disp.Send(context.Background(), notify.Notification{
		CompanyID: companyID, UserID: driverID,
		AlertType: notify.AlertHOSWarning, Title: "Break due in 30 minutes",
	}))

	require.Len(t, f.pub.msgs, 1)
	msg := f.pub.msgs[0]
	require.Equal(t, ws.ChannelNotifications, msg.Channel)
	require.Equal(t, notify.EventCreated, msg.Event)
	require.Equal(t, companyID, msg.CompanyID)
	require.Contains(t, string(msg.Payload), "Break due in 30 minutes")
}

func TestSendIgnoresAnUnknownAlertType(t *testing.T) {
	t.Parallel()
	f := newFixture(t)
	require.NoError(t, f.disp.Send(context.Background(), notify.Notification{
		CompanyID: companyID, UserID: driverID, AlertType: "made_up", Title: "x",
	}))
	require.Empty(t, f.store.records)
}

func TestSendSurfacesAStoreFailure(t *testing.T) {
	t.Parallel()
	f := newFixture(t)
	f.store.failNext = errors.New("db down")
	err := f.disp.Send(context.Background(), notify.Notification{
		CompanyID: companyID, UserID: driverID,
		AlertType: notify.AlertRouteAssigned, Title: "Route assigned",
	})
	require.Error(t, err)
}

// ------------------------------------------------------------------ broadcast

func TestBroadcastExpandsRolesAndExplicitUsers(t *testing.T) {
	t.Parallel()
	f := newFixture(t)
	f.store.settings[notify.AlertDVIRCritical] = notify.Setting{
		Channels: []string{notify.ChannelPush, notify.ChannelEmail},
		// Only the role is configured; the driver is added explicitly.
		RecipientRoles: []uuid.UUID{roleID}, Enabled: true, Found: true,
	}

	require.NoError(t, f.disp.Broadcast(context.Background(), notify.Event{
		CompanyID: companyID, AlertType: notify.AlertDVIRCritical,
		Title: "Critical defect", Users: []uuid.UUID{driverID},
	}))

	got := make([]string, 0, len(f.store.records))
	for _, rec := range f.store.records {
		got = append(got, rec.UserID.String())
	}
	sort.Strings(got)
	want := []string{adminID.String(), driverID.String()}
	sort.Strings(want)
	require.Equal(t, want, got)
	require.Len(t, f.pub.msgs, 2)
}

func TestBroadcastDeduplicatesRecipients(t *testing.T) {
	t.Parallel()
	f := newFixture(t)
	f.store.settings[notify.AlertUnidentifiedDriving] = notify.Setting{
		Channels: []string{notify.ChannelPush}, RecipientRoles: []uuid.UUID{roleID},
		Enabled: true, Found: true,
	}

	require.NoError(t, f.disp.Broadcast(context.Background(), notify.Event{
		CompanyID: companyID, AlertType: notify.AlertUnidentifiedDriving,
		Title: "Unassigned driving", Users: []uuid.UUID{adminID},
	}))
	require.Len(t, f.store.records, 1, "the same user must not be notified twice")
}

// --------------------------------------------------------------------- senders

func TestMissingCredentialsDegradeToNop(t *testing.T) {
	t.Parallel()
	// A deployment without any provider must still boot and route every
	// channel to a sender that drops and warns instead of panicking.
	senders := notify.NewSenders(nil)
	for _, channel := range notify.AllChannels {
		if channel == notify.ChannelInApp {
			continue
		}
		s, ok := senders[channel]
		require.True(t, ok, channel)
		require.NotNil(t, s)
		require.NoError(t, s.Send(context.Background(), notify.Recipient{UserID: driverID},
			notify.Notification{AlertType: notify.AlertHOSWarning, Title: "x"}))
	}
}

func TestUnconfiguredProvidersReturnNilClients(t *testing.T) {
	t.Parallel()
	fcm, err := notify.NewFCMClient(notify.FCMConfig{})
	require.NoError(t, err)
	require.Nil(t, fcm)

	apns, err := notify.NewAPNsClient(notify.APNsConfig{})
	require.NoError(t, err)
	require.Nil(t, apns)

	mailer, err := notify.NewSMTPMailer(notify.SMTPConfig{})
	require.NoError(t, err)
	require.Nil(t, mailer)

	sms, err := notify.NewSMSSender(notify.SMSConfig{})
	require.NoError(t, err)
	require.Nil(t, sms)

	tg, err := notify.NewTelegramSender(notify.TelegramConfig{})
	require.NoError(t, err)
	require.Nil(t, tg)
}

// tzA19Alerts is the alert table of TZ A§19 verbatim. Every entry is
// mandatory: dropping or renaming one silently disables a notification the
// specification requires, which no other test would catch.
var tzA19Alerts = []string{
	"hos_warning", "hos_violation",
	"route_assigned", "route_completed",
	"dvir_defects", "dvir_critical",
	"log_edit_request", "log_edit_resolved",
	"uncertified_log", "unidentified_driving",
	"eld_disconnected", "eld_malfunction",
	"maintenance_upcoming", "maintenance_overdue",
	"chat_message", "subscription_expiring",
}

// stageExtensionAlerts are the types added after the TZ table was written:
// route_reassigned / route_not_completed (Q66, stage 7) and export_ready /
// export_failed (Q75, stage 8). They are checked separately so a future
// addition does not weaken the A§19 assertion into a bare count.
var stageExtensionAlerts = []string{
	"route_reassigned", "route_not_completed",
	"export_ready", "export_failed",
}

func TestAlertCatalogueMatchesTheTZTable(t *testing.T) {
	t.Parallel()
	require.Len(t, tzA19Alerts, 16)
	for _, a := range tzA19Alerts {
		require.True(t, notify.IsAlertType(a), "TZ A§19 alert %q is missing from the catalogue", a)
		require.NotEmpty(t, notify.DefaultChannels(a), a)
		require.Contains(t, notify.AllAlertTypes, a)
	}
	require.False(t, notify.IsAlertType("nope"))
}

func TestAlertCatalogueExtensionsAreDeclared(t *testing.T) {
	t.Parallel()
	for _, a := range stageExtensionAlerts {
		require.True(t, notify.IsAlertType(a), a)
		require.NotEmpty(t, notify.DefaultChannels(a), a)
	}
	// The catalogue is exactly the TZ table plus the declared extensions: an
	// undeclared alert type would ship without a documented default channel.
	require.ElementsMatch(t, append(append([]string{}, tzA19Alerts...), stageExtensionAlerts...),
		notify.AllAlertTypes)
}
