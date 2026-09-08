package main

import (
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/server"
)

// guardInclude decides, for one module, which mutating routes the tenant
// subscription write guard applies to. A nil include guards every
// POST/PUT/PATCH/DELETE the module registers.
type guardInclude func(method, pattern string) bool

// guardAll matches every mutating route of the module it is attached to.
func guardAll(string, string) bool { return true }

// guardPrefix matches every mutating route whose pattern starts with prefix,
// relative to wherever the module itself mounted its router (Q — defect-types
// sits in the DVIR module's flat route group, not behind its own Route()).
func guardPrefix(prefix string) guardInclude {
	return func(_, pattern string) bool { return strings.HasPrefix(pattern, prefix) }
}

// guardPatterns matches an explicit set of route patterns (Q — log edit
// approve/reject are the only DVIR-adjacent admin actions inside the driver
// facing logs module).
func guardPatterns(patterns ...string) guardInclude {
	set := make(map[string]struct{}, len(patterns))
	for _, p := range patterns {
		set[p] = struct{}{}
	}
	return func(_, pattern string) bool {
		_, ok := set[pattern]
		return ok
	}
}

// guardMethodAndPattern matches one exact method/pattern pair (Q75 — only
// queuing an export is gated, reading a job never is).
func guardMethodAndPattern(method, pattern string) guardInclude {
	return func(m, p string) bool { return m == method && p == pattern }
}

// guardWrite wraps a module so RequireWritableSubscription applies to the
// mutating routes `include` selects, without the module's own RegisterRoutes
// ever importing internal/middleware for it. Every module keeps registering
// its own permission, rate limit and idempotency middlewares untouched; the
// guard is appended to the per-route chain right before the handler, so it
// always runs after the group level Authenticate/RequireCompany/Scope, which
// is where the principal and the tenant first land in the request context.
//
// A nil guard is a no-op: the module is returned unwrapped.
func guardWrite(mod server.Module, guard func(http.Handler) http.Handler, include guardInclude) server.Module {
	if guard == nil || mod == nil {
		return mod
	}
	if include == nil {
		include = guardAll
	}
	return guardedModule{mod: mod, guard: guard, include: include}
}

// guardedModule implements server.Module by handing the wrapped module a
// chi.Router that intercepts its mutating route registrations.
type guardedModule struct {
	mod     server.Module
	guard   func(http.Handler) http.Handler
	include guardInclude
}

// RegisterRoutes implements server.Module.
func (g guardedModule) RegisterRoutes(r chi.Router) {
	g.mod.RegisterRoutes(&writeGuardRouter{Router: r, guard: g.guard, include: g.include})
}

// writeGuardRouter decorates chi.Router so every POST/PUT/PATCH/DELETE the
// wrapped module registers optionally gets one extra middleware. Read routes
// (Get, Head, Options, Handle, Mount, ...) are never touched: they are
// promoted straight through the embedded chi.Router.
type writeGuardRouter struct {
	chi.Router
	guard   func(http.Handler) http.Handler
	include guardInclude
}

// apply returns the router the verb registration should use: the same one
// with the guard appended when include selects this method/pattern pair,
// otherwise the router untouched.
func (w *writeGuardRouter) apply(method, pattern string) chi.Router {
	if w.include(method, pattern) {
		return w.Router.With(w.guard)
	}
	return w.Router
}

// Post implements chi.Router.
func (w *writeGuardRouter) Post(pattern string, h http.HandlerFunc) {
	w.apply(http.MethodPost, pattern).Post(pattern, h)
}

// Put implements chi.Router.
func (w *writeGuardRouter) Put(pattern string, h http.HandlerFunc) {
	w.apply(http.MethodPut, pattern).Put(pattern, h)
}

// Patch implements chi.Router.
func (w *writeGuardRouter) Patch(pattern string, h http.HandlerFunc) {
	w.apply(http.MethodPatch, pattern).Patch(pattern, h)
}

// Delete implements chi.Router.
func (w *writeGuardRouter) Delete(pattern string, h http.HandlerFunc) {
	w.apply(http.MethodDelete, pattern).Delete(pattern, h)
}

// With implements chi.Router. The inline router chi.Router.With returns must
// stay wrapped, otherwise the verb call chained onto it (the module's own
// `.With(perm, ...).Post(...)` pattern) would bypass Post/Put/Patch/Delete
// above.
func (w *writeGuardRouter) With(mws ...func(http.Handler) http.Handler) chi.Router {
	return &writeGuardRouter{Router: w.Router.With(mws...), guard: w.guard, include: w.include}
}

// Group implements chi.Router, keeping the guard attached to the sub-router
// the module's callback receives.
func (w *writeGuardRouter) Group(fn func(r chi.Router)) chi.Router {
	return w.Router.Group(func(r chi.Router) {
		fn(&writeGuardRouter{Router: r, guard: w.guard, include: w.include})
	})
}

// Route implements chi.Router, keeping the guard attached to the mounted
// sub-router the module's callback receives.
func (w *writeGuardRouter) Route(pattern string, fn func(r chi.Router)) chi.Router {
	return w.Router.Route(pattern, func(r chi.Router) {
		fn(&writeGuardRouter{Router: r, guard: w.guard, include: w.include})
	})
}
