package geo

import (
	"fmt"
	"math"
	"strings"
)

// earthRadiusM is the mean Earth radius used by the haversine distance.
const earthRadiusM = 6371008.8

// metresPerDegreeLat is the length of one degree of latitude. It is constant
// enough (±0.5 %) for the 100 m cache grid and for the "x km from town"
// rounding the FMCSA text needs.
const metresPerDegreeLat = 111320.0

// compass8 are the eight point directions the FMCSA location text uses.
var compass8 = [8]string{"N", "NE", "E", "SE", "S", "SW", "W", "NW"}

// DistanceM returns the great circle distance between two points in metres.
func DistanceM(a, b Point) float64 {
	lat1 := a.Lat * math.Pi / 180
	lat2 := b.Lat * math.Pi / 180
	dLat := lat2 - lat1
	dLng := (b.Lng - a.Lng) * math.Pi / 180

	h := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1)*math.Cos(lat2)*math.Sin(dLng/2)*math.Sin(dLng/2)
	return 2 * earthRadiusM * math.Asin(math.Sqrt(math.Min(1, h)))
}

// BearingDeg returns the initial compass bearing from a to b in degrees
// clockwise from north, normalised to [0, 360).
func BearingDeg(a, b Point) float64 {
	lat1 := a.Lat * math.Pi / 180
	lat2 := b.Lat * math.Pi / 180
	dLng := (b.Lng - a.Lng) * math.Pi / 180

	y := math.Sin(dLng) * math.Cos(lat2)
	x := math.Cos(lat1)*math.Sin(lat2) - math.Sin(lat1)*math.Cos(lat2)*math.Cos(dLng)
	deg := math.Atan2(y, x) * 180 / math.Pi
	return math.Mod(deg+360, 360)
}

// Compass8 turns a bearing in degrees into one of N/NE/E/SE/S/SW/W/NW.
func Compass8(deg float64) string {
	idx := int(math.Round(math.Mod(deg+360, 360)/45)) % 8
	return compass8[idx]
}

// FormatFMCSA builds the location text a log record stores (Q9):
// "<distance> km <direction> of <city>, <state>". The distance is rounded to
// whole kilometres because that is the resolution the regulation asks for, and
// a point inside the town itself drops the prefix entirely.
//
// The caller passes metres; the returned string is metric. Unit conversion for
// display is the client's job, never the backend's.
func FormatFMCSA(distanceM float64, bearing, city, state string) string {
	city = strings.TrimSpace(city)
	state = strings.TrimSpace(state)
	if city == "" {
		return ""
	}
	place := city
	if state != "" {
		place = city + ", " + state
	}
	km := int(math.Round(distanceM / 1000))
	if km <= 0 || bearing == "" {
		return place
	}
	return fmt.Sprintf("%d km %s of %s", km, bearing, place)
}

// Describe fills DistanceM, Bearing and Text of a place resolved at `at`. It is
// shared by every provider so the FMCSA formatting lives in exactly one place.
func Describe(p Place, at Point) Place {
	if p.Center.Valid() && at.Valid() {
		p.DistanceM = DistanceM(p.Center, at)
		p.Bearing = Compass8(BearingDeg(p.Center, at))
	}
	if p.Text == "" {
		p.Text = FormatFMCSA(p.DistanceM, p.Bearing, p.City, p.State)
	}
	return p
}

// GridCell is a coordinate quantised to a fixed size square. Two points inside
// the same cell share one cached reverse geocoding answer.
type GridCell struct {
	Lat int64
	Lng int64
}

// Grid quantises a coordinate to a square of roughly sizeM metres on a side.
// The longitude step is widened by 1/cos(lat) so cells stay square away from
// the equator; at the poles the factor is clamped so the index cannot explode.
func Grid(lat, lng float64, sizeM float64) GridCell {
	if sizeM <= 0 {
		sizeM = DefaultGridM
	}
	latStep := sizeM / metresPerDegreeLat
	latIdx := int64(math.Round(lat / latStep))

	// Use the quantised latitude so every point in the cell derives the same
	// longitude step, otherwise neighbouring points could land in two cells.
	cosLat := math.Cos(float64(latIdx) * latStep * math.Pi / 180)
	if cosLat < 0.01 {
		cosLat = 0.01
	}
	lngStep := latStep / cosLat
	return GridCell{Lat: latIdx, Lng: int64(math.Round(lng / lngStep))}
}
