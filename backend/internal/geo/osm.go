package geo

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

// defaultTimeout bounds one provider call. Geocoding sits on the write path of
// duty status events, so it must fail fast rather than hold a transaction.
const defaultTimeout = 8 * time.Second

// maxBody caps the response we are willing to read from a provider.
const maxBody = 1 << 20

// OSM is the self hosted OpenStreetMap stack: Nominatim or Photon for reverse
// geocoding and OSRM for directions. All three speak plain HTTP JSON and carry
// no credentials, which is why they are the default deployment (TZ B§7.3).
type OSM struct {
	// Flavor selects the reverse geocoding dialect: ProviderNominatim or
	// ProviderPhoton.
	Flavor string
	// GeocodeURL is the base URL of the Nominatim/Photon instance, e.g.
	// "https://nominatim.example.com".
	GeocodeURL string
	// RoutingURL is the base URL of the OSRM instance. Empty disables
	// Directions, which then answers an empty route.
	RoutingURL string
	// UserAgent identifies the caller; the public Nominatim refuses requests
	// without one.
	UserAgent string
	// Client defaults to a bounded http.Client.
	Client *http.Client
}

// NewOSM builds a self hosted OSM provider.
func NewOSM(flavor, geocodeURL, routingURL, userAgent string, client *http.Client) *OSM {
	if flavor != ProviderPhoton {
		flavor = ProviderNominatim
	}
	if client == nil {
		client = &http.Client{Timeout: defaultTimeout}
	}
	if userAgent == "" {
		userAgent = "onebook-eld/1.0"
	}
	return &OSM{
		Flavor:     flavor,
		GeocodeURL: strings.TrimRight(geocodeURL, "/"),
		RoutingURL: strings.TrimRight(routingURL, "/"),
		UserAgent:  userAgent,
		Client:     client,
	}
}

// Name implements Provider.
func (o *OSM) Name() string {
	if o.Flavor == ProviderPhoton {
		return ProviderPhoton
	}
	return ProviderNominatim
}

// ReverseGeocode implements Provider.
func (o *OSM) ReverseGeocode(ctx context.Context, lat, lng float64) (Place, error) {
	if o.GeocodeURL == "" {
		return Place{}, ErrNotConfigured
	}
	at := Point{Lat: lat, Lng: lng}
	if o.Flavor == ProviderPhoton {
		return o.photon(ctx, at)
	}
	return o.nominatim(ctx, at)
}

// nominatimResponse is the subset of the jsonv2 payload we consume.
type nominatimResponse struct {
	Lat     string `json:"lat"`
	Lon     string `json:"lon"`
	Address struct {
		City         string `json:"city"`
		Town         string `json:"town"`
		Village      string `json:"village"`
		Hamlet       string `json:"hamlet"`
		Municipality string `json:"municipality"`
		County       string `json:"county"`
		State        string `json:"state"`
		StateCode    string `json:"ISO3166-2-lvl4"`
		CountryCode  string `json:"country_code"`
	} `json:"address"`
}

func (o *OSM) nominatim(ctx context.Context, at Point) (Place, error) {
	q := url.Values{}
	q.Set("format", "jsonv2")
	q.Set("lat", strconv.FormatFloat(at.Lat, 'f', 6, 64))
	q.Set("lon", strconv.FormatFloat(at.Lng, 'f', 6, 64))
	q.Set("zoom", "10") // city level; a house number would only add noise
	q.Set("addressdetails", "1")

	var body nominatimResponse
	if err := o.get(ctx, o.GeocodeURL+"/reverse?"+q.Encode(), &body); err != nil {
		return Place{}, err
	}
	city := firstNonEmpty(body.Address.City, body.Address.Town, body.Address.Village,
		body.Address.Hamlet, body.Address.Municipality, body.Address.County)
	if city == "" {
		return Place{Provider: o.Name()}, nil
	}
	center := Point{Lat: parseFloat(body.Lat), Lng: parseFloat(body.Lon)}
	return Describe(Place{
		City:     city,
		State:    subdivision(body.Address.StateCode, body.Address.State),
		Country:  strings.ToUpper(body.Address.CountryCode),
		Center:   center,
		Provider: o.Name(),
	}, at), nil
}

// photonResponse is the subset of the GeoJSON payload we consume.
type photonResponse struct {
	Features []struct {
		Geometry struct {
			Coordinates []float64 `json:"coordinates"` // [lng, lat]
		} `json:"geometry"`
		Properties struct {
			City    string `json:"city"`
			Name    string `json:"name"`
			County  string `json:"county"`
			State   string `json:"state"`
			Country string `json:"countrycode"`
		} `json:"properties"`
	} `json:"features"`
}

func (o *OSM) photon(ctx context.Context, at Point) (Place, error) {
	q := url.Values{}
	q.Set("lat", strconv.FormatFloat(at.Lat, 'f', 6, 64))
	q.Set("lon", strconv.FormatFloat(at.Lng, 'f', 6, 64))
	q.Set("limit", "1")

	var body photonResponse
	if err := o.get(ctx, o.GeocodeURL+"/reverse?"+q.Encode(), &body); err != nil {
		return Place{}, err
	}
	if len(body.Features) == 0 {
		return Place{Provider: o.Name()}, nil
	}
	f := body.Features[0]
	city := firstNonEmpty(f.Properties.City, f.Properties.Name, f.Properties.County)
	if city == "" {
		return Place{Provider: o.Name()}, nil
	}
	var center Point
	if len(f.Geometry.Coordinates) == 2 {
		center = Point{Lat: f.Geometry.Coordinates[1], Lng: f.Geometry.Coordinates[0]}
	}
	return Describe(Place{
		City:     city,
		State:    f.Properties.State,
		Country:  strings.ToUpper(f.Properties.Country),
		Center:   center,
		Provider: o.Name(),
	}, at), nil
}

// osrmResponse is the subset of the OSRM route payload we consume.
type osrmResponse struct {
	Code   string `json:"code"`
	Routes []struct {
		Distance float64 `json:"distance"`
		Duration float64 `json:"duration"`
		Geometry string  `json:"geometry"`
	} `json:"routes"`
}

// Directions implements Provider using OSRM.
func (o *OSM) Directions(ctx context.Context, from, to Point) (Route, error) {
	if o.RoutingURL == "" {
		return Route{Provider: o.Name()}, nil
	}
	path := fmt.Sprintf("%s/route/v1/driving/%s,%s;%s,%s?overview=full&geometries=polyline",
		o.RoutingURL,
		strconv.FormatFloat(from.Lng, 'f', 6, 64), strconv.FormatFloat(from.Lat, 'f', 6, 64),
		strconv.FormatFloat(to.Lng, 'f', 6, 64), strconv.FormatFloat(to.Lat, 'f', 6, 64))

	var body osrmResponse
	if err := o.get(ctx, path, &body); err != nil {
		return Route{}, err
	}
	if body.Code != "" && body.Code != "Ok" {
		return Route{}, fmt.Errorf("%w: osrm %s", ErrUpstream, body.Code)
	}
	if len(body.Routes) == 0 {
		return Route{Provider: o.Name()}, nil
	}
	r := body.Routes[0]
	return Route{
		DistanceM: int64(r.Distance),
		DurationS: int64(r.Duration),
		Polyline:  r.Geometry,
		Provider:  o.Name(),
	}, nil
}

func (o *OSM) get(ctx context.Context, endpoint string, out any) error {
	ctx, cancel := context.WithTimeout(ctx, defaultTimeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return fmt.Errorf("%w: %w", ErrUpstream, transportError(err))
	}
	req.Header.Set("User-Agent", o.UserAgent)
	req.Header.Set("Accept", "application/json")

	client := o.Client
	if client == nil {
		client = &http.Client{Timeout: defaultTimeout}
	}
	resp, err := client.Do(req)
	if err != nil {
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

// transportError strips the request URL out of a net/http failure. The URL of
// a provider call carries the API key (Google puts it in the query string) and
// the queried coordinates, which are PII: neither may reach an error string
// that is logged or wrapped into an API response.
func transportError(err error) error {
	var uerr *url.Error
	if errors.As(err, &uerr) {
		return fmt.Errorf("%s: %w", uerr.Op, uerr.Err)
	}
	return err
}

func firstNonEmpty(vs ...string) string {
	for _, v := range vs {
		if v = strings.TrimSpace(v); v != "" {
			return v
		}
	}
	return ""
}

// subdivision prefers the ISO 3166-2 code ("US-IL" → "IL") and falls back to
// the spelled out name, which is what the FMCSA text renders.
func subdivision(iso, name string) string {
	if iso != "" {
		if _, code, ok := strings.Cut(iso, "-"); ok && code != "" {
			return code
		}
		return iso
	}
	return name
}

func parseFloat(s string) float64 {
	v, _ := strconv.ParseFloat(s, 64)
	return v
}
