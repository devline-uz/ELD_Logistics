package telemetry

import (
	"sort"
	"time"

	"github.com/google/uuid"
)

// StopThreshold is the halt that ends a trip when no ignition-off arrives
// (TZ §13 Q64/Q65 — "ignition on → off yoki ≥ 15 daq to'xtash").
const StopThreshold = 15 * time.Minute

// MovingSpeedKmh is the speed above which a unit counts as moving when the
// device does not report ignition. Speeds are km/h on the wire and in storage.
const MovingSpeedKmh = 1.0

// Point is one normalised telemetry sample. Optional signals stay nil so
// "not reported" never collapses into a zero reading.
type Point struct {
	TS          time.Time
	Lat         *float64
	Lng         *float64
	SpeedKmh    *float64
	Heading     *float64
	OdometerM   *int64
	EngineHours *float64

	FuelPct         *float64
	CoolantTempC    *float64
	CoolantLevelPct *float64
	OilLevelPct     *float64
	BatteryPct      *float64
	BatteryVoltageV *float64

	Ignition *bool
	// DriverID is nil for unidentified driving (TZ A§10.4).
	DriverID *uuid.UUID
	// DutyStatus is the driver duty status at TS, empty when unknown.
	DutyStatus string
	// Diagnostics are the FMCSA Appendix A letters active at TS. It is only
	// meaningful together with DiagnosticsReported: an empty slice from a
	// device that reports diagnostics clears the stored codes, while a device
	// that stays silent must never clear them.
	Diagnostics         []string
	DiagnosticsReported bool
	// Source is telemetry.source: eld, phone or simulator.
	Source string
	// Disconnected marks a sample the device sent to announce that the ELD lost
	// its link to the phone (TZ §10.1 "Disconnected").
	Disconnected bool
}

// HasFix reports whether the sample carries a usable WGS84 position.
func (p Point) HasFix() bool {
	return p.Lat != nil && p.Lng != nil &&
		*p.Lat >= -90 && *p.Lat <= 90 && *p.Lng >= -180 && *p.Lng <= 180 &&
		!(*p.Lat == 0 && *p.Lng == 0)
}

// Moving reports whether the unit is under way. Ignition wins when the device
// reports it; otherwise the speed decides.
func (p Point) Moving() bool {
	if p.Ignition != nil {
		return *p.Ignition
	}
	return p.SpeedKmh != nil && *p.SpeedKmh > MovingSpeedKmh
}

// Segment is one driving interval discovered in a batch.
type Segment struct {
	// Continues is true when the interval extends a record that was already
	// open in the database instead of starting a new one.
	Continues bool
	// Closed is true when the end of the interval was observed in this batch.
	Closed bool

	Start    time.Time
	End      time.Time
	StartLat *float64
	StartLng *float64
	EndLat   *float64
	EndLng   *float64

	// DistanceM is the metres added by this batch only; a continuing segment
	// never re-counts what previous batches already booked.
	DistanceM   int64
	MaxSpeedKmh *float64
	// Points are the fixes of this batch inside the interval, for the polyline.
	Points []Point
}

// Plan is the outcome of segmenting one ordered batch of samples.
type Plan struct {
	// Points is the deduplicated, chronologically ordered batch.
	Points []Point
	// DistanceM is the total metres travelled across the batch.
	DistanceM int64
	// Trips are the trip intervals (TZ §13 Q64/Q65).
	Trips []Segment
	// Unidentified are the driver-less driving intervals (TZ A§10.4).
	Unidentified []Segment
	// Last is the newest sample of the batch, nil when the batch is empty.
	Last *Point
	// MaxSpeedKmh is the highest speed seen in the batch.
	MaxSpeedKmh *float64
}

// State is what the segmenter carries over from storage: the previous sample of
// the unit and whether a trip / unidentified record is already open.
type State struct {
	Prev             *Point
	TripOpen         bool
	UnidentifiedOpen bool
}

// Normalize sorts a batch chronologically and drops duplicate timestamps,
// keeping the last sample of a timestamp. `(unit_id, ts)` is the telemetry
// primary key, so duplicates would be ignored by the database anyway.
func Normalize(points []Point) []Point {
	if len(points) == 0 {
		return nil
	}
	sorted := make([]Point, len(points))
	copy(sorted, points)
	for i := range sorted {
		sorted[i].TS = sorted[i].TS.UTC()
	}
	sort.SliceStable(sorted, func(i, j int) bool { return sorted[i].TS.Before(sorted[j].TS) })

	out := sorted[:0]
	for i, p := range sorted {
		if i+1 < len(sorted) && sorted[i+1].TS.Equal(p.TS) {
			continue
		}
		out = append(out, p)
	}
	return out
}

// BuildPlan runs the trip and unidentified-driving state machines over a batch.
// It is pure: no clock, no I/O, so every rule is unit testable.
func BuildPlan(state State, points []Point) Plan {
	pts := Normalize(points)
	plan := Plan{Points: pts}
	if len(pts) == 0 {
		return plan
	}
	plan.Last = &pts[len(pts)-1]

	prev := state.Prev
	for i := range pts {
		if prev != nil && !pts[i].TS.After(prev.TS) {
			continue
		}
		if prev != nil {
			plan.DistanceM += StepDistanceM(*prev, pts[i])
		}
		if s := pts[i].SpeedKmh; s != nil && (plan.MaxSpeedKmh == nil || *s > *plan.MaxSpeedKmh) {
			v := *s
			plan.MaxSpeedKmh = &v
		}
		prev = &pts[i]
	}

	plan.Trips = run(state.Prev, pts, state.TripOpen, func(p Point) bool { return p.Moving() })
	plan.Unidentified = run(state.Prev, pts, state.UnidentifiedOpen, func(p Point) bool {
		return p.Moving() && p.DriverID == nil
	})
	return plan
}

// run is the shared interval detector. `active` decides whether a sample counts
// as being inside an interval; a gap of at least StopThreshold always ends one.
func run(prev *Point, pts []Point, open bool, active func(Point) bool) []Segment {
	var out []Segment
	var cur *Segment
	last := prev

	// A record left open by an earlier batch is represented by a continuing
	// segment anchored on the previous sample.
	if open {
		cur = &Segment{Continues: true}
		if last != nil {
			cur.Start, cur.End = last.TS, last.TS
			cur.StartLat, cur.StartLng = last.Lat, last.Lng
			cur.EndLat, cur.EndLng = last.Lat, last.Lng
		}
	}

	closeAt := func(at Point) {
		cur.Closed = true
		cur.End = at.TS
		if at.HasFix() {
			cur.EndLat, cur.EndLng = at.Lat, at.Lng
		}
		out = append(out, *cur)
		cur = nil
	}

	start := func(p Point) {
		cur = &Segment{Start: p.TS, End: p.TS, StartLat: p.Lat, StartLng: p.Lng, EndLat: p.Lat, EndLng: p.Lng}
		if p.HasFix() {
			cur.Points = append(cur.Points, p)
		}
		bumpSpeed(cur, p)
	}

	for i := range pts {
		p := pts[i]
		if last != nil && !p.TS.After(last.TS) {
			continue
		}

		// Q64/Q65: a silence of 15 minutes or more is a stop, wherever it falls.
		if cur != nil && last != nil && p.TS.Sub(last.TS) >= StopThreshold {
			closeAt(*last)
		}

		if cur != nil {
			if last != nil {
				cur.DistanceM += StepDistanceM(*last, p)
			}
			cur.End = p.TS
			if p.HasFix() {
				cur.EndLat, cur.EndLng = p.Lat, p.Lng
				cur.Points = append(cur.Points, p)
			}
			bumpSpeed(cur, p)
			if !active(p) {
				closeAt(p)
			}
		} else if active(p) {
			start(p)
		}
		last = &pts[i]
	}

	if cur != nil {
		out = append(out, *cur)
	}
	return out
}

func bumpSpeed(s *Segment, p Point) {
	if p.SpeedKmh == nil {
		return
	}
	if s.MaxSpeedKmh == nil || *p.SpeedKmh > *s.MaxSpeedKmh {
		v := *p.SpeedKmh
		s.MaxSpeedKmh = &v
	}
}
