package auditlog

import (
	"encoding/json"

	"github.com/devline/onebook-eld/internal/httpx"
)

// maskJSON decodes one `audit_log.old_value` / `new_value` column and returns a
// PII safe copy. The rules, in order:
//
//  1. a sensitive field name (password hash, session token, driver licence,
//     encrypted column) redacts the whole value, whatever its shape;
//  2. object keys are checked one by one with the same rule;
//  3. every remaining string is scrubbed of JWTs, bearer tokens, connection
//     strings, e-mail addresses and phone numbers.
//
// The second return value reports whether anything was redacted, so the API can
// tell the client the row is masked rather than empty.
func maskJSON(field string, raw []byte) (any, bool) {
	if len(raw) == 0 {
		return nil, false
	}
	if httpx.IsSensitiveName(field) {
		return httpx.Redacted, true
	}
	var v any
	if err := json.Unmarshal(raw, &v); err != nil {
		// An unparsable value is treated as opaque: never echoed verbatim.
		return httpx.Redacted, true
	}
	return maskAny(v)
}

func maskAny(v any) (any, bool) {
	switch t := v.(type) {
	case map[string]any:
		out := make(map[string]any, len(t))
		masked := false
		for k, val := range t {
			if httpx.IsSensitiveName(k) {
				out[k] = httpx.Redacted
				masked = true
				continue
			}
			mv, m := maskAny(val)
			out[k] = mv
			masked = masked || m
		}
		return out, masked
	case []any:
		out := make([]any, 0, len(t))
		masked := false
		for _, val := range t {
			mv, m := maskAny(val)
			out = append(out, mv)
			masked = masked || m
		}
		return out, masked
	case string:
		scrubbed := httpx.MaskSecrets(t)
		return scrubbed, scrubbed != t
	default:
		return v, false
	}
}
