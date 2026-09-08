package auth

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/tenant"
)

func TestGuardEnforcesPerIPBudget(t *testing.T) {
	ctx := context.Background()
	g := NewGuard(cache.NewMemoryStore(), GuardOptions{})

	for i := 0; i < LoginMaxPerIPPerMinute; i++ {
		require.NoError(t, g.CheckIP(ctx, "203.0.113.7"), "attempt %d must pass", i+1)
	}
	err := g.CheckIP(ctx, "203.0.113.7")
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeRateLimited))

	// Another address keeps its own budget.
	require.NoError(t, g.CheckIP(ctx, "198.51.100.4"))
}

func TestGuardWindowExpires(t *testing.T) {
	ctx := context.Background()
	store := cache.NewMemoryStore()
	now := time.Now()
	store.SetClock(func() time.Time { return now })
	g := NewGuard(store, GuardOptions{})

	for i := 0; i < LoginMaxPerIPPerMinute; i++ {
		require.NoError(t, g.CheckIP(ctx, "203.0.113.7"))
	}
	require.Error(t, g.CheckIP(ctx, "203.0.113.7"))

	now = now.Add(2 * time.Minute)
	require.NoError(t, g.CheckIP(ctx, "203.0.113.7"), "the fixed window must reset")
}

func TestGuardLocksAccountAfterHourlyBudget(t *testing.T) {
	ctx := context.Background()
	g := NewGuard(cache.NewMemoryStore(), GuardOptions{})
	userID := uuid.New()

	require.NoError(t, g.CheckAccount(ctx, userID))
	for i := 1; i < LoginMaxPerAccountPerHour; i++ {
		_, locked := g.RecordAccountFailure(ctx, userID)
		require.False(t, locked, "failure %d must not lock yet", i)
		require.NoError(t, g.CheckAccount(ctx, userID))
	}

	_, locked := g.RecordAccountFailure(ctx, userID)
	require.True(t, locked, "the 10th failure within an hour must lock the account")

	err := g.CheckAccount(ctx, userID)
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeLockedOut))

	// A successful sign in clears the counter.
	g.ResetAccount(ctx, userID)
	require.NoError(t, g.CheckAccount(ctx, userID))

	// Another account is unaffected.
	require.NoError(t, g.CheckAccount(ctx, uuid.New()))
}

func TestGuardLocksPINAfterRepeatedFailures(t *testing.T) {
	ctx := context.Background()
	g := NewGuard(cache.NewMemoryStore(), GuardOptions{})
	userID := uuid.New()

	for i := 0; i < PINMaxAttempts; i++ {
		require.NoError(t, g.CheckPIN(ctx, userID))
		g.RecordPINFailure(ctx, userID)
	}
	err := g.CheckPIN(ctx, userID)
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodePINLocked))

	g.ResetPIN(ctx, userID)
	require.NoError(t, g.CheckPIN(ctx, userID))
}

func TestGuardFailsOpenWithoutStore(t *testing.T) {
	ctx := context.Background()
	var g *Guard
	require.NoError(t, g.CheckIP(ctx, "203.0.113.7"))
	require.NoError(t, g.CheckAccount(ctx, uuid.New()))
	require.Equal(t, LoginMaxPerAccountPerHour, g.MaxAccountFailures())
	require.Equal(t, LockoutDuration, g.LockoutDuration())
}

func TestSessionExpiryIsCappedBySubscriptionGrace(t *testing.T) {
	now := time.Date(2026, 9, 6, 5, 0, 0, 0, time.UTC)

	// No subscription limit: the full TTL applies.
	require.Equal(t, now.Add(DefaultDriverRefreshTTL),
		SessionExpiry(now, DefaultDriverRefreshTTL, nil))

	// Subscription ends tomorrow: capped at end + 7 day grace.
	end := now.Add(24 * time.Hour)
	require.Equal(t, end.Add(SubscriptionGrace),
		SessionExpiry(now, DefaultDriverRefreshTTL, &end))

	// Subscription outlives the TTL: the TTL wins.
	far := now.Add(365 * 24 * time.Hour)
	require.Equal(t, now.Add(DefaultAdminRefreshTTL),
		SessionExpiry(now, DefaultAdminRefreshTTL, &far))
}

func TestRefreshTTLPerScope(t *testing.T) {
	require.Equal(t, DefaultDriverRefreshTTL, RefreshTTL(tenant.ScopeSelf, 0, 0))
	require.Equal(t, DefaultAdminRefreshTTL, RefreshTTL(tenant.ScopeAll, 0, 0))
	require.Equal(t, DefaultAdminRefreshTTL, RefreshTTL(tenant.ScopeBranch, 0, 0))
	require.True(t, IsSliding(tenant.ScopeSelf))
	require.False(t, IsSliding(tenant.ScopeAll))
}

func TestNormalizeDeviceTypeRejectsUnknownBuckets(t *testing.T) {
	require.Equal(t, tenant.DeviceWeb, NormalizeDeviceType("web"))
	require.Equal(t, tenant.DevicePhone, NormalizeDeviceType("phone"))
	require.Equal(t, tenant.DeviceTablet, NormalizeDeviceType("tablet"))
	// An invented device type must not open a fourth concurrent session slot.
	require.Equal(t, tenant.DeviceWeb, NormalizeDeviceType("watch"))
	require.Equal(t, tenant.DeviceWeb, NormalizeDeviceType(""))
}

func TestRefreshTokenIsOpaqueAndOnlyStoredHashed(t *testing.T) {
	token, hash, err := NewRefreshToken()
	require.NoError(t, err)
	require.NotEmpty(t, token)
	require.Len(t, hash, 64)
	require.NotContains(t, hash, token)
	require.Equal(t, hash, HashRefreshToken(token))

	other, otherHash, err := NewRefreshToken()
	require.NoError(t, err)
	require.NotEqual(t, token, other)
	require.NotEqual(t, hash, otherHash)
}

func TestRecoveryCodesAreSingleUseAndHashed(t *testing.T) {
	plain, hashes, err := GenerateRecoveryCodes()
	require.NoError(t, err)
	require.Len(t, plain, RecoveryCodeCount)
	require.Len(t, hashes, RecoveryCodeCount)
	for i, code := range plain {
		require.NotContains(t, hashes, code, "the plaintext code must never be stored")
		require.Len(t, hashes[i], 64)
	}

	idx, ok := MatchRecoveryCode(plain[3], hashes)
	require.True(t, ok)
	require.Equal(t, 3, idx)

	remaining := RemoveRecoveryCode(hashes, idx)
	require.Len(t, remaining, RecoveryCodeCount-1)
	_, ok = MatchRecoveryCode(plain[3], remaining)
	require.False(t, ok, "a consumed recovery code must not work twice")

	_, ok = MatchRecoveryCode("not-a-code", hashes)
	require.False(t, ok)
	_, ok = MatchRecoveryCode("", hashes)
	require.False(t, ok)
}

func TestTOTPMandatoryForPrivilegedRoles(t *testing.T) {
	require.True(t, TOTPRequiredForRole("Administrator", false))
	require.True(t, TOTPRequiredForRole("administrator", false))
	require.True(t, TOTPRequiredForRole("Fleet Manager", true))
	require.False(t, TOTPRequiredForRole("Fleet Manager", false))
	require.False(t, TOTPRequiredForRole("Driver", false))
}

func TestPermissionCatalogueRejectsUnknownKeys(t *testing.T) {
	require.True(t, IsValidPermission("units.read"))
	require.False(t, IsValidPermission("units.*"))
	require.False(t, IsValidPermission("*"))
	require.False(t, IsValidPermission("logs.delete"), "audit critical modules must not expose delete")
	require.False(t, IsValidPermission("dvir.delete"))
	require.False(t, IsValidPermission("violations.delete"))
	require.False(t, IsValidPermission("audit_log.delete"))

	filtered := FilterKnown([]string{"units.read", "units.read", "nope", "*", "drivers.read"})
	require.Equal(t, []string{"units.read", "drivers.read"}, filtered)
}
