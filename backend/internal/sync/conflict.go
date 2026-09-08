package sync

// Conflict is the outcome of conflict rule 1 for one incoming event.
type Conflict struct {
	// IncomingWins reports whether the arriving event is the canonical one.
	IncomingWins bool
	// WinnerClientEventID is the surviving event when the incoming one loses.
	WinnerClientEventID string
	// WinnerID is the stored duty_status_events.id of that survivor, so the
	// caller can point the loser's superseded_by at it.
	WinnerID string
	// Supersedes are the stored duty_status_events.id values the incoming
	// event wins over. The caller stamps superseded_by on each.
	Supersedes []string
}

// Better reports whether a strictly beats b under conflict rule 1: the higher
// time_source priority wins (eld_rtc > server > phone); on a tie the larger
// device_seq wins; then the later received_at; finally the larger
// client_event_id, so the result never depends on evaluation order.
func Better(a, b Candidate) bool {
	if ra, rb := TimeSourceRank(a.TimeSource), TimeSourceRank(b.TimeSource); ra != rb {
		return ra > rb
	}
	if sa, sb := seq(a), seq(b); sa != sb {
		return sa > sb
	}
	if !a.ReceivedAt.Equal(b.ReceivedAt) {
		return a.ReceivedAt.After(b.ReceivedAt)
	}
	return a.ClientEventID > b.ClientEventID
}

// seq flattens a missing device_seq to below every reported one.
func seq(c Candidate) int64 {
	if c.DeviceSeq == nil {
		return -1
	}
	return *c.DeviceSeq
}

// ResolveConflict picks the canonical event among an incoming event and the
// stored events already occupying the same (driver, event_time) slot.
//
// The loser is never dropped: when the incoming event wins, the stored ones are
// returned in Supersedes; when it loses, the caller stores it with
// superseded_by pointing at the winner (rule 1).
func ResolveConflict(incoming Candidate, existing []Candidate) Conflict {
	if len(existing) == 0 {
		return Conflict{IncomingWins: true}
	}
	best := existing[0]
	for _, c := range existing[1:] {
		if Better(c, best) {
			best = c
		}
	}
	if !Better(incoming, best) {
		return Conflict{WinnerClientEventID: best.ClientEventID, WinnerID: best.ID}
	}
	ids := make([]string, 0, len(existing))
	for _, c := range existing {
		if c.ID != "" {
			ids = append(ids, c.ID)
		}
	}
	return Conflict{IncomingWins: true, Supersedes: ids}
}
