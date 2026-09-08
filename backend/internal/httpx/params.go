package httpx

import (
	"fmt"
	"net"
	"net/http"
	"net/netip"
	"strings"
	"sync"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
)

// URLParamUUID reads a required uuid path parameter.
func URLParamUUID(r *http.Request, key string) (uuid.UUID, error) {
	raw := chi.URLParam(r, key)
	id, err := uuid.Parse(raw)
	if err != nil {
		return uuid.Nil, apierr.Validation("invalid path parameter", apierr.FieldError{
			Field: key, Message: "must be a valid uuid",
		})
	}
	return id, nil
}

// QueryUUID reads an optional uuid query parameter.
func QueryUUID(r *http.Request, key string) (*uuid.UUID, error) {
	raw := r.URL.Query().Get(key)
	if raw == "" {
		return nil, nil
	}
	id, err := uuid.Parse(raw)
	if err != nil {
		return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
			Field: key, Message: "must be a valid uuid",
		})
	}
	return &id, nil
}

// QueryTime reads an optional RFC3339 timestamp query parameter (UTC).
func QueryTime(r *http.Request, key string) (*time.Time, error) {
	raw := r.URL.Query().Get(key)
	if raw == "" {
		return nil, nil
	}
	t, err := time.Parse(time.RFC3339, raw)
	if err != nil {
		return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
			Field: key, Message: "must be an RFC3339 timestamp",
		})
	}
	t = t.UTC()
	return &t, nil
}

// QueryDate reads an optional YYYY-MM-DD query parameter (UTC midnight).
func QueryDate(r *http.Request, key string) (*time.Time, error) {
	raw := r.URL.Query().Get(key)
	if raw == "" {
		return nil, nil
	}
	t, err := time.Parse(time.DateOnly, raw)
	if err != nil {
		return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
			Field: key, Message: "must be a YYYY-MM-DD date",
		})
	}
	return &t, nil
}

// trustedProxies is the allowlist of peers whose X-Forwarded-For / X-Real-IP
// headers may be believed. It is empty by default: an unproxied deployment
// MUST NOT take the client address from a header, otherwise the login rate
// limit (5/min/IP) and the audit trail are trivially spoofed by sending
// `X-Forwarded-For: <random>` on every attempt.
var (
	trustedProxiesMu sync.RWMutex
	trustedProxies   []netip.Prefix
)

// SetTrustedProxies installs the reverse proxy allowlist (CIDR notation).
// Passing an empty slice disables header based client address resolution.
func SetTrustedProxies(cidrs []string) error {
	out := make([]netip.Prefix, 0, len(cidrs))
	for _, raw := range cidrs {
		raw = strings.TrimSpace(raw)
		if raw == "" {
			continue
		}
		if !strings.Contains(raw, "/") {
			addr, err := netip.ParseAddr(raw)
			if err != nil {
				return fmt.Errorf("httpx: trusted proxy %q is not an address or CIDR", raw)
			}
			out = append(out, netip.PrefixFrom(addr, addr.BitLen()))
			continue
		}
		prefix, err := netip.ParsePrefix(raw)
		if err != nil {
			return fmt.Errorf("httpx: trusted proxy %q is not a CIDR: %w", raw, err)
		}
		out = append(out, prefix.Masked())
	}

	trustedProxiesMu.Lock()
	trustedProxies = out
	trustedProxiesMu.Unlock()
	return nil
}

// isTrustedProxy reports whether addr is one of the configured reverse proxies.
func isTrustedProxy(addr netip.Addr) bool {
	trustedProxiesMu.RLock()
	defer trustedProxiesMu.RUnlock()
	if len(trustedProxies) == 0 {
		return false
	}
	addr = addr.Unmap()
	for _, p := range trustedProxies {
		if p.Contains(addr) {
			return true
		}
	}
	return false
}

// parseAddr normalises a host, "host:port" or bracketed IPv6 literal.
func parseAddr(v string) (netip.Addr, bool) {
	v = trimSpace(v)
	if v == "" {
		return netip.Addr{}, false
	}
	if ap, err := netip.ParseAddrPort(v); err == nil {
		return ap.Addr().Unmap(), true
	}
	if host, _, err := net.SplitHostPort(v); err == nil {
		v = host
	}
	v = strings.Trim(v, "[]")
	// Drop an IPv6 zone: "fe80::1%eth0".
	if i := strings.IndexByte(v, '%'); i >= 0 {
		v = v[:i]
	}
	addr, err := netip.ParseAddr(v)
	if err != nil {
		return netip.Addr{}, false
	}
	return addr.Unmap(), true
}

// ClientIP extracts the caller address. X-Forwarded-For and X-Real-IP are only
// believed when the immediate peer is a configured trusted proxy
// (SetTrustedProxies); otherwise the transport level address wins, so a client
// cannot choose its own rate limit bucket or forge the IP written to
// audit_log.
func ClientIP(r *http.Request) string {
	peer, ok := parseAddr(r.RemoteAddr)
	if !ok {
		// Unparsable peer (httptest and unit tests use a bare label): fall back
		// to the raw value and never trust a header.
		return trimSpace(r.RemoteAddr)
	}
	if !isTrustedProxy(peer) {
		return peer.String()
	}

	// Walk X-Forwarded-For right to left and return the first address that is
	// not itself a trusted proxy: everything to its left is client controlled.
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		parts := strings.Split(xff, ",")
		for i := len(parts) - 1; i >= 0; i-- {
			addr, ok := parseAddr(parts[i])
			if !ok {
				break
			}
			if !isTrustedProxy(addr) {
				return addr.String()
			}
		}
	}
	if addr, ok := parseAddr(r.Header.Get("X-Real-IP")); ok {
		return addr.String()
	}
	return peer.String()
}

func trimSpace(s string) string {
	start, end := 0, len(s)
	for start < end && (s[start] == ' ' || s[start] == '\t') {
		start++
	}
	for end > start && (s[end-1] == ' ' || s[end-1] == '\t') {
		end--
	}
	return s[start:end]
}
