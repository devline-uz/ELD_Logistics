// Package pt30 is a SKELETON decoder for the Pacific Track PT30 family of ELD
// gateways. It implements eldproto.Decoder for the ASCII sentence subset the
// device emits over TCP and Bluetooth SPP.
//
// TODO(stage-5): this is deliberately not the full vendor protocol. Missing:
// binary "compressed history" frames (0x02 opcode), the ACK/NAK handshake,
// firmware OTA sentences, the J1939/J1708 raw PGN passthrough and the
// device-side buffer replay window. Only the $PT30 position/ECM sentence is
// parsed, which is what the ingestion pipeline and its tests need today.
package pt30

import (
	"strconv"
	"strings"
	"time"

	"github.com/devline/onebook-eld/pkg/eldproto"
)

// Vendor is the eld_devices.vendor key handled by this decoder.
const Vendor = "pt30"

// sentence layout, comma separated, after the "$PT30" tag:
//
//	 0 serial            1 seq              2 ts (yyyymmddhhmmss, UTC)
//	 3 lat (deg)         4 lng (deg)        5 speed (km/h)
//	 6 heading (deg)     7 odometer (m)     8 engine hours
//	 9 fuel (%)         10 coolant (C)     11 oil (%)
//	12 battery (V)      13 ignition (0|1)  14 diagnostic letters
//
// An empty field means "not reported" and stays nil on the frame.
const fieldCount = 15

// Decoder decodes PT30 ASCII sentences.
type Decoder struct{}

// New builds the decoder.
func New() Decoder { return Decoder{} }

func init() { eldproto.Register(Decoder{}) }

// Vendor implements eldproto.Decoder.
func (Decoder) Vendor() string { return Vendor }

// Decode implements eldproto.Decoder. A payload may carry several CRLF
// separated sentences; blank lines are skipped.
func (d Decoder) Decode(payload []byte) ([]eldproto.Frame, error) {
	lines := strings.FieldsFunc(string(payload), func(r rune) bool { return r == '\n' || r == '\r' })
	frames := make([]eldproto.Frame, 0, len(lines))
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		f, err := decodeSentence(line)
		if err != nil {
			return nil, err
		}
		frames = append(frames, f)
	}
	return frames, nil
}

func decodeSentence(line string) (eldproto.Frame, error) {
	if !strings.HasPrefix(line, "$PT30,") {
		return eldproto.Frame{}, eldproto.ErrUnsupported
	}
	star := strings.LastIndexByte(line, '*')
	if star < 0 || star+3 > len(line) {
		return eldproto.Frame{}, eldproto.ErrShortFrame
	}
	body := line[1:star]
	want, err := strconv.ParseUint(line[star+1:star+3], 16, 8)
	if err != nil {
		return eldproto.Frame{}, eldproto.ErrBadChecksum
	}
	if checksum(body) != byte(want) {
		return eldproto.Frame{}, eldproto.ErrBadChecksum
	}

	// body starts with the "PT30" tag; drop it.
	fields := strings.Split(body, ",")[1:]
	if len(fields) < fieldCount {
		return eldproto.Frame{}, eldproto.ErrShortFrame
	}

	ts, err := time.ParseInLocation("20060102150405", fields[2], time.UTC)
	if err != nil {
		return eldproto.Frame{}, eldproto.ErrShortFrame
	}

	f := eldproto.Frame{
		DeviceSerial: fields[0],
		//nolint:gosec // G115: device sequence counter, wraparound is an accepted protocol behavior
		Seq:             uint32(parseUint(fields[1])),
		TS:              ts.UTC(),
		Lat:             optFloat(fields[3]),
		Lng:             optFloat(fields[4]),
		SpeedKmh:        optFloat(fields[5]),
		HeadingDeg:      optFloat(fields[6]),
		OdometerM:       optInt(fields[7]),
		EngineHours:     optFloat(fields[8]),
		FuelPct:         optFloat(fields[9]),
		CoolantTempC:    optFloat(fields[10]),
		OilLevelPct:     optFloat(fields[11]),
		BatteryVoltageV: optFloat(fields[12]),
		Ignition:        optBool(fields[13]),
		Diagnostics:     eldproto.NormalizeCodes(strings.Split(fields[14], "")),
	}
	return f, nil
}

// checksum is the NMEA style XOR over every byte between "$" and "*".
func checksum(body string) byte {
	var c byte
	for i := 0; i < len(body); i++ {
		c ^= body[i]
	}
	return c
}

func optFloat(s string) *float64 {
	if s == "" {
		return nil
	}
	v, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return nil
	}
	return &v
}

func optInt(s string) *int64 {
	if s == "" {
		return nil
	}
	v, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return nil
	}
	return &v
}

func optBool(s string) *bool {
	switch s {
	case "0":
		return eldproto.Bool(false)
	case "1":
		return eldproto.Bool(true)
	default:
		return nil
	}
}

func parseUint(s string) uint64 {
	v, err := strconv.ParseUint(s, 10, 32)
	if err != nil {
		return 0
	}
	return v
}
