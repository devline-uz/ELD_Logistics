package dvir

import (
	"encoding/json"
	"math/big"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
)

// reportRow is the shape shared by the detail, list and pending-certification
// rows; keeping one converter avoids three near identical mappers.
type reportRow struct {
	db.DvirReport
	UnitNumber   string
	OutOfService bool
	FirstName    string
	LastName     string
}

func reportFromDetail(r db.GetDvirReportDetailRow) dto.DvirReport {
	return reportFrom(reportRow{
		DvirReport:   detailToModel(r),
		UnitNumber:   r.UnitNumber,
		OutOfService: r.OutOfService,
		FirstName:    r.FirstName,
		LastName:     r.LastName,
	})
}

func reportFromList(r db.ListDvirReportsRow) dto.DvirReport {
	return reportFromDetail(db.GetDvirReportDetailRow(r))
}

func reportFromPending(r db.ListDvirPendingCertificationRow) dto.DvirReport {
	return reportFromDetail(db.GetDvirReportDetailRow(r))
}

func detailToModel(r db.GetDvirReportDetailRow) db.DvirReport {
	return db.DvirReport{
		ID: r.ID, CompanyID: r.CompanyID, UnitID: r.UnitID, DriverID: r.DriverID,
		Type: r.Type, TrailerIds: r.TrailerIds, Status: r.Status, Defects: r.Defects,
		Lat: r.Lat, Lng: r.Lng, LocationText: r.LocationText, OdometerM: r.OdometerM,
		EngineHours: r.EngineHours, DriverSignatureKey: r.DriverSignatureKey,
		MechanicID: r.MechanicID, MechanicNote: r.MechanicNote,
		MechanicSignatureKey: r.MechanicSignatureKey, RepairedAt: r.RepairedAt,
		CertifiedByDriverID: r.CertifiedByDriverID, CertifiedAt: r.CertifiedAt,
		Source: r.Source, PerformedAt: r.PerformedAt, CreatedAt: r.CreatedAt,
		UpdatedAt: r.UpdatedAt, CertificationSignatureKey: r.CertificationSignatureKey,
		ClosedAt: r.ClosedAt, ClosedReason: r.ClosedReason,
	}
}

func reportFrom(r reportRow) dto.DvirReport {
	defects := decodeDefects(r.Defects)
	critical := false
	for _, d := range defects {
		if d.IsCritical {
			critical = true
			break
		}
	}
	trailers := make([]string, 0, len(r.TrailerIds))
	for _, id := range r.TrailerIds {
		trailers = append(trailers, id.String())
	}

	out := dto.DvirReport{
		ID:                        r.ID.String(),
		UnitID:                    r.UnitID.String(),
		UnitNumber:                r.UnitNumber,
		OutOfService:              r.OutOfService,
		Type:                      r.Type,
		Status:                    r.Status,
		Kind:                      kindOf(r.Status),
		TrailerIDs:                trailers,
		Defects:                   defects,
		HasCriticalDefect:         critical,
		Lat:                       r.Lat,
		Lng:                       r.Lng,
		LocationText:              deref(r.LocationText),
		OdometerM:                 r.OdometerM,
		EngineHours:               numericToFloat(r.EngineHours),
		DriverSignatureKey:        deref(r.DriverSignatureKey),
		MechanicID:                pgUUIDString(r.MechanicID),
		MechanicNote:              deref(r.MechanicNote),
		MechanicSignatureKey:      deref(r.MechanicSignatureKey),
		CertificationSignatureKey: deref(r.CertificationSignatureKey),
		RepairedAt:                pgTime(r.RepairedAt),
		CertifiedAt:               pgTime(r.CertifiedAt),
		CertifiedByDriver:         pgUUIDString(r.CertifiedByDriverID),
		ClosedAt:                  pgTime(r.ClosedAt),
		ClosedReason:              deref(r.ClosedReason),
		Source:                    r.Source,
		PerformedAt:               r.PerformedAt.UTC(),
		CreatedAt:                 r.CreatedAt.UTC(),
		UpdatedAt:                 r.UpdatedAt.UTC(),
	}
	if r.FirstName != "" || r.LastName != "" {
		out.Driver = &dto.DriverBrief{
			ID: r.DriverID.String(), FirstName: r.FirstName, LastName: r.LastName,
		}
	}
	return out
}

// kindOf derives the mobile label of TZ §7.3 from the stored status.
func kindOf(status string) string {
	switch status {
	case dto.StatusSubmittedNoDefects:
		return dto.KindNoDefects
	case dto.StatusSubmittedDefectsFound:
		return dto.KindDefectsNotFixed
	case dto.StatusRepaired:
		return dto.KindDefectsUncertified
	case dto.StatusCertified:
		return dto.KindDefectsFixed
	default:
		return dto.KindDefectsUncertified
	}
}

func decodeDefects(raw []byte) []dto.Defect {
	out := []dto.Defect{}
	if len(raw) == 0 {
		return out
	}
	if err := json.Unmarshal(raw, &out); err != nil {
		return []dto.Defect{}
	}
	for i := range out {
		if out[i].PhotoKeys == nil {
			out[i].PhotoKeys = []string{}
		}
	}
	return out
}

func defectTypeFrom(r db.DefectType) dto.DefectType {
	return dto.DefectType{
		ID:         r.ID.String(),
		Name:       r.Name,
		Category:   r.Category,
		IsCritical: r.IsCritical,
		IsActive:   r.IsActive,
		SortOrder:  r.SortOrder,
		IsSystem:   !r.CompanyID.Valid,
		CreatedAt:  r.CreatedAt.UTC(),
		UpdatedAt:  r.UpdatedAt.UTC(),
	}
}

func deref(v *string) string {
	if v == nil {
		return ""
	}
	return *v
}

func pgTime(v pgtype.Timestamptz) *time.Time {
	if !v.Valid {
		return nil
	}
	t := v.Time.UTC()
	return &t
}

func pgUUIDString(v pgtype.UUID) *string {
	if !v.Valid {
		return nil
	}
	s := uuid.UUID(v.Bytes).String()
	return &s
}

// numericToFloat converts a Postgres numeric into a float pointer. Engine hours
// carry two decimals, well inside float64 precision.
func numericToFloat(v pgtype.Numeric) *float64 {
	if !v.Valid || v.NaN || v.Int == nil {
		return nil
	}
	f, err := v.Float64Value()
	if err != nil || !f.Valid {
		return nil
	}
	out := f.Float64
	return &out
}

// floatToNumeric converts a float into a Postgres numeric with two decimals.
func floatToNumeric(v float64) pgtype.Numeric {
	cents := big.NewInt(int64(v*100 + copySign(0.5, v)))
	return pgtype.Numeric{Int: cents, Exp: -2, Valid: true}
}

func copySign(mag, sign float64) float64 {
	if sign < 0 {
		return -mag
	}
	return mag
}
