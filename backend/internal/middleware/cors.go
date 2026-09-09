package middleware

import (
	"net/http"
	"strconv"
	"strings"
	"time"
)

// CORSOptions configures the origin allowlist.
type CORSOptions struct {
	AllowedOrigins []string
	AllowedMethods []string
	AllowedHeaders []string
	ExposedHeaders []string
	MaxAge         time.Duration
	AllowAll       bool // development convenience; never enable in production
}

// DefaultCORS builds options from the environment allowlist.
func DefaultCORS(origins []string, allowAll bool) CORSOptions {
	return CORSOptions{
		AllowedOrigins: origins,
		AllowedMethods: []string{http.MethodGet, http.MethodPost, http.MethodPut,
			http.MethodPatch, http.MethodDelete, http.MethodOptions},
		// Nomlar haqiqiy handler/middleware o'qiydigan nomlar bilan bir xil
		// bo'lishi shart: brauzer preflight javobida yo'q header'ni ko'rsa
		// so'rovni umuman yubormaydi. `Idempotency-Key` — swagger parametri va
		// `HeaderIdempotencyKey`; `X-Company-Id` — `HeaderCompanyID`.
		AllowedHeaders: []string{"Authorization", "Content-Type", "Accept",
			HeaderRequestID, HeaderIdempotencyKey, HeaderCompanyID,
			"X-Device-Id", "X-App-Version"},
		ExposedHeaders: []string{HeaderRequestID, "Retry-After", "X-RateLimit-Remaining"},
		MaxAge:         10 * time.Minute,
		AllowAll:       allowAll,
	}
}

// CORS enforces the configured origin allowlist and answers preflights.
func CORS(opts CORSOptions) func(http.Handler) http.Handler {
	allowed := make(map[string]struct{}, len(opts.AllowedOrigins))
	for _, o := range opts.AllowedOrigins {
		if o = strings.TrimSpace(o); o != "" {
			allowed[strings.ToLower(o)] = struct{}{}
		}
	}
	methods := strings.Join(opts.AllowedMethods, ", ")
	headers := strings.Join(opts.AllowedHeaders, ", ")
	exposed := strings.Join(opts.ExposedHeaders, ", ")
	maxAge := strconv.Itoa(int(opts.MaxAge.Seconds()))

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			origin := r.Header.Get("Origin")
			if origin == "" {
				next.ServeHTTP(w, r)
				return
			}

			_, ok := allowed[strings.ToLower(origin)]
			if !ok && !opts.AllowAll {
				if r.Method == http.MethodOptions {
					w.WriteHeader(http.StatusNoContent)
					return
				}
				next.ServeHTTP(w, r)
				return
			}

			h := w.Header()
			h.Set("Access-Control-Allow-Origin", origin)
			// The API authenticates with a Bearer token, never a cookie. Not
			// sending Allow-Credentials keeps a reflected origin (AllowAll in
			// development) from turning into an ambient-authority hole.
			h.Add("Vary", "Origin")
			if exposed != "" {
				h.Set("Access-Control-Expose-Headers", exposed)
			}

			if r.Method == http.MethodOptions {
				h.Set("Access-Control-Allow-Methods", methods)
				h.Set("Access-Control-Allow-Headers", headers)
				h.Set("Access-Control-Max-Age", maxAge)
				h.Add("Vary", "Access-Control-Request-Method")
				h.Add("Vary", "Access-Control-Request-Headers")
				w.WriteHeader(http.StatusNoContent)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
