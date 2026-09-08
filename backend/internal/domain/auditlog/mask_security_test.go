// Masking must hold on every path through a JSON value, not only on a flat
// object: audit_log.old_value / new_value carry whatever snapshot a domain
// wrote, and those snapshots nest (arrays of attachments, embedded settings,
// lists of sessions). One unmasked branch is a credential in a support view.
package auditlog

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/httpx"
)

func TestMaskJSONWalksEveryBranch(t *testing.T) {
	raw := []byte(`{
	  "name": "Fleet A",
	  "users": [
	    {"username": "jmiller", "password_hash": "$argon2id$v=19$abc", "email": "j@example.com"},
	    {"username": "asmith", "totp_secret_enc": "Zm9vYmFy"}
	  ],
	  "nested": {"deep": {"deeper": [{"refresh_token_hash": "deadbeef"}]}},
	  "notes": ["call +1 555 123 4567", "see eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2lnbmF0dXJl"],
	  "count": 3,
	  "active": true
	}`)

	value, masked := maskJSON("snapshot", raw)
	require.True(t, masked)

	out, err := json.Marshal(value)
	require.NoError(t, err)
	body := string(out)

	for _, secret := range []string{
		"$argon2id$v=19$abc", "Zm9vYmFy", "deadbeef",
		"j@example.com", "+1 555 123 4567", "eyJhbGciOiJIUzI1NiJ9",
	} {
		require.False(t, strings.Contains(body, secret), "leaked %q through a nested value", secret)
	}
	// Harmless data survives: masking must not blind the audit trail.
	require.Contains(t, body, "Fleet A")
	require.Contains(t, body, "jmiller")
	require.Contains(t, body, `"count":3`)
	require.Contains(t, body, `"active":true`)
}

func TestMaskJSONRedactsBySensitiveFieldName(t *testing.T) {
	// The column name alone redacts the value, whatever its shape.
	for _, field := range []string{
		"password_hash", "license_no_enc", "totp_secret_enc",
		"refresh_token_hash", "pin_hash", "api_key",
	} {
		value, masked := maskJSON(field, []byte(`{"anything":["still","secret"]}`))
		require.True(t, masked, "field %q", field)
		require.Equal(t, httpx.Redacted, value, "field %q", field)
	}
}

func TestMaskJSONNeverEchoesAnUnparsableValue(t *testing.T) {
	value, masked := maskJSON("note", []byte(`{"broken": `))
	require.True(t, masked)
	require.Equal(t, httpx.Redacted, value)

	value, masked = maskJSON("note", nil)
	require.False(t, masked)
	require.Nil(t, value)
}

func TestMaskJSONHandlesTopLevelArrays(t *testing.T) {
	value, masked := maskJSON("attachments", []byte(
		`[{"file_key":"a/b/c.jpg","token":"secret-token"},["nested@example.com"]]`))
	require.True(t, masked)

	out, err := json.Marshal(value)
	require.NoError(t, err)
	require.NotContains(t, string(out), "secret-token")
	require.NotContains(t, string(out), "nested@example.com")
	require.Contains(t, string(out), "a/b/c.jpg")
}
