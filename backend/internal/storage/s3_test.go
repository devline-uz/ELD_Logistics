package storage

import (
	"context"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/config"
)

// kindForTest stands in for an upload kind; the whitelist itself lives in the
// files domain, storage only builds keys.
const kindForTest = "dvir_photo"

func testConfig() config.S3Config {
	return config.S3Config{
		Endpoint: "http://minio.local:9000",
		Bucket:   "onebook-eld",
		Key:      "AKIAIOSFODNN7EXAMPLE",
		Secret:   "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
		Region:   "us-east-1",
	}
}

func fixedClock() func() time.Time {
	ts := time.Date(2026, 9, 6, 12, 0, 0, 0, time.UTC)
	return func() time.Time { return ts }
}

func TestBuildKeyIsServerSideAndTraversalSafe(t *testing.T) {
	companyID := uuid.MustParse("1f2e3d4c-5b6a-4978-8a1b-2c3d4e5f6071")
	now := time.Date(2026, 9, 6, 12, 0, 0, 0, time.UTC)

	cases := []struct {
		name     string
		filename string
		wantExt  string
	}{
		{"keeps a plain extension", "pre-trip.jpg", ".jpg"},
		{"lowercases the extension", "SCAN.PNG", ".png"},
		{"drops a traversal path", "../../../../etc/passwd", ""},
		{"drops a double extension trick", "invoice.pdf.exe;", ""},
		{"drops an overlong extension", "archive.tarball", ""},
		{"tolerates no extension", "noext", ""},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			key := BuildKey(companyID, kindForTest, tc.filename, now)
			require.True(t, strings.HasPrefix(key, companyID.String()+"/"+kindForTest+"/2026/09/"),
				"key %q must be tenant and kind scoped", key)
			require.NotContains(t, key, "..")
			require.NotContains(t, key, "etc/passwd")
			if tc.wantExt == "" {
				require.NotContains(t, key[strings.LastIndex(key, "/"):], ".")
			} else {
				require.True(t, strings.HasSuffix(key, tc.wantExt), "key %q", key)
			}
		})
	}

	// Two calls never collide: the file name is a fresh uuid.
	require.NotEqual(t,
		BuildKey(companyID, kindForTest, "a.jpg", now),
		BuildKey(companyID, kindForTest, "a.jpg", now))
}

func TestPresignPutSignsHostAndContentType(t *testing.T) {
	s, err := NewS3(testConfig(), fixedClock())
	require.NoError(t, err)

	out, err := s.PresignPut(context.Background(), PutRequest{
		Key:         "tenant/dvir_photo/2026/09/photo one.jpg",
		ContentType: "image/jpeg",
	})
	require.NoError(t, err)

	u, err := url.Parse(out.URL)
	require.NoError(t, err)
	require.Equal(t, "minio.local:9000", u.Host)
	// A non-AWS endpoint addresses the bucket through the path.
	require.True(t, strings.HasPrefix(u.EscapedPath(), "/onebook-eld/tenant/dvir_photo/2026/09/"), u.EscapedPath())
	// SigV4 requires %20, never '+', for a space.
	require.Contains(t, u.EscapedPath(), "photo%20one.jpg")

	q := u.Query()
	require.Equal(t, algorithm, q.Get("X-Amz-Algorithm"))
	require.Equal(t, "20260906T120000Z", q.Get("X-Amz-Date"))
	require.Equal(t, "900", q.Get("X-Amz-Expires"))
	require.Equal(t, "AKIAIOSFODNN7EXAMPLE/20260906/us-east-1/s3/aws4_request", q.Get("X-Amz-Credential"))
	require.Equal(t, "content-type;host", q.Get("X-Amz-SignedHeaders"))
	require.Len(t, q.Get("X-Amz-Signature"), 64)

	require.Equal(t, "image/jpeg", out.Headers["Content-Type"])
	require.Equal(t, time.Date(2026, 9, 6, 12, 15, 0, 0, time.UTC), out.ExpiresAt)

	// The signature is deterministic for the same request and clock.
	again, err := s.PresignPut(context.Background(), PutRequest{
		Key:         "tenant/dvir_photo/2026/09/photo one.jpg",
		ContentType: "image/jpeg",
	})
	require.NoError(t, err)
	require.Equal(t, out.URL, again.URL)

	// A different key produces a different signature.
	other, err := s.PresignPut(context.Background(), PutRequest{
		Key: "tenant/dvir_photo/2026/09/other.jpg", ContentType: "image/jpeg",
	})
	require.NoError(t, err)
	u2, err := url.Parse(other.URL)
	require.NoError(t, err)
	require.NotEqual(t, q.Get("X-Amz-Signature"), u2.Query().Get("X-Amz-Signature"))
}

func TestPresignPutUsesVirtualHostOnAWS(t *testing.T) {
	cfg := testConfig()
	cfg.Endpoint = "https://s3.us-east-1.amazonaws.com"
	s, err := NewS3(cfg, fixedClock())
	require.NoError(t, err)

	out, err := s.PresignPut(context.Background(), PutRequest{Key: "a/b.jpg", ContentType: "image/jpeg"})
	require.NoError(t, err)

	u, err := url.Parse(out.URL)
	require.NoError(t, err)
	require.Equal(t, "onebook-eld.s3.us-east-1.amazonaws.com", u.Host)
	require.Equal(t, "/a/b.jpg", u.EscapedPath())
}

func TestPresignPutRejectsBadInput(t *testing.T) {
	s, err := NewS3(testConfig(), fixedClock())
	require.NoError(t, err)

	_, err = s.PresignPut(context.Background(), PutRequest{Key: ""})
	require.ErrorIs(t, err, ErrEmptyKey)

	_, err = s.PresignPut(context.Background(), PutRequest{Key: "a", Expiry: 8 * 24 * time.Hour})
	require.ErrorIs(t, err, ErrBadExpiry)

	_, err = s.PresignPut(context.Background(), PutRequest{Key: "a", Expiry: time.Millisecond})
	require.ErrorIs(t, err, ErrBadExpiry)
}

func TestNewS3RequiresCredentials(t *testing.T) {
	cfg := testConfig()
	cfg.Key = ""
	_, err := NewS3(cfg, nil)
	require.ErrorIs(t, err, ErrNotConfigured)

	cfg = testConfig()
	cfg.Bucket = ""
	_, err = NewS3(cfg, nil)
	require.ErrorIs(t, err, ErrNotConfigured)
}

func TestFakePresignerRecordsRequests(t *testing.T) {
	f := NewFake()
	out, err := f.PresignPut(context.Background(), PutRequest{Key: "a/b c.jpg", ContentType: "image/png"})
	require.NoError(t, err)
	require.Contains(t, out.URL, "a/b%20c.jpg")
	require.Equal(t, "image/png", out.Headers["Content-Type"])
	require.Len(t, f.Requests(), 1)

	_, err = f.PresignPut(context.Background(), PutRequest{Key: ""})
	require.ErrorIs(t, err, ErrEmptyKey)
}
