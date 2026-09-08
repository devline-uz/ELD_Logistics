// Package audit records field level changes into audit_log. Every mutating
// endpoint must write at least one entry.
package audit

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net"
	"net/netip"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Action enumerates the audited mutation kinds.
type Action string

// Known audit actions.
const (
	ActionCreate  Action = "create"
	ActionUpdate  Action = "update"
	ActionDelete  Action = "delete"
	ActionRestore Action = "restore"
	ActionLogin   Action = "login"
	ActionLogout  Action = "logout"
	ActionApprove Action = "approve"
	ActionReject  Action = "reject"
	ActionCertify Action = "certify"
	ActionExport  Action = "export"
	ActionAssign  Action = "assign"

	// Security relevant actions written by internal/domain/auth.
	ActionFailedLogin     Action = "failed_login"
	ActionPasswordChange  Action = "password_change"
	ActionPasswordReset   Action = "password_reset"
	ActionTokenReuse      Action = "token_reuse"
	ActionTOTPEnabled     Action = "2fa_enabled"
	ActionTOTPVerified    Action = "2fa_verified"
	ActionSessionRevoked  Action = "session_revoked"
	ActionSessionReplaced Action = "session_replaced"
	ActionSessionPaused   Action = "session_paused"
	ActionSessionResumed  Action = "session_resumed"
	ActionPINSet          Action = "pin_set"
	ActionPINVerified     Action = "pin_verified"
	ActionPINFailed       Action = "pin_failed"
	ActionLockout         Action = "account_locked"
	ActionInviteAccepted  Action = "invitation_accepted"
	// ActionLicenseReveal records that a clear text driver licence number was
	// served (TZ B§3.4): reading PII is an audited event.
	ActionLicenseReveal Action = "license_reveal"
)

// Entry is one audited field change.
type Entry struct {
	TableName string
	RecordID  uuid.UUID
	Field     string
	OldValue  any
	NewValue  any
	Action    Action
	EditedBy  uuid.UUID
	IP        string
	CompanyID uuid.UUID
	Reason    string
	CreatedAt time.Time
}

// Recorder writes audit entries. Implementations must never fail the caller's
// business transaction silently: Record returns the error, RecordTx joins the
// caller transaction so the audit trail is atomic with the change.
type Recorder interface {
	Record(ctx context.Context, entries ...Entry) error
	RecordTx(ctx context.Context, tx pgx.Tx, entries ...Entry) error
}

const insertSQL = `
INSERT INTO audit_log (
    id, company_id, table_name, record_id, field, old_value, new_value,
    action, edited_by, ip, reason, ts
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`

// TxRunner is the subset of db.Pool that PgRecorder needs.
type TxRunner interface {
	WithTx(ctx context.Context, companyID uuid.UUID, fn func(pgx.Tx) error) error
}

// PgRecorder is the pgx backed Recorder.
type PgRecorder struct {
	pool TxRunner
	log  *slog.Logger
}

// NewPgRecorder builds a Recorder on top of the tenant aware pool.
func NewPgRecorder(pool TxRunner, log *slog.Logger) *PgRecorder {
	if log == nil {
		log = slog.Default()
	}
	return &PgRecorder{pool: pool, log: log}
}

// Record opens its own transaction and writes the entries.
func (r *PgRecorder) Record(ctx context.Context, entries ...Entry) error {
	if len(entries) == 0 || r == nil || r.pool == nil {
		return nil
	}
	companyID := entries[0].CompanyID
	if companyID == uuid.Nil {
		companyID = tenant.CompanyID(ctx)
	}
	return r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		return r.RecordTx(ctx, tx, entries...)
	})
}

// RecordTx writes the entries inside an existing transaction.
func (r *PgRecorder) RecordTx(ctx context.Context, tx pgx.Tx, entries ...Entry) error {
	for _, e := range entries {
		e = enrich(ctx, e)

		oldJSON, err := encodeValue(e.Field, e.OldValue)
		if err != nil {
			return fmt.Errorf("audit: encode old_value: %w", err)
		}
		newJSON, err := encodeValue(e.Field, e.NewValue)
		if err != nil {
			return fmt.Errorf("audit: encode new_value: %w", err)
		}

		_, err = tx.Exec(ctx, insertSQL,
			uuid.New(), nullUUID(e.CompanyID), e.TableName, nullUUID(e.RecordID), e.Field,
			oldJSON, newJSON, string(e.Action), nullUUID(e.EditedBy), nullInet(e.IP),
			nullString(e.Reason), e.CreatedAt,
		)
		if err != nil {
			return fmt.Errorf("audit: insert %s.%s: %w", e.TableName, e.Field, err)
		}
	}
	return nil
}

// NopRecorder discards entries; used in tests and during bootstrap.
type NopRecorder struct{}

// Record implements Recorder.
func (NopRecorder) Record(context.Context, ...Entry) error { return nil }

// RecordTx implements Recorder.
func (NopRecorder) RecordTx(context.Context, pgx.Tx, ...Entry) error { return nil }

// Changes builds one Entry per changed field between two field maps.
func Changes(table string, recordID uuid.UUID, action Action, before, after map[string]any) []Entry {
	entries := make([]Entry, 0, len(after))
	for field, newVal := range after {
		oldVal := before[field]
		if fmt.Sprint(oldVal) == fmt.Sprint(newVal) {
			continue
		}
		entries = append(entries, Entry{
			TableName: table,
			RecordID:  recordID,
			Field:     field,
			OldValue:  oldVal,
			NewValue:  newVal,
			Action:    action,
		})
	}
	return entries
}

func enrich(ctx context.Context, e Entry) Entry {
	if e.CreatedAt.IsZero() {
		e.CreatedAt = time.Now().UTC()
	} else {
		e.CreatedAt = e.CreatedAt.UTC()
	}
	if e.CompanyID == uuid.Nil {
		e.CompanyID = tenant.CompanyID(ctx)
	}
	if e.EditedBy == uuid.Nil {
		e.EditedBy = tenant.UserID(ctx)
	}
	if e.Action == "" {
		e.Action = ActionUpdate
	}
	return e
}

// encodeValue stores values as JSON, redacting sensitive field names.
func encodeValue(field string, v any) ([]byte, error) {
	if v == nil {
		return nil, nil
	}
	if httpx.IsSensitive(field) {
		return json.Marshal("[REDACTED]")
	}
	return json.Marshal(v)
}

func nullUUID(id uuid.UUID) any {
	if id == uuid.Nil {
		return nil
	}
	return id
}

// nullInet renders an IP for the inet column. RemoteAddr style "host:port"
// values are trimmed; anything unparseable is stored as NULL rather than
// failing the audited transaction.
func nullInet(v string) any {
	v = strings.TrimSpace(v)
	if v == "" {
		return nil
	}
	if addr, err := netip.ParseAddr(v); err == nil {
		return addr.String()
	}
	if host, _, err := net.SplitHostPort(v); err == nil {
		if addr, err := netip.ParseAddr(host); err == nil {
			return addr.String()
		}
	}
	return nil
}

func nullString(s string) any {
	if s == "" {
		return nil
	}
	return s
}
