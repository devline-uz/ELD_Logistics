// Package ws holds the WebSocket hub and its transport. Channels and payloads
// are documented by hand in docs/websocket.md — they never appear in the
// Swagger spec.
package ws

import (
	"context"
	"encoding/json"
	"log/slog"
	"sync"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/tenant"
)

// Channel names broadcast by the hub. TZ B§5: the four real time channels are
// tracking, notifications, chat and dashboard; the rest are internal events
// kept for the legacy publishers.
const (
	ChannelTracking      = "tracking"
	ChannelNotifications = "notifications"
	ChannelChat          = "chat"
	ChannelDashboard     = "dashboard"

	ChannelUnits      = "units"
	ChannelDrivers    = "drivers"
	ChannelHOS        = "hos"
	ChannelAlerts     = "alerts"
	ChannelMessages   = "messages"
	ChannelViolations = "violations"
)

// Channels lists the channels a client may subscribe to.
var Channels = []string{ChannelTracking, ChannelNotifications, ChannelChat, ChannelDashboard}

// IsChannel reports whether name is a subscribable channel.
func IsChannel(name string) bool {
	for _, c := range Channels {
		if c == name {
			return true
		}
	}
	return false
}

// Message is one envelope pushed to subscribers.
type Message struct {
	Channel   string          `json:"channel"`
	Event     string          `json:"event"`
	CompanyID uuid.UUID       `json:"company_id"`
	Payload   json.RawMessage `json:"payload"`
	SentAt    time.Time       `json:"sent_at"`
	// To narrows delivery inside the tenant. A zero value is a company wide
	// broadcast, which is only correct for payloads every subscriber of the
	// channel is entitled to (dashboard KPI, fleet tracking). Personal or
	// thread scoped payloads MUST address themselves.
	To Audience `json:"to,omitzero"`
}

// Audience restricts a message to part of the tenant. Channel permission alone
// is not authorisation: `chat.read` is held by drivers too, and a notification
// belongs to exactly one inbox, so the hub needs to know who a message is for.
type Audience struct {
	// UserID addresses one user. It is the only recipient unless Office is set.
	UserID *uuid.UUID `json:"user_id,omitempty"`
	// Office additionally delivers to company and branch scoped subscribers —
	// the dispatch side of a driver conversation. Self scoped clients (drivers)
	// are never included by it.
	Office bool `json:"office,omitempty"`
	// BranchID, when set, keeps the message inside one branch: a branch scoped
	// subscriber of another branch is skipped.
	BranchID *uuid.UUID `json:"branch_id,omitempty"`
}

// IsZero reports whether the audience is a company wide broadcast.
func (a Audience) IsZero() bool { return a.UserID == nil && !a.Office && a.BranchID == nil }

// allows reports whether the client may receive a message with this audience.
// Deny by default: an addressed message never reaches an unnamed subscriber.
func (a Audience) allows(c *Client) bool {
	if a.IsZero() {
		return true
	}
	if a.UserID != nil && *a.UserID == c.UserID {
		return true
	}
	if !a.Office || c.Scope == tenant.ScopeSelf {
		return false
	}
	if a.BranchID != nil && c.Scope == tenant.ScopeBranch &&
		(c.BranchID == nil || *c.BranchID != *a.BranchID) {
		return false
	}
	return true
}

// Filter narrows a subscription. An empty filter accepts every message of the
// channel. Matching reads the ids out of the payload, so a publisher only has
// to put unit_id / driver_id in the event body.
type Filter struct {
	UnitIDs   []uuid.UUID `json:"unit_ids,omitempty"`
	DriverIDs []uuid.UUID `json:"driver_ids,omitempty"`
}

// IsEmpty reports whether the filter accepts everything.
func (f Filter) IsEmpty() bool { return len(f.UnitIDs) == 0 && len(f.DriverIDs) == 0 }

// payloadIDs is the minimal shape the hub peeks at to apply a filter.
type payloadIDs struct {
	UnitID   *uuid.UUID `json:"unit_id"`
	DriverID *uuid.UUID `json:"driver_id"`
}

// Matches reports whether the payload passes the filter.
func (f Filter) Matches(payload json.RawMessage) bool {
	if f.IsEmpty() {
		return true
	}
	var ids payloadIDs
	if len(payload) == 0 || json.Unmarshal(payload, &ids) != nil {
		// A payload that carries no ids cannot satisfy an id filter.
		return false
	}
	if len(f.UnitIDs) > 0 && ids.UnitID != nil && containsID(f.UnitIDs, *ids.UnitID) {
		return true
	}
	if len(f.DriverIDs) > 0 && ids.DriverID != nil && containsID(f.DriverIDs, *ids.DriverID) {
		return true
	}
	return false
}

func containsID(list []uuid.UUID, id uuid.UUID) bool {
	for _, v := range list {
		if v == id {
			return true
		}
	}
	return false
}

// Client is one connected subscriber. Subscriptions are mutated by the
// transport (conn.go) and read by the hub, so they are guarded by the client's
// own mutex; the hub lock is always taken first.
type Client struct {
	ID        uuid.UUID
	UserID    uuid.UUID
	CompanyID uuid.UUID
	// Scope and BranchID mirror the principal. They are what lets the hub tell
	// a driver (self scope) from the dispatch side when a message is addressed.
	Scope    tenant.Scope
	BranchID *uuid.UUID
	// Channels is the initial subscription set. It is kept exported for the
	// existing callers; Subscribe/Unsubscribe maintain it afterwards.
	Channels []string
	Send     chan Message

	mu      sync.RWMutex
	filters map[string]Filter
}

// subscribe records a channel subscription and its filter.
func (c *Client) subscribe(channel string, f Filter) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.filters == nil {
		c.filters = make(map[string]Filter, len(Channels))
	}
	if _, ok := c.filters[channel]; !ok {
		c.Channels = append(c.Channels, channel)
	}
	c.filters[channel] = f
}

// unsubscribe drops a channel subscription.
func (c *Client) unsubscribe(channel string) bool {
	c.mu.Lock()
	defer c.mu.Unlock()
	if _, ok := c.filters[channel]; !ok {
		return false
	}
	delete(c.filters, channel)
	out := c.Channels[:0]
	for _, ch := range c.Channels {
		if ch != channel {
			out = append(out, ch)
		}
	}
	c.Channels = out
	return true
}

// accepts reports whether the client wants this message. Deny by default: a
// client that has not subscribed receives nothing.
func (c *Client) accepts(msg Message) bool {
	c.mu.RLock()
	defer c.mu.RUnlock()
	if c.filters != nil {
		f, ok := c.filters[msg.Channel]
		if !ok {
			return false
		}
		return f.Matches(msg.Payload)
	}
	// Clients built without the transport (legacy publishers, tests) fall back
	// to the plain channel list.
	for _, ch := range c.Channels {
		if ch == msg.Channel {
			return true
		}
	}
	return false
}

// Subscriptions returns a copy of the client's channel list.
func (c *Client) Subscriptions() []string {
	c.mu.RLock()
	defer c.mu.RUnlock()
	out := make([]string, len(c.Channels))
	copy(out, c.Channels)
	return out
}

// Publisher is the write side of the hub; services depend on this, not on Hub.
type Publisher interface {
	Publish(ctx context.Context, msg Message) error
}

// Hub fans messages out to the clients of one company. Cross-instance delivery
// is handled by the Redis pub/sub bridge (redis.go).
type Hub struct {
	mu      sync.RWMutex
	clients map[uuid.UUID]*Client
	log     *slog.Logger
}

// NewHub creates an empty hub.
func NewHub(log *slog.Logger) *Hub {
	if log == nil {
		log = slog.Default()
	}
	return &Hub{clients: make(map[uuid.UUID]*Client), log: log}
}

// Register adds a client to the hub.
func (h *Hub) Register(c *Client) {
	if c == nil {
		return
	}
	h.mu.Lock()
	defer h.mu.Unlock()
	h.clients[c.ID] = c
}

// Unregister removes a client and closes its send channel.
func (h *Hub) Unregister(id uuid.UUID) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if c, ok := h.clients[id]; ok {
		delete(h.clients, id)
		close(c.Send)
	}
}

// Subscribe adds a channel (with its filter) to a registered client. It runs
// under the hub lock so Publish never races with a subscription change.
func (h *Hub) Subscribe(id uuid.UUID, channel string, f Filter) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	c, ok := h.clients[id]
	if !ok {
		return false
	}
	c.subscribe(channel, f)
	return true
}

// Unsubscribe drops a channel from a registered client.
func (h *Hub) Unsubscribe(id uuid.UUID, channel string) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	c, ok := h.clients[id]
	if !ok {
		return false
	}
	return c.unsubscribe(channel)
}

// Publish delivers a message to every local client subscribed to its channel
// within the same company. Cross-node delivery is the bridge's job.
func (h *Hub) Publish(_ context.Context, msg Message) error {
	if msg.SentAt.IsZero() {
		msg.SentAt = time.Now().UTC()
	}
	h.mu.RLock()
	defer h.mu.RUnlock()
	for _, c := range h.clients {
		// Tenant isolation: a message never leaves its company, whatever the
		// client claims to be subscribed to. Inside the company the audience
		// decides, so a personal or thread scoped payload is not readable by
		// everyone who merely holds the channel permission.
		if c.CompanyID != msg.CompanyID || !msg.To.allows(c) || !c.accepts(msg) {
			continue
		}
		select {
		case c.Send <- msg:
		default:
			// Slow consumer: drop rather than block the publisher.
		}
	}
	return nil
}

// Count returns the number of connected local clients.
func (h *Hub) Count() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// Close disconnects every client.
func (h *Hub) Close() {
	h.mu.Lock()
	defer h.mu.Unlock()
	for id, c := range h.clients {
		delete(h.clients, id)
		close(c.Send)
	}
}

// NopPublisher discards every message; used in tests.
type NopPublisher struct{}

// Publish implements Publisher.
func (NopPublisher) Publish(context.Context, Message) error { return nil }

// IsOnline reports whether a user of the company holds at least one live
// connection on this node. Chat uses it to decide between a WebSocket delivery
// and a push notification; a false negative only means one extra push.
func (h *Hub) IsOnline(companyID, userID uuid.UUID) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	for _, c := range h.clients {
		if c.CompanyID == companyID && c.UserID == userID {
			return true
		}
	}
	return false
}
