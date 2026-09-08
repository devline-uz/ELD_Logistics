// Package cache is the thin key/value abstraction shared by the security layer:
// the role permission cache, the session revocation list, rate limit counters
// and idempotency records. Redis backs it in production; the in memory
// implementation keeps unit tests free of infrastructure.
package cache

import (
	"context"
	"errors"
	"time"
)

// ErrClosed is returned once a store has been shut down.
var ErrClosed = errors.New("cache: store is closed")

// Store is the minimal key/value surface the security layer needs.
type Store interface {
	// Get returns the value and whether the key exists.
	Get(ctx context.Context, key string) (string, bool, error)
	// Set writes a value with an expiry (ttl <= 0 means no expiry).
	Set(ctx context.Context, key, value string, ttl time.Duration) error
	// SetNX writes only when the key is absent and reports whether it won.
	SetNX(ctx context.Context, key, value string, ttl time.Duration) (bool, error)
	// Incr increments a counter, applying ttl on creation, and returns the new
	// value together with the remaining window.
	Incr(ctx context.Context, key string, ttl time.Duration) (int64, time.Duration, error)
	// Del removes keys.
	Del(ctx context.Context, keys ...string) error
}
