package config

import (
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// baseConfig is a valid production configuration with both infrastructure
// surfaces still unguarded.
func baseConfig() *Config {
	return &Config{
		AppEnv:           EnvProd,
		DatabaseURL:      "postgres://u:p@localhost:5432/db",
		JWTSecret:        "0123456789abcdef0123456789abcdef",
		EncryptionKey:    "0123456789abcdef0123456789abcdef",
		AccessTokenTTL:   15 * time.Minute,
		RefreshTTLDriver: 720 * time.Hour,
		RefreshTTLAdmin:  168 * time.Hour,
		CORSOrigins:      []string{"https://app.example.com"},
		Metrics:          ExposureConfig{Enabled: true},
		Docs:             ExposureConfig{Enabled: true},
	}
}

// An unauthenticated /metrics or /api/docs must never reach production: the
// process refuses to start instead of exposing the endpoint catalogue, the
// traffic volume and the Go runtime.
func TestProductionRefusesUnguardedInfraSurfaces(t *testing.T) {
	c := baseConfig()
	err := c.Validate()
	require.Error(t, err)
	require.Contains(t, err.Error(), "METRICS_TOKEN")
	require.Contains(t, err.Error(), "DOCS_TOKEN")
}

func TestProductionAcceptsTokenOrAllowlist(t *testing.T) {
	c := baseConfig()
	c.Metrics.Token = "s3cret-metrics-token"
	c.Docs.AllowCIDR = []string{"10.0.0.0/8"}
	require.NoError(t, c.Validate())

	// Turning a surface off is the other accepted answer.
	off := baseConfig()
	off.Metrics.Enabled = false
	off.Docs.Enabled = false
	require.NoError(t, off.Validate())
}

func TestStagingIsTreatedAsProduction(t *testing.T) {
	c := baseConfig()
	c.AppEnv = EnvStaging
	require.Error(t, c.Validate())
}

// Development keeps both surfaces reachable without a credential.
func TestLocalKeepsInfraSurfacesOpen(t *testing.T) {
	c := baseConfig()
	c.AppEnv = EnvLocal
	c.CORSOrigins = nil
	require.NoError(t, c.Validate())
}

func TestAllowCIDREntriesMustParse(t *testing.T) {
	c := baseConfig()
	c.Metrics.AllowCIDR = []string{"10.0.0.0/8", "not-an-address"}
	c.Docs.Token = "x"
	err := c.Validate()
	require.Error(t, err)
	require.Contains(t, err.Error(), "not-an-address")

	ok := baseConfig()
	ok.Metrics.AllowCIDR = []string{"10.0.0.0/8", "192.168.1.10", "2001:db8::/32"}
	ok.Docs.Enabled = false
	require.NoError(t, ok.Validate())
}

func TestIsGuarded(t *testing.T) {
	require.False(t, ExposureConfig{Enabled: true}.IsGuarded())
	require.True(t, ExposureConfig{Enabled: true, Token: "t"}.IsGuarded())
	require.True(t, ExposureConfig{Enabled: true, AllowCIDR: []string{"10.0.0.0/8"}}.IsGuarded())
}
