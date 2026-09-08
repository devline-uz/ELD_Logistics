// Security regression: /sync/push may not let a device declare a server side
// origin. `driver_edit`, `admin_edit` and `assigned` are written by the log
// edit approval path and by the §10.4 unidentified hand over alone; a device
// that could claim them would forge the provenance of an FMCSA record and,
// because none of the three is `auto`, escape the Q17.1 DR_IMMUTABLE guard.
package sync_test

import (
	"testing"

	sync "github.com/devline/onebook-eld/internal/sync"
)

func TestDeviceMayNotDeclareServerSideOrigin(t *testing.T) {
	t.Parallel()

	cases := []struct {
		origin  string
		allowed bool
	}{
		{"", true},
		{sync.OriginAuto, true},
		{sync.OriginDriver, true},
		{sync.OriginManualNoELD, true},
		{sync.OriginDriverEdit, false},
		{sync.OriginAdminEdit, false},
		{sync.OriginAssigned, false},
		{"root", false},
	}

	for _, tc := range cases {
		t.Run("origin="+tc.origin, func(t *testing.T) {
			if got := sync.ValidDeviceOrigin(tc.origin); got != tc.allowed {
				t.Fatalf("ValidDeviceOrigin(%q) = %v, want %v", tc.origin, got, tc.allowed)
			}

			ev := sync.Event{
				ClientEventID: "11111111-1111-4111-8111-111111111111",
				EventType:     sync.EventDutyStatus,
				Status:        sync.StatusOn,
				Origin:        tc.origin,
				EventTime:     now,
			}
			f := sync.ValidateEvent(ev, now)
			if tc.allowed && f.Reason != "" {
				t.Fatalf("origin %q must be accepted, got %+v", tc.origin, f)
			}
			if !tc.allowed && (f.Field != "origin" || f.Reason != sync.ReasonInvalidPayload) {
				t.Fatalf("origin %q must be rejected as invalid_payload, got %+v", tc.origin, f)
			}
		})
	}
}

// A hand entered DR is refused by Q4 only when its origin is one of the manual
// ones. `assigned` is not, so it used to be a way to upload driving time that
// the server then treated as neither manual nor automatic. The push layer now
// refuses the origin outright, before the duty rules ever see the event.
func TestAssignedOriginCannotSmuggleManualDriving(t *testing.T) {
	t.Parallel()

	ev := sync.Event{
		ClientEventID: "22222222-2222-4222-8222-222222222222",
		EventType:     sync.EventDutyStatus,
		Status:        sync.StatusDrive,
		Origin:        sync.OriginAssigned,
		EventTime:     now,
	}
	plan, err := sync.PlanPush(sync.Batch{Events: []sync.Event{ev}}, now, sync.Lookup{})
	if err != nil {
		t.Fatalf("PlanPush: %v", err)
	}
	d := plan.Events[0]
	if d.Result != sync.ResultRejected || d.Reason != sync.ReasonInvalidPayload {
		t.Fatalf("want rejected(invalid_payload), got %+v", d)
	}
}
