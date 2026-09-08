package cache

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

// RedisStore is the production Store.
type RedisStore struct {
	client redis.Cmdable
	prefix string
}

// NewRedisStore wraps a go-redis client. prefix namespaces every key.
func NewRedisStore(client redis.Cmdable, prefix string) *RedisStore {
	if prefix == "" {
		prefix = "eld"
	}
	return &RedisStore{client: client, prefix: prefix}
}

func (s *RedisStore) key(k string) string { return s.prefix + ":" + k }

// Get implements Store.
func (s *RedisStore) Get(ctx context.Context, key string) (string, bool, error) {
	v, err := s.client.Get(ctx, s.key(key)).Result()
	if errors.Is(err, redis.Nil) {
		return "", false, nil
	}
	if err != nil {
		return "", false, fmt.Errorf("cache: get: %w", err)
	}
	return v, true, nil
}

// Set implements Store.
func (s *RedisStore) Set(ctx context.Context, key, value string, ttl time.Duration) error {
	if err := s.client.Set(ctx, s.key(key), value, ttl).Err(); err != nil {
		return fmt.Errorf("cache: set: %w", err)
	}
	return nil
}

// SetNX implements Store.
func (s *RedisStore) SetNX(ctx context.Context, key, value string, ttl time.Duration) (bool, error) {
	ok, err := s.client.SetNX(ctx, s.key(key), value, ttl).Result()
	if err != nil {
		return false, fmt.Errorf("cache: setnx: %w", err)
	}
	return ok, nil
}

// incrScript increments a counter and sets the expiry only on creation, so the
// window is fixed and cannot be extended by a flood of requests.
var incrScript = redis.NewScript(`
local n = redis.call('INCR', KEYS[1])
if n == 1 then
  redis.call('PEXPIRE', KEYS[1], ARGV[1])
end
return {n, redis.call('PTTL', KEYS[1])}
`)

// Incr implements Store.
func (s *RedisStore) Incr(ctx context.Context, key string, ttl time.Duration) (int64, time.Duration, error) {
	if ttl <= 0 {
		ttl = time.Minute
	}
	res, err := incrScript.Run(ctx, s.client, []string{s.key(key)}, ttl.Milliseconds()).Slice()
	if err != nil {
		return 0, 0, fmt.Errorf("cache: incr: %w", err)
	}
	if len(res) != 2 {
		return 0, 0, errors.New("cache: unexpected incr reply")
	}
	count, _ := res[0].(int64)
	ms, _ := res[1].(int64)
	if ms < 0 {
		ms = ttl.Milliseconds()
	}
	return count, time.Duration(ms) * time.Millisecond, nil
}

// Del implements Store.
func (s *RedisStore) Del(ctx context.Context, keys ...string) error {
	if len(keys) == 0 {
		return nil
	}
	full := make([]string, len(keys))
	for i, k := range keys {
		full[i] = s.key(k)
	}
	if err := s.client.Del(ctx, full...).Err(); err != nil {
		return fmt.Errorf("cache: del: %w", err)
	}
	return nil
}
