// Package dto holds the trip planner payloads (TZ §13, Q66–Q68).
//
// A route is created `ongoing` and leaves that state exactly once: the
// geofence sweep completes it when the unit has stayed inside the destination
// circle for two minutes, or an admin closes it as `not_completed` with a
// reason from the fixed list. Distances are metres (`_m`), coordinates are
// WGS84 degrees and every timestamp is ISO 8601 UTC.
package dto

import (
	"time"

	shared "github.com/devline/onebook-eld/internal/httpx/dto"
)

// Shared envelopes re-exported so swagger annotations can reference dto.X.
type (
	// ErrorResponse is the single error envelope returned by every endpoint.
	ErrorResponse = shared.ErrorResponse
	// Meta carries pagination information for list responses.
	Meta = shared.Meta
)

// Route statuses (Q66).
const (
	// StatusOngoing is the state a route is created in.
	StatusOngoing = "ongoing"
	// StatusCompleted is set by the geofence sweep, never by hand.
	StatusCompleted = "completed"
	// StatusNotCompleted is the admin closure with a reason.
	StatusNotCompleted = "not_completed"
	// StatusCancelled is kept for routes voided before they ever started.
	StatusCancelled = "cancelled"
)

// Statuses lists every accepted route status.
var Statuses = []string{StatusOngoing, StatusCompleted, StatusNotCompleted, StatusCancelled}

// Not-completed reasons (Q66, fixed list).
const (
	ReasonBreakdown    = "breakdown"
	ReasonCancelled    = "cancelled"
	ReasonLoadRejected = "load_rejected"
	ReasonRoadClosed   = "road_closed"
	ReasonDriverChange = "driver_change"
	ReasonOther        = "other"
)

// Reasons lists every accepted not-completed reason.
var Reasons = []string{
	ReasonBreakdown, ReasonCancelled, ReasonLoadRejected,
	ReasonRoadClosed, ReasonDriverChange, ReasonOther,
}

// DefaultGeofenceM is the destination geofence radius applied when the request
// omits one (Q66).
const DefaultGeofenceM int32 = 300

// DwellSeconds is how long a unit must sit inside the destination geofence
// before the route counts as completed (Q66).
const DwellSeconds = 120

// Waypoint is one end of a route as it is stored and returned.
type Waypoint struct {
	// Text is the human readable address shown in the planner.
	Text string `json:"text" example:"Chicago, IL"`
	// Lat is the WGS84 latitude in degrees.
	Lat *float64 `json:"lat" example:"41.8781"`
	// Lng is the WGS84 longitude in degrees.
	Lng *float64 `json:"lng" example:"-87.6298"`
}

// WaypointInput is one end of a route as it arrives in a request.
type WaypointInput struct {
	// Text is the human readable address shown in the planner.
	Text string `json:"text" example:"Chicago, IL" validate:"required,max=255"`
	// Lat is the WGS84 latitude in degrees.
	Lat float64 `json:"lat" example:"41.8781" validate:"gte=-90,lte=90"`
	// Lng is the WGS84 longitude in degrees.
	Lng float64 `json:"lng" example:"-87.6298" validate:"gte=-180,lte=180"`
}

// Route is one trip planner entry.
type Route struct {
	// ID is the route identifier.
	ID string `json:"id" example:"7c9e6679-7425-40de-944b-e07fc1f90ae7"`
	// UnitID is the assigned unit.
	UnitID string `json:"unit_id" example:"2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8"`
	// UnitNumber is the fleet number of the assigned unit.
	UnitNumber string `json:"unit_number" example:"1021"`
	// DriverID is the assigned driver.
	DriverID string `json:"driver_id" example:"9b2f5c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d"`
	// DriverName is the driver's display name.
	DriverName string `json:"driver_name" example:"John Miller"`
	// Sequence orders the routes of one unit; the lowest ongoing sequence is
	// the current one (Q68).
	Sequence int32 `json:"sequence" example:"1"`
	// Origin is the start of the leg.
	Origin Waypoint `json:"origin"`
	// Destination is the end of the leg; its geofence completes the route.
	Destination Waypoint `json:"destination"`
	// GeofenceM is the destination geofence radius in metres.
	GeofenceM int32 `json:"geofence_m" example:"300"`
	// Status is the route state.
	Status string `json:"status" example:"ongoing" enums:"ongoing,completed,not_completed,cancelled"`
	// Note is the dispatcher's free text.
	Note string `json:"note" example:"Drop at dock 4"`
	// NotCompletedReason is set only on a not_completed route.
	NotCompletedReason string `json:"not_completed_reason,omitempty" example:"breakdown" enums:"breakdown,cancelled,load_rejected,road_closed,driver_change,other"`
	// NotCompletedNote is the admin's explanation.
	NotCompletedNote string `json:"not_completed_note,omitempty" example:"Coolant leak on I-55"`
	// GeofenceEnteredAt is when the unit was first seen inside the destination
	// geofence; it is cleared whenever the unit leaves again.
	GeofenceEnteredAt *time.Time `json:"geofence_entered_at,omitempty" format:"date-time" example:"2026-09-06T14:58:00Z"`
	// StartedAt is when the unit first moved on this route.
	StartedAt *time.Time `json:"started_at,omitempty" format:"date-time" example:"2026-09-06T08:00:00Z"`
	// CompletedAt is when the route reached a terminal state.
	CompletedAt *time.Time `json:"completed_at,omitempty" format:"date-time" example:"2026-09-06T15:00:00Z"`
	// CreatedAt is the creation timestamp.
	CreatedAt time.Time `json:"created_at" format:"date-time" example:"2026-09-06T07:45:00Z"`
	// UpdatedAt is the last modification timestamp.
	UpdatedAt time.Time `json:"updated_at" format:"date-time" example:"2026-09-06T15:00:00Z"`
}

// RouteCreate is the POST /routes payload.
type RouteCreate struct {
	// UnitID is the unit that will drive the leg.
	UnitID string `json:"unit_id" example:"2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8" validate:"required,uuid"`
	// DriverID is the driver that will be notified.
	DriverID string `json:"driver_id" example:"9b2f5c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d" validate:"required,uuid"`
	// Sequence orders several routes of the same unit (Q68); defaults to the
	// next free slot when omitted.
	Sequence int32 `json:"sequence" example:"1" validate:"omitempty,min=1,max=9999"`
	// Origin is the start of the leg.
	Origin WaypointInput `json:"origin" validate:"required"`
	// Destination is the end of the leg.
	Destination WaypointInput `json:"destination" validate:"required"`
	// GeofenceM is the destination geofence radius in metres; defaults to 300.
	GeofenceM int32 `json:"geofence_m" example:"300" validate:"omitempty,min=50,max=20000"`
	// Note is the dispatcher's free text.
	Note string `json:"note" example:"Drop at dock 4" validate:"max=1000"`
}

// RouteUpdate is the PATCH /routes/{id} payload; every field is optional.
type RouteUpdate struct {
	// UnitID reassigns the unit.
	UnitID *string `json:"unit_id,omitempty" example:"2f1a1b3c-4d5e-6f70-8192-a3b4c5d6e7f8" validate:"omitempty,uuid"`
	// DriverID reassigns the driver; the new driver is notified.
	DriverID *string `json:"driver_id,omitempty" example:"9b2f5c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d" validate:"omitempty,uuid"`
	// Sequence reorders the route inside its unit's queue.
	Sequence *int32 `json:"sequence,omitempty" example:"2" validate:"omitempty,min=1,max=9999"`
	// Origin replaces the start of the leg.
	Origin *WaypointInput `json:"origin,omitempty"`
	// Destination replaces the end of the leg.
	Destination *WaypointInput `json:"destination,omitempty"`
	// GeofenceM replaces the destination geofence radius in metres.
	GeofenceM *int32 `json:"geofence_m,omitempty" example:"500" validate:"omitempty,min=50,max=20000"`
	// Note replaces the dispatcher's free text.
	Note *string `json:"note,omitempty" example:"Dock 4 closed, use dock 7" validate:"omitempty,max=1000"`
}

// RouteNotCompleted is the POST /routes/{id}/not-completed payload (Q66).
type RouteNotCompleted struct {
	// Reason is one of the fixed closure reasons.
	Reason string `json:"reason" example:"breakdown" enums:"breakdown,cancelled,load_rejected,road_closed,driver_change,other" validate:"required,oneof=breakdown cancelled load_rejected road_closed driver_change other"`
	// Note explains the closure; it is required for `other`.
	Note string `json:"note" example:"Coolant leak on I-55" validate:"max=1000"`
}

// Directions is the GET /routes/{id}/directions answer (Q66.1). The geometry
// comes from the map provider and is cached, so repeated opens of the same
// route cost nothing.
type Directions struct {
	// RouteID is the route the geometry belongs to.
	RouteID string `json:"route_id" example:"7c9e6679-7425-40de-944b-e07fc1f90ae7"`
	// DistanceM is the driving distance in metres.
	DistanceM int64 `json:"distance_m" example:"412345"`
	// DurationS is the estimated driving time in seconds.
	DurationS int64 `json:"duration_s" example:"15600"`
	// Polyline is the geometry in encoded polyline format (precision 5).
	Polyline string `json:"polyline" example:"_p~iF~ps|U_ulLnnqC"`
	// Provider names the map provider that answered.
	Provider string `json:"provider" example:"nominatim" enums:"nominatim,photon,google,nop"`
	// Origin is the start coordinate the geometry was requested for.
	Origin Waypoint `json:"origin"`
	// Destination is the end coordinate the geometry was requested for.
	Destination Waypoint `json:"destination"`
}

// RouteEnvelope wraps a single route.
type RouteEnvelope struct {
	// Data is the route.
	Data Route `json:"data"`
}

// RouteListEnvelope wraps a page of routes.
type RouteListEnvelope struct {
	// Data is the page of routes.
	Data []Route `json:"data"`
	// Meta carries the pagination counters.
	Meta Meta `json:"meta"`
}

// DirectionsEnvelope wraps a directions answer.
type DirectionsEnvelope struct {
	// Data is the route geometry.
	Data Directions `json:"data"`
}
