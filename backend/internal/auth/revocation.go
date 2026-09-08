package auth

import (
	"context"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/cache"
)

// Revocations is the short lived deny list that closes the gap between a
// session being revoked and its already issued access token expiring. Entries
// only need to outlive one access token, so the TTL equals the access TTL.
type Revocations struct {
	store cache.Store
	ttl   time.Duration
}

// NewRevocations builds the deny list. A nil store disables it: access tokens
// then stay valid until they expire, which is the documented fallback.
func NewRevocations(store cache.Store, accessTTL time.Duration) *Revocations {
	if accessTTL <= 0 {
		accessTTL = DefaultAccessTTL
	}
	// Add the clock skew allowance so a token accepted at the edge of its
	// window still sees the revocation.
	return &Revocations{store: store, ttl: accessTTL + 2*allowedClockSkew}
}

func revokedKey(sessionID uuid.UUID) string { return "revoked:session:" + sessionID.String() }

// Revoke marks a session as revoked.
func (r *Revocations) Revoke(ctx context.Context, sessionIDs ...uuid.UUID) error {
	if r == nil || r.store == nil {
		return nil
	}
	for _, id := range sessionIDs {
		if id == uuid.Nil {
			continue
		}
		if err := r.store.Set(ctx, revokedKey(id), "1", r.ttl); err != nil {
			return err
		}
	}
	return nil
}

// Clear removes a revocation marker (session resumed after Leave Truck).
func (r *Revocations) Clear(ctx context.Context, sessionID uuid.UUID) error {
	if r == nil || r.store == nil || sessionID == uuid.Nil {
		return nil
	}
	return r.store.Del(ctx, revokedKey(sessionID))
}

// IsRevoked implements RevocationStore.
func (r *Revocations) IsRevoked(ctx context.Context, sessionID uuid.UUID) (bool, error) {
	if r == nil || r.store == nil || sessionID == uuid.Nil {
		return false, nil
	}
	_, ok, err := r.store.Get(ctx, revokedKey(sessionID))
	if err != nil {
		return false, err
	}
	return ok, nil
}
