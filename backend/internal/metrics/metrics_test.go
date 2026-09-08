package metrics

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/prometheus/client_golang/prometheus"
	dto "github.com/prometheus/client_model/go"
	"github.com/stretchr/testify/require"
)

type fakeHub struct{ n int }

func (f fakeHub) Count() int { return f.n }

type fakePool struct{ a, i, t int32 }

func (f fakePool) Stat() (int32, int32, int32) { return f.a, f.i, f.t }

// The route label must be the chi pattern, never the concrete path: an id in a
// label explodes the series count and leaks into the monitoring stack.
func TestHTTPMiddlewareLabelsWithRoutePattern(t *testing.T) {
	r := chi.NewRouter()
	r.Use(HTTPMiddleware(nil))
	r.Get("/api/v1/units/{id}", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"data":"ok"}`))
	})

	r.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodGet, "/api/v1/units/6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f", nil))

	labels := collectLabels(t, httpRequestDuration)
	require.Contains(t, labels, "GET|/api/v1/units/{id}|200")
	for l := range labels {
		require.NotContains(t, l, "6f1a1a5e", "a concrete id must never become a label value")
	}
}

// An unmatched path collapses into one series instead of one per scanned URL.
func TestRoutePatternFallsBackToUnmatched(t *testing.T) {
	r := httptest.NewRequest(http.MethodGet, "/nope", nil)
	require.Equal(t, "unmatched", routePattern(r))
}

// Registration is idempotent: a process that builds several routers re-points
// the gauge source instead of panicking on a duplicate collector.
func TestGaugeSourcesArePointers(t *testing.T) {
	RegisterWS(fakeHub{n: 7})
	RegisterDBPool(fakePool{a: 3, i: 5, t: 8})
	require.NotPanics(t, func() {
		RegisterWS(fakeHub{n: 2})
		RegisterDBPool(fakePool{a: 1, i: 1, t: 2})
	})

	a, i, total := poolStat()
	require.EqualValues(t, 1, a)
	require.EqualValues(t, 1, i)
	require.EqualValues(t, 2, total)

	RegisterWS(nil)
	RegisterDBPool(nil)
	a, i, total = poolStat()
	require.Zero(t, a+i+total, "a cleared source reports zero, it does not panic")
}

func TestClockDefaults(t *testing.T) {
	var c Clock
	require.WithinDuration(t, time.Now(), c.orDefault()(), time.Second)
}

// collectLabels gathers the label tuples of a collector as `a|b|c` keys.
func collectLabels(t testing.TB, c prometheus.Collector) map[string]struct{} {
	t.Helper()
	ch := make(chan prometheus.Metric, 128)
	go func() {
		c.Collect(ch)
		close(ch)
	}()
	out := map[string]struct{}{}
	for m := range ch {
		var pb dto.Metric
		require.NoError(t, m.Write(&pb))
		parts := make([]string, 0, len(pb.GetLabel()))
		for _, l := range pb.GetLabel() {
			parts = append(parts, l.GetValue())
		}
		out[strings.Join(parts, "|")] = struct{}{}
	}
	return out
}
