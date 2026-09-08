//go:build integration

package testutil

import "testing"

// TestMain owns the shared containers for this package: they are started on
// first use and terminated once, after every test has finished.
func TestMain(m *testing.M) { RunMain(m) }
