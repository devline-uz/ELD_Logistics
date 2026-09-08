package reports

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/storage"
)

// Deps are the reporting module dependencies. Repo and Verifier are required;
// the rest degrade gracefully so tests can wire a minimal module.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	// Files signs the download links of finished exports; nil hides them.
	Files storage.Downloader
	// Queue hands a queued job to the worker; nil leaves it queued.
	Queue Enqueuer
	// Builder renders the exports. The API only needs it so a single service
	// instance can be shared with the worker; nil is fine for the HTTP side.
	Builder *Builder
	// Store backs the per user rate limit and the Idempotency-Key replay cache.
	Store cache.Store
	Log   *slog.Logger
	Now   func() time.Time
}

// Module wires the reporting routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the reporting HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo, deps.Files, deps.Queue, deps.Builder, deps.Log, deps.Now),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// Service exposes the business layer so the worker can reuse it for the daily
// Distance by Region roll-up without building a second instance.
func (m *Module) Service() *Service { return m.svc }

// exportRateLimit is the per user budget of POST /reports/export-jobs. An
// export is expensive to produce, so it is deliberately tighter than the
// generic write budget.
const exportRateLimit = 30

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		// Unconditional: a module wired without a verifier must fail closed
		// (mw.Authenticate answers 503), never serve reports unauthenticated.
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}

		g.Route("/reports", func(rp chi.Router) {
			rp.With(mw.RequirePermission(auth.PermReportsRead)).Get("/activity", m.activity)
			rp.With(mw.RequirePermission(auth.PermReportsRead)).Get("/distance-by-region", m.distanceByRegion)
			rp.With(mw.RequirePermission(auth.PermReportsRead)).Get("/export-jobs", m.listExportJobs)
			rp.With(m.exportGuards()...).Post("/export-jobs", m.createExportJob)
			rp.With(mw.RequirePermission(auth.PermReportsRead)).Get("/export-jobs/{id}", m.getExportJob)
		})
	})
}

// exportGuards is the middleware chain of POST /reports/export-jobs.
func (m *Module) exportGuards() []func(http.Handler) http.Handler {
	chain := []func(http.Handler) http.Handler{mw.RequirePermission(auth.PermReportsExport)}
	if m.store != nil {
		chain = append(chain, mw.UserRateLimit(m.store, exportRateLimit), mw.Idempotency(m.store, false))
	}
	return chain
}
