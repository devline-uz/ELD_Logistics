package auth

import (
	"encoding/base64"
	"errors"
	"fmt"
	"net/http"
	"runtime"
	"strings"
	"unicode"

	"golang.org/x/crypto/argon2"

	"github.com/devline/onebook-eld/internal/apierr"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
)

// Argon2id parameters (TZ B§3.3). Changing them keeps existing hashes valid:
// VerifyPassword reads the cost parameters back from the encoded value.
const (
	argonTime    uint32 = 3
	argonMemory  uint32 = 64 * 1024 // 64 MiB
	argonThreads uint8  = 4
	argonKeyLen  uint32 = 32
	argonSaltLen int    = 16

	// MinPasswordLen is the minimum password length (TZ A§16).
	MinPasswordLen = 10
	// MaxPasswordLen bounds the work an attacker can force on the hasher.
	MaxPasswordLen = 128
	// PINLength is the fixed length of a driver PIN.
	PINLength = 6
)

// Errors returned by the password helpers.
var (
	ErrHashFormat = errors.New("auth: password hash is malformed")
	ErrNoPassword = errors.New("auth: user has no password set")
)

// dummyHash equalises the cost of a login against an unknown user with the
// cost of a login against a real one, so response time does not disclose
// whether a username exists.
var dummyHash = mustHash("onebook-eld-timing-equaliser")

// HashPassword derives an Argon2id hash in the standard PHC encoding:
// $argon2id$v=19$m=65536,t=3,p=4$<b64 salt>$<b64 hash>.
func HashPassword(password string) (string, error) {
	if password == "" {
		return "", ErrNoPassword
	}
	salt, err := appcrypto.RandomBytes(argonSaltLen)
	if err != nil {
		return "", err
	}
	return encodeArgon(password, salt, argonTime, argonMemory, argonThreads, argonKeyLen), nil
}

// VerifyPassword compares a candidate password with an encoded Argon2id hash in
// constant time. It returns false (never an error) for a simple mismatch.
func VerifyPassword(password, encoded string) (bool, error) {
	p, salt, want, err := decodeArgon(encoded)
	if err != nil {
		return false, err
	}
	//nolint:gosec // G115: want is a decoded Argon2 hash, always a few dozen bytes
	got := argon2.IDKey([]byte(password), salt, p.time, p.memory, p.threads, uint32(len(want)))
	return appcrypto.ConstantTimeEqualBytes(got, want), nil
}

// VerifyPasswordDummy burns the same CPU as VerifyPassword. Call it when the
// user lookup failed so the timing profile of both paths matches.
func VerifyPasswordDummy(password string) {
	_, _ = VerifyPassword(password, dummyHash)
}

// ValidatePassword enforces the policy: at least MinPasswordLen characters and
// a mix of letters and digits.
func ValidatePassword(password string) error {
	if len(password) < MinPasswordLen {
		return apierr.New(apierr.CodePasswordWeak, http.StatusUnprocessableEntity,
			fmt.Sprintf("password must be at least %d characters", MinPasswordLen)).
			WithDetails(apierr.FieldError{Field: "password", Message: "too short"})
	}
	if len(password) > MaxPasswordLen {
		return apierr.New(apierr.CodePasswordWeak, http.StatusUnprocessableEntity,
			fmt.Sprintf("password must be at most %d characters", MaxPasswordLen)).
			WithDetails(apierr.FieldError{Field: "password", Message: "too long"})
	}
	var hasLetter, hasDigit bool
	for _, r := range password {
		switch {
		case unicode.IsLetter(r):
			hasLetter = true
		case unicode.IsDigit(r):
			hasDigit = true
		}
	}
	if !hasLetter || !hasDigit {
		return apierr.New(apierr.CodePasswordWeak, http.StatusUnprocessableEntity,
			"password must contain both letters and digits").
			WithDetails(apierr.FieldError{Field: "password", Message: "must mix letters and digits"})
	}
	return nil
}

// ValidatePIN enforces the 6 digit driver PIN format.
func ValidatePIN(pin string) error {
	if len(pin) != PINLength {
		return apierr.New(apierr.CodePINInvalid, http.StatusUnprocessableEntity,
			fmt.Sprintf("pin must be exactly %d digits", PINLength)).
			WithDetails(apierr.FieldError{Field: "pin", Message: "must be 6 digits"})
	}
	for _, r := range pin {
		if r < '0' || r > '9' {
			return apierr.New(apierr.CodePINInvalid, http.StatusUnprocessableEntity,
				"pin must contain digits only").
				WithDetails(apierr.FieldError{Field: "pin", Message: "digits only"})
		}
	}
	return nil
}

// HashPIN derives an Argon2id hash for a 6 digit PIN.
func HashPIN(pin string) (string, error) {
	if err := ValidatePIN(pin); err != nil {
		return "", err
	}
	salt, err := appcrypto.RandomBytes(argonSaltLen)
	if err != nil {
		return "", err
	}
	return encodeArgon(pin, salt, argonTime, argonMemory, argonThreads, argonKeyLen), nil
}

// VerifyPIN compares a candidate PIN with its stored Argon2id hash.
func VerifyPIN(pin, encoded string) (bool, error) {
	return VerifyPassword(pin, encoded)
}

type argonParams struct {
	time    uint32
	memory  uint32
	threads uint8
}

func encodeArgon(secret string, salt []byte, t, m uint32, p uint8, keyLen uint32) string {
	sum := argon2.IDKey([]byte(secret), salt, t, m, p, keyLen)
	return fmt.Sprintf("$argon2id$v=%d$m=%d,t=%d,p=%d$%s$%s",
		argon2.Version, m, t, p,
		base64.RawStdEncoding.EncodeToString(salt),
		base64.RawStdEncoding.EncodeToString(sum),
	)
}

func decodeArgon(encoded string) (argonParams, []byte, []byte, error) {
	var p argonParams
	if encoded == "" {
		return p, nil, nil, ErrNoPassword
	}
	parts := strings.Split(encoded, "$")
	if len(parts) != 6 || parts[0] != "" || parts[1] != "argon2id" {
		return p, nil, nil, ErrHashFormat
	}

	var version int
	if _, err := fmt.Sscanf(parts[2], "v=%d", &version); err != nil || version != argon2.Version {
		return p, nil, nil, ErrHashFormat
	}
	var threads uint8
	if _, err := fmt.Sscanf(parts[3], "m=%d,t=%d,p=%d", &p.memory, &p.time, &threads); err != nil {
		return p, nil, nil, ErrHashFormat
	}
	p.threads = threads
	if p.memory == 0 || p.time == 0 || p.threads == 0 || int(p.threads) > 4*runtime.NumCPU()+8 {
		return p, nil, nil, ErrHashFormat
	}

	salt, err := base64.RawStdEncoding.DecodeString(parts[4])
	if err != nil || len(salt) == 0 {
		return p, nil, nil, ErrHashFormat
	}
	sum, err := base64.RawStdEncoding.DecodeString(parts[5])
	if err != nil || len(sum) == 0 {
		return p, nil, nil, ErrHashFormat
	}
	return p, salt, sum, nil
}

func mustHash(secret string) string {
	// Fixed salt: the value is only used to burn CPU, never to protect a secret.
	return encodeArgon(secret, []byte("onebook-eld-dummy"), argonTime, argonMemory, argonThreads, argonKeyLen)
}
