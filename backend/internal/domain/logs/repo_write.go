package logs

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/hos"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// totalsLookbackDays is how far back the totals recomputation replays so an
// overnight status carries into the day being rewritten.
const totalsLookbackDays = 2

// Certify implements Repo (Q26.1): the signature, the `certification` event
// and the day lock all land in one transaction.
func (r *PgRepo) Certify(ctx context.Context, in CertifyInput, entries []audit.Entry) (DailyLog, error) {
	var out DailyLog
	err := r.pool.WithTx(ctx, in.CompanyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		row, err := q.LogsCertifyDailyLog(ctx, db.LogsCertifyDailyLogParams{
			CompanyID: in.CompanyID, ID: in.DailyLogID,
			SignedAt:       pgconv.Time(in.SignedAt.UTC()),
			SignatureKey:   &in.SignatureKey,
			SignedDeviceID: in.DeviceID, SignedIp: in.IP,
			SignedBy: pgconv.UUID(in.UserID),
		})
		if err != nil {
			return err
		}
		if _, err := q.CreateDutyStatusEvent(ctx, db.CreateDutyStatusEventParams{
			CompanyID: in.CompanyID, DriverID: pgconv.UUID(in.DriverID),
			EventType: eventCertify, Special: string(hos.SpecialNone),
			EventTime: in.SignedAt.UTC(), TimeSource: "server", Origin: originDriver,
			TrailerIds: []uuid.UUID{}, ShippingDocIds: []uuid.UUID{},
			ClientEventID: in.ClientEventID, DailyLogID: pgconv.UUID(in.DailyLogID),
		}); err != nil {
			return err
		}
		// Q26.1: certified events may only move through an edit request.
		if err := q.LogsLockDayEvents(ctx, db.LogsLockDayEventsParams{
			Locked: true, CompanyID: in.CompanyID, DailyLogID: pgconv.UUID(in.DailyLogID),
		}); err != nil {
			return err
		}
		out = DailyLog{
			ID: row.ID, CompanyID: row.CompanyID, DriverID: row.DriverID,
			LogDate: row.LogDate.Time, Timezone: row.Timezone,
			UnitIDs: row.UnitIds, TrailerIDs: row.TrailerIds, ShippingDocIDs: row.ShippingDocIds,
			DistanceM: row.DistanceM, Totals: row.Totals,
			CertificationStatus: row.CertificationStatus,
			SignedAt:            pgconv.ToTimePtr(row.SignedAt),
			SignatureKey:        row.SignatureKey, SignedDeviceID: row.SignedDeviceID, SignedIP: row.SignedIp,
			CreatedAt: row.CreatedAt, UpdatedAt: row.UpdatedAt,
		}
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	return out, err
}

// CreateEditRequest implements Repo (Q17): the admin proposal is stored
// pending; the log itself is untouched until the driver approves.
func (r *PgRepo) CreateEditRequest(ctx context.Context, in EditRequest, entries []audit.Entry) (EditRequest, error) {
	out := in
	err := r.pool.WithTx(ctx, in.CompanyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		row, err := q.LogsCreateEditRequest(ctx, db.LogsCreateEditRequestParams{
			CompanyID: in.CompanyID, DriverID: in.DriverID, DailyLogID: in.DailyLogID,
			RequestedBy: in.RequestedBy, Changes: in.Changes, Source: in.Source,
			UnidentifiedEventID: pgconv.UUIDPtr(in.UnidentifiedEventID),
		})
		if err != nil {
			return err
		}
		out.ID = row.ID
		out.Status = row.Status
		out.CreatedAt = row.CreatedAt
		out.UpdatedAt = row.UpdatedAt
		for i := range entries {
			entries[i].RecordID = row.ID
		}
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	return out, err
}

// RejectEditRequest implements Repo: the log stays as it is, the reason is
// stored and an unidentified proposal falls back to pending (§10.4).
func (r *PgRepo) RejectEditRequest(ctx context.Context, companyID, id, by uuid.UUID, reason string,
	unidentifiedID *uuid.UUID, entries []audit.Entry,
) (EditRequest, error) {
	var out EditRequest
	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		row, err := q.LogsResolveEditRequest(ctx, db.LogsResolveEditRequestParams{
			CompanyID: companyID, ID: id, Status: editRejected,
			ResolvedBy: pgconv.UUID(by), DriverNote: &reason,
		})
		if err != nil {
			return err
		}
		if unidentifiedID != nil {
			if err := q.LogsResetUnidentifiedEvent(ctx, db.LogsResetUnidentifiedEventParams{
				CompanyID: companyID, ID: *unidentifiedID,
			}); err != nil {
				return err
			}
		}
		out = EditRequest{
			ID: row.ID, CompanyID: row.CompanyID, DriverID: row.DriverID,
			DailyLogID: row.DailyLogID, RequestedBy: row.RequestedBy,
			Status: row.Status, Source: row.Source, Changes: row.Changes,
			DriverNote: row.DriverNote, ResolvedAt: pgconv.ToTimePtr(row.ResolvedAt),
			UnidentifiedEventID: pgconv.ToUUIDPtr(row.UnidentifiedEventID),
			CreatedAt:           row.CreatedAt, UpdatedAt: row.UpdatedAt,
		}
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	return out, err
}

// ApplyEdit implements Repo: one transaction writes the new events, flags the
// originals with `superseded_by` (nothing is deleted), moves the assigned
// unidentified rows, recomputes the day totals and falls the day back to
// needs_recertify when it was certified (Q17, Q18).
func (r *PgRepo) ApplyEdit(ctx context.Context, plan EditPlan, entries []audit.Entry) error {
	loc, err := time.LoadLocation(plan.Timezone)
	if err != nil || loc == nil {
		loc = time.UTC
	}
	return r.pool.WithTx(ctx, plan.CompanyID, func(tx pgx.Tx) error {
		q := db.New(tx)

		for _, group := range plan.Groups {
			var anchor uuid.UUID
			for i, ev := range group.Boundary {
				status := ev.Status
				note := ev.Note
				row, err := q.LogsInsertEditEvent(ctx, db.LogsInsertEditEventParams{
					CompanyID: plan.CompanyID, DriverID: pgconv.UUID(plan.DriverID),
					UnitID: pgconv.UUIDPtr(ev.UnitID), Status: &status, Special: ev.Special,
					EventTime: ev.EventTime.UTC(), Origin: ev.Origin, Notes: &note,
					ClientEventID: uuid.New(), DailyLogID: pgconv.UUID(plan.DailyLogID),
				})
				if err != nil {
					return err
				}
				if i == 0 {
					anchor = row.ID
				}
			}
			if len(group.Supersede) > 0 && anchor != uuid.Nil {
				if err := q.LogsSupersedeEvents(ctx, db.LogsSupersedeEventsParams{
					CompanyID: plan.CompanyID, Ids: group.Supersede, SupersededBy: pgconv.UUID(anchor),
				}); err != nil {
					return err
				}
			}
		}

		if len(plan.AssignEventIDs) > 0 {
			if err := q.LogsAssignEventsToDriver(ctx, db.LogsAssignEventsToDriverParams{
				CompanyID: plan.CompanyID, Ids: plan.AssignEventIDs,
				DriverID: pgconv.UUID(plan.DriverID), DailyLogID: pgconv.UUID(plan.DailyLogID),
			}); err != nil {
				return err
			}
		}

		if plan.ResolveRequestID != nil {
			if _, err := q.LogsResolveEditRequest(ctx, db.LogsResolveEditRequestParams{
				CompanyID: plan.CompanyID, ID: *plan.ResolveRequestID, Status: plan.ResolveStatus,
				ResolvedBy: pgconv.UUID(plan.ResolveBy), DriverNote: plan.ResolveNote,
			}); err != nil {
				return err
			}
		}
		if plan.UnidentifiedID != nil {
			if _, err := q.LogsClaimUnidentifiedEvent(ctx, db.LogsClaimUnidentifiedEventParams{
				CompanyID: plan.CompanyID, ID: *plan.UnidentifiedID,
				AssignedDriverID: pgconv.UUID(plan.DriverID),
			}); err != nil {
				return err
			}
		}

		if err := recomputeTotals(ctx, q, plan.CompanyID, plan.DriverID, plan.DailyLogID, plan.Day, loc); err != nil {
			return err
		}
		// Q18: a certified day that was edited has to be signed again.
		if plan.Certified {
			if err := q.LogsMarkNeedsRecertify(ctx, db.LogsMarkNeedsRecertifyParams{
				CompanyID: plan.CompanyID, ID: plan.DailyLogID,
			}); err != nil {
				return err
			}
			if err := q.LogsLockDayEvents(ctx, db.LogsLockDayEventsParams{
				Locked: false, CompanyID: plan.CompanyID, DailyLogID: pgconv.UUID(plan.DailyLogID),
			}); err != nil {
				return err
			}
		}
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
}

// recomputeTotals rewrites daily_logs.totals from the stored events of that
// day using hos.DayTotalsFor.
func recomputeTotals(ctx context.Context, q *db.Queries, companyID, driverID, dailyLogID uuid.UUID,
	day time.Time, loc *time.Location,
) error {
	local := localDay(day, loc)
	_, end := hos.DayRange(local, loc)
	rows, err := q.LogsListDriverEventsBetween(ctx, db.LogsListDriverEventsBetweenParams{
		CompanyID: companyID, DriverID: pgconv.UUID(driverID),
		FromAt: local.AddDate(0, 0, -totalsLookbackDays).UTC(), ToAt: end.UTC(),
	})
	if err != nil {
		return err
	}

	events := make([]hos.Event, 0, len(rows))
	units := make([]uuid.UUID, 0, 4)
	seen := make(map[uuid.UUID]struct{}, 4)
	for _, row := range rows {
		se := storedEvent(row)
		events = append(events, se.HosEvent())
		if se.UnitID != nil && row.EventTime.Before(end) && !row.EventTime.Before(local.UTC()) {
			if _, dup := seen[*se.UnitID]; !dup {
				seen[*se.UnitID] = struct{}{}
				units = append(units, *se.UnitID)
			}
		}
	}

	totals := hos.DayTotalsFor(events, local, loc)
	payload, err := json.Marshal(map[string]int64{
		"off": minutesOf(totals.Off),
		"sb":  minutesOf(totals.SB),
		"dr":  minutesOf(totals.Drive),
		"on":  minutesOf(totals.On),
	})
	if err != nil {
		return err
	}
	return q.DutySetDailyLogTotals(ctx, db.DutySetDailyLogTotalsParams{
		CompanyID: companyID, ID: dailyLogID, Totals: payload, UnitIds: units,
	})
}

func minutesOf(d time.Duration) int64 { return int64(d / time.Minute) }

// CreateAssignmentRequest implements Repo (§10.4). Q: the earlier version ran
// the edit request insert and the unidentified_events status flip in two
// separate transactions; a failure of the second left the request `pending`
// forever while the block never reached `proposed` — a permanent data
// mismatch. Both writes now share one transaction: either the proposal and
// the status flip both land, or neither does.
func (r *PgRepo) CreateAssignmentRequest(ctx context.Context, req EditRequest, blockID, driverID, by uuid.UUID,
	requestEntries, proposeEntries []audit.Entry,
) (EditRequest, error) {
	out := req
	err := r.pool.WithTx(ctx, req.CompanyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		row, err := q.LogsCreateEditRequest(ctx, db.LogsCreateEditRequestParams{
			CompanyID: req.CompanyID, DriverID: req.DriverID, DailyLogID: req.DailyLogID,
			RequestedBy: req.RequestedBy, Changes: req.Changes, Source: req.Source,
			UnidentifiedEventID: pgconv.UUIDPtr(req.UnidentifiedEventID),
		})
		if err != nil {
			return err
		}
		out.ID = row.ID
		out.Status = row.Status
		out.CreatedAt = row.CreatedAt
		out.UpdatedAt = row.UpdatedAt
		for i := range requestEntries {
			requestEntries[i].RecordID = row.ID
		}

		if _, err := q.LogsProposeUnidentifiedEvent(ctx, db.LogsProposeUnidentifiedEventParams{
			CompanyID: req.CompanyID, ID: blockID,
			AssignedDriverID: pgconv.UUID(driverID),
			EditRequestID:    pgconv.UUID(row.ID),
			ResolvedBy:       pgconv.UUID(by),
		}); err != nil {
			return err
		}

		entries := make([]audit.Entry, 0, len(requestEntries)+len(proposeEntries))
		entries = append(entries, requestEntries...)
		entries = append(entries, proposeEntries...)
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	return out, err
}

// AnnotateUnidentified implements Repo (§10.4): the block stays unassigned
// with an explanation, for example a mechanic's test drive.
func (r *PgRepo) AnnotateUnidentified(ctx context.Context, companyID, id, by uuid.UUID, annotation string,
	entries []audit.Entry,
) (Unidentified, error) {
	var out Unidentified
	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		row, err := q.LogsAnnotateUnidentifiedEvent(ctx, db.LogsAnnotateUnidentifiedEventParams{
			CompanyID: companyID, ID: id, Annotation: &annotation, ResolvedBy: pgconv.UUID(by),
		})
		if err != nil {
			return err
		}
		out = unidentifiedFrom(row)
		return r.recorder.RecordTx(ctx, tx, entries...)
	})
	return out, err
}

// SyncViolations implements Repo (Q58): everything the engine still reports is
// upserted, everything it stopped reporting is closed with a reason. A closed
// violation stays in the table forever.
func (r *PgRepo) SyncViolations(ctx context.Context, in ViolationSync) error {
	return r.pool.WithTx(ctx, in.CompanyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		open, err := q.LogsListOpenViolationsForLog(ctx, db.LogsListOpenViolationsForLogParams{
			CompanyID: in.CompanyID, DailyLogID: pgconv.UUID(in.DailyLogID),
		})
		if err != nil {
			return err
		}

		wanted := make(map[string]struct{}, len(in.Items))
		for _, item := range in.Items {
			wanted[item.Type] = struct{}{}
			if _, err := q.LogsUpsertDayViolation(ctx, db.LogsUpsertDayViolationParams{
				CompanyID: in.CompanyID, DriverID: pgconv.UUID(in.DriverID),
				UnitID: pgconv.UUIDPtr(in.UnitID), DailyLogID: pgconv.UUID(in.DailyLogID),
				Type: item.Type, Severity: item.Severity, OccurredAt: item.OccurredAt.UTC(),
				Details: item.Details, PolicyVersionID: pgconv.UUIDPtr(in.PolicyVersionID),
			}); err != nil {
				return err
			}
		}

		byReason := map[string][]string{}
		for _, row := range open {
			if _, still := wanted[row.Type]; still {
				continue
			}
			reason := ResolutionReason(row.Type)
			byReason[reason] = append(byReason[reason], row.Type)
		}
		for reason, types := range byReason {
			r := reason
			if err := q.LogsResolveDayViolations(ctx, db.LogsResolveDayViolationsParams{
				CompanyID: in.CompanyID, DailyLogID: pgconv.UUID(in.DailyLogID),
				Types: types, ResolvedReason: &r,
			}); err != nil {
				return err
			}
		}
		return nil
	})
}

// RaiseUnidentifiedViolation implements Repo (Q57 `unidentified_driving`).
func (r *PgRepo) RaiseUnidentifiedViolation(ctx context.Context, in UnidentifiedViolation) error {
	return r.pool.WithTx(ctx, in.CompanyID, func(tx pgx.Tx) error {
		_, err := db.New(tx).LogsUpsertUnidentifiedViolation(ctx, db.LogsUpsertUnidentifiedViolationParams{
			CompanyID: in.CompanyID, UnidentifiedEventID: pgconv.UUID(in.EventID),
			UnitID: pgconv.UUIDPtr(in.UnitID), OccurredAt: in.OccurredAt.UTC(), Details: in.Details,
		})
		return err
	})
}

// ResolveUnidentifiedViolation implements Repo: assignment closes the alert.
func (r *PgRepo) ResolveUnidentifiedViolation(ctx context.Context, companyID, eventID uuid.UUID,
	reason string, by *uuid.UUID,
) error {
	return r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		return db.New(tx).LogsResolveUnidentifiedViolation(ctx, db.LogsResolveUnidentifiedViolationParams{
			CompanyID: companyID, UnidentifiedEventID: pgconv.UUID(eventID),
			ResolvedReason: &reason, ResolvedBy: pgconv.UUIDPtr(by),
		})
	})
}
