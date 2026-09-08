// Package metrics owns the Prometheus instrumentation of the API and the
// worker. Everything is registered on the default registry, which
// promhttp.Handler() exposes behind the gated /metrics route (TZ B§14).
//
// Cardinality rule: a label value is always a bounded set. HTTP metrics are
// labelled with the chi *route pattern* (`/api/v1/units/{id}`), never the
// concrete path, so an id can never explode the series count or leak into the
// monitoring stack.
package metrics

import (
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/prometheus/client_golang/prometheus"
)

// Namespace prefixes every series of this service.
const Namespace = "eld"

var (
	// httpRequestDuration is the request latency histogram. The buckets cover
	// a cached read (5 ms) through a heavy export (10 s).
	httpRequestDuration = prometheus.NewHistogramVec(prometheus.HistogramOpts{
		Namespace: Namespace,
		Subsystem: "http",
		Name:      "request_duration_seconds",
		Help:      "HTTP request latency by route pattern, method and status class.",
		Buckets:   []float64{0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10},
	}, []string{"route", "method", "status"})

	// httpRequestsInFlight tracks concurrency, so a saturated pool is visible
	// before the latency histogram moves.
	httpRequestsInFlight = prometheus.NewGauge(prometheus.GaugeOpts{
		Namespace: Namespace,
		Subsystem: "http",
		Name:      "requests_in_flight",
		Help:      "Number of HTTP requests currently being served.",
	})

	// httpResponseSize records the payload size of list and export endpoints.
	httpResponseSize = prometheus.NewHistogramVec(prometheus.HistogramOpts{
		Namespace: Namespace,
		Subsystem: "http",
		Name:      "response_size_bytes",
		Help:      "HTTP response body size by route pattern.",
		Buckets:   prometheus.ExponentialBuckets(256, 4, 8),
	}, []string{"route"})
)

func init() {
	prometheus.MustRegister(httpRequestDuration, httpRequestsInFlight, httpResponseSize)
}

// sizeWriter captures the status code and the byte count of a response while
// staying transparent to the WebSocket upgrade and to streaming handlers.
type sizeWriter struct {
	http.ResponseWriter
	status int
	bytes  int
}

func (w *sizeWriter) WriteHeader(code int) {
	if w.status == 0 {
		w.status = code
		w.ResponseWriter.WriteHeader(code)
	}
}

func (w *sizeWriter) Write(b []byte) (int, error) {
	if w.status == 0 {
		w.status = http.StatusOK
	}
	n, err := w.ResponseWriter.Write(b)
	w.bytes += n
	return n, err
}

// Unwrap exposes the wrapped writer for http.ResponseController.
func (w *sizeWriter) Unwrap() http.ResponseWriter { return w.ResponseWriter }

// HTTPMiddleware instruments every request. It must run after chi has matched
// the route, so it reads the pattern from the route context on the way out.
func HTTPMiddleware(now Clock) func(http.Handler) http.Handler {
	clock := now.orDefault()
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := clock()
			sw := &sizeWriter{ResponseWriter: w}

			httpRequestsInFlight.Inc()
			defer httpRequestsInFlight.Dec()

			next.ServeHTTP(sw, r)

			if sw.status == 0 {
				sw.status = http.StatusOK
			}
			route := routePattern(r)
			httpRequestDuration.WithLabelValues(route, r.Method, strconv.Itoa(sw.status)).
				Observe(clock().Sub(start).Seconds())
			httpResponseSize.WithLabelValues(route).Observe(float64(sw.bytes))
		})
	}
}

// routePattern returns the chi pattern of the matched route, or a constant
// placeholder. Unmatched paths collapse into one series instead of one per
// scanned URL.
func routePattern(r *http.Request) string {
	if rc := chi.RouteContext(r.Context()); rc != nil {
		if p := rc.RoutePattern(); p != "" {
			return p
		}
	}
	return "unmatched"
}
