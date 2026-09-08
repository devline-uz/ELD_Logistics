// Package dto holds the response envelopes shared by every domain package.
// Domain dto packages alias these types so swagger annotations can keep
// referring to dto.ErrorResponse / dto.Meta.
package dto

// FieldError describes one failed field level validation.
type FieldError struct {
	Field   string `json:"field" example:"unit_number"`
	Message string `json:"message" example:"required"`
}

// ErrorBody is the body of an error response.
type ErrorBody struct {
	Code    string       `json:"code" example:"VALIDATION_ERROR"`
	Message string       `json:"message" example:"validation failed"`
	Details []FieldError `json:"details,omitempty"`
}

// ErrorResponse is the single error envelope returned by every endpoint.
type ErrorResponse struct {
	Error ErrorBody `json:"error"`
}

// Meta carries pagination information for list responses.
type Meta struct {
	Page    int   `json:"page" example:"1"`
	PerPage int   `json:"per_page" example:"25"`
	Total   int64 `json:"total" example:"123"`
}

// MessageResponse is a generic acknowledgement payload.
type MessageResponse struct {
	Message string `json:"message" example:"ok"`
}

// IDResponse returns the identifier of a created or affected resource.
type IDResponse struct {
	ID string `json:"id" example:"6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f"`
}

// HealthResponse is returned by /health and /ready.
type HealthResponse struct {
	Status  string `json:"status" example:"ok"`
	Version string `json:"version" example:"1.0.0"`
	Region  string `json:"region" example:"us-east-1"`
}
