package geo_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/geo"
)

// springfield is the reference town used across the table tests.
var springfield = geo.Point{Lat: 39.7817, Lng: -89.6501}

func TestFormatFMCSAMatchesTheRegulationText(t *testing.T) {
	t.Parallel()
	cases := []struct {
		name      string
		distanceM float64
		bearing   string
		city      string
		state     string
		want      string
	}{
		{"Q9 canonical form", 12_400, "NE", "Springfield", "IL", "12 km NE of Springfield, IL"},
		{"rounds to whole kilometres", 11_600, "NE", "Springfield", "IL", "12 km NE of Springfield, IL"},
		{"inside the town drops the prefix", 300, "N", "Springfield", "IL", "Springfield, IL"},
		{"no subdivision", 5_000, "SW", "Tashkent", "", "5 km SW of Tashkent"},
		{"no city is no text", 5_000, "SW", "", "IL", ""},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			require.Equal(t, tc.want, geo.FormatFMCSA(tc.distanceM, tc.bearing, tc.city, tc.state))
		})
	}
}

func TestCompass8CoversEveryOctant(t *testing.T) {
	t.Parallel()
	for deg, want := range map[float64]string{
		0: "N", 44: "NE", 90: "E", 135: "SE", 180: "S", 225: "SW", 270: "W", 315: "NW", 359: "N",
	} {
		require.Equal(t, want, geo.Compass8(deg), "bearing %v", deg)
	}
}

func TestGridCollapsesPointsInsideOneHundredMetres(t *testing.T) {
	t.Parallel()
	// ~30 m north of the reference point: same cell.
	near := geo.Point{Lat: springfield.Lat + 0.00027, Lng: springfield.Lng}
	require.Equal(t,
		geo.Grid(springfield.Lat, springfield.Lng, geo.DefaultGridM),
		geo.Grid(near.Lat, near.Lng, geo.DefaultGridM))

	// ~1 km east: different cell.
	far := geo.Point{Lat: springfield.Lat, Lng: springfield.Lng + 0.012}
	require.NotEqual(t,
		geo.Grid(springfield.Lat, springfield.Lng, geo.DefaultGridM),
		geo.Grid(far.Lat, far.Lng, geo.DefaultGridM))
}

// countingProvider records how often the upstream was actually called.
type countingProvider struct {
	calls int
	place geo.Place
	route geo.Route
}

func (c *countingProvider) ReverseGeocode(context.Context, float64, float64) (geo.Place, error) {
	c.calls++
	return c.place, nil
}

func (c *countingProvider) Directions(context.Context, geo.Point, geo.Point) (geo.Route, error) {
	c.calls++
	return c.route, nil
}

func (c *countingProvider) Name() string { return "counting" }

func TestCacheServesTheSameGridCellWithoutCallingTheProvider(t *testing.T) {
	t.Parallel()
	up := &countingProvider{place: geo.Place{
		City: "Springfield", State: "IL", Country: "US", Center: springfield, Provider: "counting",
		Text: "", DistanceM: 0,
	}}
	p := geo.NewCached(up, cache.NewMemoryStore(), geo.CacheOptions{})

	ctx := context.Background()
	// 12 km north-east of the town centre.
	at := geo.Point{Lat: springfield.Lat + 0.0765, Lng: springfield.Lng + 0.0995}

	first, err := p.ReverseGeocode(ctx, at.Lat, at.Lng)
	require.NoError(t, err)
	require.Equal(t, 1, up.calls)
	require.Equal(t, "12 km NE of Springfield, IL", first.Text)

	// Same cell, 30 m away: served from Redis, the provider is untouched.
	second, err := p.ReverseGeocode(ctx, at.Lat+0.00027, at.Lng)
	require.NoError(t, err)
	require.Equal(t, 1, up.calls, "second lookup inside the same 100 m cell must not hit the provider")
	require.Equal(t, first.City, second.City)
	require.Equal(t, "12 km NE of Springfield, IL", second.Text)

	// A different cell pays for a fresh lookup.
	_, err = p.ReverseGeocode(ctx, at.Lat+0.5, at.Lng)
	require.NoError(t, err)
	require.Equal(t, 2, up.calls)
}

func TestCacheNeverStoresAnEmptyAnswer(t *testing.T) {
	t.Parallel()
	up := &countingProvider{}
	p := geo.NewCached(up, cache.NewMemoryStore(), geo.CacheOptions{})

	for i := 0; i < 3; i++ {
		_, err := p.ReverseGeocode(context.Background(), springfield.Lat, springfield.Lng)
		require.NoError(t, err)
	}
	require.Equal(t, 3, up.calls, "an outage must not poison the grid for a month")
}

func TestDirectionsAreCachedPerOriginDestinationPair(t *testing.T) {
	t.Parallel()
	up := &countingProvider{route: geo.Route{DistanceM: 412_000, DurationS: 15_600, Polyline: "abc"}}
	p := geo.NewCached(up, cache.NewMemoryStore(), geo.CacheOptions{})

	from := springfield
	to := geo.Point{Lat: 41.8781, Lng: -87.6298}
	ctx := context.Background()

	a, err := p.Directions(ctx, from, to)
	require.NoError(t, err)
	b, err := p.Directions(ctx, from, to)
	require.NoError(t, err)
	require.Equal(t, 1, up.calls)
	require.Equal(t, a, b)

	_, err = p.Directions(ctx, to, from)
	require.NoError(t, err)
	require.Equal(t, 2, up.calls, "the reversed pair is a different route")
}

func TestNopProviderDegradesInsteadOfFailing(t *testing.T) {
	t.Parallel()
	p := geo.NewNop(nil)

	place, err := p.ReverseGeocode(context.Background(), springfield.Lat, springfield.Lng)
	require.NoError(t, err)
	require.True(t, place.Empty())

	route, err := p.Directions(context.Background(), springfield, springfield)
	require.NoError(t, err)
	require.True(t, route.Empty())
}

func TestNominatimBuildsTheFMCSAText(t *testing.T) {
	t.Parallel()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		require.Equal(t, "/reverse", r.URL.Path)
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"lat":"39.7817","lon":"-89.6501","address":{"city":"Springfield","ISO3166-2-lvl4":"US-IL","country_code":"us"}}`))
	}))
	defer srv.Close()

	p := geo.NewOSM(geo.ProviderNominatim, srv.URL, "", "", srv.Client())
	place, err := p.ReverseGeocode(context.Background(), springfield.Lat+0.0765, springfield.Lng+0.0995)
	require.NoError(t, err)
	require.Equal(t, "Springfield", place.City)
	require.Equal(t, "IL", place.State)
	require.Equal(t, "US", place.Country)
	require.Equal(t, "12 km NE of Springfield, IL", place.Text)
}

func TestOSRMDirectionsAreParsed(t *testing.T) {
	t.Parallel()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"code":"Ok","routes":[{"distance":412345.6,"duration":15600.2,"geometry":"_p~iF~ps|U"}]}`))
	}))
	defer srv.Close()

	p := geo.NewOSM(geo.ProviderNominatim, srv.URL, srv.URL, "", srv.Client())
	route, err := p.Directions(context.Background(), springfield, geo.Point{Lat: 41.8781, Lng: -87.6298})
	require.NoError(t, err)
	require.Equal(t, int64(412345), route.DistanceM)
	require.Equal(t, int64(15600), route.DurationS)
	require.Equal(t, "_p~iF~ps|U", route.Polyline)
}
