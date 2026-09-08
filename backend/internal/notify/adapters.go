package notify

import (
	"context"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/domain/dvir"
	"github.com/devline/onebook-eld/internal/domain/maintenance"
	"github.com/devline/onebook-eld/internal/domain/reports"
	"github.com/devline/onebook-eld/internal/domain/routes"
)

// DvirAlerter adapts the dispatcher to dvir.Alerter. The DVIR package raises
// its own alert kinds and never imports internal/notify, so the mapping to the
// TZ A§19 alert catalogue lives here.
type DvirAlerter struct{ Dispatcher *Dispatcher }

// NewDvirAlerter builds the adapter; a nil dispatcher yields a no-op alerter.
func NewDvirAlerter(d *Dispatcher) dvir.Alerter {
	if d == nil {
		return dvir.NopAlerter{}
	}
	return DvirAlerter{Dispatcher: d}
}

// Alert implements dvir.Alerter.
func (a DvirAlerter) Alert(ctx context.Context, alertType string, al dvir.Alert) error {
	title, body := dvirText(alertType, al)
	entityID := al.DvirID
	ev := Event{
		CompanyID:  al.CompanyID,
		Title:      title,
		Body:       body,
		EntityType: "dvir",
		EntityID:   &entityID,
		Data:       dvirData(al),
	}

	switch alertType {
	case dvir.AlertCriticalDefect:
		ev.AlertType = AlertDVIRCritical
	case dvir.AlertDefectsFound:
		ev.AlertType = AlertDVIRDefects
	case dvir.AlertPendingCertification, dvir.AlertClosedNoCertification:
		// Both are addressed at the driver of the report, not at the office.
		ev.AlertType = AlertDVIRDefects
		if al.DriverID == uuid.Nil {
			return nil
		}
		return a.Dispatcher.Send(ctx, Notification{
			CompanyID: al.CompanyID, UserID: al.DriverID, AlertType: ev.AlertType,
			Title: title, Body: body,
			EntityType: ev.EntityType, EntityID: ev.EntityID, Data: ev.Data,
		})
	default:
		return nil
	}
	if al.DriverID != uuid.Nil {
		ev.Users = []uuid.UUID{al.DriverID}
	}
	return a.Dispatcher.Broadcast(ctx, ev)
}

// dvirText builds a short, PII free summary.
func dvirText(alertType string, al dvir.Alert) (string, string) {
	body := al.Message
	switch alertType {
	case dvir.AlertCriticalDefect:
		return "Critical defect — unit out of service", body
	case dvir.AlertDefectsFound:
		return "DVIR defects reported", body
	case dvir.AlertPendingCertification:
		return "DVIR waiting for your certification", body
	case dvir.AlertClosedNoCertification:
		return "DVIR closed without certification", body
	}
	return "DVIR update", body
}

// dvirData carries only identifiers and the unit number (never PII).
func dvirData(al dvir.Alert) map[string]string {
	data := map[string]string{"dvir_id": al.DvirID.String()}
	if al.UnitID != uuid.Nil {
		data["unit_id"] = al.UnitID.String()
	}
	if al.UnitNumber != "" {
		data["unit_number"] = al.UnitNumber
	}
	return data
}

// MaintenanceAlerter adapts the dispatcher to maintenance.Alerter.
type MaintenanceAlerter struct{ Dispatcher *Dispatcher }

// NewMaintenanceAlerter builds the adapter; a nil dispatcher yields a no-op.
func NewMaintenanceAlerter(d *Dispatcher) maintenance.Alerter {
	if d == nil {
		return maintenance.NopAlerter{}
	}
	return MaintenanceAlerter{Dispatcher: d}
}

// Alert implements maintenance.Alerter. The schedule's own delivery methods
// win for the users it names (Q38); the configured recipient roles are served
// by the ordinary settings fan out.
func (a MaintenanceAlerter) Alert(ctx context.Context, alertType string, r maintenance.Reminder) error {
	kind := AlertMaintenanceUpcoming
	title := "Maintenance due soon"
	if alertType == maintenance.ReminderOverdue {
		kind, title = AlertMaintenanceOverdue, "Maintenance overdue"
	}
	entityID := r.ScheduleID
	data := map[string]string{"schedule_id": r.ScheduleID.String()}
	if r.UnitID != uuid.Nil {
		data["unit_id"] = r.UnitID.String()
	}
	if r.UnitNumber != "" {
		data["unit_number"] = r.UnitNumber
	}

	channels := filterChannels(r.DeliveryMethods)
	var last error
	for _, userID := range r.Recipients {
		if userID == uuid.Nil {
			continue
		}
		if err := a.Dispatcher.Send(ctx, Notification{
			CompanyID: r.CompanyID, UserID: userID, AlertType: kind,
			Title: title, Body: r.Message,
			EntityType: "maintenance_schedule", EntityID: &entityID,
			Channels: channels, Data: data,
		}); err != nil {
			last = err
		}
	}

	// The office side is addressed through notification_settings.
	if err := a.Dispatcher.Broadcast(ctx, Event{
		CompanyID: r.CompanyID, AlertType: kind, Title: title, Body: r.Message,
		EntityType: "maintenance_schedule", EntityID: &entityID, Data: data,
	}); err != nil {
		last = err
	}
	return last
}

// filterChannels drops anything outside the known catalogue so a stale
// schedule row cannot inject an unknown channel key.
func filterChannels(in []string) []string {
	out := make([]string, 0, len(in))
	for _, c := range in {
		if IsChannel(c) {
			out = append(out, c)
		}
	}
	if len(out) == 0 {
		return nil
	}
	return out
}

// RoutesAlerter adapts the dispatcher to routes.Alerter. The trip planner
// raises its own alert kinds and never imports internal/notify; the mapping to
// the TZ A§19 alert catalogue lives here (Q66.1).
type RoutesAlerter struct{ Dispatcher *Dispatcher }

// NewRoutesAlerter builds the adapter; a nil dispatcher yields a no-op alerter.
func NewRoutesAlerter(d *Dispatcher) routes.Alerter {
	if d == nil {
		return routes.NopAlerter{}
	}
	return RoutesAlerter{Dispatcher: d}
}

// Alert implements routes.Alerter. Assignment, reassignment and the admin
// closure are addressed at the driver only; the geofence completion is
// broadcast to the office roles configured for AlertRouteCompleted (Q66).
func (a RoutesAlerter) Alert(ctx context.Context, alertType string, al routes.Alert) error {
	title, kind := routesText(alertType)
	if kind == "" {
		return nil
	}
	entityID := al.RouteID
	data := routesData(al)

	if alertType == routes.AlertRouteCompleted {
		return a.Dispatcher.Broadcast(ctx, Event{
			CompanyID: al.CompanyID, AlertType: kind, Title: title, Body: al.Message,
			EntityType: "route", EntityID: &entityID, Data: data,
		})
	}
	if al.DriverID == uuid.Nil {
		return nil
	}
	return a.Dispatcher.Send(ctx, Notification{
		CompanyID: al.CompanyID, UserID: al.DriverID, AlertType: kind,
		Title: title, Body: al.Message, EntityType: "route", EntityID: &entityID, Data: data,
	})
}

// routesText maps a routes.Alert kind onto its notification title and the
// TZ A§19 alert type.
func routesText(alertType string) (title, kind string) {
	switch alertType {
	case routes.AlertRouteAssigned:
		return "New route assigned", AlertRouteAssigned
	case routes.AlertRouteReassigned:
		return "Route reassigned", AlertRouteReassigned
	case routes.AlertRouteCompleted:
		return "Route completed", AlertRouteCompleted
	case routes.AlertRouteNotCompleted:
		return "Route closed as not completed", AlertRouteNotCompleted
	default:
		return "", ""
	}
}

// routesData carries only identifiers, never a coordinate: a position is PII.
func routesData(al routes.Alert) map[string]string {
	data := map[string]string{"route_id": al.RouteID.String(), "unit_id": al.UnitID.String()}
	if al.UnitNumber != "" {
		data["unit_number"] = al.UnitNumber
	}
	if al.Reason != "" {
		data["reason"] = al.Reason
	}
	return data
}

// ReportsAlerter adapts the dispatcher to reports.Alerter. The reporting
// module raises its own alert kinds and never imports internal/notify (Q75).
type ReportsAlerter struct{ Dispatcher *Dispatcher }

// NewReportsAlerter builds the adapter; a nil dispatcher yields a no-op.
func NewReportsAlerter(d *Dispatcher) reports.Alerter {
	if d == nil {
		return reports.NopAlerter{}
	}
	return ReportsAlerter{Dispatcher: d}
}

// Alert implements reports.Alerter. An export is addressed at the requester
// only; the document content never leaves the object storage link.
func (a ReportsAlerter) Alert(ctx context.Context, alertType string, al reports.Alert) error {
	if al.UserID == uuid.Nil {
		return nil
	}
	kind, title := AlertExportReady, "Your export is ready"
	if alertType == reports.AlertExportFailed {
		kind, title = AlertExportFailed, "Your export could not be produced"
	}
	entityID := al.JobID
	data := map[string]string{"job_id": al.JobID.String(), "type": al.Type, "format": al.Format}
	if al.FileName != "" {
		data["file_name"] = al.FileName
	}
	if al.Reason != "" {
		data["reason"] = al.Reason
	}
	return a.Dispatcher.Send(ctx, Notification{
		CompanyID: al.CompanyID, UserID: al.UserID, AlertType: kind,
		Title: title, Body: al.Message, EntityType: "report_export_job", EntityID: &entityID, Data: data,
	})
}
