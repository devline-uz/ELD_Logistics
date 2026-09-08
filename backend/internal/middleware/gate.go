package middleware

import (
	"crypto/sha256"
	"crypto/subtle"
	"net/http"
	"net/netip"
	"strings"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/httpx"
)

// GateOptions configures an infrastructure surface guard (/metrics,
// /api/docs). These endpoints carry no principal, so they are protected by a
// static bearer token, a source address allowlist, or both.
type GateOptions struct {
	// Name appears in the error message only.
	Name string
	// Enabled turns the surface off entirely; a disabled surface answers 404
	// so its existence is not confirmed.
	Enabled bool
	// Token is the expected bearer credential. Empty disables token auth.
	Token string
	// AllowCIDR lists source networks (or bare addresses) that skip the token.
	AllowCIDR []string
	// Open lets an unconfigured surface stay reachable. It must only be true
	// in development: config.Validate rejects an unguarded surface in
	// staging/production.
	Open bool
}

// Gate protects a route group that has no authenticated principal. Precedence:
// disabled wins over everything, then the address allowlist, then the token,
// and finally Open for development runs.
func Gate(opts GateOptions) func(http.Handler) http.Handler {
	name := opts.Name
	if name == "" {
		name = "endpoint"
	}
	prefixes := parsePrefixes(opts.AllowCIDR)
	tokenSum := sha256.Sum256([]byte(opts.Token))

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if !opts.Enabled {
				httpx.WriteError(w, r, apierr.NotFound("endpoint"))
				return
			}
			if len(prefixes) > 0 && addrAllowed(prefixes, httpx.ClientIP(r)) {
				next.ServeHTTP(w, r)
				return
			}
			if opts.Token != "" {
				// Only the Authorization header is accepted: a token in the
				// query string would end up in access logs and referrers.
				got, _ := bearerToken(r)
				// Hashing both sides keeps the comparison constant time and
				// independent of the credential length.
				gotSum := sha256.Sum256([]byte(got))
				if got != "" && subtle.ConstantTimeCompare(gotSum[:], tokenSum[:]) == 1 {
					next.ServeHTTP(w, r)
					return
				}
				w.Header().Set("WWW-Authenticate", `Bearer realm="`+name+`"`)
				httpx.WriteError(w, r, apierr.Unauthorized(name+" requires a bearer token"))
				return
			}
			if opts.Open {
				next.ServeHTTP(w, r)
				return
			}
			httpx.WriteError(w, r, apierr.NotFound("endpoint"))
		})
	}
}

func parsePrefixes(entries []string) []netip.Prefix {
	out := make([]netip.Prefix, 0, len(entries))
	for _, raw := range entries {
		raw = strings.TrimSpace(raw)
		if raw == "" {
			continue
		}
		if p, err := netip.ParsePrefix(raw); err == nil {
			out = append(out, p)
			continue
		}
		if a, err := netip.ParseAddr(raw); err == nil {
			out = append(out, netip.PrefixFrom(a, a.BitLen()))
		}
	}
	return out
}

func addrAllowed(prefixes []netip.Prefix, ip string) bool {
	addr, err := netip.ParseAddr(strings.TrimSpace(ip))
	if err != nil {
		return false
	}
	addr = addr.Unmap()
	for _, p := range prefixes {
		if p.Contains(addr) {
			return true
		}
	}
	return false
}
