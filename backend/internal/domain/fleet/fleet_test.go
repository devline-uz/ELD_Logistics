//go:build integration

// Integration coverage of the fleet module against a real Postgres: the happy
// paths, the validation and permission gates, cross-tenant isolation (404, not
// 403), the soft-delete aware unique indexes and the ELD wiring rules.
package fleet_test

import (
	"net/http"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/fleet"
	"github.com/devline/onebook-eld/internal/domain/fleet/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

// allFleetPerms is every permission the module gates on.
var allFleetPerms = []string{
	core.PermUnitsRead, core.PermUnitsCreate, core.PermUnitsUpdate, core.PermUnitsDelete,
	core.PermUnitsActivate, core.PermUnitsDeactivate, core.PermUnitsAssignDriver, core.PermUnitsDiagnostics,
	core.PermELDDevicesRead, core.PermELDDevicesCreate, core.PermELDDevicesUpdate,
	core.PermELDDevicesDelete, core.PermELDDevicesAssignUnit,
	core.PermTrailersRead, core.PermTrailersCreate, core.PermTrailersUpdate, core.PermTrailersDelete,
	core.PermShippingDocsRead, core.PermShippingDocsCreate, core.PermShippingDocsUpdate, core.PermShippingDocsDelete,
}

func newServer(t testing.TB) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	repo := fleet.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger()))
	return testutil.NewServer(t, fleet.New(fleet.Deps{Repo: repo, Verifier: testutil.ContextVerifier()}))
}

func validUnit(number string) dto.UnitCreate {
	return dto.UnitCreate{
		UnitNumber:   number,
		Make:         "Freightliner",
		Model:        "Cascadia",
		LicensePlate: "AA123BB",
		FuelType:     dto.FuelDiesel,
	}
}

func decodeUnit(t testing.TB, resp *testutil.Response) dto.Unit {
	t.Helper()
	var env dto.UnitEnvelope
	resp.JSON(&env)
	return env.Data
}

func TestUnitLifecycleHappyPath(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allFleetPerms...)
	c := srv.AsTenant(tn)

	created := srv.AsTenant(tn).Post("/api/v1/units", validUnit("HAPPY-1"))
	testutil.RequireStatus(t, created, http.StatusCreated)
	testutil.RequireNoPII(t, created.Body)
	unit := decodeUnit(t, created)
	require.Equal(t, "HAPPY-1", unit.UnitNumber)
	require.Equal(t, dto.StatusActive, unit.Status)
	// A brand new unit has never reported telemetry.
	require.Nil(t, unit.OdometerM, "odometer_m must be null before the first telemetry point")

	got := c.Get("/api/v1/units/" + unit.ID)
	testutil.RequireStatus(t, got, http.StatusOK)
	require.Equal(t, unit.ID, decodeUnit(t, got).ID)

	plateRegion := "TX"
	patched := c.Patch("/api/v1/units/"+unit.ID, dto.UnitUpdate{PlateRegion: &plateRegion})
	testutil.RequireStatus(t, patched, http.StatusOK)
	require.Equal(t, "TX", decodeUnit(t, patched).PlateRegion)

	deactivated := c.Post("/api/v1/units/"+unit.ID+"/deactivate", nil)
	testutil.RequireStatus(t, deactivated, http.StatusOK)
	require.Equal(t, dto.StatusInactive, decodeUnit(t, deactivated).Status)

	// Q1/Q2: inactive rows live behind their own tab.
	require.False(t, listContains(t, c, unit.ID), "an inactive unit must not appear in the default list")
	require.True(t, listContains(t, c, unit.ID, testutil.Query("include_inactive", "true")),
		"include_inactive=true must reveal the unit again")

	activated := c.Post("/api/v1/units/"+unit.ID+"/activate", nil)
	testutil.RequireStatus(t, activated, http.StatusOK)
	require.Equal(t, dto.StatusActive, decodeUnit(t, activated).Status)

	testutil.RequireStatus(t, c.Delete("/api/v1/units/"+unit.ID), http.StatusNoContent)
	testutil.RequireStatusCode(t, c.Get("/api/v1/units/"+unit.ID), http.StatusNotFound, apierr.CodeNotFound)
}

func listContains(t testing.TB, c *testutil.TestServer, id string, opts ...testutil.RequestOption) bool {
	t.Helper()
	resp := c.Get("/api/v1/units", append(opts, testutil.Query("per_page", "50"))...)
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.UnitListEnvelope
	resp.JSON(&env)
	for _, u := range env.Data {
		if u.ID == id {
			return true
		}
	}
	return false
}

func TestCreateUnitRejectsIncompletePayload(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	c := srv.AsTenant(testutil.SeedTenant(t, allFleetPerms...))

	// Q18.1: make, model, license_plate and fuel_type are mandatory.
	resp := c.Post("/api/v1/units", map[string]any{"unit_number": "NO-FIELDS"})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// §18.3: VIN is optional but must be 17 characters when present.
	bad := validUnit("BAD-VIN")
	bad.VIN = "TOOSHORT"
	testutil.RequireStatusCode(t, c.Post("/api/v1/units", bad),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// The sort whitelist rejects anything it does not know.
	testutil.RequireStatusCode(t, c.Get("/api/v1/units", testutil.Query("sort", "notes")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestUnitsRequirePermission(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	readOnly := srv.AsTenant(testutil.SeedTenant(t, core.PermUnitsRead))

	testutil.RequireStatus(t, readOnly.Get("/api/v1/units"), http.StatusOK)
	testutil.RequireStatusCode(t, readOnly.Post("/api/v1/units", validUnit("NO-PERM")),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatusCode(t, srv.Anonymous().Get("/api/v1/units"),
		http.StatusUnauthorized, apierr.CodeUnauthorized)
}

func TestUnitCrossTenantAnswers404(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, allFleetPerms...)
	ca := srv.AsTenant(a)
	foreign := b.Unit.ID.String()

	// Never 403: the API must not confirm that a foreign row exists.
	testutil.RequireStatusCode(t, ca.Get("/api/v1/units/"+foreign), http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, ca.Patch("/api/v1/units/"+foreign, dto.UnitUpdate{}),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, ca.Delete("/api/v1/units/"+foreign), http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, ca.Get("/api/v1/units/"+foreign+"/diagnostics"),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, ca.Get("/api/v1/eld-devices/"+b.Device.ID.String()),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, ca.Get("/api/v1/trailers/"+b.Trailer.ID.String()),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestDuplicateUnitNumberAnswers409(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	c := srv.AsTenant(testutil.SeedTenant(t, allFleetPerms...))

	testutil.RequireStatus(t, c.Post("/api/v1/units", validUnit("DUP-1")), http.StatusCreated)
	testutil.RequireStatusCode(t, c.Post("/api/v1/units", validUnit("DUP-1")),
		http.StatusConflict, apierr.CodeUniqueViolation)

	// The index is on lower(unit_number): case does not create a new slot.
	testutil.RequireStatusCode(t, c.Post("/api/v1/units", validUnit("dup-1")),
		http.StatusConflict, apierr.CodeUniqueViolation)
}

func TestUnitNumberIsReusableAfterSoftDelete(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	c := srv.AsTenant(testutil.SeedTenant(t, allFleetPerms...))

	first := c.Post("/api/v1/units", validUnit("REUSE-1"))
	testutil.RequireStatus(t, first, http.StatusCreated)
	testutil.RequireStatus(t, c.Delete("/api/v1/units/"+decodeUnit(t, first).ID), http.StatusNoContent)

	// units_company_number_uniq is partial on deleted_at IS NULL.
	second := c.Post("/api/v1/units", validUnit("REUSE-1"))
	testutil.RequireStatus(t, second, http.StatusCreated)
	require.NotEqual(t, decodeUnit(t, first).ID, decodeUnit(t, second).ID)
}

func TestAssignDriverAndHistory(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allFleetPerms...)
	c := srv.AsTenant(tn)

	assigned := c.Post("/api/v1/units/"+tn.Unit.ID.String()+"/assign-driver",
		dto.UnitAssignDriver{DriverID: tn.Driver.ID.String(), Role: dto.RolePrimary})
	testutil.RequireStatus(t, assigned, http.StatusCreated)
	var env dto.UnitAssignmentEnvelope
	assigned.JSON(&env)
	require.Equal(t, dto.RolePrimary, env.Data.Role)
	require.Equal(t, tn.Driver.ID.String(), env.Data.DriverID)

	// Q1.1: re-assigning primary closes the previous open row instead of
	// tripping unit_driver_assignments_open_uniq.
	testutil.RequireStatus(t, c.Post("/api/v1/units/"+tn.Unit.ID.String()+"/assign-driver",
		dto.UnitAssignDriver{DriverID: tn.Driver.ID.String(), Role: dto.RolePrimary}), http.StatusCreated)

	// An unknown driver is a 404, never a 500.
	testutil.RequireStatusCode(t, c.Post("/api/v1/units/"+tn.Unit.ID.String()+"/assign-driver",
		dto.UnitAssignDriver{DriverID: "00000000-0000-4000-8000-000000000000", Role: dto.RolePrimary}),
		http.StatusNotFound, apierr.CodeNotFound)

	history := c.Get("/api/v1/units/" + tn.Unit.ID.String() + "/history")
	testutil.RequireStatus(t, history, http.StatusOK)
	var hist dto.UnitHistoryEnvelope
	history.JSON(&hist)
	require.NotEmpty(t, hist.Data, "assignments and audit entries must show up in the history")
}

func TestUnitDiagnostics(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allFleetPerms...)

	resp := srv.AsTenant(tn).Get("/api/v1/units/" + tn.Unit.ID.String() + "/diagnostics")
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.UnitDiagnosticsEnvelope
	resp.JSON(&env)
	require.Equal(t, tn.Unit.ID.String(), env.Data.UnitID)
	require.NotNil(t, env.Data.DeviceID, "the seeded device is wired to the seeded unit")
	// The fixture never reports telemetry, so the unit cannot be Online.
	require.NotEqual(t, dto.ConnOnline, env.Data.ConnectionState)
	require.Nil(t, env.Data.Telemetry.OdometerM)
}

func TestEldDeviceWiringRules(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allFleetPerms...)
	c := srv.AsTenant(tn)

	created := c.Post("/api/v1/eld-devices", dto.EldDeviceCreate{
		Vendor: "Geotab", Serial: "SPARE-" + tn.Unit.ID.String()[:8], ConnectionType: dto.ConnBluetooth,
	})
	testutil.RequireStatus(t, created, http.StatusCreated)
	var devEnv dto.EldDeviceEnvelope
	created.JSON(&devEnv)
	spare := devEnv.Data

	// One active device per unit: the seeded unit already carries one.
	testutil.RequireStatusCode(t, c.Post("/api/v1/eld-devices/"+spare.ID+"/assign-unit",
		dto.EldDeviceAssignUnit{UnitID: strptr(tn.Unit.ID.String())}),
		http.StatusConflict, apierr.CodeAlreadyAssigned)

	// Q3.1: an inactive unit accepts no ELD.
	fresh := c.Post("/api/v1/units", validUnit("WIRING-1"))
	testutil.RequireStatus(t, fresh, http.StatusCreated)
	unit := decodeUnit(t, fresh)
	testutil.RequireStatus(t, c.Post("/api/v1/units/"+unit.ID+"/deactivate", nil), http.StatusOK)
	testutil.RequireStatusCode(t, c.Post("/api/v1/eld-devices/"+spare.ID+"/assign-unit",
		dto.EldDeviceAssignUnit{UnitID: &unit.ID}),
		http.StatusConflict, apierr.CodeInvalidState)

	// Re-activated, the same wiring succeeds.
	testutil.RequireStatus(t, c.Post("/api/v1/units/"+unit.ID+"/activate", nil), http.StatusOK)
	wired := c.Post("/api/v1/eld-devices/"+spare.ID+"/assign-unit", dto.EldDeviceAssignUnit{UnitID: &unit.ID})
	testutil.RequireStatus(t, wired, http.StatusOK)
	wired.JSON(&devEnv)
	require.NotNil(t, devEnv.Data.UnitID)
	require.Equal(t, unit.ID, *devEnv.Data.UnitID)

	// A duplicate serial is a 409, and the serial index ignores case.
	testutil.RequireStatusCode(t, c.Post("/api/v1/eld-devices", dto.EldDeviceCreate{
		Vendor: "Geotab", Serial: spare.Serial,
	}), http.StatusConflict, apierr.CodeUniqueViolation)

	testutil.RequireStatus(t, c.Delete("/api/v1/eld-devices/"+spare.ID), http.StatusNoContent)
	testutil.RequireStatusCode(t, c.Get("/api/v1/eld-devices/"+spare.ID), http.StatusNotFound, apierr.CodeNotFound)
}

func TestTrailerAndShippingDocumentCRUD(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	c := srv.AsTenant(testutil.SeedTenant(t, allFleetPerms...))

	for _, tc := range []struct{ path, number string }{
		{"/api/v1/trailers", "TR-CRUD-1"},
		{"/api/v1/shipping-documents", "BOL-CRUD-1"},
	} {
		t.Run(tc.path, func(t *testing.T) {
			created := c.Post(tc.path, dto.CatalogCreate{Number: tc.number, Notes: "seeded"})
			testutil.RequireStatus(t, created, http.StatusCreated)
			var env struct {
				Data struct {
					ID     string `json:"id"`
					Number string `json:"number"`
					Notes  string `json:"notes"`
				} `json:"data"`
			}
			created.JSON(&env)
			require.Equal(t, tc.number, env.Data.Number)

			testutil.RequireStatusCode(t, c.Post(tc.path, dto.CatalogCreate{Number: tc.number}),
				http.StatusConflict, apierr.CodeUniqueViolation)

			notes := "updated"
			testutil.RequireStatus(t, c.Patch(tc.path+"/"+env.Data.ID, dto.CatalogUpdate{Notes: &notes}), http.StatusOK)
			testutil.RequireStatus(t, c.Get(tc.path+"/"+env.Data.ID), http.StatusOK)
			testutil.RequireStatus(t, c.Delete(tc.path+"/"+env.Data.ID), http.StatusNoContent)
			testutil.RequireStatusCode(t, c.Get(tc.path+"/"+env.Data.ID), http.StatusNotFound, apierr.CodeNotFound)

			// The partial unique index frees the number again.
			testutil.RequireStatus(t, c.Post(tc.path, dto.CatalogCreate{Number: tc.number}), http.StatusCreated)
		})
	}
}

func TestUnitWriteIsAudited(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allFleetPerms...)
	c := srv.AsTenant(tn)

	before := testutil.CountIn(t, "audit_log", tn.ID())
	testutil.RequireStatus(t, c.Post("/api/v1/units", validUnit("AUDIT-1")), http.StatusCreated)
	require.Greater(t, testutil.CountIn(t, "audit_log", tn.ID()), before,
		"every write must leave an audit_log trail")
}

func strptr(v string) *string { return &v }
