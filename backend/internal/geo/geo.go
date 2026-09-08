// Package geo is the map provider abstraction of the platform (TZ B§7.3).
//
// Two operations are needed by the domain: turning a coordinate into the FMCSA
// style location text every log and DVIR record carries (Q9), and drawing the
// line between two stops for the trip planner (Q66.1). Both are billed per call
// by every commercial provider, so this package is written around a cache: the
// concrete providers are dumb HTTP clients and Cached() is what production
// wires.
//
// Coordinates are WGS84 degrees, distances are metres and durations are
// seconds, matching the rest of the backend.
package geo

import (
	"context"
	"errors"
	"log/slog"
	"sync"
)

// Provider names, used in logs and in the cache key namespace.
const (
	ProviderNominatim = "nominatim"
	ProviderPhoton    = "photon"
	ProviderGoogle    = "google"
	ProviderNop       = "nop"
)

// Errors returned by this package. They are transport level: the domain maps
// them to apierr, this package never imports it.
var (
	// ErrNotConfigured means no usable provider was wired.
	ErrNotConfigured = errors.New("geo: no map provider is configured")
	// ErrNoResult means the provider answered successfully with nothing.
	ErrNoResult = errors.New("geo: provider returned no result")
	// ErrUpstream wraps a provider side failure (HTTP status, bad payload).
	ErrUpstream = errors.New("geo: provider request failed")
)

// Point is a WGS84 coordinate.
type Point struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}

// Valid reports whether the point is inside the coordinate domain. The zero
// value (0,0) is treated as unset because no fleet operates in the Gulf of
// Guinea and an accidental zero must never be geocoded.
func (p Point) Valid() bool {
	if p.Lat == 0 && p.Lng == 0 {
		return false
	}
	return p.Lat >= -90 && p.Lat <= 90 && p.Lng >= -180 && p.Lng <= 180
}

// Place is one reverse geocoding answer.
type Place struct {
	// Text is the FMCSA formatted location, e.g. "12 km NE of Springfield, IL"
	// (Q9). It is the only field the log record stores.
	Text string `json:"text"`
	// City is the nearest named place.
	City string `json:"city"`
	// State is the ISO 3166-2 subdivision code without the country prefix
	// ("IL", "ON") when the provider exposes one, otherwise the full name.
	State string `json:"state"`
	// Country is the ISO 3166-1 alpha-2 code, upper case.
	Country string `json:"country"`
	// Center is the coordinate of City, used to derive DistanceM and Bearing.
	Center Point `json:"center"`
	// DistanceM is the distance from the queried point to City in metres.
	DistanceM float64 `json:"distance_m"`
	// Bearing is the eight point compass direction from City to the queried
	// point ("NE"), i.e. the direction the FMCSA text reads.
	Bearing string `json:"bearing"`
	// Provider is the name of the source that answered.
	Provider string `json:"provider"`
}

// Empty reports whether the answer carries nothing usable.
func (p Place) Empty() bool { return p.Text == "" && p.City == "" }

// Route is one directions answer.
type Route struct {
	// DistanceM is the driving distance in metres.
	DistanceM int64 `json:"distance_m"`
	// DurationS is the estimated driving time in seconds.
	DurationS int64 `json:"duration_s"`
	// Polyline is the geometry in Google's encoded polyline algorithm format
	// (precision 5), which both OSRM and Google emit natively.
	Polyline string `json:"polyline"`
	// Provider is the name of the source that answered.
	Provider string `json:"provider"`
}

// Empty reports whether the answer carries nothing usable.
func (r Route) Empty() bool { return r.DistanceM == 0 && r.Polyline == "" }

// Provider is the map provider surface the domain depends on. Every
// implementation in this package is safe for concurrent use.
type Provider interface {
	// ReverseGeocode turns a coordinate into a named place.
	ReverseGeocode(ctx context.Context, lat, lng float64) (Place, error)
	// Directions returns the driving route between two points.
	Directions(ctx context.Context, from, to Point) (Route, error)
	// Name identifies the implementation; it namespaces the cache keys.
	Name() string
}

// Nop is the provider used when no credentials are configured. It warns once
// and then answers empty results without an error, so a deployment without a
// map key degrades to "no location text" instead of failing every write path.
type Nop struct {
	log  *slog.Logger
	once sync.Once
}

// NewNop builds the degraded provider.
func NewNop(log *slog.Logger) *Nop {
	if log == nil {
		log = slog.Default()
	}
	return &Nop{log: log}
}

func (n *Nop) warn(ctx context.Context) {
	n.once.Do(func() {
		n.log.WarnContext(ctx, "geo: no map provider configured, location text and route geometry are disabled")
	})
}

// ReverseGeocode implements Provider.
func (n *Nop) ReverseGeocode(ctx context.Context, _, _ float64) (Place, error) {
	n.warn(ctx)
	return Place{Provider: ProviderNop}, nil
}

// Directions implements Provider.
func (n *Nop) Directions(ctx context.Context, _, _ Point) (Route, error) {
	n.warn(ctx)
	return Route{Provider: ProviderNop}, nil
}

// Name implements Provider.
func (n *Nop) Name() string { return ProviderNop }
