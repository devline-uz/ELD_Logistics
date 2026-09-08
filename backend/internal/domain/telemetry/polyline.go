package telemetry

import "strings"

// EncodePolyline renders an ordered track as a Google encoded polyline
// (precision 5). Trip and unidentified tracks are stored as one small object in
// object storage instead of being replayed from the telemetry hypertable, which
// is subject to retention (TZ B§3.4, §13 Q64).
func EncodePolyline(points []Point) string {
	var b strings.Builder
	var prevLat, prevLng int64
	for _, p := range points {
		if !p.HasFix() {
			continue
		}
		lat := round(*p.Lat * 1e5)
		lng := round(*p.Lng * 1e5)
		encodeInt(&b, lat-prevLat)
		encodeInt(&b, lng-prevLng)
		prevLat, prevLng = lat, lng
	}
	return b.String()
}

func round(v float64) int64 {
	if v < 0 {
		return int64(v - 0.5)
	}
	return int64(v + 0.5)
}

func encodeInt(b *strings.Builder, v int64) {
	u := uint64(v << 1) //nolint:gosec // G115: standard Google polyline bit-reinterpretation, not a truncation
	if v < 0 {
		u = uint64(^(v << 1)) //nolint:gosec // G115: standard Google polyline bit-reinterpretation, not a truncation
	}
	for u >= 0x20 {
		b.WriteByte(byte((0x20 | (u & 0x1f)) + 63)) //nolint:gosec // G115: masked to 5 bits, always < 256
		u >>= 5
	}
	b.WriteByte(byte(u + 63))
}
