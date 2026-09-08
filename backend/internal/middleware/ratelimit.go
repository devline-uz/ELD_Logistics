package middleware

import (
	"net/http"
	"strconv"
	"time"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Rate limit policy (TZ B§3.2).
const (
	// LoginPerIPPerMinute caps login attempts per source address.
	LoginPerIPPerMinute = 5
	// LoginPerAccountPerHour caps login attempts per account.
	LoginPerAccountPerHour = 10
	// DefaultPerUserPerMinute is the global authenticated budget.
	DefaultPerUserPerMinute = 600
	// SyncPerDevicePerMinute caps offline sync traffic per device.
	SyncPerDevicePerMinute = 60
)

// RateLimitOptions configures one RateLimit instance.
type RateLimitOptions struct {
	// Name namespaces the counter so several limits can share a key function.
	Name string
	// Limit is the number of requests allowed inside Window.
	Limit int
	// Window is the fixed counting window.
	Window time.Duration
	// Key derives the bucket. Returning an empty string skips the limit.
	Key func(*http.Request) string
}

// RateLimit enforces a fixed window counter in the shared store. A store
// outage never blocks traffic: the limiter fails open and the deeper account
// level guards (users.locked_until) still apply.
func RateLimit(store cache.Store, opts RateLimitOptions) func(http.Handler) http.Handler {
	if opts.Window <= 0 {
		opts.Window = time.Minute
	}
	if opts.Limit <= 0 {
		opts.Limit = DefaultPerUserPerMinute
	}
	if opts.Key == nil {
		opts.Key = KeyByIP
	}
	if opts.Name == "" {
		opts.Name = "default"
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if store == nil {
				next.ServeHTTP(w, r)
				return
			}
			bucket := opts.Key(r)
			if bucket == "" {
				next.ServeHTTP(w, r)
				return
			}

			count, ttl, err := store.Incr(r.Context(), "rl:"+opts.Name+":"+bucket, opts.Window)
			if err != nil {
				next.ServeHTTP(w, r)
				return
			}

			remaining := opts.Limit - int(count)
			if remaining < 0 {
				remaining = 0
			}
			w.Header().Set("X-RateLimit-Limit", strconv.Itoa(opts.Limit))
			w.Header().Set("X-RateLimit-Remaining", strconv.Itoa(remaining))

			if int(count) > opts.Limit {
				retry := int(ttl.Seconds())
				if retry < 1 {
					retry = 1
				}
				w.Header().Set("Retry-After", strconv.Itoa(retry))
				httpx.WriteError(w, r, apierr.TooMany("rate limit exceeded, retry later"))
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

// KeyByIP buckets by client address.
func KeyByIP(r *http.Request) string {
	return "ip:" + httpx.ClientIP(r)
}

// KeyByUser buckets by authenticated user, falling back to the address for
// anonymous traffic.
func KeyByUser(r *http.Request) string {
	if p, ok := tenant.PrincipalFrom(r.Context()); ok {
		return "user:" + p.UserID.String()
	}
	return "ip:" + httpx.ClientIP(r)
}

// KeyByDevice buckets by session device, which is what /sync/* is limited on.
func KeyByDevice(r *http.Request) string {
	p, ok := tenant.PrincipalFrom(r.Context())
	if !ok {
		return "ip:" + httpx.ClientIP(r)
	}
	return "device:" + p.UserID.String() + ":" + p.SessionID.String()
}

// LoginRateLimit is the per-IP budget in front of POST /auth/login. perMinute
// comes from cfg.RateLimit.Login; a non-positive value falls back to the
// TZ B§3.2 default of LoginPerIPPerMinute.
func LoginRateLimit(store cache.Store, perMinute int) func(http.Handler) http.Handler {
	if perMinute <= 0 {
		perMinute = LoginPerIPPerMinute
	}
	return RateLimit(store, RateLimitOptions{
		Name: "login", Limit: perMinute, Window: time.Minute, Key: KeyByIP,
	})
}

// UserRateLimit is the global 600/min/user budget.
func UserRateLimit(store cache.Store, limit int) func(http.Handler) http.Handler {
	return RateLimit(store, RateLimitOptions{
		Name: "user", Limit: limit, Window: time.Minute, Key: KeyByUser,
	})
}

// SyncRateLimit is the 60/min/device budget for /sync/push and /sync/pull.
func SyncRateLimit(store cache.Store) func(http.Handler) http.Handler {
	return RateLimit(store, RateLimitOptions{
		Name: "sync", Limit: SyncPerDevicePerMinute, Window: time.Minute, Key: KeyByDevice,
	})
}
