package httpx

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/devline/onebook-eld/internal/apierr"
)

// Pagination defaults and bounds (per conventions: 10/25/50, hard max 100).
const (
	DefaultPage    = 1
	DefaultPerPage = 25
	MaxPerPage     = 100
	// MaxPage bounds ?page so (page-1)*per_page cannot overflow int32 when
	// computing Offset(); it is far beyond any realistic result set.
	MaxPage = 1_000_000
)

// AllowedPerPage is the closed set of page sizes accepted by ?per_page
// (TZ B§18.3). Any other value returns 422 VALIDATION_ERROR.
var AllowedPerPage = []int{10, 25, 50}

// joinInts renders a small int slice as a comma separated list for error
// messages.
func joinInts(vs []int) string {
	parts := make([]string, len(vs))
	for i, v := range vs {
		parts[i] = strconv.Itoa(v)
	}
	return strings.Join(parts, ", ")
}

// Page holds a parsed pagination request.
type Page struct {
	Page    int
	PerPage int
}

// Offset returns the SQL OFFSET for the page. Safe from int32 overflow
// because ParsePagination bounds Page to MaxPage and PerPage to MaxPerPage.
//
//nolint:gosec // G115: bounded by MaxPage*MaxPerPage in ParsePagination
func (p Page) Offset() int32 { return int32((p.Page - 1) * p.PerPage) }

// Limit returns the SQL LIMIT for the page. Safe from int32 overflow because
// ParsePagination bounds PerPage to MaxPerPage.
func (p Page) Limit() int32 { return int32(p.PerPage) } //nolint:gosec // G115: bounded by MaxPerPage in ParsePagination

// Meta builds the response metadata for a known total.
func (p Page) Meta(total int64) Meta {
	return Meta{Page: p.Page, PerPage: p.PerPage, Total: total}
}

// ParsePagination reads ?page and ?per_page from the request.
func ParsePagination(r *http.Request) (Page, error) {
	q := r.URL.Query()
	p := Page{Page: DefaultPage, PerPage: DefaultPerPage}

	if raw := strings.TrimSpace(q.Get("page")); raw != "" {
		v, err := strconv.Atoi(raw)
		if err != nil || v < 1 {
			return p, apierr.Validation("invalid pagination", apierr.FieldError{
				Field: "page", Message: "must be a positive integer",
			})
		}
		if v > MaxPage {
			return p, apierr.Validation("invalid pagination", apierr.FieldError{
				Field: "page", Message: "must be at most " + strconv.Itoa(MaxPage),
			})
		}
		p.Page = v
	}

	if raw := strings.TrimSpace(q.Get("per_page")); raw != "" {
		v, err := strconv.Atoi(raw)
		if err != nil {
			return p, apierr.Validation("invalid pagination", apierr.FieldError{
				Field: "per_page", Message: "must be one of: " + joinInts(AllowedPerPage),
			})
		}
		allowed := false
		for _, a := range AllowedPerPage {
			if v == a {
				allowed = true
				break
			}
		}
		if !allowed {
			return p, apierr.Validation("invalid pagination", apierr.FieldError{
				Field: "per_page", Message: "must be one of: " + joinInts(AllowedPerPage),
			})
		}
		p.PerPage = v
	}

	return p, nil
}

// Sort holds a parsed and whitelisted sort request.
type Sort struct {
	Field string
	Order string // "asc" | "desc"
}

// OrderBy renders the sort as a SQL fragment. Safe to interpolate because the
// field came from a whitelist.
func (s Sort) OrderBy() string {
	if s.Field == "" {
		return ""
	}
	return s.Field + " " + strings.ToUpper(s.Order)
}

// ParseSort reads ?sort and ?order, rejecting anything outside allowed.
// def is used when ?sort is absent; it is not validated against allowed.
func ParseSort(r *http.Request, allowed []string, def Sort) (Sort, error) {
	q := r.URL.Query()
	s := def
	if s.Order == "" {
		s.Order = "asc"
	}

	if field := strings.TrimSpace(q.Get("sort")); field != "" {
		ok := false
		for _, a := range allowed {
			if a == field {
				ok = true
				break
			}
		}
		if !ok {
			return def, apierr.Validation("invalid sort field", apierr.FieldError{
				Field: "sort", Message: "must be one of: " + strings.Join(allowed, ", "),
			})
		}
		s.Field = field
	}

	switch strings.ToLower(strings.TrimSpace(q.Get("order"))) {
	case "":
	case "asc":
		s.Order = "asc"
	case "desc":
		s.Order = "desc"
	default:
		return def, apierr.Validation("invalid sort order", apierr.FieldError{
			Field: "order", Message: "must be one of: asc, desc",
		})
	}

	return s, nil
}

// QueryBool reads an optional boolean query parameter.
func QueryBool(r *http.Request, key string) (*bool, error) {
	raw := strings.TrimSpace(r.URL.Query().Get(key))
	if raw == "" {
		return nil, nil
	}
	v, err := strconv.ParseBool(raw)
	if err != nil {
		return nil, apierr.Validation("invalid query parameter", apierr.FieldError{
			Field: key, Message: "must be a boolean",
		})
	}
	return &v, nil
}
