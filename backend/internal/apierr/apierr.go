package apierr

import (
	"errors"
	"fmt"
	"net/http"
)

// FieldError describes one failed field level validation.
type FieldError struct {
	Field   string `json:"field" example:"unit_number"`
	Message string `json:"message" example:"required"`
}

// MsgMustBeUUID is the shared FieldError.Message for UUID path/body fields.
const MsgMustBeUUID = "must be a uuid"

// E is the canonical application error. Handlers return it and httpx.WriteError
// converts it into the wire format.
type E struct {
	Code       string
	HTTPStatus int
	Message    string
	Details    []FieldError
	Err        error
}

// Error implements error.
func (e *E) Error() string {
	if e == nil {
		return "<nil>"
	}
	if e.Err != nil {
		return fmt.Sprintf("%s: %s: %v", e.Code, e.Message, e.Err)
	}
	return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

// Unwrap exposes the wrapped cause for errors.Is / errors.As.
func (e *E) Unwrap() error {
	if e == nil {
		return nil
	}
	return e.Err
}

// Status returns the HTTP status, defaulting to 500.
func (e *E) Status() int {
	if e == nil || e.HTTPStatus == 0 {
		return http.StatusInternalServerError
	}
	return e.HTTPStatus
}

// WithDetails attaches field errors and returns the same error for chaining.
func (e *E) WithDetails(details ...FieldError) *E {
	e.Details = append(e.Details, details...)
	return e
}

// WithErr attaches an underlying cause and returns the same error for chaining.
func (e *E) WithErr(err error) *E {
	e.Err = err
	return e
}

// New builds an error with an explicit code and status.
func New(code string, status int, msg string) *E {
	return &E{Code: code, HTTPStatus: status, Message: msg}
}

// Wrap builds an error with an explicit code, status and underlying cause.
func Wrap(err error, code string, status int, msg string) *E {
	return &E{Code: code, HTTPStatus: status, Message: msg, Err: err}
}

// Validation returns 422 VALIDATION_ERROR.
func Validation(msg string, details ...FieldError) *E {
	if msg == "" {
		msg = "validation failed"
	}
	return &E{
		Code:       CodeValidationError,
		HTTPStatus: http.StatusUnprocessableEntity,
		Message:    msg,
		Details:    details,
	}
}

// BadRequest returns 400 BAD_REQUEST.
func BadRequest(msg string) *E {
	return New(CodeBadRequest, http.StatusBadRequest, orDefault(msg, "bad request"))
}

// NotFound returns 404 NOT_FOUND. Cross-tenant access MUST also map here.
func NotFound(resource string) *E {
	msg := "resource not found"
	if resource != "" {
		msg = resource + " not found"
	}
	return New(CodeNotFound, http.StatusNotFound, msg)
}

// Forbidden returns 403 FORBIDDEN.
func Forbidden(msg string) *E {
	return New(CodeForbidden, http.StatusForbidden, orDefault(msg, "forbidden"))
}

// Unauthorized returns 401 UNAUTHORIZED.
func Unauthorized(msg string) *E {
	return New(CodeUnauthorized, http.StatusUnauthorized, orDefault(msg, "authentication required"))
}

// Conflict returns 409 with the given code (defaults to CONFLICT).
func Conflict(code, msg string) *E {
	return New(orDefault(code, CodeConflict), http.StatusConflict, orDefault(msg, "conflict"))
}

// TooMany returns 429 RATE_LIMITED.
func TooMany(msg string) *E {
	return New(CodeRateLimited, http.StatusTooManyRequests, orDefault(msg, "too many requests"))
}

// Internal returns 500 INTERNAL_ERROR wrapping the cause. The cause is logged,
// never sent to the client.
func Internal(err error, msg string) *E {
	return Wrap(err, CodeInternal, http.StatusInternalServerError, orDefault(msg, "internal server error"))
}

// From extracts an *E from an error chain.
func From(err error) (*E, bool) {
	var e *E
	if errors.As(err, &e) {
		return e, true
	}
	return nil, false
}

// Is reports whether err carries the given API error code.
func Is(err error, code string) bool {
	e, ok := From(err)
	return ok && e.Code == code
}

func orDefault(v, def string) string {
	if v == "" {
		return def
	}
	return v
}
