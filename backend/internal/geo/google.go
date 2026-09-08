package geo

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
)

// googleBaseURL is the public Maps Platform endpoint; it is a field so tests
// can point the provider at a stub server.
const googleBaseURL = "https://maps.googleapis.com/maps/api"

// Google is the commercial provider. It is only wired when an API key is
// configured; without one the factory falls back to Nop.
type Google struct {
	// APIKey is the Maps Platform key. It is never logged.
	APIKey string
	// BaseURL defaults to the public Maps Platform endpoint.
	BaseURL string
	// Region biases the geocoder, e.g. "us".
	Region string
	// Client defaults to a bounded http.Client.
	Client *http.Client
}

// NewGoogle builds the commercial provider.
func NewGoogle(apiKey, region string, client *http.Client) *Google {
	if client == nil {
		client = &http.Client{Timeout: defaultTimeout}
	}
	return &Google{APIKey: apiKey, BaseURL: googleBaseURL, Region: region, Client: client}
}

// Name implements Provider.
func (g *Google) Name() string { return ProviderGoogle }

type googleGeocodeResponse struct {
	Status  string `json:"status"`
	Message string `json:"error_message"`
	Results []struct {
		AddressComponents []struct {
			LongName  string   `json:"long_name"`
			ShortName string   `json:"short_name"`
			Types     []string `json:"types"`
		} `json:"address_components"`
		Geometry struct {
			Location struct {
				Lat float64 `json:"lat"`
				Lng float64 `json:"lng"`
			} `json:"location"`
		} `json:"geometry"`
	} `json:"results"`
}

// ReverseGeocode implements Provider.
func (g *Google) ReverseGeocode(ctx context.Context, lat, lng float64) (Place, error) {
	if g.APIKey == "" {
		return Place{}, ErrNotConfigured
	}
	at := Point{Lat: lat, Lng: lng}
	q := url.Values{}
	q.Set("latlng", strconv.FormatFloat(lat, 'f', 6, 64)+","+strconv.FormatFloat(lng, 'f', 6, 64))
	q.Set("result_type", "locality|administrative_area_level_3|administrative_area_level_2")
	q.Set("key", g.APIKey)

	var body googleGeocodeResponse
	if err := g.get(ctx, g.base()+"/geocode/json?"+q.Encode(), &body); err != nil {
		return Place{}, err
	}
	switch body.Status {
	case "OK":
	case "ZERO_RESULTS":
		return Place{Provider: ProviderGoogle}, nil
	default:
		// error_message can echo the key back; only the status is safe to log.
		return Place{}, fmt.Errorf("%w: google %s", ErrUpstream, body.Status)
	}
	if len(body.Results) == 0 {
		return Place{Provider: ProviderGoogle}, nil
	}

	res := body.Results[0]
	var city, state, country string
	for _, c := range res.AddressComponents {
		for _, t := range c.Types {
			switch t {
			case "locality", "postal_town":
				if city == "" {
					city = c.LongName
				}
			case "administrative_area_level_2":
				if city == "" {
					city = c.LongName
				}
			case "administrative_area_level_1":
				state = c.ShortName
			case "country":
				country = strings.ToUpper(c.ShortName)
			}
		}
	}
	if city == "" {
		return Place{Provider: ProviderGoogle}, nil
	}
	return Describe(Place{
		City:     city,
		State:    state,
		Country:  country,
		Center:   Point{Lat: res.Geometry.Location.Lat, Lng: res.Geometry.Location.Lng},
		Provider: ProviderGoogle,
	}, at), nil
}

type googleDirectionsResponse struct {
	Status string `json:"status"`
	Routes []struct {
		OverviewPolyline struct {
			Points string `json:"points"`
		} `json:"overview_polyline"`
		Legs []struct {
			Distance struct {
				Value int64 `json:"value"`
			} `json:"distance"`
			Duration struct {
				Value int64 `json:"value"`
			} `json:"duration"`
		} `json:"legs"`
	} `json:"routes"`
}

// Directions implements Provider.
func (g *Google) Directions(ctx context.Context, from, to Point) (Route, error) {
	if g.APIKey == "" {
		return Route{}, ErrNotConfigured
	}
	q := url.Values{}
	q.Set("origin", strconv.FormatFloat(from.Lat, 'f', 6, 64)+","+strconv.FormatFloat(from.Lng, 'f', 6, 64))
	q.Set("destination", strconv.FormatFloat(to.Lat, 'f', 6, 64)+","+strconv.FormatFloat(to.Lng, 'f', 6, 64))
	q.Set("mode", "driving")
	q.Set("key", g.APIKey)

	var body googleDirectionsResponse
	if err := g.get(ctx, g.base()+"/directions/json?"+q.Encode(), &body); err != nil {
		return Route{}, err
	}
	switch body.Status {
	case "OK":
	case "ZERO_RESULTS", "NOT_FOUND":
		return Route{Provider: ProviderGoogle}, nil
	default:
		return Route{}, fmt.Errorf("%w: google %s", ErrUpstream, body.Status)
	}
	if len(body.Routes) == 0 {
		return Route{Provider: ProviderGoogle}, nil
	}
	r := body.Routes[0]
	var distance, duration int64
	for _, leg := range r.Legs {
		distance += leg.Distance.Value
		duration += leg.Duration.Value
	}
	return Route{
		DistanceM: distance,
		DurationS: duration,
		Polyline:  r.OverviewPolyline.Points,
		Provider:  ProviderGoogle,
	}, nil
}

func (g *Google) base() string {
	if g.BaseURL != "" {
		return strings.TrimRight(g.BaseURL, "/")
	}
	return googleBaseURL
}

func (g *Google) get(ctx context.Context, endpoint string, out any) error {
	ctx, cancel := context.WithTimeout(ctx, defaultTimeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return fmt.Errorf("%w: %w", ErrUpstream, transportError(err))
	}
	req.Header.Set("Accept", "application/json")

	client := g.Client
	if client == nil {
		client = &http.Client{Timeout: defaultTimeout}
	}
	resp, err := client.Do(req)
	if err != nil {
		// transportError drops the URL: it carries `key=<GEO_API_KEY>`.
		return fmt.Errorf("%w: %w", ErrUpstream, transportError(err))
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("%w: status %d", ErrUpstream, resp.StatusCode)
	}
	if err := json.NewDecoder(io.LimitReader(resp.Body, maxBody)).Decode(out); err != nil {
		return fmt.Errorf("%w: malformed provider payload", ErrUpstream)
	}
	return nil
}

// compile time guards.
var (
	_ Provider = (*Google)(nil)
	_ Provider = (*OSM)(nil)
	_ Provider = (*Nop)(nil)
	_ Provider = (*Cached)(nil)
)
