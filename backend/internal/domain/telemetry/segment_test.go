// Pure unit coverage of the segmentation rules (TZ §13 Q64/Q65, A§10.4). No
// database is involved, so every rule can be exercised in isolation.
package telemetry_test

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/domain/telemetry"
)

var base = time.Date(2026, 9, 6, 5, 0, 0, 0, time.UTC)

func f(v float64) *float64 { return &v }
func i(v int64) *int64     { return &v }
func b(v bool) *bool       { return &v }

// pt builds a sample at base+offset.
func pt(offset time.Duration, lat, lng float64, ignition bool, opts ...func(*telemetry.Point)) telemetry.Point {
	p := telemetry.Point{TS: base.Add(offset), Lat: f(lat), Lng: f(lng), Ignition: b(ignition)}
	for _, o := range opts {
		o(&p)
	}
	return p
}

func withDriver(id uuid.UUID) func(*telemetry.Point) {
	return func(p *telemetry.Point) { p.DriverID = &id }
}

func withOdometer(v int64) func(*telemetry.Point) {
	return func(p *telemetry.Point) { p.OdometerM = i(v) }
}

func withSpeed(v float64) func(*telemetry.Point) {
	return func(p *telemetry.Point) { p.SpeedKmh = f(v) }
}

func TestNormalizeSortsAndDropsDuplicateTimestamps(t *testing.T) {
	pts := telemetry.Normalize([]telemetry.Point{
		{TS: base.Add(2 * time.Minute)},
		{TS: base},
		{TS: base.Add(2 * time.Minute), SpeedKmh: f(9)},
		{TS: base.Add(time.Minute)},
	})
	require.Len(t, pts, 3)
	require.Equal(t, base, pts[0].TS)
	require.Equal(t, base.Add(time.Minute), pts[1].TS)
	require.Equal(t, base.Add(2*time.Minute), pts[2].TS)
	// The last sample of a duplicated timestamp wins.
	require.NotNil(t, pts[2].SpeedKmh)
}

func TestHaversineDistance(t *testing.T) {
	// One degree of latitude is about 111 km.
	require.InDelta(t, 111195, telemetry.HaversineM(0, 0, 1, 0), 100)
	require.Equal(t, 0.0, telemetry.HaversineM(31.52, 74.35, 31.52, 74.35))
}

func TestStepDistancePrefersOdometer(t *testing.T) {
	a := pt(0, 31.5, 74.3, true, withOdometer(1_000_000))
	next := pt(time.Minute, 31.6, 74.4, true, withOdometer(1_012_000))
	// The ECM reading wins over the ~14 km GPS leg.
	require.EqualValues(t, 12000, telemetry.StepDistanceM(a, next))

	// An odometer reset falls back to the GPS distance instead of a negative leg.
	reset := pt(time.Minute, 31.6, 74.4, true, withOdometer(5))
	require.Greater(t, telemetry.StepDistanceM(a, reset), int64(10_000))

	// Without a fix and without an odometer there is nothing to measure.
	require.EqualValues(t, 0, telemetry.StepDistanceM(
		telemetry.Point{TS: base}, telemetry.Point{TS: base.Add(time.Minute)}))
}

func TestTripClosesOnIgnitionOff(t *testing.T) {
	plan := telemetry.BuildPlan(telemetry.State{}, []telemetry.Point{
		pt(0, 31.50, 74.30, true, withSpeed(0)),
		pt(1*time.Minute, 31.51, 74.31, true, withSpeed(60)),
		pt(2*time.Minute, 31.52, 74.32, false, withSpeed(0)),
	})
	require.Len(t, plan.Trips, 1)
	trip := plan.Trips[0]
	require.False(t, trip.Continues)
	require.True(t, trip.Closed)
	require.Equal(t, base, trip.Start)
	require.Equal(t, base.Add(2*time.Minute), trip.End)
	require.Greater(t, trip.DistanceM, int64(0))
	require.InDelta(t, 60, *trip.MaxSpeedKmh, 1e-9)
	require.Len(t, trip.Points, 3)
}

func TestTripStaysOpenWhileIgnitionOn(t *testing.T) {
	plan := telemetry.BuildPlan(telemetry.State{}, []telemetry.Point{
		pt(0, 31.50, 74.30, true),
		pt(time.Minute, 31.51, 74.31, true),
	})
	require.Len(t, plan.Trips, 1)
	require.False(t, plan.Trips[0].Closed)
}

func TestTripClosesOnFifteenMinuteStop(t *testing.T) {
	// No ignition-off arrives; the 15 minute silence ends the trip at the last
	// sample before the gap and the sample after it opens a new one.
	plan := telemetry.BuildPlan(telemetry.State{}, []telemetry.Point{
		pt(0, 31.50, 74.30, true),
		pt(2*time.Minute, 31.51, 74.31, true),
		pt(20*time.Minute, 31.60, 74.40, true),
	})
	require.Len(t, plan.Trips, 2)
	require.True(t, plan.Trips[0].Closed)
	require.Equal(t, base.Add(2*time.Minute), plan.Trips[0].End)
	require.False(t, plan.Trips[1].Closed)
	require.Equal(t, base.Add(20*time.Minute), plan.Trips[1].Start)
}

func TestGapBelowThresholdKeepsOneTrip(t *testing.T) {
	plan := telemetry.BuildPlan(telemetry.State{}, []telemetry.Point{
		pt(0, 31.50, 74.30, true),
		pt(14*time.Minute+59*time.Second, 31.51, 74.31, true),
	})
	require.Len(t, plan.Trips, 1)
	require.False(t, plan.Trips[0].Closed)
}

func TestTripSegmentContinuesAcrossBatches(t *testing.T) {
	prev := pt(0, 31.50, 74.30, true)
	plan := telemetry.BuildPlan(telemetry.State{Prev: &prev, TripOpen: true}, []telemetry.Point{
		pt(time.Minute, 31.51, 74.31, true),
		pt(2*time.Minute, 31.52, 74.32, false),
	})
	require.Len(t, plan.Trips, 1)
	require.True(t, plan.Trips[0].Continues, "the open trip must be extended, not duplicated")
	require.True(t, plan.Trips[0].Closed)
}

func TestSamplesOlderThanTheStoredStateAreIgnored(t *testing.T) {
	prev := pt(10*time.Minute, 31.50, 74.30, true)
	plan := telemetry.BuildPlan(telemetry.State{Prev: &prev}, []telemetry.Point{
		pt(time.Minute, 31.60, 74.40, true),
	})
	require.Empty(t, plan.Trips)
	require.EqualValues(t, 0, plan.DistanceM)
}

func TestUnidentifiedOpensWithoutDriverAndClosesOnLogin(t *testing.T) {
	driver := uuid.New()
	plan := telemetry.BuildPlan(telemetry.State{}, []telemetry.Point{
		pt(0, 31.50, 74.30, true),
		pt(time.Minute, 31.51, 74.31, true),
		pt(2*time.Minute, 31.52, 74.32, true, withDriver(driver)),
	})
	require.Len(t, plan.Unidentified, 1)
	ue := plan.Unidentified[0]
	require.True(t, ue.Closed, "a driver login must close the unidentified buffer")
	require.Equal(t, base, ue.Start)
	require.Equal(t, base.Add(2*time.Minute), ue.End)
	require.Greater(t, ue.DistanceM, int64(0))

	// The trip itself is one continuous drive, unidentified or not.
	require.Len(t, plan.Trips, 1)
	require.False(t, plan.Trips[0].Closed)
}

func TestIdentifiedDrivingNeverOpensUnidentified(t *testing.T) {
	driver := uuid.New()
	plan := telemetry.BuildPlan(telemetry.State{}, []telemetry.Point{
		pt(0, 31.50, 74.30, true, withDriver(driver)),
		pt(time.Minute, 31.51, 74.31, true, withDriver(driver)),
	})
	require.Empty(t, plan.Unidentified)
}

func TestSpeedDecidesWhenIgnitionIsUnreported(t *testing.T) {
	plan := telemetry.BuildPlan(telemetry.State{}, []telemetry.Point{
		{TS: base, Lat: f(31.5), Lng: f(74.3), SpeedKmh: f(0)},
		{TS: base.Add(time.Minute), Lat: f(31.51), Lng: f(74.31), SpeedKmh: f(55)},
		{TS: base.Add(2 * time.Minute), Lat: f(31.52), Lng: f(74.32), SpeedKmh: f(0)},
	})
	require.Len(t, plan.Trips, 1)
	require.True(t, plan.Trips[0].Closed)
	require.Equal(t, base.Add(time.Minute), plan.Trips[0].Start)
}

func TestEmptyBatch(t *testing.T) {
	plan := telemetry.BuildPlan(telemetry.State{}, nil)
	require.Nil(t, plan.Last)
	require.Empty(t, plan.Trips)
	require.EqualValues(t, 0, plan.DistanceM)
}

func TestEncodePolyline(t *testing.T) {
	// Reference vector from the Google encoded polyline specification.
	pts := []telemetry.Point{
		{TS: base, Lat: f(38.5), Lng: f(-120.2)},
		{TS: base.Add(time.Minute), Lat: f(40.7), Lng: f(-120.95)},
		{TS: base.Add(2 * time.Minute), Lat: f(43.252), Lng: f(-126.453)},
	}
	require.Equal(t, "_p~iF~ps|U_ulLnnqC_mqNvxq`@", telemetry.EncodePolyline(pts))
	require.Equal(t, "", telemetry.EncodePolyline(nil))
}
