package storage

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"net/url"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/config"
)

// SigV4 constants.
const (
	algorithm       = "AWS4-HMAC-SHA256"
	service         = "s3"
	unsignedPayload = "UNSIGNED-PAYLOAD"
	isoLayout       = "20060102T150405Z"
	dateLayout      = "20060102"
)

// S3 presigns PUT uploads for any S3 compatible endpoint (AWS S3, MinIO,
// Ceph). Only the query string signing algorithm is implemented, which is all
// the API needs: bytes never pass through this process, so pulling in the full
// AWS SDK (which requires a newer Go toolchain than the project pins) would buy
// nothing. The implementation follows AWS SigV4 "Authenticating Requests: Using
// Query Parameters".
type S3 struct {
	endpoint  *url.URL
	bucket    string
	region    string
	accessKey string
	secretKey string
	pathStyle bool
	now       func() time.Time
}

// NewS3 builds a presigner from the S3_* configuration. now is overridable so
// signatures are deterministic in tests.
func NewS3(cfg config.S3Config, now func() time.Time) (*S3, error) {
	if cfg.Key == "" || cfg.Secret == "" {
		return nil, ErrNotConfigured
	}
	raw := cfg.Endpoint
	if raw == "" {
		return nil, ErrNotConfigured
	}
	if !strings.Contains(raw, "://") {
		scheme := "http"
		if cfg.UseSSL {
			scheme = "https"
		}
		raw = scheme + "://" + raw
	}
	u, err := url.Parse(raw)
	if err != nil {
		return nil, fmt.Errorf("storage: parse S3_ENDPOINT: %w", err)
	}
	if u.Host == "" {
		return nil, ErrNotConfigured
	}
	if cfg.Bucket == "" {
		return nil, ErrNotConfigured
	}
	if now == nil {
		now = time.Now
	}
	region := cfg.Region
	if region == "" {
		region = "us-east-1"
	}
	return &S3{
		endpoint:  u,
		bucket:    cfg.Bucket,
		region:    region,
		accessKey: cfg.Key,
		secretKey: cfg.Secret,
		// AWS itself resolves the bucket through the host name; every other
		// implementation (MinIO by default) expects it in the path.
		pathStyle: !strings.HasSuffix(strings.ToLower(u.Hostname()), "amazonaws.com"),
		now:       now,
	}, nil
}

// Bucket implements Presigner.
func (s *S3) Bucket() string { return s.bucket }

// PresignPut implements Presigner.
func (s *S3) PresignPut(_ context.Context, req PutRequest) (PresignedPut, error) {
	if s == nil {
		return PresignedPut{}, ErrNotConfigured
	}
	key := strings.TrimPrefix(req.Key, "/")
	if key == "" {
		return PresignedPut{}, ErrEmptyKey
	}
	expiry := req.Expiry
	if expiry == 0 {
		expiry = DefaultExpiry
	}
	if expiry < time.Second || expiry > MaxExpiry {
		return PresignedPut{}, ErrBadExpiry
	}

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

	// Signing Content-Type binds the upload to the type the server approved:
	// a client cannot swap an approved image/png for text/html.
	signedHeaders := []string{"host"}
	headerValues := map[string]string{"host": host}
	if req.ContentType != "" {
		signedHeaders = append(signedHeaders, "content-type")
		headerValues["content-type"] = req.ContentType
	}
	// Signing Content-Length binds the upload to the size the server approved
	// against the per kind ceiling: a larger body no longer verifies.
	if req.ContentLength > 0 {
		signedHeaders = append(signedHeaders, "content-length")
		headerValues["content-length"] = strconv.FormatInt(req.ContentLength, 10)
	}
	sort.Strings(signedHeaders)

	q := url.Values{}
	q.Set("X-Amz-Algorithm", algorithm)
	q.Set("X-Amz-Credential", s.accessKey+"/"+credentialScope)
	q.Set("X-Amz-Date", amzDate)
	q.Set("X-Amz-Expires", strconv.Itoa(int(expiry.Seconds())))
	q.Set("X-Amz-SignedHeaders", strings.Join(signedHeaders, ";"))

	var canonicalHeaders strings.Builder
	for _, h := range signedHeaders {
		canonicalHeaders.WriteString(h)
		canonicalHeaders.WriteByte(':')
		canonicalHeaders.WriteString(strings.TrimSpace(headerValues[h]))
		canonicalHeaders.WriteByte('\n')
	}

	canonicalRequest := strings.Join([]string{
		"PUT",
		canonicalURI,
		encodeQuery(q),
		canonicalHeaders.String(),
		strings.Join(signedHeaders, ";"),
		unsignedPayload,
	}, "\n")

	stringToSign := strings.Join([]string{
		algorithm,
		amzDate,
		credentialScope,
		hex.EncodeToString(sha256sum([]byte(canonicalRequest))),
	}, "\n")

	signature := hex.EncodeToString(hmacSHA256(s.signingKey(scopeDate), []byte(stringToSign)))
	q.Set("X-Amz-Signature", signature)

	// canonicalURI is already RFC 3986 encoded; building the string directly
	// keeps it byte identical to what was signed.
	out := s.endpoint.Scheme + "://" + host + canonicalURI + "?" + encodeQuery(q)

	headers := map[string]string{}
	if req.ContentType != "" {
		headers["Content-Type"] = req.ContentType
	}
	if req.ContentLength > 0 {
		headers["Content-Length"] = strconv.FormatInt(req.ContentLength, 10)
	}

	return PresignedPut{
		URL:       out,
		Key:       key,
		ExpiresAt: now.Add(expiry),
		Headers:   headers,
	}, nil
}

func (s *S3) signingKey(scopeDate string) []byte {
	k := hmacSHA256([]byte("AWS4"+s.secretKey), []byte(scopeDate))
	k = hmacSHA256(k, []byte(s.region))
	k = hmacSHA256(k, []byte(service))
	return hmacSHA256(k, []byte("aws4_request"))
}

func hmacSHA256(key, data []byte) []byte {
	m := hmac.New(sha256.New, key)
	m.Write(data)
	return m.Sum(nil)
}

func sha256sum(b []byte) []byte {
	sum := sha256.Sum256(b)
	return sum[:]
}

// hexSHA256 and hexHMAC are the two hex encodings the SigV4 string to sign
// needs; they keep the callers free of encoding noise.
func hexSHA256(b []byte) string { return hex.EncodeToString(sha256sum(b)) }

func hexHMAC(key, data []byte) string { return hex.EncodeToString(hmacSHA256(key, data)) }

// encodePath applies RFC 3986 encoding to every path segment while keeping the
// separators, as SigV4 requires for S3 canonical URIs.
func encodePath(p string) string {
	segments := strings.Split(p, "/")
	for i, seg := range segments {
		segments[i] = encodeRFC3986(seg)
	}
	return strings.Join(segments, "/")
}

// encodeQuery renders the query string with RFC 3986 encoding and sorted keys.
// net/url's Encode() escapes spaces as '+', which SigV4 rejects.
func encodeQuery(q url.Values) string {
	keys := make([]string, 0, len(q))
	for k := range q {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	var b strings.Builder
	for _, k := range keys {
		values := append([]string(nil), q[k]...)
		sort.Strings(values)
		for _, v := range values {
			if b.Len() > 0 {
				b.WriteByte('&')
			}
			b.WriteString(encodeRFC3986(k))
			b.WriteByte('=')
			b.WriteString(encodeRFC3986(v))
		}
	}
	return b.String()
}

const hexDigits = "0123456789ABCDEF"

func encodeRFC3986(s string) string {
	var b strings.Builder
	b.Grow(len(s))
	for i := 0; i < len(s); i++ {
		c := s[i]
		switch {
		case c >= 'A' && c <= 'Z', c >= 'a' && c <= 'z', c >= '0' && c <= '9',
			c == '-', c == '_', c == '.', c == '~':
			b.WriteByte(c)
		default:
			b.WriteByte('%')
			b.WriteByte(hexDigits[c>>4])
			b.WriteByte(hexDigits[c&0x0F])
		}
	}
	return b.String()
}
