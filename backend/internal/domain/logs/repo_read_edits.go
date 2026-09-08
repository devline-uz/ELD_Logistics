// Read side of the propose/approve queue, the unidentified driving buffer and
// the violation catalogue. Split out of repo_read.go to keep both files under
// the 400 line ceiling.
package logs

import (
	"context"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// EditRequest implements Repo.
func (r *PgRepo) EditRequest(ctx context.Context, companyID, id uuid.UUID) (EditRequest, error) {
	var out EditRequest
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		row, err := q.LogsGetEditRequest(ctx, db.LogsGetEditRequestParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		out = EditRequest{
			ID: row.ID, CompanyID: row.CompanyID, DriverID: row.DriverID,
			DriverUserID: row.UserID, BranchID: pgconv.ToUUIDPtr(row.BranchID),
			DriverName: fullName(row.FirstName, row.LastName),
			DailyLogID: row.DailyLogID, LogDate: row.LogDate.Time, Timezone: row.Timezone,
			RequestedBy: row.RequestedBy, Status: row.Status, Source: row.Source,
			Changes: row.Changes, DriverNote: row.DriverNote,
			UnidentifiedEventID: pgconv.ToUUIDPtr(row.UnidentifiedEventID),
			ResolvedAt:          pgconv.ToTimePtr(row.ResolvedAt),
			CreatedAt:           row.CreatedAt, UpdatedAt: row.UpdatedAt,
		}
		return nil
	})
	return out, err
}

// EditRequests implements Repo.
func (r *PgRepo) EditRequests(ctx context.Context, f EditRequestFilter) ([]EditRequest, int64, error) {
	var (
		out   []EditRequest
		total int64
	)
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		rows, err := q.LogsListEditRequests(ctx, db.LogsListEditRequestsParams{
			CompanyID: f.CompanyID, Status: f.Status,
			DriverID: pgconv.UUIDPtr(f.DriverID), BranchID: pgconv.UUIDPtr(f.BranchID),
			Lim: f.Limit, Off: f.Offset,
		})
		if err != nil {
			return err
		}
		out = make([]EditRequest, 0, len(rows))
		for _, row := range rows {
			out = append(out, EditRequest{
				ID: row.ID, CompanyID: row.CompanyID, DriverID: row.DriverID,
				DriverName: fullName(row.FirstName, row.LastName),
				DailyLogID: row.DailyLogID, LogDate: row.LogDate.Time, Timezone: row.Timezone,
				RequestedBy: row.RequestedBy, Status: row.Status, Source: row.Source,
				Changes: row.Changes, DriverNote: row.DriverNote,
				UnidentifiedEventID: pgconv.ToUUIDPtr(row.UnidentifiedEventID),
				ResolvedAt:          pgconv.ToTimePtr(row.ResolvedAt),
				CreatedAt:           row.CreatedAt, UpdatedAt: row.UpdatedAt,
			})
		}
		total, err = q.LogsCountEditRequests(ctx, db.LogsCountEditRequestsParams{
			CompanyID: f.CompanyID, Status: f.Status,
			DriverID: pgconv.UUIDPtr(f.DriverID), BranchID: pgconv.UUIDPtr(f.BranchID),
		})
		return err
	})
	return out, total, err
}

// PendingEditsForDriver implements Repo: the /sync/pull payload (Q17).
func (r *PgRepo) PendingEditsForDriver(ctx context.Context, companyID, driverID uuid.UUID,
	since time.Time, limit int32,
) ([]PendingEdit, error) {
	out := []PendingEdit{}
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.LogsListPendingEditRequestsForDriver(ctx, db.LogsListPendingEditRequestsForDriverParams{
			CompanyID: companyID, DriverID: driverID, Since: since.UTC(), Lim: limit,
		})
		if err != nil {
			return err
		}
		for _, row := range rows {
			out = append(out, PendingEdit{
				ID: row.ID, DailyLogID: row.DailyLogID, Status: row.Status, Source: row.Source,
				Changes: row.Changes, LogDate: row.LogDate.Time, Timezone: row.Timezone,
				CreatedAt: row.CreatedAt, UpdatedAt: row.UpdatedAt,
			})
		}
		return nil
	})
	return out, err
}

// Unidentified implements Repo.
func (r *PgRepo) Unidentified(ctx context.Context, companyID, id uuid.UUID) (Unidentified, error) {
	var out Unidentified
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		row, err := q.LogsGetUnidentifiedEvent(ctx, db.LogsGetUnidentifiedEventParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		out = unidentifiedFrom(db.UnidentifiedEvent{
			ID: row.ID, CompanyID: row.CompanyID, UnitID: row.UnitID, StartAt: row.StartAt,
			EndAt: row.EndAt, DistanceM: row.DistanceM, Status: row.Status,
			AssignedDriverID: row.AssignedDriverID, Annotation: row.Annotation,
			EditRequestID: row.EditRequestID, CreatedAt: row.CreatedAt,
		})
		out.UnitNumber = row.UnitNumber
		return nil
	})
	return out, err
}

func unidentifiedFrom(row db.UnidentifiedEvent) Unidentified {
	return Unidentified{
		ID: row.ID, CompanyID: row.CompanyID, UnitID: row.UnitID,
		StartAt: row.StartAt, EndAt: pgconv.ToTimePtr(row.EndAt), DistanceM: row.DistanceM,
		Status: row.Status, AssignedDriverID: pgconv.ToUUIDPtr(row.AssignedDriverID),
		Annotation: row.Annotation, EditRequestID: pgconv.ToUUIDPtr(row.EditRequestID),
		CreatedAt: row.CreatedAt,
	}
}

// StaleUnidentified implements Repo: blocks unassigned for longer than the
// 8 day window (Q57 `unidentified_driving`).
func (r *PgRepo) StaleUnidentified(ctx context.Context, companyID uuid.UUID, before time.Time) ([]Unidentified, error) {
	out := []Unidentified{}
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.LogsListStaleUnidentifiedEvents(ctx, db.LogsListStaleUnidentifiedEventsParams{
			CompanyID: companyID, Before: before.UTC(),
		})
		if err != nil {
			return err
		}
		for _, row := range rows {
			out = append(out, unidentifiedFrom(row))
		}
		return nil
	})
	return out, err
}

// Violations implements Repo.
func (r *PgRepo) Violations(ctx context.Context, f ViolationFilter) ([]ViolationRow, int64, error) {
	var (
		out   []ViolationRow
		total int64
	)
	err := r.read(ctx, f.CompanyID, func(q *db.Queries) error {
		rows, err := q.LogsListViolations(ctx, db.LogsListViolationsParams{
			CompanyID: f.CompanyID, DriverID: pgconv.UUIDPtr(f.DriverID), BranchID: pgconv.UUIDPtr(f.BranchID),
			Type: f.Type, Severity: f.Severity, Resolved: f.Resolved,
			FromAt: pgconv.TimePtr(f.From), ToAt: pgconv.TimePtr(f.To),
			Lim: f.Limit, Off: f.Offset,
		})
		if err != nil {
			return err
		}
		out = make([]ViolationRow, 0, len(rows))
		for _, row := range rows {
			v := ViolationRow{
				ID: row.ID, DriverID: pgconv.ToUUIDPtr(row.DriverID),
				DailyLogID: pgconv.ToUUIDPtr(row.DailyLogID), UnitID: pgconv.ToUUIDPtr(row.UnitID),
				Type: row.Type, Severity: row.Severity, OccurredAt: row.OccurredAt,
				Details: row.Details, PolicyVersionID: pgconv.ToUUIDPtr(row.PolicyVersionID),
				ResolvedAt: pgconv.ToTimePtr(row.ResolvedAt), ResolvedReason: row.ResolvedReason,
				CreatedAt: row.CreatedAt,
			}
			v.DriverName = optionalName(row.FirstName, row.LastName)
			if row.LogDate.Valid {
				d := row.LogDate.Time
				v.LogDate = &d
			}
			out = append(out, v)
		}
		total, err = q.LogsCountViolations(ctx, db.LogsCountViolationsParams{
			CompanyID: f.CompanyID, DriverID: pgconv.UUIDPtr(f.DriverID), BranchID: pgconv.UUIDPtr(f.BranchID),
			Type: f.Type, Severity: f.Severity, Resolved: f.Resolved,
			FromAt: pgconv.TimePtr(f.From), ToAt: pgconv.TimePtr(f.To),
		})
		return err
	})
	return out, total, err
}

// Violation implements Repo.
func (r *PgRepo) Violation(ctx context.Context, companyID, id uuid.UUID) (ViolationRow, error) {
	var out ViolationRow
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		row, err := q.LogsGetViolation(ctx, db.LogsGetViolationParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		out = ViolationRow{
			ID: row.ID, DriverID: pgconv.ToUUIDPtr(row.DriverID),
			DailyLogID: pgconv.ToUUIDPtr(row.DailyLogID), UnitID: pgconv.ToUUIDPtr(row.UnitID),
			BranchID: pgconv.ToUUIDPtr(row.BranchID),
			Type:     row.Type, Severity: row.Severity, OccurredAt: row.OccurredAt,
			Details: row.Details, PolicyVersionID: pgconv.ToUUIDPtr(row.PolicyVersionID),
			ResolvedAt: pgconv.ToTimePtr(row.ResolvedAt), ResolvedReason: row.ResolvedReason,
			CreatedAt: row.CreatedAt,
		}
		out.DriverName = optionalName(row.FirstName, row.LastName)
		if row.LogDate.Valid {
			d := row.LogDate.Time
			out.LogDate = &d
		}
		return nil
	})
	return out, err
}

// dayKeyOf renders a stored log date as the API calendar day.
func dayKeyOf(day time.Time) string { return day.Format(dayLayout) }

// localDay rebuilds the local midnight of a stored DATE inside loc (Q10.2).
func localDay(day time.Time, loc *time.Location) time.Time {
	return time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, loc)
}

// LogViolations implements Repo: every violation of one log day, open or
// closed. A closed violation is kept forever (Q58).
func (r *PgRepo) LogViolations(ctx context.Context, companyID, dailyLogID uuid.UUID) ([]ViolationRow, error) {
	out := []ViolationRow{}
	err := r.read(ctx, companyID, func(q *db.Queries) error {
		rows, err := q.ListViolationsByDailyLog(ctx, db.ListViolationsByDailyLogParams{
			CompanyID: companyID, DailyLogID: pgconv.UUID(dailyLogID),
		})
		if err != nil {
			return err
		}
		for _, row := range rows {
			out = append(out, ViolationRow{
				ID: row.ID, DriverID: pgconv.ToUUIDPtr(row.DriverID),
				DailyLogID: pgconv.ToUUIDPtr(row.DailyLogID), UnitID: pgconv.ToUUIDPtr(row.UnitID),
				Type: row.Type, Severity: row.Severity, OccurredAt: row.OccurredAt,
				Details: row.Details, PolicyVersionID: pgconv.ToUUIDPtr(row.PolicyVersionID),
				ResolvedAt: pgconv.ToTimePtr(row.ResolvedAt), ResolvedReason: row.ResolvedReason,
				CreatedAt: row.CreatedAt,
			})
		}
		return nil
	})
	return out, err
}
