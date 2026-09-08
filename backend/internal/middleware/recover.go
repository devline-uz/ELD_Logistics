package middleware

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"runtime/debug"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/httpx"
)

// Recover converts a panic into a 500 response and logs the stack trace.
// http.ErrAbortHandler is re-raised so the server can close the connection.
func Recover(log *slog.Logger) func(http.Handler) http.Handler {
	if log == nil {
		log = slog.Default()
	}
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := r.Context()
			defer func(ctx context.Context) {
				rec := recover()
				if rec == nil {
					return
				}
				if rerr, ok := rec.(error); ok && errors.Is(rerr, http.ErrAbortHandler) {
					panic(rec)
				}
				err := fmt.Errorf("panic: %v", rec)
				log.ErrorContext(ctx, "panic recovered",
					"request_id", httpx.RequestIDFrom(ctx),
					"method", r.Method,
					"path", httpx.MaskPath(r.URL.Path),
					"error", httpx.MaskSecrets(err.Error()),
					"stack", string(debug.Stack()),
				)
				httpx.WriteError(w, r, apierr.Internal(err, "internal server error"))
			}(ctx)
			next.ServeHTTP(w, r)
		})
	}
}
