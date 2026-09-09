// Package config loads and validates process configuration from the environment.
package config

import (
	"errors"
	"fmt"
	"net/netip"
	"strings"
	"time"

	"github.com/caarlos0/env/v11"

	"github.com/devline/onebook-eld/internal/geo"
)

// Environment names.
const (
	EnvLocal   = "local"
	EnvDev     = "dev"
	EnvStaging = "staging"
	EnvProd    = "prod"
)

// Config is the full application configuration.
type Config struct {
	AppEnv        string `env:"APP_ENV" envDefault:"local"`
	Region        string `env:"REGION" envDefault:"us-east-1"`
	HTTPAddr      string `env:"HTTP_ADDR" envDefault:":8080"`
	PublicBaseURL string `env:"PUBLIC_BASE_URL" envDefault:"http://localhost:8080"`
	LogLevel      string `env:"LOG_LEVEL" envDefault:"info"`
	SentryDSN     string `env:"SENTRY_DSN"`

	DatabaseURL string `env:"DATABASE_URL,required"`
	RedisURL    string `env:"REDIS_URL" envDefault:"redis://localhost:6379/0"`

	JWTSecret     string `env:"JWT_SECRET,required"`
	EncryptionKey string `env:"ENCRYPTION_KEY,required"`

	TOTPIssuer string `env:"TOTP_ISSUER" envDefault:"ONEBOOK ELD"`

	// TOTPEnrolmentRequired gates the mandatory 2FA enrolment of Super Admin
	// and Administrator accounts (TZ B§3.4). It defaults to on; setting
	// AUTH_TOTP_ENROLMENT_REQUIRED=false lets those roles sign in with the
	// password alone, which is a temporary demo concession and must be turned
	// back on before the platform is handed to real operators. Accounts that
	// already enrolled keep being asked for their code either way.
	TOTPEnrolmentRequired bool `env:"AUTH_TOTP_ENROLMENT_REQUIRED" envDefault:"true"`

	AccessTokenTTL   time.Duration `env:"ACCESS_TOKEN_TTL" envDefault:"15m"`
	RefreshTTLDriver time.Duration `env:"REFRESH_TTL_DRIVER" envDefault:"720h"`
	RefreshTTLAdmin  time.Duration `env:"REFRESH_TTL_ADMIN" envDefault:"168h"`

	CORSOrigins []string `env:"CORS_ORIGINS" envSeparator:","`

	S3 S3Config `envPrefix:"S3_"`

	RateLimit RateLimitConfig `envPrefix:"RATE_LIMIT_"`

	Metrics ExposureConfig `envPrefix:"METRICS_"`
	Docs    ExposureConfig `envPrefix:"DOCS_"`

	// Notify holds the notification provider credentials. Every field is
	// optional: a missing credential disables that channel with a warning
	// instead of failing the boot (TZ Q89).
	Notify NotifyConfig `envPrefix:"NOTIFY_"`

	// WS tunes the realtime transport.
	WS WSConfig `envPrefix:"WS_"`

	// Geo selects the map provider used for reverse geocoding and route
	// drawing. Every field is optional: without one the platform falls back to
	// the nop provider with a warning (TZ B§7.3).
	Geo geo.Config `envPrefix:"GEO_"`
}

// NotifyConfig holds the notification provider credentials.
type NotifyConfig struct {
	FCM      FCMConfig      `envPrefix:"FCM_"`
	APNs     APNsConfig     `envPrefix:"APNS_"`
	SMTP     SMTPConfig     `envPrefix:"SMTP_"`
	SMS      SMSConfig      `envPrefix:"SMS_"`
	Telegram TelegramConfig `envPrefix:"TELEGRAM_"`
}

// FCMConfig configures Firebase Cloud Messaging (HTTP v1).
type FCMConfig struct {
	ProjectID string `env:"PROJECT_ID"`
	// ServiceAccountFile points at the service account JSON key.
	ServiceAccountFile string `env:"SERVICE_ACCOUNT_FILE"`
	// ServiceAccountJSON carries the key inline (secret manager deployments).
	ServiceAccountJSON string `env:"SERVICE_ACCOUNT_JSON"`
}

// APNsConfig configures the Apple Push Notification service.
type APNsConfig struct {
	// AuthKeyFile points at the .p8 provider key.
	AuthKeyFile string `env:"AUTH_KEY_FILE"`
	AuthKeyP8   string `env:"AUTH_KEY"`
	KeyID       string `env:"KEY_ID"`
	TeamID      string `env:"TEAM_ID"`
	Topic       string `env:"TOPIC"`
	Production  bool   `env:"PRODUCTION" envDefault:"false"`
}

// SMTPConfig configures the email channel.
type SMTPConfig struct {
	Host     string `env:"HOST"`
	Port     int    `env:"PORT" envDefault:"587"`
	Username string `env:"USERNAME"`
	Password string `env:"PASSWORD"`
	From     string `env:"FROM"`
	StartTLS bool   `env:"STARTTLS" envDefault:"true"`
}

// SMSConfig configures the generic HTTP SMS gateway.
type SMSConfig struct {
	Endpoint  string `env:"ENDPOINT"`
	Token     string `env:"TOKEN"`
	ToField   string `env:"TO_FIELD" envDefault:"to"`
	TextField string `env:"TEXT_FIELD" envDefault:"text"`
}

// TelegramConfig configures the Telegram bot channel (TZ Q89 [MAY]).
type TelegramConfig struct {
	BotToken string `env:"BOT_TOKEN"`
}

// WSConfig tunes the WebSocket transport.
type WSConfig struct {
	// AllowedOrigins is the browser origin allowlist of the upgrade handshake.
	// Empty means same-origin only.
	AllowedOrigins []string `env:"ALLOWED_ORIGINS" envSeparator:","`
	// Enabled turns the realtime endpoint off entirely.
	Enabled bool `env:"ENABLED" envDefault:"true"`
	// PingPeriod is the server side keepalive interval (TZ B§3 default 30 s).
	PingPeriod time.Duration `env:"PING_PERIOD" envDefault:"30s"`
	// PongWait is how long a client may stay silent before the connection is
	// dropped. Zero derives two missed pings plus a grace second.
	PongWait time.Duration `env:"PONG_WAIT" envDefault:"65s"`
}

// ExposureConfig gates an infrastructure surface (/metrics, /api/docs) that
// leaks internal detail. Outside development the surface must be either turned
// off or protected by a bearer token and/or a source address allowlist.
type ExposureConfig struct {
	Enabled bool `env:"ENABLED" envDefault:"true"`
	// Token is compared in constant time against the bearer credential.
	Token string `env:"TOKEN"`
	// AllowCIDR bypasses the token for the listed source networks.
	AllowCIDR []string `env:"ALLOW_CIDR" envSeparator:","`
}

// IsGuarded reports whether at least one credential is configured.
func (e ExposureConfig) IsGuarded() bool {
	return e.Token != "" || len(e.AllowCIDR) > 0
}

// S3Config holds object storage credentials (S3 compatible).
type S3Config struct {
	Endpoint  string `env:"ENDPOINT" envDefault:"http://localhost:9000"`
	Bucket    string `env:"BUCKET" envDefault:"onebook-eld"`
	Key       string `env:"KEY"`
	Secret    string `env:"SECRET"`
	Region    string `env:"REGION" envDefault:"us-east-1"`
	UseSSL    bool   `env:"USE_SSL" envDefault:"false"`
	PublicURL string `env:"PUBLIC_URL"`
}

// RateLimitConfig holds Redis backed rate limiting knobs.
type RateLimitConfig struct {
	Enabled bool          `env:"ENABLED" envDefault:"true"`
	Window  time.Duration `env:"WINDOW" envDefault:"1m"`
	Default int           `env:"DEFAULT" envDefault:"120"`
	Login   int           `env:"LOGIN" envDefault:"5"`
	Sync    int           `env:"SYNC" envDefault:"60"`
	Burst   int           `env:"BURST" envDefault:"20"`
	// LoginPerAccountHour caps login attempts against a single account.
	LoginPerAccountHour int `env:"LOGIN_ACCOUNT_PER_HOUR" envDefault:"10"`
	// UserPerMinute is the global authenticated budget (TZ B§3.2).
	UserPerMinute int `env:"USER_PER_MIN" envDefault:"600"`
	// LockoutMinutes is how long users.locked_until blocks an account.
	LockoutMinutes int      `env:"LOCKOUT_MINUTES" envDefault:"15"`
	TrustedCIDR    []string `env:"TRUSTED_CIDR" envSeparator:","`
}

const (
	minJWTSecretLen  = 32
	encryptionKeyLen = 32
)

// Load reads the configuration from the environment and validates it.
func Load() (*Config, error) {
	var cfg Config
	if err := env.Parse(&cfg); err != nil {
		return nil, fmt.Errorf("parse env: %w", err)
	}
	if err := cfg.Validate(); err != nil {
		return nil, err
	}
	return &cfg, nil
}

// Validate checks invariants that env parsing cannot express.
func (c *Config) Validate() error {
	var errs []error

	switch c.AppEnv {
	case EnvLocal, EnvDev, EnvStaging, EnvProd:
	default:
		errs = append(errs, fmt.Errorf("APP_ENV %q is invalid (local|dev|staging|prod)", c.AppEnv))
	}

	if len(c.JWTSecret) < minJWTSecretLen {
		errs = append(errs, fmt.Errorf("JWT_SECRET must be at least %d bytes", minJWTSecretLen))
	}
	if len(c.EncryptionKey) != encryptionKeyLen {
		errs = append(errs, fmt.Errorf("ENCRYPTION_KEY must be exactly %d bytes (AES-256)", encryptionKeyLen))
	}
	if c.DatabaseURL == "" {
		errs = append(errs, errors.New("DATABASE_URL is required"))
	}
	if c.AccessTokenTTL <= 0 {
		errs = append(errs, errors.New("ACCESS_TOKEN_TTL must be positive"))
	}
	if c.RefreshTTLDriver <= 0 || c.RefreshTTLAdmin <= 0 {
		errs = append(errs, errors.New("REFRESH_TTL_DRIVER and REFRESH_TTL_ADMIN must be positive"))
	}
	if c.IsProduction() && len(c.CORSOrigins) == 0 {
		errs = append(errs, errors.New("CORS_ORIGINS is required outside local"))
	}
	for _, o := range c.CORSOrigins {
		if strings.TrimSpace(o) == "" {
			errs = append(errs, errors.New("CORS_ORIGINS contains an empty entry"))
		}
	}

	errs = append(errs, c.validateExposure("METRICS", c.Metrics)...)
	errs = append(errs, c.validateExposure("DOCS", c.Docs)...)

	return errors.Join(errs...)
}

// validateExposure checks one infrastructure surface. An unauthenticated
// /metrics exposes endpoint names, traffic volume and the Go runtime, and
// /api/docs the whole API surface, so neither may stay open in production.
func (c *Config) validateExposure(prefix string, e ExposureConfig) []error {
	var errs []error
	if c.IsProduction() && e.Enabled && !e.IsGuarded() {
		errs = append(errs, fmt.Errorf(
			"%s_TOKEN or %s_ALLOW_CIDR is required outside development (or set %s_ENABLED=false)",
			prefix, prefix, prefix))
	}
	for _, raw := range e.AllowCIDR {
		cidr := strings.TrimSpace(raw)
		if cidr == "" {
			continue
		}
		if _, err := netip.ParsePrefix(cidr); err == nil {
			continue
		}
		if _, err := netip.ParseAddr(cidr); err != nil {
			errs = append(errs, fmt.Errorf("%s_ALLOW_CIDR entry %q is not an address or prefix", prefix, cidr))
		}
	}
	return errs
}

// IsProduction reports whether the process runs in a non-development environment.
func (c *Config) IsProduction() bool {
	return c.AppEnv == EnvProd || c.AppEnv == EnvStaging
}

// SlogLevel maps LOG_LEVEL to a slog level value.
func (c *Config) SlogLevel() int {
	switch strings.ToLower(c.LogLevel) {
	case "debug":
		return -4
	case "warn", "warning":
		return 4
	case "error":
		return 8
	default:
		return 0
	}
}
