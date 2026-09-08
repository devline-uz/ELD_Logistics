//go:build integration

// Support desk hardening. Two things are checked here that the lifecycle test
// does not cover: an attachment key must be an object of the caller's own
// tenant (TZ B§3.4), and the status transition must obey the same `self` scope
// as every read — a role that was misconfigured with `support.update_status`
// and a `self` scope must still not touch another driver's ticket.
package support_test

import (
	"net/http"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/support/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

func TestAttachmentKeyMustBelongToTheTenant(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allSupportPerms...)
	other := testutil.SeedTenant(t, allSupportPerms...)
	c := srv.AsTenant(tn)

	foreign := other.Company.ID.String() + "/chat/2026/09/secret.pdf"
	testutil.RequireStatusCode(t, c.Post("/api/v1/support-tickets", dto.TicketCreate{
		Subject:     "Nice file you have there",
		Attachments: []string{foreign},
	}), http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// A key with no tenant prefix at all is refused just as hard.
	testutil.RequireStatusCode(t, c.Post("/api/v1/support-tickets", dto.TicketCreate{
		Subject:     "Bare key",
		Attachments: []string{"tickets/2026/09/a.jpg"},
	}), http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// The same rule applies on the message thread, not only on the ticket.
	ticket := decodeTicket(t, c.Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Clean"}))
	testutil.RequireStatusCode(t, c.Post("/api/v1/support-tickets/"+ticket.ID+"/messages",
		dto.TicketMessageCreate{Text: "see attached", Attachments: []string{foreign}}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// An own key still goes through.
	own := tn.Company.ID.String() + "/chat/2026/09/mine.jpg"
	msg := c.Post("/api/v1/support-tickets/"+ticket.ID+"/messages",
		dto.TicketMessageCreate{Text: "see attached", Attachments: []string{own}})
	testutil.RequireStatus(t, msg, http.StatusCreated)
}

func TestSelfScopedStatusChangeStaysOnOwnTicket(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allSupportPerms...)

	otherUser := testutil.NewUser(t, tn.Company.ID, testutil.WithRole(tn.Role))
	otherDriver := testutil.NewDriver(t, tn.Company.ID, testutil.WithUser(otherUser))

	otherPrincipal := tn.DriverPrincipal(core.PermSupportRead, core.PermSupportCreate)
	otherPrincipal.UserID = otherDriver.UserID
	theirs := decodeTicket(t, srv.AsPrincipal(otherPrincipal).
		Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Theirs"}))

	// A self scoped principal that was granted the status permission by a
	// misconfigured role still cannot reach a ticket it does not own: 404.
	escalated := tn.DriverPrincipal(core.PermSupportRead, core.PermSupportCreate,
		core.PermSupportUpdateStatus)
	driver := srv.AsPrincipal(escalated)

	testutil.RequireStatusCode(t, driver.Patch("/api/v1/support-tickets/"+theirs.ID+"/status",
		dto.TicketStatusUpdate{Status: dto.StatusResolved}),
		http.StatusNotFound, apierr.CodeNotFound)

	mine := decodeTicket(t, driver.Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "Mine"}))
	moved := driver.Patch("/api/v1/support-tickets/"+mine.ID+"/status",
		dto.TicketStatusUpdate{Status: dto.StatusInProgress})
	testutil.RequireStatus(t, moved, http.StatusOK)
	require.Equal(t, dto.StatusInProgress, decodeTicket(t, moved).Status)
}

func TestCrossTenantStatusChangeIsNotFound(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	a := testutil.SeedTenant(t, allSupportPerms...)
	b := testutil.SeedTenant(t, allSupportPerms...)

	ticket := decodeTicket(t, srv.AsTenant(a).
		Post("/api/v1/support-tickets", dto.TicketCreate{Subject: "A's ticket"}))

	testutil.RequireStatusCode(t, srv.AsTenant(b).
		Patch("/api/v1/support-tickets/"+ticket.ID+"/status",
			dto.TicketStatusUpdate{Status: dto.StatusResolved}),
		http.StatusNotFound, apierr.CodeNotFound)
}
