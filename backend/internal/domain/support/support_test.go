//go:build integration

// Integration coverage of the support module against a real Postgres: the
// ticket lifecycle, the thread, the driver `self` scope, feedback validation
// and cross-tenant isolation (404, not 403).
package support_test

import (
	"net/http"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/support"
	"github.com/devline/onebook-eld/internal/domain/support/dto"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// allSupportPerms is every permission the module gates on.
var allSupportPerms = []string{
	core.PermSupportRead, core.PermSupportCreate, core.PermSupportUpdateStatus,
	core.PermFeedbackRead, core.PermFeedbackCreate,
}

func newServer(t testing.TB) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	repo := support.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger()))
	return testutil.NewServer(t, support.New(support.Deps{Repo: repo, Verifier: testutil.ContextVerifier()}))
}

func decodeTicket(t testing.TB, resp *testutil.Response) dto.Ticket {
	t.Helper()
	var env dto.TicketEnvelope
	resp.JSON(&env)
	return env.Data
}

func TestTicketLifecycleHappyPath(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allSupportPerms...)
	c := srv.AsTenant(tn)

	created := c.Post("/api/v1/support-tickets", dto.TicketCreate{
		Subject:     "ELD device keeps disconnecting",
		Description: "Bluetooth drops every few minutes.",
		ContactOn:   "email",
		// Attachment keys must be this tenant's own objects (storage.OwnsKey).
		Attachments: []string{
			tn.Company.ID.String() + "/chat/2026/09/a.jpg",
			tn.Company.ID.String() + "/chat/2026/09/b.jpg",
		},
	})
	testutil.RequireStatus(t, created, http.StatusCreated)
	ticket := decodeTicket(t, created)
	// Q77: a ticket opens as `new`, never `open`.
	require.Equal(t, dto.StatusNew, ticket.Status)
	require.Len(t, ticket.Attachments, 2)
	require.Nil(t, ticket.ResolvedAt)

	got := c.Get("/api/v1/support-tickets/" + ticket.ID)
	testutil.RequireStatus(t, got, http.StatusOK)
	require.Equal(t, ticket.ID, decodeTicket(t, got).ID)

	// new → in_progress → resolved.
	inProgress := c.Patch("/api/v1/support-tickets/"+ticket.ID+"/status",
		dto.TicketStatusUpdate{Status: dto.StatusInProgress})
	testutil.RequireStatus(t, inProgress, http.StatusOK)
	require.Equal(t, dto.StatusInProgress, decodeTicket(t, inProgress).Status)

	resolved := c.Patch("/api/v1/support-tickets/"+ticket.ID+"/status",
		dto.TicketStatusUpdate{Status: dto.StatusResolved})
	testutil.RequireStatus(t, resolved, http.StatusOK)
	done := decodeTicket(t, resolved)
	require.Equal(t, dto.StatusResolved, done.Status)
	require.NotNil(t, done.ResolvedAt, "resolved_at must be stamped")

	// Backward and repeated transitions are refused.
	back := c.Patch("/api/v1/support-tickets/"+ticket.ID+"/status",
		dto.TicketStatusUpdate{Status: dto.StatusInProgress})
	testutil.RequireStatusCode(t, back, http.StatusConflict, apierr.CodeInvalidState)
	again := c.Patch("/api/v1/support-tickets/"+ticket.ID+"/status",
		dto.TicketStatusUpdate{Status: dto.StatusResolved})
	testutil.RequireStatusCode(t, again, http.StatusConflict, apierr.CodeInvalidState)

	// Every status change is audited.
	require.GreaterOrEqual(t, auditCount(t, tn, ticket.ID), 3,
		"create plus two transitions must leave an audit trail")
}

func auditCount(t testing.TB, tn *testutil.Tenant, recordID string) int {
	t.Helper()
	var n int
	err := testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM audit_log WHERE company_id = $1 AND table_name = 'support_tickets' AND record_id = $2`,
		tn.Company.ID, recordID).Scan(&n)
	require.NoError(t, err)
	return n
}

func TestTicketThread(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allSupportPerms...)
	c := srv.AsTenant(tn)

	ticket := decodeTicket(t, c.Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Thread"}))

	reply := c.Post("/api/v1/support-tickets/"+ticket.ID+"/messages",
		dto.TicketMessageCreate{Text: "A replacement cable ships today."})
	testutil.RequireStatus(t, reply, http.StatusCreated)
	var msgEnv dto.TicketMessageEnvelope
	reply.JSON(&msgEnv)
	require.Equal(t, ticket.ID, msgEnv.Data.TicketID)
	require.NotEmpty(t, msgEnv.Data.SenderName)

	list := c.Get("/api/v1/support-tickets/" + ticket.ID + "/messages")
	testutil.RequireStatus(t, list, http.StatusOK)
	var listEnv dto.TicketMessageListEnvelope
	list.JSON(&listEnv)
	require.Len(t, listEnv.Data, 1)
	require.EqualValues(t, 1, listEnv.Meta.Total)

	// The counter on the ticket follows the thread.
	require.EqualValues(t, 1, decodeTicket(t, c.Get("/api/v1/support-tickets/"+ticket.ID)).MessageCount)

	// An empty message carries no information.
	testutil.RequireStatusCode(t,
		c.Post("/api/v1/support-tickets/"+ticket.ID+"/messages", dto.TicketMessageCreate{Text: "   "}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

func TestDriverSelfScope(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allSupportPerms...)

	// A second driver of the same company.
	otherUser := testutil.NewUser(t, tn.Company.ID, testutil.WithRole(tn.Role))
	otherDriver := testutil.NewDriver(t, tn.Company.ID, testutil.WithUser(otherUser))

	driverPrincipal := tn.DriverPrincipal(core.PermSupportRead, core.PermSupportCreate, core.PermFeedbackCreate)
	driver := srv.AsPrincipal(driverPrincipal)

	otherPrincipal := tn.DriverPrincipal(core.PermSupportRead, core.PermSupportCreate)
	otherPrincipal.UserID = otherDriver.UserID
	other := srv.AsPrincipal(otherPrincipal)

	admin := srv.AsTenant(tn)

	mine := decodeTicket(t, driver.Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Mine"}))
	// driver_id is resolved from the token, never from the body.
	require.NotNil(t, mine.DriverID)
	require.Equal(t, tn.Driver.ID.String(), *mine.DriverID)

	theirs := decodeTicket(t, other.Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Theirs"}))
	adminTicket := decodeTicket(t, admin.Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Office"}))

	// The driver only ever sees its own ticket.
	ids := ticketIDs(t, driver)
	require.Contains(t, ids, mine.ID)
	require.NotContains(t, ids, theirs.ID)
	require.NotContains(t, ids, adminTicket.ID)

	// Widening the filter changes nothing.
	widened := ticketIDs(t, driver, testutil.Query("driver_id", otherDriver.ID.String()))
	require.Equal(t, []string{mine.ID}, widened)

	// Another driver's ticket is 404, never 403: ids cannot be probed.
	testutil.RequireStatusCode(t, driver.Get("/api/v1/support-tickets/"+theirs.ID),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t,
		driver.Post("/api/v1/support-tickets/"+theirs.ID+"/messages", dto.TicketMessageCreate{Text: "hi"}),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, driver.Get("/api/v1/support-tickets/"+theirs.ID+"/messages"),
		http.StatusNotFound, apierr.CodeNotFound)

	// The office sees every ticket of the company.
	adminIDs := ticketIDs(t, admin)
	require.Subset(t, adminIDs, []string{mine.ID, theirs.ID, adminTicket.ID})

	// A driver cannot move the ticket along the lifecycle.
	testutil.RequireStatusCode(t,
		driver.Patch("/api/v1/support-tickets/"+mine.ID+"/status", dto.TicketStatusUpdate{Status: dto.StatusResolved}),
		http.StatusForbidden, apierr.CodeForbidden)
}

func ticketIDs(t testing.TB, c *testutil.TestServer, opts ...testutil.RequestOption) []string {
	t.Helper()
	resp := c.Get("/api/v1/support-tickets", append(opts, testutil.Query("per_page", "50"))...)
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.TicketListEnvelope
	resp.JSON(&env)
	out := make([]string, 0, len(env.Data))
	for _, tk := range env.Data {
		out = append(out, tk.ID)
	}
	return out
}

func TestTicketValidationAndFilters(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	c := srv.AsTenant(testutil.SeedTenant(t, allSupportPerms...))

	// Q77: subject is mandatory.
	testutil.RequireStatusCode(t, c.Post("/api/v1/support-tickets", map[string]any{"description": "no subject"}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// Q77: at most three attachments.
	testutil.RequireStatusCode(t, c.Post("/api/v1/support-tickets", dto.TicketCreate{
		Subject:     "Too many files",
		Attachments: []string{"a", "b", "c", "d"},
	}), http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// Unknown status filter and unknown sort field are rejected, not ignored.
	testutil.RequireStatusCode(t, c.Get("/api/v1/support-tickets", testutil.Query("status", "open")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
	testutil.RequireStatusCode(t, c.Get("/api/v1/support-tickets", testutil.Query("sort", "description")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	open := decodeTicket(t, c.Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Filterable one"}))
	moved := decodeTicket(t, c.Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Filterable two"}))
	testutil.RequireStatus(t, c.Patch("/api/v1/support-tickets/"+moved.ID+"/status",
		dto.TicketStatusUpdate{Status: dto.StatusInProgress}), http.StatusOK)

	newOnes := ticketIDs(t, c, testutil.Query("status", dto.StatusNew))
	require.Contains(t, newOnes, open.ID)
	require.NotContains(t, newOnes, moved.ID)

	found := ticketIDs(t, c, testutil.Query("search", "Filterable two"))
	require.Equal(t, []string{moved.ID}, found)
}

func TestTicketCrossTenantIsolation(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, allSupportPerms...)

	ticket := decodeTicket(t, srv.AsTenant(a).Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Tenant A"}))

	// Cross-tenant reads and writes are 404, never 403.
	testutil.RequireStatusCode(t, srv.AsTenant(b).Get("/api/v1/support-tickets/"+ticket.ID),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, srv.AsTenant(b).Patch("/api/v1/support-tickets/"+ticket.ID+"/status",
		dto.TicketStatusUpdate{Status: dto.StatusInProgress}), http.StatusNotFound, apierr.CodeNotFound)
	require.NotContains(t, ticketIDs(t, srv.AsTenant(b)), ticket.ID)
}

func TestTicketPermissionsAreEnforced(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	// A tenant whose role holds nothing at all.
	c := srv.AsTenant(testutil.SeedTenant(t))

	testutil.RequireStatus(t, c.Get("/api/v1/support-tickets"), http.StatusForbidden)
	testutil.RequireStatus(t, c.Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "x"}), http.StatusForbidden)
	testutil.RequireStatus(t, c.Get("/api/v1/feedback"), http.StatusForbidden)
	testutil.RequireStatus(t, c.Post("/api/v1/feedback", dto.FeedbackCreate{Text: "x"}), http.StatusForbidden)
	testutil.RequireStatus(t, srv.Anonymous().Get("/api/v1/support-tickets"), http.StatusUnauthorized)
}

func TestFeedbackFlow(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allSupportPerms...)
	rating := int16(4)

	driver := srv.AsPrincipal(tn.DriverPrincipal(core.PermFeedbackCreate))
	created := driver.Post("/api/v1/feedback", dto.FeedbackCreate{
		AppRating: &rating, Text: "The log screen is much faster now.",
	})
	testutil.RequireStatus(t, created, http.StatusCreated)
	var env dto.FeedbackEnvelope
	created.JSON(&env)
	require.NotNil(t, env.Data.AppRating)
	require.EqualValues(t, 4, *env.Data.AppRating)
	// driver_id is resolved from the token.
	require.NotNil(t, env.Data.DriverID)
	require.Equal(t, tn.Driver.ID.String(), *env.Data.DriverID)

	// Q80: feedback is never answered — there is no detail route.
	testutil.RequireStatus(t, srv.AsTenant(tn).Get("/api/v1/feedback/"+env.Data.ID), http.StatusNotFound)

	// An empty submission carries no information.
	testutil.RequireStatusCode(t, driver.Post("/api/v1/feedback", dto.FeedbackCreate{}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
	// A rating outside 1..5 is refused.
	bad := int16(9)
	testutil.RequireStatusCode(t, driver.Post("/api/v1/feedback", dto.FeedbackCreate{AppRating: &bad}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// The office reads the stream and can filter it.
	admin := srv.AsTenant(tn)
	list := admin.Get("/api/v1/feedback", testutil.Query("min_rating", "4"))
	testutil.RequireStatus(t, list, http.StatusOK)
	var listEnv dto.FeedbackListEnvelope
	list.JSON(&listEnv)
	require.NotEmpty(t, listEnv.Data)

	require.Empty(t, feedbackIDs(t, admin, testutil.Query("min_rating", "5")))
	testutil.RequireStatusCode(t, admin.Get("/api/v1/feedback", testutil.Query("min_rating", "0")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// Cross-tenant feedback stays invisible.
	otherIDs := feedbackIDs(t, srv.AsTenant(testutil.SeedTenant(t, allSupportPerms...)))
	require.NotContains(t, otherIDs, env.Data.ID)
}

func feedbackIDs(t testing.TB, c *testutil.TestServer, opts ...testutil.RequestOption) []string {
	t.Helper()
	resp := c.Get("/api/v1/feedback", append(opts, testutil.Query("per_page", "50"))...)
	testutil.RequireStatus(t, resp, http.StatusOK)
	var env dto.FeedbackListEnvelope
	resp.JSON(&env)
	out := make([]string, 0, len(env.Data))
	for _, f := range env.Data {
		out = append(out, f.ID)
	}
	return out
}

func TestOfficeTicketHasNoDriver(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allSupportPerms...)
	p := tn.Principal()
	require.Equal(t, tenant.ScopeAll, p.Scope)

	ticket := decodeTicket(t, srv.AsPrincipal(p).Post("/api/v1/support-tickets",
		dto.TicketCreate{Subject: "Filed from the office"}))
	require.Nil(t, ticket.DriverID, "an office user has no driver row")
	require.NotNil(t, ticket.CreatedBy)
	require.Equal(t, p.UserID.String(), *ticket.CreatedBy)
}
