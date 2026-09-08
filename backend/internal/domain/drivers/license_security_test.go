//go:build integration

// Regression coverage for the licence reveal endpoint: it needs its own
// permission key and every call is audited (TZ B§3.4, A§16 Q82).
package drivers_test

import (
	"net/http"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/drivers/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

// seedDriver creates one driver and returns its id and clear licence number.
func seedDriver(t *testing.T, client *testutil.TestServer) (string, string) {
	t.Helper()
	const plain = "TX-7781-0043"
	username := "lic." + strings.ReplaceAll(uuid.NewString()[:8], "-", "")
	resp := client.Post("/api/v1/drivers", dto.DriverCreate{
		FirstName: "Lic", LastName: "Reveal", Username: username,
		Email: username + "@example.com", LicenseNo: plain,
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)
	var env dto.DriverEnvelope
	resp.JSON(&env)
	return env.Data.ID, plain
}

func countLicenseReveals(t *testing.T, driverID uuid.UUID) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM audit_log WHERE record_id = $1 AND action = 'license_reveal'`,
		driverID).Scan(&n))
	return n
}

// Editing a driver must not imply the right to read the licence number in
// clear text: that is a separate, dedicated key.
func TestLicenseRevealNeedsItsOwnPermission(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	admin := srv.AsTenant(tn)

	id, plain := seedDriver(t, admin)

	// drivers.update alone is no longer enough.
	editor := srv.AsPrincipal(principalWith(tn, core.PermDriversRead, core.PermDriversUpdate))
	testutil.RequireStatusCode(t, editor.Get("/api/v1/drivers/"+id+"/license"),
		http.StatusForbidden, apierr.CodeForbidden)

	// The dedicated key opens it.
	reader := srv.AsPrincipal(principalWith(tn, core.PermDriversRead, core.PermDriversLicenseView))
	resp := reader.Get("/api/v1/drivers/" + id + "/license")
	testutil.RequireStatus(t, resp, http.StatusOK)
	var lic dto.DriverLicenseEnvelope
	resp.JSON(&lic)
	require.Equal(t, plain, lic.Data.LicenseNo)
}

// Reading PII is an audited event: who revealed which licence, and when.
func TestLicenseRevealIsAudited(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, driverPermissions...)
	client := srv.AsTenant(tn)

	id, _ := seedDriver(t, client)
	driverID := uuid.MustParse(id)
	require.Equal(t, 0, countLicenseReveals(t, driverID))

	testutil.RequireStatus(t, client.Get("/api/v1/drivers/"+id+"/license"), http.StatusOK)
	require.Equal(t, 1, countLicenseReveals(t, driverID))

	testutil.RequireStatus(t, client.Get("/api/v1/drivers/"+id+"/license"), http.StatusOK)
	require.Equal(t, 2, countLicenseReveals(t, driverID), "every reveal is one entry")

	// The entry names the caller and the field, and never stores the clear
	// value: only a masked form reaches audit_log.
	var editedBy uuid.UUID
	var field string
	var newValue []byte
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT edited_by, field, new_value FROM audit_log
		  WHERE record_id = $1 AND action = 'license_reveal' ORDER BY ts DESC LIMIT 1`,
		driverID).Scan(&editedBy, &field, &newValue))
	require.Equal(t, tn.Principal().UserID, editedBy)
	require.Equal(t, "license_no", field)
	require.NotContains(t, string(newValue), "7781")
	require.NotContains(t, string(newValue), "TX-7781-0043")
}

// A driver of another tenant is a 404, and it must not leave an audit trail on
// the victim's record either.
func TestLicenseRevealIsTenantScoped(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	owner := testutil.SeedTenant(t, driverPermissions...)
	intruder := testutil.SeedTenant(t, driverPermissions...)

	id, _ := seedDriver(t, srv.AsTenant(owner))
	driverID := uuid.MustParse(id)

	testutil.RequireStatusCode(t, srv.AsTenant(intruder).Get("/api/v1/drivers/"+id+"/license"),
		http.StatusNotFound, apierr.CodeNotFound)
	require.Equal(t, 0, countLicenseReveals(t, driverID))
}
