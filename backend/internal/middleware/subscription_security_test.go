package middleware

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/tenant"
)

var subNow = time.Date(2026, 9, 7, 12, 0, 0, 0, time.UTC)

func subSource(state SubscriptionState) SubscriptionSource {
	return SubscriptionSourceFunc(func(context.Context, uuid.UUID) (SubscriptionState, error) {
		return state, nil
	})
}

// serveSubscription runs one request through RequireWritableSubscription.
func serveSubscription(t testing.TB, state SubscriptionState, p *tenant.Principal, method, path string) *httptest.ResponseRecorder {
	t.Helper()
	r := httptest.NewRequest(method, path, nil)
	if p != nil {
		r = r.WithContext(tenant.WithPrincipal(r.Context(), p))
	}
	w := httptest.NewRecorder()
	mw := RequireWritableSubscription(subSource(state), WithSubscriptionClock(func() time.Time { return subNow }))
	mw(okHandler()).ServeHTTP(w, r)
	return w
}

func adminPrincipal() *tenant.Principal {
	companyID := uuid.New()
	return &tenant.Principal{
		UserID: uuid.New(), CompanyID: &companyID, RoleID: uuid.New(),
		Scope: tenant.ScopeAll, SessionID: uuid.New(), DeviceType: tenant.DeviceWeb,
		Permissions: []string{"units.update"},
	}
}

func driverPrincipal() *tenant.Principal {
	p := adminPrincipal()
	p.Scope = tenant.ScopeSelf
	p.DeviceType = tenant.DevicePhone
	p.Permissions = []string{"logs.certify"}
	return p
}

func requireErrorCode(t testing.TB, w *httptest.ResponseRecorder, code string) {
	t.Helper()
	var body struct {
		Error struct {
			Code string `json:"code"`
		} `json:"error"`
	}
	require.NoError(t, json.Unmarshal(w.Body.Bytes(), &body))
	require.Equal(t, code, body.Error.Code)
}

// A lapsed subscription freezes the admin panel writes (TZ B§15).
func TestSubscriptionReadonlyBlocksAdminWrites(t *testing.T) {
	lapsed := subNow.Add(-core.SubscriptionGrace - time.Hour)
	cases := []struct {
		name  string
		state SubscriptionState
	}{
		{"explicit readonly", SubscriptionState{Status: SubscriptionReadonly}},
		{"grace window expired", SubscriptionState{Status: SubscriptionGrace, EndAt: &lapsed}},
		{"active but paid period long gone", SubscriptionState{Status: SubscriptionActive, EndAt: &lapsed}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			for _, method := range []string{http.MethodPost, http.MethodPatch, http.MethodPut, http.MethodDelete} {
				w := serveSubscription(t, tc.state, adminPrincipal(), method, "/api/v1/units/x")
				require.Equal(t, http.StatusForbidden, w.Code, method)
				requireErrorCode(t, w, apierr.CodeSubscriptionReadonly)
			}
		})
	}
}

// Read only means read: safe methods always pass.
func TestSubscriptionReadonlyAllowsReads(t *testing.T) {
	state := SubscriptionState{Status: SubscriptionReadonly}
	for _, method := range []string{http.MethodGet, http.MethodHead, http.MethodOptions} {
		w := serveSubscription(t, state, adminPrincipal(), method, "/api/v1/units")
		require.Equal(t, http.StatusOK, w.Code, method)
	}
}

// TZ B§15: compliance does not stop with billing — the driver application keeps
// recording HOS even while the admin panel is frozen.
func TestSubscriptionReadonlyNeverBlocksDriver(t *testing.T) {
	state := SubscriptionState{Status: SubscriptionReadonly}
	for _, path := range []string{"/api/v1/sync/push", "/api/v1/daily-logs/x/certify", "/api/v1/dvir-reports"} {
		w := serveSubscription(t, state, driverPrincipal(), http.MethodPost, path)
		require.Equal(t, http.StatusOK, w.Code, path)
	}
}

// The platform owner must stay able to renew a frozen tenant.
func TestSubscriptionReadonlyAllowsSuperAdmin(t *testing.T) {
	p := adminPrincipal()
	p.IsSuperAdmin = true
	w := serveSubscription(t, SubscriptionState{Status: SubscriptionReadonly}, p, http.MethodPatch, "/api/v1/companies/x")
	require.Equal(t, http.StatusOK, w.Code)
}

// Inside the paid period and inside the grace window the panel stays writable.
func TestSubscriptionWritableWindows(t *testing.T) {
	future := subNow.Add(30 * 24 * time.Hour)
	inGrace := subNow.Add(-core.SubscriptionGrace + time.Hour)
	cases := []SubscriptionState{
		{Status: SubscriptionActive, EndAt: &future},
		{Status: SubscriptionTrial, EndAt: &future},
		{Status: SubscriptionGrace, EndAt: &inGrace},
		{Status: SubscriptionActive},
	}
	for _, state := range cases {
		w := serveSubscription(t, state, adminPrincipal(), http.MethodPost, "/api/v1/units")
		require.Equal(t, http.StatusOK, w.Code, state.Status)
	}
}

// A request without a principal, or a module wired without a source, must fail
// closed rather than grant an unattributable write.
func TestSubscriptionFailsClosed(t *testing.T) {
	w := serveSubscription(t, SubscriptionState{Status: SubscriptionActive}, nil, http.MethodPost, "/api/v1/units")
	require.Equal(t, http.StatusUnauthorized, w.Code)

	r := httptest.NewRequest(http.MethodPost, "/api/v1/units", nil)
	r = r.WithContext(tenant.WithPrincipal(r.Context(), adminPrincipal()))
	rec := httptest.NewRecorder()
	RequireWritableSubscription(nil)(okHandler()).ServeHTTP(rec, r)
	require.Equal(t, http.StatusServiceUnavailable, rec.Code)
}

func TestSubscriptionStateEncoding(t *testing.T) {
	end := subNow.Add(24 * time.Hour)
	state := SubscriptionState{Status: SubscriptionActive, EndAt: &end}
	decoded, ok := decodeSubscription(encodeSubscription(state))
	require.True(t, ok)
	require.Equal(t, state.Status, decoded.Status)
	require.NotNil(t, decoded.EndAt)
	require.True(t, end.Equal(*decoded.EndAt))

	open, ok := decodeSubscription(encodeSubscription(SubscriptionState{Status: SubscriptionTrial}))
	require.True(t, ok)
	require.Nil(t, open.EndAt)

	_, ok = decodeSubscription("garbage")
	require.False(t, ok)
}
