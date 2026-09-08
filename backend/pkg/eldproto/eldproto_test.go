package eldproto_test

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/pkg/eldproto"
	_ "github.com/devline/onebook-eld/pkg/eldproto/pt30"
	_ "github.com/devline/onebook-eld/pkg/eldproto/teltonika"
)

func TestNormalizeCodes(t *testing.T) {
	cases := map[string]struct {
		in   []string
		want []string
	}{
		"catalogue order": {[]string{"S", "P", "E"}, []string{"P", "E", "S"}},
		"drops unknown":   {[]string{"P", "X", "", "z"}, []string{"P"}},
		"drops duplicate": {[]string{"T", "T", "T"}, []string{"T"}},
		"empty":           {nil, []string{}},
	}
	for name, tc := range cases {
		t.Run(name, func(t *testing.T) {
			require.Equal(t, tc.want, eldproto.NormalizeCodes(tc.in))
		})
	}
}

func TestIsMalfunctionCode(t *testing.T) {
	for _, c := range eldproto.AllMalfunctionCodes {
		require.True(t, eldproto.IsMalfunctionCode(c))
	}
	require.False(t, eldproto.IsMalfunctionCode("X"))
	require.False(t, eldproto.IsMalfunctionCode("p"))
}

func TestRegistry(t *testing.T) {
	require.Equal(t, []string{"pt30", "teltonika"}, eldproto.Vendors())

	_, err := eldproto.Get("nope")
	require.ErrorIs(t, err, eldproto.ErrUnknownVendor)
}

func TestHasFix(t *testing.T) {
	require.False(t, eldproto.Frame{}.HasFix())
	require.False(t, eldproto.Frame{Lat: eldproto.Float(0), Lng: eldproto.Float(0)}.HasFix())
	require.False(t, eldproto.Frame{Lat: eldproto.Float(91), Lng: eldproto.Float(10)}.HasFix())
	require.True(t, eldproto.Frame{Lat: eldproto.Float(31.5), Lng: eldproto.Float(74.3)}.HasFix())
}
