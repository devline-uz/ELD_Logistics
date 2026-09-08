package telemetry

import "math"

// earthRadiusM is the mean Earth radius used by the haversine formula.
const earthRadiusM = 6371008.8

// maxOdometerStepM guards against an ECM odometer reset or a corrupt reading
// being booked as a 1000 km leg. Beyond it the GPS distance is used instead.
const maxOdometerStepM = 1_000_000

// maxGPSStepM drops teleporting fixes: two consecutive samples are at most 30 s
// / 5 min apart (Q63.1), so 300 km between them is never real movement.
const maxGPSStepM = 300_000

// HaversineM is the great circle distance between two WGS84 points in metres.
func HaversineM(lat1, lng1, lat2, lng2 float64) float64 {
	p1 := lat1 * math.Pi / 180
	p2 := lat2 * math.Pi / 180
	dp := (lat2 - lat1) * math.Pi / 180
	dl := (lng2 - lng1) * math.Pi / 180

	a := math.Sin(dp/2)*math.Sin(dp/2) + math.Cos(p1)*math.Cos(p2)*math.Sin(dl/2)*math.Sin(dl/2)
	return 2 * earthRadiusM * math.Asin(math.Min(1, math.Sqrt(a)))
}

// StepDistanceM is the metres travelled between two consecutive samples.
// Q61/Q62 — the ECM odometer wins when both samples carry a plausible reading;
// otherwise the haversine distance between the GPS fixes is used. Distances are
// always metres: the backend never converts units.
func StepDistanceM(prev, next Point) int64 {
	if prev.OdometerM != nil && next.OdometerM != nil {
		d := *next.OdometerM - *prev.OdometerM
		if d >= 0 && d <= maxOdometerStepM {
			return d
		}
	}
	if !prev.HasFix() || !next.HasFix() {
		return 0
	}
	d := HaversineM(*prev.Lat, *prev.Lng, *next.Lat, *next.Lng)
	if d > maxGPSStepM {
		return 0
	}
	return int64(math.Round(d))
}
