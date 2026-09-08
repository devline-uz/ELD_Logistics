package testutil

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgconn"
	"github.com/stretchr/testify/require"
)

// PostgreSQL SQLSTATE codes asserted by the infrastructure tests.
const (
	SQLStateInsufficientPrivilege = "42501" // RLS violation, REVOKEd privilege
	SQLStateUniqueViolation       = "23505"
	SQLStateForeignKeyViolation   = "23503"
	SQLStateCheckViolation        = "23514"
)

// piiFields are response keys that must never reach a client.
var piiFields = []string{"password", "token", "license_no", "totp_secret", "pin", "recovery_codes"}

// piiSuffixes are response key suffixes that must never reach a client.
var piiSuffixes = []string{"_hash", "_enc"}

// RequireStatus asserts the HTTP status code.
func RequireStatus(t testing.TB, resp *Response, want int) {
	t.Helper()
	require.Equal(t, want, resp.Code, "unexpected status; body: %s", resp)
}

// RequireErrorCode asserts the status family and the canonical error code.
func RequireErrorCode(t testing.TB, resp *Response, code string) {
	t.Helper()
	require.GreaterOrEqual(t, resp.Code, 400, "expected an error response; body: %s", resp)
	require.Equal(t, code, resp.ErrorCode(), "unexpected error code; body: %s", resp)
}

// RequireStatusCode asserts both the HTTP status and the error code.
func RequireStatusCode(t testing.TB, resp *Response, status int, code string) {
	t.Helper()
	RequireStatus(t, resp, status)
	require.Equal(t, code, resp.ErrorCode(), "unexpected error code; body: %s", resp)
}

// RequireNoPII fails when the JSON body exposes a secret or PII field:
// password, token, license_no, or any *_hash / *_enc key, at any depth.
func RequireNoPII(t testing.TB, body []byte) {
	t.Helper()
	if len(body) == 0 {
		return
	}
	var v any
	if err := json.Unmarshal(body, &v); err != nil {
		return // not JSON: nothing to inspect
	}
	if leaked := findPII(v, ""); leaked != "" {
		t.Fatalf("response leaks PII/secret field %q; body: %s", leaked, body)
	}
}

func findPII(v any, path string) string {
	switch n := v.(type) {
	case map[string]any:
		for k, child := range n {
			if isPIIKey(k) {
				return join(path, k)
			}
			if leaked := findPII(child, join(path, k)); leaked != "" {
				return leaked
			}
		}
	case []any:
		for i, child := range n {
			if leaked := findPII(child, join(path, itoa(i))); leaked != "" {
				return leaked
			}
		}
	}
	return ""
}

func isPIIKey(key string) bool {
	k := strings.ToLower(key)
	for _, f := range piiFields {
		if k == f || strings.HasSuffix(k, "_"+f) || strings.HasPrefix(k, f+"_") {
			return true
		}
	}
	for _, s := range piiSuffixes {
		if strings.HasSuffix(k, s) {
			return true
		}
	}
	return false
}

func join(path, key string) string {
	if path == "" {
		return key
	}
	return path + "." + key
}

func itoa(i int) string {
	if i == 0 {
		return "0"
	}
	var buf [20]byte
	pos := len(buf)
	for i > 0 {
		pos--
		buf[pos] = byte('0' + i%10)
		i /= 10
	}
	return string(buf[pos:])
}

// RequirePGError asserts err is a PostgreSQL error carrying the given SQLSTATE.
func RequirePGError(t testing.TB, err error, sqlState string) {
	t.Helper()
	require.Error(t, err, "expected SQLSTATE %s", sqlState)
	var pgErr *pgconn.PgError
	require.ErrorAs(t, err, &pgErr, "expected a *pgconn.PgError, got %v", err)
	require.Equal(t, sqlState, pgErr.Code, "unexpected SQLSTATE (%s)", pgErr.Message)
}

// RequirePermissionDenied asserts the database refused the statement (REVOKEd
// privilege or an RLS policy violation).
func RequirePermissionDenied(t testing.TB, err error) {
	t.Helper()
	RequirePGError(t, err, SQLStateInsufficientPrivilege)
}
