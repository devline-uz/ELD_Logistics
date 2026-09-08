package auth

import (
	"context"
	"net/http"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/cache"
)

// Brute force policy (TZ B§3.2).
const (
	// LoginMaxPerIPPerMinute caps login attempts from one address.
	LoginMaxPerIPPerMinute = 5
	// LoginMaxPerAccountPerHour caps login attempts against one account.
	LoginMaxPerAccountPerHour = 10
	// LockoutDuration is how long users.locked_until blocks an account.
	LockoutDuration = 15 * time.Minute
	// PINMaxAttempts caps consecutive PIN failures.
	PINMaxAttempts = 5
	// PINAttemptWindow is the PIN failure counting window.
	PINAttemptWindow = 15 * time.Minute
)

// Guard counts authentication failures in Redis. It complements the persistent
// users.failed_logins / users.locked_until columns: the counter catches
// distributed guessing before the row level lockout kicks in.
type Guard struct {
	store             cache.Store
	perIPPerMinute    int
	perAccountPerHour int
	pinAttempts       int
	lockout           time.Duration
}

// GuardOptions tunes the Guard; zero values fall back to the policy defaults.
type GuardOptions struct {
	PerIPPerMinute    int
	PerAccountPerHour int
	PINAttempts       int
	Lockout           time.Duration
}

// NewGuard builds the brute force guard.
func NewGuard(store cache.Store, opts GuardOptions) *Guard {
	g := &Guard{
		store:             store,
		perIPPerMinute:    orInt(opts.PerIPPerMinute, LoginMaxPerIPPerMinute),
		perAccountPerHour: orInt(opts.PerAccountPerHour, LoginMaxPerAccountPerHour),
		pinAttempts:       orInt(opts.PINAttempts, PINMaxAttempts),
		lockout:           LockoutDuration,
	}
	if opts.Lockout > 0 {
		g.lockout = opts.Lockout
	}
	return g
}

// LockoutDuration returns the configured lockout window.
func (g *Guard) LockoutDuration() time.Duration {
	if g == nil || g.lockout <= 0 {
		return LockoutDuration
	}
	return g.lockout
}

// MaxAccountFailures returns the per account failure threshold.
func (g *Guard) MaxAccountFailures() int {
	if g == nil || g.perAccountPerHour <= 0 {
		return LoginMaxPerAccountPerHour
	}
	return g.perAccountPerHour
}

// CheckIP enforces the per address login budget. It counts the attempt, so it
// must be called exactly once per login request.
func (g *Guard) CheckIP(ctx context.Context, ip string) error {
	if g == nil || g.store == nil || ip == "" {
		return nil
	}
	n, ttl, err := g.store.Incr(ctx, "login:ip:"+ip, time.Minute)
	if err != nil {
		return nil //nolint:nilerr // never fail closed on a cache outage; the account limit still applies
	}
	if int(n) > g.perIPPerMinute {
		return rateLimited("too many login attempts from this address", ttl)
	}
	return nil
}

// CheckAccount enforces the per account hourly budget without counting.
func (g *Guard) CheckAccount(ctx context.Context, userID uuid.UUID) error {
	if g == nil || g.store == nil || userID == uuid.Nil {
		return nil
	}
	raw, ok, err := g.store.Get(ctx, "login:acct:"+userID.String())
	if err != nil || !ok {
		return nil //nolint:nilerr // never fail closed on a cache outage; treat as "no recorded failures"
	}
	n := int64(0)
	for _, c := range raw {
		if c < '0' || c > '9' {
			return nil
		}
		n = n*10 + int64(c-'0')
	}
	if int(n) >= g.perAccountPerHour {
		return lockedOut(g.LockoutDuration())
	}
	return nil
}

// RecordAccountFailure counts one failed attempt and reports whether the
// account budget is now exhausted.
func (g *Guard) RecordAccountFailure(ctx context.Context, userID uuid.UUID) (int, bool) {
	if g == nil || g.store == nil || userID == uuid.Nil {
		return 0, false
	}
	n, _, err := g.store.Incr(ctx, "login:acct:"+userID.String(), time.Hour)
	if err != nil {
		return 0, false
	}
	return int(n), int(n) >= g.perAccountPerHour
}

// ResetAccount clears the failure counter after a successful login.
func (g *Guard) ResetAccount(ctx context.Context, userID uuid.UUID) {
	if g == nil || g.store == nil || userID == uuid.Nil {
		return
	}
	_ = g.store.Del(ctx, "login:acct:"+userID.String())
}

// CheckPIN enforces the PIN attempt budget without counting.
func (g *Guard) CheckPIN(ctx context.Context, userID uuid.UUID) error {
	if g == nil || g.store == nil || userID == uuid.Nil {
		return nil
	}
	raw, ok, err := g.store.Get(ctx, "pin:fail:"+userID.String())
	if err != nil || !ok {
		return nil //nolint:nilerr // never fail closed on a cache outage; treat as "no recorded failures"
	}
	n := int64(0)
	for _, c := range raw {
		if c < '0' || c > '9' {
			return nil
		}
		n = n*10 + int64(c-'0')
	}
	if int(n) >= g.pinAttempts {
		return apierr.New(apierr.CodePINLocked, http.StatusTooManyRequests,
			"too many failed PIN attempts, sign in with your password")
	}
	return nil
}

// RecordPINFailure counts one failed PIN attempt.
func (g *Guard) RecordPINFailure(ctx context.Context, userID uuid.UUID) int {
	if g == nil || g.store == nil || userID == uuid.Nil {
		return 0
	}
	n, _, err := g.store.Incr(ctx, "pin:fail:"+userID.String(), PINAttemptWindow)
	if err != nil {
		return 0
	}
	return int(n)
}

// ResetPIN clears the PIN failure counter.
func (g *Guard) ResetPIN(ctx context.Context, userID uuid.UUID) {
	if g == nil || g.store == nil || userID == uuid.Nil {
		return
	}
	_ = g.store.Del(ctx, "pin:fail:"+userID.String())
}

func rateLimited(msg string, retryAfter time.Duration) *apierr.E {
	e := apierr.TooMany(msg)
	if retryAfter > 0 {
		e.Details = append(e.Details, apierr.FieldError{
			Field:   "retry_after_seconds",
			Message: durationSeconds(retryAfter),
		})
	}
	return e
}

func lockedOut(d time.Duration) *apierr.E {
	return apierr.New(apierr.CodeLockedOut, http.StatusTooManyRequests,
		"account temporarily locked after repeated failed sign in attempts").
		WithDetails(apierr.FieldError{Field: "retry_after_seconds", Message: durationSeconds(d)})
}

func durationSeconds(d time.Duration) string {
	secs := int64(d.Seconds())
	if secs < 1 {
		secs = 1
	}
	return formatInt64(secs)
}

func formatInt64(n int64) string {
	if n == 0 {
		return "0"
	}
	var buf [20]byte
	i := len(buf)
	for n > 0 {
		i--
		buf[i] = byte('0' + n%10)
		n /= 10
	}
	return string(buf[i:])
}

func orInt(v, def int) int {
	if v <= 0 {
		return def
	}
	return v
}
