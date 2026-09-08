//go:build integration

// Integration coverage of the DVIR module: the §7.2 state machine (legal and
// illegal transitions), the Q31 driver-only rule, the Q27.2 critical defect
// out-of-service flag, the pending certification flow, the Q30.1 seven day
// fallback, the PDF fallback and cross-tenant isolation (404, never 403).
package dvir_test

import (
	"context"
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/dvir"
	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// allDvirPerms is every permission the module gates on.
var allDvirPerms = []string{
	core.PermDVIRRead, core.PermDVIRCreate, core.PermDVIRRepair, core.PermDVIRCertify,
	core.PermDVIRExport, core.PermDefectTypesRead, core.PermDefectTypesCreate,
	core.PermDefectTypesUpdate,
}

var now = time.Date(2026, 9, 6, 12, 0, 0, 0, time.UTC)

type harness struct {
	srv  *testutil.TestServer
	svc  *dvir.Service
	pool *db.Pool
}

func newHarness(t testing.TB) *harness {
	t.Helper()
	pool := testutil.NewDB(t)
	repo := dvir.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger()))
	mod := dvir.New(dvir.Deps{
		Repo:     repo,
		Verifier: testutil.ContextVerifier(),
		Log:      testutil.Logger(),
		Now:      func() time.Time { return now },
	})
	return &harness{srv: testutil.NewServer(t, mod), svc: mod.Service(), pool: pool}
}

// driverClient is a self scoped mobile principal with every DVIR permission.
func (h *harness) driverClient(tn *testutil.Tenant) *testutil.TestServer {
	return h.srv.AsPrincipal(tn.DriverPrincipal(allDvirPerms...))
}

// adminClient is a company scoped web principal: it holds the same permissions
// but owns no driver record.
func (h *harness) adminClient(tn *testutil.Tenant) *testutil.TestServer {
	return h.srv.AsTenant(tn)
}

// ---------------------------------------------------------------- fixtures

// newDefectType inserts a company catalogue entry.
func newDefectType(t testing.TB, companyID uuid.UUID, name string, critical bool) uuid.UUID {
	t.Helper()
	id := uuid.New()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO defect_types (id, company_id, name, category, is_critical, is_active, sort_order)
		 VALUES ($1,$2,$3,'truck',$4,true,1)`,
		id, companyID, name+"-"+id.String()[:8], critical)
	require.NoError(t, err, "insert defect type")
	return id
}

// seedLastState writes the telemetry snapshot the DVIR capture reads (Q28).
func seedLastState(t testing.TB, companyID, unitID uuid.UUID, odometerM int64) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO unit_last_state (unit_id, company_id, ts, lat, lng, odometer_m, engine_hours, online_status)
		 VALUES ($1,$2,$3,31.52,74.35,$4,1234.50,'online')
		 ON CONFLICT (unit_id) DO UPDATE SET odometer_m = EXCLUDED.odometer_m, ts = EXCLUDED.ts`,
		unitID, companyID, now.Add(-time.Minute), odometerM)
	require.NoError(t, err, "seed unit_last_state")
}

func decodeReport(t testing.TB, resp *testutil.Response) dto.DvirReport {
	t.Helper()
	var env struct {
		Data dto.DvirReport `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

func decodeReports(t testing.TB, resp *testutil.Response) []dto.DvirReport {
	t.Helper()
	var env struct {
		Data []dto.DvirReport `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

// objKey builds an object key of this tenant. A key of another company is
// refused by the service, so every test must sign with its own.
func objKey(tn *testutil.Tenant, kind, name string) string {
	return storage.BuildKey(tn.ID(), kind, name, now)
}

// submit files one DVIR through the mobile endpoint and returns it.
func submit(t testing.TB, h *harness, tn *testutil.Tenant, kind string, defects ...dto.DefectInput) dto.DvirReport {
	t.Helper()
	if defects == nil {
		defects = []dto.DefectInput{}
	}
	resp := h.driverClient(tn).Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID:             tn.Unit.ID.String(),
		Type:               kind,
		Defects:            defects,
		DriverSignatureKey: objKey(tn, "signature", "sig.png"),
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)
	return decodeReport(t, resp)
}

// ---------------------------------------------------------------- state machine

func TestSubmitWithoutDefectsIsTerminal(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	seedLastState(t, tn.ID(), tn.Unit.ID, 128430000)

	rep := submit(t, h, tn, dto.TypePreTrip)
	require.Equal(t, dto.StatusSubmittedNoDefects, rep.Status)
	require.Equal(t, dto.KindNoDefects, rep.Kind)
	require.Empty(t, rep.Defects)
	require.False(t, rep.HasCriticalDefect)

	// Q28 — time, location and odometer are captured server side.
	require.NotNil(t, rep.OdometerM)
	require.EqualValues(t, 128430000, *rep.OdometerM)
	require.NotNil(t, rep.Lat)
	require.Equal(t, now, rep.PerformedAt)

	// A terminal report accepts neither repair nor certification.
	client := h.driverClient(tn)
	repair := h.adminClient(tn).Post("/api/v1/dvir-reports/"+rep.ID+"/repair", dto.DvirRepair{
		MechanicNote: "nothing to do", MechanicSignatureKey: objKey(tn, "signature", "m.png"),
	})
	testutil.RequireStatusCode(t, repair, http.StatusConflict, apierr.CodeDVIRInvalidTransition)

	certify := client.Post("/api/v1/dvir-reports/"+rep.ID+"/certify", dto.DvirCertify{SignatureKey: objKey(tn, "signature", "s.png")})
	testutil.RequireStatusCode(t, certify, http.StatusConflict, apierr.CodeDVIRInvalidTransition)
}

func TestDefectFlowWalksTheWholeStateMachine(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	seedLastState(t, tn.ID(), tn.Unit.ID, 128430000)
	defectType := newDefectType(t, tn.ID(), "Windshield Wipers", false)

	rep := submit(t, h, tn, dto.TypePostTrip, dto.DefectInput{
		DefectTypeID: defectType.String(),
		Note:         "wiper blade torn",
		PhotoKeys:    []string{objKey(tn, "dvir_photo", "a.jpg"), objKey(tn, "dvir_photo", "b.jpg")},
	})
	require.Equal(t, dto.StatusSubmittedDefectsFound, rep.Status)
	require.Equal(t, dto.KindDefectsNotFixed, rep.Kind)
	require.Len(t, rep.Defects, 1)
	require.Equal(t, "wiper blade torn", rep.Defects[0].Note)
	require.Len(t, rep.Defects[0].PhotoKeys, 2)
	require.False(t, rep.OutOfService)

	// A driver may not certify before the Service Manager repaired it.
	early := h.driverClient(tn).Post("/api/v1/dvir-reports/"+rep.ID+"/certify",
		dto.DvirCertify{SignatureKey: objKey(tn, "signature", "s.png")})
	testutil.RequireStatusCode(t, early, http.StatusConflict, apierr.CodeDVIRInvalidTransition)

	cost := 120.5
	repaired := decodeReport(t, mustOK(t, h.adminClient(tn).Post(
		"/api/v1/dvir-reports/"+rep.ID+"/repair", dto.DvirRepair{
			MechanicNote:         "blade replaced",
			MechanicSignatureKey: objKey(tn, "signature", "mech.png"),
			InvoiceNo:            "INV-1",
			Vendor:               "Dallas Truck Service",
			Cost:                 &cost,
			InvoiceKey:           objKey(tn, "invoice", "inv.pdf"),
		})))
	require.Equal(t, dto.StatusRepaired, repaired.Status)
	require.Equal(t, dto.KindDefectsUncertified, repaired.Kind)
	require.NotNil(t, repaired.RepairedAt)
	require.Equal(t, "blade replaced", repaired.MechanicNote)

	// A second repair is not a legal transition out of `repaired`.
	again := h.adminClient(tn).Post("/api/v1/dvir-reports/"+rep.ID+"/repair", dto.DvirRepair{
		MechanicNote: "again", MechanicSignatureKey: objKey(tn, "signature", "mech.png"),
	})
	testutil.RequireStatusCode(t, again, http.StatusConflict, apierr.CodeDVIRInvalidTransition)

	certified := decodeReport(t, mustOK(t, h.driverClient(tn).Post(
		"/api/v1/dvir-reports/"+rep.ID+"/certify", dto.DvirCertify{SignatureKey: objKey(tn, "signature", "cert.png")})))
	require.Equal(t, dto.StatusCertified, certified.Status)
	require.Equal(t, dto.KindDefectsFixed, certified.Kind)
	require.NotNil(t, certified.CertifiedAt)
	require.NotNil(t, certified.CertifiedByDriver)
	require.Equal(t, tn.Driver.ID.String(), *certified.CertifiedByDriver)

	// Certifying twice is refused by the same guard.
	twice := h.driverClient(tn).Post("/api/v1/dvir-reports/"+rep.ID+"/certify",
		dto.DvirCertify{SignatureKey: objKey(tn, "signature", "cert.png")})
	testutil.RequireStatusCode(t, twice, http.StatusConflict, apierr.CodeDVIRInvalidTransition)
}

// ---------------------------------------------------------------- Q31

func TestAdminCannotFileADvirOnADriversBehalf(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)

	resp := h.adminClient(tn).Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID:             tn.Unit.ID.String(),
		Type:               dto.TypePreTrip,
		DriverSignatureKey: objKey(tn, "signature", "sig.png"),
	})
	testutil.RequireStatusCode(t, resp, http.StatusForbidden, apierr.CodeDVIRAdminCreateDenied)
}

// ---------------------------------------------------------------- Q27.2

func TestCriticalDefectPutsTheUnitOutOfService(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	seedLastState(t, tn.ID(), tn.Unit.ID, 128430000)
	critical := newDefectType(t, tn.ID(), "Brakes (Service)", true)

	rep := submit(t, h, tn, dto.TypePreTrip, dto.DefectInput{
		DefectTypeID: critical.String(), Note: "no pressure",
	})
	require.True(t, rep.HasCriticalDefect)
	require.True(t, rep.OutOfService)
	require.True(t, unitOutOfService(t, tn.Unit.ID), "units.out_of_service must be set")

	// Certifying the repair releases the unit again.
	mustOK(t, h.adminClient(tn).Post("/api/v1/dvir-reports/"+rep.ID+"/repair", dto.DvirRepair{
		MechanicNote: "brake line replaced", MechanicSignatureKey: objKey(tn, "signature", "mech.png"),
	}))
	mustOK(t, h.driverClient(tn).Post("/api/v1/dvir-reports/"+rep.ID+"/certify",
		dto.DvirCertify{SignatureKey: objKey(tn, "signature", "cert.png")}))
	require.False(t, unitOutOfService(t, tn.Unit.ID), "a certified repair clears out_of_service")
}

func TestCriticalDefectRaisesAnAlert(t *testing.T) {
	t.Parallel()
	pool := testutil.NewDB(t)
	rec := &recordingAlerter{}
	mod := dvir.New(dvir.Deps{
		Repo:     dvir.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger())),
		Verifier: testutil.ContextVerifier(),
		Alerter:  rec,
		Log:      testutil.Logger(),
		Now:      func() time.Time { return now },
	})
	srv := testutil.NewServer(t, mod)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	critical := newDefectType(t, tn.ID(), "Steering", true)

	resp := srv.AsPrincipal(tn.DriverPrincipal(allDvirPerms...)).Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID:             tn.Unit.ID.String(),
		Type:               dto.TypePreTrip,
		Defects:            []dto.DefectInput{{DefectTypeID: critical.String(), Note: "play in the wheel"}},
		DriverSignatureKey: objKey(tn, "signature", "sig.png"),
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)
	require.Equal(t, []string{dvir.AlertCriticalDefect}, rec.kinds())
}

func TestDefectRejectsMoreThanFivePhotosAndUnknownTypes(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	defectType := newDefectType(t, tn.ID(), "Mirrors", false)
	client := h.driverClient(tn)

	tooMany := client.Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID: tn.Unit.ID.String(), Type: dto.TypePreTrip,
		DriverSignatureKey: objKey(tn, "signature", "sig.png"),
		Defects: []dto.DefectInput{{
			DefectTypeID: defectType.String(),
			PhotoKeys:    []string{"a", "b", "c", "d", "e", "f"},
		}},
	})
	testutil.RequireStatusCode(t, tooMany, http.StatusUnprocessableEntity, apierr.CodeValidationError)

	unknown := client.Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID: tn.Unit.ID.String(), Type: dto.TypePreTrip,
		DriverSignatureKey: objKey(tn, "signature", "sig.png"),
		Defects:            []dto.DefectInput{{DefectTypeID: uuid.NewString()}},
	})
	testutil.RequireStatusCode(t, unknown, http.StatusUnprocessableEntity, apierr.CodeDefectTypeUnknown)
}

// ---------------------------------------------------------------- pending certification

func TestPendingCertificationDrivesTheNextPreTrip(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	defectType := newDefectType(t, tn.ID(), "Tires", false)
	client := h.driverClient(tn)

	rep := submit(t, h, tn, dto.TypePostTrip, dto.DefectInput{DefectTypeID: defectType.String()})

	pending := decodeReports(t, mustOK(t, client.Get("/api/v1/dvir-reports/pending-certification",
		testutil.Query("unit_id", tn.Unit.ID.String()))))
	require.Len(t, pending, 1)
	require.Equal(t, rep.ID, pending[0].ID)

	mustOK(t, h.adminClient(tn).Post("/api/v1/dvir-reports/"+rep.ID+"/repair", dto.DvirRepair{
		MechanicNote: "tyre replaced", MechanicSignatureKey: objKey(tn, "signature", "mech.png"),
	}))
	// Still pending: repaired but not confirmed by a driver.
	stillPending := decodeReports(t, mustOK(t, client.Get("/api/v1/dvir-reports/pending-certification",
		testutil.Query("unit_id", tn.Unit.ID.String()))))
	require.Len(t, stillPending, 1)
	require.Equal(t, dto.StatusRepaired, stillPending[0].Status)

	mustOK(t, client.Post("/api/v1/dvir-reports/"+rep.ID+"/certify",
		dto.DvirCertify{SignatureKey: objKey(tn, "signature", "cert.png")}))
	cleared := decodeReports(t, mustOK(t, client.Get("/api/v1/dvir-reports/pending-certification",
		testutil.Query("unit_id", tn.Unit.ID.String()))))
	require.Empty(t, cleared)
}

func TestAnotherDriverMayConfirmTheRepair(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	defectType := newDefectType(t, tn.ID(), "Horn", false)

	rep := submit(t, h, tn, dto.TypePreTrip, dto.DefectInput{DefectTypeID: defectType.String()})
	mustOK(t, h.adminClient(tn).Post("/api/v1/dvir-reports/"+rep.ID+"/repair", dto.DvirRepair{
		MechanicNote: "fixed", MechanicSignatureKey: objKey(tn, "signature", "mech.png"),
	}))

	// Q30.1 — a different driver of the same tenant is accepted.
	otherUser := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))
	other := testutil.NewDriver(t, tn.ID(), testutil.WithUser(otherUser))
	p := tn.DriverPrincipal(allDvirPerms...)
	p.UserID = otherUser.ID

	out := decodeReport(t, mustOK(t, h.srv.AsPrincipal(p).Post("/api/v1/dvir-reports/"+rep.ID+"/certify",
		dto.DvirCertify{SignatureKey: objKey(tn, "signature", "other.png")})))
	require.Equal(t, dto.StatusCertified, out.Status)
	require.Equal(t, other.ID.String(), *out.CertifiedByDriver)
}

// ---------------------------------------------------------------- Q30.1 fallback

func TestSevenDayFallbackClosesUnconfirmedReports(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	defectType := newDefectType(t, tn.ID(), "Exhaust", false)

	rep := submit(t, h, tn, dto.TypePreTrip, dto.DefectInput{DefectTypeID: defectType.String()})
	ctx := tenant.WithCompanyID(context.Background(), tn.ID())

	// Inside the grace window nothing is closed.
	closed, err := h.svc.CloseOverdue(ctx, dvir.CertificationGraceDays)
	require.NoError(t, err)
	require.Zero(t, closed)

	backdate(t, rep.ID, dvir.CertificationGraceDays+1)
	closed, err = h.svc.CloseOverdue(ctx, dvir.CertificationGraceDays)
	require.NoError(t, err)
	require.Equal(t, 1, closed)

	out := decodeReport(t, mustOK(t, h.driverClient(tn).Get("/api/v1/dvir-reports/"+rep.ID)))
	require.Equal(t, dto.StatusClosedNoCertification, out.Status)
	require.NotNil(t, out.ClosedAt)
	require.NotEmpty(t, out.ClosedReason)

	// The closed report leaves the pending list and the sweep is idempotent.
	pending := decodeReports(t, mustOK(t, h.driverClient(tn).Get("/api/v1/dvir-reports/pending-certification")))
	require.Empty(t, pending)
	closed, err = h.svc.CloseOverdue(ctx, dvir.CertificationGraceDays)
	require.NoError(t, err)
	require.Zero(t, closed)
}

func TestInactiveUnitClosesTheReportImmediately(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	defectType := newDefectType(t, tn.ID(), "Radiator", false)

	rep := submit(t, h, tn, dto.TypePreTrip, dto.DefectInput{DefectTypeID: defectType.String()})
	setUnitStatus(t, tn.Unit.ID, "inactive")

	closed, err := h.svc.CloseOverdue(tenant.WithCompanyID(context.Background(), tn.ID()), dvir.CertificationGraceDays)
	require.NoError(t, err)
	require.Equal(t, 1, closed)

	out := decodeReport(t, mustOK(t, h.driverClient(tn).Get("/api/v1/dvir-reports/"+rep.ID)))
	require.Equal(t, dto.StatusClosedNoCertification, out.Status)
	require.Equal(t, "unit is inactive", out.ClosedReason)
}

// ---------------------------------------------------------------- reads

func TestPdfFallsBackToHTMLWithoutChrome(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	rep := submit(t, h, tn, dto.TypePreTrip)

	resp := h.adminClient(tn).Get("/api/v1/dvir-reports/" + rep.ID + "/pdf")
	testutil.RequireStatus(t, resp, http.StatusOK)
	require.Contains(t, resp.Header.Get("Content-Type"), "text/html")
	require.Contains(t, resp.String(), "Driver Vehicle Inspection Report")
	require.Contains(t, resp.Header.Get("Content-Disposition"), ".html")
}

func TestListFiltersAndScopesToTheOwnDriver(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	pre := submit(t, h, tn, dto.TypePreTrip)
	post := submit(t, h, tn, dto.TypePostTrip)

	byType := decodeReports(t, mustOK(t, h.adminClient(tn).Get("/api/v1/dvir-reports",
		testutil.Query("type", dto.TypePostTrip), testutil.Query("unit_id", tn.Unit.ID.String()))))
	require.Len(t, byType, 1)
	require.Equal(t, post.ID, byType[0].ID)

	byStatus := decodeReports(t, mustOK(t, h.adminClient(tn).Get("/api/v1/dvir-reports",
		testutil.Query("status", dto.StatusSubmittedNoDefects),
		testutil.Query("unit_id", tn.Unit.ID.String()))))
	require.NotEmpty(t, byStatus)
	for _, r := range byStatus {
		require.Equal(t, dto.StatusSubmittedNoDefects, r.Status)
	}

	// A self scoped driver only ever sees its own reports.
	mine := decodeReports(t, mustOK(t, h.driverClient(tn).Get("/api/v1/dvir-reports")))
	for _, r := range mine {
		require.NotNil(t, r.Driver)
		require.Equal(t, tn.Driver.ID.String(), r.Driver.ID)
	}
	require.Contains(t, ids(mine), pre.ID)

	bad := h.adminClient(tn).Get("/api/v1/dvir-reports", testutil.Query("status", "nope"))
	testutil.RequireStatusCode(t, bad, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestDefectTypeCatalogue(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allDvirPerms...)
	client := h.adminClient(tn)

	// The 61 shared defaults are visible to every tenant and read only.
	defaults := decodeDefectTypes(t, mustOK(t, client.Get("/api/v1/defect-types",
		testutil.Query("per_page", "50"))))
	require.NotEmpty(t, defaults)
	var systemID string
	for _, d := range defaults {
		if d.IsSystem {
			systemID = d.ID
			break
		}
	}
	require.NotEmpty(t, systemID, "the seeded catalogue must be visible")

	locked := client.Patch("/api/v1/defect-types/"+systemID, dto.DefectTypeUpdate{IsActive: boolPtr(false)})
	testutil.RequireStatusCode(t, locked, http.StatusConflict, apierr.CodeDefectTypeSystemLocked)

	created := decodeDefectType(t, mustCreated(t, client.Post("/api/v1/defect-types", dto.DefectTypeCreate{
		Name: "Custom hydraulics " + uuid.NewString()[:8], Category: dto.CategoryTruck,
		IsCritical: true, IsActive: true, SortOrder: 99,
	})))
	require.False(t, created.IsSystem)
	require.True(t, created.IsCritical)

	patched := decodeDefectType(t, mustOK(t, client.Patch("/api/v1/defect-types/"+created.ID,
		dto.DefectTypeUpdate{IsCritical: boolPtr(false), IsActive: boolPtr(false)})))
	require.False(t, patched.IsCritical)
	require.False(t, patched.IsActive)

	// An inactive type can no longer be reported.
	resp := h.driverClient(tn).Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID: tn.Unit.ID.String(), Type: dto.TypePreTrip,
		DriverSignatureKey: objKey(tn, "signature", "sig.png"),
		Defects:            []dto.DefectInput{{DefectTypeID: created.ID}},
	})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeDefectTypeUnknown)
}

// ---------------------------------------------------------------- isolation

func TestCrossTenantAccessAnswers404(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allDvirPerms...)
	rep := submit(t, h, a, dto.TypePreTrip)

	other := h.adminClient(b)
	testutil.RequireStatusCode(t, other.Get("/api/v1/dvir-reports/"+rep.ID),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, other.Get("/api/v1/dvir-reports/"+rep.ID+"/pdf"),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, other.Post("/api/v1/dvir-reports/"+rep.ID+"/repair",
		dto.DvirRepair{MechanicNote: "x", MechanicSignatureKey: "k"}),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, h.srv.AsPrincipal(b.DriverPrincipal(allDvirPerms...)).
		Post("/api/v1/dvir-reports/"+rep.ID+"/certify", dto.DvirCertify{SignatureKey: "k"}),
		http.StatusNotFound, apierr.CodeNotFound)

	// A unit of another tenant is equally invisible on create.
	testutil.RequireStatusCode(t, h.srv.AsPrincipal(b.DriverPrincipal(allDvirPerms...)).
		Post("/api/v1/dvir-reports", dto.DvirCreate{
			UnitID: a.Unit.ID.String(), Type: dto.TypePreTrip,
			DriverSignatureKey: objKey(b, "signature", "sig.png"),
		}), http.StatusNotFound, apierr.CodeNotFound)
}

func TestUnauthenticatedAndUnprivilegedCallsAreRefused(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t) // no permissions at all

	testutil.RequireStatus(t, h.srv.Anonymous().Get("/api/v1/dvir-reports"), http.StatusUnauthorized)
	testutil.RequireStatusCode(t, h.srv.AsTenant(tn).Get("/api/v1/dvir-reports"),
		http.StatusForbidden, apierr.CodeForbidden)
}

// ---------------------------------------------------------------- helpers

type recordingAlerter struct {
	seen []string
}

func (r *recordingAlerter) Alert(_ context.Context, kind string, _ dvir.Alert) error {
	r.seen = append(r.seen, kind)
	return nil
}

func (r *recordingAlerter) kinds() []string { return r.seen }

func mustOK(t testing.TB, resp *testutil.Response) *testutil.Response {
	t.Helper()
	testutil.RequireStatus(t, resp, http.StatusOK)
	return resp
}

func mustCreated(t testing.TB, resp *testutil.Response) *testutil.Response {
	t.Helper()
	testutil.RequireStatus(t, resp, http.StatusCreated)
	return resp
}

func decodeDefectType(t testing.TB, resp *testutil.Response) dto.DefectType {
	t.Helper()
	var env struct {
		Data dto.DefectType `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

func decodeDefectTypes(t testing.TB, resp *testutil.Response) []dto.DefectType {
	t.Helper()
	var env struct {
		Data []dto.DefectType `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

func ids(reports []dto.DvirReport) []string {
	out := make([]string, 0, len(reports))
	for _, r := range reports {
		out = append(out, r.ID)
	}
	return out
}

func boolPtr(v bool) *bool { return &v }

func unitOutOfService(t testing.TB, unitID uuid.UUID) bool {
	t.Helper()
	var v bool
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT out_of_service FROM units WHERE id = $1`, unitID).Scan(&v))
	return v
}

func setUnitStatus(t testing.TB, unitID uuid.UUID, status string) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE units SET status = $2 WHERE id = $1`, unitID, status)
	require.NoError(t, err)
}

// backdate moves a report into the past so the grace window has elapsed.
func backdate(t testing.TB, id string, days int) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		fmt.Sprintf(`UPDATE dvir_reports SET performed_at = now() - interval '%d days' WHERE id = $1`, days), id)
	require.NoError(t, err)
}
