// Package dto holds the notification centre payloads: the in-app inbox
// (TZ A§19 / Q87–Q88) and the push token registry.
//
// A device token is a credential: it is accepted by POST /devices/push-token
// and never returned by any endpoint.
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

// Notification is one row of the in-app inbox.
type Notification struct {
	ID         string     `json:"id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	AlertType  string     `json:"alert_type" example:"hos_violation" enums:"hos_warning,hos_violation,route_assigned,route_completed,dvir_defects,dvir_critical,log_edit_request,log_edit_resolved,uncertified_log,unidentified_driving,eld_disconnected,eld_malfunction,maintenance_upcoming,maintenance_overdue,chat_message,subscription_expiring"`
	Title      string     `json:"title" example:"11-hour driving limit exceeded"`
	Body       string     `json:"body" example:"Driver John Doe exceeded the 11 hour driving limit at 18:05Z."`
	EntityType string     `json:"entity_type" example:"violations"`
	EntityID   string     `json:"entity_id" example:"1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34"`
	Channels   []string   `json:"channels" example:"push,email,in_app"`
	Read       bool       `json:"read" example:"false"`
	ReadAt     *time.Time `json:"read_at" format:"date-time" example:"2026-09-06T18:22:00Z"`
	SentAt     *time.Time `json:"sent_at" format:"date-time" example:"2026-09-06T18:05:00Z"`
	CreatedAt  time.Time  `json:"created_at" format:"date-time" example:"2026-09-06T18:05:00Z"`
}

// NotificationEnvelope wraps a single notification.
type NotificationEnvelope struct {
	Data Notification `json:"data"`
}

// NotificationListEnvelope wraps a page of notifications plus the unread
// counter the mobile badge needs.
type NotificationListEnvelope struct {
	Data []Notification `json:"data"`
	Meta ListMeta       `json:"meta"`
}

// ListMeta is the pagination metadata extended with the unread total.
type ListMeta struct {
	Page    int   `json:"page" example:"1"`
	PerPage int   `json:"per_page" example:"25"`
	Total   int64 `json:"total" example:"123"`
	Unread  int64 `json:"unread" example:"4"`
}

// ReadResult is returned by the read endpoints.
type ReadResult struct {
	Updated int64 `json:"updated" example:"7"`
	Unread  int64 `json:"unread" example:"0"`
}

// ReadResultEnvelope wraps a read acknowledgement.
type ReadResultEnvelope struct {
	Data ReadResult `json:"data"`
}

// PushTokenCreate registers (or refreshes) one device push token.
type PushTokenCreate struct {
	DeviceID   string `json:"device_id" example:"9f8b7c6d-1122-3344-5566-778899aabbcc" validate:"required,max=128"`
	Platform   string `json:"platform" example:"android" enums:"android,ios,web" validate:"required,oneof=android ios web"`
	Token      string `json:"token" example:"fcm-registration-token" validate:"required,max=4096"`
	AppVersion string `json:"app_version" example:"1.4.2" validate:"omitempty,max=32"`
}

// PushToken is the registration acknowledgement. The token itself is never
// echoed back.
type PushToken struct {
	DeviceID   string    `json:"device_id" example:"9f8b7c6d-1122-3344-5566-778899aabbcc"`
	Platform   string    `json:"platform" example:"android"`
	AppVersion string    `json:"app_version" example:"1.4.2"`
	LastSeenAt time.Time `json:"last_seen_at" format:"date-time" example:"2026-09-06T18:05:00Z"`
}

// PushTokenEnvelope wraps a push token registration.
type PushTokenEnvelope struct {
	Data PushToken `json:"data"`
}
