package storage

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

// removeTimeout bounds one delete round trip. A retention sweep may issue many
// of them, so a hung endpoint must not stall the worker.
const removeTimeout = 15 * time.Second

// deleteExpiry is the lifetime of the signature of a server side delete. The
// URL never leaves this process, so it only has to outlive one request.
const deleteExpiry = time.Minute

// Remover deletes objects the server no longer keeps a reference to. The
// retention sweep (TZ B§7.2 / B§15) needs it: clearing report_export_jobs.
// file_key without deleting the blob leaves the export downloadable by anyone
// who kept the presigned link's object key and can sign a new one.
type Remover interface {
	Remove(ctx context.Context, keys ...string) error
}

// PresignedDelete is a signed DELETE instruction.
type PresignedDelete struct {
	URL       string
	Key       string
	ExpiresAt time.Time
}

// DeletePresigner signs an object delete. It is separate from Presigner so an
// implementation may support uploads without deletes.
type DeletePresigner interface {
	PresignDelete(ctx context.Context, key string, expiry time.Duration) (PresignedDelete, error)
}

// PresignDelete implements DeletePresigner.
func (s *S3) PresignDelete(_ context.Context, key string, expiry time.Duration) (PresignedDelete, error) {
	if s == nil {
		return PresignedDelete{}, ErrNotConfigured
	}
	key = strings.TrimPrefix(strings.TrimSpace(key), "/")
	if key == "" {
		return PresignedDelete{}, ErrEmptyKey
	}
	if expiry == 0 {
		expiry = deleteExpiry
	}
	if expiry < time.Second || expiry > MaxExpiry {
		return PresignedDelete{}, ErrBadExpiry
	}
	signed, expiresAt := s.presignQuery(http.MethodDelete, key, expiry)
	return PresignedDelete{URL: signed, Key: key, ExpiresAt: expiresAt}, nil
}

// PresignRemover turns any DeletePresigner into a Remover by signing a DELETE
// and performing it, so there stays exactly one SigV4 implementation to audit.
type PresignRemover struct {
	signer DeletePresigner
	client *http.Client
}

// NewPresignRemover wraps a presigner. A nil client falls back to a bounded one.
func NewPresignRemover(signer DeletePresigner, client *http.Client) *PresignRemover {
	if client == nil {
		client = &http.Client{Timeout: removeTimeout}
	}
	return &PresignRemover{signer: signer, client: client}
}

// Remove implements Remover. Deleting an object that is already gone is not an
// error: S3 answers 204 either way, which keeps the retention sweep idempotent.
// The first failure is returned, but every remaining key is still attempted so
// one unreachable object cannot pin the whole sweep.
func (p *PresignRemover) Remove(ctx context.Context, keys ...string) error {
	if p == nil || p.signer == nil {
		return ErrNotConfigured
	}
	var firstErr error
	for _, key := range keys {
		if strings.TrimSpace(key) == "" {
			continue
		}
		if err := p.removeOne(ctx, key); err != nil && firstErr == nil {
			firstErr = err
		}
	}
	return firstErr
}

func (p *PresignRemover) removeOne(ctx context.Context, key string) error {
	signed, err := p.signer.PresignDelete(ctx, key, deleteExpiry)
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodDelete, signed.URL, nil)
	if err != nil {
		return err
	}
	resp, err := p.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 4096))
	// 404 is success for a delete: the object is gone, which is the goal.
	if resp.StatusCode == http.StatusNotFound {
		return nil
	}
	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("storage: delete %q: unexpected status %d", key, resp.StatusCode)
	}
	return nil
}

// NopRemover discards deletes. It keeps the retention sweep running when no
// object storage is configured (local development, unit tests).
type NopRemover struct{}

// Remove implements Remover.
func (NopRemover) Remove(context.Context, ...string) error { return nil }

// presignQuery builds a SigV4 query string signature for one object and verb.
// It is the single signing path of this package; PresignGet and PresignDelete
// both go through it.
func (s *S3) presignQuery(method, key string, expiry time.Duration) (string, time.Time) {
	now := s.now().UTC()
	amzDate := now.Format(isoLayout)
	scopeDate := now.Format(dateLayout)
	credentialScope := strings.Join([]string{scopeDate, s.region, service, "aws4_request"}, "/")

	host := s.endpoint.Host
	canonicalURI := "/" + encodePath(key)
	if s.pathStyle {
		canonicalURI = "/" + s.bucket + "/" + encodePath(key)
	} else {
		host = s.bucket + "." + host
	}

	q := url.Values{}
	q.Set("X-Amz-Algorithm", algorithm)
	q.Set("X-Amz-Credential", s.accessKey+"/"+credentialScope)
	q.Set("X-Amz-Date", amzDate)
	q.Set("X-Amz-Expires", strconv.Itoa(int(expiry.Seconds())))
	q.Set("X-Amz-SignedHeaders", "host")

	canonicalRequest := strings.Join([]string{
		method,
		canonicalURI,
		encodeQuery(q),
		"host:" + host + "\n",
		"host",
		unsignedPayload,
	}, "\n")

	stringToSign := strings.Join([]string{
		algorithm, amzDate, credentialScope,
		hexSHA256([]byte(canonicalRequest)),
	}, "\n")

	q.Set("X-Amz-Signature", hexHMAC(s.signingKey(scopeDate), []byte(stringToSign)))
	return s.endpoint.Scheme + "://" + host + canonicalURI + "?" + encodeQuery(q), now.Add(expiry)
}
