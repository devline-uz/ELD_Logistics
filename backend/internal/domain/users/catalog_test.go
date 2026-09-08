package users

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
)

// The catalogue is what GET /permissions publishes: every key of the single
// source of truth must be described and grouped.
func TestPermissionCatalogueCoversEveryKey(t *testing.T) {
	catalogue := permissionCatalogue()

	seen := make(map[string]struct{})
	for _, module := range catalogue {
		require.NotEmpty(t, module.Module, "module key")
		require.NotEmpty(t, module.Label, "module %q has no label", module.Module)
		for _, p := range module.Permissions {
			require.NotEmpty(t, permissionDescriptions[p.Key],
				"permission %q is missing from permissionDescriptions", p.Key)
			require.NotEmpty(t, p.Description, "permission %q has no description", p.Key)
			require.Equal(t, module.Module, moduleOf(p.Key), "permission %q is in the wrong module", p.Key)
			seen[p.Key] = struct{}{}
		}
	}

	require.Len(t, seen, len(core.AllPermissions), "catalogue and core.AllPermissions disagree")
	for _, key := range core.AllPermissions {
		_, ok := seen[key]
		require.True(t, ok, "permission %q is missing from the catalogue", key)
	}
}

// Q82.2: audit critical modules have no delete permission, so a role editor
// must never accept one.
func TestValidatePermissionsRejectsAuditCriticalDeletes(t *testing.T) {
	for _, key := range []string{"logs.delete", "dvir.delete", "violations.delete", "telemetry.delete", "audit_log.delete"} {
		_, err := validatePermissions([]string{"units.read", key})
		require.Error(t, err, "%s must be rejected", key)
		require.True(t, apierr.Is(err, apierr.CodeValidationError), "%s: %v", key, err)
		require.False(t, core.IsValidPermission(key), "%s must not exist in the catalogue", key)
	}
}

func TestValidatePermissionsRejectsUnknownKeys(t *testing.T) {
	_, err := validatePermissions([]string{"units.read", "units.teleport"})
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeValidationError))

	e, ok := apierr.From(err)
	require.True(t, ok)
	require.NotEmpty(t, e.Details)
}

func TestValidatePermissionsDeduplicatesAndSorts(t *testing.T) {
	out, err := validatePermissions([]string{"units.read", "drivers.read", "units.read"})
	require.NoError(t, err)
	require.Equal(t, []string{"drivers.read", "units.read"}, out)
}

func TestValidatePermissionsRejectsEmptySet(t *testing.T) {
	_, err := validatePermissions(nil)
	require.Error(t, err)
	require.True(t, apierr.Is(err, apierr.CodeValidationError))
}
