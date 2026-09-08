package storage

import (
	"context"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
)

// The declared upload size must be part of the signature. Without it the size
// check performed at presign time is advisory only: the client can sign a 1 KiB
// upload and then PUT a multi gigabyte body with the very same URL.
func TestPresignPutSignsContentLength(t *testing.T) {
	s, err := NewS3(testConfig(), fixedClock())
	require.NoError(t, err)
	ctx := context.Background()

	small, err := s.PresignPut(ctx, PutRequest{
		Key: "tenant/dvir_photo/2026/09/a.jpg", ContentType: "image/jpeg", ContentLength: 1024,
	})
	require.NoError(t, err)

	u, err := url.Parse(small.URL)
	require.NoError(t, err)
	signed := u.Query().Get("X-Amz-SignedHeaders")
	require.Equal(t, "content-length;content-type;host", signed,
		"content-length must be part of the signed headers")

	// The client is told exactly which headers to send.
	require.Equal(t, "1024", small.Headers["Content-Length"])
	require.Equal(t, "image/jpeg", small.Headers["Content-Type"])

	// A larger body cannot reuse the signature: the same request with another
	// length signs differently.
	large, err := s.PresignPut(ctx, PutRequest{
		Key: "tenant/dvir_photo/2026/09/a.jpg", ContentType: "image/jpeg", ContentLength: 50 << 20,
	})
	require.NoError(t, err)
	lu, err := url.Parse(large.URL)
	require.NoError(t, err)
	require.NotEqual(t, u.Query().Get("X-Amz-Signature"), lu.Query().Get("X-Amz-Signature"))

	// Signing stays deterministic for an identical request.
	again, err := s.PresignPut(ctx, PutRequest{
		Key: "tenant/dvir_photo/2026/09/a.jpg", ContentType: "image/jpeg", ContentLength: 1024,
	})
	require.NoError(t, err)
	require.Equal(t, small.URL, again.URL)
}

// The canonical request must carry the header value itself, not only its name.
func TestPresignPutCanonicalisesContentLength(t *testing.T) {
	s, err := NewS3(testConfig(), fixedClock())
	require.NoError(t, err)

	out, err := s.PresignPut(context.Background(), PutRequest{
		Key: "a/b.jpg", ContentType: "image/png", ContentLength: 7,
	})
	require.NoError(t, err)

	// Two uploads of the same object that differ only in one byte of length
	// must not share a signature.
	other, err := s.PresignPut(context.Background(), PutRequest{
		Key: "a/b.jpg", ContentType: "image/png", ContentLength: 8,
	})
	require.NoError(t, err)
	require.NotEqual(t, out.URL, other.URL)
}

// Server generated objects (trip polylines) keep working: without a length the
// header is simply not signed.
func TestPresignPutWithoutContentLengthIsUnchanged(t *testing.T) {
	s, err := NewS3(testConfig(), fixedClock())
	require.NoError(t, err)

	out, err := s.PresignPut(context.Background(), PutRequest{Key: "a/b.jpg", ContentType: "image/png"})
	require.NoError(t, err)
	u, err := url.Parse(out.URL)
	require.NoError(t, err)
	require.Equal(t, "content-type;host", u.Query().Get("X-Amz-SignedHeaders"))
	_, ok := out.Headers["Content-Length"]
	require.False(t, ok)
	require.False(t, strings.Contains(u.Query().Get("X-Amz-SignedHeaders"), "content-length"))
}

func TestFakePresignerReportsContentLength(t *testing.T) {
	f := NewFake()
	out, err := f.PresignPut(context.Background(), PutRequest{
		Key: "a/b.jpg", ContentType: "image/png", ContentLength: 2048,
	})
	require.NoError(t, err)
	require.Equal(t, "2048", out.Headers["Content-Length"])
	require.Equal(t, int64(2048), f.Requests()[0].ContentLength)
}

// OwnsKey is the gate every domain that stores a client supplied object key
// relies on (chat file_key, DVIR photo and signature keys, maintenance
// invoice_key): a key of another tenant must never be accepted.
func TestOwnsKeyRejectsForeignAndMalformedKeys(t *testing.T) {
	mine := uuid.New()
	theirs := uuid.New()
	now := time.Date(2026, 9, 7, 12, 0, 0, 0, time.UTC)

	require.True(t, OwnsKey(mine, BuildKey(mine, "chat", "a.pdf", now)))
	require.True(t, OwnsKey(mine, BuildKey(mine, "dvir_photo", "a.jpg", now)))

	require.False(t, OwnsKey(mine, BuildKey(theirs, "chat", "a.pdf", now)))
	require.False(t, OwnsKey(mine, ""))
	require.False(t, OwnsKey(uuid.Nil, BuildKey(mine, "chat", "a.pdf", now)))
	require.False(t, OwnsKey(mine, "/"+mine.String()+"/chat/2026/09/a.pdf"))
	require.False(t, OwnsKey(mine, mine.String()+"/../"+theirs.String()+"/chat/a.pdf"))
	require.False(t, OwnsKey(mine, mine.String()), "a bare tenant prefix is not an object")
	require.False(t, OwnsKey(mine, mine.String()+"x/chat/2026/09/a.pdf"))
}
