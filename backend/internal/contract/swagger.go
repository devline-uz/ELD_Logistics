// Package contract loads the generated OpenAPI document (docs/swagger.json)
// and exposes the operation list the permission-matrix and HTTP contract
// tests iterate over (TZ 9-bosqich 3-qism).
//
// It has no docker/DB dependency: swagger.json is parsed as plain JSON, so
// this package stays a fast `go test ./...` citizen instead of an
// integration-only one, and can run wherever `make swag` has produced a
// fresh docs/swagger.json.
package contract

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"runtime"
	"sort"
	"strings"
)

// Permission markers a swag `@x-permission` annotation may carry besides a
// real permission key (see eld-api-contract / eld-security).
const (
	Public        = "public"
	Authenticated = "authenticated"
	SuperAdmin    = "super_admin"
)

// Operation is one method+path pair read out of docs/swagger.json.
type Operation struct {
	Method      string // "GET", "POST", ...
	Path        string // template, e.g. "/units/{id}"
	Permission  string // @x-permission value
	OperationID string
}

// Gated reports whether the operation is behind a real permission key, i.e.
// neither "public" nor "authenticated" (both skip the permission matrix: they
// have no key to check, only a 401/anonymous contract).
func (o Operation) Gated() bool {
	return o.Permission != Public && o.Permission != Authenticated
}

// HasPathParam reports whether the path template carries at least one
// {param} placeholder.
func (o Operation) HasPathParam() bool {
	return braceRe.MatchString(o.Path)
}

// swaggerDoc mirrors only the subset of the OpenAPI document this package
// reads. The full swag output has hundreds of unrelated fields.
type swaggerDoc struct {
	Paths map[string]map[string]struct {
		OperationID string `json:"operationId"`
		Permission  string `json:"x-permission"`
	} `json:"paths"`
}

// LoadOperations parses every operation out of the swagger.json at path.
func LoadOperations(path string) ([]Operation, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("contract: read %s: %w", path, err)
	}

	var doc swaggerDoc
	if err := json.Unmarshal(raw, &doc); err != nil {
		return nil, fmt.Errorf("contract: parse %s: %w", path, err)
	}

	ops := make([]Operation, 0, len(doc.Paths)*2)
	for p, methods := range doc.Paths {
		for method, op := range methods {
			// swag emits a sibling "parameters" key for path-level (shared)
			// parameters; it is not an HTTP verb.
			if method == "parameters" {
				continue
			}
			ops = append(ops, Operation{
				Method:      strings.ToUpper(method),
				Path:        p,
				Permission:  op.Permission,
				OperationID: op.OperationID,
			})
		}
	}
	sort.Slice(ops, func(i, j int) bool {
		if ops[i].Path != ops[j].Path {
			return ops[i].Path < ops[j].Path
		}
		return ops[i].Method < ops[j].Method
	})
	return ops, nil
}

var braceRe = regexp.MustCompile(`\{[^}]+\}`)

// ResolvePath fills every {param} placeholder with the result of valueFn,
// called once per placeholder, turning a path template into a routable URL.
// Handlers see a syntactically valid but (by default) nonexistent id, which
// is exactly what the permission-matrix and 404 contract tests need: the
// request must clear chi routing and reach the permission gate/repository
// before any {id} is looked up.
func ResolvePath(path string, valueFn func() string) string {
	return braceRe.ReplaceAllStringFunc(path, func(string) string { return valueFn() })
}

// DefaultSwaggerPath is docs/swagger.json resolved relative to this source
// file rather than the caller's working directory, so both `go test
// ./internal/contract/...` and `go test ./cmd/api/...` (a different package
// depth would break a literal "../../docs/swagger.json") find the same file.
var DefaultSwaggerPath = func() string {
	_, file, _, _ := runtime.Caller(0)
	// file = .../backend/internal/contract/swagger.go
	return filepath.Join(filepath.Dir(file), "..", "..", "docs", "swagger.json")
}()
