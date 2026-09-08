//go:build integration

// Export download hardening (Q75, TZ B§3.4). A presigned GET cannot be
// revoked, so the key that is about to be signed must be re-checked against
// the caller's tenant prefix even though the job row is already company
// scoped: a corrupted or migrated `file_key` must never become a signature
// over another company's object.
package reports_test

import (
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/reports/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

// finishedJob queues and renders one CSV export, returning the wire job.
func finishedJob(t testing.TB, h *harness, tn *testutil.Tenant) dto.ExportJob {
	t.Helper()
	resp := h.srv.AsTenant(tn).Post("/api/v1/reports/export-jobs", map[string]any{
		"type": dto.TypeHOS, "format": dto.FormatCSV,
		"params": map[string]any{"from": "2026-09-01", "to": "2026-09-06"},
	})
	testutil.RequireStatus(t, resp, http.StatusAccepted)
	job := decodeJob(t, resp)
	require.NoError(t, h.run.Run(tenantCtx(t, tn.ID()), uuid.MustParse(job.ID)))
	return job
}

func TestDownloadLinkIsNeverSignedForAForeignKey(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allReportPerms...)

	job := finishedJob(t, h, a)
	ready := decodeJob(t, h.srv.AsTenant(a).Get("/api/v1/reports/export-jobs/"+job.ID))
	require.NotEmpty(t, ready.DownloadURL, "the baseline must produce a link")

	// Repoint the stored key at the other tenant's namespace.
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE report_export_jobs SET file_key = $2 WHERE id = $1`,
		uuid.MustParse(job.ID), b.ID().String()+"/reports/2026/09/stolen.csv")
	require.NoError(t, err)

	tampered := decodeJob(t, h.srv.AsTenant(a).Get("/api/v1/reports/export-jobs/"+job.ID))
	require.Empty(t, tampered.DownloadURL, "a key outside the tenant prefix is never signed")

	// The same holds for a key with no tenant prefix at all.
	_, err = testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE report_export_jobs SET file_key = 'reports/2026/09/stolen.csv' WHERE id = $1`,
		uuid.MustParse(job.ID))
	require.NoError(t, err)
	bare := decodeJob(t, h.srv.AsTenant(a).Get("/api/v1/reports/export-jobs/"+job.ID))
	require.Empty(t, bare.DownloadURL)
}

func TestExportJobListNeverLeaksAnotherTenantsJob(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allReportPerms...)

	mine := finishedJob(t, h, a)
	theirs := finishedJob(t, h, b)

	resp := h.srv.AsTenant(a).Get("/api/v1/reports/export-jobs", testutil.Query("per_page", "50"))
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env struct {
		Data []dto.ExportJob `json:"data"`
	}
	resp.JSON(&env)

	ids := make([]string, 0, len(env.Data))
	for _, j := range env.Data {
		ids = append(ids, j.ID)
	}
	require.Contains(t, ids, mine.ID)
	require.NotContains(t, ids, theirs.ID)
}

func TestExportParamsCannotWidenTheTenant(t *testing.T) {
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allReportPerms...)
	seedTelemetry(t, b.ID(), b.Unit.ID, b.Driver.ID, day.Add(6*time.Hour), 39.78, -89.65, 100)

	// `params` is a typed struct and the decoder refuses unknown fields, so a
	// smuggled company_id never even reaches the job row.
	testutil.RequireStatusCode(t, h.srv.AsTenant(a).Post("/api/v1/reports/export-jobs", map[string]any{
		"type": dto.TypeActivity, "format": dto.FormatCSV,
		"params": map[string]any{
			"subject": dto.SubjectUnits, "from": "2026-09-06", "to": "2026-09-06",
			"company_id": b.ID().String(),
		},
	}), http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// A foreign unit id in the filters narrows to nothing instead of widening.
	resp := h.srv.AsTenant(a).Post("/api/v1/reports/export-jobs", map[string]any{
		"type": dto.TypeActivity, "format": dto.FormatCSV,
		"params": map[string]any{
			"subject":  dto.SubjectUnits,
			"from":     "2026-09-06",
			"to":       "2026-09-06",
			"unit_ids": []string{b.Unit.ID.String()},
		},
	})
	testutil.RequireStatus(t, resp, http.StatusAccepted)
	job := decodeJob(t, resp)
	require.NoError(t, h.run.Run(tenantCtx(t, a.ID()), uuid.MustParse(job.ID)))

	obj, ok := h.files.Object(readFileKey(t, uuid.MustParse(job.ID)))
	require.True(t, ok)
	require.NotContains(t, string(obj.Body), b.Unit.UnitNumber,
		"an export must never render another tenant's rows")
}
