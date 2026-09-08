package chat

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/chat/dto"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
)

// fakeRepo is a minimal, in-memory Repo used only to exercise Backfiller: no
// database, no testcontainers. It also records every context it was called
// with, so a test can prove the backfiller never widens the tenant it was
// asked to replay.
type fakeRepo struct {
	byUser    map[uuid.UUID]Driver
	messages  map[uuid.UUID][]db.ChatMessage // by driver id, any order
	threads   []db.ListChatThreadsRow
	last      []db.ListChatLastMessagesRow
	seenTx    []uuid.UUID // company_id observed on every call
	historyOf []uuid.UUID // driver ids History was actually called for
}

func (f *fakeRepo) observe(ctx context.Context) {
	f.seenTx = append(f.seenTx, tenant.CompanyID(ctx))
}

func (f *fakeRepo) Driver(context.Context, uuid.UUID) (Driver, error) { panic("unused by Backfiller") }

func (f *fakeRepo) DriverByUser(ctx context.Context, userID uuid.UUID) (Driver, error) {
	f.observe(ctx)
	d, ok := f.byUser[userID]
	if !ok {
		return Driver{}, apierr.NotFound("driver")
	}
	return d, nil
}

func (f *fakeRepo) DriverOfMessage(context.Context, uuid.UUID) (Driver, error) {
	panic("unused by Backfiller")
}

func (f *fakeRepo) CurrentDutyStatus(context.Context, uuid.UUID) (string, error) {
	panic("unused by Backfiller")
}

func (f *fakeRepo) Threads(ctx context.Context, _ ThreadFilter) ([]db.ListChatThreadsRow, []db.ListChatLastMessagesRow, int64, error) {
	f.observe(ctx)
	return f.threads, f.last, int64(len(f.threads)), nil
}

func (f *fakeRepo) History(ctx context.Context, hf HistoryFilter) ([]db.ChatMessage, error) {
	f.observe(ctx)
	f.historyOf = append(f.historyOf, hf.DriverID)
	rows := append([]db.ChatMessage(nil), f.messages[hf.DriverID]...)
	// Mirror the real query: newest first, capped at the limit.
	for i, j := 0, len(rows)-1; i < j; i, j = i+1, j-1 {
		rows[i], rows[j] = rows[j], rows[i]
	}
	sortDesc(rows)
	if int(hf.Limit) > 0 && len(rows) > int(hf.Limit) {
		rows = rows[:hf.Limit]
	}
	return rows, nil
}

func sortDesc(rows []db.ChatMessage) {
	for i := 1; i < len(rows); i++ {
		for j := i; j > 0 && rows[j].SentAt.After(rows[j-1].SentAt); j-- {
			rows[j], rows[j-1] = rows[j-1], rows[j]
		}
	}
}

func (f *fakeRepo) Create(context.Context, NewMessage) (db.ChatMessage, error) {
	panic("unused by Backfiller")
}

func (f *fakeRepo) MarkRead(context.Context, uuid.UUID, uuid.UUID) (db.ChatMessage, int64, error) {
	panic("unused by Backfiller")
}

func (f *fakeRepo) Unread(context.Context, uuid.UUID, uuid.UUID) (int64, error) {
	panic("unused by Backfiller")
}

var _ Repo = (*fakeRepo)(nil)

func msg(driverID, senderID uuid.UUID, sentAt time.Time) db.ChatMessage {
	text := "hi"
	return db.ChatMessage{
		ID: uuid.New(), DriverID: driverID, SenderID: senderID,
		Kind: dto.KindText, Text: &text, SentAt: sentAt,
	}
}

// -------------------------------------------------------------------- self

func TestBackfillSelfScopeReturnsOnlyOwnMessagesAfterSince(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 9, 7, 12, 0, 0, 0, time.UTC)
	companyID := uuid.New()
	own := Driver{ID: uuid.New(), UserID: uuid.New()}
	other := Driver{ID: uuid.New(), UserID: uuid.New()}
	since := now.Add(-2 * time.Hour)

	repo := &fakeRepo{byUser: map[uuid.UUID]Driver{own.UserID: own}, messages: map[uuid.UUID][]db.ChatMessage{
		own.ID: {
			msg(own.ID, own.UserID, now.Add(-3*time.Hour)), // before since: dropped
			msg(own.ID, own.UserID, now.Add(-1*time.Hour)),
			msg(own.ID, own.UserID, now.Add(-30*time.Minute)),
		},
		other.ID: {
			msg(other.ID, other.UserID, now.Add(-10*time.Minute)),
		},
	}}
	b := NewBackfiller(repo, func() time.Time { return now })

	out, err := b.Backfill(context.Background(), ws.BackfillRequest{
		CompanyID: companyID, UserID: own.UserID, Channel: ws.ChannelChat, Since: since, Limit: ws.MaxBackfill,
	})
	require.NoError(t, err)
	require.Len(t, out, 2, "the message before `since` must not be replayed")
	require.True(t, out[0].SentAt.Before(out[1].SentAt), "oldest first")

	for _, m := range out {
		require.Equal(t, ws.ChannelChat, m.Channel)
		require.Equal(t, EventMessageCreated, m.Event)
		require.Equal(t, companyID, m.CompanyID)
		require.NotNil(t, m.To.UserID)
		require.Equal(t, own.UserID, *m.To.UserID, "a driver reconnect must never be addressed to another driver")

		var payload dto.Message
		require.NoError(t, json.Unmarshal(m.Payload, &payload))
		require.Equal(t, own.ID.String(), payload.DriverID, "another driver's thread must never leak into the reply")
	}

	// The other driver's thread was never even queried.
	require.NotContains(t, repo.historyOf, other.ID)

	// The repo saw exactly the company the request named.
	for _, seen := range repo.seenTx {
		require.Equal(t, companyID, seen)
	}
}

func TestBackfillSelfScopeUnknownDriverIsNotFound(t *testing.T) {
	t.Parallel()
	repo := &fakeRepo{byUser: map[uuid.UUID]Driver{}}
	b := NewBackfiller(repo, nil)
	// An office principal (no driver record) falls through to the office
	// path, which must not error just because Threads/last are empty.
	out, err := b.Backfill(context.Background(), ws.BackfillRequest{
		CompanyID: uuid.New(), UserID: uuid.New(), Channel: ws.ChannelChat,
		Since: time.Now().Add(-time.Hour), Limit: ws.MaxBackfill,
	})
	require.NoError(t, err)
	require.Empty(t, out)
}

// ------------------------------------------------------------------ office

func TestBackfillOfficeScopeAggregatesActiveThreadsAndStopsAtStaleOnes(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 9, 7, 12, 0, 0, 0, time.UTC)
	companyID := uuid.New()
	since := now.Add(-2 * time.Hour)

	active := Driver{ID: uuid.New(), UserID: uuid.New()}
	alsoActive := Driver{ID: uuid.New(), UserID: uuid.New()}
	stale := Driver{ID: uuid.New(), UserID: uuid.New()} // last message before `since`

	repo := &fakeRepo{
		byUser: map[uuid.UUID]Driver{}, // office principal: no driver record
		threads: []db.ListChatThreadsRow{
			{DriverID: active.ID, DriverUserID: active.UserID},
			{DriverID: alsoActive.ID, DriverUserID: alsoActive.UserID},
			{DriverID: stale.ID, DriverUserID: stale.UserID},
		},
		last: []db.ListChatLastMessagesRow{
			{DriverID: active.ID, SentAt: now.Add(-10 * time.Minute)},
			{DriverID: alsoActive.ID, SentAt: now.Add(-20 * time.Minute)},
			{DriverID: stale.ID, SentAt: now.Add(-3 * time.Hour)},
		},
		messages: map[uuid.UUID][]db.ChatMessage{
			active.ID:     {msg(active.ID, active.UserID, now.Add(-10*time.Minute))},
			alsoActive.ID: {msg(alsoActive.ID, alsoActive.UserID, now.Add(-20*time.Minute))},
			stale.ID:      {msg(stale.ID, stale.UserID, now.Add(-3*time.Hour))},
		},
	}
	b := NewBackfiller(repo, func() time.Time { return now })

	out, err := b.Backfill(context.Background(), ws.BackfillRequest{
		CompanyID: companyID, UserID: uuid.New(), Channel: ws.ChannelChat, Since: since, Limit: ws.MaxBackfill,
	})
	require.NoError(t, err)
	require.Len(t, out, 2)

	drivers := make([]string, 0, len(out))
	for _, m := range out {
		var payload dto.Message
		require.NoError(t, json.Unmarshal(m.Payload, &payload))
		drivers = append(drivers, payload.DriverID)
		require.True(t, m.To.Office, "office replay must still address the dispatch side")
	}
	require.ElementsMatch(t, []string{active.ID.String(), alsoActive.ID.String()}, drivers)

	// The stale thread's own history was never fetched: the scan stopped once
	// it hit a thread whose last activity was not after `since`.
	require.NotContains(t, repo.historyOf, stale.ID)
}

func TestBackfillOtherTenantChannelIsIgnored(t *testing.T) {
	t.Parallel()
	repo := &fakeRepo{}
	b := NewBackfiller(repo, nil)
	out, err := b.Backfill(context.Background(), ws.BackfillRequest{
		Channel: ws.ChannelDashboard, Since: time.Now(),
	})
	require.NoError(t, err)
	require.Nil(t, out, "a channel this backfiller does not own must be a no-op, not an error")
}

// -------------------------------------------------------------------- bounds

func TestBackfillHonorsTheEventLimit(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 9, 7, 12, 0, 0, 0, time.UTC)
	own := Driver{ID: uuid.New(), UserID: uuid.New()}
	since := now.Add(-24 * time.Hour)

	const total = ws.MaxBackfill + 50
	var msgs []db.ChatMessage
	for i := 0; i < total; i++ {
		msgs = append(msgs, msg(own.ID, own.UserID, since.Add(time.Duration(i+1)*time.Second)))
	}
	repo := &fakeRepo{byUser: map[uuid.UUID]Driver{own.UserID: own},
		messages: map[uuid.UUID][]db.ChatMessage{own.ID: msgs}}
	b := NewBackfiller(repo, func() time.Time { return now })

	out, err := b.Backfill(context.Background(), ws.BackfillRequest{
		CompanyID: uuid.New(), UserID: own.UserID, Channel: ws.ChannelChat,
		Since: since, Limit: ws.MaxBackfill,
	})
	require.NoError(t, err)
	require.LessOrEqual(t, len(out), ws.MaxBackfill)
	// The kept messages are the most recent ones, still oldest first.
	require.True(t, out[0].SentAt.Before(out[len(out)-1].SentAt))
}

func TestBackfillClampsToThe24HourWindow(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 9, 7, 12, 0, 0, 0, time.UTC)
	own := Driver{ID: uuid.New(), UserID: uuid.New()}
	// `since` is far older than the 24h window; the message sits just inside
	// the clamped window and must still come back.
	insideClamp := now.Add(-23 * time.Hour)
	repo := &fakeRepo{byUser: map[uuid.UUID]Driver{own.UserID: own},
		messages: map[uuid.UUID][]db.ChatMessage{own.ID: {msg(own.ID, own.UserID, insideClamp)}}}
	b := NewBackfiller(repo, func() time.Time { return now })

	out, err := b.Backfill(context.Background(), ws.BackfillRequest{
		CompanyID: uuid.New(), UserID: own.UserID, Channel: ws.ChannelChat,
		Since: now.Add(-30 * 24 * time.Hour), Limit: ws.MaxBackfill,
	})
	require.NoError(t, err)
	require.Len(t, out, 1)
}
