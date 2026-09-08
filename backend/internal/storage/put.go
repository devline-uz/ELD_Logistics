package storage

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"
)

// putTimeout bounds one server side upload; these objects are small (trip
// polylines, unidentified tracks), never user files.
const putTimeout = 15 * time.Second

// Putter uploads an object the server generated itself. Client uploads keep
// using Presigner: the API never proxies user file bytes (TZ B§3.4).
type Putter interface {
	PutObject(ctx context.Context, key string, body []byte, contentType string) error
}

// PresignPutter turns any Presigner into a Putter by signing a PUT and
// performing it, so there is exactly one signing implementation to audit.
type PresignPutter struct {
	signer Presigner
	client *http.Client
}

// NewPresignPutter wraps a presigner. A nil client falls back to a bounded one.
func NewPresignPutter(signer Presigner, client *http.Client) *PresignPutter {
	if client == nil {
		client = &http.Client{Timeout: putTimeout}
	}
	return &PresignPutter{signer: signer, client: client}
}

// PutObject implements Putter.
func (p *PresignPutter) PutObject(ctx context.Context, key string, body []byte, contentType string) error {
	if p == nil || p.signer == nil {
		return ErrNotConfigured
	}
	if key == "" {
		return ErrEmptyKey
	}
	signed, err := p.signer.PresignPut(ctx, PutRequest{
		Key: key, ContentType: contentType, ContentLength: int64(len(body)),
	})
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPut, signed.URL, bytes.NewReader(body))
	if err != nil {
		return err
	}
	for k, v := range signed.Headers {
		req.Header.Set(k, v)
	}
	req.ContentLength = int64(len(body))

	resp, err := p.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 4096))
	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("storage: put %q: unexpected status %d", key, resp.StatusCode)
	}
	return nil
}

// NopPutter discards objects. It keeps the ingestion pipeline running when no
// object storage is configured (local development, unit tests).
type NopPutter struct{}

// PutObject implements Putter.
func (NopPutter) PutObject(context.Context, string, []byte, string) error { return nil }

// MemoryPutter keeps objects in memory so tests can assert what was stored.
type MemoryPutter struct {
	// Err, when set, is returned by every call.
	Err error

	mu      sync.Mutex
	objects map[string][]byte
}

// NewMemoryPutter builds an empty in-memory object store.
func NewMemoryPutter() *MemoryPutter { return &MemoryPutter{objects: map[string][]byte{}} }

// PutObject implements Putter.
func (m *MemoryPutter) PutObject(_ context.Context, key string, body []byte, _ string) error {
	if m.Err != nil {
		return m.Err
	}
	if key == "" {
		return ErrEmptyKey
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.objects == nil {
		m.objects = map[string][]byte{}
	}
	m.objects[key] = append([]byte(nil), body...)
	return nil
}

// Object returns a stored object and whether it exists.
func (m *MemoryPutter) Object(key string) ([]byte, bool) {
	m.mu.Lock()
	defer m.mu.Unlock()
	v, ok := m.objects[key]
	return v, ok
}

// Len reports how many objects were stored.
func (m *MemoryPutter) Len() int {
	m.mu.Lock()
	defer m.mu.Unlock()
	return len(m.objects)
}
