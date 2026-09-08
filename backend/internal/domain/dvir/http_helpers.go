package dvir

import (
	"net/http"
	"strings"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/tenant"
)

// ---------------------------------------------------------------- helpers

// resolve loads the report of {id} and applies the caller scope. A report the
// caller may not see answers 404, never 403.
func (m *Module) resolve(r *http.Request) (*dto.DvirReport, error) {
	id, err := httpx.URLParamUUID(r, "id")
	if err != nil {
		return nil, err
	}
	rep, err := m.svc.Get(r.Context(), id)
	if err != nil {
		return nil, err
	}
	if self, ok := m.selfDriverID(r); ok && rep.Driver != nil && rep.Driver.ID != self.String() {
		return nil, apierr.NotFound("dvir report")
	}
	return rep, nil
}

// selfDriverID returns the caller's driver id when the principal is self
// scoped, so list and detail never leak another driver's inspection.
func (m *Module) selfDriverID(r *http.Request) (uuid.UUID, bool) {
	f, ok := mw.ScopeFrom(r.Context())
	if !ok || f.Scope != tenant.ScopeSelf {
		return uuid.Nil, false
	}
	driver, err := m.svc.SelfDriver(r.Context())
	if err != nil {
		return uuid.Nil, false
	}
	return driver.ID, true
}

// queryEnum reads an optional query parameter constrained to a whitelist.
func queryEnum(r *http.Request, key string, allowed ...string) (*string, error) {
	raw := strings.TrimSpace(r.URL.Query().Get(key))
	if raw == "" {
		return nil, nil
	}
	for _, a := range allowed {
		if raw == a {
			v := raw
			return &v, nil
		}
	}
	return nil, apierr.Validation("unsupported "+key,
		apierr.FieldError{Field: key, Message: "must be one of " + strings.Join(allowed, ", ")})
}
