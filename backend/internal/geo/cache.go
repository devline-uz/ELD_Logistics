package geo

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"time"

	"github.com/devline/onebook-eld/internal/cache"
)

// DefaultGridM is the side of the reverse geocoding cache cell in metres
// (TZ B§7.3). Reverse geocoding is the single largest variable cost of the
// platform: every duty status event, DVIR and unidentified record needs a
// location text, and a fleet reports a sample every 30 s or 300 m. Collapsing
// them onto a 100 m grid turns a per sample bill into a per street corner one
// without changing the rendered text, which is rounded to whole kilometres.
const DefaultGridM = 100

// Cache TTLs. A town does not move, so the reverse geocoding entry lives long;
// a route can change with road work, so directions expire within the day.
const (
	// DefaultPlaceTTL is how long one grid cell keeps its place.
	DefaultPlaceTTL = 30 * 24 * time.Hour
	// DefaultRouteTTL is how long one origin/destination pair keeps its route.
	DefaultRouteTTL = 24 * time.Hour
)

// keyPrefix namespaces every entry this package writes into the shared store.
const keyPrefix = "geo:"

// Cached decorates a Provider with the Redis backed grid cache. It is what
// production wires; the bare providers are only used by tests and by Cached
// itself.
type Cached struct {
	next     Provider
	store    cache.Store
	log      *slog.Logger
	gridM    float64
	placeTTL time.Duration
	routeTTL time.Duration
}

// CacheOptions tunes the decorator. The zero value is valid and applies the
// package defaults.
type CacheOptions struct {
	// GridM overrides the reverse geocoding cell size in metres.
	GridM float64
	// PlaceTTL overrides the reverse geocoding entry lifetime.
	PlaceTTL time.Duration
	// RouteTTL overrides the directions entry lifetime.
	RouteTTL time.Duration
	// Log receives cache decode failures; nil uses slog.Default.
	Log *slog.Logger
}

// NewCached wraps next with the grid cache. A nil store returns next unchanged
// so a test or a degraded boot still has a working provider.
func NewCached(next Provider, store cache.Store, opts CacheOptions) Provider {
	if next == nil {
		next = NewNop(opts.Log)
	}
	if store == nil {
		return next
	}
	c := &Cached{
		next:     next,
		store:    store,
		log:      opts.Log,
		gridM:    opts.GridM,
		placeTTL: opts.PlaceTTL,
		routeTTL: opts.RouteTTL,
	}
	if c.log == nil {
		c.log = slog.Default()
	}
	if c.gridM <= 0 {
		c.gridM = DefaultGridM
	}
	if c.placeTTL <= 0 {
		c.placeTTL = DefaultPlaceTTL
	}
	if c.routeTTL <= 0 {
		c.routeTTL = DefaultRouteTTL
	}
	return c
}

// Name implements Provider; the cache is transparent.
func (c *Cached) Name() string { return c.next.Name() }

// PlaceKey is the cache key of one reverse geocoding cell. It is exported so
// tests and cache warmers can address the same entry.
func PlaceKey(provider string, lat, lng, gridM float64) string {
	cell := Grid(lat, lng, gridM)
	return fmt.Sprintf("%srev:%s:%d:%d", keyPrefix, provider, cell.Lat, cell.Lng)
}

// RouteKey is the cache key of one directions pair, quantised on the same grid
// so a driver re-opening the same route never pays twice.
func RouteKey(provider string, from, to Point, gridM float64) string {
	a := Grid(from.Lat, from.Lng, gridM)
	b := Grid(to.Lat, to.Lng, gridM)
	return fmt.Sprintf("%sdir:%s:%d:%d:%d:%d", keyPrefix, provider, a.Lat, a.Lng, b.Lat, b.Lng)
}

// ReverseGeocode implements Provider, serving from the 100 m grid cache.
func (c *Cached) ReverseGeocode(ctx context.Context, lat, lng float64) (Place, error) {
	key := PlaceKey(c.next.Name(), lat, lng, c.gridM)
	if raw, ok, err := c.store.Get(ctx, key); err == nil && ok {
		var p Place
		if json.Unmarshal([]byte(raw), &p) == nil {
			// The cell is shared, the queried point is not: recompute the
			// distance and bearing so the text stays honest at the cell edge.
			p.Text = ""
			return Describe(p, Point{Lat: lat, Lng: lng}), nil
		}
		c.log.WarnContext(ctx, "geo: dropping undecodable cache entry",
			slog.String("kind", "reverse"), slog.String("provider", c.next.Name()))
	}

	p, err := c.next.ReverseGeocode(ctx, lat, lng)
	if err != nil {
		return p, err
	}
	// Normalise here as well so a provider that only fills city/state still
	// answers the FMCSA text, and so hit and miss return the same shape.
	p = Describe(p, Point{Lat: lat, Lng: lng})
	if p.Empty() {
		// Never cache "nothing": an outage would poison the grid for a month.
		return p, nil
	}
	c.put(ctx, key, p, c.placeTTL)
	return p, nil
}

// Directions implements Provider.
func (c *Cached) Directions(ctx context.Context, from, to Point) (Route, error) {
	key := RouteKey(c.next.Name(), from, to, c.gridM)
	if raw, ok, err := c.store.Get(ctx, key); err == nil && ok {
		var r Route
		if json.Unmarshal([]byte(raw), &r) == nil {
			return r, nil
		}
		c.log.WarnContext(ctx, "geo: dropping undecodable cache entry",
			slog.String("kind", "directions"), slog.String("provider", c.next.Name()))
	}

	r, err := c.next.Directions(ctx, from, to)
	if err != nil || r.Empty() {
		return r, err
	}
	c.put(ctx, key, r, c.routeTTL)
	return r, nil
}

// put stores one entry, treating a cache failure as a miss: a broken Redis must
// slow the platform down, never break it.
func (c *Cached) put(ctx context.Context, key string, v any, ttl time.Duration) {
	raw, err := json.Marshal(v)
	if err != nil {
		return
	}
	if err := c.store.Set(ctx, key, string(raw), ttl); err != nil {
		// The key embeds the grid cell, i.e. a coordinate: it is PII and is
		// never logged (TZ B§6.1 logging rules).
		c.log.WarnContext(ctx, "geo: cache write failed",
			slog.String("provider", c.next.Name()), slog.String("error", err.Error()))
	}
}
