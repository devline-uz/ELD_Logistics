// Package httpx contains the transport helpers shared by every HTTP handler:
// JSON writing, centralised error mapping, decoding+validation, pagination and
// PII masking.
package httpx

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/httpx/dto"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Re-exported shared envelopes so handlers only need one import.
type (
	// FieldError describes one failed field level validation.
	FieldError = dto.FieldError
	// ErrorBody is the body of an error response.
	ErrorBody = dto.ErrorBody
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = dto.ErrorResponse
	// Meta carries pagination information for list responses.
	Meta = dto.Meta
)

// Envelope wraps a single resource payload.
type Envelope struct {
	Data any `json:"data"`
}

// ListEnvelope wraps a collection payload plus pagination metadata.
type ListEnvelope struct {
	Data any  `json:"data"`
	Meta Meta `json:"meta"`
}

// WriteJSON writes v as JSON with the given status code.
func WriteJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	if v == nil || status == http.StatusNoContent {
		w.WriteHeader(status)
		return
	}
	buf, err := json.Marshal(v)
	if err != nil {
		slog.Error("json marshal failed", "error", err.Error())
		w.WriteHeader(http.StatusInternalServerError)
		_, _ = w.Write([]byte(`{"error":{"code":"INTERNAL_ERROR","message":"internal server error"}}`))
		return
	}
	w.WriteHeader(status)
	_, _ = w.Write(buf)
}

// WriteData writes a single resource envelope.
func WriteData(w http.ResponseWriter, status int, data any) {
	WriteJSON(w, status, Envelope{Data: data})
}

// WriteList writes a collection envelope with pagination metadata.
func WriteList(w http.ResponseWriter, data any, meta Meta) {
	WriteJSON(w, http.StatusOK, ListEnvelope{Data: data, Meta: meta})
}

// WriteNoContent writes 204.
func WriteNoContent(w http.ResponseWriter) {
	w.WriteHeader(http.StatusNoContent)
}

// WriteError maps err onto the canonical error envelope. Known apierr.E values
// are surfaced as-is; anything else becomes a 500 with a masked log entry and
// no internal detail leaked to the caller.
func WriteError(w http.ResponseWriter, r *http.Request, err error) {
	if err == nil {
		return
	}

	var e *apierr.E
	if !errors.As(err, &e) {
		e = apierr.Internal(err, "internal server error")
	}

	if e.Status() >= http.StatusInternalServerError {
		logError(r.Context(), r, e)
	}

	body := ErrorResponse{Error: ErrorBody{
		Code:    e.Code,
		Message: e.Message,
	}}
	if len(e.Details) > 0 {
		body.Error.Details = make([]FieldError, 0, len(e.Details))
		for _, d := range e.Details {
			body.Error.Details = append(body.Error.Details, FieldError{Field: d.Field, Message: d.Message})
		}
	}

	if e.Code == apierr.CodeRateLimited {
		w.Header().Set("Retry-After", "60")
	}
	WriteJSON(w, e.Status(), body)
}

func logError(ctx context.Context, r *http.Request, e *apierr.E) {
	attrs := []any{
		"code", e.Code,
		"status", e.Status(),
		"method", r.Method,
		"path", MaskPath(r.URL.Path),
		"request_id", RequestIDFrom(ctx),
	}
	if p, ok := tenant.PrincipalFrom(ctx); ok {
		attrs = append(attrs, "user_id", p.UserID.String())
		if p.CompanyID != nil {
			attrs = append(attrs, "company_id", p.CompanyID.String())
		}
	}
	if e.Err != nil {
		attrs = append(attrs, "error", MaskSecrets(e.Err.Error()))
	}
	slog.ErrorContext(ctx, "request failed", attrs...)
}

type reqIDKey struct{}

// WithRequestID stores the request id in the context.
func WithRequestID(ctx context.Context, id string) context.Context {
	return context.WithValue(ctx, reqIDKey{}, id)
}

// RequestIDFrom returns the request id stored in the context, if any.
func RequestIDFrom(ctx context.Context) string {
	if v, ok := ctx.Value(reqIDKey{}).(string); ok {
		return v
	}
	return ""
}
