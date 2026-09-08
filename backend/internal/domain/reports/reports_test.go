//go:build integration

// Integration coverage of the reporting module (TZ §14): the Q75 odometer
// change, Distance by Region served from the daily roll-up, the roll-up job
// itself, the asynchronous export lifecycle with its 24 hour download link,
// the regulation profile gate on the regulator export and cross-tenant
// isolation (404, never 403).
package reports_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/reports"
	"github.com/devline/onebook-eld/internal/domain/reports/dto"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// allReportPerms is every permission the module gates on.
var allReportPerms = []string{core.PermReportsRead, core.PermReportsExport}

// baseNow is the frozen clock of the harness.
var baseNow = time.Date(2026, 9, 10, 12, 0, 0, 0, time.UTC)

// day is the telemetry day every fixture writes into.
var day = time.Date(2026, 9, 6, 0, 0, 0, 0, time.UTC)

type harness struct {
	srv   *testutil.TestServer
	svc   *reports.Service
	run   *reports.Runner
	files *storage.Fake
	pool  *db.Pool
}

func newHarness(t testing.TB) *harness {
	t.Helper()
	pool := testutil.NewDB(t)
	repo := reports.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger()))
	files := storage.NewFake()
	now := func() time.Time { return baseNow }

	builder := reports.NewBuilder(repo, nil, reports.HTMLRenderer{}, testutil.Logger(), now)
	mod := reports.New(reports.Deps{
		Repo:     repo,
		Verifier: testutil.ContextVerifier(),
		Files:    files,
		Builder:  builder,
		Log:      testutil.Logger(),
		Now:      now,
	})
	return &harness{
		srv:   testutil.NewServer(t, mod),
		svc:   mod.Service(),
		run:   reports.NewRunner(repo, builder, files, nil, testutil.Logger(), now),
		files: files,
		pool:  pool,
	}
}

func tenantCtx(t testing.TB, companyID uuid.UUID) context.Context {
	t.Helper()
	return tenant.WithCompanyID(testutil.Ctx(t), companyID)
}

// ------------------------------------------------------------- fixtures

// seedTelemetry writes one sample with an odometer reading.
func seedTelemetry(t testing.TB, companyID, unitID, driverID uuid.UUID,
	ts time.Time, lat, lng float64, odometerM int64) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO telemetry (ts, company_id, unit_id, driver_id, lat, lng, odometer_m, source)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,'eld')
		 ON CONFLICT (unit_id, ts) DO NOTHING`,
		ts, companyID, unitID, driverID, lat, lng, odometerM)
	require.NoError(t, err, "seed telemetry")
}

// seedRegionDistance writes one row of the daily roll-up the report reads.
func seedRegionDistance(t testing.TB, companyID, unitID uuid.UUID, code string, on time.Time, distanceM int64) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO unit_region_distance_daily (unit_id, region_code, date, company_id, distance_m)
		 VALUES ($1,$2,$3,$4,$5)
		 ON CONFLICT (unit_id, region_code, date) DO UPDATE SET distance_m = EXCLUDED.distance_m`,
		unitID, code, on, companyID, distanceM)
	require.NoError(t, err, "seed unit_region_distance_daily")
}

// seedRegion inserts a square jurisdiction polygon around a point. `regions`
// is a global reference table, so it is shared by every tenant.
func seedRegion(t testing.TB, code, name string, lat, lng, halfSideDeg float64) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO regions (code, name, country, geom) VALUES ($1,$2,'US',
		   ST_Multi(ST_SetSRID(ST_MakeEnvelope($3,$4,$5,$6), 4326)))
		 ON CONFLICT (code) DO UPDATE SET geom = EXCLUDED.geom`,
		code, name, lng-halfSideDeg, lat-halfSideDeg, lng+halfSideDeg, lat+halfSideDeg)
	require.NoError(t, err, "seed region")
}

// setRegulationProfile flips the tenant onto another regulation profile.
func setRegulationProfile(t testing.TB, companyID uuid.UUID, profile string) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE companies SET regulation_profile = $2 WHERE id = $1`, companyID, profile)
	require.NoError(t, err, "set regulation_profile")
}

func decodeJob(t testing.TB, resp *testutil.Response) dto.ExportJob {
	t.Helper()
	var env struct {
		Data dto.ExportJob `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

// ------------------------------------------------------- activity report

func TestActivityReportComputesOdometerChange(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)

	seedTelemetry(t, tn.ID(), tn.Unit.ID, tn.Driver.ID, day.Add(6*time.Hour), 39.78, -89.65, 128_430_000)
	seedTelemetry(t, tn.ID(), tn.Unit.ID, tn.Driver.ID, day.Add(18*time.Hour), 41.87, -87.62, 129_180_000)

	resp := h.srv.AsTenant(tn).Get("/api/v1/reports/activity",
		testutil.Query("subject", dto.SubjectUnits),
		testutil.Query("from", "2026-09-06"),
		testutil.Query("to", "2026-09-06"))
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env struct {
		Data []dto.ActivityRow `json:"data"`
	}
	resp.JSON(&env)

	var row *dto.ActivityRow
	for i := range env.Data {
		if env.Data[i].SubjectID == tn.Unit.ID.String() {
			row = &env.Data[i]
		}
	}
	require.NotNil(t, row, "the seeded unit must appear in the report")
	require.True(t, row.HasData)
	require.Equal(t, int64(128_430_000), row.StartOdometerM)
	require.Equal(t, int64(129_180_000), row.EndOdometerM)
	// Q75: Odometer Change = End − Start.
	require.Equal(t, int64(750_000), row.OdometerChangeM)
}

func TestActivityReportReportsUnitsWithoutTelemetryAsEmpty(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)

	resp := h.srv.AsTenant(tn).Get("/api/v1/reports/activity",
		testutil.Query("from", "2026-09-06"), testutil.Query("to", "2026-09-06"))
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env struct {
		Data []dto.ActivityRow `json:"data"`
	}
	resp.JSON(&env)
	for _, row := range env.Data {
		if row.SubjectID == tn.Unit.ID.String() {
			require.False(t, row.HasData)
			require.Zero(t, row.OdometerChangeM, "a silent unit must not report a negative change")
		}
	}
}

func TestActivityReportRejectsAnInvertedWindow(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)

	resp := h.srv.AsTenant(tn).Get("/api/v1/reports/activity",
		testutil.Query("from", "2026-09-30"), testutil.Query("to", "2026-09-01"))
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

// -------------------------------------------------- distance by region

func TestDistanceByRegionIsServedFromTheDailyRollUp(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)
	seedRegion(t, "US-IL-RPT", "Illinois", 39.78, -89.65, 2)

	seedRegionDistance(t, tn.ID(), tn.Unit.ID, "US-IL-RPT", day, 412_000)
	seedRegionDistance(t, tn.ID(), tn.Unit.ID, "US-IL-RPT", day.AddDate(0, 0, 1), 88_000)

	c := h.srv.AsTenant(tn)
	resp := c.Get("/api/v1/reports/distance-by-region",
		testutil.Query("quarter", "3"), testutil.Query("year", "2026"),
		testutil.Query("mode", dto.ModeRegionsAndUnits),
		testutil.Query("unit_id", tn.Unit.ID.String()))
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env struct {
		Data []dto.RegionDistanceRow  `json:"data"`
		Meta dto.DistanceByRegionMeta `json:"meta"`
	}
	resp.JSON(&env)
	require.Len(t, env.Data, 1, "one unit in one region is one row")
	require.Equal(t, "US-IL-RPT", env.Data[0].RegionCode)
	require.Equal(t, tn.Unit.ID.String(), env.Data[0].UnitID)
	require.Equal(t, int64(500_000), env.Data[0].DistanceM, "the quarter is the sum of its days")
	require.Equal(t, "2026-07-01", env.Meta.From)
	require.Equal(t, "2026-09-30", env.Meta.To)
	require.Equal(t, int64(500_000), env.Meta.TotalDistanceM)

	// regions_only collapses the unit column away. It decodes into a fresh
	// value: encoding/json merges into existing slice elements, so reusing the
	// previous one would silently keep its unit_id.
	resp = c.Get("/api/v1/reports/distance-by-region",
		testutil.Query("quarter", "3"), testutil.Query("year", "2026"),
		testutil.Query("mode", dto.ModeRegionsOnly),
		testutil.Query("unit_id", tn.Unit.ID.String()))
	testutil.RequireStatus(t, resp, http.StatusOK)

	var only struct {
		Data []dto.RegionDistanceRow `json:"data"`
	}
	resp.JSON(&only)
	require.Len(t, only.Data, 1)
	require.Empty(t, only.Data[0].UnitID)
	require.Equal(t, int64(500_000), only.Data[0].DistanceM)
}

func TestDistanceByRegionRejectsABadQuarter(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)

	resp := h.srv.AsTenant(tn).Get("/api/v1/reports/distance-by-region",
		testutil.Query("quarter", "7"), testutil.Query("year", "2026"))
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestRegionRollUpAggregatesTheTrackAndIsIdempotent(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)
	// Deliberately far from every other fixture polygon: FindRegionByPoint
	// answers the first match, so overlapping test jurisdictions would make
	// this assertion depend on insertion order.
	seedRegion(t, "US-AGG", "Aggregation land", 5.0, 5.0, 1)

	// A straight eastbound run of roughly 1 km inside the polygon.
	for i := 0; i < 10; i++ {
		seedTelemetry(t, tn.ID(), tn.Unit.ID, tn.Driver.ID,
			day.Add(time.Duration(i)*time.Minute), 5.0, 5.0+float64(i)*0.001, int64(1_000_000+i*100))
	}
	ctx := tenantCtx(t, tn.ID())

	n, err := h.svc.AggregateRegionDistance(ctx, day)
	require.NoError(t, err)
	require.Equal(t, 1, n, "one unit, one region")

	first := readRegionDistance(t, tn.ID(), tn.Unit.ID, "US-AGG", day)
	require.Greater(t, first, int64(500), "the track must accumulate a real distance")

	// Rerunning the same day must not double count.
	_, err = h.svc.AggregateRegionDistance(ctx, day)
	require.NoError(t, err)
	require.Equal(t, first, readRegionDistance(t, tn.ID(), tn.Unit.ID, "US-AGG", day))

	// And the report now answers straight from that roll-up.
	resp := h.srv.AsTenant(tn).Get("/api/v1/reports/distance-by-region",
		testutil.Query("quarter", "3"), testutil.Query("year", "2026"),
		testutil.Query("unit_id", tn.Unit.ID.String()))
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env struct {
		Data []dto.RegionDistanceRow `json:"data"`
	}
	resp.JSON(&env)
	require.Len(t, env.Data, 1)
	require.Equal(t, first, env.Data[0].DistanceM)
}

func readRegionDistance(t testing.TB, companyID, unitID uuid.UUID, code string, on time.Time) int64 {
	t.Helper()
	var out int64
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT COALESCE(sum(distance_m),0) FROM unit_region_distance_daily
		  WHERE company_id=$1 AND unit_id=$2 AND region_code=$3 AND date=$4`,
		companyID, unitID, code, on).Scan(&out)
	require.NoError(t, err)
	return out
}

// ------------------------------------------------------------ export jobs

func TestExportJobRunsEndToEndAndExpiresInTwentyFourHours(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)
	seedTelemetry(t, tn.ID(), tn.Unit.ID, tn.Driver.ID, day.Add(6*time.Hour), 39.78, -89.65, 100)
	seedTelemetry(t, tn.ID(), tn.Unit.ID, tn.Driver.ID, day.Add(9*time.Hour), 39.79, -89.64, 5_000)
	c := h.srv.AsTenant(tn)

	resp := c.Post("/api/v1/reports/export-jobs", map[string]any{
		"type":   dto.TypeActivity,
		"format": dto.FormatCSV,
		"params": map[string]any{"subject": dto.SubjectUnits, "from": "2026-09-06", "to": "2026-09-06"},
	})
	testutil.RequireStatus(t, resp, http.StatusAccepted)

	queued := decodeJob(t, resp)
	require.Equal(t, dto.StatusQueued, queued.Status)
	require.Empty(t, queued.DownloadURL, "a queued job has nothing to download yet")

	jobID := uuid.MustParse(queued.ID)
	require.NoError(t, h.run.Run(tenantCtx(t, tn.ID()), jobID))

	done := decodeJob(t, c.Get("/api/v1/reports/export-jobs/"+queued.ID))
	require.Equal(t, dto.StatusDone, done.Status)
	require.NotEmpty(t, done.FileName)
	require.Greater(t, done.FileSizeB, int64(0))
	require.NotEmpty(t, done.DownloadURL, "a finished job carries a presigned link")
	require.NotNil(t, done.ExpiresAt)
	// Q75: the link is valid for 24 hours.
	require.Equal(t, baseNow.Add(24*time.Hour), done.ExpiresAt.UTC())
	require.NotNil(t, done.FinishedAt)

	// The rendered bytes really landed in object storage under a tenant key.
	key := readFileKey(t, jobID)
	require.Contains(t, key, tn.ID().String(), "the object key is tenant scoped")
	obj, ok := h.files.Object(key)
	require.True(t, ok, "the export must be uploaded")
	require.Contains(t, string(obj.Body), "Odometer change (m)")

	// Creating and finishing an export are both audited (who exported what).
	require.GreaterOrEqual(t, countExportAudit(t, tn.ID(), jobID), 2)
}

func TestExpiredExportDropsItsDownloadLink(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)
	c := h.srv.AsTenant(tn)

	resp := c.Post("/api/v1/reports/export-jobs", map[string]any{
		"type":   dto.TypeHOS,
		"format": dto.FormatCSV,
		"params": map[string]any{"from": "2026-09-01", "to": "2026-09-06"},
	})
	testutil.RequireStatus(t, resp, http.StatusAccepted)
	job := decodeJob(t, resp)
	require.NoError(t, h.run.Run(tenantCtx(t, tn.ID()), uuid.MustParse(job.ID)))

	// Age the job past its window: the link must disappear with the file.
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE report_export_jobs SET expires_at = now() - interval '1 minute' WHERE id = $1`,
		uuid.MustParse(job.ID))
	require.NoError(t, err)

	expired := decodeJob(t, c.Get("/api/v1/reports/export-jobs/"+job.ID))
	require.Equal(t, dto.StatusDone, expired.Status)
	require.Empty(t, expired.DownloadURL, "the 24 hour window is over")
}

func TestExportJobFailsCleanlyOnABadWindow(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)
	c := h.srv.AsTenant(tn)

	resp := c.Post("/api/v1/reports/export-jobs", map[string]any{
		"type": dto.TypeHOS, "params": map[string]any{"from": "2026-09-01"},
	})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestRegulatorExportIsGatedOnTheRegulationProfile(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allReportPerms...)
	c := h.srv.AsTenant(tn)
	body := map[string]any{
		"type":   dto.TypeRegulator,
		"params": map[string]any{"from": "2026-09-01", "to": "2026-09-08", "comment": "Roadside"},
	}

	// The seeded company is on `us_fmcsa`: the FMCSA output file is stage two.
	setRegulationProfile(t, tn.ID(), "us_fmcsa")
	resp := c.Post("/api/v1/reports/export-jobs", body)
	testutil.RequireStatusCode(t, resp, http.StatusNotImplemented, apierr.CodeFeatureDisabled)

	// On `generic` the bundle is produced immediately as a PDF + CSV archive.
	setRegulationProfile(t, tn.ID(), "generic")
	resp = c.Post("/api/v1/reports/export-jobs", body)
	testutil.RequireStatus(t, resp, http.StatusAccepted)

	job := decodeJob(t, resp)
	require.Equal(t, dto.FormatZIP, job.Format, "the regulator bundle is always an archive")
	require.NoError(t, h.run.Run(tenantCtx(t, tn.ID()), uuid.MustParse(job.ID)))

	done := decodeJob(t, c.Get("/api/v1/reports/export-jobs/"+job.ID))
	require.Equal(t, dto.StatusDone, done.Status)
	obj, ok := h.files.Object(readFileKey(t, uuid.MustParse(job.ID)))
	require.True(t, ok)
	require.Equal(t, "application/zip", obj.ContentType)
	require.Equal(t, []byte("PK"), obj.Body[:2], "a ZIP archive starts with the PK signature")
}

func readFileKey(t testing.TB, jobID uuid.UUID) string {
	t.Helper()
	var key string
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT file_key FROM report_export_jobs WHERE id = $1`, jobID).Scan(&key))
	return key
}

func countExportAudit(t testing.TB, companyID, jobID uuid.UUID) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM audit_log
		  WHERE company_id=$1 AND table_name='report_export_jobs' AND record_id=$2 AND action='export'`,
		companyID, jobID).Scan(&n))
	return n
}

// ------------------------------------------------------------- isolation

func TestCrossTenantExportJobAnswersNotFound(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allReportPerms...)

	resp := h.srv.AsTenant(a).Post("/api/v1/reports/export-jobs", map[string]any{
		"type": dto.TypeHOS, "format": dto.FormatCSV,
		"params": map[string]any{"from": "2026-09-01", "to": "2026-09-06"},
	})
	testutil.RequireStatus(t, resp, http.StatusAccepted)
	job := decodeJob(t, resp)

	testutil.RequireStatus(t, h.srv.AsTenant(b).Get("/api/v1/reports/export-jobs/"+job.ID),
		http.StatusNotFound)
}

func TestReportsRequireTheirPermission(t *testing.T) {
	h := newHarness(t)
	tn := testutil.SeedTenant(t, core.PermReportsRead)
	c := h.srv.AsTenant(tn)

	// reports.read is enough to look, never to export.
	testutil.RequireStatus(t, c.Get("/api/v1/reports/distance-by-region",
		testutil.Query("quarter", "3"), testutil.Query("year", "2026")), http.StatusOK)
	testutil.RequireStatus(t, c.Post("/api/v1/reports/export-jobs", map[string]any{
		"type": dto.TypeHOS, "params": map[string]any{"from": "2026-09-01", "to": "2026-09-06"},
	}), http.StatusForbidden)
}
