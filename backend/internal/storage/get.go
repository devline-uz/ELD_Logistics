package storage

import (
	"context"
	"net/http"
	"strings"
	"time"
)

// PresignedGet is a ready to use download link.
type PresignedGet struct {
	URL       string
	Key       string
	ExpiresAt time.Time
}

// Downloader issues presigned download URLs for objects the server itself
// produced (report exports, log PDFs). It is a separate interface from
// Presigner so an implementation may support uploads without downloads.
type Downloader interface {
	PresignGet(ctx context.Context, key string, expiry time.Duration) (PresignedGet, error)
}

// PresignGet implements Downloader. The link carries the signature in the
// query string, so it works from a plain browser redirect and expires on its
// own — nothing has to be revoked when a report export ages out.
func (s *S3) PresignGet(_ context.Context, key string, expiry time.Duration) (PresignedGet, error) {
	if s == nil {
		return PresignedGet{}, ErrNotConfigured
	}
	key = strings.TrimPrefix(key, "/")
	if key == "" {
		return PresignedGet{}, ErrEmptyKey
	}
	if expiry == 0 {
		expiry = DefaultExpiry
	}
	if expiry < time.Second || expiry > MaxExpiry {
		return PresignedGet{}, ErrBadExpiry
	}

	signed, expiresAt := s.presignQuery(http.MethodGet, key, expiry)
	return PresignedGet{URL: signed, Key: key, ExpiresAt: expiresAt}, nil
}

// PresignGet implements Downloader for the in-memory fake.
func (f *Fake) PresignGet(_ context.Context, key string, expiry time.Duration) (PresignedGet, error) {
	if f.Err != nil {
		return PresignedGet{}, f.Err
	}
	if key == "" {
		return PresignedGet{}, ErrEmptyKey
	}
	if expiry == 0 {
		expiry = DefaultExpiry
	}
	now := time.Now
	if f.Now != nil {
		now = f.Now
	}
	base := f.baseURL()
	return PresignedGet{
		URL:       base + "/" + f.Bucket() + "/" + encodePath(key) + "?X-Amz-Signature=fake-get",
		Key:       key,
		ExpiresAt: now().UTC().Add(expiry),
	}, nil
}

// compile time guards.
var (
	_ Downloader = (*S3)(nil)
	_ Downloader = (*Fake)(nil)
)
