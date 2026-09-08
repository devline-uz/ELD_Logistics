// Package support serves the help desk of the company: support tickets with a
// message thread (TZ A§15 Q77-Q79) and the driver app feedback form (Q80).
// A driver holds the `self` scope and only ever sees the tickets it owns.
package support

import (
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Deps are the support module dependencies. Repo and Verifier are required;
// Store is optional and only backs the rate limit / idempotency guards.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	// Store backs the optional Idempotency-Key replay cache on POST routes.
	Store cache.Store
}

// Module wires the support routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the support HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// Sort whitelists. Anything outside them is rejected with 422.
var (
	ticketSorts   = []string{"created_at", "status", "subject"}
	feedbackSorts = []string{"submitted_at", "app_rating"}
)

// writeRateLimit is the per user budget of the support mutation endpoints.
const writeRateLimit = 60

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		// Unconditional: a module wired without a verifier must fail closed
		// (mw.Authenticate answers 503), never serve tickets unauthenticated.
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}

		g.Route("/support-tickets", func(t chi.Router) {
			t.With(mw.RequirePermission(auth.PermSupportRead)).Get("/", m.listTickets)
			t.With(m.writeGuards(auth.PermSupportCreate)...).Post("/", m.createTicket)
			t.With(mw.RequirePermission(auth.PermSupportRead)).Get("/{id}", m.getTicket)
			t.With(mw.RequirePermission(auth.PermSupportUpdateStatus)).
				Patch("/{id}/status", m.setTicketStatus)
			t.With(mw.RequirePermission(auth.PermSupportRead)).Get("/{id}/messages", m.listMessages)
			t.With(m.writeGuards(auth.PermSupportCreate)...).Post("/{id}/messages", m.addMessage)
		})

		g.Route("/feedback", func(f chi.Router) {
			f.With(mw.RequirePermission(auth.PermFeedbackRead)).Get("/", m.listFeedback)
			f.With(m.writeGuards(auth.PermFeedbackCreate)...).Post("/", m.createFeedback)
		})
	})
}

// writeGuards is the middleware chain of a mutation route: permission, per user
// rate limit and the optional Idempotency-Key replay cache.
func (m *Module) writeGuards(perm string) []func(http.Handler) http.Handler {
	chain := []func(http.Handler) http.Handler{mw.RequirePermission(perm)}
	if m.store != nil {
		chain = append(chain, mw.UserRateLimit(m.store, writeRateLimit), mw.Idempotency(m.store, false))
	}
	return chain
}
