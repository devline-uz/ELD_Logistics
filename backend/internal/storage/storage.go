// Package storage presigns S3 compatible object uploads. The API server never
// proxies file bytes: it hands the client a short lived, signed PUT URL and
// stores only the object key (TZ B§3.4).
package storage

import (
	"context"
	"errors"
	"path"
	"strings"
	"time"

	"github.com/google/uuid"
)

// DefaultExpiry is the lifetime of a presigned upload URL (TZ B§3.4).
const DefaultExpiry = 15 * time.Minute

// MaxExpiry is the SigV4 ceiling for query string authentication.
const MaxExpiry = 7 * 24 * time.Hour

// Errors returned by this package.
var (
	ErrNotConfigured = errors.New("storage: object storage is not configured")
	ErrEmptyKey      = errors.New("storage: key must not be empty")
	ErrBadExpiry     = errors.New("storage: expiry must be between 1s and 7d")
)

// PutRequest describes the upload a client is about to perform.
type PutRequest struct {
	// Key is the object key inside the bucket. It is always built by the
	// server (see BuildKey); client supplied paths are never trusted.
	Key string
	// ContentType is signed, so the PUT must carry exactly this header.
	ContentType string
	// ContentLength, when positive, is signed as well: the object store then
	// rejects any PUT whose body is not exactly this many bytes. Without it
	// the size the client declared at presign time is unenforceable and the
	// per kind ceiling can be bypassed (TZ B§3.4).
	ContentLength int64
	// Expiry defaults to DefaultExpiry.
	Expiry time.Duration
}

// PresignedPut is a ready to use upload instruction.
type PresignedPut struct {
	URL       string
	Key       string
	ExpiresAt time.Time
	// Headers the client MUST send with the PUT for the signature to verify.
	Headers map[string]string
}

// Presigner issues presigned upload URLs. internal/domain/files depends on this
// interface only, so tests can substitute Fake.
type Presigner interface {
	PresignPut(ctx context.Context, req PutRequest) (PresignedPut, error)
	Bucket() string
}

// BuildKey derives a collision free, tenant scoped object key. The client can
// influence only the file extension, which is sanitised here, so "../" style
// traversal can never reach the bucket.
func BuildKey(companyID uuid.UUID, kind, filename string, now time.Time) string {
	ext := sanitiseExt(filename)
	tenant := "shared"
	if companyID != uuid.Nil {
		tenant = companyID.String()
	}
	return path.Join(
		tenant,
		kind,
		now.UTC().Format("2006/01"),
		uuid.NewString()+ext,
	)
}

// OwnsKey reports whether an object key produced by BuildKey belongs to this
// tenant. Every domain that stores a client supplied key (chat file_key, DVIR
// photo and signature keys, maintenance invoice_key) MUST check it: the key is
// the only thing standing between a stored reference and another company's
// object, and a presigned GET issued later would honour whatever was stored.
func OwnsKey(companyID uuid.UUID, key string) bool {
	key = strings.TrimSpace(key)
	if key == "" || companyID == uuid.Nil {
		return false
	}
	if strings.Contains(key, "..") || strings.HasPrefix(key, "/") {
		return false
	}
	prefix := companyID.String() + "/"
	if !strings.HasPrefix(key, prefix) {
		return false
	}
	// tenant / kind / yyyy / mm / file — a bare prefix match is not enough.
	return len(strings.Split(key, "/")) >= 3
}

// sanitiseExt keeps a short, lowercase, alphanumeric extension or nothing.
func sanitiseExt(filename string) string {
	ext := strings.ToLower(path.Ext(path.Base(filename)))
	if len(ext) < 2 || len(ext) > 6 {
		return ""
	}
	for _, r := range ext[1:] {
		if (r < 'a' || r > 'z') && (r < '0' || r > '9') {
			return ""
		}
	}
	return ext
}
