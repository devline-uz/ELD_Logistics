package contract

import (
	"testing"

	"github.com/stretchr/testify/require"
)

// TestLoadOperations is the cheap half of the regression shield described in
// the 9-bosqich 3-qism task: every operation swag generates MUST declare an
// @x-permission, or a future endpoint could ship wide open by accident. The
// docker-backed half (does the declared key actually gate the route for every
// default role) lives in cmd/api's permission matrix test.
func TestLoadOperations(t *testing.T) {
	ops, err := LoadOperations(DefaultSwaggerPath)
	require.NoError(t, err, "parse %s (run `make swag` first)", DefaultSwaggerPath)
	require.NotEmpty(t, ops)

	seen := make(map[string]bool, len(ops))
	for _, op := range ops {
		require.NotEmpty(t, op.Permission, "%s %s must declare @x-permission", op.Method, op.Path)
		seen[op.Method+" "+op.Path] = true
	}
	require.Len(t, seen, len(ops), "duplicate method+path in swagger.json")

	t.Logf("swagger.json: %d operations, %d gated by a real permission key", len(ops), countGated(ops))
}

func countGated(ops []Operation) int {
	n := 0
	for _, op := range ops {
		if op.Gated() {
			n++
		}
	}
	return n
}

func TestResolvePath(t *testing.T) {
	i := 0
	next := func() string { i++; return "X" }
	require.Equal(t, "/units/X", ResolvePath("/units/{id}", next))
	require.Equal(t, "/drivers/X/co-drivers/X", ResolvePath("/drivers/{driver_id}/co-drivers/{co_driver_id}", next))
	require.Equal(t, "/units", ResolvePath("/units", next))
}
