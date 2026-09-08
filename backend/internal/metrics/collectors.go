package metrics

import (
	"context"
	"log/slog"
	"sync/atomic"
	"time"

	"github.com/prometheus/client_golang/prometheus"
)

// Clock is an injectable time source; the zero value uses time.Now.
type Clock func() time.Time

func (c Clock) orDefault() Clock {
	if c == nil {
		return time.Now
	}
	return c
}

// ---------------------------------------------------------------- websocket

// WSCounter reports the number of live WebSocket connections. *ws.Hub
// implements it with Count().
type WSCounter interface {
	Count() int
}

// PoolStater reports the pgx pool utilisation. *db.Pool implements it with
// Stat().
type PoolStater interface {
	Stat() (acquired, idle, total int32)
}

// The gauges below are registered once, in init, and read their source through
// an atomic pointer. Registration therefore stays idempotent: a process that
// builds several routers (the integration test suite does) re-points the source
// instead of panicking on a duplicate collector.
var (
	wsSource   atomic.Pointer[WSCounter]
	poolSource atomic.Pointer[PoolStater]
)

// RegisterWS publishes the live WebSocket connection gauge. Passing nil clears
// the source, so a build without the hub simply reports zero.
func RegisterWS(hub WSCounter) {
	if hub == nil {
		wsSource.Store(nil)
		return
	}
	wsSource.Store(&hub)
}

// RegisterDBPool publishes the connection pool gauges. Saturation shows up as
// acquired == total with idle at zero.
func RegisterDBPool(pool PoolStater) {
	if pool == nil {
		poolSource.Store(nil)
		return
	}
	poolSource.Store(&pool)
}

func poolStat() (int32, int32, int32) {
	if p := poolSource.Load(); p != nil {
		return (*p).Stat()
	}
	return 0, 0, 0
}

func init() {
	prometheus.MustRegister(prometheus.NewGaugeFunc(prometheus.GaugeOpts{
		Namespace: Namespace,
		Subsystem: "ws",
		Name:      "connections",
		Help:      "Live WebSocket connections held by this instance.",
	}, func() float64 {
		if h := wsSource.Load(); h != nil {
			return float64((*h).Count())
		}
		return 0
	}))

	gauge := func(name, help string, pick func(a, i, t int32) float64) prometheus.Collector {
		return prometheus.NewGaugeFunc(prometheus.GaugeOpts{
			Namespace: Namespace, Subsystem: "db_pool", Name: name, Help: help,
		}, func() float64 {
			a, i, t := poolStat()
			return pick(a, i, t)
		})
	}
	prometheus.MustRegister(
		gauge("acquired_connections", "Connections currently checked out of the pool.",
			func(a, _, _ int32) float64 { return float64(a) }),
		gauge("idle_connections", "Connections sitting idle in the pool.",
			func(_, i, _ int32) float64 { return float64(i) }),
		gauge("total_connections", "Connections owned by the pool.",
			func(_, _, t int32) float64 { return float64(t) }),
	)
}

// ---------------------------------------------------------------- queue lag

// QueueStat is one asynq queue snapshot.
type QueueStat struct {
	Queue string
	// Size is every task in the queue, whatever its state.
	Size int
	// Pending waits for a free worker; a growing value is the lag signal.
	Pending   int
	Active    int
	Scheduled int
	Retry     int
	// Latency is how long the oldest pending task has been waiting.
	Latency time.Duration
}

// QueueStatsSource reads the queue snapshots. The asynq inspector adapter
// lives in the worker wiring so this package stays free of a Redis client.
type QueueStatsSource interface {
	QueueStats(ctx context.Context) ([]QueueStat, error)
}

var (
	queueSize = prometheus.NewGaugeVec(prometheus.GaugeOpts{
		Namespace: Namespace, Subsystem: "queue", Name: "tasks",
		Help: "Tasks per asynq queue and state.",
	}, []string{"queue", "state"})

	queueLatency = prometheus.NewGaugeVec(prometheus.GaugeOpts{
		Namespace: Namespace, Subsystem: "queue", Name: "latency_seconds",
		Help: "Age of the oldest pending task per asynq queue.",
	}, []string{"queue"})

	queueScrapeErrors = prometheus.NewCounter(prometheus.CounterOpts{
		Namespace: Namespace, Subsystem: "queue", Name: "scrape_errors_total",
		Help: "Failed asynq inspector scrapes.",
	})
)

func init() {
	prometheus.MustRegister(queueSize, queueLatency, queueScrapeErrors)
}

// DefaultQueueScrapeInterval is how often the queue gauges are refreshed.
const DefaultQueueScrapeInterval = 15 * time.Second

// PollQueues refreshes the queue gauges until ctx is cancelled. Run it in a
// goroutine from the worker; a scrape failure only increments a counter, it
// never stops the loop.
func PollQueues(ctx context.Context, src QueueStatsSource, interval time.Duration, log *slog.Logger) {
	if src == nil {
		return
	}
	if interval <= 0 {
		interval = DefaultQueueScrapeInterval
	}
	if log == nil {
		log = slog.Default()
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		if err := scrapeQueues(ctx, src); err != nil {
			queueScrapeErrors.Inc()
			log.WarnContext(ctx, "metrics: queue scrape failed", slog.String("error", err.Error()))
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
	}
}

func scrapeQueues(ctx context.Context, src QueueStatsSource) error {
	stats, err := src.QueueStats(ctx)
	if err != nil {
		return err
	}
	for _, s := range stats {
		queueSize.WithLabelValues(s.Queue, "total").Set(float64(s.Size))
		queueSize.WithLabelValues(s.Queue, "pending").Set(float64(s.Pending))
		queueSize.WithLabelValues(s.Queue, "active").Set(float64(s.Active))
		queueSize.WithLabelValues(s.Queue, "scheduled").Set(float64(s.Scheduled))
		queueSize.WithLabelValues(s.Queue, "retry").Set(float64(s.Retry))
		queueLatency.WithLabelValues(s.Queue).Set(s.Latency.Seconds())
	}
	return nil
}
