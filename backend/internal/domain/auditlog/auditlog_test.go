//go:build integration

// Integration coverage of the audit journal against a real Postgres: the
// filters, the pagination, cross-tenant isolation and — the point of the
// module — that no secret ever leaves in `old_value` / `new_value`.
package auditlog_test

import (
	"encoding/json"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/auditlog"
	"github.com/devline/onebook-eld/internal/domain/auditlog/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	"github.com/devline/onebook-eld/internal/testutil"
)

func newServer(t testing.TB) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	return testutil.NewServer(t, auditlog.New(auditlog.Deps{
		Repo: auditlog.NewRepo(pool), Verifier: testutil.ContextVerifier(),
	}))
}

// entry is one audit_log row inserted straight through the admin pool: the
// module itself is read only on purpose.
type entry struct {
	Table    string
	RecordID uuid.UUID
	Field    string
	Old      string
	New      string
	Action   string
	EditedBy uuid.UUID
	TS       time.Time
}

func insertEntry(t testing.TB, companyID uuid.UUID, e entry) uuid.UUID {
	t.Helper()
	if e.Action == "" {
		e.Action = "update"
	}
	if e.TS.IsZero() {
		e.TS = time.Now().UTC()
	}
	id := uuid.New()
	var oldV, newV any
	if e.Old != "" {
		oldV = []byte(e.Old)
	}
	if e.New != "" {
		newV = []byte(e.New)
	}
	var editedBy any
	if e.EditedBy != uuid.Nil {
		editedBy = e.EditedBy
	}
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO audit_log (id, company_id, table_name, record_id, field, old_value, new_value, action, edited_by, ts)
		 VALUES ($1,$2,$3,$4,$5,$6::jsonb,$7::jsonb,$8,$9,$10)`,
		id, companyID, e.Table, e.RecordID, e.Field, oldV, newV, e.Action, editedBy, e.TS)
	require.NoError(t, err)
	return id
}

func list(t testing.TB, c *testutil.TestServer, opts ...testutil.RequestOption) dto.EntryListEnvelope {
	t.Helper()
	resp := c.Get("/api/v1/audit-log", append(opts, testutil.Query("per_page", "50"))...)
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.EntryListEnvelope
	resp.JSON(&env)
	return env
}

func find(t testing.TB, env dto.EntryListEnvelope, id uuid.UUID) dto.Entry {
	t.Helper()
	for _, e := range env.Data {
		if e.ID == id.String() {
			return e
		}
	}
	t.Fatalf("audit entry %s is missing from the page", id)
	return dto.Entry{}
}

func TestAuditLogMasksSecrets(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermAuditView)
	c := srv.AsTenant(tn)

	// 1. A sensitive field name redacts the value whatever its shape.
	hash := insertEntry(t, tn.Company.ID, entry{
		Table: "users", RecordID: tn.User.ID, Field: "password_hash",
		Old: `"$argon2id$v=19$m=65536,t=3,p=2$oldsaltoldsalt$oldhash"`,
		New: `"$argon2id$v=19$m=65536,t=3,p=2$newsaltnewsalt$newhash"`,
	})
	// 2. Encrypted columns follow the same rule.
	license := insertEntry(t, tn.Company.ID, entry{
		Table: "drivers", RecordID: tn.Driver.ID, Field: "license_no_enc",
		New: `"TX-DL-99887766"`,
	})
	refresh := insertEntry(t, tn.Company.ID, entry{
		Table: "sessions", RecordID: uuid.New(), Field: "refresh_token_hash",
		New: `"9f8e7d6c5b4a39281706f5e4d3c2b1a0"`,
	})
	// 3. Object keys are checked one by one, and free text is scrubbed.
	nested := insertEntry(t, tn.Company.ID, entry{
		Table: "companies", RecordID: tn.Company.ID, Field: "settings",
		New: `{"email":"dispatch@example.com","api_key":"sk-live-abcdef","timezone":"UTC",` +
			`"note":"token eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2lnbmF0dXJl kelsin"}`,
	})
	// 4. An ordinary change stays readable — masking must not blind the audit.
	plain := insertEntry(t, tn.Company.ID, entry{
		Table: "support_tickets", RecordID: uuid.New(), Field: "status",
		Old: `"new"`, New: `"in_progress"`,
	})

	env := list(t, c, testutil.Query("per_page", "50"))

	hashed := find(t, env, hash)
	require.True(t, hashed.Masked)
	require.Equal(t, httpx.Redacted, hashed.OldValue)
	require.Equal(t, httpx.Redacted, hashed.NewValue)

	lic := find(t, env, license)
	require.True(t, lic.Masked)
	require.Equal(t, httpx.Redacted, lic.NewValue)
	require.Nil(t, lic.OldValue, "an insert has no old value")

	require.Equal(t, httpx.Redacted, find(t, env, refresh).NewValue)

	obj := find(t, env, nested)
	require.True(t, obj.Masked)
	settings, ok := obj.NewValue.(map[string]any)
	require.True(t, ok, "an object value must stay an object")
	require.Equal(t, httpx.Redacted, settings["email"])
	require.Equal(t, httpx.Redacted, settings["api_key"])
	require.Equal(t, "UTC", settings["timezone"], "a harmless key must survive")
	require.NotContains(t, settings["note"], "eyJhbGciOiJIUzI1NiJ9", "a JWT must never be echoed")

	readable := find(t, env, plain)
	require.False(t, readable.Masked)
	require.Equal(t, "new", readable.OldValue)
	require.Equal(t, "in_progress", readable.NewValue)

	// Nothing that looks like a secret survives anywhere in the payload.
	raw, err := json.Marshal(env)
	require.NoError(t, err)
	body := string(raw)
	for _, secret := range []string{
		"argon2id", "TX-DL-99887766", "sk-live-abcdef",
		"dispatch@example.com", "9f8e7d6c5b4a39281706f5e4d3c2b1a0",
	} {
		require.False(t, strings.Contains(body, secret), "leaked %q", secret)
	}
}

func TestAuditLogFilters(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermAuditView)
	c := srv.AsTenant(tn)

	record := uuid.New()
	other := uuid.New()
	base := time.Now().UTC().Add(-48 * time.Hour)

	target := insertEntry(t, tn.Company.ID, entry{
		Table: "support_tickets", RecordID: record, Field: "status",
		Old: `"new"`, New: `"in_progress"`, EditedBy: tn.User.ID, TS: base,
	})
	sameTableOtherRecord := insertEntry(t, tn.Company.ID, entry{
		Table: "support_tickets", RecordID: other, Field: "status",
		New: `"new"`, Action: "create", EditedBy: tn.Driver.UserID, TS: base.Add(time.Hour),
	})
	otherTable := insertEntry(t, tn.Company.ID, entry{
		Table: "units", RecordID: uuid.New(), Field: "status",
		New: `"inactive"`, EditedBy: tn.User.ID, TS: base.Add(2 * time.Hour),
	})

	ids := func(env dto.EntryListEnvelope) []string {
		out := make([]string, 0, len(env.Data))
		for _, e := range env.Data {
			out = append(out, e.ID)
		}
		return out
	}

	byTable := ids(list(t, c, testutil.Query("table", "support_tickets")))
	require.Subset(t, byTable, []string{target.String(), sameTableOtherRecord.String()})
	require.NotContains(t, byTable, otherTable.String())

	byRecord := ids(list(t, c, testutil.Query("record_id", record.String())))
	require.Equal(t, []string{target.String()}, byRecord)

	byUser := ids(list(t, c, testutil.Query("user", tn.Driver.UserID.String())))
	require.Contains(t, byUser, sameTableOtherRecord.String())
	require.NotContains(t, byUser, target.String())

	byAction := ids(list(t, c, testutil.Query("action", "create")))
	require.Contains(t, byAction, sameTableOtherRecord.String())
	require.NotContains(t, byAction, target.String())

	// [from, to) — the window is half open.
	window := ids(list(t,
		c,
		testutil.Query("from", base.Add(30*time.Minute).Format(time.RFC3339)),
		testutil.Query("to", base.Add(90*time.Minute).Format(time.RFC3339)),
	))
	require.Equal(t, []string{sameTableOtherRecord.String()}, window)

	// Newest first by default, oldest first on request.
	all := list(t, c, testutil.Query("table", "support_tickets"))
	require.Equal(t, sameTableOtherRecord.String(), all.Data[0].ID)
	asc := list(t, c, testutil.Query("table", "support_tickets"), testutil.Query("order", "asc"))
	require.Equal(t, target.String(), asc.Data[0].ID)

	// The acting user is resolved for the journal screen.
	require.NotEmpty(t, find(t, all, target).EditedByName)
	require.NotEmpty(t, find(t, all, target).Username)

	// The dropdown lists the audited tables of this tenant only.
	tables := c.Get("/api/v1/audit-log/tables")
	testutil.RequireStatus(t, tables, http.StatusOK)
	var tableEnv dto.TableListEnvelope
	tables.JSON(&tableEnv)
	require.Subset(t, tableEnv.Data, []string{"support_tickets", "units"})

	// A malformed filter fails loudly instead of returning an empty page.
	testutil.RequireStatusCode(t, c.Get("/api/v1/audit-log", testutil.Query("table", "DROP TABLE")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
	testutil.RequireStatusCode(t, c.Get("/api/v1/audit-log", testutil.Query("record_id", "not-a-uuid")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
	testutil.RequireStatusCode(t, c.Get("/api/v1/audit-log", testutil.Query("from", "yesterday")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestAuditLogPagination(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, core.PermAuditView)
	c := srv.AsTenant(tn)

	record := uuid.New()
	base := time.Now().UTC().Add(-72 * time.Hour)
	const total = 15
	for i := range total {
		insertEntry(t, tn.Company.ID, entry{
			Table: "trailers", RecordID: record, Field: "number",
			New: `"T-100"`, TS: base.Add(time.Duration(i) * time.Minute),
		})
	}

	resp := c.Get("/api/v1/audit-log",
		testutil.Query("record_id", record.String()),
		testutil.Query("per_page", "10"), testutil.Query("page", "2"))
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.EntryListEnvelope
	resp.JSON(&env)
	require.Len(t, env.Data, total-10)
	require.EqualValues(t, total, env.Meta.Total)
	require.Equal(t, 2, env.Meta.Page)
	require.Equal(t, 10, env.Meta.PerPage)
}

func TestAuditLogIsReadOnlyAndTenantScoped(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, core.PermAuditView)

	mine := insertEntry(t, a.Company.ID, entry{
		Table: "units", RecordID: a.Unit.ID, Field: "status", New: `"inactive"`,
	})

	seen := list(t, srv.AsTenant(b))
	for _, e := range seen.Data {
		require.NotEqual(t, mine.String(), e.ID, "another tenant's audit trail must stay invisible")
	}

	// The module exposes no write route at all.
	c := srv.AsTenant(a)
	testutil.RequireStatus(t, c.Post("/api/v1/audit-log", map[string]any{"table": "units"}), http.StatusMethodNotAllowed)
	testutil.RequireStatus(t, c.Delete("/api/v1/audit-log/"+mine.String()), http.StatusNotFound)

	// audit.view is required; an anonymous caller is 401.
	testutil.RequireStatus(t, srv.AsTenant(testutil.SeedTenant(t)).Get("/api/v1/audit-log"), http.StatusForbidden)
	testutil.RequireStatus(t, srv.Anonymous().Get("/api/v1/audit-log"), http.StatusUnauthorized)
}
