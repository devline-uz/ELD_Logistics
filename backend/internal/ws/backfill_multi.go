package ws

import "context"

// MultiBackfiller dispatches a backfill request to whichever of its members
// handles the request's channel; each per-channel Backfiller (chat,
// notifications, ...) already ignores channels it does not own by returning
// (nil, nil). Wiring passes one of these into Deps.Backfill.
type MultiBackfiller []Backfiller

// Backfill implements Backfiller.
func (m MultiBackfiller) Backfill(ctx context.Context, req BackfillRequest) ([]Message, error) {
	for _, b := range m {
		if b == nil {
			continue
		}
		msgs, err := b.Backfill(ctx, req)
		if err != nil {
			return nil, err
		}
		if len(msgs) > 0 {
			return msgs, nil
		}
	}
	return nil, nil
}
