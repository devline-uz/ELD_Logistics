// Package server assembles the HTTP router: global middleware, the
// infrastructure endpoints and the /api/v1 group that domain modules attach to.
package server

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	httpSwagger "github.com/swaggo/http-swagger/v2"
	"github.com/swaggo/swag"

	"github.com/devline/onebook-eld/internal/config"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/httpx/dto"
	"github.com/devline/onebook-eld/internal/metrics"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/ws"

	// Blank import registers the swag generated specification.
	_ "github.com/devline/onebook-eld/docs"
)

// Module is implemented by every domain package that exposes HTTP routes. The
// router hands it the /api/v1 sub-router, already carrying global middleware.
type Module interface {
	RegisterRoutes(r chi.Router)
}

// HealthChecker reports the readiness of a backing service.
type HealthChecker interface {
	Health(ctx context.Context) error
}

// Deps are the shared dependencies the router and infrastructure routes need.
// Domain modules receive their own dependencies at construction time.
type Deps struct {
	Logger   *slog.Logger
	DB       HealthChecker
	Redis    HealthChecker
	Verifier mw.AuthVerifier
	Hub      *ws.Hub
	Version  string
	// Pool publishes the pgx pool gauges on /metrics. Optional: a nil pool
	// simply reports zero.
	Pool metrics.PoolStater
}

// Global request limits.
const (
	defaultBodyLimit = 2 << 20 // 2 MiB
	defaultTimeout   = 60 * time.Second
)

// NewRouter builds the application handler.
func NewRouter(cfg *config.Config, deps Deps, mods ...Module) http.Handler {
	log := deps.Logger
	if log == nil {
		log = slog.Default()
	}

	r := chi.NewRouter()

	r.Use(mw.RequestID)
	r.Use(mw.Recover(log))
	r.Use(mw.RequestLogger(log))
	// After the logger so a panic is still counted, before the business
	// middleware so a 401 or 429 shows up in the latency histogram.
	r.Use(metrics.HTTPMiddleware(nil))
	r.Use(mw.SecurityHeaders)
	r.Use(mw.CORS(mw.DefaultCORS(cfg.CORSOrigins, !cfg.IsProduction() && len(cfg.CORSOrigins) == 0)))
	r.Use(mw.BodyLimit(defaultBodyLimit))
	r.Use(chimw.CleanPath)
	r.Use(chimw.Timeout(defaultTimeout))

	r.NotFound(func(w http.ResponseWriter, req *http.Request) {
		httpx.WriteError(w, req, errNotFound())
	})
	r.MethodNotAllowed(func(w http.ResponseWriter, req *http.Request) {
		httpx.WriteError(w, req, errMethodNotAllowed())
	})

	// Gauges read their source through an atomic pointer, so building a second
	// router (tests) re-points them instead of registering a duplicate.
	metrics.RegisterWS(hubCounter(deps.Hub))
	metrics.RegisterDBPool(deps.Pool)

	registerInfraRoutes(r, cfg, deps)

	r.Route("/api/v1", func(api chi.Router) {
		api.Use(mw.NoCache)
		for _, m := range mods {
			if m != nil {
				m.RegisterRoutes(api)
			}
		}
	})

	return r
}

// hubCounter avoids handing metrics a non-nil interface wrapping a nil *ws.Hub.
func hubCounter(hub *ws.Hub) metrics.WSCounter {
	if hub == nil {
		return nil
	}
	return hub
}

func registerInfraRoutes(r chi.Router, cfg *config.Config, deps Deps) {
	version := deps.Version
	if version == "" {
		version = "dev"
	}

	r.Get("/health", func(w http.ResponseWriter, _ *http.Request) {
		httpx.WriteJSON(w, http.StatusOK, dto.HealthResponse{
			Status: "ok", Version: version, Region: cfg.Region,
		})
	})

	r.Get("/ready", func(w http.ResponseWriter, req *http.Request) {
		ctx := req.Context()
		if deps.DB != nil {
			if err := deps.DB.Health(ctx); err != nil {
				httpx.WriteError(w, req, errUnavailable("database", err))
				return
			}
		}
		if deps.Redis != nil {
			if err := deps.Redis.Health(ctx); err != nil {
				httpx.WriteError(w, req, errUnavailable("redis", err))
				return
			}
		}
		httpx.WriteJSON(w, http.StatusOK, dto.HealthResponse{
			Status: "ready", Version: version, Region: cfg.Region,
		})
	})

	// /metrics leaks endpoint names, traffic volume and the Go runtime, and
	// /api/docs the whole API surface: both are gated by METRICS_*/DOCS_*.
	// Development keeps them open; config.Validate refuses an unguarded
	// surface in staging and production.
	r.With(mw.Gate(gateOptions("metrics", cfg.Metrics, cfg))).
		Handle("/metrics", promhttp.Handler())

	r.Route("/api/docs", func(d chi.Router) {
		d.Use(mw.Gate(gateOptions("api docs", cfg.Docs, cfg)))
		d.Get("/swagger.json", serveSpec)
		d.Get("/", http.RedirectHandler("/api/docs/index.html", http.StatusFound).ServeHTTP)
		d.Get("/*", httpSwagger.Handler(httpSwagger.URL("/api/docs/swagger.json")))
	})
}

// gateOptions turns an exposure config into a gate. Without any credential the
// surface stays reachable in development only.
func gateOptions(name string, e config.ExposureConfig, cfg *config.Config) mw.GateOptions {
	return mw.GateOptions{
		Name:      name,
		Enabled:   e.Enabled,
		Token:     e.Token,
		AllowCIDR: e.AllowCIDR,
		Open:      !cfg.IsProduction(),
	}
}

// serveSpec returns the raw swagger document generated by `make swag`.
func serveSpec(w http.ResponseWriter, req *http.Request) {
	doc, err := swag.ReadDoc()
	if err != nil {
		httpx.WriteError(w, req, errUnavailable("swagger spec", err))
		return
	}
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	_, _ = w.Write([]byte(doc))
}
