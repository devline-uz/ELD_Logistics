//go:build integration

// Integration coverage of the file, import and export module: the presign
// whitelist, all-or-nothing CSV/XLSX imports, the export audit entry and the
// import NFR (1000 rows under 30 s).
package files_test

import (
	"bytes"
	"context"
	"encoding/csv"
	"fmt"
	"mime/multipart"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/domain/files"
	"github.com/devline/onebook-eld/internal/domain/files/dto"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

var filePermissions = []string{
	core.PermFilesUpload,
	core.PermDriversImport, core.PermDriversExport,
	core.PermUnitsImport, core.PermUnitsExport,
}

func ctxVerifier() mw.AuthVerifier {
	return mw.VerifierFunc(func(ctx context.Context, _ string) (*tenant.Principal, error) {
		if p, ok := tenant.PrincipalFrom(ctx); ok {
			return p, nil
		}
		return nil, apierr.Unauthorized("no test principal")
	})
}

func newServer(t *testing.T) (*testutil.TestServer, *storage.Fake) {
	t.Helper()
	pool := testutil.NewDB(t)
	cipher, err := appcrypto.NewCipherFromString(testutil.TestConfig().EncryptionKey)
	require.NoError(t, err)

	recorder := audit.NewPgRecorder(pool, testutil.Logger())
	fake := storage.NewFake()

	mod := files.New(files.Deps{
		Repo:      files.NewRepo(pool, recorder),
		Presigner: fake,
		Cipher:    cipher,
		Audit:     recorder,
		Verifier:  ctxVerifier(),
		Logger:    testutil.Logger(),
	})
	return testutil.NewServer(t, mod), fake
}

// ---------------------------------------------------------------- presign

func TestPresignKindWhitelist(t *testing.T) {
	t.Parallel()
	srv, fake := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	// Happy path: an approved kind, type and size.
	resp := client.Post("/api/v1/files/presign", dto.PresignRequest{
		Kind: "dvir_photo", ContentType: "image/jpeg", SizeBytes: 1 << 20,
		Filename: "pre-trip-front.jpg",
	})
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env dto.PresignEnvelope
	resp.JSON(&env)
	require.NotEmpty(t, env.Data.UploadURL)
	require.Equal(t, http.MethodPut, env.Data.Method)
	require.False(t, env.Data.ExpiresAt.IsZero())
	require.WithinDuration(t, time.Now().UTC().Add(storage.DefaultExpiry), env.Data.ExpiresAt, time.Minute)
	require.Equal(t, int64(5<<20), env.Data.MaxBytes)
	// The key is server side: tenant scoped, kind scoped, random file name.
	require.True(t, strings.HasPrefix(env.Data.Key, tn.Company.ID.String()+"/dvir_photo/"),
		"unexpected key %q", env.Data.Key)
	require.True(t, strings.HasSuffix(env.Data.Key, ".jpg"))
	require.Len(t, fake.Requests(), 1)

	cases := []struct {
		name string
		in   dto.PresignRequest
		code int
		errc string
	}{
		{
			name: "kind outside the whitelist",
			in:   dto.PresignRequest{Kind: "backup", ContentType: "image/jpeg", SizeBytes: 10},
			code: http.StatusUnprocessableEntity, errc: apierr.CodeValidationError,
		},
		{
			name: "content type not allowed for the kind",
			in:   dto.PresignRequest{Kind: "dvir_photo", ContentType: "application/x-msdownload", SizeBytes: 10},
			code: http.StatusUnprocessableEntity, errc: apierr.CodeFileTypeInvalid,
		},
		{
			name: "dvir photo above 5 MiB",
			in:   dto.PresignRequest{Kind: "dvir_photo", ContentType: "image/jpeg", SizeBytes: (5 << 20) + 1},
			code: http.StatusRequestEntityTooLarge, errc: apierr.CodeFileTooLarge,
		},
		{
			name: "invoice above 10 MiB",
			in:   dto.PresignRequest{Kind: "invoice", ContentType: "application/pdf", SizeBytes: (10 << 20) + 1},
			code: http.StatusRequestEntityTooLarge, errc: apierr.CodeFileTooLarge,
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			testutil.RequireStatusCode(t, client.Post("/api/v1/files/presign", tc.in), tc.code, tc.errc)
		})
	}

	// A path traversal attempt in the file name cannot escape the prefix.
	trav := client.Post("/api/v1/files/presign", dto.PresignRequest{
		Kind: "invoice", ContentType: "application/pdf", SizeBytes: 1024,
		Filename: "../../../../etc/passwd",
	})
	testutil.RequireStatus(t, trav, http.StatusOK)
	trav.JSON(&env)
	require.True(t, strings.HasPrefix(env.Data.Key, tn.Company.ID.String()+"/invoice/"))
	require.NotContains(t, env.Data.Key, "..")
}

func TestPresignRequiresPermission(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t)

	client := srv.AsTenant(tn) // the role holds no permission at all
	testutil.RequireStatusCode(t, client.Post("/api/v1/files/presign", dto.PresignRequest{
		Kind: "logo", ContentType: "image/png", SizeBytes: 100,
	}), http.StatusForbidden, apierr.CodeForbidden)

	testutil.RequireStatusCode(t, srv.Anonymous().Post("/api/v1/files/presign", nil),
		http.StatusUnauthorized, apierr.CodeUnauthorized)
}

// ---------------------------------------------------------------- import

func TestImportDriversHappyPath(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	prefix := shortID()
	rows := [][]string{
		{"Ann", "Lee", prefix + ".ann", "+14155550101", prefix + ".ann@example.com", "TX-1111-2222", "TX", "Dallas"},
		{"Bob", "Ray", prefix + ".bob", "+14155550102", prefix + ".bob@example.com", "TX-3333-4444", "TX", "Dallas"},
	}
	body, ct := csvUpload(t, "drivers.csv", driverHeader, rows)

	resp := client.Do(http.MethodPost, "/api/v1/drivers/import", body, testutil.Header("Content-Type", ct))
	testutil.RequireStatus(t, resp, http.StatusOK)
	testutil.RequireNoPII(t, resp.Body)

	var env dto.ImportResultEnvelope
	resp.JSON(&env)
	require.Equal(t, 2, env.Data.Imported)
	require.Empty(t, env.Data.Errors)

	require.Equal(t, 2, countDriversNamed(t, tn.Company.ID, prefix))
	// The licence number never lands in the database in clear text.
	require.Equal(t, 0, countClearLicense(t, tn.Company.ID, "TX-1111-2222"))
	// Each imported driver got an invitation, and no password.
	require.Equal(t, 2, countInvitedDrivers(t, tn.Company.ID, prefix))
}

func TestImportDriversIsAllOrNothing(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	prefix := shortID()
	rows := [][]string{
		{"Ann", "Lee", prefix + ".ann", "+14155550101", prefix + ".ann@example.com", "TX-1111-2222", "TX", "Dallas"},
		// row 3: the username breaks Q18.3 and there is no licence number.
		{"Bad", "Row", "X!", "", "", "", "", ""},
		{"Cy", "Doe", prefix + ".cy", "+14155550103", prefix + ".cy@example.com", "TX-5555-6666", "TX", "Dallas"},
	}
	body, ct := csvUpload(t, "drivers.csv", driverHeader, rows)

	resp := client.Do(http.MethodPost, "/api/v1/drivers/import", body, testutil.Header("Content-Type", ct))
	testutil.RequireStatus(t, resp, http.StatusUnprocessableEntity)

	var env dto.ImportResultEnvelope
	resp.JSON(&env)
	require.Zero(t, env.Data.Imported)
	require.NotEmpty(t, env.Data.Errors)
	for _, e := range env.Data.Errors {
		require.Equal(t, 3, e.Row, "every error must point at the offending row")
	}
	fields := map[string]bool{}
	for _, e := range env.Data.Errors {
		fields[e.Field] = true
	}
	require.True(t, fields["username"])
	require.True(t, fields["license_no"])

	// TZ §18.4: not a single row was written.
	require.Equal(t, 0, countDriversNamed(t, tn.Company.ID, prefix))
}

func TestImportDriversRejectsDuplicatesAndExistingUsernames(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	prefix := shortID()
	dup := prefix + ".dup"
	rows := [][]string{
		{"Ann", "Lee", dup, "", prefix + ".a@example.com", "TX-1", "TX", "Dallas"},
		{"Bob", "Ray", dup, "", prefix + ".b@example.com", "TX-2", "TX", "Dallas"},
	}
	body, ct := csvUpload(t, "drivers.csv", driverHeader, rows)
	resp := client.Do(http.MethodPost, "/api/v1/drivers/import", body, testutil.Header("Content-Type", ct))
	testutil.RequireStatus(t, resp, http.StatusUnprocessableEntity)

	var env dto.ImportResultEnvelope
	resp.JSON(&env)
	require.NotEmpty(t, env.Data.Errors)
	require.Equal(t, 0, countDriversNamed(t, tn.Company.ID, prefix))

	// A username that already exists in the tenant is rejected too.
	existing := [][]string{{"Ann", "Lee", tn.User.Username, "", prefix + ".c@example.com", "TX-3", "TX", "Dallas"}}
	body, ct = csvUpload(t, "drivers.csv", driverHeader, existing)
	resp = client.Do(http.MethodPost, "/api/v1/drivers/import", body, testutil.Header("Content-Type", ct))
	testutil.RequireStatus(t, resp, http.StatusUnprocessableEntity)
	resp.JSON(&env)
	require.NotEmpty(t, env.Data.Errors)
	require.Equal(t, "username", env.Data.Errors[0].Field)
}

func TestImportDriversRejectsBadHeader(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	body, ct := csvUpload(t, "drivers.csv", []string{"name", "mail"}, [][]string{{"Ann", "a@b.co"}})
	resp := client.Do(http.MethodPost, "/api/v1/drivers/import", body, testutil.Header("Content-Type", ct))
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestImportUnits(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	prefix := shortID()
	rows := [][]string{
		{prefix + "-1", "Freightliner", "Cascadia", "2021", "TX-4821", "TX", "1FUJGLDR9CLBP8834", "diesel", "true"},
		{prefix + "-2", "Volvo", "VNL", "2019", "TX-4822", "TX", "", "diesel", "false"},
	}
	body, ct := csvUpload(t, "units.csv", unitHeader, rows)
	resp := client.Do(http.MethodPost, "/api/v1/units/import", body, testutil.Header("Content-Type", ct))
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env dto.ImportResultEnvelope
	resp.JSON(&env)
	require.Equal(t, 2, env.Data.Imported)
	require.Equal(t, 2, countUnitsNamed(t, tn.Company.ID, prefix))

	// A bad fuel type and a malformed VIN reject the whole file.
	bad := [][]string{
		{prefix + "-3", "Volvo", "VNL", "2019", "TX-4823", "TX", "TOO-SHORT", "plutonium", "false"},
	}
	body, ct = csvUpload(t, "units.csv", unitHeader, bad)
	resp = client.Do(http.MethodPost, "/api/v1/units/import", body, testutil.Header("Content-Type", ct))
	testutil.RequireStatus(t, resp, http.StatusUnprocessableEntity)
	resp.JSON(&env)
	require.Zero(t, env.Data.Imported)
	require.Equal(t, 2, countUnitsNamed(t, tn.Company.ID, prefix), "nothing new was written")
}

// TestImportDriversNFR measures the TZ non functional requirement: 1000 rows
// must import in well under 30 seconds.
func TestImportDriversNFR(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	const rowCount = 1000
	prefix := shortID()
	rows := make([][]string, 0, rowCount)
	for i := 0; i < rowCount; i++ {
		u := fmt.Sprintf("%s.%04d", prefix, i)
		rows = append(rows, []string{
			"Nfr", fmt.Sprintf("Driver%04d", i), u,
			fmt.Sprintf("+1415555%04d", i), u + "@example.com",
			fmt.Sprintf("TX-9999-%04d", i), "TX", "Dallas Yard",
		})
	}
	body, ct := csvUpload(t, "drivers.csv", driverHeader, rows)

	start := time.Now()
	resp := client.Do(http.MethodPost, "/api/v1/drivers/import", body, testutil.Header("Content-Type", ct))
	elapsed := time.Since(start)

	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.ImportResultEnvelope
	resp.JSON(&env)
	require.Equal(t, rowCount, env.Data.Imported)

	t.Logf("NFR: imported %d driver rows in %s", rowCount, elapsed.Round(time.Millisecond))
	require.Less(t, elapsed, 30*time.Second, "TZ NFR: 1000 CSV rows must import in under 30 s")
}

// ---------------------------------------------------------------- export

func TestExportDriversMasksLicenseAndIsAudited(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	const plain = "TX-7777-8888"
	setLicense(t, tn.Company.ID, tn.Driver.ID, plain)

	resp := client.Get("/api/v1/drivers/export")
	testutil.RequireStatus(t, resp, http.StatusOK)
	require.Contains(t, resp.Header.Get("Content-Type"), "text/csv")
	require.Contains(t, resp.Header.Get("Content-Disposition"), "attachment;")

	text := string(resp.Body)
	require.Contains(t, text, "license_no_masked")
	require.NotContains(t, text, plain, "an export never carries the clear licence number")
	require.Contains(t, text, "***8888")

	// The download is recorded: who exported what.
	require.GreaterOrEqual(t, countExportAudit(t, tn.Company.ID, "drivers"), 1)

	// XLSX is a real workbook (ZIP magic bytes).
	xlsx := client.Get("/api/v1/drivers/export", testutil.Query("format", "xlsx"))
	testutil.RequireStatus(t, xlsx, http.StatusOK)
	require.True(t, bytes.HasPrefix(xlsx.Body, []byte("PK")), "xlsx must be a zip container")

	// An unknown format is rejected.
	testutil.RequireStatusCode(t, client.Get("/api/v1/drivers/export", testutil.Query("format", "pdf")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestExportUnitsAndTemplates(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	resp := client.Get("/api/v1/units/export")
	testutil.RequireStatus(t, resp, http.StatusOK)
	require.Contains(t, string(resp.Body), tn.Unit.UnitNumber)
	require.GreaterOrEqual(t, countExportAudit(t, tn.Company.ID, "units"), 1)

	// The templates carry exactly the TZ §18.4 columns, in order.
	drivers := client.Get("/api/v1/drivers/import-template")
	testutil.RequireStatus(t, drivers, http.StatusOK)
	require.Equal(t, driverHeader, firstCSVRow(t, drivers.Body))
	require.Contains(t, drivers.Header.Get("Content-Disposition"), "drivers_import_template.csv")

	units := client.Get("/api/v1/units/import-template")
	testutil.RequireStatus(t, units, http.StatusOK)
	require.Equal(t, unitHeader, firstCSVRow(t, units.Body))

	// A downloaded template re-uploads cleanly (round trip).
	xlsx := client.Get("/api/v1/drivers/import-template", testutil.Query("format", "xlsx"))
	testutil.RequireStatus(t, xlsx, http.StatusOK)
	require.True(t, bytes.HasPrefix(xlsx.Body, []byte("PK")))
}

func TestExportRequiresPermissionAndIsTenantScoped(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, filePermissions...)

	// Company A never sees company B's units in its own export.
	resp := srv.AsTenant(a).Get("/api/v1/units/export")
	testutil.RequireStatus(t, resp, http.StatusOK)
	require.NotContains(t, string(resp.Body), b.Unit.UnitNumber)

	// A caller without units.export is refused.
	p := a.Principal()
	p.Permissions = []string{core.PermDriversRead}
	testutil.RequireStatusCode(t, srv.AsPrincipal(p).Get("/api/v1/units/export"),
		http.StatusForbidden, apierr.CodeForbidden)
}

// ---------------------------------------------------------------- helpers

var driverHeader = []string{
	"first_name", "last_name", "username", "phone", "email",
	"license_no", "license_region", "home_terminal",
}

var unitHeader = []string{
	"unit_number", "make", "model", "year", "plate",
	"plate_region", "vin", "fuel_type", "sleeper_berth",
}

func shortID() string {
	return "i" + strings.ReplaceAll(uuid.NewString()[:8], "-", "")
}

// csvUpload builds a multipart body carrying one CSV file.
func csvUpload(t *testing.T, filename string, header []string, rows [][]string) ([]byte, string) {
	t.Helper()

	var sheet bytes.Buffer
	w := csv.NewWriter(&sheet)
	require.NoError(t, w.Write(header))
	for _, row := range rows {
		require.NoError(t, w.Write(row))
	}
	w.Flush()
	require.NoError(t, w.Error())

	var body bytes.Buffer
	mw := multipart.NewWriter(&body)
	part, err := mw.CreateFormFile("file", filename)
	require.NoError(t, err)
	_, err = part.Write(sheet.Bytes())
	require.NoError(t, err)
	require.NoError(t, mw.Close())

	return body.Bytes(), mw.FormDataContentType()
}

func firstCSVRow(t *testing.T, body []byte) []string {
	t.Helper()
	rows, err := csv.NewReader(bytes.NewReader(body)).ReadAll()
	require.NoError(t, err)
	require.NotEmpty(t, rows)
	return rows[0]
}

func countDriversNamed(t *testing.T, companyID uuid.UUID, prefix string) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t), `
		SELECT count(*) FROM drivers d JOIN users u ON u.id = d.user_id
		WHERE d.company_id = $1 AND u.username LIKE $2 AND d.deleted_at IS NULL`,
		companyID, prefix+"%").Scan(&n))
	return n
}

func countInvitedDrivers(t *testing.T, companyID uuid.UUID, prefix string) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t), `
		SELECT count(*) FROM users u
		JOIN invitations i ON i.user_id = u.id AND i.used_at IS NULL
		WHERE u.company_id = $1 AND u.username LIKE $2
		  AND u.status = 'invited' AND u.password_hash IS NULL`,
		companyID, prefix+"%").Scan(&n))
	return n
}

func countClearLicense(t *testing.T, companyID uuid.UUID, plain string) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM drivers WHERE company_id = $1 AND license_no_enc LIKE '%' || $2 || '%'`,
		companyID, plain).Scan(&n))
	return n
}

func countUnitsNamed(t *testing.T, companyID uuid.UUID, prefix string) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM units WHERE company_id = $1 AND unit_number LIKE $2 AND deleted_at IS NULL`,
		companyID, prefix+"%").Scan(&n))
	return n
}

func countExportAudit(t *testing.T, companyID uuid.UUID, table string) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM audit_log WHERE company_id = $1 AND table_name = $2 AND action = 'export'`,
		companyID, table).Scan(&n))
	return n
}

// setLicense stores an encrypted licence number straight on the fixture driver.
func setLicense(t *testing.T, companyID, driverID uuid.UUID, plain string) {
	t.Helper()
	cipher, err := appcrypto.NewCipherFromString(testutil.TestConfig().EncryptionKey)
	require.NoError(t, err)
	enc, err := cipher.EncryptString(plain)
	require.NoError(t, err)

	_, err = testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE drivers SET license_no_enc = $3 WHERE company_id = $1 AND id = $2`,
		companyID, driverID, enc)
	require.NoError(t, err)
}
