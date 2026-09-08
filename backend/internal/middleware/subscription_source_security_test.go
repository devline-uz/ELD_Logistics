package middleware

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/cache"
)

// The subscription state is memoised for DefaultSubscriptionTTL, so a status
// change is invisible to RequireWritableSubscription for up to a minute. That
// cuts both ways: a suspended tenant keeps writing, and a renewed tenant stays
// frozen. Invalidate is the escape hatch every writer of
// companies.subscription_status must call.
func TestInvalidateDropsTheMemoisedState(t *testing.T) {
	t.Parallel()
	store := cache.NewMemoryStore()
	companyID := uuid.New()
	key := subscriptionCacheKey(companyID)

	require.NoError(t, store.Set(context.Background(), key,
		encodeSubscription(SubscriptionState{Status: SubscriptionActive}), time.Minute))
	_, ok, err := store.Get(context.Background(), key)
	require.NoError(t, err)
	require.True(t, ok)

	src := NewSubscriptionSource(nil, store, 0)
	require.NoError(t, src.Invalidate(context.Background(), companyID))

	_, ok, err = store.Get(context.Background(), key)
	require.NoError(t, err)
	require.False(t, ok, "a suspension must take effect at once, not after the TTL")
}

func TestInvalidateIsSafeWithoutACacheOrACompany(t *testing.T) {
	t.Parallel()
	// No cache store: every read already hits the database, nothing to drop.
	require.NoError(t, NewSubscriptionSource(nil, nil, 0).
		Invalidate(context.Background(), uuid.New()))
	// A nil company id is never a cache key; it must not delete a wildcard.
	require.NoError(t, NewSubscriptionSource(nil, cache.NewMemoryStore(), 0).
		Invalidate(context.Background(), uuid.Nil))

	var nilSrc *PgSubscriptionSource
	require.NoError(t, nilSrc.Invalidate(context.Background(), uuid.New()))
}

func TestSubscriptionCacheKeyIsTenantScoped(t *testing.T) {
	t.Parallel()
	a, b := uuid.New(), uuid.New()
	require.NotEqual(t, subscriptionCacheKey(a), subscriptionCacheKey(b))
	require.Contains(t, subscriptionCacheKey(a), a.String())
}
