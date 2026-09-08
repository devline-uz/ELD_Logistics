package fleet

import (
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/fleet/dto"
)

// onlineWindow is the telemetry age below which a device counts as Online
// (TZ §10.1).
const onlineWindow = 5 * time.Minute

// malfunctionNames maps the FMCSA Appendix A letters to a readable label
// (TZ §10.5).
var malfunctionNames = map[string]string{
	"P": "power compliance",
	"E": "engine synchronization",
	"T": "timing compliance",
	"L": "positioning compliance",
	"R": "data recording compliance",
	"S": "data transfer compliance",
	"O": "other ELD detected malfunction",
}

func unitFromList(r db.FleetListUnitsRow) dto.Unit {
	return dto.Unit{
		ID:              r.ID.String(),
		UnitNumber:      r.UnitNumber,
		Make:            pgconv.Deref(r.Make),
		Model:           pgconv.Deref(r.Model),
		Year:            r.Year,
		VIN:             pgconv.Deref(r.Vin),
		LicensePlate:    pgconv.Deref(r.LicensePlate),
		PlateRegion:     pgconv.Deref(r.PlateRegion),
		FuelType:        pgconv.Deref(r.FuelType),
		SleeperBerth:    r.SleeperBerth,
		GVWRClass:       pgconv.Deref(r.GvwrClass),
		Status:          r.Status,
		OutOfService:    r.OutOfService,
		Notes:           pgconv.Deref(r.Notes),
		BranchID:        pgconv.UUIDString(r.BranchID),
		BranchName:      pgconv.Deref(r.BranchName),
		EldDeviceID:     pgconv.UUIDString(r.EldDeviceID),
		EldDeviceSerial: pgconv.Deref(r.EldDeviceSerial),
		OdometerM:       r.OdometerM,
		TelemetryAt:     pgconv.ToTimePtr(r.TelemetryAt),
		ActivatedOn:     pgconv.ToTimePtr(r.ActivatedOn),
		CreatedAt:       r.CreatedAt.UTC(),
		UpdatedAt:       r.UpdatedAt.UTC(),
	}
}

func unitFromRow(r db.FleetGetUnitRow) dto.Unit {
	return unitFromList(db.FleetListUnitsRow(r))
}

func deviceFromRow(r db.FleetGetEldDeviceRow) dto.EldDevice {
	return deviceFromList(db.FleetListEldDevicesRow(r))
}

func deviceFromList(r db.FleetListEldDevicesRow) dto.EldDevice {
	codes := r.MalfunctionCodes
	if codes == nil {
		codes = []string{}
	}
	return dto.EldDevice{
		ID:               r.ID.String(),
		Vendor:           r.Vendor,
		Model:            pgconv.Deref(r.Model),
		Serial:           r.Serial,
		Firmware:         pgconv.Deref(r.Firmware),
		ConnectionType:   pgconv.Deref(r.ConnectionType),
		SimPresent:       r.SimPresent,
		Status:           r.Status,
		Notes:            pgconv.Deref(r.Notes),
		UnitID:           pgconv.UUIDString(r.UnitID),
		UnitNumber:       pgconv.Deref(r.UnitNumber),
		MalfunctionCodes: codes,
		LastSeenAt:       pgconv.ToTimePtr(r.LastSeenAt),
		CreatedAt:        r.CreatedAt.UTC(),
		UpdatedAt:        r.UpdatedAt.UTC(),
	}
}

func trailerFrom(r db.Trailer) dto.Trailer {
	return dto.Trailer{
		ID:        r.ID.String(),
		Number:    r.Number,
		Notes:     pgconv.Deref(r.Notes),
		CreatedAt: r.CreatedAt.UTC(),
		UpdatedAt: r.UpdatedAt.UTC(),
	}
}

func docFrom(r db.ShippingDocument) dto.ShippingDocument {
	return dto.ShippingDocument{
		ID:        r.ID.String(),
		Number:    r.Number,
		Notes:     pgconv.Deref(r.Notes),
		CreatedAt: r.CreatedAt.UTC(),
		UpdatedAt: r.UpdatedAt.UTC(),
	}
}

// diagnosticsFrom renders the administrator facing device state (TZ §10.1):
// Malfunction wins over everything, then Disconnected as reported by the
// device, then Online when telemetry is younger than five minutes.
func diagnosticsFrom(r db.FleetGetUnitDiagnosticsRow, now time.Time) dto.UnitDiagnostics {
	out := dto.UnitDiagnostics{
		UnitID:           r.UnitID.String(),
		UnitNumber:       r.UnitNumber,
		DeviceID:         pgconv.UUIDString(r.DeviceID),
		DeviceSerial:     pgconv.Deref(r.DeviceSerial),
		DeviceVendor:     pgconv.Deref(r.DeviceVendor),
		DeviceModel:      pgconv.Deref(r.DeviceModel),
		DeviceFirmware:   pgconv.Deref(r.DeviceFirmware),
		ConnectionType:   pgconv.Deref(r.ConnectionType),
		SimPresent:       r.SimPresent != nil && *r.SimPresent,
		DeviceStatus:     pgconv.Deref(r.DeviceStatus),
		MalfunctionCodes: malfunctions(r.MalfunctionCodes),
		LastSeenAt:       pgconv.ToTimePtr(r.LastSeenAt),
		TelemetryAt:      pgconv.ToTimePtr(r.TelemetryAt),
		Telemetry: dto.UnitTelemetry{
			OdometerM:       r.OdometerM,
			EngineHours:     numeric(r.EngineHours),
			FuelPct:         r.FuelPct,
			CoolantTempC:    r.CoolantTempC,
			CoolantLevelPct: r.CoolantLevelPct,
			OilLevelPct:     r.OilLevelPct,
			BatteryPct:      r.BatteryPct,
			BatteryVoltageV: r.BatteryVoltageV,
		},
	}
	out.ConnectionState = connectionState(r, now)
	return out
}

func connectionState(r db.FleetGetUnitDiagnosticsRow, now time.Time) string {
	if !r.DeviceID.Valid {
		return dto.ConnNoDevice
	}
	if len(r.MalfunctionCodes) > 0 || pgconv.Deref(r.DeviceStatus) == "malfunction" {
		return dto.ConnMalfunction
	}
	// The device itself reports the phone link is down (unit_last_state is fed
	// by the ingest pipeline; "disconnected" is only ever written by it).
	if s := pgconv.Deref(r.OnlineStatus); s == "disconnected" {
		return dto.ConnDisconnected
	}
	last := r.TelemetryAt
	if !last.Valid && r.LastSeenAt.Valid {
		last = r.LastSeenAt
	}
	if last.Valid && now.Sub(last.Time.UTC()) <= onlineWindow {
		return dto.ConnOnline
	}
	if !last.Valid {
		return dto.ConnDisconnected
	}
	return dto.ConnOffline
}

func malfunctions(codes []string) []dto.MalfunctionCode {
	out := make([]dto.MalfunctionCode, 0, len(codes))
	for _, c := range codes {
		key := strings.ToUpper(strings.TrimSpace(c))
		if key == "" {
			continue
		}
		name, ok := malfunctionNames[key]
		if !ok {
			name = malfunctionNames["O"]
		}
		out = append(out, dto.MalfunctionCode{Code: key, Description: name})
	}
	return out
}

func assignmentFrom(r db.FleetListUnitAssignmentsRow) dto.UnitAssignment {
	return dto.UnitAssignment{
		ID:           r.ID.String(),
		UnitID:       r.UnitID.String(),
		DriverID:     r.DriverID.String(),
		DriverName:   fullName(&r.FirstName, &r.LastName),
		Role:         r.Role,
		AssignedAt:   r.AssignedAt.UTC(),
		UnassignedAt: pgconv.ToTimePtr(r.UnassignedAt),
	}
}

func historyFromAudit(r db.FleetListUnitAuditRow) dto.UnitHistoryEntry {
	return dto.UnitHistoryEntry{
		Kind:      "audit",
		ID:        r.ID.String(),
		At:        r.Ts.UTC(),
		Action:    r.Action,
		Field:     pgconv.Deref(r.Field),
		OldValue:  string(r.OldValue),
		NewValue:  string(r.NewValue),
		ActorID:   pgconv.UUIDString(r.EditedBy),
		ActorName: fullName(r.FirstName, r.LastName),
	}
}

func historyFromAssignment(r db.FleetListUnitAssignmentsRow) dto.UnitHistoryEntry {
	return dto.UnitHistoryEntry{
		Kind:      "assignment",
		ID:        r.ID.String(),
		At:        r.AssignedAt.UTC(),
		Action:    string(audit.ActionAssign),
		Field:     "driver_id",
		NewValue:  r.DriverID.String(),
		ActorName: fullName(&r.FirstName, &r.LastName),
	}
}

func fullName(first, last *string) string {
	name := strings.TrimSpace(pgconv.Deref(first) + " " + pgconv.Deref(last))
	return name
}

func numeric(v pgtype.Numeric) *float64 {
	if !v.Valid {
		return nil
	}
	f, err := v.Float64Value()
	if err != nil || !f.Valid {
		return nil
	}
	out := f.Float64
	return &out
}
