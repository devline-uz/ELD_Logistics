package crypto

import (
	"encoding/base64"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func testCipher(t *testing.T) *Cipher {
	t.Helper()
	c, err := NewCipherFromString(strings.Repeat("k", KeySize))
	require.NoError(t, err)
	return c
}

func TestCipherRejectsShortKey(t *testing.T) {
	for _, key := range []string{"", "short", strings.Repeat("k", 31), strings.Repeat("k", 33)} {
		_, err := NewCipherFromString(key)
		require.ErrorIs(t, err, ErrKeySize, "key %q must be rejected", key)
	}
}

func TestEncryptRoundTripAndNonceIsUnique(t *testing.T) {
	c := testCipher(t)
	const secret = "JBSWY3DPEHPK3PXP"

	first, err := c.EncryptString(secret)
	require.NoError(t, err)
	second, err := c.EncryptString(secret)
	require.NoError(t, err)

	// A fresh random nonce per call means identical plaintext never produces
	// identical ciphertext.
	require.NotEqual(t, first, second)
	require.NotContains(t, first, secret)

	got, err := c.DecryptString(first)
	require.NoError(t, err)
	require.Equal(t, secret, got)

	raw, err := base64.StdEncoding.DecodeString(first)
	require.NoError(t, err)
	require.Greater(t, len(raw), NonceSize)
}

func TestDecryptRejectsTamperedCiphertext(t *testing.T) {
	c := testCipher(t)
	sealed, err := c.EncryptString("license-no-1234")
	require.NoError(t, err)

	raw, err := base64.StdEncoding.DecodeString(sealed)
	require.NoError(t, err)
	raw[len(raw)-1] ^= 0xFF

	_, err = c.Decrypt(base64.StdEncoding.EncodeToString(raw))
	require.ErrorIs(t, err, ErrCipherText)

	_, err = c.Decrypt("not-base64!!")
	require.ErrorIs(t, err, ErrCipherText)
	_, err = c.Decrypt("")
	require.ErrorIs(t, err, ErrCipherText)
}

func TestDecryptRejectsForeignKey(t *testing.T) {
	a := testCipher(t)
	b, err := NewCipherFromString(strings.Repeat("z", KeySize))
	require.NoError(t, err)

	sealed, err := a.EncryptString("totp-secret")
	require.NoError(t, err)
	_, err = b.Decrypt(sealed)
	require.ErrorIs(t, err, ErrCipherText)
}

func TestRandomTokenEntropy(t *testing.T) {
	seen := make(map[string]struct{}, 512)
	for i := 0; i < 512; i++ {
		tok, err := RandomToken(TokenBytes)
		require.NoError(t, err)
		require.NotContains(t, seen, tok, "crypto/rand must not repeat a 32 byte token")
		seen[tok] = struct{}{}
	}
	_, err := RandomToken(0)
	require.ErrorIs(t, err, ErrTokenLength)
}

func TestRandomDigitsShape(t *testing.T) {
	for i := 0; i < 64; i++ {
		pin, err := RandomDigits(6)
		require.NoError(t, err)
		require.Len(t, pin, 6)
		for _, r := range pin {
			require.True(t, r >= '0' && r <= '9')
		}
	}
}

func TestHashSHA256IsStable(t *testing.T) {
	require.Equal(t, HashSHA256("abc"), HashSHA256("abc"))
	require.NotEqual(t, HashSHA256("abc"), HashSHA256("abd"))
	require.Len(t, HashSHA256("abc"), 64)
}

func TestConstantTimeEqual(t *testing.T) {
	require.True(t, ConstantTimeEqual("token", "token"))
	require.False(t, ConstantTimeEqual("token", "tokeN"))
	require.False(t, ConstantTimeEqual("token", "token-longer"))
	require.False(t, ConstantTimeEqual("", "x"))
}
