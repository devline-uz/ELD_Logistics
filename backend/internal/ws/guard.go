package ws

import (
	"context"
	"net/http"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Subscription is one resolved `subscribe` frame.
type Subscription struct {
	Channel string
	// CompanyID is the tenant the client claims. It is optional on the wire;
	// when present it MUST equal the principal's own company.
	CompanyID uuid.UUID
	Filter    Filter
	Since     *time.Time
}

// channelPermission maps a channel onto the permission key it requires. An
// empty value means "any authenticated principal".
var channelPermission = map[string]string{
	ChannelTracking:      auth.PermTrackingViewLive,
	ChannelChat:          auth.PermChatRead,
	ChannelDashboard:     auth.PermDashboardRead,
	ChannelNotifications: "",
}

// ChannelPermission returns the permission key a channel is gated behind.
func ChannelPermission(channel string) (string, bool) {
	key, ok := channelPermission[channel]
	return key, ok
}

// Guard decides whether a principal may subscribe. Every `subscribe` frame is
// checked, not just the first one (TZ B§3 — WS auth).
type Guard interface {
	Authorize(ctx context.Context, p *tenant.Principal, sub Subscription) error
}

// UnitOwner verifies that units belong to the tenant. Wiring it is optional;
// without it a unit_ids filter only narrows what the client sees, it never
// widens it, because the hub already refuses to cross a company boundary.
type UnitOwner interface {
	OwnsUnits(ctx context.Context, companyID uuid.UUID, ids []uuid.UUID) error
}

// PermissionGuard is the default Guard: known channel, permission key, tenant
// match and (when wired) unit ownership.
type PermissionGuard struct {
	Units UnitOwner
	// MaxFilterIDs bounds a filter so one client cannot pin the hub with a
	// huge id set. Zero falls back to DefaultMaxFilterIDs.
	MaxFilterIDs int
}

// DefaultMaxFilterIDs bounds unit_ids / driver_ids in a subscribe frame.
const DefaultMaxFilterIDs = 500

// Authorize implements Guard.
func (g PermissionGuard) Authorize(ctx context.Context, p *tenant.Principal, sub Subscription) error {
	if p == nil {
		return apierr.Unauthorized("authentication required")
	}
	if !IsChannel(sub.Channel) {
		return apierr.NotFound("channel")
	}
	if p.CompanyID == nil || *p.CompanyID == uuid.Nil {
		return apierr.Forbidden("no active company for this session")
	}
	// Tenant isolation: a client may never name another company.
	if sub.CompanyID != uuid.Nil && sub.CompanyID != *p.CompanyID {
		return apierr.Forbidden("channel belongs to another company")
	}

	key, ok := channelPermission[sub.Channel]
	if !ok {
		return apierr.NotFound("channel")
	}
	if key != "" && !p.HasPermission(key) {
		return apierr.Forbidden("permission " + key + " is required")
	}

	max := g.MaxFilterIDs
	if max <= 0 {
		max = DefaultMaxFilterIDs
	}
	if len(sub.Filter.UnitIDs) > max || len(sub.Filter.DriverIDs) > max {
		return apierr.New(apierr.CodeValidationError, http.StatusUnprocessableEntity,
			"filter holds too many ids")
	}
	if len(sub.Filter.UnitIDs) > 0 && g.Units != nil {
		if err := g.Units.OwnsUnits(ctx, *p.CompanyID, sub.Filter.UnitIDs); err != nil {
			return err
		}
	}
	return nil
}

// BackfillRequest asks a channel for the events a reconnecting client missed.
type BackfillRequest struct {
	CompanyID uuid.UUID
	UserID    uuid.UUID
	Channel   string
	Since     time.Time
	Filter    Filter
	Limit     int
}

// Backfiller replays the events published since a reconnect point. Wiring it is
// optional: without one, `since` is accepted and answered with an empty replay.
type Backfiller interface {
	Backfill(ctx context.Context, req BackfillRequest) ([]Message, error)
}

// MaxBackfill bounds one replay.
const MaxBackfill = 200

// MaxBackfillWindow is how far back a reconnect may reach.
const MaxBackfillWindow = 24 * time.Hour
