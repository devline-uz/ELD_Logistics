package storage

import (
	"context"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/config"
)

// TZ B§7.2 / B§15: an expired export must leave nothing behind. Clearing
// report_export_jobs.file_key without deleting the object keeps the artefact —
// a full HOS or regulator report — alive in the bucket forever, reachable by
// anyone who can sign a GET for the key (backup dumps, a leaked key column, an
// operator with bucket credentials). These tests pin the delete path.

func removeTestS3(t testing.TB, endpoint string) *S3 {
	t.Helper()
	s3, err := NewS3(config.S3Config{
		Endpoint: endpoint, Bucket: "onebook", Key: "AKIAEXAMPLE", Secret: "secret",
		Region: "us-east-1",
	}, func() time.Time { return time.Date(2026, 9, 7, 4, 17, 0, 0, time.UTC) })
	require.NoError(t, err)
	return s3
}

func TestPresignDeleteSignsTheObjectKey(t *testing.T) {
	s3 := removeTestS3(t, "http://minio.test:9000")

	signed, err := s3.PresignDelete(context.Background(), "c1/reports/2026/09/export.csv", 0)
	require.NoError(t, err)
	require.Equal(t, "c1/reports/2026/09/export.csv", signed.Key)

	u, err := url.Parse(signed.URL)
	require.NoError(t, err)
	require.Equal(t, "/onebook/c1/reports/2026/09/export.csv", u.Path)
	q := u.Query()
	require.NotEmpty(t, q.Get("X-Amz-Signature"), "the delete must be authenticated")
	require.Equal(t, "AWS4-HMAC-SHA256", q.Get("X-Amz-Algorithm"))
	require.Equal(t, "60", q.Get("X-Amz-Expires"),
		"a server side delete only has to outlive one request")

	// The verb is part of the canonical request: a GET signature must not be
	// reusable as a DELETE.
	get, err := s3.PresignGet(context.Background(), "c1/reports/2026/09/export.csv", time.Minute)
	require.NoError(t, err)
	getSig, err := url.Parse(get.URL)
	require.NoError(t, err)
	require.NotEqual(t, getSig.Query().Get("X-Amz-Signature"), q.Get("X-Amz-Signature"))
}

func TestPresignDeleteRejectsBadInput(t *testing.T) {
	s3 := removeTestS3(t, "http://minio.test:9000")

	_, err := s3.PresignDelete(context.Background(), "  ", 0)
	require.ErrorIs(t, err, ErrEmptyKey)
	_, err = s3.PresignDelete(context.Background(), "/", 0)
	require.ErrorIs(t, err, ErrEmptyKey)
	_, err = s3.PresignDelete(context.Background(), "c1/a.csv", 30*24*time.Hour)
	require.ErrorIs(t, err, ErrBadExpiry)

	var nilS3 *S3
	_, err = nilS3.PresignDelete(context.Background(), "c1/a.csv", 0)
	require.ErrorIs(t, err, ErrNotConfigured)
}

func TestRemoverIssuesADeleteForEveryKey(t *testing.T) {
	var seen []string
	var methods []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		methods = append(methods, r.Method)
		seen = append(seen, r.URL.Path)
		require.NotEmpty(t, r.URL.Query().Get("X-Amz-Signature"))
		w.WriteHeader(http.StatusNoContent)
	}))
	defer srv.Close()

	rm := NewPresignRemover(removeTestS3(t, srv.URL), srv.Client())
	require.NoError(t, rm.Remove(context.Background(),
		"c1/reports/2026/09/a.csv", "", "   ", "c1/reports/2026/09/b.pdf"))

	require.Equal(t, []string{http.MethodDelete, http.MethodDelete}, methods)
	require.Equal(t, []string{
		"/onebook/c1/reports/2026/09/a.csv",
		"/onebook/c1/reports/2026/09/b.pdf",
	}, seen, "empty keys are skipped, real ones are all deleted")
}

func TestRemoverTreatsAMissingObjectAsDeleted(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNotFound)
	}))
	defer srv.Close()

	rm := NewPresignRemover(removeTestS3(t, srv.URL), srv.Client())
	require.NoError(t, rm.Remove(context.Background(), "c1/gone.csv"),
		"the retention sweep must stay idempotent")
}

func TestRemoverReportsFailuresButStillTriesEveryKey(t *testing.T) {
	var attempted []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		attempted = append(attempted, r.URL.Path)
		if strings.HasSuffix(r.URL.Path, "locked.csv") {
			w.WriteHeader(http.StatusForbidden)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}))
	defer srv.Close()

	rm := NewPresignRemover(removeTestS3(t, srv.URL), srv.Client())
	err := rm.Remove(context.Background(), "c1/locked.csv", "c1/ok.csv")
	require.Error(t, err, "a refused delete must surface so the sweep is retried")
	require.NotContains(t, err.Error(), "secret", "the error must not carry credentials")
	require.Len(t, attempted, 2, "one failure must not strand the remaining objects")

	var nilRemover *PresignRemover
	require.ErrorIs(t, nilRemover.Remove(context.Background(), "c1/a.csv"), ErrNotConfigured)
	require.NoError(t, NopRemover{}.Remove(context.Background(), "c1/a.csv"))
}

func TestFakeRemoveDropsTheStoredObject(t *testing.T) {
	f := NewFake()
	require.NoError(t, f.PutObject(context.Background(), "c1/a.csv", []byte("body"), "text/csv"))
	_, ok := f.Object("c1/a.csv")
	require.True(t, ok)

	require.NoError(t, f.Remove(context.Background(), "c1/a.csv", " "))
	_, ok = f.Object("c1/a.csv")
	require.False(t, ok, "the blob has to be gone, not just dereferenced")
	require.Equal(t, []string{"c1/a.csv"}, f.Removed())
}
