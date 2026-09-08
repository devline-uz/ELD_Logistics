package pt30_test

import (
	"fmt"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/pkg/eldproto"
	"github.com/devline/onebook-eld/pkg/eldproto/pt30"
)

// sentence builds a valid $PT30 line with the NMEA style XOR checksum.
func sentence(body string) string {
	var c byte
	for i := 0; i < len(body); i++ {
		c ^= body[i]
	}
	return fmt.Sprintf("$%s*%02X", body, c)
}

const full = "PT30,ELD-000123,1042,20260906051200,31.520000,74.350000,62.5,180,128430000,1234.5,74,88,60,13.8,1,TL"

func TestDecodeFullSentence(t *testing.T) {
	frames, err := pt30.New().Decode([]byte(sentence(full)))
	require.NoError(t, err)
	require.Len(t, frames, 1)

	f := frames[0]
	require.Equal(t, "ELD-000123", f.DeviceSerial)
	require.EqualValues(t, 1042, f.Seq)
	require.Equal(t, time.Date(2026, 9, 6, 5, 12, 0, 0, time.UTC), f.TS)
	require.InDelta(t, 31.52, *f.Lat, 1e-9)
	require.InDelta(t, 74.35, *f.Lng, 1e-9)
	require.InDelta(t, 62.5, *f.SpeedKmh, 1e-9)
	require.EqualValues(t, 128430000, *f.OdometerM)
	require.InDelta(t, 13.8, *f.BatteryVoltageV, 1e-9)
	require.True(t, *f.Ignition)
	// Appendix A letters come back in catalogue order (T before L).
	require.Equal(t, []string{eldproto.MalfunctionTiming, eldproto.MalfunctionPositioning}, f.Diagnostics)
	require.True(t, f.HasFix())
}

func TestDecodeOmittedFieldsStayNil(t *testing.T) {
	frames, err := pt30.New().Decode([]byte(sentence(
		"PT30,ELD-9,7,20260906051200,,,,,,,,,,,0,")))
	require.NoError(t, err)
	require.Len(t, frames, 1)

	f := frames[0]
	require.Nil(t, f.Lat)
	require.Nil(t, f.SpeedKmh)
	require.Nil(t, f.OdometerM)
	require.False(t, f.HasFix())
	require.False(t, *f.Ignition)
	require.Empty(t, f.Diagnostics)
}

func TestDecodeMultipleSentences(t *testing.T) {
	payload := sentence(full) + "\r\n" + sentence(full) + "\r\n"
	frames, err := pt30.New().Decode([]byte(payload))
	require.NoError(t, err)
	require.Len(t, frames, 2)
}

func TestDecodeRejectsCorruptPayloads(t *testing.T) {
	dec := pt30.New()
	cases := map[string]struct {
		in   string
		want error
	}{
		"bad checksum": {sentence(full)[:len(sentence(full))-1] + "0", eldproto.ErrBadChecksum},
		"no checksum":  {"$" + full, eldproto.ErrShortFrame},
		"truncated":    {sentence("PT30,ELD-1,1,20260906051200,31.5"), eldproto.ErrShortFrame},
		"bad time":     {sentence("PT30,ELD-1,1,nope,,,,,,,,,,,,"), eldproto.ErrShortFrame},
		"other vendor": {sentence("PTXX,ELD-1"), eldproto.ErrUnsupported},
	}
	for name, tc := range cases {
		t.Run(name, func(t *testing.T) {
			_, err := dec.Decode([]byte(tc.in))
			require.ErrorIs(t, err, tc.want)
		})
	}
}

func TestRegistered(t *testing.T) {
	d, err := eldproto.Get(pt30.Vendor)
	require.NoError(t, err)
	require.Equal(t, pt30.Vendor, d.Vendor())
}
