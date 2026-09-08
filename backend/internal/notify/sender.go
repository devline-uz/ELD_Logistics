package notify

import (
	"context"
	"log/slog"
	"sync"

	"github.com/google/uuid"
)

// Device is one registered push endpoint of a user.
type Device struct {
	// Platform is "android", "ios" or "web".
	Platform string
	// Token is the FCM registration id or the APNs device token.
	Token string
	// DeviceID is the client's stable installation id.
	DeviceID string
}

// Push platforms.
const (
	PlatformAndroid = "android"
	PlatformIOS     = "ios"
	PlatformWeb     = "web"
)

// IsPlatform reports whether v is a supported push platform.
func IsPlatform(v string) bool {
	return v == PlatformAndroid || v == PlatformIOS || v == PlatformWeb
}

// Recipient is the contact card of one user. It is assembled by the dispatcher
// from the users table and the registered devices; it never reaches a log.
type Recipient struct {
	UserID         uuid.UUID
	Email          string
	Phone          string
	TelegramChatID string
	Devices        []Device
}

// Sender delivers a notification over exactly one channel.
type Sender interface {
	// Channel is the channel key this sender serves.
	Channel() string
	Send(ctx context.Context, to Recipient, n Notification) error
}

// NopSender accepts everything and delivers nothing. It stands in for a
// channel whose credentials are missing so the process still boots; the first
// call logs one warning per channel.
type NopSender struct {
	channel string
	log     *slog.Logger
	once    sync.Once
	reason  string
}

// NewNopSender builds a disabled channel sender.
func NewNopSender(channel, reason string, log *slog.Logger) *NopSender {
	if log == nil {
		log = slog.Default()
	}
	if reason == "" {
		reason = "provider credentials are not configured"
	}
	return &NopSender{channel: channel, log: log, reason: reason}
}

// Channel implements Sender.
func (s *NopSender) Channel() string { return s.channel }

// Send implements Sender.
func (s *NopSender) Send(ctx context.Context, _ Recipient, n Notification) error {
	s.once.Do(func() {
		s.log.WarnContext(ctx, "notify: channel disabled, notifications are dropped",
			slog.String("channel", s.channel),
			slog.String("reason", s.reason))
	})
	s.log.DebugContext(ctx, "notify: dropped notification",
		slog.String("channel", s.channel), slog.String("alert_type", n.AlertType))
	return nil
}

// Senders is the channel key to Sender routing table used by the dispatcher.
type Senders map[string]Sender

// NewSenders builds a routing table, filling every missing channel with a
// NopSender so a lookup never returns nil.
func NewSenders(log *slog.Logger, senders ...Sender) Senders {
	out := make(Senders, len(AllChannels))
	for _, s := range senders {
		if s != nil {
			out[s.Channel()] = s
		}
	}
	for _, c := range AllChannels {
		if c == ChannelInApp {
			continue
		}
		if _, ok := out[c]; !ok {
			out[c] = NewNopSender(c, "provider credentials are not configured", log)
		}
	}
	return out
}
