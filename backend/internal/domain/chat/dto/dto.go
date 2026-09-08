// Package dto holds the chat payloads (TZ §15.4): a strictly 1:1 conversation
// between the company office and one driver. The driver side sees a single
// "Dispatch" thread; the admin side sees one thread per driver.
//
// Attachments are referenced by the object storage `file_key` returned by
// POST /files/presign — the chat endpoints never carry binary data.
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

// Message kinds accepted by the chat.
const (
	KindText     = "text"
	KindImage    = "image"
	KindFile     = "file"
	KindLocation = "location"
)

// Delivery states of one message (TZ §15.4).
const (
	StatusSent      = "sent"
	StatusDelivered = "delivered"
	StatusRead      = "read"
)

// Sender sides.
const (
	SideDriver = "driver"
	SideOffice = "office"
)

// MaxTextLen is the message length limit of TZ §15.4.
const MaxTextLen = 2000

// Message is one chat message.
type Message struct {
	ID          string     `json:"id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	DriverID    string     `json:"driver_id" example:"1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34"`
	SenderID    string     `json:"sender_id" example:"3a2b1c0d-9e8f-4a5b-8c7d-6e5f4a3b2c1d"`
	SenderSide  string     `json:"sender_side" example:"office" enums:"driver,office"`
	Kind        string     `json:"kind" example:"text" enums:"text,image,file,location"`
	Text        string     `json:"text" example:"Please head to dock 4 after your break."`
	FileKey     string     `json:"file_key" example:"chat/2026/09/6f1a1a5e.pdf"`
	Lat         *float64   `json:"lat" example:"31.5204"`
	Lng         *float64   `json:"lng" example:"74.3587"`
	Status      string     `json:"status" example:"delivered" enums:"sent,delivered,read"`
	SentAt      time.Time  `json:"sent_at" format:"date-time" example:"2026-09-06T18:05:00Z"`
	DeliveredAt *time.Time `json:"delivered_at" format:"date-time" example:"2026-09-06T18:05:04Z"`
	ReadAt      *time.Time `json:"read_at" format:"date-time" example:"2026-09-06T18:07:11Z"`
}

// Thread is one conversation entry of the admin side list.
type Thread struct {
	DriverID     string   `json:"driver_id" example:"1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34"`
	DriverName   string   `json:"driver_name" example:"John Doe"`
	DriverStatus string   `json:"driver_status" example:"active" enums:"active,inactive"`
	UnreadCount  int64    `json:"unread_count" example:"3"`
	LastMessage  *Message `json:"last_message"`
}

// ThreadListEnvelope wraps a page of threads.
type ThreadListEnvelope struct {
	Data []Thread `json:"data"`
	Meta Meta     `json:"meta"`
}

// CursorMeta is the cursor pagination metadata of the message history.
type CursorMeta struct {
	// PerPage is the requested page size.
	PerPage int `json:"per_page" example:"50"`
	// HasMore reports whether older messages exist.
	HasMore bool `json:"has_more" example:"true"`
	// NextBefore is the cursor to pass as ?before for the next (older) page.
	NextBefore *time.Time `json:"next_before" format:"date-time" example:"2026-09-06T17:40:00Z"`
	// Unread is the number of unread messages the caller has in this thread.
	Unread int64 `json:"unread" example:"2"`
}

// MessageListEnvelope wraps a cursor page of messages, newest first.
type MessageListEnvelope struct {
	Data []Message  `json:"data"`
	Meta CursorMeta `json:"meta"`
}

// MessageEnvelope wraps a single message.
type MessageEnvelope struct {
	Data Message `json:"data"`
}

// MessageCreate is the POST body of a new chat message.
type MessageCreate struct {
	Kind string `json:"kind" example:"text" enums:"text,image,file,location" validate:"required,oneof=text image file location"`
	// Text is required for a text message and optional as a caption otherwise.
	Text string `json:"text" example:"Please head to dock 4 after your break." validate:"omitempty,max=2000"`
	// FileKey is the storage key returned by POST /files/presign; required for
	// image and file messages.
	FileKey string `json:"file_key" example:"chat/2026/09/6f1a1a5e.pdf" validate:"omitempty,max=512"`
	// Lat and Lng are required for a location message.
	Lat *float64 `json:"lat" example:"31.5204" validate:"omitempty,gte=-90,lte=90"`
	Lng *float64 `json:"lng" example:"74.3587" validate:"omitempty,gte=-180,lte=180"`
}

// ReadResult acknowledges a read receipt.
type ReadResult struct {
	Updated int64 `json:"updated" example:"1"`
	Unread  int64 `json:"unread" example:"0"`
}

// ReadResultEnvelope wraps a read acknowledgement.
type ReadResultEnvelope struct {
	Data ReadResult `json:"data"`
}
