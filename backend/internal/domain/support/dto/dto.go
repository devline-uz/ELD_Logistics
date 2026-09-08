// Package dto holds the support module request and response payloads: support
// tickets, their thread messages and the driver feedback form (TZ A§15 Q77-Q80).
// sqlc models never leave the repository layer; everything a client sees is
// defined here and carries an example tag for the generated Swagger document.
package dto

import (
	"time"

	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared envelopes re-exported so swagger annotations can reference dto.X.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// MessageResponse is a generic acknowledgement payload.
	MessageResponse = shared.MessageResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
)

// Ticket lifecycle (Q77): a ticket opens as `new`, an admin moves it to
// `in_progress` and finally to `resolved`. `closed` is the legacy terminal
// state kept for rows created before stage 8.
const (
	StatusNew        = "new"
	StatusInProgress = "in_progress"
	StatusResolved   = "resolved"
	StatusClosed     = "closed"
)

// MaxAttachments is the per ticket / per message attachment budget (Q77).
const MaxAttachments = 3

// MaxMessageLength caps one thread message.
const MaxMessageLength = 4000

// Ticket is one support request of the company.
type Ticket struct {
	ID string `json:"id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	// DriverID is set when the ticket was filed from the driver app.
	DriverID   *string `json:"driver_id" example:"2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f"`
	DriverName string  `json:"driver_name" example:"John Miller"`
	// CreatedBy is the user that filed the ticket.
	CreatedBy   *string `json:"created_by" example:"8d3e2f1a-4b5c-4d6e-9f70-1a2b3c4d5e6f"`
	CreatorName string  `json:"creator_name" example:"Anna Ross"`
	Subject     string  `json:"subject" example:"ELD device keeps disconnecting"`
	Description string  `json:"description" example:"The device drops the Bluetooth link every few minutes."`
	// ContactOn is the channel the reporter wants an answer on (Q78).
	ContactOn string `json:"contact_on" example:"email"`
	Status    string `json:"status" example:"new" enums:"new,in_progress,resolved,closed"`
	// Attachments are storage file keys, at most three (Q77).
	Attachments  []string   `json:"attachments" example:"3f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8/chat/2026/09/photo-1.jpg"`
	MessageCount int64      `json:"message_count" example:"3"`
	ResolvedAt   *time.Time `json:"resolved_at" format:"date-time" example:"2026-09-07T11:30:00Z"`
	CreatedAt    time.Time  `json:"created_at" format:"date-time" example:"2026-09-06T09:12:00Z"`
	UpdatedAt    time.Time  `json:"updated_at" format:"date-time" example:"2026-09-07T11:30:00Z"`
}

// TicketCreate is the POST /support-tickets payload. Q77 — subject is
// mandatory, everything else is optional; at most three attachments.
type TicketCreate struct {
	Subject     string `json:"subject" example:"ELD device keeps disconnecting" validate:"required,max=200"`
	Description string `json:"description" example:"The device drops the Bluetooth link every few minutes." validate:"max=4000"`
	// ContactOn is the answer channel the reporter picked (Q78).
	ContactOn string `json:"contact_on" example:"email" enums:"email,phone,sms,in_app" validate:"omitempty,oneof=email phone sms in_app"`
	// Attachments are storage file keys returned by POST /files/presign, max
	// three. A key of another company is rejected (422).
	Attachments []string `json:"attachments" example:"3f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8/chat/2026/09/photo-1.jpg" validate:"max=3,dive,required,max=512"`
}

// TicketStatusUpdate is the PATCH /support-tickets/{id}/status payload.
type TicketStatusUpdate struct {
	Status string `json:"status" example:"in_progress" enums:"new,in_progress,resolved" validate:"required,oneof=new in_progress resolved"`
}

// TicketMessage is one entry of the ticket thread (Q77 [SHOULD]).
type TicketMessage struct {
	ID          string    `json:"id" example:"3c9a1f2e-5d4b-4a6c-8e1f-0d2b3a4c5e6f"`
	TicketID    string    `json:"ticket_id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
	SenderID    string    `json:"sender_id" example:"8d3e2f1a-4b5c-4d6e-9f70-1a2b3c4d5e6f"`
	SenderName  string    `json:"sender_name" example:"Anna Ross"`
	Text        string    `json:"text" example:"We shipped a replacement cable today."`
	Attachments []string  `json:"attachments" example:"3f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8/chat/2026/09/reply-1.pdf"`
	CreatedAt   time.Time `json:"created_at" format:"date-time" example:"2026-09-07T11:30:00Z"`
}

// TicketMessageCreate is the POST /support-tickets/{id}/messages payload.
type TicketMessageCreate struct {
	Text        string   `json:"text" example:"We shipped a replacement cable today." validate:"required,max=4000"`
	Attachments []string `json:"attachments" example:"3f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8/chat/2026/09/reply-1.pdf" validate:"max=3,dive,required,max=512"`
}

// Feedback is one driver app rating (Q80). Feedback gets no reply.
type Feedback struct {
	ID         string  `json:"id" example:"1a2b3c4d-5e6f-4708-8192-a3b4c5d6e7f8"`
	DriverID   *string `json:"driver_id" example:"2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f"`
	DriverName string  `json:"driver_name" example:"John Miller"`
	// AppRating is 1..5 stars, null when the driver only left a comment.
	AppRating   *int16    `json:"app_rating" example:"4"`
	Text        string    `json:"text" example:"The log screen is much faster now."`
	SubmittedAt time.Time `json:"submitted_at" format:"date-time" example:"2026-09-06T18:40:00Z"`
}

// FeedbackCreate is the POST /feedback payload. Q80 — the driver sends a star
// rating, a free text note, or both; the endpoint never answers back.
type FeedbackCreate struct {
	AppRating *int16 `json:"app_rating" example:"4" validate:"omitempty,min=1,max=5"`
	Text      string `json:"text" example:"The log screen is much faster now." validate:"max=2000"`
}

// Response envelopes.
type (
	// TicketEnvelope wraps a single ticket.
	TicketEnvelope struct {
		Data Ticket `json:"data"`
	}
	// TicketListEnvelope wraps a page of tickets.
	TicketListEnvelope struct {
		Data []Ticket `json:"data"`
		Meta Meta     `json:"meta"`
	}
	// TicketMessageEnvelope wraps a single thread message.
	TicketMessageEnvelope struct {
		Data TicketMessage `json:"data"`
	}
	// TicketMessageListEnvelope wraps a page of thread messages.
	TicketMessageListEnvelope struct {
		Data []TicketMessage `json:"data"`
		Meta Meta            `json:"meta"`
	}
	// FeedbackEnvelope wraps a single feedback entry.
	FeedbackEnvelope struct {
		Data Feedback `json:"data"`
	}
	// FeedbackListEnvelope wraps a page of feedback entries.
	FeedbackListEnvelope struct {
		Data []Feedback `json:"data"`
		Meta Meta       `json:"meta"`
	}
)
