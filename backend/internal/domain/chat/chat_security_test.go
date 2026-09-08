//go:build integration

// Security regression coverage of the chat module: the WebSocket fan-out is
// addressed to one thread rather than broadcast to every `chat.read` holder, a
// read receipt is authorised before it mutates anything, and a client supplied
// file_key may only name this tenant's own object.
package chat_test

import (
	"net/http"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/domain/chat/dto"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/testutil"
)

// A chat event addresses the thread owner plus the office. Without that, every
// driver of the company holds `chat.read` and would receive every conversation.
func TestChatEventIsAddressedToItsThread(t *testing.T) {
	t.Parallel()
	srv, pub := newServer(t)
	tn := testutil.SeedTenant(t, chatPerms...)

	resp := srv.AsTenant(tn).Post(threadPath(tn.Driver.ID), map[string]any{
		"kind": "text", "text": "Head to dock 4.",
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)

	require.Len(t, pub.msgs, 1)
	to := pub.msgs[0].To
	require.False(t, to.IsZero(), "a chat message must never be a company wide broadcast")
	require.NotNil(t, to.UserID)
	require.Equal(t, tn.Driver.UserID, *to.UserID)
	require.True(t, to.Office, "the dispatch side must still receive the thread")
}

// A driver acknowledging another driver's message is a 404 and, crucially,
// changes nothing: the scope is resolved before the write, so no receipt is
// stored and no `chat_message_read` event carrying the text is published.
func TestDriverCannotAcknowledgeAnotherThread(t *testing.T) {
	t.Parallel()
	srv, pub := newServer(t)
	tn := testutil.SeedTenant(t, chatPerms...)

	// A second driver of the same company.
	otherUser := testutil.NewUser(t, tn.ID(), testutil.WithRole(tn.Role))
	other := testutil.NewDriver(t, tn.ID(), testutil.WithUser(otherUser))

	sent := decodeMessage(t, srv.AsTenant(tn).Post(threadPath(tn.Driver.ID), map[string]any{
		"kind": "text", "text": "Confidential dispatch note.",
	}))
	published := len(pub.msgs)

	p := tn.DriverPrincipal(chatPerms...)
	p.UserID = other.UserID
	resp := srv.AsPrincipal(p).Post("/api/v1/chat/messages/"+sent.ID+"/read", nil)
	testutil.RequireStatus(t, resp, http.StatusNotFound)
	require.Len(t, pub.msgs, published, "a refused receipt must not publish the message")

	// The message is still unread for its real owner.
	owner := srv.AsPrincipal(tn.DriverPrincipal(chatPerms...))
	items, _ := decodeMessages(t, owner.Get(threadPath(tn.Driver.ID)))
	require.Len(t, items, 1)
	require.Equal(t, dto.StatusSent, items[0].Status)
	require.Nil(t, items[0].ReadAt)
}

// A message id of another company is a 404, never a 403.
func TestCrossTenantAcknowledgeIsNotFound(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, chatPerms...)

	sent := decodeMessage(t, srv.AsTenant(a).Post(threadPath(a.Driver.ID), map[string]any{
		"kind": "text", "text": "internal",
	}))
	resp := srv.AsTenant(b).Post("/api/v1/chat/messages/"+sent.ID+"/read", nil)
	testutil.RequireStatus(t, resp, http.StatusNotFound)
}

// file_key is client supplied: it must be proven to belong to this tenant
// before it is stored, or a later presigned download would serve another
// company's object.
func TestForeignFileKeyIsRejected(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, chatPerms...)

	foreign := storage.BuildKey(b.ID(), "chat", "invoice.pdf", now)
	resp := srv.AsTenant(a).Post(threadPath(a.Driver.ID), map[string]any{
		"kind": "file", "file_key": foreign,
	})
	testutil.RequireStatus(t, resp, http.StatusUnprocessableEntity)

	for _, key := range []string{
		"../" + b.ID().String() + "/chat/2026/09/x.pdf",
		"/" + a.ID().String() + "/chat/2026/09/x.pdf",
		uuid.NewString() + "/chat/2026/09/x.pdf",
		a.ID().String(),
	} {
		bad := srv.AsTenant(a).Post(threadPath(a.Driver.ID), map[string]any{
			"kind": "file", "file_key": key,
		})
		testutil.RequireStatus(t, bad, http.StatusUnprocessableEntity)
	}

	own := storage.BuildKey(a.ID(), "chat", "invoice.pdf", now)
	ok := srv.AsTenant(a).Post(threadPath(a.Driver.ID), map[string]any{
		"kind": "file", "file_key": own,
	})
	testutil.RequireStatus(t, ok, http.StatusCreated)
}
