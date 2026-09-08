package auth

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/cache"
)

// RolePermissionCacheTTL is the permission cache lifetime (TZ B§3, RBAC).
const RolePermissionCacheTTL = 5 * time.Minute

// PermissionLoader reads the permission keys of a role from the database.
type PermissionLoader func(ctx context.Context, roleID uuid.UUID) ([]string, error)

// RolePermissionCache caches role -> permission keys in Redis. Role and
// role_permission mutations MUST call Invalidate so a narrowed role takes
// effect immediately instead of after the TTL.
type RolePermissionCache struct {
	store  cache.Store
	loader PermissionLoader
	ttl    time.Duration
}

// NewRolePermissionCache wires the cache. A nil store degrades to a pass
// through that always hits the loader.
func NewRolePermissionCache(store cache.Store, loader PermissionLoader, ttl time.Duration) *RolePermissionCache {
	if ttl <= 0 {
		ttl = RolePermissionCacheTTL
	}
	return &RolePermissionCache{store: store, loader: loader, ttl: ttl}
}

func rolePermKey(roleID uuid.UUID) string { return "perm:role:" + roleID.String() }

// PermissionsForRole implements PermissionSource.
func (c *RolePermissionCache) PermissionsForRole(ctx context.Context, roleID uuid.UUID) ([]string, error) {
	if c == nil || c.loader == nil {
		return nil, nil
	}
	if roleID == uuid.Nil {
		return nil, nil
	}

	if c.store != nil {
		raw, ok, err := c.store.Get(ctx, rolePermKey(roleID))
		if err == nil && ok {
			var perms []string
			if json.Unmarshal([]byte(raw), &perms) == nil {
				return perms, nil
			}
		}
	}

	perms, err := c.loader(ctx, roleID)
	if err != nil {
		return nil, fmt.Errorf("auth: load role permissions: %w", err)
	}
	if perms == nil {
		perms = []string{}
	}

	if c.store != nil {
		if buf, err := json.Marshal(perms); err == nil {
			_ = c.store.Set(ctx, rolePermKey(roleID), string(buf), c.ttl)
		}
	}
	return perms, nil
}

// Invalidate drops the cached permissions of the given roles.
func (c *RolePermissionCache) Invalidate(ctx context.Context, roleIDs ...uuid.UUID) error {
	if c == nil || c.store == nil || len(roleIDs) == 0 {
		return nil
	}
	keys := make([]string, 0, len(roleIDs))
	for _, id := range roleIDs {
		if id != uuid.Nil {
			keys = append(keys, rolePermKey(id))
		}
	}
	return c.store.Del(ctx, keys...)
}
