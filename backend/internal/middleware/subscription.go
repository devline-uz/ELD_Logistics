package middleware

import (
	"context"
	"net/http"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/tenant"
)

// SubscriptionState is the writability snapshot of one tenant, read from
// `companies.subscription_status` / `subscription_end_at`.
type SubscriptionState struct {
	// Status is one of trial | active | grace | readonly.
	Status string
	// EndAt is the paid-through date, nil for an open ended tenant.
	EndAt *time.Time
}

// Subscription statuses of `companies.subscription_status`.
const (
	SubscriptionTrial    = "trial"
	SubscriptionActive   = "active"
	SubscriptionGrace    = "grace"
	SubscriptionReadonly = "readonly"
)

// Writable reports whether the admin panel may still write. TZ B§15: the paid
// period is followed by a seven day grace window; after that, and whenever the
// tenant was explicitly flipped to `readonly`, the admin panel is read only.
func (s SubscriptionState) Writable(now time.Time) bool {
	if s.Status == SubscriptionReadonly {
		return false
	}
	if s.EndAt == nil {
		return true
	}
	return now.UTC().Before(s.EndAt.UTC().Add(core.SubscriptionGrace))
}

// SubscriptionSource resolves the subscription state of a tenant. The
// implementation is expected to cache: this runs on every admin write.
type SubscriptionSource interface {
	SubscriptionState(ctx context.Context, companyID uuid.UUID) (SubscriptionState, error)
}

// SubscriptionSourceFunc adapts a function to SubscriptionSource.
type SubscriptionSourceFunc func(ctx context.Context, companyID uuid.UUID) (SubscriptionState, error)

// SubscriptionState implements SubscriptionSource.
func (f SubscriptionSourceFunc) SubscriptionState(ctx context.Context, companyID uuid.UUID) (SubscriptionState, error) {
	return f(ctx, companyID)
}

// WritableSubscriptionOption tunes RequireWritableSubscription.
type WritableSubscriptionOption func(*writableSubscription)

// WithSubscriptionClock injects the clock, for tests.
func WithSubscriptionClock(now func() time.Time) WritableSubscriptionOption {
	return func(w *writableSubscription) {
		if now != nil {
			w.now = now
		}
	}
}

type writableSubscription struct {
	src SubscriptionSource
	now func() time.Time
}

// RequireWritableSubscription answers 403 SUBSCRIPTION_READONLY to a mutating
// request of a tenant whose subscription lapsed (TZ B§15).
//
// Wiring rules — this middleware belongs on the *admin panel write routes only*:
//
//   - it must NOT be mounted on the driver application: HOS recording never
//     stops, compliance does not depend on billing. `/sync/*`,
//     `/daily-logs/{id}/certify` and the driver `POST /dvir-reports` are
//     explicitly exempt;
//   - as a second line of defence the middleware itself lets a `self` scoped
//     principal (the driver app) and a platform super admin through, so a
//     wiring mistake can never freeze a driver's log book;
//   - safe methods (GET, HEAD, OPTIONS) always pass: read only means read.
func RequireWritableSubscription(src SubscriptionSource, opts ...WritableSubscriptionOption) func(http.Handler) http.Handler {
	w := &writableSubscription{src: src, now: func() time.Time { return time.Now().UTC() }}
	for _, opt := range opts {
		opt(w)
	}
	return w.handler
}

func (ws *writableSubscription) handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !isMutating(r.Method) {
			next.ServeHTTP(w, r)
			return
		}
		p, ok := tenant.PrincipalFrom(r.Context())
		if !ok {
			httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
			return
		}
		// TZ B§15: the driver application keeps recording HOS whatever the
		// billing state says, and the platform owner must stay able to renew
		// the subscription of a frozen tenant.
		if p.IsSuperAdmin || p.Scope == tenant.ScopeSelf {
			next.ServeHTTP(w, r)
			return
		}
		companyID := tenant.CompanyID(r.Context())
		if companyID == uuid.Nil || ws.src == nil {
			// Fail closed on a misconfigured module rather than granting a
			// write nobody can attribute to a tenant.
			httpx.WriteError(w, r, apierr.New(apierr.CodeUnavailable, http.StatusServiceUnavailable,
				"the subscription state is unavailable"))
			return
		}

		state, err := ws.src.SubscriptionState(r.Context(), companyID)
		if err != nil {
			httpx.WriteError(w, r, err)
			return
		}
		if !state.Writable(ws.now()) {
			httpx.WriteError(w, r, apierr.New(apierr.CodeSubscriptionReadonly, http.StatusForbidden,
				"the company subscription lapsed: the admin panel is read only"))
			return
		}
		next.ServeHTTP(w, r)
	})
}

// isMutating reports whether the method changes state.
func isMutating(method string) bool {
	switch method {
	case http.MethodGet, http.MethodHead, http.MethodOptions:
		return false
	default:
		return true
	}
}
