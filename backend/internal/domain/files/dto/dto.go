// Package dto holds the wire contract of the file, import and export module.
package dto

import (
	"time"

	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared envelopes re-exported so swagger annotations can stay local.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
	// MessageResponse is a generic acknowledgement payload.
	MessageResponse = shared.MessageResponse
)

// PresignRequest asks for a short lived upload URL. The object key is always
// built by the server: a client supplied path is never trusted.
type PresignRequest struct {
	Kind        string `json:"kind" example:"dvir_photo" enums:"dvir_photo,invoice,signature,logo,chat,import" validate:"required"`
	ContentType string `json:"content_type" example:"image/jpeg" validate:"required,max=128"`
	// SizeBytes is the size the client is about to upload; it is checked
	// against the per-kind ceiling before a URL is issued and is then signed
	// into the URL as Content-Length, so the PUT must match it exactly.
	SizeBytes int64 `json:"size_bytes" example:"1048576" validate:"required,gt=0"`
	// Filename is optional and only contributes a sanitised file extension.
	Filename string `json:"filename,omitempty" example:"pre-trip-front.jpg" validate:"omitempty,max=255"`
}

// PresignResponse is the upload instruction. The server stores only `key`.
type PresignResponse struct {
	UploadURL string `json:"upload_url" example:"https://s3.example.com/onebook-eld/1f.../dvir_photo/2026/09/8c7....jpg?X-Amz-Signature=..."`
	Key       string `json:"key" example:"1f2e3d4c-5b6a-4978-8habc/dvir_photo/2026/09/8c7b6a59-4837-4261-95f4-e3d2c1b0a9f8.jpg"`
	// Method is always PUT.
	Method    string            `json:"method" example:"PUT"`
	ExpiresAt time.Time         `json:"expires_at" format:"date-time" example:"2026-09-06T12:15:00Z"`
	MaxBytes  int64             `json:"max_bytes" example:"5242880"`
	Headers   map[string]string `json:"headers" example:"Content-Type:image/jpeg"`
}

// ImportRowError names one rejected cell of an import file.
type ImportRowError struct {
	Row     int    `json:"row" example:"7"`
	Field   string `json:"field" example:"username"`
	Message string `json:"message" example:"must be 4-32 characters of [a-z0-9._]"`
}

// ImportResult is the report of a CSV/XLSX import. TZ §18.4 is all-or-nothing:
// when `errors` is not empty nothing at all was written and `imported` is 0.
type ImportResult struct {
	Imported int              `json:"imported" example:"120"`
	Total    int              `json:"total" example:"120"`
	Errors   []ImportRowError `json:"errors"`
}

// PresignEnvelope wraps a presigned upload instruction.
type PresignEnvelope struct {
	Data PresignResponse `json:"data"`
}

// ImportResultEnvelope wraps an import report. It is returned with 200 when
// every row was written and with 422 when the file was rejected as a whole.
type ImportResultEnvelope struct {
	Data ImportResult `json:"data"`
}
