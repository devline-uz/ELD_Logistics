package teltonika_test

import (
	"encoding/binary"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/pkg/eldproto"
	"github.com/devline/onebook-eld/pkg/eldproto/teltonika"
)

// packet builds a one record Codec 8 test vector.
func packet(codec byte, records ...[]byte) []byte {
	data := []byte{codec, byte(len(records))}
	for _, r := range records {
		data = append(data, r...)
	}
	data = append(data, byte(len(records)))

	out := []byte{0, 0, 0, 0}
	out = binary.BigEndian.AppendUint32(out, uint32(len(data)))
	out = append(out, data...)
	out = binary.BigEndian.AppendUint32(out, 0) // CRC placeholder
	return out
}

func record(ts time.Time, latE7, lngE7 int32, speed uint16) []byte {
	b := binary.BigEndian.AppendUint64(nil, uint64(ts.UnixMilli()))
	b = append(b, 1) // priority
	b = binary.BigEndian.AppendUint32(b, uint32(lngE7))
	b = binary.BigEndian.AppendUint32(b, uint32(latE7))
	b = binary.BigEndian.AppendUint16(b, 120) // altitude
	b = binary.BigEndian.AppendUint16(b, 180) // angle
	b = append(b, 9)                          // satellites
	b = binary.BigEndian.AppendUint16(b, speed)

	b = append(b, 0) // event io id
	b = append(b, 6) // total io elements
	b = append(b, 4) // one byte elements
	b = append(b, 239, 1)
	b = append(b, 48, 74)
	b = append(b, 32, 0xF6) // -10 C
	b = append(b, 253, 0x02|0x08)
	b = append(b, 1) // two byte elements
	b = binary.BigEndian.AppendUint16(append(b, 67), 13800)
	b = append(b, 1) // four byte elements
	b = binary.BigEndian.AppendUint32(append(b, 16), 128430000)
	b = append(b, 0) // eight byte elements
	return b
}

func TestDecodeCodec8Record(t *testing.T) {
	ts := time.Date(2026, 9, 6, 5, 12, 0, 0, time.UTC)
	frames, err := teltonika.New().Decode(packet(teltonika.Codec8, record(ts, 315200000, 743500000, 62)))
	require.NoError(t, err)
	require.Len(t, frames, 1)

	f := frames[0]
	require.Equal(t, ts, f.TS)
	require.InDelta(t, 31.52, *f.Lat, 1e-6)
	require.InDelta(t, 74.35, *f.Lng, 1e-6)
	require.InDelta(t, 62, *f.SpeedKmh, 1e-9)
	require.InDelta(t, 180, *f.HeadingDeg, 1e-9)
	require.True(t, *f.Ignition)
	require.InDelta(t, 74, *f.FuelPct, 1e-9)
	require.InDelta(t, -10, *f.CoolantTempC, 1e-9)
	require.InDelta(t, 13.8, *f.BatteryVoltageV, 1e-9)
	require.EqualValues(t, 128430000, *f.OdometerM)
	require.Equal(t, []string{eldproto.MalfunctionEngineSync, eldproto.MalfunctionPositioning}, f.Diagnostics)
}

func TestDecodeManyRecords(t *testing.T) {
	ts := time.Date(2026, 9, 6, 5, 12, 0, 0, time.UTC)
	frames, err := teltonika.New().Decode(packet(teltonika.Codec8,
		record(ts, 315200000, 743500000, 0),
		record(ts.Add(30*time.Second), 315300000, 743600000, 55),
	))
	require.NoError(t, err)
	require.Len(t, frames, 2)
	require.EqualValues(t, 0, frames[0].Seq)
	require.EqualValues(t, 1, frames[1].Seq)
}

func TestDecodeDropsNullIsland(t *testing.T) {
	frames, err := teltonika.New().Decode(packet(teltonika.Codec8,
		record(time.Now().UTC().Truncate(time.Millisecond), 0, 0, 0)))
	require.NoError(t, err)
	require.Nil(t, frames[0].Lat)
	require.Nil(t, frames[0].Lng)
	require.False(t, frames[0].HasFix())
}

func TestDecodeRejectsCorruptPayloads(t *testing.T) {
	ts := time.Date(2026, 9, 6, 5, 12, 0, 0, time.UTC)
	dec := teltonika.New()

	_, err := dec.Decode([]byte{0, 0, 0, 1, 0, 0, 0, 2, 0x08, 0})
	require.ErrorIs(t, err, eldproto.ErrUnsupported)

	_, err = dec.Decode(packet(0x8E, record(ts, 1, 1, 0)))
	require.ErrorIs(t, err, eldproto.ErrUnsupported)

	full := packet(teltonika.Codec8, record(ts, 315200000, 743500000, 62))
	_, err = dec.Decode(full[:len(full)-12])
	require.ErrorIs(t, err, eldproto.ErrShortFrame)

	_, err = dec.Decode([]byte{})
	require.ErrorIs(t, err, eldproto.ErrShortFrame)
}

func TestRegistered(t *testing.T) {
	d, err := eldproto.Get(teltonika.Vendor)
	require.NoError(t, err)
	require.Equal(t, teltonika.Vendor, d.Vendor())
}
