package chat

import (
	"context"
	"encoding/json"
	"sort"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
)

// officeThreadScan bounds how many of the most recently active threads an
// office side reconnect scans for missed messages. Threads come back ordered
// by last activity (ListChatThreads), so this only costs a query per thread
// that actually has something newer than `since`; ws.MaxBackfill (200) caps
// the reply regardless.
const officeThreadScan = 50

// Backfiller replays the chat messages a reconnecting client missed (TZ B§3
// — WS `since` backfill). It composes the existing Repo methods (Threads,
// History) rather than adding a new query: a driver reconnect reads its own
// thread, an office reconnect scans the recently active ones. Either way the
// result is handed back to internal/ws/session.go, which re-applies the
// tenant and Audience gates before delivery — this is defense in depth, not
// the only gate, but a driver backfill never even queries another thread.
type Backfiller struct {
	repo Repo
	now  func() time.Time
}

// NewBackfiller builds the chat channel Backfiller. repo is the same Repo the
// chat Service uses.
func NewBackfiller(repo Repo, now func() time.Time) *Backfiller {
	if now == nil {
		now = time.Now
	}
	return &Backfiller{repo: repo, now: now}
}

// Backfill implements ws.Backfiller.
func (b *Backfiller) Backfill(ctx context.Context, req ws.BackfillRequest) ([]ws.Message, error) {
	if req.Channel != ws.ChannelChat {
		return nil, nil
	}
	limit := req.Limit
	if limit <= 0 || limit > ws.MaxBackfill {
		limit = ws.MaxBackfill
	}
	// Defense in depth: internal/ws/session.go already clamps `since` to the
	// 24h window before calling in, but this package must not depend on that
	// caller doing it right.
	since := req.Since
	if oldest := b.now().UTC().Add(-ws.MaxBackfillWindow); since.Before(oldest) {
		since = oldest
	}
	// Q: the underlying Repo resolves company_id from the context, exactly as
	// every HTTP request does; a reconnect must not be allowed to widen scope
	// beyond the tenant it authenticated into.
	ctx = tenant.WithCompanyID(ctx, req.CompanyID)

	driver, err := b.repo.DriverByUser(ctx, req.UserID)
	if err == nil {
		return b.selfSince(ctx, req.CompanyID, driver, since, limit)
	}
	if e, ok := apierr.From(err); ok && e.Code == apierr.CodeNotFound {
		// Not a driver: the office side of the tenant.
		return b.officeSince(ctx, req.CompanyID, since, limit)
	}
	return nil, err
}

// selfSince replays one driver's own thread. It never touches another
// driver's history: the id it queries is the caller's own, resolved from its
// authenticated user id, not from anything on the wire.
func (b *Backfiller) selfSince(ctx context.Context, companyID uuid.UUID, driver Driver, since time.Time, limit int) ([]ws.Message, error) {
	limit32 := int32(limit) //nolint:gosec // G115: capped at ws.MaxBackfill
	rows, err := b.repo.History(ctx, HistoryFilter{DriverID: driver.ID, Limit: limit32})
	if err != nil {
		return nil, err
	}
	out := make([]ws.Message, 0, len(rows))
	for _, row := range rows {
		if !row.SentAt.After(since) {
			continue
		}
		msg, err := chatMessage(companyID, driver.UserID, driver.BranchID, row)
		if err != nil {
			continue
		}
		out = append(out, msg)
	}
	return sortAndCap(out, limit), nil
}

// officeSince scans the most recently active threads for messages newer than
// `since`. Threads are ordered by last activity, so the scan stops as soon as
// one page-worth of threads has nothing left to offer.
func (b *Backfiller) officeSince(ctx context.Context, companyID uuid.UUID, since time.Time, limit int) ([]ws.Message, error) {
	threads, last, _, err := b.repo.Threads(ctx, ThreadFilter{Limit: officeThreadScan})
	if err != nil {
		return nil, err
	}
	lastSentAt := make(map[uuid.UUID]time.Time, len(last))
	for _, m := range last {
		lastSentAt[m.DriverID] = m.SentAt
	}

	var out []ws.Message
	for _, th := range threads {
		sentAt, ok := lastSentAt[th.DriverID]
		if !ok || !sentAt.After(since) {
			// Descending activity order: nothing further on the page is newer.
			break
		}
		branchID := pgconv.ToUUIDPtr(th.BranchID)
		limit32 := int32(limit) //nolint:gosec // G115: capped at ws.MaxBackfill
		rows, err := b.repo.History(ctx, HistoryFilter{DriverID: th.DriverID, Limit: limit32})
		if err != nil {
			return nil, err
		}
		for _, row := range rows {
			if !row.SentAt.After(since) {
				continue
			}
			msg, err := chatMessage(companyID, th.DriverUserID, branchID, row)
			if err != nil {
				continue
			}
			out = append(out, msg)
		}
		if len(out) >= limit {
			break
		}
	}
	return sortAndCap(out, limit), nil
}

// chatMessage wraps one stored row into the wire envelope Service.publish
// uses, so a replayed message is indistinguishable in shape from a live one.
func chatMessage(companyID, driverUserID uuid.UUID, branchID *uuid.UUID, row db.ChatMessage) (ws.Message, error) {
	payload, err := json.Marshal(toDTO(row, driverUserID))
	if err != nil {
		return ws.Message{}, err
	}
	return ws.Message{
		Channel:   ws.ChannelChat,
		Event:     EventMessageCreated,
		CompanyID: companyID,
		Payload:   payload,
		SentAt:    row.SentAt.UTC(),
		To:        ws.Audience{UserID: &driverUserID, Office: true, BranchID: branchID},
	}, nil
}

// sortAndCap orders messages oldest first and, if the reconnect produced more
// than the channel's backfill limit, keeps the most recent ones — the caller
// can always fall back to the regular history endpoint for anything older.
func sortAndCap(msgs []ws.Message, limit int) []ws.Message {
	sort.Slice(msgs, func(i, j int) bool { return msgs[i].SentAt.Before(msgs[j].SentAt) })
	if limit > 0 && len(msgs) > limit {
		msgs = msgs[len(msgs)-limit:]
	}
	return msgs
}
