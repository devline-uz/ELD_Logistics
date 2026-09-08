// Package eldproto is the vendor agnostic boundary between an ELD hardware
// protocol and the telemetry ingestion pipeline (TZ §10, §13 Q61/Q62).
//
// A vendor package implements Decoder and returns []Frame; internal/domain/telemetry
// knows nothing about wire formats. Units are raw and never converted:
// distance in metres, speed in km/h, temperature in Celsius, time in UTC.
package eldproto

import (
	"errors"
	"sort"
	"sync"
	"time"
)

// Decoding errors shared by every vendor implementation.
var (
	// ErrShortFrame means the payload ended before a complete record.
	ErrShortFrame = errors.New("eldproto: short frame")
	// ErrBadChecksum means the trailing integrity field did not verify.
	ErrBadChecksum = errors.New("eldproto: bad checksum")
	// ErrUnsupported means the payload announced a codec this build cannot read.
	ErrUnsupported = errors.New("eldproto: unsupported codec")
	// ErrUnknownVendor is returned by Get for a vendor that was never registered.
	ErrUnknownVendor = errors.New("eldproto: unknown vendor")
)

// FMCSA Appendix A malfunction / diagnostic codes (TZ §10.5). Devices report
// them as single letters; anything outside this set is dropped.
const (
	MalfunctionPower        = "P" // power compliance
	MalfunctionEngineSync   = "E" // engine synchronisation
	MalfunctionTiming       = "T" // timing
	MalfunctionPositioning  = "L" // positioning
	MalfunctionDataRecord   = "R" // data recording
	MalfunctionDataTransfer = "S" // data transfer
	MalfunctionOther        = "O" // other
)

// AllMalfunctionCodes is the ordered catalogue of Appendix A codes.
var AllMalfunctionCodes = []string{
	MalfunctionPower, MalfunctionEngineSync, MalfunctionTiming, MalfunctionPositioning,
	MalfunctionDataRecord, MalfunctionDataTransfer, MalfunctionOther,
}

var malfunctionSet = func() map[string]struct{} {
	m := make(map[string]struct{}, len(AllMalfunctionCodes))
	for _, c := range AllMalfunctionCodes {
		m[c] = struct{}{}
	}
	return m
}()

// IsMalfunctionCode reports whether code is a known Appendix A letter.
func IsMalfunctionCode(code string) bool {
	_, ok := malfunctionSet[code]
	return ok
}

// NormalizeCodes drops unknown and duplicate codes and returns them in the
// catalogue order, so eld_devices.malfunction_codes is always canonical.
func NormalizeCodes(codes []string) []string {
	seen := make(map[string]struct{}, len(codes))
	out := make([]string, 0, len(codes))
	for _, c := range codes {
		if !IsMalfunctionCode(c) {
			continue
		}
		if _, dup := seen[c]; dup {
			continue
		}
		seen[c] = struct{}{}
		out = append(out, c)
	}
	order := map[string]int{}
	for i, c := range AllMalfunctionCodes {
		order[c] = i
	}
	sort.Slice(out, func(i, j int) bool { return order[out[i]] < order[out[j]] })
	return out
}

// Frame is one decoded telemetry record. Every optional signal is a pointer so
// "the device did not report it" stays distinct from a zero reading, which is
// what the telemetry table stores as NULL.
type Frame struct {
	// DeviceSerial identifies the reporting hardware; the ingestion layer maps
	// it to eld_devices.serial. Empty when the transport already knows it.
	DeviceSerial string `json:"device_serial"`
	// Seq is the device side monotonic counter used to keep batch order.
	Seq uint32 `json:"seq"`
	// TS is the record time in UTC (device RTC).
	TS time.Time `json:"ts"`

	Lat        *float64 `json:"lat"`
	Lng        *float64 `json:"lng"`
	SpeedKmh   *float64 `json:"speed_kmh"`
	HeadingDeg *float64 `json:"heading_deg"`

	// OdometerM is the ECM total distance in metres.
	OdometerM *int64 `json:"odometer_m"`
	// EngineHours is the ECM total engine time in hours.
	EngineHours *float64 `json:"engine_hours"`

	FuelPct         *float64 `json:"fuel_pct"`
	CoolantTempC    *float64 `json:"coolant_temp_c"`
	CoolantLevelPct *float64 `json:"coolant_level_pct"`
	OilLevelPct     *float64 `json:"oil_level_pct"`
	BatteryPct      *float64 `json:"battery_pct"`
	BatteryVoltageV *float64 `json:"battery_voltage_v"`

	Ignition *bool `json:"ignition"`

	// Diagnostics carries the Appendix A letters active at TS.
	Diagnostics []string `json:"diagnostics"`
}

// HasFix reports whether the frame carries a usable GPS position.
func (f Frame) HasFix() bool {
	return f.Lat != nil && f.Lng != nil &&
		*f.Lat >= -90 && *f.Lat <= 90 && *f.Lng >= -180 && *f.Lng <= 180 &&
		!(*f.Lat == 0 && *f.Lng == 0)
}

// Decoder turns a raw device payload into zero or more frames. Implementations
// must be safe for concurrent use and must never panic on malformed input.
type Decoder interface {
	// Vendor is the eld_devices.vendor key this decoder handles.
	Vendor() string
	// Decode parses one transport payload.
	Decode(payload []byte) ([]Frame, error)
}

var (
	registryMu sync.RWMutex
	registry   = map[string]Decoder{}
)

// Register makes a decoder discoverable by vendor key. Re-registering a vendor
// replaces the previous decoder, which keeps tests independent.
func Register(d Decoder) {
	if d == nil {
		return
	}
	registryMu.Lock()
	defer registryMu.Unlock()
	registry[d.Vendor()] = d
}

// Get returns the decoder registered for vendor.
func Get(vendor string) (Decoder, error) {
	registryMu.RLock()
	defer registryMu.RUnlock()
	d, ok := registry[vendor]
	if !ok {
		return nil, ErrUnknownVendor
	}
	return d, nil
}

// Vendors lists the registered vendor keys in a stable order.
func Vendors() []string {
	registryMu.RLock()
	defer registryMu.RUnlock()
	out := make([]string, 0, len(registry))
	for k := range registry {
		out = append(out, k)
	}
	sort.Strings(out)
	return out
}

// Float returns a pointer to v; vendor packages use it to fill optional fields.
func Float(v float64) *float64 { return &v }

// Int returns a pointer to v.
func Int(v int64) *int64 { return &v }

// Bool returns a pointer to v.
func Bool(v bool) *bool { return &v }
