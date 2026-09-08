package auth

import (
	"net/http"
	"strings"
	"time"

	"github.com/pquerna/otp"
	"github.com/pquerna/otp/totp"

	"github.com/devline/onebook-eld/internal/apierr"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
)

// TOTP policy (TZ B§3.4).
const (
	// TOTPDigits is the code length.
	TOTPDigits = otp.DigitsSix
	// TOTPPeriod is the code validity window in seconds.
	TOTPPeriod = 30
	// TOTPSkew accepts one period before and after to tolerate clock drift.
	TOTPSkew = 1
	// RecoveryCodeCount is the number of single use recovery codes issued.
	RecoveryCodeCount = 10
	// recoveryCodeBytes is the entropy of one recovery code.
	recoveryCodeBytes = 10
)

// TOTPManager owns TOTP enrolment and verification. The shared secret is only
// ever persisted AES-256-GCM encrypted (users.totp_secret_enc).
type TOTPManager struct {
	issuer string
	cipher *appcrypto.Cipher
}

// NewTOTPManager builds the manager. issuer is shown in the authenticator app.
func NewTOTPManager(issuer string, c *appcrypto.Cipher) *TOTPManager {
	if strings.TrimSpace(issuer) == "" {
		issuer = "ONEBOOK ELD"
	}
	return &TOTPManager{issuer: issuer, cipher: c}
}

// Enrolment is the result of starting a 2FA setup.
type Enrolment struct {
	// Secret is the base32 shared secret shown for manual entry.
	Secret string
	// SecretEnc is the AES-256-GCM value to persist.
	SecretEnc string
	// URL is the otpauth:// provisioning URI rendered as a QR code.
	URL string
}

// Generate creates a new shared secret for account (username or email).
func (m *TOTPManager) Generate(account string) (*Enrolment, error) {
	key, err := totp.Generate(totp.GenerateOpts{
		Issuer:      m.issuer,
		AccountName: account,
		Period:      TOTPPeriod,
		Digits:      TOTPDigits,
		Algorithm:   otp.AlgorithmSHA1,
	})
	if err != nil {
		return nil, apierr.Internal(err, "could not start two factor enrolment")
	}

	enc, err := m.cipher.EncryptString(key.Secret())
	if err != nil {
		return nil, apierr.Internal(err, "could not protect the two factor secret")
	}
	return &Enrolment{Secret: key.Secret(), SecretEnc: enc, URL: key.URL()}, nil
}

// Validate checks code against the encrypted secret at time now.
func (m *TOTPManager) Validate(secretEnc, code string, now time.Time) (bool, error) {
	if secretEnc == "" {
		return false, apierr.New(apierr.CodeTOTPSetupRequired, http.StatusForbidden,
			"two factor authentication is not configured")
	}
	secret, err := m.cipher.DecryptString(secretEnc)
	if err != nil {
		return false, apierr.Internal(err, "could not read the two factor secret")
	}
	ok, err := totp.ValidateCustom(strings.TrimSpace(code), secret, now.UTC(), totp.ValidateOpts{
		Period:    TOTPPeriod,
		Skew:      TOTPSkew,
		Digits:    TOTPDigits,
		Algorithm: otp.AlgorithmSHA1,
	})
	if err != nil {
		return false, nil //nolint:nilerr // a malformed/expired code is a rejection, not a system fault
	}
	return ok, nil
}

// GenerateRecoveryCodes returns RecoveryCodeCount single use codes together
// with the SHA-256 hashes that are stored in users.recovery_codes.
func GenerateRecoveryCodes() (plain []string, hashes []string, err error) {
	plain = make([]string, 0, RecoveryCodeCount)
	hashes = make([]string, 0, RecoveryCodeCount)
	for i := 0; i < RecoveryCodeCount; i++ {
		code, err := appcrypto.RandomHex(recoveryCodeBytes)
		if err != nil {
			return nil, nil, err
		}
		plain = append(plain, code)
		hashes = append(hashes, appcrypto.HashSHA256(code))
	}
	return plain, hashes, nil
}

// MatchRecoveryCode looks the candidate up in the stored hashes using constant
// time comparison and returns the index of the consumed code.
func MatchRecoveryCode(candidate string, hashes []string) (int, bool) {
	if strings.TrimSpace(candidate) == "" {
		return -1, false
	}
	want := appcrypto.HashSHA256(strings.TrimSpace(strings.ToLower(candidate)))
	idx := -1
	for i, h := range hashes {
		if appcrypto.ConstantTimeEqual(h, want) {
			idx = i
		}
	}
	return idx, idx >= 0
}

// RemoveRecoveryCode returns hashes without the element at idx (single use).
func RemoveRecoveryCode(hashes []string, idx int) []string {
	if idx < 0 || idx >= len(hashes) {
		return hashes
	}
	out := make([]string, 0, len(hashes)-1)
	out = append(out, hashes[:idx]...)
	return append(out, hashes[idx+1:]...)
}

// TOTPRequiredForRole reports whether 2FA enrolment is mandatory. Super Admin
// and Administrator MUST enrol (TZ B§3.4).
func TOTPRequiredForRole(roleName string, isSuperAdmin bool) bool {
	if isSuperAdmin {
		return true
	}
	switch strings.ToLower(strings.TrimSpace(roleName)) {
	case "super admin", "administrator":
		return true
	default:
		return false
	}
}
