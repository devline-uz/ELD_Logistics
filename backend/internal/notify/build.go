package notify

import (
	"log/slog"
	"os"
	"strings"

	"github.com/devline/onebook-eld/internal/config"
)

// Build assembles the channel senders from configuration. A missing credential
// never fails: that channel degrades to a NopSender that warns once, so a
// deployment without FCM, APNs, SMTP or an SMS gateway still boots (TZ Q89).
func Build(cfg config.NotifyConfig, log *slog.Logger) Senders {
	if log == nil {
		log = slog.Default()
	}
	var senders []Sender

	if push := buildPush(cfg, log); push != nil {
		senders = append(senders, push)
	}
	if mailer, err := NewSMTPMailer(SMTPConfig{
		Host: cfg.SMTP.Host, Port: cfg.SMTP.Port, Username: cfg.SMTP.Username,
		Password: cfg.SMTP.Password, From: cfg.SMTP.From, StartTLS: cfg.SMTP.StartTLS,
	}); err != nil {
		log.Warn("notify: smtp disabled", slog.String("error", err.Error()))
	} else if mailer != nil {
		senders = append(senders, &EmailSender{Mailer: mailer})
	}
	if sms, err := NewSMSSender(SMSConfig{
		Endpoint: cfg.SMS.Endpoint, Token: cfg.SMS.Token,
		ToField: cfg.SMS.ToField, TextField: cfg.SMS.TextField,
	}); err != nil {
		log.Warn("notify: sms disabled", slog.String("error", err.Error()))
	} else if sms != nil {
		senders = append(senders, sms)
	}
	if tg, err := NewTelegramSender(TelegramConfig{BotToken: cfg.Telegram.BotToken}); err != nil {
		log.Warn("notify: telegram disabled", slog.String("error", err.Error()))
	} else if tg != nil {
		senders = append(senders, tg)
	}

	return NewSenders(log, senders...)
}

// buildPush wires FCM and APNs; either half may be missing.
func buildPush(cfg config.NotifyConfig, log *slog.Logger) Sender {
	fcm, err := NewFCMClient(FCMConfig{
		ProjectID:          cfg.FCM.ProjectID,
		ServiceAccountJSON: readSecret(cfg.FCM.ServiceAccountJSON, cfg.FCM.ServiceAccountFile, log),
	})
	if err != nil {
		log.Warn("notify: fcm disabled", slog.String("error", err.Error()))
		fcm = nil
	}
	apns, err := NewAPNsClient(APNsConfig{
		AuthKeyP8:  readSecret(cfg.APNs.AuthKeyP8, cfg.APNs.AuthKeyFile, log),
		KeyID:      cfg.APNs.KeyID,
		TeamID:     cfg.APNs.TeamID,
		Topic:      cfg.APNs.Topic,
		Production: cfg.APNs.Production,
	})
	if err != nil {
		log.Warn("notify: apns disabled", slog.String("error", err.Error()))
		apns = nil
	}
	if fcm == nil && apns == nil {
		return nil
	}
	return &PushSender{FCM: fcm, APNs: apns, Log: log}
}

// readSecret prefers the inline value and falls back to a file path. The
// secret is never logged, only the failure to read it.
func readSecret(inline, path string, log *slog.Logger) []byte {
	if v := strings.TrimSpace(inline); v != "" {
		return []byte(v)
	}
	if path == "" {
		return nil
	}
	buf, err := os.ReadFile(path)
	if err != nil {
		log.Warn("notify: secret file unreadable", slog.String("path", path))
		return nil
	}
	return buf
}
