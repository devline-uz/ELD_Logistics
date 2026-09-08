package dashboard

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/dashboard/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
)

// Deps are the dashboard module dependencies. Repo and Verifier are required.
type Deps struct {
	Repo      Repo
	Verifier  mw.AuthVerifier
	Store     cache.Store
	Publisher ws.Publisher
	Log       *slog.Logger
	// Now is injectable so the company timezone day boundary is testable.
	Now func() time.Time
}

// Module wires the dashboard route into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the dashboard HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo, deps.Publisher, deps.Log, deps.Now),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// Service exposes the business layer to a composing module (the WebSocket
// dashboard channel republishes the same payload).
func (m *Module) Service() *Service { return m.svc }

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}
		g.With(mw.RequirePermission(auth.PermDashboardRead)).Get("/dashboard/summary", m.summary)
	})
}

// summary godoc
//
//	@Summary      Dashboard summary
//	@Description  TZ A§20 — the KPI cards, the current duty status block and today's routes. Every window is cut on the company timezone: `active_units` counts the units that reported telemetry today, `drivers_on_duty` the drivers currently in ON or DR, `violations` the violations of the current ISO week (Monday–Sunday), `uncertified_logs` the logs uncertified for two days or more, and `unassigned_driving` the unidentified driving events still pending. `disconnected_eld` is the stored connectivity state; `malfunction_eld` is derived from the device diagnostics. A branch scoped principal sees only its own branch in the route block. The same payload is republished on the WebSocket `dashboard` channel, so a client either polls this endpoint every 60 seconds or subscribes.
//	@Tags         dashboard
//	@Produce      json
//	@Success      200  {object}  dto.SummaryEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "dashboard.read"
//	@Router       /dashboard/summary [get]
func (m *Module) summary(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	if _, ok := tenant.PrincipalFrom(ctx); !ok {
		httpx.WriteError(w, r, apierr.Unauthorized("authentication required"))
		return
	}
	var branchID *uuid.UUID
	if sf, ok := mw.ScopeFrom(ctx); ok && sf.Scope == tenant.ScopeBranch {
		branchID = sf.BranchID
	}
	var out dto.Summary
	out, err := m.svc.Summary(ctx, branchID)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}
