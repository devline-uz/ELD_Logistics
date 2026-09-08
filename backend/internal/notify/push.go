package notify

import (
	"bytes"
	"context"
	"crypto"
	"crypto/ecdsa"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"

	"golang.org/x/net/http2"
)

// PushSender routes a push to FCM (Android/web) or APNs (iOS) per device. A
// missing provider for one platform does not disable the other.
type PushSender struct {
	FCM  *FCMClient
	APNs *APNsClient
	Log  *slog.Logger
}

// Channel implements Sender.
func (p *PushSender) Channel() string { return ChannelPush }

// Send implements Sender. One failing device never stops the others; the
// error returned is the last failure so the caller can log it.
func (p *PushSender) Send(ctx context.Context, to Recipient, n Notification) error {
	var last error
	for _, d := range to.Devices {
		var err error
		switch d.Platform {
		case PlatformIOS:
			if p.APNs == nil {
				continue
			}
			err = p.APNs.Push(ctx, d.Token, n)
		case PlatformAndroid, PlatformWeb:
			if p.FCM == nil {
				continue
			}
			err = p.FCM.Push(ctx, d.Token, n)
		default:
			continue
		}
		if err != nil {
			last = err
			if p.Log != nil {
				// The device token is a credential: it is never logged.
				p.Log.WarnContext(ctx, "notify: push failed",
					slog.String("platform", d.Platform),
					slog.String("alert_type", n.AlertType),
					slog.String("error", err.Error()))
			}
		}
	}
	return last
}

// ---------------------------------------------------------------- FCM HTTP v1

// FCMConfig configures the Firebase Cloud Messaging HTTP v1 client.
type FCMConfig struct {
	ProjectID string
	// ServiceAccountJSON is the raw service account key. When empty the client
	// is not built and push degrades to the other platform.
	ServiceAccountJSON []byte
	// Endpoint overrides https://fcm.googleapis.com in tests.
	Endpoint string
	Timeout  time.Duration
}

// FCMClient talks to the FCM HTTP v1 API with a service account bearer token.
type FCMClient struct {
	projectID string
	endpoint  string
	tokens    *serviceAccountTokens
	http      *http.Client
}

// NewFCMClient builds the client, or returns nil when it is not configured.
func NewFCMClient(cfg FCMConfig) (*FCMClient, error) {
	if cfg.ProjectID == "" || len(cfg.ServiceAccountJSON) == 0 {
		return nil, nil
	}
	ts, err := newServiceAccountTokens(cfg.ServiceAccountJSON, "https://www.googleapis.com/auth/firebase.messaging")
	if err != nil {
		return nil, err
	}
	endpoint := cfg.Endpoint
	if endpoint == "" {
		endpoint = "https://fcm.googleapis.com"
	}
	timeout := cfg.Timeout
	if timeout <= 0 {
		timeout = 10 * time.Second
	}
	return &FCMClient{
		projectID: cfg.ProjectID,
		endpoint:  strings.TrimRight(endpoint, "/"),
		tokens:    ts,
		http:      &http.Client{Timeout: timeout},
	}, nil
}

// fcmMessage is the v1 send envelope.
type fcmMessage struct {
	Message struct {
		Token        string            `json:"token"`
		Notification fcmNotification   `json:"notification"`
		Data         map[string]string `json:"data,omitempty"`
	} `json:"message"`
}

type fcmNotification struct {
	Title string `json:"title"`
	Body  string `json:"body,omitempty"`
}

// Push delivers one notification to one registration token.
func (c *FCMClient) Push(ctx context.Context, token string, n Notification) error {
	if c == nil || token == "" {
		return nil
	}
	var msg fcmMessage
	msg.Message.Token = token
	msg.Message.Notification = fcmNotification{Title: n.Title, Body: n.Body}
	msg.Message.Data = pushData(n)

	buf, err := json.Marshal(msg)
	if err != nil {
		return err
	}
	access, err := c.tokens.token(ctx)
	if err != nil {
		return err
	}
	endpoint := fmt.Sprintf("%s/v1/projects/%s/messages:send", c.endpoint, c.projectID)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint, bytes.NewReader(buf))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+access)

	resp, err := c.http.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
		return fmt.Errorf("notify: fcm responded %d: %s", resp.StatusCode, strings.TrimSpace(string(body)))
	}
	_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 4096))
	return nil
}

// pushData renders the notification metadata as the string map both providers
// accept. Values must never carry PII.
func pushData(n Notification) map[string]string {
	data := make(map[string]string, len(n.Data)+3)
	for k, v := range n.Data {
		data[k] = v
	}
	data["alert_type"] = n.AlertType
	if n.EntityType != "" {
		data["entity_type"] = n.EntityType
	}
	if n.EntityID != nil {
		data["entity_id"] = n.EntityID.String()
	}
	return data
}

// serviceAccountTokens mints and caches Google OAuth access tokens from a
// service account key (RS256 assertion grant).
type serviceAccountTokens struct {
	email    string
	tokenURI string
	scope    string
	key      *rsa.PrivateKey

	mu     sync.Mutex
	value  string
	expiry time.Time
	client *http.Client
}

type serviceAccountKey struct {
	ClientEmail string `json:"client_email"`
	PrivateKey  string `json:"private_key"`
	TokenURI    string `json:"token_uri"`
}

func newServiceAccountTokens(raw []byte, scope string) (*serviceAccountTokens, error) {
	var key serviceAccountKey
	if err := json.Unmarshal(raw, &key); err != nil {
		return nil, fmt.Errorf("notify: service account key: %w", err)
	}
	if key.ClientEmail == "" || key.PrivateKey == "" {
		return nil, errors.New("notify: service account key is incomplete")
	}
	priv, err := parseRSAKey([]byte(key.PrivateKey))
	if err != nil {
		return nil, err
	}
	tokenURI := key.TokenURI
	if tokenURI == "" {
		tokenURI = "https://oauth2.googleapis.com/token" //nolint:gosec // G101: public Google OAuth2 endpoint URL, not a credential
	}
	return &serviceAccountTokens{
		email: key.ClientEmail, tokenURI: tokenURI, scope: scope, key: priv,
		client: &http.Client{Timeout: 10 * time.Second},
	}, nil
}

func (t *serviceAccountTokens) token(ctx context.Context) (string, error) {
	t.mu.Lock()
	defer t.mu.Unlock()
	if t.value != "" && time.Now().Before(t.expiry.Add(-time.Minute)) {
		return t.value, nil
	}
	assertion, err := t.assertion()
	if err != nil {
		return "", err
	}
	form := url.Values{
		"grant_type": {"urn:ietf:params:oauth:grant-type:jwt-bearer"},
		"assertion":  {assertion},
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, t.tokenURI, strings.NewReader(form.Encode()))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	resp, err := t.client.Do(req)
	if err != nil {
		return "", err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		return "", fmt.Errorf("notify: oauth token endpoint responded %d", resp.StatusCode)
	}
	var out struct {
		AccessToken string `json:"access_token"`
		ExpiresIn   int64  `json:"expires_in"`
	}
	if err := json.NewDecoder(io.LimitReader(resp.Body, 1<<16)).Decode(&out); err != nil {
		return "", err
	}
	if out.AccessToken == "" {
		return "", errors.New("notify: oauth token endpoint returned no token")
	}
	t.value = out.AccessToken
	t.expiry = time.Now().Add(time.Duration(out.ExpiresIn) * time.Second)
	return t.value, nil
}

func (t *serviceAccountTokens) assertion() (string, error) {
	now := time.Now()
	header := map[string]string{"alg": "RS256", "typ": "JWT"}
	claims := map[string]any{
		"iss":   t.email,
		"scope": t.scope,
		"aud":   t.tokenURI,
		"iat":   now.Unix(),
		"exp":   now.Add(time.Hour).Unix(),
	}
	signing, err := joseSigningInput(header, claims)
	if err != nil {
		return "", err
	}
	sum := sha256.Sum256([]byte(signing))
	sig, err := rsa.SignPKCS1v15(rand.Reader, t.key, crypto.SHA256, sum[:])
	if err != nil {
		return "", err
	}
	return signing + "." + base64.RawURLEncoding.EncodeToString(sig), nil
}

func joseSigningInput(header map[string]string, claims map[string]any) (string, error) {
	h, err := json.Marshal(header)
	if err != nil {
		return "", err
	}
	c, err := json.Marshal(claims)
	if err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(h) + "." + base64.RawURLEncoding.EncodeToString(c), nil
}

func parseRSAKey(pemBytes []byte) (*rsa.PrivateKey, error) {
	block, _ := pem.Decode(pemBytes)
	if block == nil {
		return nil, errors.New("notify: service account key is not PEM encoded")
	}
	if key, err := x509.ParsePKCS1PrivateKey(block.Bytes); err == nil {
		return key, nil
	}
	parsed, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("notify: service account key: %w", err)
	}
	key, ok := parsed.(*rsa.PrivateKey)
	if !ok {
		return nil, errors.New("notify: service account key is not RSA")
	}
	return key, nil
}

// -------------------------------------------------------------------- APNs

// APNsConfig configures the Apple Push Notification service client.
type APNsConfig struct {
	// AuthKeyP8 is the .p8 provider key. Empty disables APNs.
	AuthKeyP8 []byte
	KeyID     string
	TeamID    string
	Topic     string
	// Production selects api.push.apple.com over the sandbox host.
	Production bool
	// Endpoint overrides the host in tests.
	Endpoint string
	Timeout  time.Duration
}

// APNsClient pushes over the APNs HTTP/2 API with a provider token (ES256).
type APNsClient struct {
	endpoint string
	topic    string
	keyID    string
	teamID   string
	key      *ecdsa.PrivateKey
	http     *http.Client

	mu       sync.Mutex
	token    string
	issuedAt time.Time
}

// NewAPNsClient builds the client, or returns nil when it is not configured.
func NewAPNsClient(cfg APNsConfig) (*APNsClient, error) {
	if len(cfg.AuthKeyP8) == 0 || cfg.KeyID == "" || cfg.TeamID == "" || cfg.Topic == "" {
		return nil, nil
	}
	block, _ := pem.Decode(cfg.AuthKeyP8)
	if block == nil {
		return nil, errors.New("notify: apns key is not PEM encoded")
	}
	parsed, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("notify: apns key: %w", err)
	}
	key, ok := parsed.(*ecdsa.PrivateKey)
	if !ok {
		return nil, errors.New("notify: apns key is not ECDSA")
	}
	endpoint := cfg.Endpoint
	if endpoint == "" {
		endpoint = "https://api.sandbox.push.apple.com"
		if cfg.Production {
			endpoint = "https://api.push.apple.com"
		}
	}
	timeout := cfg.Timeout
	if timeout <= 0 {
		timeout = 10 * time.Second
	}
	return &APNsClient{
		endpoint: strings.TrimRight(endpoint, "/"),
		topic:    cfg.Topic, keyID: cfg.KeyID, teamID: cfg.TeamID, key: key,
		http: &http.Client{
			Timeout:   timeout,
			Transport: &http2.Transport{TLSClientConfig: &tls.Config{MinVersion: tls.VersionTLS12}},
		},
	}, nil
}

// apnsPayload is the aps envelope.
type apnsPayload struct {
	APS struct {
		Alert struct {
			Title string `json:"title"`
			Body  string `json:"body,omitempty"`
		} `json:"alert"`
		Sound string `json:"sound,omitempty"`
	} `json:"aps"`
	Data map[string]string `json:"data,omitempty"`
}

// Push delivers one notification to one device token.
func (c *APNsClient) Push(ctx context.Context, deviceToken string, n Notification) error {
	if c == nil || deviceToken == "" {
		return nil
	}
	var payload apnsPayload
	payload.APS.Alert.Title = n.Title
	payload.APS.Alert.Body = n.Body
	payload.APS.Sound = "default"
	payload.Data = pushData(n)

	buf, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	jwtToken, err := c.providerToken()
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost,
		c.endpoint+"/3/device/"+deviceToken, bytes.NewReader(buf))
	if err != nil {
		return err
	}
	req.Header.Set("authorization", "bearer "+jwtToken)
	req.Header.Set("apns-topic", c.topic)
	req.Header.Set("apns-push-type", "alert")
	req.Header.Set("content-type", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
		return fmt.Errorf("notify: apns responded %d: %s", resp.StatusCode, strings.TrimSpace(string(body)))
	}
	return nil
}

// providerToken mints (and caches for an hour, as Apple requires) the ES256
// provider authentication token.
func (c *APNsClient) providerToken() (string, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.token != "" && time.Since(c.issuedAt) < 45*time.Minute {
		return c.token, nil
	}
	header := map[string]string{"alg": "ES256", "kid": c.keyID}
	claims := map[string]any{"iss": c.teamID, "iat": time.Now().Unix()}
	signing, err := joseSigningInput(header, claims)
	if err != nil {
		return "", err
	}
	sum := sha256.Sum256([]byte(signing))
	r, s, err := ecdsa.Sign(rand.Reader, c.key, sum[:])
	if err != nil {
		return "", err
	}
	sig := make([]byte, 64)
	r.FillBytes(sig[:32])
	s.FillBytes(sig[32:])
	c.token = signing + "." + base64.RawURLEncoding.EncodeToString(sig)
	c.issuedAt = time.Now()
	return c.token, nil
}
