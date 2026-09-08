//go:build integration

// Regression coverage for the §10.4 assignment atomicity fix: the
// log_edit_requests insert and the unidentified_events status flip must land
// in a single transaction, never two.
package logs_test

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/domain/logs"
	"github.com/devline/onebook-eld/internal/testutil"
)

// TestAssignUnidentifiedRollsBackOnMidTransactionFailure reproduces the bug
// that motivated the fix: the request and the status flip used to run in two
// separate transactions, so a failure of the second (here: a driver id that
// does not exist, violating the FK on assigned_driver_id) used to leave a
// `pending` log_edit_requests row behind a block that never reached
// `proposed`. With both writes sharing one transaction, the whole attempt
// rolls back and neither row is left behind.
func TestAssignUnidentifiedRollsBackOnMidTransactionFailure(t *testing.T) {
	t.Parallel()
	pool := testutil.NewDB(t)
	tn := testutil.SeedTenant(t, allPerms...)
	c := seedCrew(t, tn)
	from := dayStart().Add(14 * time.Hour)
	block := seedBlock(t, tn, from, from.Add(20*time.Minute))

	repo := logs.NewRepo(pool, nil)
	req := logs.EditRequest{
		CompanyID: tn.ID(), DriverID: c.Driver.ID, DailyLogID: c.Log.ID,
		RequestedBy: c.User.ID, Source: "unidentified_assign",
		Changes: []byte(`[]`), UnidentifiedEventID: &block,
		LogDate: logDay, Timezone: "America/Chicago",
	}
	// A driver id that does not exist: the log_edit_requests insert (first
	// write) succeeds because it references the real c.Driver.ID, but the
	// unidentified_events update (second write) fails its FK on
	// assigned_driver_id — the exact "non-existent driver" mid-transaction
	// failure the task calls out.
	bogusDriver := uuid.New()

	_, err := repo.CreateAssignmentRequest(testutil.Ctx(t), req, block, bogusDriver, c.User.ID, nil, nil)
	require.Error(t, err)

	count := scalar[int64](t, `SELECT count(*) FROM log_edit_requests WHERE unidentified_event_id = $1`, block)
	require.Equal(t, int64(0), count, "the failed second write must roll back the first")

	status := scalar[string](t, `SELECT status FROM unidentified_events WHERE id = $1`, block)
	require.Equal(t, "pending", status, "the block must remain untouched")
}
