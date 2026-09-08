package geo

import (
	"log/slog"
	"net/http"
	"strings"

	"github.com/devline/onebook-eld/internal/cache"
)

// Config is the map provider configuration (TZ B§7.3). It is loaded from the
// environment by internal/config and handed to New at wiring time.
type Config struct {
	// Provider selects the implementation: "nominatim", "photon", "google" or
	// "" / "nop" for the degraded one.
	Provider string `env:"PROVIDER" envDefault:"nominatim"`
	// GeocodeURL is the self hosted Nominatim/Photon base URL.
	GeocodeURL string `env:"GEOCODE_URL"`
	// RoutingURL is the self hosted OSRM base URL.
	RoutingURL string `env:"ROUTING_URL"`
	// APIKey is the Google Maps Platform key.
	APIKey string `env:"API_KEY"`
	// Region biases the Google geocoder, e.g. "us".
	Region string `env:"REGION"`
	// UserAgent identifies this deployment to the OSM stack.
	UserAgent string `env:"USER_AGENT" envDefault:"onebook-eld/1.0"`
	// GridM overrides the reverse geocoding cache cell size in metres.
	GridM float64 `env:"CACHE_GRID_M" envDefault:"100"`
}

// New builds the provider described by cfg, wrapped in the grid cache.
//
// A configuration that cannot produce a working provider degrades to Nop with a
// warning rather than failing the boot: a missing map key must not stop a fleet
// from recording hours of service.
func New(cfg Config, store cache.Store, client *http.Client, log *slog.Logger) Provider {
	if log == nil {
		log = slog.Default()
	}
	var p Provider
	switch strings.ToLower(strings.TrimSpace(cfg.Provider)) {
	case ProviderGoogle:
		if cfg.APIKey == "" {
			log.Warn("geo: google selected without GEO_API_KEY, falling back to the nop provider")
			p = NewNop(log)
		} else {
			p = NewGoogle(cfg.APIKey, cfg.Region, client)
		}
	case ProviderNominatim, ProviderPhoton:
		if cfg.GeocodeURL == "" {
			log.Warn("geo: self hosted provider selected without GEO_GEOCODE_URL, falling back to the nop provider",
				slog.String("provider", cfg.Provider))
			p = NewNop(log)
		} else {
			p = NewOSM(strings.ToLower(cfg.Provider), cfg.GeocodeURL, cfg.RoutingURL, cfg.UserAgent, client)
		}
	default:
		p = NewNop(log)
	}
	return NewCached(p, store, CacheOptions{GridM: cfg.GridM, Log: log})
}
