package notify

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// TelegramConfig configures the Bot API adapter (TZ Q89 — Telegram is a MAY).
type TelegramConfig struct {
	BotToken string
	// Endpoint overrides https://api.telegram.org in tests.
	Endpoint string
	Timeout  time.Duration
}

// TelegramSender is the Telegram channel.
type TelegramSender struct {
	endpoint string
	http     *http.Client
}

// NewTelegramSender builds the sender, or returns nil when it is not configured.
func NewTelegramSender(cfg TelegramConfig) (*TelegramSender, error) {
	if strings.TrimSpace(cfg.BotToken) == "" {
		return nil, nil
	}
	base := cfg.Endpoint
	if base == "" {
		base = "https://api.telegram.org"
	}
	if cfg.Timeout <= 0 {
		cfg.Timeout = 10 * time.Second
	}
	return &TelegramSender{
		endpoint: strings.TrimRight(base, "/") + "/bot" + cfg.BotToken + "/sendMessage",
		http:     &http.Client{Timeout: cfg.Timeout},
	}, nil
}

// Channel implements Sender.
func (s *TelegramSender) Channel() string { return ChannelTelegram }

// Send implements Sender.
func (s *TelegramSender) Send(ctx context.Context, to Recipient, n Notification) error {
	if s == nil || strings.TrimSpace(to.TelegramChatID) == "" {
		return nil
	}
	text := n.Title
	if n.Body != "" {
		text += "\n" + n.Body
	}
	buf, err := json.Marshal(map[string]string{"chat_id": to.TelegramChatID, "text": text})
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, s.endpoint, bytes.NewReader(buf))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := s.http.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 4096))
	if resp.StatusCode >= 300 {
		return fmt.Errorf("notify: telegram responded %d", resp.StatusCode)
	}
	return nil
}
