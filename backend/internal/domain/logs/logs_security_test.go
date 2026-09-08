//go:build integration

// Security regressions of stage 4: the `self` scope must bind every violation
// and log-edit route to the caller's own driver, not only the list endpoints.
package logs_test

import (
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

// A Driver holds `violations.read`, so GET /violations/{id} used to hand it
// any violation of the company by id. The self scope now applies to the detail
// route as well and a foreign row answers 404, never 403.
func TestViolationDetailIsScopedToSelf(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	mine, other := seedCrew(t, tn), seedCrew(t, tn)

	for _, c := range []crew{mine, other} {
		seedEvent(t, tn, c, dayStart(), "DR", "auto")
		seedEvent(t, tn, c, dayStart().Add(12*time.Hour), "OFF", "auto")
		testutil.RequireStatus(t, certify(t, srv, tn, c), 200)
	}

	all := decodeViolations(t, srv.AsTenant(tn).Get("/api/v1/violations"))
	require.NotEmpty(t, all)
	var minesID, othersID string
	for _, v := range all {
		switch {
		case v.DriverID != nil && *v.DriverID == mine.Driver.ID.String():
			minesID = v.ID
		case v.DriverID != nil && *v.DriverID == other.Driver.ID.String():
			othersID = v.ID
		}
	}
	require.NotEmpty(t, minesID)
	require.NotEmpty(t, othersID)

	as := srv.AsPrincipal(mine.driver(tn))
	testutil.RequireStatus(t, as.Get("/api/v1/violations/"+minesID), 200)
	testutil.RequireStatusCode(t, as.Get("/api/v1/violations/"+othersID), 404, "NOT_FOUND")

	// The list stays narrowed to the caller's own rows.
	rows := decodeViolations(t, as.Get("/api/v1/violations"))
	for _, v := range rows {
		require.NotNil(t, v.DriverID)
		require.Equal(t, mine.Driver.ID.String(), *v.DriverID,
			"a self scoped caller never sees another driver's violation")
	}
	// Even an explicit driver_id filter cannot widen it.
	rows = decodeViolations(t, as.Get("/api/v1/violations",
		testutil.Query("driver_id", other.Driver.ID.String())))
	for _, v := range rows {
		require.NotNil(t, v.DriverID)
		require.Equal(t, mine.Driver.ID.String(), *v.DriverID)
	}
}

// A Driver also holds `logs.propose_edit`. The proposal is a write against a
// log day, so it must obey the same scope as the read path: proposing on
// another driver's day answers 404.
func TestEditProposalIsScopedToSelf(t *testing.T) {
	t.Parallel()
	srv := newServer(t)
	tn := testutil.SeedTenant(t, allPerms...)
	mine, other := seedCrew(t, tn), seedCrew(t, tn)
	seedEvent(t, tn, other, dayStart(), "ON", "driver")

	body := func(c crew) dto.LogEditRequestCreate {
		return dto.LogEditRequestCreate{
			DriverID:   c.Driver.ID.String(),
			DailyLogID: c.Log.ID.String(),
			Changes: []dto.LogEditChange{{
				From: dayStart().Add(time.Hour), To: dayStart().Add(2 * time.Hour),
				Status: "ON", Special: "none", Note: "corrected by the driver",
			}},
		}
	}

	as := srv.AsPrincipal(mine.driver(tn))
	testutil.RequireStatusCode(t,
		as.Post("/api/v1/log-edit-requests", body(other)), 404, "NOT_FOUND")
	testutil.RequireStatus(t,
		as.Post("/api/v1/log-edit-requests", body(mine)), 201)
}
