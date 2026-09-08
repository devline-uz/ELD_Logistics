package auth

import (
	"regexp"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
)

// argon2idPHC is the encoding every stored password hash must match.
var argon2idPHC = regexp.MustCompile(
	`^\$argon2id\$v=19\$m=65536,t=3,p=4\$[A-Za-z0-9+/]{22}\$[A-Za-z0-9+/]{43}$`)

func TestHashPasswordUsesArgon2idWithPolicyParameters(t *testing.T) {
	hash, err := HashPassword("Str0ngPassphrase")
	require.NoError(t, err)
	require.Regexp(t, argon2idPHC, hash, "hash must be Argon2id m=64MiB t=3 p=4 with a 16 byte salt and 32 byte key")
	require.NotContains(t, hash, "Str0ngPassphrase")
}

func TestHashPasswordSaltIsRandom(t *testing.T) {
	a, err := HashPassword("Str0ngPassphrase")
	require.NoError(t, err)
	b, err := HashPassword("Str0ngPassphrase")
	require.NoError(t, err)
	require.NotEqual(t, a, b, "each hash must carry its own random salt")
}

func TestVerifyPassword(t *testing.T) {
	hash, err := HashPassword("Str0ngPassphrase")
	require.NoError(t, err)

	ok, err := VerifyPassword("Str0ngPassphrase", hash)
	require.NoError(t, err)
	require.True(t, ok)

	ok, err = VerifyPassword("str0ngpassphrase", hash)
	require.NoError(t, err)
	require.False(t, ok, "verification must be case sensitive")

	ok, err = VerifyPassword("", hash)
	require.NoError(t, err)
	require.False(t, ok)
}

func TestVerifyPasswordRejectsMalformedHashes(t *testing.T) {
	valid, err := HashPassword("Str0ngPassphrase")
	require.NoError(t, err)

	cases := map[string]string{
		"empty":           "",
		"plaintext":       "Str0ngPassphrase",
		"bcrypt":          "$2a$10$abcdefghijklmnopqrstuv",
		"wrong algorithm": strings.Replace(valid, "argon2id", "argon2i", 1),
		"wrong version":   strings.Replace(valid, "v=19", "v=16", 1),
		"truncated":       valid[:len(valid)-10],
		"bad salt base64": corruptSaltSegment(valid),
	}
	for name, encoded := range cases {
		_, err := VerifyPassword("Str0ngPassphrase", encoded)
		require.Error(t, err, "case %s must not verify", name)
	}
}

// corruptSaltSegment replaces the salt segment of an encoded Argon2id hash
// with invalid base64 so decodeArgon rejects it while keeping 6 `$` parts,
// distinct from the "truncated"/"wrong version" cases above.
func corruptSaltSegment(encoded string) string {
	parts := strings.Split(encoded, "$")
	parts[4] = "not-valid-base64!!"
	return strings.Join(parts, "$")
}

func TestValidatePasswordPolicy(t *testing.T) {
	require.NoError(t, ValidatePassword("Str0ngPassphrase"))
	require.NoError(t, ValidatePassword("abcdefghi1"))

	for _, weak := range []string{"short1", "onlyletters", "1234567890", strings.Repeat("a1", 100)} {
		err := ValidatePassword(weak)
		require.Error(t, err, "password %q must be rejected", weak)
		require.True(t, apierr.Is(err, apierr.CodePasswordWeak))
	}
}

func TestPINHashingAndPolicy(t *testing.T) {
	require.NoError(t, ValidatePIN("483920"))
	for _, bad := range []string{"", "12345", "1234567", "12345a", "abcdef"} {
		require.Error(t, ValidatePIN(bad), "pin %q must be rejected", bad)
	}

	hash, err := HashPIN("483920")
	require.NoError(t, err)
	require.Regexp(t, argon2idPHC, hash)
	require.NotContains(t, hash, "483920")

	ok, err := VerifyPIN("483920", hash)
	require.NoError(t, err)
	require.True(t, ok)

	ok, err = VerifyPIN("483921", hash)
	require.NoError(t, err)
	require.False(t, ok)
}
