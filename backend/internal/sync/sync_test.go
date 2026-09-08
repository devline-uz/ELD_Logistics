// Table tests of the offline sync rule layer: every conflict rule (1-5), the
// batch ceilings and the time integrity thresholds. The package is pure, so the
// server instant is a fixture and no clock, DB or network is involved.
package sync_test

import (
	"errors"
	"testing"
	"time"

	sync "github.com/devline/onebook-eld/internal/sync"
)

// now is the fixed server instant every case is measured against.
var now = time.Date(2026, 9, 6, 12, 0, 0, 0, time.UTC)

const (
	idA = "11111111-1111-4111-8111-111111111111"
	idB = "22222222-2222-4222-8222-222222222222"
	idC = "33333333-3333-4333-8333-333333333333"
)

func seq(v int64) *int64     { return &v }
func f64(v float64) *float64 { return &v }
func i32(v int32) *int32     { return &v }

// event builds a minimal valid duty status change.
func event(mut ...func(*sync.Event)) sync.Event {
	e := sync.Event{
		ClientEventID: idA,
		EventType:     sync.EventStatusChange,
		Status:        sync.StatusOn,
		EventTime:     now.Add(-time.Hour),
		TimeSource:    sync.TimeSourceELDRTC,
		DeviceSeq:     seq(1042),
	}
	for _, m := range mut {
		m(&e)
	}
	return e
}

// ---------------------------------------------------------------- validation

func TestValidateEvent(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name       string
		event      sync.Event
		wantReason string
		wantField  string
	}{
		{name: "valid", event: event()},
		{
			name:       "client_event_id must be a uuid",
			event:      event(func(e *sync.Event) { e.ClientEventID = "not-a-uuid" }),
			wantReason: sync.ReasonInvalidPayload, wantField: "client_event_id",
		},
		{
			name:       "event_type must be known",
			event:      event(func(e *sync.Event) { e.EventType = "teleport" }),
			wantReason: sync.ReasonInvalidPayload, wantField: "event_type",
		},
		{
			name:       "duty status change requires a status",
			event:      event(func(e *sync.Event) { e.Status = "" }),
			wantReason: sync.ReasonInvalidPayload, wantField: "status",
		},
		{
			name:       "status must be in the enum",
			event:      event(func(e *sync.Event) { e.Status = "OFFF" }),
			wantReason: sync.ReasonInvalidPayload, wantField: "status",
		},
		{
			name:  "positional event needs no status",
			event: event(func(e *sync.Event) { e.EventType = sync.EventIntermediate; e.Status = "" }),
		},
		{
			name:       "special must be in the enum",
			event:      event(func(e *sync.Event) { e.Special = "moon" }),
			wantReason: sync.ReasonInvalidPayload, wantField: "special",
		},
		{
			name:       "origin must be in the enum",
			event:      event(func(e *sync.Event) { e.Origin = "hacker" }),
			wantReason: sync.ReasonInvalidPayload, wantField: "origin",
		},
		{
			name:       "time_source must be in the enum",
			event:      event(func(e *sync.Event) { e.TimeSource = "sundial" }),
			wantReason: sync.ReasonInvalidPayload, wantField: "time_source",
		},
		{
			name:       "event_time is required",
			event:      event(func(e *sync.Event) { e.EventTime = time.Time{} }),
			wantReason: sync.ReasonInvalidPayload, wantField: "event_time",
		},
		{
			name:       "device_seq cannot be negative",
			event:      event(func(e *sync.Event) { e.DeviceSeq = seq(-1) }),
			wantReason: sync.ReasonInvalidPayload, wantField: "device_seq",
		},
		{
			name: "notes are capped at 60 characters (Q7)",
			event: event(func(e *sync.Event) {
				e.Notes = "123456789012345678901234567890123456789012345678901234567890x"
			}),
			wantReason: sync.ReasonInvalidPayload, wantField: "notes",
		},
		{
			name:  "60 character note is accepted",
			event: event(func(e *sync.Event) { e.Notes = "123456789012345678901234567890123456789012345678901234567890" }),
		},
		{
			name:       "latitude out of range",
			event:      event(func(e *sync.Event) { e.Lat = f64(91) }),
			wantReason: sync.ReasonInvalidPayload, wantField: "lat",
		},
		{
			name:       "longitude out of range",
			event:      event(func(e *sync.Event) { e.Lng = f64(-181) }),
			wantReason: sync.ReasonInvalidPayload, wantField: "lng",
		},
		{
			name:       "gps accuracy cannot be negative",
			event:      event(func(e *sync.Event) { e.GPSAccuracyM = i32(-5) }),
			wantReason: sync.ReasonInvalidPayload, wantField: "gps_accuracy_m",
		},
		{
			name:       "odometer cannot be negative",
			event:      event(func(e *sync.Event) { e.OdometerM = new(int64); *e.OdometerM = -1 }),
			wantReason: sync.ReasonInvalidPayload, wantField: "odometer_m",
		},
		{
			name:       "speed out of range",
			event:      event(func(e *sync.Event) { e.SpeedKmh = f64(401) }),
			wantReason: sync.ReasonInvalidPayload, wantField: "speed_kmh",
		},
		{
			name:       "trailer ids must be uuids",
			event:      event(func(e *sync.Event) { e.TrailerIDs = []string{"nope"} }),
			wantReason: sync.ReasonInvalidPayload, wantField: "trailer_ids",
		},
		{
			name:       "shipping doc ids must be uuids",
			event:      event(func(e *sync.Event) { e.ShippingDocIDs = []string{"nope"} }),
			wantReason: sync.ReasonInvalidPayload, wantField: "shipping_doc_ids",
		},
		{
			name:       "unit id must be a uuid",
			event:      event(func(e *sync.Event) { e.UnitID = "nope" }),
			wantReason: sync.ReasonInvalidPayload, wantField: "unit_id",
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got := sync.ValidateEvent(tc.event, now)
			if got.Reason != tc.wantReason || got.Field != tc.wantField {
				t.Fatalf("got %+v, want reason=%q field=%q", got, tc.wantReason, tc.wantField)
			}
		})
	}
}

// Rule 3: an event more than five minutes ahead of the server is refused.
func TestCheckEventTimeWindow(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name       string
		at         time.Time
		wantReason string
	}{
		{name: "past", at: now.Add(-24 * time.Hour)},
		{name: "now", at: now},
		{name: "four minutes ahead is tolerated", at: now.Add(4 * time.Minute)},
		{name: "exactly five minutes ahead is tolerated", at: now.Add(sync.FutureSkew)},
		{
			name: "six minutes ahead is rejected", at: now.Add(6 * time.Minute),
			wantReason: sync.ReasonTimeInFuture,
		},
		{
			name: "older than the offline window", at: now.Add(-sync.MaxPastAge - time.Hour),
			wantReason: sync.ReasonTimeOutOfRange,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if got := sync.CheckEventTime(tc.at, now); got.Reason != tc.wantReason {
				t.Fatalf("got reason %q, want %q", got.Reason, tc.wantReason)
			}
		})
	}
}

// --------------------------------------------------------------- batch limits

func TestValidateBatchCeilings(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name  string
		batch sync.Batch
		want  error
	}{
		{name: "empty", batch: sync.Batch{}},
		{name: "at the event ceiling", batch: sync.Batch{Events: make([]sync.Event, sync.MaxEvents)}},
		{
			name:  "over the event ceiling",
			batch: sync.Batch{Events: make([]sync.Event, sync.MaxEvents+1)},
			want:  sync.ErrTooManyEvents,
		},
		{
			name:  "at the telemetry ceiling",
			batch: sync.Batch{Telemetry: make([]sync.TelemetryPoint, sync.MaxTelemetryPoints)},
		},
		{
			name:  "over the telemetry ceiling",
			batch: sync.Batch{Telemetry: make([]sync.TelemetryPoint, sync.MaxTelemetryPoints+1)},
			want:  sync.ErrTooManyTelemetry,
		},
		{name: "over the dvir ceiling", batch: sync.Batch{DvirCount: sync.MaxDvir + 1}, want: sync.ErrTooManyDvir},
		{name: "over the chat ceiling", batch: sync.Batch{ChatCount: sync.MaxChat + 1}, want: sync.ErrTooManyChat},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if err := sync.ValidateBatch(tc.batch); !errors.Is(err, tc.want) {
				t.Fatalf("got %v, want %v", err, tc.want)
			}
		})
	}
}

func TestPlanPushRefusesOversizedBatch(t *testing.T) {
	t.Parallel()
	_, err := sync.PlanPush(sync.Batch{Events: make([]sync.Event, sync.MaxEvents+1)}, now, sync.Lookup{})
	if !errors.Is(err, sync.ErrTooManyEvents) {
		t.Fatalf("got %v, want ErrTooManyEvents", err)
	}
}

// ------------------------------------------------------------ time integrity

func TestEvaluateClock(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name            string
		clock           sync.Clock
		wantSource      string
		wantSkew        int
		wantUnverified  bool
		wantWarn        bool
		wantMalfunction bool
	}{
		{
			name:       "eld rtc in sync with the phone",
			clock:      sync.Clock{Phone: now, ELDRTC: now},
			wantSource: sync.TimeSourceELDRTC,
		},
		{
			name:       "one minute drift stays below the warning level",
			clock:      sync.Clock{Phone: now.Add(time.Minute), ELDRTC: now},
			wantSource: sync.TimeSourceELDRTC, wantSkew: 60,
		},
		{
			name:       "three minutes drift warns the driver",
			clock:      sync.Clock{Phone: now.Add(3 * time.Minute), ELDRTC: now},
			wantSource: sync.TimeSourceELDRTC, wantSkew: 180, wantWarn: true,
		},
		{
			name:       "a phone running behind keeps the sign",
			clock:      sync.Clock{Phone: now.Add(-3 * time.Minute), ELDRTC: now},
			wantSource: sync.TimeSourceELDRTC, wantSkew: -180, wantWarn: true,
		},
		{
			name:       "eleven minutes drift is a timing malfunction",
			clock:      sync.Clock{Phone: now.Add(11 * time.Minute), ELDRTC: now},
			wantSource: sync.TimeSourceELDRTC, wantSkew: 660, wantWarn: true, wantMalfunction: true,
		},
		{
			name:       "no eld: the phone is the only clock and is unverified",
			clock:      sync.Clock{Phone: now.Add(30 * time.Second)},
			wantSource: sync.TimeSourcePhone, wantSkew: 30, wantUnverified: true,
		},
		{
			name:       "no eld and a badly drifted phone",
			clock:      sync.Clock{Phone: now.Add(12 * time.Minute)},
			wantSource: sync.TimeSourcePhone, wantSkew: 720, wantUnverified: true,
			wantWarn: true, wantMalfunction: true,
		},
		{name: "no device clock at all is server stamped", clock: sync.Clock{}, wantSource: sync.TimeSourceServer},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got := sync.EvaluateClock(tc.clock, now)
			if got.Source != tc.wantSource || got.SkewSec != tc.wantSkew ||
				got.Unverified != tc.wantUnverified || got.Warn != tc.wantWarn ||
				got.Malfunction != tc.wantMalfunction {
				t.Fatalf("got %+v, want source=%q skew=%d unverified=%v warn=%v malfunction=%v",
					got, tc.wantSource, tc.wantSkew, tc.wantUnverified, tc.wantWarn, tc.wantMalfunction)
			}
			wantCode := ""
			if tc.wantMalfunction {
				wantCode = sync.MalfunctionTiming
			}
			if got.MalfunctionCode() != wantCode {
				t.Fatalf("malfunction code %q, want %q", got.MalfunctionCode(), wantCode)
			}
		})
	}
}

func TestEventIntegrityPerEvent(t *testing.T) {
	t.Parallel()
	in := sync.EvaluateClock(sync.Clock{Phone: now.Add(3 * time.Minute), ELDRTC: now}, now)

	cases := []struct {
		name           string
		source         string
		wantSource     string
		wantUnverified bool
	}{
		{name: "event names the eld rtc", source: sync.TimeSourceELDRTC, wantSource: sync.TimeSourceELDRTC},
		{name: "event stamped from the phone is unverified", source: sync.TimeSourcePhone,
			wantSource: sync.TimeSourcePhone, wantUnverified: true},
		{name: "event without a source inherits the batch", source: "", wantSource: sync.TimeSourceELDRTC},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			src, unverified, skew := sync.EventIntegrity(event(func(e *sync.Event) { e.TimeSource = tc.source }), in)
			if src != tc.wantSource || unverified != tc.wantUnverified || skew != 180 {
				t.Fatalf("got source=%q unverified=%v skew=%d, want %q/%v/180",
					src, unverified, skew, tc.wantSource, tc.wantUnverified)
			}
		})
	}
}

// ---------------------------------------------------------------- conflicts

func TestBetterOrdering(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name string
		a, b sync.Candidate
		want bool
	}{
		{
			name: "eld_rtc beats server",
			a:    sync.Candidate{TimeSource: sync.TimeSourceELDRTC},
			b:    sync.Candidate{TimeSource: sync.TimeSourceServer},
			want: true,
		},
		{
			name: "server beats phone",
			a:    sync.Candidate{TimeSource: sync.TimeSourceServer},
			b:    sync.Candidate{TimeSource: sync.TimeSourcePhone},
			want: true,
		},
		{
			name: "phone loses to eld_rtc",
			a:    sync.Candidate{TimeSource: sync.TimeSourcePhone},
			b:    sync.Candidate{TimeSource: sync.TimeSourceELDRTC},
			want: false,
		},
		{
			name: "equal source: the larger device_seq wins",
			a:    sync.Candidate{TimeSource: sync.TimeSourcePhone, DeviceSeq: seq(9)},
			b:    sync.Candidate{TimeSource: sync.TimeSourcePhone, DeviceSeq: seq(8)},
			want: true,
		},
		{
			name: "equal source: a missing device_seq loses",
			a:    sync.Candidate{TimeSource: sync.TimeSourcePhone},
			b:    sync.Candidate{TimeSource: sync.TimeSourcePhone, DeviceSeq: seq(0)},
			want: false,
		},
		{
			name: "equal seq: the later received_at wins",
			a:    sync.Candidate{TimeSource: sync.TimeSourcePhone, DeviceSeq: seq(1), ReceivedAt: now},
			b:    sync.Candidate{TimeSource: sync.TimeSourcePhone, DeviceSeq: seq(1), ReceivedAt: now.Add(-time.Second)},
			want: true,
		},
		{
			name: "fully equal: the larger client_event_id wins deterministically",
			a:    sync.Candidate{TimeSource: sync.TimeSourcePhone, DeviceSeq: seq(1), ClientEventID: idB},
			b:    sync.Candidate{TimeSource: sync.TimeSourcePhone, DeviceSeq: seq(1), ClientEventID: idA},
			want: true,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if got := sync.Better(tc.a, tc.b); got != tc.want {
				t.Fatalf("Better = %v, want %v", got, tc.want)
			}
		})
	}
}

func TestResolveConflict(t *testing.T) {
	t.Parallel()

	stored := func(id, clientID, source string, s int64) sync.Candidate {
		return sync.Candidate{ID: id, ClientEventID: clientID, TimeSource: source, DeviceSeq: seq(s)}
	}

	cases := []struct {
		name           string
		incoming       sync.Candidate
		existing       []sync.Candidate
		wantWins       bool
		wantWinner     string
		wantSupersedes []string
	}{
		{
			name:     "no stored event at that instant",
			incoming: sync.Candidate{ClientEventID: idA, TimeSource: sync.TimeSourcePhone},
			wantWins: true,
		},
		{
			name:           "eld_rtc supersedes a stored phone event",
			incoming:       sync.Candidate{ClientEventID: idA, TimeSource: sync.TimeSourceELDRTC, DeviceSeq: seq(1)},
			existing:       []sync.Candidate{stored("e1", idB, sync.TimeSourcePhone, 99)},
			wantWins:       true,
			wantSupersedes: []string{"e1"},
		},
		{
			name:       "phone loses to a stored eld_rtc event",
			incoming:   sync.Candidate{ClientEventID: idA, TimeSource: sync.TimeSourcePhone, DeviceSeq: seq(99)},
			existing:   []sync.Candidate{stored("e1", idB, sync.TimeSourceELDRTC, 1)},
			wantWinner: idB,
		},
		{
			name:           "equal source: the larger device_seq supersedes",
			incoming:       sync.Candidate{ClientEventID: idA, TimeSource: sync.TimeSourceServer, DeviceSeq: seq(50)},
			existing:       []sync.Candidate{stored("e1", idB, sync.TimeSourceServer, 10)},
			wantWins:       true,
			wantSupersedes: []string{"e1"},
		},
		{
			name:       "equal source: the smaller device_seq loses",
			incoming:   sync.Candidate{ClientEventID: idA, TimeSource: sync.TimeSourceServer, DeviceSeq: seq(10)},
			existing:   []sync.Candidate{stored("e1", idB, sync.TimeSourceServer, 50)},
			wantWinner: idB,
		},
		{
			name:           "a winner supersedes every stored event at that instant",
			incoming:       sync.Candidate{ClientEventID: idA, TimeSource: sync.TimeSourceELDRTC, DeviceSeq: seq(5)},
			existing:       []sync.Candidate{stored("e1", idB, sync.TimeSourcePhone, 1), stored("e2", idC, sync.TimeSourceServer, 2)},
			wantWins:       true,
			wantSupersedes: []string{"e1", "e2"},
		},
		{
			name:       "the best stored candidate is the one compared against",
			incoming:   sync.Candidate{ClientEventID: idA, TimeSource: sync.TimeSourceServer, DeviceSeq: seq(1)},
			existing:   []sync.Candidate{stored("e1", idB, sync.TimeSourcePhone, 1), stored("e2", idC, sync.TimeSourceELDRTC, 1)},
			wantWinner: idC,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got := sync.ResolveConflict(tc.incoming, tc.existing)
			if got.IncomingWins != tc.wantWins {
				t.Fatalf("IncomingWins = %v, want %v", got.IncomingWins, tc.wantWins)
			}
			if got.WinnerClientEventID != tc.wantWinner {
				t.Fatalf("winner = %q, want %q", got.WinnerClientEventID, tc.wantWinner)
			}
			// The stored id of the winner has to travel with it: the loser's
			// superseded_by column is set from it.
			if tc.wantWinner != "" && got.WinnerID == "" {
				t.Fatalf("a losing conflict must carry the winner's stored id: %+v", got)
			}
			if len(got.Supersedes) != len(tc.wantSupersedes) {
				t.Fatalf("supersedes = %v, want %v", got.Supersedes, tc.wantSupersedes)
			}
			for i, id := range tc.wantSupersedes {
				if got.Supersedes[i] != id {
					t.Fatalf("supersedes = %v, want %v", got.Supersedes, tc.wantSupersedes)
				}
			}
		})
	}
}

// --------------------------------------------------------------- push plan

func TestPlanPushRules(t *testing.T) {
	t.Parallel()

	locked := time.Date(2026, 9, 1, 8, 0, 0, 0, time.UTC)

	cases := []struct {
		name     string
		events   []sync.Event
		lookup   sync.Lookup
		want     []sync.Decision
		wantNorm func(*testing.T, []sync.Event)
	}{
		{
			name:   "a fresh event is accepted",
			events: []sync.Event{event()},
			want:   []sync.Decision{{ClientEventID: idA, Result: sync.ResultAccepted}},
		},
		{
			name:   "a stored client_event_id is a duplicate, not an error",
			events: []sync.Event{event()},
			lookup: sync.Lookup{Known: func(id string) bool { return id == idA }},
			want:   []sync.Decision{{ClientEventID: idA, Result: sync.ResultDuplicate}},
		},
		{
			name:   "the same client_event_id twice in one batch",
			events: []sync.Event{event(), event()},
			want: []sync.Decision{
				{ClientEventID: idA, Result: sync.ResultAccepted},
				{ClientEventID: idA, Result: sync.ResultDuplicate},
			},
		},
		{
			name:   "rule 3 — an event in the future is rejected",
			events: []sync.Event{event(func(e *sync.Event) { e.EventTime = now.Add(10 * time.Minute) })},
			want: []sync.Decision{{
				ClientEventID: idA, Result: sync.ResultRejected,
				Reason: sync.ReasonTimeInFuture, Field: "event_time",
			}},
		},
		{
			name:   "rule 5 — a certified day only accepts edit requests",
			events: []sync.Event{event(func(e *sync.Event) { e.EventTime = locked })},
			lookup: sync.Lookup{DayLocked: func(t time.Time) bool { return t.Equal(locked) }},
			want: []sync.Decision{{
				ClientEventID: idA, Result: sync.ResultRejected, Reason: sync.ReasonLogLocked,
			}},
		},
		{
			name:   "an invalid payload is rejected before the time window",
			events: []sync.Event{event(func(e *sync.Event) { e.Status = ""; e.EventTime = now.Add(time.Hour) })},
			want: []sync.Decision{{
				ClientEventID: idA, Result: sync.ResultRejected,
				Reason: sync.ReasonInvalidPayload, Field: "status",
			}},
		},
		{
			name:   "rule 1 — the incoming event supersedes the stored one",
			events: []sync.Event{event()},
			lookup: sync.Lookup{Existing: func(time.Time) []sync.Candidate {
				return []sync.Candidate{{ID: "e1", ClientEventID: idB, TimeSource: sync.TimeSourcePhone, DeviceSeq: seq(1)}}
			}},
			want: []sync.Decision{{
				ClientEventID: idA, Result: sync.ResultAccepted, Supersedes: []string{"e1"},
			}},
		},
		{
			name:   "rule 1 — the loser is still stored, flagged superseded",
			events: []sync.Event{event(func(e *sync.Event) { e.TimeSource = sync.TimeSourcePhone })},
			lookup: sync.Lookup{Existing: func(time.Time) []sync.Candidate {
				return []sync.Candidate{{ID: "e1", ClientEventID: idB, TimeSource: sync.TimeSourceELDRTC, DeviceSeq: seq(1)}}
			}},
			want: []sync.Decision{{
				ClientEventID: idA, Result: sync.ResultAccepted,
				Reason: sync.ReasonSuperseded, SupersededBy: idB, SupersededByID: "e1",
			}},
		},
		{
			name: "conflict resolution does not touch positional events",
			events: []sync.Event{event(func(e *sync.Event) {
				e.EventType = sync.EventIntermediate
				e.TimeSource = sync.TimeSourcePhone
			})},
			lookup: sync.Lookup{Existing: func(time.Time) []sync.Candidate {
				return []sync.Candidate{{ID: "e1", ClientEventID: idB, TimeSource: sync.TimeSourceELDRTC}}
			}},
			want: []sync.Decision{{ClientEventID: idA, Result: sync.ResultAccepted}},
		},
		{
			name:   "normalization fills the storage defaults",
			events: []sync.Event{event(func(e *sync.Event) { e.Special = ""; e.Origin = ""; e.Notes = "  Pickup  " })},
			want:   []sync.Decision{{ClientEventID: idA, Result: sync.ResultAccepted}},
			wantNorm: func(t *testing.T, evs []sync.Event) {
				t.Helper()
				got := evs[0]
				if got.EventType != sync.EventDutyStatus {
					t.Fatalf("event_type = %q, want duty_status", got.EventType)
				}
				if got.Special != sync.SpecialNone || got.Origin != sync.OriginAuto {
					t.Fatalf("special/origin = %q/%q", got.Special, got.Origin)
				}
				if got.Notes != "Pickup" {
					t.Fatalf("notes = %q", got.Notes)
				}
			},
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			p, err := sync.PlanPush(sync.Batch{
				Events: tc.events,
				Clock:  sync.Clock{Phone: now, ELDRTC: now},
			}, now, tc.lookup)
			if err != nil {
				t.Fatalf("PlanPush: %v", err)
			}
			if len(p.Events) != len(tc.want) {
				t.Fatalf("got %d decisions, want %d", len(p.Events), len(tc.want))
			}
			for i, want := range tc.want {
				requireDecision(t, p.Events[i], want)
			}
			if tc.wantNorm != nil {
				tc.wantNorm(t, p.Normalized)
			}
		})
	}
}

// A superseded event is still written: the plan keeps its normalized row.
func TestPlanPushKeepsTheSupersededEvent(t *testing.T) {
	t.Parallel()
	p, err := sync.PlanPush(sync.Batch{
		Events: []sync.Event{event(func(e *sync.Event) { e.TimeSource = sync.TimeSourcePhone })},
	}, now, sync.Lookup{Existing: func(time.Time) []sync.Candidate {
		return []sync.Candidate{{ID: "e1", ClientEventID: idB, TimeSource: sync.TimeSourceELDRTC}}
	}})
	if err != nil {
		t.Fatalf("PlanPush: %v", err)
	}
	if !p.Events[0].Accepted() {
		t.Fatalf("the loser must still be accepted for storage: %+v", p.Events[0])
	}
	if p.Normalized[0].ClientEventID != idA {
		t.Fatalf("normalized event missing: %+v", p.Normalized[0])
	}
}

func requireDecision(t *testing.T, got, want sync.Decision) {
	t.Helper()
	if got.Result != want.Result || got.Reason != want.Reason || got.Field != want.Field ||
		got.SupersededBy != want.SupersededBy || got.SupersededByID != want.SupersededByID ||
		len(got.Supersedes) != len(want.Supersedes) {
		t.Fatalf("got %+v, want %+v", got, want)
	}
	for i := range want.Supersedes {
		if got.Supersedes[i] != want.Supersedes[i] {
			t.Fatalf("got %+v, want %+v", got, want)
		}
	}
}

// ---------------------------------------------------------------- telemetry

func TestPlanTelemetry(t *testing.T) {
	t.Parallel()

	pt := func(offset time.Duration, mut ...func(*sync.TelemetryPoint)) sync.TelemetryPoint {
		p := sync.TelemetryPoint{TS: now.Add(offset), Lat: f64(31.52), Lng: f64(74.35), SpeedKmh: f64(62)}
		for _, m := range mut {
			m(&p)
		}
		return p
	}

	cases := []struct {
		name          string
		points        []sync.TelemetryPoint
		wantAccepted  int
		wantDuplicate int
		wantRejected  int
	}{
		{name: "empty batch"},
		{name: "three distinct samples", points: []sync.TelemetryPoint{pt(-3 * time.Minute), pt(-2 * time.Minute), pt(-time.Minute)}, wantAccepted: 3},
		{
			name:          "rule 4 — a repeated ts is ignored, not an error",
			points:        []sync.TelemetryPoint{pt(-time.Minute), pt(-time.Minute)},
			wantAccepted:  1,
			wantDuplicate: 1,
		},
		{
			name:         "a sample in the future is dropped",
			points:       []sync.TelemetryPoint{pt(10 * time.Minute)},
			wantRejected: 1,
		},
		{
			name:         "a zero timestamp is dropped",
			points:       []sync.TelemetryPoint{{}},
			wantRejected: 1,
		},
		{
			name:         "an impossible coordinate is dropped",
			points:       []sync.TelemetryPoint{pt(-time.Minute, func(p *sync.TelemetryPoint) { p.Lat = f64(120) })},
			wantRejected: 1,
		},
		{
			name:         "an impossible speed is dropped",
			points:       []sync.TelemetryPoint{pt(-time.Minute, func(p *sync.TelemetryPoint) { p.SpeedKmh = f64(999) })},
			wantRejected: 1,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got := sync.PlanTelemetry(tc.points, now)
			if len(got.Points) != tc.wantAccepted || got.Duplicate != tc.wantDuplicate || got.Rejected != tc.wantRejected {
				t.Fatalf("got accepted=%d duplicate=%d rejected=%d, want %d/%d/%d",
					len(got.Points), got.Duplicate, got.Rejected,
					tc.wantAccepted, tc.wantDuplicate, tc.wantRejected)
			}
		})
	}
}

func TestPlanTelemetryOrdersByTimestamp(t *testing.T) {
	t.Parallel()
	got := sync.PlanTelemetry([]sync.TelemetryPoint{
		{TS: now.Add(-time.Minute)},
		{TS: now.Add(-3 * time.Minute)},
		{TS: now.Add(-2 * time.Minute)},
	}, now)
	for i := 1; i < len(got.Points); i++ {
		if got.Points[i].TS.Before(got.Points[i-1].TS) {
			t.Fatalf("points are not ordered: %v", got.Points)
		}
	}
}
