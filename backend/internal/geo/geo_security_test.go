// Secret hygiene of the map providers. Google puts the API key in the query
// string, so any error text that carries the request URL leaks GEO_API_KEY into
// the logs (TZ B§3.5: keys never reach a log line), and the OSM URL carries the
// queried coordinates, which are PII.
package geo

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

const testKey = "AIzaSyTOPSECRETKEY0000000000000000000000"

// deadServer returns the base URL of a server that is already closed, so every
// call fails at the transport level — the path that used to echo the URL.
func deadServer(t *testing.T) string {
	t.Helper()
	srv := httptest.NewServer(http.NotFoundHandler())
	url := srv.URL
	srv.Close()
	return url
}

func TestGoogleTransportErrorNeverCarriesTheAPIKey(t *testing.T) {
	g := NewGoogle(testKey, "us", nil)
	g.BaseURL = deadServer(t)

	_, err := g.ReverseGeocode(context.Background(), 39.7817, -89.6501)
	require.Error(t, err)
	requireNoSecret(t, err.Error())

	_, err = g.Directions(context.Background(),
		Point{Lat: 39.7817, Lng: -89.6501}, Point{Lat: 41.8781, Lng: -87.6298})
	require.Error(t, err)
	requireNoSecret(t, err.Error())
}

func TestGoogleUpstreamStatusErrorNeverCarriesTheAPIKey(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusForbidden)
	}))
	defer srv.Close()

	g := NewGoogle(testKey, "", nil)
	g.BaseURL = srv.URL
	_, err := g.Directions(context.Background(), Point{Lat: 1, Lng: 1}, Point{Lat: 2, Lng: 2})
	require.Error(t, err)
	requireNoSecret(t, err.Error())
}

func TestGoogleProviderErrorMessageIsNotEchoed(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		// A real Maps error_message echoes the key back at the caller.
		_, _ = w.Write([]byte(`{"status":"REQUEST_DENIED","error_message":"The provided API key ` +
			testKey + ` is invalid."}`))
	}))
	defer srv.Close()

	g := NewGoogle(testKey, "", nil)
	g.BaseURL = srv.URL
	_, err := g.ReverseGeocode(context.Background(), 39.7817, -89.6501)
	require.Error(t, err)
	requireNoSecret(t, err.Error())
}

func TestOSMTransportErrorNeverCarriesTheCoordinates(t *testing.T) {
	o := NewOSM(ProviderNominatim, deadServer(t), deadServer(t), "onebook-eld/test", nil)

	_, err := o.ReverseGeocode(context.Background(), 39.7817, -89.6501)
	require.Error(t, err)
	require.NotContains(t, err.Error(), "39.7817", "a coordinate is PII and must not reach an error string")
	require.NotContains(t, err.Error(), "-89.6501")

	_, err = o.Directions(context.Background(),
		Point{Lat: 39.7817, Lng: -89.6501}, Point{Lat: 41.8781, Lng: -87.6298})
	require.Error(t, err)
	require.NotContains(t, err.Error(), "39.7817")
	require.NotContains(t, err.Error(), "41.8781")
}

func requireNoSecret(t *testing.T, msg string) {
	t.Helper()
	require.NotContains(t, msg, testKey, "the map provider key must never reach an error string")
	require.False(t, strings.Contains(msg, "key="), "the signed query string must not be echoed")
}
