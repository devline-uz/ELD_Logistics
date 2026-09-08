//go:build integration

package duty_test

import (
	"testing"

	"github.com/devline/onebook-eld/internal/testutil"
)

// TestMain owns the shared containers for this package.
func TestMain(m *testing.M) { testutil.RunMain(m) }
