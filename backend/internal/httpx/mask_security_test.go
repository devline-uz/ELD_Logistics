package httpx_test

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/httpx"
)

// The JWT pattern used to require at least five characters in every one of the
// three segments. A token whose signature is shorter — an `alg=none` forgery
// (empty signature) or a truncated log line — slipped through unmasked, and the
// header and payload of an access token carry sub, cid, sid and jti in plain
// base64url. Only the `eyJ` header anchor is needed to recognise a token.
func TestMaskSecretsCatchesShortSignatureJWTs(t *testing.T) {
	t.Parallel()

	header := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
	payload := "eyJzdWIiOiIzYTdiMWMyZCIsImNpZCI6ImYzOTgwNDkwIn0"

	cases := []struct {
		name  string
		token string
	}{
		{"alg none, empty signature", header + "." + payload + "."},
		{"one character signature", header + "." + payload + ".a"},
		{"four character signature", header + "." + payload + ".abcd"},
		{"full signature", header + "." + payload + ".c2lnbmF0dXJlLXZhbHVl"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got := httpx.MaskSecrets("session refused for token " + tc.token)
			require.Contains(t, got, httpx.Redacted)
			require.NotContains(t, got, payload,
				"the payload carries sub/cid/sid and must never reach a log")
			require.NotContains(t, got, header)
		})
	}
}

func TestMaskSecretsRedactsJWTsAnywhereInTheLine(t *testing.T) {
	t.Parallel()
	token := "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0."
	got := httpx.MaskSecrets("GET /api/v1/ws?token=" + token + " failed")
	require.NotContains(t, got, "eyJ")
	require.Contains(t, got, "GET /api/v1/ws?token=")
	require.Contains(t, got, "failed")
}

// The pattern must stay anchored on the base64url header: ordinary dotted text
// (a file name, a version, a hostname) is not a token and must survive.
func TestMaskSecretsDoesNotEatOrdinaryDottedText(t *testing.T) {
	t.Parallel()
	for _, s := range []string{
		"activity-units.csv",
		"pgx/v5.7.1 connect timeout",
		"unit_number 1021 on route 3.2.1",
	} {
		require.Equal(t, s, httpx.MaskSecrets(s))
	}
}

// The phone pattern (`\d[\d\s\-().]{7,}\d`) is shaped just like a bare ISO
// date (`2026-09-06`); a log line quoting `certified_at 2026-09-06` must not
// have its date redacted as if it were a phone number.
func TestMaskSecretsDoesNotEatISODates(t *testing.T) {
	t.Parallel()
	for _, s := range []string{
		"certified_at 2026-09-06",
		"log_date=2026-01-01",
	} {
		require.Equal(t, s, httpx.MaskSecrets(s))
	}
}

func TestMaskSecretsStillScrubsTheOtherFamilies(t *testing.T) {
	t.Parallel()
	got := httpx.MaskSecrets("Authorization: Bearer abc123 for dispatch@example.com +1 555 010 0000 " +
		"postgres://eld:hunter2@db:5432/eld")
	require.NotContains(t, got, "abc123")
	require.NotContains(t, got, "dispatch@example.com")
	require.NotContains(t, got, "hunter2")
	require.NotContains(t, strings.ToLower(got), "555 010 0000")
}
