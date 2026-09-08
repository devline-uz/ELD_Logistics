package sync

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/sync/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Deps are the sync module dependencies. Repo, Duty and Verifier are required;
// Store adds the per device rate limit and the Idempotency-Key replay cache.
type Deps struct {
	Repo Repo
	// Duty owns the duty status write path and the HOS policy.
	Duty DutyService
	// Telemetry owns trips, the unidentified buffer and the live map.
	Telemetry TelemetryIngestor
	Verifier  mw.AuthVerifier
	// Store backs the sync rate limit and the idempotent response replay.
	Store cache.Store
	// Now is injectable so `server_time` and the pull cursor are testable.
	Now func() time.Time
	Log *slog.Logger
}

// Module wires the offline sync routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the sync HTTP module.
func New(d Deps) *Module {
	return &Module{
		svc:      NewService(d.Repo, d.Duty, d.Telemetry, d.Now, d.Log),
		verifier: d.Verifier,
		store:    d.Store,
	}
}

// Service exposes the sync service for tests and background drains.
func (m *Module) Service() *Service { return m.svc }

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		// Unconditional: a module wired without a verifier must fail closed
		// (mw.Authenticate answers 503), never accept an anonymous upload.
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		// 60 requests per minute per device (TZ B§3.2).
		g.Use(mw.SyncRateLimit(m.store))

		// There is no `sync.*` permission key: the protocol operates on the
		// caller's own log, so `logs.read` is the gate every driver role
		// carries and the driver record itself is the second check (a caller
		// that is not a driver gets 403 from the service).
		//
		// Idempotency-Key is mandatory on push: a retried upload replays the
		// recorded response instead of re-deciding the batch.
		g.With(mw.RequirePermission(auth.PermLogsRead), mw.Idempotency(m.store, true)).
			Post("/sync/push", m.push)
		g.With(mw.RequirePermission(auth.PermLogsRead)).Get("/sync/pull", m.pull)
	})
}

// push godoc
//
//	@Summary      Upload an offline batch
//	@Description  TZ D§2 — the driver app drains its offline queue here. Each element is answered individually with `accepted`, `duplicate` or `rejected(reason)`; a duplicate `client_event_id` is never an error. Conflict rules: an event more than five minutes ahead of the server is `rejected(time_in_future)`; an event on a certified day is `rejected(log_locked)`; two devices claiming the same instant are resolved by `time_source` priority (eld_rtc > server > phone) then by the larger `device_seq`, and the loser is still stored with `superseded_by` set and reported as `accepted` with `reason=superseded`. The server also enforces the duty rules it owns: PC/YM need `hos_policy.allow_pc`/`allow_ym`, SB needs a sleeper berth on the unit, DR is never selected by hand, and motion at or above `motion_threshold_kmh` coerces the status to DR. Ceilings: 500 events, 5000 telemetry points, 100 DVIR, 500 chat. `Idempotency-Key` is required. DVIR and chat elements are acknowledged but only processed from stages 5-6 on.
//	@Tags         sync
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string          true  "Idempotency key; a repeat replays the recorded response for 24h"
//	@Param        body             body    dto.PushRequest true  "Offline batch"
//	@Success      200  {object}  dto.PushEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST — Idempotency-Key missing"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN — the caller is not a driver"
//	@Failure      409  {object}  dto.ErrorResponse  "IDEMPOTENCY_CONFLICT"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR, BATCH_TOO_LARGE"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.read"
//	@Router       /sync/push [post]
func (m *Module) push(w http.ResponseWriter, r *http.Request) {
	var body dto.PushRequest
	if err := httpx.DecodeAndValidate(r, &body); err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	out, err := m.svc.Push(r.Context(), PushInput{
		CompanyID: tenant.CompanyID(r.Context()),
		UserID:    tenant.UserID(r.Context()),
		Request:   body,
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// pull godoc
//
//	@Summary      Download server changes
//	@Description  TZ D§2 — everything the device has to catch up on since `since`: pending log edit requests, the unidentified driving buffer of the driver's unit (A§10.4), the server's canonical copies of changed duty status events and log days (conflict rule 2 — the server wins and the device rebuilds its local log), the current `hos_policy`, the DVIR defect catalogue, the quick-note templates and new chat messages. `next_since` is the newest `updated_at` actually returned, so a truncated page (`truncated=true`) resumes exactly where it stopped. Without `since` the default window is the last 8 days. A Driver reads its own data only.
//	@Tags         sync
//	@Produce      json
//	@Param        since    query  string  false  "Cursor from the previous pull, RFC3339"
//	@Param        unit_id  query  string  false  "Unit the driver is logged into; selects the unidentified driving buffer"
//	@Success      200  {object}  dto.PullEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN — the caller is not a driver"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "logs.read"
//	@Router       /sync/pull [get]
func (m *Module) pull(w http.ResponseWriter, r *http.Request) {
	since, err := httpx.QueryTime(r, "since")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	unitID, err := httpx.QueryUUID(r, "unit_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	in := PullInput{
		CompanyID: tenant.CompanyID(r.Context()),
		UserID:    tenant.UserID(r.Context()),
		UnitID:    unitID,
	}
	if since != nil {
		in.Since = since.UTC()
	}

	out, err := m.svc.Pull(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}
