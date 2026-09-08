package middleware

import (
	"bufio"
	"log/slog"
	"net"
	"net/http"
	"time"

	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

type statusWriter struct {
	http.ResponseWriter
	status int
	bytes  int
}

func (w *statusWriter) WriteHeader(code int) {
	if w.status == 0 {
		w.status = code
		w.ResponseWriter.WriteHeader(code)
	}
}

func (w *statusWriter) Write(b []byte) (int, error) {
	if w.status == 0 {
		w.status = http.StatusOK
	}
	n, err := w.ResponseWriter.Write(b)
	w.bytes += n
	return n, err
}

// Unwrap exposes the wrapped writer for http.ResponseController (flush, hijack).
func (w *statusWriter) Unwrap() http.ResponseWriter { return w.ResponseWriter }

// Hijack hands the raw connection to the caller. The WebSocket upgrade asserts
// http.Hijacker on the writer it is given, so Unwrap alone is not enough: the
// /ws handshake would answer 500 behind this middleware.
func (w *statusWriter) Hijack() (net.Conn, *bufio.ReadWriter, error) {
	h, ok := w.ResponseWriter.(http.Hijacker)
	if !ok {
		return nil, nil, http.ErrNotSupported
	}
	conn, rw, err := h.Hijack()
	if err == nil && w.status == 0 {
		w.status = http.StatusSwitchingProtocols
	}
	return conn, rw, err
}

// Flush keeps streaming responses working through the logger.
func (w *statusWriter) Flush() {
	if f, ok := w.ResponseWriter.(http.Flusher); ok {
		f.Flush()
	}
}

// RequestLogger emits one structured JSON line per request. PII is masked; no
// request or response body is ever logged.
func RequestLogger(log *slog.Logger) func(http.Handler) http.Handler {
	if log == nil {
		log = slog.Default()
	}
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			sw := &statusWriter{ResponseWriter: w}

			next.ServeHTTP(sw, r)

			if sw.status == 0 {
				sw.status = http.StatusOK
			}
			ctx := r.Context()
			attrs := []any{
				"request_id", httpx.RequestIDFrom(ctx),
				"method", r.Method,
				"path", httpx.MaskPath(r.URL.Path),
				"query", httpx.MaskQuery(r.URL.RawQuery),
				"status", sw.status,
				"dur_ms", time.Since(start).Milliseconds(),
				"bytes", sw.bytes,
				"ip", httpx.ClientIP(r),
			}
			if p, ok := tenant.PrincipalFrom(ctx); ok {
				attrs = append(attrs, "user_id", p.UserID.String())
				if p.CompanyID != nil {
					attrs = append(attrs, "company_id", p.CompanyID.String())
				}
				attrs = append(attrs, "device_type", p.DeviceType)
			}

			switch {
			case sw.status >= http.StatusInternalServerError:
				log.ErrorContext(ctx, "http request", attrs...)
			case sw.status >= http.StatusBadRequest:
				log.WarnContext(ctx, "http request", attrs...)
			default:
				log.InfoContext(ctx, "http request", attrs...)
			}
		})
	}
}
