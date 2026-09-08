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

// SMSConfig configures the generic HTTP SMS gateway adapter. Any provider that
// accepts a JSON POST fits; the field names are configurable so no vendor SDK
// is needed.
type SMSConfig struct {
	Endpoint string
	// Token is sent as a bearer credential when set.
	Token string
	// ToField and TextField name the JSON keys of the provider payload.
	ToField   string
	TextField string
	// Extra is merged into every request body (sender id, route, ...).
	Extra   map[string]string
	Timeout time.Duration
}

// SMSSender is the SMS channel over a plain HTTP gateway.
type SMSSender struct {
	cfg  SMSConfig
	http *http.Client
}

// NewSMSSender builds the sender, or returns nil when it is not configured.
func NewSMSSender(cfg SMSConfig) (*SMSSender, error) {
	if strings.TrimSpace(cfg.Endpoint) == "" {
		return nil, nil
	}
	if cfg.ToField == "" {
		cfg.ToField = "to"
	}
	if cfg.TextField == "" {
		cfg.TextField = "text"
	}
	if cfg.Timeout <= 0 {
		cfg.Timeout = 10 * time.Second
	}
	return &SMSSender{cfg: cfg, http: &http.Client{Timeout: cfg.Timeout}}, nil
}

// Channel implements Sender.
func (s *SMSSender) Channel() string { return ChannelSMS }

// maxSMSLen keeps one alert inside a few segments.
const maxSMSLen = 320

// Send implements Sender.
func (s *SMSSender) Send(ctx context.Context, to Recipient, n Notification) error {
	if s == nil || strings.TrimSpace(to.Phone) == "" {
		return nil
	}
	text := n.Title
	if n.Body != "" {
		text += ": " + n.Body
	}
	if len(text) > maxSMSLen {
		text = text[:maxSMSLen]
	}
	payload := make(map[string]string, len(s.cfg.Extra)+2)
	for k, v := range s.cfg.Extra {
		payload[k] = v
	}
	payload[s.cfg.ToField] = to.Phone
	payload[s.cfg.TextField] = text

	buf, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, s.cfg.Endpoint, bytes.NewReader(buf))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	if s.cfg.Token != "" {
		req.Header.Set("Authorization", "Bearer "+s.cfg.Token)
	}
	resp, err := s.http.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		// The response may echo the phone number, so it is not surfaced.
		_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 4096))
		return fmt.Errorf("notify: sms gateway responded %d", resp.StatusCode)
	}
	_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 4096))
	return nil
}
