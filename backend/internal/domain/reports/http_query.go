// Query parameter helpers shared by the reporting handlers, plus the swag
// type anchor.
package reports

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/reports/dto"
)

// queryEnum returns a whitelisted optional query parameter.
func queryEnum(r *http.Request, key string, allowed ...string) (*string, error) {
	v := strings.TrimSpace(r.URL.Query().Get(key))
	if v == "" {
		return nil, nil
	}
	for _, a := range allowed {
		if a == v {
			return &v, nil
		}
	}
	return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
		Field: key, Message: "must be one of: " + strings.Join(allowed, ", "),
	})
}

// queryInt reads a required integer query parameter.
func queryInt(r *http.Request, key string) (int, error) {
	raw := strings.TrimSpace(r.URL.Query().Get(key))
	if raw == "" {
		return 0, apierr.Validation("missing query parameter",
			apierr.FieldError{Field: key, Message: "required"})
	}
	v, err := strconv.Atoi(raw)
	if err != nil {
		return 0, apierr.Validation("invalid query parameter",
			apierr.FieldError{Field: key, Message: "must be an integer"})
	}
	return v, nil
}

// queryUUIDs reads a repeatable uuid filter. An unparseable value is rejected
// rather than silently ignored: a filter that quietly widens is a data leak in
// the making.
func queryUUIDs(r *http.Request, key string) ([]uuid.UUID, error) {
	raw := r.URL.Query()[key]
	if len(raw) == 0 {
		return nil, nil
	}
	out := make([]uuid.UUID, 0, len(raw))
	for _, chunk := range raw {
		for _, part := range strings.Split(chunk, ",") {
			part = strings.TrimSpace(part)
			if part == "" {
				continue
			}
			id, err := uuid.Parse(part)
			if err != nil {
				return nil, apierr.Validation("invalid query parameter",
					apierr.FieldError{Field: key, Message: "must be a uuid"})
			}
			out = append(out, id)
		}
	}
	if len(out) == 0 {
		return nil, nil
	}
	return out, nil
}

// swaggerRefs keeps the envelope types referenced by the annotations reachable
// for swag's type walker.
var _ = []any{
	dto.ActivityListEnvelope{}, dto.DistanceByRegionEnvelope{},
	dto.ExportJobEnvelope{}, dto.ExportJobListEnvelope{}, dto.ErrorResponse{},
}
