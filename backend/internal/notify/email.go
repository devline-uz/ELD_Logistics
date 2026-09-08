package notify

import (
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"mime"
	"net"
	"net/smtp"
	"strings"
	"time"
)

// Mailer is the transport behind the email channel. SMTP is the default
// implementation; an SES (or any API) adapter only has to satisfy this.
type Mailer interface {
	Mail(ctx context.Context, to, subject, body string) error
}

// EmailSender is the email channel.
type EmailSender struct {
	Mailer Mailer
}

// Channel implements Sender.
func (s *EmailSender) Channel() string { return ChannelEmail }

// Send implements Sender.
func (s *EmailSender) Send(ctx context.Context, to Recipient, n Notification) error {
	if s.Mailer == nil || strings.TrimSpace(to.Email) == "" {
		return nil
	}
	return s.Mailer.Mail(ctx, to.Email, n.Title, n.Body)
}

// SMTPConfig configures the SMTP mailer.
type SMTPConfig struct {
	Host     string
	Port     int
	Username string
	Password string
	From     string
	// StartTLS upgrades the connection; plaintext is only for a local relay.
	StartTLS bool
	Timeout  time.Duration
}

// SMTPMailer sends mail over SMTP.
type SMTPMailer struct {
	cfg SMTPConfig
}

// NewSMTPMailer builds the mailer, or returns nil when it is not configured.
func NewSMTPMailer(cfg SMTPConfig) (*SMTPMailer, error) {
	if cfg.Host == "" || cfg.From == "" {
		return nil, nil
	}
	if cfg.Port == 0 {
		cfg.Port = 587
	}
	if cfg.Timeout <= 0 {
		cfg.Timeout = 15 * time.Second
	}
	return &SMTPMailer{cfg: cfg}, nil
}

// Mail implements Mailer.
func (m *SMTPMailer) Mail(ctx context.Context, to, subject, body string) error {
	if m == nil {
		return nil
	}
	if strings.ContainsAny(to, "\r\n") || strings.ContainsAny(subject, "\r\n") {
		// Header injection guard: a newline in a header is always an attack.
		return errors.New("notify: header injection rejected")
	}
	addr := net.JoinHostPort(m.cfg.Host, fmt.Sprint(m.cfg.Port))
	dialer := &net.Dialer{Timeout: m.cfg.Timeout}
	conn, err := dialer.DialContext(ctx, "tcp", addr)
	if err != nil {
		return err
	}
	client, err := smtp.NewClient(conn, m.cfg.Host)
	if err != nil {
		_ = conn.Close()
		return err
	}
	defer func() { _ = client.Close() }()

	if m.cfg.StartTLS {
		if err := client.StartTLS(&tls.Config{ServerName: m.cfg.Host, MinVersion: tls.VersionTLS12}); err != nil {
			return err
		}
	}
	if m.cfg.Username != "" {
		if err := client.Auth(smtp.PlainAuth("", m.cfg.Username, m.cfg.Password, m.cfg.Host)); err != nil {
			return err
		}
	}
	if err := client.Mail(m.cfg.From); err != nil {
		return err
	}
	if err := client.Rcpt(to); err != nil {
		return err
	}
	w, err := client.Data()
	if err != nil {
		return err
	}
	msg := "From: " + m.cfg.From + "\r\n" +
		"To: " + to + "\r\n" +
		"Subject: " + mime.QEncoding.Encode("utf-8", subject) + "\r\n" +
		"MIME-Version: 1.0\r\n" +
		"Content-Type: text/plain; charset=utf-8\r\n\r\n" + body + "\r\n"
	if _, err := w.Write([]byte(msg)); err != nil {
		_ = w.Close()
		return err
	}
	if err := w.Close(); err != nil {
		return err
	}
	return client.Quit()
}
