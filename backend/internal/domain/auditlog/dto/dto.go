// Package dto holds the audit log read model (TZ A§17). `audit_log` is
// append-only, so this package deliberately exposes no create, update or
// delete payload: the module is read only.
package dto

import (
	"time"

	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared envelopes re-exported so swagger annotations can reference dto.X.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
)

// Entry is one row of the audit trail. `old_value` and `new_value` are always
// masked before they leave the server: a password hash, a session token or a
// driver licence number never reaches a client (TZ B§6.1 — PII masking).
type Entry struct {
	ID string `json:"id" example:"3c9a1f2e-5d4b-4a6c-8e1f-0d2b3a4c5e6f"`
	// TableName is the audited table, e.g. `units` or `support_tickets`.
	TableName string `json:"table" example:"support_tickets"`
	// RecordID is the audited row, null for account wide events such as login.
	RecordID *string `json:"record_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	Field    string  `json:"field" example:"status"`
	// OldValue is the masked value before the change, null on insert. The
	// stored shape is whatever the audited column held (a string, a number, a
	// JSON object); swag cannot type an `any`, so the schema renders it as a
	// free form string.
	OldValue any `json:"old_value" swaggertype:"string" example:"new"`
	// NewValue is the masked value after the change, null on delete.
	NewValue any `json:"new_value" swaggertype:"string" example:"in_progress"`
	// Masked reports that at least one of the two values was redacted.
	Masked bool   `json:"masked" example:"false"`
	Action string `json:"action" example:"update" enums:"insert,create,update,soft_delete,delete,restore,login,logout,failed_login,export,permission_change,log_edit_request,hos_policy_change,token_reuse,cross_tenant_attempt,certify,assign,approve,reject,license_reveal"`
	// EditedBy is the acting user, null for system jobs.
	EditedBy     *string   `json:"edited_by" example:"8d3e2f1a-4b5c-4d6e-9f70-1a2b3c4d5e6f"`
	EditedByName string    `json:"edited_by_name" example:"Anna Ross"`
	Username     string    `json:"username" example:"anna.ross"`
	IP           string    `json:"ip" example:"203.0.113.24"`
	UserAgent    string    `json:"user_agent" example:"Mozilla/5.0"`
	Reason       string    `json:"reason" example:"driver requested correction"`
	TS           time.Time `json:"ts" format:"date-time" example:"2026-09-07T11:30:00Z"`
}

// Response envelopes.
type (
	// EntryListEnvelope wraps a page of audit entries.
	EntryListEnvelope struct {
		Data []Entry `json:"data"`
		Meta Meta    `json:"meta"`
	}
	// TableListEnvelope wraps the audited table names of the company, for the
	// filter dropdown of the audit journal screen.
	TableListEnvelope struct {
		Data []string `json:"data" example:"support_tickets"`
	}
)
