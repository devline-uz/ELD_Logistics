// Package teltonika is a SKELETON decoder for Teltonika FMx AVL Codec 8
// packets, the second reference transport of the ELD gateway layer.
//
// TODO(stage-5): only the Codec 8 (0x08) TCP data packet is parsed. Missing:
// Codec 8 Extended (0x8E), Codec 16, the IMEI handshake frame, the CRC-16/IBM
// trailer verification, GPRS command codecs (0x0C) and the full IO element
// catalogue. The IO elements mapped below are the handful the ingestion
// pipeline needs; everything else is skipped by length, never guessed.
package teltonika

import (
	"encoding/binary"
	"time"

	"github.com/devline/onebook-eld/pkg/eldproto"
)

// Vendor is the eld_devices.vendor key handled by this decoder.
const Vendor = "teltonika"

// Codec8 is the only codec id this skeleton accepts.
const Codec8 = 0x08

// Mapped AVL IO element ids (Teltonika FMB protocol numbering).
const (
	ioIgnition        = 239 // 1 byte, 0/1
	ioBatteryVoltage  = 67  // 2 bytes, mV
	ioTotalOdometerM  = 16  // 4 bytes, metres
	ioFuelLevelPct    = 48  // 1 byte, %
	ioCoolantTempC    = 32  // 1 byte, signed Celsius
	ioEngineHoursMin  = 102 // 4 bytes, minutes
	ioDigitalInput1   = 1   // 1 byte, unused - kept to document the skip path
	ioMalfunctionMask = 253 // 1 byte, vendor bitmask -> Appendix A letters
)

// malfunctionBits maps the vendor bitmask to FMCSA Appendix A letters.
var malfunctionBits = []struct {
	bit  byte
	code string
}{
	{0x01, eldproto.MalfunctionPower},
	{0x02, eldproto.MalfunctionEngineSync},
	{0x04, eldproto.MalfunctionTiming},
	{0x08, eldproto.MalfunctionPositioning},
	{0x10, eldproto.MalfunctionDataRecord},
	{0x20, eldproto.MalfunctionDataTransfer},
	{0x40, eldproto.MalfunctionOther},
}

// Decoder decodes Codec 8 AVL packets.
type Decoder struct{}

// New builds the decoder.
func New() Decoder { return Decoder{} }

func init() { eldproto.Register(Decoder{}) }

// Vendor implements eldproto.Decoder.
func (Decoder) Vendor() string { return Vendor }

// reader is a bounds checked cursor over the packet.
type reader struct {
	b   []byte
	i   int
	err error
}

func (r *reader) take(n int) []byte {
	if r.err != nil {
		return nil
	}
	if r.i+n > len(r.b) {
		r.err = eldproto.ErrShortFrame
		return nil
	}
	out := r.b[r.i : r.i+n]
	r.i += n
	return out
}

func (r *reader) u8() byte {
	b := r.take(1)
	if b == nil {
		return 0
	}
	return b[0]
}

func (r *reader) u16() uint16 {
	b := r.take(2)
	if b == nil {
		return 0
	}
	return binary.BigEndian.Uint16(b)
}

func (r *reader) u32() uint32 {
	b := r.take(4)
	if b == nil {
		return 0
	}
	return binary.BigEndian.Uint32(b)
}

func (r *reader) u64() uint64 {
	b := r.take(8)
	if b == nil {
		return 0
	}
	return binary.BigEndian.Uint64(b)
}

// Decode implements eldproto.Decoder.
//
// Packet layout: 4 zero bytes | data length (u32) | codec id (u8) |
// record count (u8) | records... | record count (u8) | CRC-16 (u32).
func (d Decoder) Decode(payload []byte) ([]eldproto.Frame, error) {
	r := &reader{b: payload}
	if pre := r.take(4); r.err != nil {
		return nil, r.err
	} else if binary.BigEndian.Uint32(pre) != 0 {
		return nil, eldproto.ErrUnsupported
	}
	_ = r.u32() // data field length; the transport already framed the packet
	if codec := r.u8(); codec != Codec8 {
		if r.err != nil {
			return nil, r.err
		}
		return nil, eldproto.ErrUnsupported
	}
	count := int(r.u8())
	if r.err != nil {
		return nil, r.err
	}

	frames := make([]eldproto.Frame, 0, count)
	for i := 0; i < count; i++ {
		f, err := decodeRecord(r, uint32(i))
		if err != nil {
			return nil, err
		}
		frames = append(frames, f)
	}
	if r.err != nil {
		return nil, r.err
	}
	if tail := int(r.u8()); r.err == nil && tail != count {
		return nil, eldproto.ErrBadChecksum
	}
	// TODO(stage-5): verify the trailing CRC-16/IBM over the data field.
	return frames, r.err
}

func decodeRecord(r *reader, seq uint32) (eldproto.Frame, error) {
	ms := r.u64()
	_ = r.u8()            // priority
	lng := int32(r.u32()) //nolint:gosec // G115: Teltonika AVL wire format encodes lat/lng as signed int32 bit patterns
	lat := int32(r.u32()) //nolint:gosec // G115: Teltonika AVL wire format encodes lat/lng as signed int32 bit patterns
	_ = r.u16()           // altitude, metres
	angle := r.u16()
	_ = r.u8() // satellites
	speed := r.u16()
	if r.err != nil {
		return eldproto.Frame{}, r.err
	}

	f := eldproto.Frame{
		Seq:        seq,
		TS:         time.UnixMilli(int64(ms)).UTC(), //nolint:gosec // G115: device epoch-ms timestamp, far below int64 overflow range
		Lat:        eldproto.Float(float64(lat) / 1e7),
		Lng:        eldproto.Float(float64(lng) / 1e7),
		SpeedKmh:   eldproto.Float(float64(speed)),
		HeadingDeg: eldproto.Float(float64(angle)),
	}

	_ = r.u8() // event io id
	total := int(r.u8())
	read := 0
	for _, width := range []int{1, 2, 4, 8} {
		n := int(r.u8())
		if r.err != nil {
			return eldproto.Frame{}, r.err
		}
		for j := 0; j < n; j++ {
			id := r.u8()
			raw := r.take(width)
			if r.err != nil {
				return eldproto.Frame{}, r.err
			}
			applyIO(&f, id, raw)
			read++
		}
	}
	if read != total {
		return eldproto.Frame{}, eldproto.ErrShortFrame
	}
	if !f.HasFix() {
		f.Lat, f.Lng = nil, nil
	}
	return f, nil
}

// applyIO maps one AVL IO element onto the frame; unknown ids are skipped.
func applyIO(f *eldproto.Frame, id byte, raw []byte) {
	switch id {
	case ioIgnition:
		f.Ignition = eldproto.Bool(raw[0] != 0)
	case ioBatteryVoltage:
		f.BatteryVoltageV = eldproto.Float(float64(binary.BigEndian.Uint16(raw)) / 1000)
	case ioTotalOdometerM:
		f.OdometerM = eldproto.Int(int64(binary.BigEndian.Uint32(raw)))
	case ioFuelLevelPct:
		f.FuelPct = eldproto.Float(float64(raw[0]))
	case ioCoolantTempC:
		//nolint:gosec // G115: Teltonika AVL wire format encodes coolant temp as a signed byte
		f.CoolantTempC = eldproto.Float(float64(int8(raw[0])))
	case ioEngineHoursMin:
		f.EngineHours = eldproto.Float(float64(binary.BigEndian.Uint32(raw)) / 60)
	case ioMalfunctionMask:
		codes := make([]string, 0, len(malfunctionBits))
		for _, m := range malfunctionBits {
			if raw[0]&m.bit != 0 {
				codes = append(codes, m.code)
			}
		}
		f.Diagnostics = eldproto.NormalizeCodes(codes)
	}
}
