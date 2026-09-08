//go:build integration

// Integration coverage of the chat module: the office thread list, the driver's
// single "Dispatch" thread, cursor pagination, the sent/delivered/read states,
// the driving mode block of TZ §15.4 and cross-tenant isolation (404, never
// 403).
package chat_test

import (
	"context"
	"net/http"
	"sync/atomic"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/chat"
	"github.com/devline/onebook-eld/internal/domain/chat/dto"
	"github.com/devline/onebook-eld/internal/testutil"
	"github.com/devline/onebook-eld/internal/ws"
)

var chatPerms = []string{core.PermChatRead, core.PermChatSend}

var now = time.Date(2026, 9, 6, 18, 0, 0, 0, time.UTC)

// capture records everything published on the chat channel.
type capture struct{ msgs []ws.Message }

func (c *capture) Publish(_ context.Context, m ws.Message) error {
	c.msgs = append(c.msgs, m)
	return nil
}

func newServer(t testing.TB) (*testutil.TestServer, *capture) {
	t.Helper()
	pool := testutil.NewDB(t)
	pub := &capture{}
	return testutil.NewServer(t, chat.New(chat.Deps{
		Repo:      chat.NewRepo(pool, nil),
		Verifier:  testutil.ContextVerifier(),
		Publisher: pub,
		Now:       func() time.Time { return now },
	})), pub
}

func threadPath(driverID uuid.UUID) string {
	return "/api/v1/chat/threads/" + driverID.String() + "/messages"
}

func decodeMessages(t *testing.T, resp *testutil.Response) ([]dto.Message, dto.CursorMeta) {
	t.Helper()
	var body struct {
		Data []dto.Message  `json:"data"`
		Meta dto.CursorMeta `json:"meta"`
	}
	resp.JSON(&body)
	return body.Data, body.Meta
}

func decodeThreads(t *testing.T, resp *testutil.Response) []dto.Thread {
	t.Helper()
	var body struct {
		Data []dto.Thread `json:"data"`
	}
	resp.JSON(&body)
	return body.Data
}

func decodeMessage(t *testing.T, resp *testutil.Response) dto.Message {
	t.Helper()
	var body struct {
		Data dto.Message `json:"data"`
	}
	resp.JSON(&body)
	return body.Data
}

// dutySeq keeps every duty status event written by a test strictly newer than
// the one seeded by SeedTenant (which is DR by default).
var dutySeq atomic.Int64

// setDutyStatus writes the driver's current duty status event.
func setDutyStatus(t *testing.T, tn *testutil.Tenant, status string) {
	t.Helper()
	at := time.Now().UTC().Add(time.Duration(dutySeq.Add(1)) * time.Second)
	testutil.NewDutyStatusEvent(t, tn.ID(),
		testutil.WithDriver(tn.Driver),
		testutil.WithUnit(tn.Unit),
		testutil.WithEventType("duty_status"),
		testutil.With("status", status),
		testutil.WithEventTime(at))
}

// ------------------------------------------------------------------- sending

func TestOfficeSendsAndDriverReads(t *testing.T) {
	t.Parallel()
	srv, pub := newServer(t)
	tn := testutil.SeedTenant(t, chatPerms...)

	resp := srv.AsTenant(tn).Post(threadPath(tn.Driver.ID), map[string]any{
		"kind": "text", "text": "Please head to dock 4 after your break.",
	})
	testutil.RequireStatus(t, resp, http.StatusCreated)
	testutil.RequireNoPII(t, resp.Body)

	msg := decodeMessage(t, resp)
	require.Equal(t, dto.SideOffice, msg.SenderSide)
	require.Equal(t, dto.StatusSent, msg.Status)
	require.Equal(t, tn.Driver.ID.String(), msg.DriverID)
	require.Nil(t, msg.ReadAt)

	// The message is fanned out on the WebSocket chat channel.
	require.Len(t, pub.msgs, 1)
	require.Equal(t, ws.ChannelChat, pub.msgs[0].Channel)
	require.Equal(t, chat.EventMessageCreated, pub.msgs[0].Event)
	require.Equal(t, tn.ID(), pub.msgs[0].CompanyID)

	// The driver acknowledges it: the state moves to read.
	driver := srv.AsPrincipal(tn.DriverPrincipal(chatPerms...))
	ack := driver.Post("/api/v1/chat/messages/"+msg.ID+"/read", nil)
	testutil.RequireStatus(t, ack, http.StatusOK)

	items, _ := decodeMessages(t, driver.Get(threadPath(tn.Driver.ID)))
	require.Len(t, items, 1)
	require.Equal(t, dto.StatusRead, items[0].Status)
	require.NotNil(t, items[0].ReadAt)
	require.NotNil(t, items[0].DeliveredAt)
}

func TestSenderCannotAcknowledgeItsOwnMessage(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, chatPerms...)
	c := srv.AsTenant(tn)

	msg := decodeMessage(t, c.Post(threadPath(tn.Driver.ID), map[string]any{
		"kind": "text", "text": "hello",
	}))
	resp := c.Post("/api/v1/chat/messages/"+msg.ID+"/read", nil)
	testutil.RequireStatus(t, resp, http.StatusOK)

	var body struct {
		Data dto.ReadResult `json:"data"`
	}
	resp.JSON(&body)
	require.EqualValues(t, 0, body.Data.Updated, "the author must not mark its own message read")
}

func TestDrivingModeBlocksTheDriver(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, chatPerms...)
	setDutyStatus(t, tn, "DR")

	driver := srv.AsPrincipal(tn.DriverPrincipal(chatPerms...))
	resp := driver.Post(threadPath(tn.Driver.ID), map[string]any{"kind": "text", "text": "on my way"})
	testutil.RequireStatusCode(t, resp, http.StatusConflict, apierr.CodeDrivingModeBlocked)

	// The office side is not blocked: the message waits for the driver.
	office := srv.AsTenant(tn).Post(threadPath(tn.Driver.ID), map[string]any{
		"kind": "text", "text": "call me when you stop",
	})
	testutil.RequireStatus(t, office, http.StatusCreated)

	// Once the driver leaves DR the block is gone.
	setDutyStatus(t, tn, "ON")
	ok := driver.Post(threadPath(tn.Driver.ID), map[string]any{"kind": "text", "text": "on my way"})
	testutil.RequireStatus(t, ok, http.StatusCreated)
}

func TestMessageValidation(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, chatPerms...)
	c := srv.AsTenant(tn)

	// A text message needs text.
	testutil.RequireStatusCode(t,
		c.Post(threadPath(tn.Driver.ID), map[string]any{"kind": "text"}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// An image needs a file_key; the upload itself is bounded at presign time.
	testutil.RequireStatusCode(t,
		c.Post(threadPath(tn.Driver.ID), map[string]any{"kind": "image"}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// A location needs coordinates.
	testutil.RequireStatusCode(t,
		c.Post(threadPath(tn.Driver.ID), map[string]any{"kind": "location"}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// 2000 characters is the limit of TZ §15.4.
	long := make([]byte, 2001)
	for i := range long {
		long[i] = 'a'
	}
	testutil.RequireStatus(t,
		c.Post(threadPath(tn.Driver.ID), map[string]any{"kind": "text", "text": string(long)}),
		http.StatusUnprocessableEntity)

	// A shared location is accepted.
	loc := c.Post(threadPath(tn.Driver.ID), map[string]any{
		"kind": "location", "lat": 31.5204, "lng": 74.3587,
	})
	testutil.RequireStatus(t, loc, http.StatusCreated)
	require.Equal(t, dto.KindLocation, decodeMessage(t, loc).Kind)
}

// ---------------------------------------------------------------- pagination

func TestCursorPaginationWalksBackwards(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, chatPerms...)
	c := srv.AsTenant(tn)

	for i := 0; i < 5; i++ {
		testutil.RequireStatus(t, c.Post(threadPath(tn.Driver.ID), map[string]any{
			"kind": "text", "text": "message",
		}), http.StatusCreated)
	}

	first, meta := decodeMessages(t, c.Get(threadPath(tn.Driver.ID), testutil.Query("limit", "2")))
	require.Len(t, first, 2)
	require.True(t, meta.HasMore)
	require.NotNil(t, meta.NextBefore)

	second, meta2 := decodeMessages(t, c.Get(threadPath(tn.Driver.ID),
		testutil.Query("limit", "2"),
		testutil.Query("before", meta.NextBefore.Format(time.RFC3339Nano))))
	require.Len(t, second, 2)
	require.True(t, meta2.HasMore)
	// Newest first, and the pages do not overlap.
	require.True(t, second[0].SentAt.Before(first[len(first)-1].SentAt) ||
		second[0].SentAt.Equal(first[len(first)-1].SentAt))
	for _, a := range first {
		for _, b := range second {
			require.NotEqual(t, a.ID, b.ID)
		}
	}

	last, meta3 := decodeMessages(t, c.Get(threadPath(tn.Driver.ID),
		testutil.Query("limit", "2"),
		testutil.Query("before", meta2.NextBefore.Format(time.RFC3339Nano))))
	require.Len(t, last, 1)
	require.False(t, meta3.HasMore)

	// A malformed cursor is a validation error, not an empty page.
	testutil.RequireStatusCode(t,
		c.Get(threadPath(tn.Driver.ID), testutil.Query("before", "yesterday")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
	testutil.RequireStatusCode(t,
		c.Get(threadPath(tn.Driver.ID), testutil.Query("limit", "5000")),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

// ------------------------------------------------------------------- threads

func TestThreadListShowsEveryDriverAndUnreadCount(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, chatPerms...)
	other := testutil.NewDriver(t, tn.ID())
	c := srv.AsTenant(tn)
	setDutyStatus(t, tn, "ON")

	// The driver writes twice; both stay unread for the office.
	driver := srv.AsPrincipal(tn.DriverPrincipal(chatPerms...))
	for i := 0; i < 2; i++ {
		testutil.RequireStatus(t, driver.Post(threadPath(tn.Driver.ID), map[string]any{
			"kind": "text", "text": "checking in",
		}), http.StatusCreated)
	}

	threads := decodeThreads(t, c.Get("/api/v1/chat/threads"))
	require.Len(t, threads, 2, "a driver without messages still has a thread")

	byID := map[string]dto.Thread{}
	for _, th := range threads {
		byID[th.DriverID] = th
	}
	active := byID[tn.Driver.ID.String()]
	require.EqualValues(t, 2, active.UnreadCount)
	require.NotNil(t, active.LastMessage)
	require.Equal(t, dto.SideDriver, active.LastMessage.SenderSide)

	empty := byID[other.ID.String()]
	require.Nil(t, empty.LastMessage)
	require.EqualValues(t, 0, empty.UnreadCount)

	// with_messages=true drops the empty conversation.
	only := decodeThreads(t, c.Get("/api/v1/chat/threads", testutil.Query("with_messages", "true")))
	require.Len(t, only, 1)
	require.Equal(t, tn.Driver.ID.String(), only[0].DriverID)
}

func TestDriverSeesOnlyItsOwnDispatchThread(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, chatPerms...)
	other := testutil.NewDriver(t, tn.ID())

	driver := srv.AsPrincipal(tn.DriverPrincipal(chatPerms...))
	threads := decodeThreads(t, driver.Get("/api/v1/chat/threads"))
	require.Len(t, threads, 1)
	require.Equal(t, tn.Driver.ID.String(), threads[0].DriverID)

	// Another driver's thread is invisible: 404, never 403.
	testutil.RequireStatusCode(t, driver.Get(threadPath(other.ID)),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t,
		driver.Post(threadPath(other.ID), map[string]any{"kind": "text", "text": "hi"}),
		http.StatusNotFound, apierr.CodeNotFound)
}

// -------------------------------------------------------------- isolation

func TestCrossTenantThreadIsNotFound(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	a, b := testutil.SeedTwoCompanies(t, chatPerms...)

	client := srv.AsTenant(a)
	testutil.RequireStatusCode(t, client.Get(threadPath(b.Driver.ID)),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t,
		client.Post(threadPath(b.Driver.ID), map[string]any{"kind": "text", "text": "hi"}),
		http.StatusNotFound, apierr.CodeNotFound)

	// A message of the other tenant cannot be acknowledged either.
	msg := decodeMessage(t, srv.AsTenant(b).Post(threadPath(b.Driver.ID), map[string]any{
		"kind": "text", "text": "internal",
	}))
	testutil.RequireStatusCode(t, client.Post("/api/v1/chat/messages/"+msg.ID+"/read", nil),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestChatRequiresPermissions(t *testing.T) {
	t.Parallel()
	srv, _ := newServer(t)
	tn := testutil.SeedTenant(t, core.PermChatRead) // read only
	c := srv.AsTenant(tn)

	testutil.RequireStatus(t, c.Get("/api/v1/chat/threads"), http.StatusOK)
	testutil.RequireStatusCode(t,
		c.Post(threadPath(tn.Driver.ID), map[string]any{"kind": "text", "text": "hi"}),
		http.StatusForbidden, apierr.CodeForbidden)

	none := testutil.SeedTenant(t)
	testutil.RequireStatusCode(t, srv.AsTenant(none).Get("/api/v1/chat/threads"),
		http.StatusForbidden, apierr.CodeForbidden)
	testutil.RequireStatusCode(t, srv.Anonymous().Get("/api/v1/chat/threads"),
		http.StatusUnauthorized, apierr.CodeUnauthorized)
}
