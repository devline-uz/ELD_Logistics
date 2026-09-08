package notify

import (
	"context"
	"encoding/json"
	"log/slog"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
)

// Setting is one notification_settings row resolved for an alert type.
type Setting struct {
	Channels       []string
	RecipientRoles []uuid.UUID
	Enabled        bool
	// Found is false when the company has no row and the TZ A§19 defaults
	// apply.
	Found bool
}

// Record is the notifications row the dispatcher writes before delivering.
type Record struct {
	CompanyID  uuid.UUID
	UserID     uuid.UUID
	AlertType  string
	Title      string
	Body       string
	EntityType string
	EntityID   *uuid.UUID
	Channels   []string
	SentAt     time.Time
}

// Store is everything the dispatcher needs from persistence. It is implemented
// by internal/domain/notifications so this package stays free of SQL.
type Store interface {
	// Setting returns the company's configuration for one alert type.
	Setting(ctx context.Context, companyID uuid.UUID, alertType string) (Setting, error)
	// RecipientsByRoles resolves the active users holding any of the roles.
	RecipientsByRoles(ctx context.Context, companyID uuid.UUID, roleIDs []uuid.UUID) ([]Recipient, error)
	// Recipients resolves specific users, dropping unknown or inactive ones.
	Recipients(ctx context.Context, companyID uuid.UUID, userIDs []uuid.UUID) ([]Recipient, error)
	// Insert writes the in-app notification and returns its id.
	Insert(ctx context.Context, rec Record) (uuid.UUID, error)
}

// Deps are the dispatcher dependencies. Store is required; without a Publisher
// the WebSocket notifications channel is simply not fed.
type Deps struct {
	Store     Store
	Senders   Senders
	Publisher ws.Publisher
	Log       *slog.Logger
	Now       func() time.Time
}

// Dispatcher resolves recipients and channels, records the in-app
// notification, publishes it on the WebSocket notifications channel and hands
// it to every configured provider. It implements Notifier.
type Dispatcher struct {
	store   Store
	senders Senders
	pub     ws.Publisher
	log     *slog.Logger
	now     func() time.Time
}

// NewDispatcher builds the dispatcher.
func NewDispatcher(deps Deps) *Dispatcher {
	d := &Dispatcher{
		store: deps.Store, senders: deps.Senders, pub: deps.Publisher,
		log: deps.Log, now: deps.Now,
	}
	if d.log == nil {
		d.log = slog.Default()
	}
	if d.now == nil {
		d.now = time.Now
	}
	if d.pub == nil {
		d.pub = ws.NopPublisher{}
	}
	if d.senders == nil {
		d.senders = NewSenders(d.log)
	}
	return d
}

// EventNotification is the WebSocket payload of the notifications channel.
type EventNotification struct {
	ID         uuid.UUID  `json:"id"`
	UserID     uuid.UUID  `json:"user_id"`
	AlertType  string     `json:"alert_type"`
	Title      string     `json:"title"`
	Body       string     `json:"body,omitempty"`
	EntityType string     `json:"entity_type,omitempty"`
	EntityID   *uuid.UUID `json:"entity_id,omitempty"`
	Channels   []string   `json:"channels"`
	CreatedAt  time.Time  `json:"created_at"`
}

// EventCreated is the notifications channel event name.
const EventCreated = "notification_created"

// Send implements Notifier: one alert to one user.
func (d *Dispatcher) Send(ctx context.Context, n Notification) error {
	companyID := n.CompanyID
	if companyID == uuid.Nil {
		companyID = tenant.CompanyID(ctx)
	}
	if companyID == uuid.Nil || n.UserID == uuid.Nil || !IsAlertType(n.AlertType) {
		return nil
	}
	recipients, err := d.store.Recipients(ctx, companyID, []uuid.UUID{n.UserID})
	if err != nil {
		return err
	}
	if len(recipients) == 0 {
		return nil
	}
	channels, ok, err := d.channels(ctx, companyID, n.AlertType, n.Channels)
	if err != nil || !ok {
		return err
	}
	return d.deliver(ctx, companyID, n, channels, recipients[0])
}

// Broadcast expands a role addressed event into one notification per
// recipient. A single failing recipient never stops the others.
func (d *Dispatcher) Broadcast(ctx context.Context, ev Event) error {
	companyID := ev.CompanyID
	if companyID == uuid.Nil {
		companyID = tenant.CompanyID(ctx)
	}
	if companyID == uuid.Nil || !IsAlertType(ev.AlertType) {
		return nil
	}
	setting, err := d.store.Setting(ctx, companyID, ev.AlertType)
	if err != nil {
		return err
	}
	if setting.Found && !setting.Enabled && !IsMandatoryPush(ev.AlertType) {
		return nil
	}
	configured := setting.Channels
	if !setting.Found || len(configured) == 0 {
		configured = DefaultChannels(ev.AlertType)
	}
	channels := ResolveChannels(ev.AlertType, configured)

	recipients := make(map[uuid.UUID]Recipient)
	if len(setting.RecipientRoles) > 0 {
		byRole, err := d.store.RecipientsByRoles(ctx, companyID, setting.RecipientRoles)
		if err != nil {
			return err
		}
		for _, r := range byRole {
			recipients[r.UserID] = r
		}
	}
	if len(ev.Users) > 0 {
		explicit, err := d.store.Recipients(ctx, companyID, ev.Users)
		if err != nil {
			return err
		}
		for _, r := range explicit {
			recipients[r.UserID] = r
		}
	}

	var last error
	for _, r := range recipients {
		n := Notification{
			CompanyID: companyID, UserID: r.UserID, AlertType: ev.AlertType,
			Title: ev.Title, Body: ev.Body,
			EntityType: ev.EntityType, EntityID: ev.EntityID, Data: ev.Data,
		}
		if err := d.deliver(ctx, companyID, n, channels, r); err != nil {
			last = err
			d.log.WarnContext(ctx, "notify: delivery failed",
				slog.String("alert_type", ev.AlertType), slog.String("error", err.Error()))
		}
	}
	return last
}

// channels resolves the effective channel list of one alert type, reporting
// whether the alert must be sent at all.
func (d *Dispatcher) channels(ctx context.Context, companyID uuid.UUID, alertType string, override []string) ([]string, bool, error) {
	if len(override) > 0 {
		return ResolveChannels(alertType, override), true, nil
	}
	setting, err := d.store.Setting(ctx, companyID, alertType)
	if err != nil {
		return nil, false, err
	}
	// Q89: hos_* and eld_* are safety alerts and cannot be switched off.
	if setting.Found && !setting.Enabled && !IsMandatoryPush(alertType) {
		return nil, false, nil
	}
	configured := setting.Channels
	if !setting.Found || len(configured) == 0 {
		configured = DefaultChannels(alertType)
	}
	return ResolveChannels(alertType, configured), true, nil
}

// deliver records the in-app notification, publishes it and pushes it out.
func (d *Dispatcher) deliver(ctx context.Context, companyID uuid.UUID, n Notification, channels []string, to Recipient) error {
	now := d.now().UTC()
	id, err := d.store.Insert(ctx, Record{
		CompanyID: companyID, UserID: to.UserID, AlertType: n.AlertType,
		Title: n.Title, Body: n.Body, EntityType: n.EntityType, EntityID: n.EntityID,
		Channels: channels, SentAt: now,
	})
	if err != nil {
		return err
	}

	if payload, err := json.Marshal(EventNotification{
		ID: id, UserID: to.UserID, AlertType: n.AlertType, Title: n.Title, Body: n.Body,
		EntityType: n.EntityType, EntityID: n.EntityID, Channels: channels, CreatedAt: now,
	}); err == nil {
		// A notification is one inbox: it is addressed to its owner, never
		// broadcast to every subscriber of the company channel.
		recipient := to.UserID
		if err := d.pub.Publish(ctx, ws.Message{
			Channel:   ws.ChannelNotifications,
			Event:     EventCreated,
			CompanyID: companyID,
			Payload:   payload,
			SentAt:    now,
			To:        ws.Audience{UserID: &recipient},
		}); err != nil {
			d.log.WarnContext(ctx, "notify: websocket publish failed", slog.String("error", err.Error()))
		}
	}

	var last error
	for _, c := range channels {
		if c == ChannelInApp {
			continue
		}
		sender, ok := d.senders[c]
		if !ok || sender == nil {
			continue
		}
		if err := sender.Send(ctx, to, n); err != nil {
			last = err
		}
	}
	return last
}
