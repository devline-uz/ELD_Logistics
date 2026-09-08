package cache

import (
	"context"
	"sync"
	"time"
)

type entry struct {
	value     string
	expiresAt time.Time
}

// MemoryStore is an in-process Store used by unit tests and by single node
// development runs. It is safe for concurrent use.
type MemoryStore struct {
	mu   sync.Mutex
	data map[string]entry
	now  func() time.Time
}

// NewMemoryStore builds an empty store.
func NewMemoryStore() *MemoryStore {
	return &MemoryStore{data: make(map[string]entry), now: time.Now}
}

// SetClock overrides the time source; tests only.
func (s *MemoryStore) SetClock(now func() time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.now = now
}

func (s *MemoryStore) get(key string) (entry, bool) {
	e, ok := s.data[key]
	if !ok {
		return entry{}, false
	}
	if !e.expiresAt.IsZero() && s.now().After(e.expiresAt) {
		delete(s.data, key)
		return entry{}, false
	}
	return e, true
}

// Get implements Store.
func (s *MemoryStore) Get(_ context.Context, key string) (string, bool, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	e, ok := s.get(key)
	return e.value, ok, nil
}

// Set implements Store.
func (s *MemoryStore) Set(_ context.Context, key, value string, ttl time.Duration) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	e := entry{value: value}
	if ttl > 0 {
		e.expiresAt = s.now().Add(ttl)
	}
	s.data[key] = e
	return nil
}

// SetNX implements Store.
func (s *MemoryStore) SetNX(_ context.Context, key, value string, ttl time.Duration) (bool, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.get(key); ok {
		return false, nil
	}
	e := entry{value: value}
	if ttl > 0 {
		e.expiresAt = s.now().Add(ttl)
	}
	s.data[key] = e
	return true, nil
}

// Incr implements Store.
func (s *MemoryStore) Incr(_ context.Context, key string, ttl time.Duration) (int64, time.Duration, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ttl <= 0 {
		ttl = time.Minute
	}
	e, ok := s.get(key)
	var n int64
	if ok {
		for _, c := range e.value {
			n = n*10 + int64(c-'0')
		}
	} else {
		e = entry{expiresAt: s.now().Add(ttl)}
	}
	n++
	e.value = formatInt(n)
	s.data[key] = e
	return n, e.expiresAt.Sub(s.now()), nil
}

// Del implements Store.
func (s *MemoryStore) Del(_ context.Context, keys ...string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, k := range keys {
		delete(s.data, k)
	}
	return nil
}

func formatInt(n int64) string {
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
