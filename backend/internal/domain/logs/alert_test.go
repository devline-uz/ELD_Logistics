//go:build integration

// Regression coverage for TZ A§5.3: an admin proposal notifies the driver and
// an approve/reject notifies the requesting admin.
package logs_test

import (
	"context"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/duty"
	"github.com/devline/onebook-eld/internal/domain/logs"
	"github.com/devline/onebook-eld/internal/testutil"
)

// fakeAlerter records every alert so a test can assert on it without wiring
// internal/notify.
type fakeAlerter struct {
	mu     sync.Mutex
	kinds  []string
	alerts []logs.Alert
}

func (f *fakeAlerter) Alert(_ context.Context, kind string, a logs.Alert) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.kinds = append(f.kinds, kind)
	f.alerts = append(f.alerts, a)
	return nil
}

func (f *fakeAlerter) calls() ([]string, []logs.Alert) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]string(nil), f.kinds...), append([]logs.Alert(nil), f.alerts...)
}

// newAlertServer is newServer plus a fake Alerter, so a case can assert on the
// TZ A§5.3 notifications without touching internal/notify.
func newAlertServer(t testing.TB, alerter logs.Alerter) *testutil.TestServer {
	t.Helper()
	pool := testutil.NewDB(t)
	nowFn := func() time.Time { return now }

	dutyMod := duty.New(duty.Deps{
		Repo:     duty.NewRepo(pool, nil),
		Verifier: testutil.ContextVerifier(),
		Now:      nowFn,
	})
	tokens, err := core.NewTokenService("test-secret-test-secret-test-secret-32", time.Hour)
	require.NoError(t, err)

	return testutil.NewServer(t, logs.New(logs.Deps{
		Repo:     logs.NewRepo(pool, nil),
		Duty:     dutyMod.Service(),
		Verifier: testutil.ContextVerifier(),
		Now:      nowFn,
		Tokens:   tokens,
		Alerter:  alerter,
	}))
}

// TZ A§5.3: an admin proposal must notify the driver.
func TestCreateEditRequestAlertsTheDriver(t *testing.T) {
	t.Parallel()
	fa := &fakeAlerter{}
	srv := newAlertServer(t, fa)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(6*time.Hour), "ON", "auto")

	resp := srv.AsTenant(tn).Post("/api/v1/log-edit-requests", map[string]any{
		"driver_id":    c.Driver.ID.String(),
		"daily_log_id": c.Log.ID.String(),
		"changes": []map[string]any{{
			"from":   dayStart().Add(8 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(9 * time.Hour).Format(time.RFC3339),
			"status": "SB", "note": "matches the dispatch note",
		}},
	})
	testutil.RequireStatus(t, resp, 201)

	kinds, alerts := fa.calls()
	require.Contains(t, kinds, logs.AlertLogEditRequested)
	require.Equal(t, c.Driver.ID, alerts[0].DriverID)
	require.NotEmpty(t, alerts[0].Message)
}

// TZ A§5.3: approving a proposal notifies the requesting admin.
func TestApproveEditAlertsTheAdmin(t *testing.T) {
	t.Parallel()
	fa := &fakeAlerter{}
	srv := newAlertServer(t, fa)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(6*time.Hour), "ON", "auto")

	created := decodeEditRequest(t, srv.AsTenant(tn).Post("/api/v1/log-edit-requests", map[string]any{
		"driver_id":    c.Driver.ID.String(),
		"daily_log_id": c.Log.ID.String(),
		"changes": []map[string]any{{
			"from":   dayStart().Add(8 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(9 * time.Hour).Format(time.RFC3339),
			"status": "SB", "note": "matches the dispatch note",
		}},
	}))

	resp := srv.AsPrincipal(c.driver(tn)).Post("/api/v1/log-edit-requests/"+created.ID+"/approve", nil)
	testutil.RequireStatus(t, resp, 200)

	kinds, alerts := fa.calls()
	require.Contains(t, kinds, logs.AlertLogEditResolved)
	last := alerts[len(alerts)-1]
	require.Equal(t, "approved", last.Status)
}

// TZ A§5.3: rejecting a proposal notifies the requesting admin.
func TestRejectEditAlertsTheAdmin(t *testing.T) {
	t.Parallel()
	fa := &fakeAlerter{}
	srv := newAlertServer(t, fa)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	seedEvent(t, tn, c, dayStart().Add(6*time.Hour), "ON", "auto")

	created := decodeEditRequest(t, srv.AsTenant(tn).Post("/api/v1/log-edit-requests", map[string]any{
		"driver_id":    c.Driver.ID.String(),
		"daily_log_id": c.Log.ID.String(),
		"changes": []map[string]any{{
			"from":   dayStart().Add(8 * time.Hour).Format(time.RFC3339),
			"to":     dayStart().Add(9 * time.Hour).Format(time.RFC3339),
			"status": "SB", "note": "matches the dispatch note",
		}},
	}))

	resp := srv.AsPrincipal(c.driver(tn)).Post("/api/v1/log-edit-requests/"+created.ID+"/reject",
		map[string]any{"reason": "wrong shift"})
	testutil.RequireStatus(t, resp, 200)

	kinds, alerts := fa.calls()
	require.Contains(t, kinds, logs.AlertLogEditResolved)
	last := alerts[len(alerts)-1]
	require.Equal(t, "rejected", last.Status)
}

// TZ A§5.3: proposing an unidentified assignment also notifies the driver.
func TestAssignUnidentifiedAlertsTheDriver(t *testing.T) {
	t.Parallel()
	fa := &fakeAlerter{}
	srv := newAlertServer(t, fa)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	from := dayStart().Add(14 * time.Hour)
	block := seedBlock(t, tn, from, from.Add(40*time.Minute))

	resp := srv.AsTenant(tn).Post("/api/v1/unidentified-events/"+block.String()+"/assign",
		map[string]any{"driver_id": c.Driver.ID.String(), "note": "matches your dispatch"})
	testutil.RequireStatus(t, resp, 201)

	kinds, alerts := fa.calls()
	require.Contains(t, kinds, logs.AlertLogEditRequested)
	require.Equal(t, c.Driver.ID, alerts[0].DriverID)
}
