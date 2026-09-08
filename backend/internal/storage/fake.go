package storage

import (
	"context"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"
)

// fakeBaseURL is the origin the fake pretends to be when BaseURL is unset.
const fakeBaseURL = "https://storage.test"

// Fake is an in-memory Presigner for tests and local runs without MinIO. It
// records every request so assertions can inspect what the service asked for.
type Fake struct {
	// BaseURL is the origin the fake pretends to be.
	BaseURL string
	// Err, when set, is returned by every call.
	Err error
	// Now is overridable; defaults to time.Now.
	Now func() time.Time

	mu       sync.Mutex
	requests []PutRequest
	objects  map[string]FakeObject
	removed  []string
}

// NewFake builds a Fake with sensible defaults.
func NewFake() *Fake {
	return &Fake{BaseURL: fakeBaseURL, Now: time.Now}
}

// Bucket implements Presigner.
func (f *Fake) Bucket() string { return "test-bucket" }

// PresignPut implements Presigner.
func (f *Fake) PresignPut(_ context.Context, req PutRequest) (PresignedPut, error) {
	if f.Err != nil {
		return PresignedPut{}, f.Err
	}
	if req.Key == "" {
		return PresignedPut{}, ErrEmptyKey
	}
	expiry := req.Expiry
	if expiry == 0 {
		expiry = DefaultExpiry
	}
	now := time.Now
	if f.Now != nil {
		now = f.Now
	}

	f.mu.Lock()
	f.requests = append(f.requests, req)
	f.mu.Unlock()

	headers := map[string]string{}
	if req.ContentType != "" {
		headers["Content-Type"] = req.ContentType
	}
	if req.ContentLength > 0 {
		headers["Content-Length"] = strconv.FormatInt(req.ContentLength, 10)
	}
	base := f.baseURL()
	return PresignedPut{
		URL:       base + "/" + f.Bucket() + "/" + encodePath(req.Key) + "?X-Amz-Signature=" + url.QueryEscape("fake"),
		Key:       req.Key,
		ExpiresAt: now().UTC().Add(expiry),
		Headers:   headers,
	}, nil
}

// PresignDelete implements DeletePresigner for the fake.
func (f *Fake) PresignDelete(_ context.Context, key string, expiry time.Duration) (PresignedDelete, error) {
	if f.Err != nil {
		return PresignedDelete{}, f.Err
	}
	if key == "" {
		return PresignedDelete{}, ErrEmptyKey
	}
	if expiry == 0 {
		expiry = deleteExpiry
	}
	now := time.Now
	if f.Now != nil {
		now = f.Now
	}
	base := f.baseURL()
	return PresignedDelete{
		URL:       base + "/" + f.Bucket() + "/" + encodePath(key) + "?X-Amz-Signature=" + url.QueryEscape("fake"),
		Key:       key,
		ExpiresAt: now().UTC().Add(expiry),
	}, nil
}

// Remove implements Remover: it drops the object from the in-memory store and
// records the key, so a test can assert that retention really deleted a blob.
// Deleting an unknown key is not an error, exactly as with S3.
func (f *Fake) Remove(_ context.Context, keys ...string) error {
	if f.Err != nil {
		return f.Err
	}
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, key := range keys {
		if strings.TrimSpace(key) == "" {
			continue
		}
		delete(f.objects, key)
		f.removed = append(f.removed, key)
	}
	return nil
}

// Removed returns every key handed to Remove so far.
func (f *Fake) Removed() []string {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]string(nil), f.removed...)
}

// baseURL is the origin of every fake URL.
func (f *Fake) baseURL() string {
	if f.BaseURL == "" {
		return fakeBaseURL
	}
	return f.BaseURL
}

// Requests returns a copy of every presign request seen so far.
func (f *Fake) Requests() []PutRequest {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]PutRequest(nil), f.requests...)
}

// PutObject implements Putter for the fake: it records the object in memory so
// a test can assert what the server uploaded without a bucket.
func (f *Fake) PutObject(_ context.Context, key string, body []byte, contentType string) error {
	if f.Err != nil {
		return f.Err
	}
	if key == "" {
		return ErrEmptyKey
	}
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.objects == nil {
		f.objects = map[string]FakeObject{}
	}
	f.objects[key] = FakeObject{Body: append([]byte(nil), body...), ContentType: contentType}
	return nil
}

// FakeObject is one object stored by the fake.
type FakeObject struct {
	Body        []byte
	ContentType string
}

// Object returns a stored object.
func (f *Fake) Object(key string) (FakeObject, bool) {
	f.mu.Lock()
	defer f.mu.Unlock()
	o, ok := f.objects[key]
	return o, ok
}

// compile time guards.
var (
	_ Putter          = (*Fake)(nil)
	_ Remover         = (*Fake)(nil)
	_ DeletePresigner = (*Fake)(nil)
	_ DeletePresigner = (*S3)(nil)
	_ Remover         = (*PresignRemover)(nil)
	_ Remover         = NopRemover{}
)
