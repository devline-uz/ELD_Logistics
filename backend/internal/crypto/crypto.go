// Package crypto holds the primitives shared by the security layer:
// AES-256-GCM envelope encryption for columns at rest, SHA-256 hashing for
// opaque tokens and CSPRNG helpers. math/rand is never used here.
package crypto

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"math/big"
)

// AES-256-GCM parameters.
const (
	// KeySize is the AES-256 key length in bytes.
	KeySize = 32
	// NonceSize is the GCM nonce length in bytes.
	NonceSize = 12
	// TokenBytes is the default entropy of an opaque token.
	TokenBytes = 32
)

// Errors returned by this package.
var (
	ErrKeySize     = fmt.Errorf("crypto: key must be exactly %d bytes", KeySize)
	ErrCipherText  = errors.New("crypto: ciphertext is malformed")
	ErrNotEnabled  = errors.New("crypto: cipher is not configured")
	ErrTokenLength = errors.New("crypto: token length must be positive")
)

// Cipher performs authenticated encryption with AES-256-GCM. It is safe for
// concurrent use.
type Cipher struct {
	aead cipher.AEAD
}

// NewCipher builds a Cipher from a raw 32 byte key.
func NewCipher(key []byte) (*Cipher, error) {
	if len(key) != KeySize {
		return nil, ErrKeySize
	}
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("crypto: new aes cipher: %w", err)
	}
	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, fmt.Errorf("crypto: new gcm: %w", err)
	}
	return &Cipher{aead: aead}, nil
}

// NewCipherFromString builds a Cipher from the raw ENCRYPTION_KEY value. The
// key is accepted either as 32 raw bytes or as base64/hex of 32 bytes.
func NewCipherFromString(key string) (*Cipher, error) {
	if len(key) == KeySize {
		return NewCipher([]byte(key))
	}
	if raw, err := base64.StdEncoding.DecodeString(key); err == nil && len(raw) == KeySize {
		return NewCipher(raw)
	}
	if raw, err := hex.DecodeString(key); err == nil && len(raw) == KeySize {
		return NewCipher(raw)
	}
	return nil, ErrKeySize
}

// Encrypt seals plaintext and returns base64(nonce || ciphertext || tag).
// A fresh 12 byte nonce is drawn from crypto/rand for every call.
func (c *Cipher) Encrypt(plaintext []byte) (string, error) {
	if c == nil || c.aead == nil {
		return "", ErrNotEnabled
	}
	nonce := make([]byte, NonceSize)
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return "", fmt.Errorf("crypto: read nonce: %w", err)
	}
	sealed := c.aead.Seal(nonce, nonce, plaintext, nil)
	return base64.StdEncoding.EncodeToString(sealed), nil
}

// EncryptString is Encrypt for string payloads.
func (c *Cipher) EncryptString(plaintext string) (string, error) {
	return c.Encrypt([]byte(plaintext))
}

// Decrypt opens a value produced by Encrypt.
func (c *Cipher) Decrypt(encoded string) ([]byte, error) {
	if c == nil || c.aead == nil {
		return nil, ErrNotEnabled
	}
	raw, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		return nil, ErrCipherText
	}
	if len(raw) < NonceSize+c.aead.Overhead() {
		return nil, ErrCipherText
	}
	nonce, body := raw[:NonceSize], raw[NonceSize:]
	plaintext, err := c.aead.Open(nil, nonce, body, nil)
	if err != nil {
		return nil, ErrCipherText
	}
	return plaintext, nil
}

// DecryptString is Decrypt for string payloads.
func (c *Cipher) DecryptString(encoded string) (string, error) {
	raw, err := c.Decrypt(encoded)
	if err != nil {
		return "", err
	}
	return string(raw), nil
}

// HashSHA256 returns the lowercase hex SHA-256 digest of v. Opaque tokens are
// stored in this form; the plaintext token never reaches the database.
func HashSHA256(v string) string {
	sum := sha256.Sum256([]byte(v))
	return hex.EncodeToString(sum[:])
}

// HashSHA256Bytes returns the lowercase hex SHA-256 digest of b.
func HashSHA256Bytes(b []byte) string {
	sum := sha256.Sum256(b)
	return hex.EncodeToString(sum[:])
}

// RandomBytes returns n cryptographically secure random bytes.
func RandomBytes(n int) ([]byte, error) {
	if n <= 0 {
		return nil, ErrTokenLength
	}
	buf := make([]byte, n)
	if _, err := io.ReadFull(rand.Reader, buf); err != nil {
		return nil, fmt.Errorf("crypto: read random: %w", err)
	}
	return buf, nil
}

// RandomToken returns an unpadded base64url token carrying n bytes of entropy.
func RandomToken(n int) (string, error) {
	buf, err := RandomBytes(n)
	if err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

// RandomHex returns a lowercase hex token carrying n bytes of entropy.
func RandomHex(n int) (string, error) {
	buf, err := RandomBytes(n)
	if err != nil {
		return "", err
	}
	return hex.EncodeToString(buf), nil
}

// RandomDigits returns an n digit numeric string drawn without modulo bias.
func RandomDigits(n int) (string, error) {
	if n <= 0 {
		return "", ErrTokenLength
	}
	out := make([]byte, n)
	max := big.NewInt(10)
	for i := range out {
		v, err := rand.Int(rand.Reader, max)
		if err != nil {
			return "", fmt.Errorf("crypto: read random digit: %w", err)
		}
		out[i] = byte('0' + v.Int64()) //nolint:gosec // G115: v is rand.Int(reader, 10), always 0-9
	}
	return string(out), nil
}

// ConstantTimeEqual compares two secrets without leaking their contents through
// timing. Tokens and PINs MUST be compared with this helper, never with ==.
func ConstantTimeEqual(a, b string) bool {
	return subtle.ConstantTimeCompare([]byte(a), []byte(b)) == 1
}

// ConstantTimeEqualBytes is ConstantTimeEqual for byte slices.
func ConstantTimeEqualBytes(a, b []byte) bool {
	return subtle.ConstantTimeCompare(a, b) == 1
}
