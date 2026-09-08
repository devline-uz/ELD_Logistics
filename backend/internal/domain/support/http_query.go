// Query parameter helpers shared by the support handlers.
package support

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/httpx"
)

// pathUUID reads the {id} path parameter.
func pathUUID(r *http.Request) (uuid.UUID, error) { return httpx.URLParamUUID(r, "id") }

// queryText returns a trimmed optional query parameter.
func queryText(r *http.Request, key string) *string {
	v := strings.TrimSpace(r.URL.Query().Get(key))
	if v == "" {
		return nil
	}
	return &v
}

// queryEnum returns a whitelisted optional query parameter.
func queryEnum(r *http.Request, key string, allowed ...string) (*string, error) {
	v := queryText(r, key)
	if v == nil {
		return nil, nil
	}
	for _, a := range allowed {
		if a == *v {
			return v, nil
		}
	}
	return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
		Field: key, Message: "must be one of: " + strings.Join(allowed, ", "),
	})
}

// queryRating reads an optional 1..5 star filter.
func queryRating(r *http.Request, key string) (*int16, error) {
	raw := queryText(r, key)
	if raw == nil {
		return nil, nil
	}
	n, err := strconv.Atoi(*raw)
	if err != nil || n < 1 || n > 5 {
		return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
			Field: key, Message: "must be an integer between 1 and 5",
		})
	}
	v := int16(n) //nolint:gosec // G109: n is validated to [1,5] above
	return &v, nil
}
