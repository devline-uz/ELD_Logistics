package sync

import (
	"encoding/json"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/db"
	dutydto "github.com/devline/onebook-eld/internal/domain/duty/dto"
	"github.com/devline/onebook-eld/internal/domain/sync/dto"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// changedEventDTO maps a server-canonical event onto the wire shape. The device
// rebuilds its local log from these rows (conflict rule 2).
func changedEventDTO(row db.SyncListEventsChangedSinceRow) dto.DutyStatusEvent {
	out := dto.DutyStatusEvent{
		ID:             row.ID.String(),
		ClientEventID:  row.ClientEventID.String(),
		EventType:      row.EventType,
		Special:        row.Special,
		Origin:         row.Origin,
		EventTime:      row.EventTime.UTC(),
		TimeSource:     row.TimeSource,
		TimeUnverified: row.TimeUnverified,
		ClockSkewSec:   row.ClockSkewSec,
		ReceivedAt:     row.ReceivedAt.UTC(),
		Lat:            row.Lat,
		Lng:            row.Lng,
		LocationText:   row.LocationText,
		GPSAccuracyM:   row.GpsAccuracyM,
		OdometerM:      row.OdometerM,
		EngineHours:    numericFloat(row.EngineHours),
		Notes:          row.Notes,
		TrailerIDs:     idStrings(row.TrailerIds),
		ShippingDocIDs: idStrings(row.ShippingDocIds),
		DeviceSeq:      row.DeviceSeq,
		Locked:         row.Locked,
	}
	if row.Status != nil {
		out.Status = *row.Status
	}
	out.UnitID = pgconv.UUIDString(row.UnitID)
	out.SupersededBy = pgconv.UUIDString(row.SupersededBy)
	out.DailyLogID = pgconv.UUIDString(row.DailyLogID)
	return out
}

// dailyLogDTO maps one canonical log day. `totals` is stored as minutes per
// duty line (Q10.2) and rewritten by the duty service on every write.
func dailyLogDTO(row db.SyncListDailyLogsChangedSinceRow) dto.DailyLogSummary {
	out := dto.DailyLogSummary{
		ID:                  row.ID.String(),
		Timezone:            row.Timezone,
		Totals:              parseTotals(row.Totals),
		DistanceM:           row.DistanceM,
		CertificationStatus: row.CertificationStatus,
		SignedAt:            pgconv.ToTimePtr(row.SignedAt),
		UpdatedAt:           row.UpdatedAt.UTC(),
	}
	if row.LogDate.Valid {
		out.LogDate = dayKeyOf(row.LogDate.Time)
	}
	return out
}

// parseTotals decodes the daily_logs.totals document. An unreadable document
// reports zeros rather than failing the pull: the totals are derived data and
// the next write recomputes them.
func parseTotals(raw []byte) dutydto.DayTotals {
	var doc struct {
		Off int64 `json:"off"`
		SB  int64 `json:"sb"`
		DR  int64 `json:"dr"`
		On  int64 `json:"on"`
	}
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &doc)
	}
	return dutydto.DayTotals{OffMin: doc.Off, SBMin: doc.SB, DriveMin: doc.DR, OnMin: doc.On}
}

// unidentifiedDTO maps one pending unidentified driving entry (TZ A§10.4).
func unidentifiedDTO(row db.SyncListUnidentifiedForUnitsRow) dto.UnidentifiedEvent {
	return dto.UnidentifiedEvent{
		ID:         row.ID.String(),
		UnitID:     row.UnitID.String(),
		UnitNumber: row.UnitNumber,
		StartAt:    row.StartAt.UTC(),
		EndAt:      pgconv.ToTimePtr(row.EndAt),
		DistanceM:  row.DistanceM,
		Status:     row.Status,
		UpdatedAt:  row.UpdatedAt.UTC(),
	}
}

// chatDTO maps one chat message of the driver's thread.
func chatDTO(row db.SyncListChatSinceRow) dto.ChatMessage {
	return dto.ChatMessage{
		ID:          row.ID.String(),
		SenderID:    row.SenderID.String(),
		Kind:        row.Kind,
		Text:        row.Text,
		FileKey:     row.FileKey,
		Lat:         row.Lat,
		Lng:         row.Lng,
		SentAt:      row.SentAt.UTC(),
		DeliveredAt: pgconv.ToTimePtr(row.DeliveredAt),
		ReadAt:      pgconv.ToTimePtr(row.ReadAt),
		UpdatedAt:   row.UpdatedAt.UTC(),
	}
}

// numericFloat reads a numeric(12,2) column back into a float.
func numericFloat(n pgtype.Numeric) *float64 {
	if !n.Valid {
		return nil
	}
	v, err := n.Float64Value()
	if err != nil || !v.Valid {
		return nil
	}
	out := v.Float64
	return &out
}

func idStrings(ids []uuid.UUID) []string {
	out := make([]string, 0, len(ids))
	for _, id := range ids {
		out = append(out, id.String())
	}
	return out
}
