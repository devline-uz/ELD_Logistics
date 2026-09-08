package httpx

import (
	"net/url"
	"regexp"
	"strings"
	"time"
)

// SensitiveKeys are request/response fields that MUST never reach the logs.
var SensitiveKeys = map[string]struct{}{
	"password": {}, "new_password": {}, "old_password": {}, "current_password": {},
	"pin": {}, "pin_code": {}, "token": {}, "access_token": {}, "refresh_token": {},
	"id_token": {}, "authorization": {}, "secret": {}, "api_key": {}, "apikey": {},
	"totp": {}, "totp_code": {}, "otp": {}, "code": {}, "recovery_code": {},
	"license_no": {}, "license_number": {}, "driver_license": {}, "ssn": {},
	"phone": {}, "phone_number": {}, "email": {}, "lat": {}, "lng": {},
	"latitude": {}, "longitude": {}, "card_number": {}, "cvv": {},
	"encryption_key": {}, "jwt_secret": {}, "database_url": {},
}

const redacted = "[REDACTED]"

var (
	emailRe  = regexp.MustCompile(`(?i)[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}`)
	bearerRe = regexp.MustCompile(`(?i)bearer\s+[A-Za-z0-9\-._~+/]+=*`)
	// A JWT is header.payload.signature. The signature part must NOT carry a
	// length floor: an `alg=none` token has an empty one and a truncated token
	// a very short one, and both still leak the header and the payload — which
	// is where sub, cid, sid and jti live. The header alone (`eyJ…`) is enough
	// to recognise the token, so only the header is anchored.
	jwtRe   = regexp.MustCompile(`eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]*`)
	pgURLRe = regexp.MustCompile(`(?i)(postgres(?:ql)?|redis|rediss)://[^:\s]+:[^@\s]+@`)
	phoneRe = regexp.MustCompile(`\+?\d[\d\s\-().]{7,}\d`)
)

// IsSensitive reports whether a field name carries PII or secrets.
func IsSensitive(key string) bool {
	_, ok := SensitiveKeys[strings.ToLower(strings.TrimSpace(key))]
	return ok
}

// sensitiveFragments match derived column names that the exact SensitiveKeys
// set cannot list: `password_hash`, `refresh_token_hash`, `license_no_enc`,
// `totp_secret_enc`. Fragments are deliberately narrow so ordinary columns
// (`shipping_document_id`) are not swallowed.
var sensitiveFragments = []string{
	"password", "token", "secret", "license", "ssn", "cvv", "card_number",
	"api_key", "apikey", "credential", "recovery_code", "_pin", "pin_",
	"encryption_key", "_enc",
}

// IsSensitiveName reports whether a column or field name carries a secret or
// PII, including the derived names stored in audit_log.field.
func IsSensitiveName(key string) bool {
	k := strings.ToLower(strings.TrimSpace(key))
	if IsSensitive(k) {
		return true
	}
	for _, f := range sensitiveFragments {
		if strings.Contains(k, f) {
			return true
		}
	}
	return false
}

// Redacted is the replacement written over a masked value.
const Redacted = redacted

// MaskValue redacts a value entirely if its key is sensitive.
func MaskValue(key, value string) string {
	if IsSensitive(key) {
		return redacted
	}
	return value
}

// MaskEmail keeps the first character and the domain: j***@example.com.
func MaskEmail(email string) string {
	at := strings.LastIndex(email, "@")
	if at <= 0 {
		return redacted
	}
	return email[:1] + "***" + email[at:]
}

// MaskTail keeps only the last n characters of a value.
func MaskTail(v string, n int) string {
	r := []rune(v)
	if len(r) <= n || n <= 0 {
		return redacted
	}
	return "***" + string(r[len(r)-n:])
}

// MaskSecrets scrubs tokens, credentials, emails and phone numbers from a free
// form string (log messages, upstream error texts).
func MaskSecrets(s string) string {
	if s == "" {
		return s
	}
	s = jwtRe.ReplaceAllString(s, redacted)
	s = bearerRe.ReplaceAllString(s, "Bearer "+redacted)
	s = pgURLRe.ReplaceAllString(s, "$1://"+redacted+"@")
	s = emailRe.ReplaceAllString(s, redacted)
	s = phoneRe.ReplaceAllStringFunc(s, func(m string) string {
		// `\d[\d\s\-().]{7,}\d` also matches a bare ISO date (2026-09-06):
		// same shape, no phone number underneath. Leave real dates alone.
		if _, err := time.Parse(time.DateOnly, m); err == nil {
			return m
		}
		return redacted
	})
	return s
}

// MaskQuery redacts sensitive query parameters, keeping the key names.
func MaskQuery(raw string) string {
	if raw == "" {
		return ""
	}
	values, err := url.ParseQuery(raw)
	if err != nil {
		return redacted
	}
	for k, vs := range values {
		if IsSensitive(k) {
			for i := range vs {
				vs[i] = redacted
			}
			values[k] = vs
		}
	}
	return values.Encode()
}

// MaskPath scrubs a request path of anything that resembles a secret.
func MaskPath(p string) string {
	return MaskSecrets(p)
}

// MaskMap returns a shallow copy of m with sensitive values redacted.
func MaskMap(m map[string]any) map[string]any {
	if m == nil {
		return nil
	}
	out := make(map[string]any, len(m))
	for k, v := range m {
		if IsSensitive(k) {
			out[k] = redacted
			continue
		}
		if s, ok := v.(string); ok {
			out[k] = MaskSecrets(s)
			continue
		}
		if nested, ok := v.(map[string]any); ok {
			out[k] = MaskMap(nested)
			continue
		}
		out[k] = v
	}
	return out
}
