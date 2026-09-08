package sync

import "time"

// EvaluateClock derives the batch time-integrity verdict from the device clock
// snapshot and the server instant (Q-B1.2).
//
// Priority: 1) ELD RTC, 2) server time, 3) phone. When the ELD is connected the
// phone is compared against the RTC; without an ELD the phone is compared
// against the server and every event stamped from it is time_unverified. A
// batch that carries no device clock at all is server stamped and verified.
func EvaluateClock(c Clock, now time.Time) Integrity {
	switch {
	case !c.ELDRTC.IsZero():
		in := Integrity{Source: TimeSourceELDRTC}
		if !c.Phone.IsZero() {
			in.SkewSec = skewSeconds(c.Phone, c.ELDRTC)
		}
		return withThresholds(in)
	case !c.Phone.IsZero():
		// Q7.1: no ELD — the phone is the only clock, so the batch is
		// unverified and the drift is measured against the server.
		return withThresholds(Integrity{
			Source:     TimeSourcePhone,
			SkewSec:    skewSeconds(c.Phone, now),
			Unverified: true,
		})
	default:
		return Integrity{Source: TimeSourceServer}
	}
}

// withThresholds applies the 2-minute warning and 10-minute malfunction levels.
func withThresholds(in Integrity) Integrity {
	skew := time.Duration(abs(in.SkewSec)) * time.Second
	in.Warn = skew > WarnSkew
	in.Malfunction = skew > MalfunctionSkew
	return in
}

// skewSeconds returns phone - reference, rounded to whole seconds. The sign is
// kept so a device running behind is distinguishable from one running ahead.
func skewSeconds(phone, reference time.Time) int {
	return int(phone.Sub(reference).Round(time.Second) / time.Second)
}

func abs(v int) int {
	if v < 0 {
		return -v
	}
	return v
}

// EventIntegrity resolves the per-event time fields from the event's own
// declared source and the batch verdict. An event that names no source inherits
// the batch source; any event stamped from the phone is time_unverified.
func EventIntegrity(e Event, in Integrity) (source string, unverified bool, skewSec int) {
	source = e.TimeSource
	if !ValidTimeSource(source) {
		source = in.Source
	}
	if source == "" {
		source = TimeSourceServer
	}
	return source, source == TimeSourcePhone, in.SkewSec
}
