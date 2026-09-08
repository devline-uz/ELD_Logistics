// Package auditlog serves the audit journal (TZ A§17). `audit_log` is
// append-only — a database trigger rejects UPDATE and DELETE — so this module
// exposes read routes only. Every `old_value` / `new_value` leaves the server
// masked: password hashes, session tokens and driver licence numbers are
// redacted before serialisation.
package auditlog

import (
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/auditlog/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// Deps are the audit log module dependencies. Repo and Verifier are required;
// Store is optional and only backs the per user rate limit.
type Deps struct {
	Repo     Repo
	Verifier mw.AuthVerifier
	Store    cache.Store
}

// Module wires the audit log routes into the /api/v1 router. It implements
// server.Module.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
	store    cache.Store
}

// New builds the audit log HTTP module.
func New(deps Deps) *Module {
	return &Module{
		svc:      NewService(deps.Repo),
		verifier: deps.Verifier,
		store:    deps.Store,
	}
}

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Group(func(g chi.Router) {
		// Unconditional: a module wired without a verifier must fail closed
		// (mw.Authenticate answers 503), never serve the audit trail
		// unauthenticated.
		g.Use(mw.Authenticate(m.verifier))
		g.Use(mw.RequireFullSession)
		g.Use(mw.RequireCompany)
		g.Use(mw.Scope)
		if m.store != nil {
			g.Use(mw.UserRateLimit(m.store, mw.DefaultPerUserPerMinute))
		}

		g.Route("/audit-log", func(a chi.Router) {
			a.With(mw.RequirePermission(auth.PermAuditView)).Get("/", m.list)
			a.With(mw.RequirePermission(auth.PermAuditView)).Get("/tables", m.tables)
		})
	})
}

// list godoc
//
//	@Summary      List audit log entries
//	@Description  TZ A§17 — the single audit trail; the four journals of the UI are filtered views of this endpoint. Newest first by default. `old_value` and `new_value` are masked: a password hash, session token, encrypted column or driver licence number is returned as `[REDACTED]` and `masked` is true. The table is append-only, so there is no create, update or delete route.
//	@Tags         audit
//	@Produce      json
//	@Param        page       query     int     false  "Page number"                        default(1)
//	@Param        per_page   query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        order      query     string  false  "Timestamp order"  Enums(asc, desc)  default(desc)
//	@Param        table      query     string  false  "Audited table name"  example(support_tickets)
//	@Param        record_id  query     string  false  "Audited row id (uuid)"
//	@Param        user       query     string  false  "Acting user id (uuid), matches audit_log.edited_by"
//	@Param        action     query     string  false  "Audited action"  example(update)
//	@Param        from       query     string  false  "Timestamp at or after (RFC3339)"
//	@Param        to         query     string  false  "Timestamp before (RFC3339)"
//	@Success      200  {object}  dto.EntryListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "audit.view"
//	@Router       /audit-log [get]
func (m *Module) list(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, []string{"ts"}, httpx.Sort{Field: "ts", Order: "desc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	recordID, err := httpx.QueryUUID(r, "record_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	userID, err := httpx.QueryUUID(r, "user")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	from, err := httpx.QueryTime(r, "from")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	to, err := httpx.QueryTime(r, "to")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	table, err := identifier(r, "table")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	action, err := identifier(r, "action")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	entries, total, err := m.svc.List(r.Context(), Filter{
		TableName: table,
		RecordID:  recordID,
		UserID:    userID,
		Action:    action,
		From:      from,
		To:        to,
		Order:     sort.Order,
		Limit:     page.Limit(),
		Offset:    page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, entries, page.Meta(total))
}

// tables godoc
//
//	@Summary      List audited table names
//	@Description  Distinct `audit_log.table_name` values of the company, for the filter dropdown of the audit journal screen.
//	@Tags         audit
//	@Produce      json
//	@Success      200  {object}  dto.TableListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Security     BearerAuth
//	@x-permission "audit.view"
//	@Router       /audit-log/tables [get]
func (m *Module) tables(w http.ResponseWriter, r *http.Request) {
	out, err := m.svc.Tables(r.Context())
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// identifier reads an optional lower case identifier filter. The value reaches
// SQL as a bound parameter, but the shape is still validated so a typo fails
// loudly instead of silently returning an empty page.
func identifier(r *http.Request, key string) (*string, error) {
	v := strings.TrimSpace(r.URL.Query().Get(key))
	if v == "" {
		return nil, nil
	}
	if len(v) > 64 || strings.IndexFunc(v, func(c rune) bool {
		return c != '_' && (c < 'a' || c > 'z') && (c < '0' || c > '9')
	}) >= 0 {
		return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
			Field: key, Message: "must be a lower case identifier",
		})
	}
	return &v, nil
}

// swaggerRefs keeps the envelope types referenced by the annotations reachable
// for swag's type walker.
var _ = []any{dto.EntryListEnvelope{}, dto.TableListEnvelope{}, dto.ErrorResponse{}}
