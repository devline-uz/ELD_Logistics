package middleware

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/cache"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Idempotency policy (TZ B§3.2).
const (
	// HeaderIdempotencyKey carries the client supplied key.
	HeaderIdempotencyKey = "Idempotency-Key"
	// IdempotencyTTL is how long a recorded response is replayed.
	IdempotencyTTL = 24 * time.Hour
	// maxIdempotencyKeyLen bounds the header so it cannot bloat the store.
	maxIdempotencyKeyLen = 128
	// maxReplayBytes bounds the response body kept for replay.
	maxReplayBytes = 256 << 10
)

type idempotentRecord struct {
	Status int    `json:"status"`
	Body   string `json:"body"`
}

// captureWriter records the response so a repeated request can replay it.
type captureWriter struct {
	http.ResponseWriter
	status   int
	body     []byte
	overflow bool
}

func (w *captureWriter) WriteHeader(code int) {
	if w.status == 0 {
		w.status = code
	}
	w.ResponseWriter.WriteHeader(code)
}

func (w *captureWriter) Write(b []byte) (int, error) {
	if w.status == 0 {
		w.status = http.StatusOK
	}
	if !w.overflow {
		if len(w.body)+len(b) > maxReplayBytes {
			w.overflow = true
			w.body = nil
		} else {
			w.body = append(w.body, b...)
		}
	}
	return w.ResponseWriter.Write(b)
}

func (w *captureWriter) Unwrap() http.ResponseWriter { return w.ResponseWriter }

// Idempotency replays the recorded response of a previously seen
// Idempotency-Key for 24 hours. required makes the header mandatory, which is
// the case for POST /sync/push.
func Idempotency(store cache.Store, required bool) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if r.Method != http.MethodPost && r.Method != http.MethodPatch {
				next.ServeHTTP(w, r)
				return
			}

			key := r.Header.Get(HeaderIdempotencyKey)
			if len(key) > maxIdempotencyKeyLen {
				httpx.WriteError(w, r, apierr.BadRequest("Idempotency-Key is too long"))
				return
			}
			if key == "" {
				if required {
					httpx.WriteError(w, r, apierr.BadRequest("Idempotency-Key header is required"))
					return
				}
				next.ServeHTTP(w, r)
				return
			}
			if store == nil {
				next.ServeHTTP(w, r)
				return
			}

			// The key is scoped to the caller and the route so two tenants can
			// never observe each other's recorded responses.
			owner := "anon:" + httpx.ClientIP(r)
			if p, ok := tenant.PrincipalFrom(r.Context()); ok {
				owner = p.UserID.String()
			}
			storeKey := "idem:" + appcrypto.HashSHA256(owner+"|"+r.Method+"|"+r.URL.Path+"|"+key)

			if raw, found, err := store.Get(r.Context(), storeKey); err == nil && found {
				var rec idempotentRecord
				if json.Unmarshal([]byte(raw), &rec) == nil && rec.Status != 0 {
					w.Header().Set("Content-Type", "application/json; charset=utf-8")
					w.Header().Set("Idempotent-Replay", "true")
					w.WriteHeader(rec.Status)
					_, _ = w.Write([]byte(rec.Body))
					return
				}
				httpx.WriteError(w, r, apierr.Conflict(apierr.CodeIdempotencyConflict,
					"a request with this Idempotency-Key is still in flight"))
				return
			}

			if ok, err := store.SetNX(r.Context(), storeKey, "", IdempotencyTTL); err == nil && !ok {
				httpx.WriteError(w, r, apierr.Conflict(apierr.CodeIdempotencyConflict,
					"a request with this Idempotency-Key is still in flight"))
				return
			}

			cw := &captureWriter{ResponseWriter: w}
			next.ServeHTTP(cw, r)

			// Only successful responses are replayable; a failure must be
			// retryable with the same key.
			if cw.status >= 200 && cw.status < 300 && !cw.overflow {
				if buf, err := json.Marshal(idempotentRecord{Status: cw.status, Body: string(cw.body)}); err == nil {
					_ = store.Set(r.Context(), storeKey, string(buf), IdempotencyTTL)
					return
				}
			}
			_ = store.Del(r.Context(), storeKey)
		})
	}
}
