package routes

import (
	"strings"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/routes/dto"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// toRoute maps the detail row onto the wire type. The sqlc model never leaves
// the package.
func toRoute(r db.GetRouteDetailRow) dto.Route {
	return dto.Route{
		ID:         r.ID.String(),
		UnitID:     r.UnitID.String(),
		UnitNumber: r.UnitNumber,
		DriverID:   r.DriverID.String(),
		DriverName: displayName(r.FirstName, r.LastName),
		Sequence:   r.Sequence,
		Origin: dto.Waypoint{
			Text: pgconv.Deref(r.OriginText), Lat: r.OriginLat, Lng: r.OriginLng,
		},
		Destination: dto.Waypoint{
			Text: pgconv.Deref(r.DestText), Lat: r.DestLat, Lng: r.DestLng,
		},
		GeofenceM:          r.GeofenceM,
		Status:             r.Status,
		Note:               pgconv.Deref(r.Note),
		NotCompletedReason: pgconv.Deref(r.NotCompletedReason),
		NotCompletedNote:   pgconv.Deref(r.NotCompletedNote),
		GeofenceEnteredAt:  pgconv.ToTimePtr(r.GeofenceEnteredAt),
		StartedAt:          pgconv.ToTimePtr(r.StartedAt),
		CompletedAt:        pgconv.ToTimePtr(r.CompletedAt),
		CreatedAt:          r.CreatedAt,
		UpdatedAt:          r.UpdatedAt,
	}
}

// toRouteFromList maps a list row. The two sqlc rows carry the same columns;
// converting through one shape keeps the mapping in a single place.
func toRouteFromList(r db.ListRoutesRow) dto.Route {
	return toRoute(db.GetRouteDetailRow{
		ID: r.ID, CompanyID: r.CompanyID, UnitID: r.UnitID, DriverID: r.DriverID,
		Sequence: r.Sequence, OriginText: r.OriginText, OriginLat: r.OriginLat,
		OriginLng: r.OriginLng, DestText: r.DestText, DestLat: r.DestLat,
		DestLng: r.DestLng, GeofenceM: r.GeofenceM, Status: r.Status,
		CreatedBy: r.CreatedBy, StartedAt: r.StartedAt, CompletedAt: r.CompletedAt,
		NotCompletedReason: r.NotCompletedReason, Note: r.Note, PolylineKey: r.PolylineKey,
		CreatedAt: r.CreatedAt, UpdatedAt: r.UpdatedAt, DeletedAt: r.DeletedAt,
		NotCompletedNote: r.NotCompletedNote, NotCompletedBy: r.NotCompletedBy,
		GeofenceEnteredAt: r.GeofenceEnteredAt, UnitNumber: r.UnitNumber,
		FirstName: r.FirstName, LastName: r.LastName,
	})
}

// displayName builds the driver label. It is a name, not a credential: the
// license number and contact details never reach this module.
func displayName(first, last string) string {
	return strings.TrimSpace(strings.TrimSpace(first) + " " + strings.TrimSpace(last))
}
