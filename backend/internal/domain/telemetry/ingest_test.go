//go:build integration

// Integration coverage of the telemetry ingestion pipeline against a real
// TimescaleDB: batch writes and duplicate handling, trip segmentation, the
// unit_last_state upsert, the unidentified driving buffer, ELD malfunction
// bookkeeping and the periodic offline sweep.
package telemetry_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/domain/telemetry"
	"github.com/devline/onebook-eld/internal/domain/telemetry/dto"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

type harness struct {
	svc     *telemetry.Service
	store   cache.Store
	objects *storage.MemoryPutter
	now     time.Time
}

func newHarness(t testing.TB) *harness {
	t.Helper()
	pool := testutil.NewDB(t)
	h := &harness{
		store:   cache.NewMemoryStore(),
		objects: storage.NewMemoryPutter(),
		now:     time.Now().UTC(),
	}
	h.svc = telemetry.New(telemetry.Deps{
		Repo:    telemetry.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger())),
		Store:   h.store,
		Objects: h.objects,
		Now:     func() time.Time { return h.now },
		Log:     testutil.Logger(),
	})
	return h
}

func ctxFor(t testing.TB, tn *testutil.Tenant) context.Context {
	t.Helper()
	return tenant.WithCompanyID(testutil.Ctx(t), tn.ID())
}

// batch builds an ingestion payload for the tenant's unit.
func batch(tn *testutil.Tenant, points ...dto.Point) dto.Batch {
	return dto.Batch{UnitID: tn.Unit.ID.String(), Source: dto.SourceELD, Points: points}
}

func point(at time.Time, lat, lng float64, ignition bool) dto.Point {
	return dto.Point{TS: at, Lat: f(lat), Lng: f(lng), Ignition: b(ignition), SpeedKmh: f(0)}
}

func TestIngestWritesBatchAndIgnoresDuplicates(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	ctx := ctxFor(t, tn)
	start := h.now.Add(-time.Hour).Truncate(time.Second)

	in := batch(tn,
		point(start, 31.50, 74.30, true),
		point(start.Add(30*time.Second), 31.51, 74.31, true),
		point(start.Add(60*time.Second), 31.52, 74.32, true),
	)
	res, err := h.svc.Ingest(ctx, in)
	require.NoError(t, err)
	require.Equal(t, 3, res.Accepted)
	require.Equal(t, 0, res.Duplicate)
	require.Equal(t, 3, telemetryRows(t, tn.Unit.ID))

	// Q: a repeated (unit_id, ts) is silently ignored, never an error.
	again, err := h.svc.Ingest(ctx, in)
	require.NoError(t, err)
	require.Equal(t, 0, again.Accepted)
	require.Equal(t, 3, again.Duplicate)
	require.Equal(t, 3, telemetryRows(t, tn.Unit.ID))
}

func TestIngestDeduplicatesInsideOneBatch(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	start := h.now.Add(-time.Hour).Truncate(time.Second)

	res, err := h.svc.Ingest(ctxFor(t, tn), batch(tn,
		point(start, 31.50, 74.30, true),
		point(start, 31.50, 74.30, true),
	))
	require.NoError(t, err)
	require.Equal(t, 1, res.Accepted)
	require.Equal(t, 1, telemetryRows(t, tn.Unit.ID))
}

func TestIngestRejectsOversizedBatch(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	start := h.now.Add(-24 * time.Hour).Truncate(time.Second)

	points := make([]dto.Point, dto.MaxBatchPoints+1)
	for i := range points {
		points[i] = point(start.Add(time.Duration(i)*time.Second), 31.5, 74.3, true)
	}
	_, err := h.svc.Ingest(ctxFor(t, tn), batch(tn, points...))
	require.True(t, apierr.Is(err, apierr.CodeBatchTooLarge), "want BATCH_TOO_LARGE, got %v", err)
}

func TestIngestRejectsCrossTenantUnitWith404(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	a, other := testutil.SeedTwoCompanies(t)
	start := h.now.Add(-time.Hour).Truncate(time.Second)

	in := batch(other, point(start, 31.5, 74.3, true))
	_, err := h.svc.Ingest(ctxFor(t, a), in)
	require.True(t, apierr.Is(err, apierr.CodeNotFound), "cross-tenant must be 404, got %v", err)
	require.Equal(t, 0, telemetryRows(t, other.Unit.ID))
}

func TestIngestUpsertsUnitLastStateAndCache(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	ctx := ctxFor(t, tn)
	start := h.now.Add(-2 * time.Minute).Truncate(time.Second)

	_, err := h.svc.Ingest(ctx, batch(tn,
		point(start, 31.50, 74.30, true),
		dto.Point{TS: start.Add(time.Minute), Lat: f(31.55), Lng: f(74.35), Ignition: b(true),
			SpeedKmh: f(62.5), OdometerM: i(128430000), DutyStatus: "DR"},
	))
	require.NoError(t, err)

	state := lastState(t, tn.Unit.ID)
	require.Equal(t, start.Add(time.Minute).UTC(), state.ts.UTC(), "the newest sample must win")
	require.InDelta(t, 31.55, state.lat, 1e-9)
	require.EqualValues(t, 128430000, state.odometer)
	require.Equal(t, "DR", state.dutyStatus)
	require.Equal(t, telemetry.StatusOnline, state.online)

	cached, ok, err := h.store.Get(ctx, telemetry.LastStateKey(tn.Unit.ID))
	require.NoError(t, err)
	require.True(t, ok, "the live map mirror unit:last:<id> must be written")
	require.Contains(t, cached, tn.Unit.ID.String())

	// An out of order batch must never move the state backwards.
	_, err = h.svc.Ingest(ctx, batch(tn, point(start.Add(-time.Hour), 10, 10, true)))
	require.NoError(t, err)
	require.Equal(t, start.Add(time.Minute).UTC(), lastState(t, tn.Unit.ID).ts.UTC())
}

func TestIngestStaleBatchIsMarkedOffline(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	old := h.now.Add(-30 * time.Minute).Truncate(time.Second)

	res, err := h.svc.Ingest(ctxFor(t, tn), batch(tn, point(old, 31.5, 74.3, false)))
	require.NoError(t, err)
	require.Equal(t, telemetry.StatusOffline, res.OnlineStatus)
	require.Equal(t, telemetry.StatusOffline, lastState(t, tn.Unit.ID).online)
}

func TestIngestReportsDisconnectedState(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	at := h.now.Add(-time.Minute).Truncate(time.Second)

	res, err := h.svc.Ingest(ctxFor(t, tn), batch(tn,
		dto.Point{TS: at, Lat: f(31.5), Lng: f(74.3), Ignition: b(false), Disconnected: true}))
	require.NoError(t, err)
	require.Equal(t, telemetry.StatusDisconnected, res.OnlineStatus)
	require.Equal(t, telemetry.StatusDisconnected, lastState(t, tn.Unit.ID).online)
}

func TestTripClosesOnIgnitionOffWithDistanceAndPolyline(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	start := h.now.Add(-time.Hour).Truncate(time.Second)

	res, err := h.svc.Ingest(ctxFor(t, tn), batch(tn,
		dto.Point{TS: start, Lat: f(31.50), Lng: f(74.30), Ignition: b(true), SpeedKmh: f(10), OdometerM: i(1_000_000)},
		dto.Point{TS: start.Add(5 * time.Minute), Lat: f(31.60), Lng: f(74.40), Ignition: b(true), SpeedKmh: f(88), OdometerM: i(1_014_000)},
		dto.Point{TS: start.Add(10 * time.Minute), Lat: f(31.70), Lng: f(74.50), Ignition: b(false), SpeedKmh: f(0), OdometerM: i(1_028_000)},
	))
	require.NoError(t, err)
	require.Equal(t, 1, res.TripsOpened)
	require.Equal(t, 1, res.TripsClosed)

	trips := listTrips(t, tn.Unit.ID)
	require.Len(t, trips, 1)
	trip := trips[0]
	require.Equal(t, start.UTC(), trip.startAt.UTC())
	require.NotNil(t, trip.endAt)
	require.Equal(t, start.Add(10*time.Minute).UTC(), trip.endAt.UTC())
	// Q61/Q62: the ECM odometer wins over the GPS estimate.
	require.EqualValues(t, 28000, trip.distanceM)
	require.EqualValues(t, 600, *trip.durationSec)
	require.InDelta(t, 88, *trip.maxSpeed, 1e-9)

	require.NotNil(t, trip.polylineKey, "a closed trip stores its track in object storage")
	body, ok := h.objects.Object(*trip.polylineKey)
	require.True(t, ok)
	require.NotEmpty(t, body)
}

func TestTripSplitsOnFifteenMinuteStop(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	start := h.now.Add(-2 * time.Hour).Truncate(time.Second)

	// No ignition-off arrives: only the 15 minute silence ends the first trip.
	res, err := h.svc.Ingest(ctxFor(t, tn), batch(tn,
		point(start, 31.50, 74.30, true),
		point(start.Add(2*time.Minute), 31.55, 74.35, true),
		point(start.Add(25*time.Minute), 31.90, 74.70, true),
		point(start.Add(27*time.Minute), 31.95, 74.75, true),
	))
	require.NoError(t, err)
	require.Equal(t, 2, res.TripsOpened)
	require.Equal(t, 1, res.TripsClosed)

	trips := listTrips(t, tn.Unit.ID)
	require.Len(t, trips, 2)
	require.NotNil(t, trips[0].endAt)
	require.Equal(t, start.Add(2*time.Minute).UTC(), trips[0].endAt.UTC())
	require.Nil(t, trips[1].endAt, "the second trip is still running")
	require.Equal(t, start.Add(25*time.Minute).UTC(), trips[1].startAt.UTC())
}

func TestTripContinuesAcrossBatches(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	ctx := ctxFor(t, tn)
	start := h.now.Add(-time.Hour).Truncate(time.Second)

	_, err := h.svc.Ingest(ctx, batch(tn, point(start, 31.50, 74.30, true)))
	require.NoError(t, err)
	res, err := h.svc.Ingest(ctx, batch(tn,
		point(start.Add(time.Minute), 31.55, 74.35, true),
		point(start.Add(2*time.Minute), 31.60, 74.40, false),
	))
	require.NoError(t, err)
	require.Equal(t, 0, res.TripsOpened, "the open trip must be extended, not duplicated")
	require.Equal(t, 1, res.TripsClosed)

	trips := listTrips(t, tn.Unit.ID)
	require.Len(t, trips, 1)
	require.Equal(t, start.UTC(), trips[0].startAt.UTC())
	require.Greater(t, trips[0].distanceM, int64(0), "distance accrues across batches")
	require.EqualValues(t, 120, *trips[0].durationSec, "duration measures from the stored trip start")
}

func TestUnidentifiedBufferOpensAndClosesOnDriverLogin(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	ctx := ctxFor(t, tn)
	start := h.now.Add(-time.Hour).Truncate(time.Second)

	// A§10.4: driving with driver_id NULL buffers an unidentified event.
	res, err := h.svc.Ingest(ctx, batch(tn,
		dto.Point{TS: start, Lat: f(31.50), Lng: f(74.30), Ignition: b(true), OdometerM: i(2_000_000)},
		dto.Point{TS: start.Add(5 * time.Minute), Lat: f(31.60), Lng: f(74.40), Ignition: b(true), OdometerM: i(2_009_000)},
	))
	require.NoError(t, err)
	require.Equal(t, 1, res.UnidentifiedOpened)
	require.Equal(t, 0, res.UnidentifiedClosed)

	open := listUnidentified(t, tn.Unit.ID)
	require.Len(t, open, 1)
	require.Nil(t, open[0].endAt)
	require.Equal(t, "pending", open[0].status)
	require.EqualValues(t, 9000, open[0].distanceM)

	// The driver logs in: the buffer closes, the trip keeps running.
	driverID := tn.Driver.ID.String()
	res, err = h.svc.Ingest(ctx, dto.Batch{UnitID: tn.Unit.ID.String(), Points: []dto.Point{
		{TS: start.Add(10 * time.Minute), Lat: f(31.70), Lng: f(74.50), Ignition: b(true),
			OdometerM: i(2_018_000), DriverID: &driverID},
	}})
	require.NoError(t, err)
	require.Equal(t, 0, res.UnidentifiedOpened)
	require.Equal(t, 1, res.UnidentifiedClosed)

	closed := listUnidentified(t, tn.Unit.ID)
	require.Len(t, closed, 1)
	require.NotNil(t, closed[0].endAt)
	require.Equal(t, start.Add(10*time.Minute).UTC(), closed[0].endAt.UTC())
	require.EqualValues(t, 18000, closed[0].distanceM)
	require.Equal(t, "pending", closed[0].status, "closing the buffer must not resolve it")
}

func TestIdentifiedDrivingNeverBuffers(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	start := h.now.Add(-time.Hour).Truncate(time.Second)
	driverID := tn.Driver.ID.String()

	res, err := h.svc.Ingest(ctxFor(t, tn), dto.Batch{UnitID: tn.Unit.ID.String(), Points: []dto.Point{
		{TS: start, Lat: f(31.50), Lng: f(74.30), Ignition: b(true), DriverID: &driverID},
		{TS: start.Add(time.Minute), Lat: f(31.55), Lng: f(74.35), Ignition: b(true), DriverID: &driverID},
	}})
	require.NoError(t, err)
	require.Equal(t, 0, res.UnidentifiedOpened)
	require.Empty(t, listUnidentified(t, tn.Unit.ID))
}

func TestDiagnosticsDriveEldStatusAndAudit(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	ctx := ctxFor(t, tn)
	at := h.now.Add(-time.Minute).Truncate(time.Second)

	// §10.5: an Appendix A code moves the device into malfunction.
	_, err := h.svc.Ingest(ctx, dto.Batch{UnitID: tn.Unit.ID.String(), Points: []dto.Point{
		{TS: at, Lat: f(31.5), Lng: f(74.3), Ignition: b(true), Diagnostics: []string{"L", "T"}},
	}})
	require.NoError(t, err)

	status, codes := deviceHealth(t, tn.Device.ID)
	require.Equal(t, "malfunction", status)
	require.Equal(t, []string{"T", "L"}, codes, "codes are stored in Appendix A order")
	require.Greater(t, auditRows(t, tn.Device.ID), 0, "an ELD status change is audited")

	// An empty array clears the codes; silence would not.
	_, err = h.svc.Ingest(ctx, dto.Batch{UnitID: tn.Unit.ID.String(), Points: []dto.Point{
		{TS: at.Add(time.Second), Lat: f(31.5), Lng: f(74.3), Ignition: b(true), Diagnostics: []string{}},
	}})
	require.NoError(t, err)
	status, codes = deviceHealth(t, tn.Device.ID)
	require.Equal(t, "active", status)
	require.Empty(t, codes)
}

func TestSilenceNeverClearsMalfunctionCodes(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	ctx := ctxFor(t, tn)
	at := h.now.Add(-time.Minute).Truncate(time.Second)

	_, err := h.svc.Ingest(ctx, dto.Batch{UnitID: tn.Unit.ID.String(), Points: []dto.Point{
		{TS: at, Ignition: b(true), Diagnostics: []string{"P"}},
	}})
	require.NoError(t, err)
	_, err = h.svc.Ingest(ctx, dto.Batch{UnitID: tn.Unit.ID.String(), Points: []dto.Point{
		{TS: at.Add(time.Second), Ignition: b(true)},
	}})
	require.NoError(t, err)

	status, codes := deviceHealth(t, tn.Device.ID)
	require.Equal(t, "malfunction", status)
	require.Equal(t, []string{"P"}, codes)
}

func TestMarkStaleOfflineDemotesSilentUnits(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t)
	ctx := ctxFor(t, tn)

	// A fresh sample (now) keeps the unit online...
	_, err := h.svc.Ingest(ctx, batch(tn, point(h.now.Truncate(time.Second), 31.5, 74.3, true)))
	require.NoError(t, err)
	require.Equal(t, telemetry.StatusOnline, lastState(t, tn.Unit.ID).online)

	n, err := h.svc.MarkStaleOffline(ctx, telemetry.StaleThresholdMinutes)
	require.NoError(t, err)
	require.EqualValues(t, 0, n)
	require.Equal(t, telemetry.StatusOnline, lastState(t, tn.Unit.ID).online)

	// ...until the sweep runs with a window the sample no longer fits into.
	backdateLastState(t, tn.Unit.ID, -10*time.Minute)
	n, err = h.svc.MarkStaleOffline(ctx, telemetry.StaleThresholdMinutes)
	require.NoError(t, err)
	require.EqualValues(t, 1, n)
	require.Equal(t, telemetry.StatusOffline, lastState(t, tn.Unit.ID).online)
}

func TestMarkStaleOfflineIsTenantScoped(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	a, other := testutil.SeedTwoCompanies(t)

	for _, tn := range []*testutil.Tenant{a, other} {
		_, err := h.svc.Ingest(ctxFor(t, tn), batch(tn, point(h.now.Truncate(time.Second), 31.5, 74.3, true)))
		require.NoError(t, err)
		backdateLastState(t, tn.Unit.ID, -10*time.Minute)
	}

	n, err := h.svc.MarkStaleOffline(ctxFor(t, a), telemetry.StaleThresholdMinutes)
	require.NoError(t, err)
	require.EqualValues(t, 1, n, "the sweep must never cross the tenant boundary")
	require.Equal(t, telemetry.StatusOffline, lastState(t, a.Unit.ID).online)
	require.Equal(t, telemetry.StatusOnline, lastState(t, other.Unit.ID).online)
}

// ------------------------------------------------------------------ helpers

func telemetryRows(t testing.TB, unitID uuid.UUID) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).
		QueryRow(testutil.Ctx(t), `SELECT count(*) FROM telemetry WHERE unit_id = $1`, unitID).Scan(&n))
	return n
}

type stateRow struct {
	ts         time.Time
	lat        float64
	odometer   int64
	dutyStatus string
	online     string
}

func lastState(t testing.TB, unitID uuid.UUID) stateRow {
	t.Helper()
	var s stateRow
	var lat *float64
	var odo *int64
	var duty *string
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT ts, lat, odometer_m, duty_status, online_status FROM unit_last_state WHERE unit_id = $1`,
		unitID).Scan(&s.ts, &lat, &odo, &duty, &s.online))
	if lat != nil {
		s.lat = *lat
	}
	if odo != nil {
		s.odometer = *odo
	}
	if duty != nil {
		s.dutyStatus = *duty
	}
	return s
}

func backdateLastState(t testing.TB, unitID uuid.UUID, delta time.Duration) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`UPDATE unit_last_state SET ts = now() + $2::interval WHERE unit_id = $1`,
		unitID, delta.String())
	require.NoError(t, err)
}

type tripRow struct {
	startAt     time.Time
	endAt       *time.Time
	distanceM   int64
	durationSec *int32
	maxSpeed    *float64
	polylineKey *string
}

func listTrips(t testing.TB, unitID uuid.UUID) []tripRow {
	t.Helper()
	rows, err := testutil.AdminPool(t).Query(testutil.Ctx(t),
		`SELECT start_at, end_at, distance_m, duration_sec, max_speed_kmh, polyline_key
		 FROM trips WHERE unit_id = $1 ORDER BY start_at`, unitID)
	require.NoError(t, err)
	defer rows.Close()

	var out []tripRow
	for rows.Next() {
		var r tripRow
		require.NoError(t, rows.Scan(&r.startAt, &r.endAt, &r.distanceM, &r.durationSec, &r.maxSpeed, &r.polylineKey))
		out = append(out, r)
	}
	require.NoError(t, rows.Err())
	return out
}

type unidentifiedRow struct {
	startAt   time.Time
	endAt     *time.Time
	distanceM int64
	status    string
}

func listUnidentified(t testing.TB, unitID uuid.UUID) []unidentifiedRow {
	t.Helper()
	rows, err := testutil.AdminPool(t).Query(testutil.Ctx(t),
		`SELECT start_at, end_at, distance_m, status FROM unidentified_events
		 WHERE unit_id = $1 ORDER BY start_at`, unitID)
	require.NoError(t, err)
	defer rows.Close()

	var out []unidentifiedRow
	for rows.Next() {
		var r unidentifiedRow
		require.NoError(t, rows.Scan(&r.startAt, &r.endAt, &r.distanceM, &r.status))
		out = append(out, r)
	}
	require.NoError(t, rows.Err())
	return out
}

func deviceHealth(t testing.TB, deviceID uuid.UUID) (string, []string) {
	t.Helper()
	var status string
	var codes []string
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT status, malfunction_codes FROM eld_devices WHERE id = $1`, deviceID).Scan(&status, &codes))
	return status, codes
}

func auditRows(t testing.TB, recordID uuid.UUID) int {
	t.Helper()
	var n int
	require.NoError(t, testutil.AdminPool(t).QueryRow(testutil.Ctx(t),
		`SELECT count(*) FROM audit_log WHERE table_name = 'eld_devices' AND record_id = $1`,
		recordID).Scan(&n))
	return n
}
