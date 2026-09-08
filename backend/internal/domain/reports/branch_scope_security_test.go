//go:build integration

// Branch scope regression coverage of the reporting module (TZ A§16 / Q82).
//
// A `branch` scoped role must not read company wide aggregates: the activity
// report is partitioned by units.branch_id / drivers.branch_id (the subject of
// the row is what the branch owns) and Distance by Region by units.branch_id.
// The asynchronous export is rendered by a worker with no request scope, so
// the caller's branch is frozen into report_export_jobs.params at creation
// time; a rendered export is only readable by the user that asked for it.
package reports_test

import (
	"encoding/json"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/reports/dto"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// branchPrincipal builds a `branch` scoped principal pinned to branchID. It is
// a user of its own: an export requested by the administrator must not be
// readable just because both principals happen to share a user row.
func branchPrincipal(t testing.TB, tn *testutil.Tenant, branchID uuid.UUID,
	permissions ...string) *tenant.Principal {
	t.Helper()
	user := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role), testutil.WithBranchID(branchID))
	p := tn.Principal()
	p.UserID = user.ID
	p.Scope = tenant.ScopeBranch
	p.BranchID = &branchID
	if len(permissions) > 0 {
		p.Permissions = permissions
	}
	return p
}

// twoBranchFixture is one tenant with a unit and a driver in each of two
// branches, both reporting telemetry on the same day.
type twoBranchFixture struct {
	tn                   *testutil.Tenant
	north, south         testutil.Branch
	northUnit, southUnit testutil.Unit
	northDriver          testutil.Driver
	southDriver          testutil.Driver
}

func seedTwoBranches(t testing.TB) twoBranchFixture {
	t.Helper()
	tn := testutil.SeedTenant(t, allReportPerms...)
	north := tn.Branch
	south := testutil.NewBranch(t, tn.ID())

	newSide := func(b testutil.Branch, odo int64) (testutil.Unit, testutil.Driver) {
		unit := testutil.NewUnit(t, tn.ID(), testutil.WithBranch(b))
		user := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))
		driver := testutil.NewDriver(t, tn.ID(), testutil.WithUser(user), testutil.WithBranch(b))
		seedTelemetry(t, tn.ID(), unit.ID, driver.ID, day.Add(6*time.Hour), 39.78, -89.65, odo)
		seedTelemetry(t, tn.ID(), unit.ID, driver.ID, day.Add(18*time.Hour), 41.87, -87.62, odo+750_000)
		return unit, driver
	}

	f := twoBranchFixture{tn: tn, north: north, south: south}
	f.northUnit, f.northDriver = newSide(north, 100_000_000)
	f.southUnit, f.southDriver = newSide(south, 200_000_000)
	return f
}

func activityIDs(t testing.TB, resp *testutil.Response) []string {
	t.Helper()
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env struct {
		Data []dto.ActivityRow `json:"data"`
	}
	resp.JSON(&env)
	out := make([]string, 0, len(env.Data))
	for _, r := range env.Data {
		out = append(out, r.SubjectID)
	}
	return out
}

func TestActivityReportIsPartitionedByBranch(t *testing.T) {
	h := newHarness(t)
	f := seedTwoBranches(t)
	mgr := h.srv.AsPrincipal(branchPrincipal(t, f.tn, f.north.ID, allReportPerms...))

	units := activityIDs(t, mgr.Get("/api/v1/reports/activity",
		testutil.Query("subject", dto.SubjectUnits),
		testutil.Query("from", "2026-09-06"), testutil.Query("to", "2026-09-06")))
	require.Contains(t, units, f.northUnit.ID.String())
	require.NotContains(t, units, f.southUnit.ID.String(),
		"a branch manager must not see another branch's unit odometer")

	drivers := activityIDs(t, mgr.Get("/api/v1/reports/activity",
		testutil.Query("subject", dto.SubjectDrivers),
		testutil.Query("from", "2026-09-06"), testutil.Query("to", "2026-09-06")))
	require.Contains(t, drivers, f.northDriver.ID.String())
	require.NotContains(t, drivers, f.southDriver.ID.String())

	// An explicit filter on the other branch's subject cannot widen the page.
	foreign := activityIDs(t, mgr.Get("/api/v1/reports/activity",
		testutil.Query("subject", dto.SubjectUnits),
		testutil.Query("unit_id", f.southUnit.ID.String()),
		testutil.Query("from", "2026-09-06"), testutil.Query("to", "2026-09-06")))
	require.Empty(t, foreign)

	// The company scoped caller still sees both branches.
	all := activityIDs(t, h.srv.AsTenant(f.tn).Get("/api/v1/reports/activity",
		testutil.Query("subject", dto.SubjectUnits), testutil.Query("per_page", "50"),
		testutil.Query("from", "2026-09-06"), testutil.Query("to", "2026-09-06")))
	require.Contains(t, all, f.northUnit.ID.String())
	require.Contains(t, all, f.southUnit.ID.String())
}

func TestDistanceByRegionIsPartitionedByBranch(t *testing.T) {
	h := newHarness(t)
	f := seedTwoBranches(t)
	seedRegion(t, "US-IL-BR", "Illinois (branch fixture)", 39.78, -89.65, 1)
	seedRegion(t, "US-IN-BR", "Indiana (branch fixture)", 39.78, -86.15, 1)
	seedRegionDistance(t, f.tn.ID(), f.northUnit.ID, "US-IL-BR", day, 120_000)
	seedRegionDistance(t, f.tn.ID(), f.southUnit.ID, "US-IN-BR", day, 340_000)

	mgr := h.srv.AsPrincipal(branchPrincipal(t, f.tn, f.north.ID, allReportPerms...))
	resp := mgr.Get("/api/v1/reports/distance-by-region",
		testutil.Query("quarter", "3"), testutil.Query("year", "2026"))
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env struct {
		Data []dto.RegionDistanceRow  `json:"data"`
		Meta dto.DistanceByRegionMeta `json:"meta"`
	}
	resp.JSON(&env)

	for _, r := range env.Data {
		require.NotEqual(t, f.southUnit.ID.String(), r.UnitID,
			"another branch's unit must not appear in the roll-up")
		require.NotEqual(t, "US-IN-BR", r.RegionCode)
	}
	require.EqualValues(t, 120_000, env.Meta.TotalDistanceM,
		"the total must be summed over the branch rows only")
}

func TestExportJobFreezesTheRequesterBranch(t *testing.T) {
	h := newHarness(t)
	f := seedTwoBranches(t)
	mgr := h.srv.AsPrincipal(branchPrincipal(t, f.tn, f.north.ID, allReportPerms...))

	// A branch manager cannot smuggle another branch into the export params:
	// the server overwrites the field with the caller's own branch.
	resp := mgr.Post("/api/v1/reports/export-jobs", map[string]any{
		"type": dto.TypeActivity, "format": dto.FormatCSV,
		"params": map[string]any{
			"from": "2026-09-06", "to": "2026-09-06", "subject": dto.SubjectUnits,
			"branch_id": f.south.ID.String(),
		},
	})
	testutil.RequireStatus(t, resp, http.StatusAccepted)
	job := decodeJob(t, resp)

	var raw []byte
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT params FROM report_export_jobs WHERE id = $1`, uuid.MustParse(job.ID)).Scan(&raw))
	var stored dto.ExportParams
	require.NoError(t, json.Unmarshal(raw, &stored))
	require.Equal(t, f.north.ID.String(), stored.BranchID,
		"the worker renders with the requester's branch, not the one it asked for")

	// The rendered artefact only contains the caller's branch.
	require.NoError(t, h.run.Run(tenantCtx(t, f.tn.ID()), uuid.MustParse(job.ID)))
	done := decodeJob(t, mgr.Get("/api/v1/reports/export-jobs/"+job.ID))
	require.Equal(t, dto.StatusDone, done.Status)

	key := exportKey(t, uuid.MustParse(job.ID))
	object, ok := h.files.Object(key)
	require.True(t, ok, "the runner must have stored the artefact")
	require.Contains(t, string(object.Body), f.northUnit.UnitNumber)
	require.NotContains(t, string(object.Body), f.southUnit.UnitNumber,
		"the export must not carry another branch's unit")
}

func TestBranchScopedCallerOnlyReadsItsOwnExports(t *testing.T) {
	h := newHarness(t)
	f := seedTwoBranches(t)

	// An administrator renders a company wide export.
	admin := h.srv.AsTenant(f.tn)
	resp := admin.Post("/api/v1/reports/export-jobs", map[string]any{
		"type": dto.TypeActivity, "format": dto.FormatCSV,
		"params": map[string]any{"from": "2026-09-06", "to": "2026-09-06", "subject": dto.SubjectUnits},
	})
	testutil.RequireStatus(t, resp, http.StatusAccepted)
	companyJob := decodeJob(t, resp)
	require.NoError(t, h.run.Run(tenantCtx(t, f.tn.ID()), uuid.MustParse(companyJob.ID)))

	mgr := h.srv.AsPrincipal(branchPrincipal(t, f.tn, f.north.ID, allReportPerms...))
	testutil.RequireStatusCode(t, mgr.Get("/api/v1/reports/export-jobs/"+companyJob.ID),
		http.StatusNotFound, apierr.CodeNotFound)

	var env struct {
		Data []dto.ExportJob `json:"data"`
	}
	list := mgr.Get("/api/v1/reports/export-jobs", testutil.Query("per_page", "50"))
	testutil.RequireStatus(t, list, http.StatusOK)
	list.JSON(&env)
	for _, j := range env.Data {
		require.NotEqual(t, companyJob.ID, j.ID,
			"a company wide export must not be listed to a branch scoped caller")
	}

	// The administrator still reaches its own job.
	testutil.RequireStatus(t, admin.Get("/api/v1/reports/export-jobs/"+companyJob.ID), http.StatusOK)
}

// exportKey reads the object key the runner stored for a finished job.
func exportKey(t testing.TB, jobID uuid.UUID) string {
	t.Helper()
	var key *string
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT file_key FROM report_export_jobs WHERE id = $1`, jobID).Scan(&key))
	require.NotNil(t, key)
	return *key
}
