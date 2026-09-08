package middleware

import (
	"context"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/db"
)

// DefaultSubscriptionTTL is how long a resolved subscription state is reused.
// A minute is short enough that a renewal unfreezes the panel promptly and long
// enough to keep the hot write path free of an extra round trip.
const DefaultSubscriptionTTL = time.Minute

// PgSubscriptionSource reads `companies.subscription_status` through the pool
// and memoises the answer in the shared cache. It is the SubscriptionSource
// RequireWritableSubscription is wired with in production.
type PgSubscriptionSource struct {
	pool  *db.Pool
	store cache.Store
	ttl   time.Duration
}

// NewSubscriptionSource builds the cached source. store may be nil, in which
// case every call hits the database.
func NewSubscriptionSource(pool *db.Pool, store cache.Store, ttl time.Duration) *PgSubscriptionSource {
	if ttl <= 0 {
		ttl = DefaultSubscriptionTTL
	}
	return &PgSubscriptionSource{pool: pool, store: store, ttl: ttl}
}

// SubscriptionState implements SubscriptionSource.
func (s *PgSubscriptionSource) SubscriptionState(ctx context.Context, companyID uuid.UUID) (SubscriptionState, error) {
	if s == nil || s.pool == nil {
		return SubscriptionState{}, apierr.New(apierr.CodeUnavailable, 503, "the subscription state is unavailable")
	}
	key := subscriptionCacheKey(companyID)
	if s.store != nil {
		if raw, ok, err := s.store.Get(ctx, key); err == nil && ok {
			if state, ok := decodeSubscription(raw); ok {
				return state, nil
			}
		}
	}

	var row db.GetCompanySubscriptionRow
	err := s.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error {
		var err error
		row, err = db.New(tx).GetCompanySubscription(ctx, companyID)
		return err
	})
	if err != nil {
		return SubscriptionState{}, db.MapError(err, "company")
	}

	state := SubscriptionState{Status: row.SubscriptionStatus}
	if row.SubscriptionEndAt.Valid {
		end := row.SubscriptionEndAt.Time.UTC()
		state.EndAt = &end
	}
	if s.store != nil {
		_ = s.store.Set(ctx, key, encodeSubscription(state), s.ttl)
	}
	return state, nil
}

// Invalidate drops the memoised subscription state of one tenant. It must be
// called by every writer of `companies.subscription_status` /
// `subscription_end_at` — the company update handler, the billing webhook and
// the subscription expiry job — otherwise a renewal or a suspension only takes
// effect after DefaultSubscriptionTTL, which either keeps a paid tenant frozen
// or keeps writing open for a tenant that has just been suspended.
func (s *PgSubscriptionSource) Invalidate(ctx context.Context, companyID uuid.UUID) error {
	if s == nil || s.store == nil || companyID == uuid.Nil {
		return nil
	}
	return s.store.Del(ctx, subscriptionCacheKey(companyID))
}

// subscriptionCacheKey is the single place the cache key is built, so a reader
// and an invalidator can never drift apart.
func subscriptionCacheKey(companyID uuid.UUID) string {
	return "subscription:" + companyID.String()
}

// encodeSubscription serialises a state as `status|unix`, with an empty second
// field for an open ended subscription.
func encodeSubscription(s SubscriptionState) string {
	if s.EndAt == nil {
		return s.Status + "|"
	}
	return s.Status + "|" + strconv.FormatInt(s.EndAt.UTC().Unix(), 10)
}

func decodeSubscription(raw string) (SubscriptionState, bool) {
	status, end, ok := strings.Cut(raw, "|")
	if !ok || status == "" {
		return SubscriptionState{}, false
	}
	state := SubscriptionState{Status: status}
	if end != "" {
		sec, err := strconv.ParseInt(end, 10, 64)
		if err != nil {
			return SubscriptionState{}, false
		}
		t := time.Unix(sec, 0).UTC()
		state.EndAt = &t
	}
	return state, true
}
