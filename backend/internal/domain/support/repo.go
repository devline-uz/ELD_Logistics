package support

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// TicketFilter is the resolved GET /support-tickets query. Nil pointers mean
// "no filter". SelfUserID is set for a driver (`self` scope) principal and
// narrows the result to the tickets that principal owns.
type TicketFilter struct {
	Status     *string
	DriverID   *uuid.UUID
	Search     *string
	From       *time.Time
	To         *time.Time
	SelfUserID *uuid.UUID
	Sort       string
	Order      string
	Limit      int32
	Offset     int32
}

// FeedbackFilter is the resolved GET /feedback query.
type FeedbackFilter struct {
	DriverID  *uuid.UUID
	MinRating *int16
	From      *time.Time
	To        *time.Time
	Sort      string
	Order     string
	Limit     int32
	Offset    int32
}

// MessageFilter is the resolved GET /support-tickets/{id}/messages query.
type MessageFilter struct {
	TicketID uuid.UUID
	Limit    int32
	Offset   int32
}

// Repo is everything the support service needs from storage. Mutating methods
// take a callback that builds the audit entries; the repository writes the
// change and its audit trail inside one transaction so they can never diverge.
type Repo interface {
	ListTickets(ctx context.Context, f TicketFilter) ([]db.SupportListTicketsRow, int64, error)
	GetTicket(ctx context.Context, id uuid.UUID) (db.SupportGetTicketRow, error)
	CreateTicket(ctx context.Context, arg db.CreateSupportTicketParams,
		mk func(db.SupportTicket) []audit.Entry) (db.SupportGetTicketRow, error)
	SetTicketStatus(ctx context.Context, id uuid.UUID, status string,
		mk func(before string, after db.SupportTicket) []audit.Entry) (db.SupportGetTicketRow, error)

	ListMessages(ctx context.Context, f MessageFilter) ([]db.SupportListTicketMessagesRow, int64, error)
	CreateMessage(ctx context.Context, arg db.CreateTicketMessageParams,
		mk func(db.TicketMessage) []audit.Entry) (db.SupportGetTicketMessageRow, error)

	ListFeedback(ctx context.Context, f FeedbackFilter) ([]db.SupportListFeedbackRow, int64, error)
	CreateFeedback(ctx context.Context, arg db.CreateFeedbackParams,
		mk func(db.Feedback) []audit.Entry) (db.SupportListFeedbackRow, error)

	// DriverIDForUser resolves the caller's driver row, if any. It is how a
	// `self` scoped principal is attached to the ticket it files.
	DriverIDForUser(ctx context.Context, userID uuid.UUID) (uuid.UUID, error)
}

// PgRepo is the pgx/sqlc implementation of Repo. Every statement runs through
// Pool.WithTx / Pool.WithConn, which sets `SET LOCAL app.company_id` so RLS is
// the second line of defence behind the explicit company_id predicates.
type PgRepo struct {
	pool     *db.Pool
	recorder audit.Recorder
}

// NewRepo builds the storage adapter.
func NewRepo(pool *db.Pool, recorder audit.Recorder) *PgRepo {
	if recorder == nil {
		recorder = audit.NopRecorder{}
	}
	return &PgRepo{pool: pool, recorder: recorder}
}

func (r *PgRepo) read(ctx context.Context, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, tenant.CompanyID(ctx), func(tx pgx.Tx) error {
		return fn(db.New(tx))
	})
}

func (r *PgRepo) write(ctx context.Context, fn func(q *db.Queries, tx pgx.Tx) error) error {
	return r.pool.WithTx(ctx, tenant.CompanyID(ctx), func(tx pgx.Tx) error {
		return fn(db.New(tx), tx)
	})
}

// ListTickets implements Repo.
func (r *PgRepo) ListTickets(ctx context.Context, f TicketFilter) ([]db.SupportListTicketsRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.SupportListTicketsRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.SupportListTickets(ctx, db.SupportListTicketsParams{
			CompanyID:  companyID,
			Status:     f.Status,
			DriverID:   pgconv.UUIDPtr(f.DriverID),
			Search:     f.Search,
			FromTs:     pgconv.TimePtr(f.From),
			ToTs:       pgconv.TimePtr(f.To),
			SelfUserID: pgconv.UUIDPtr(f.SelfUserID),
			SortBy:     f.Sort,
			SortDir:    f.Order,
			RowLimit:   f.Limit,
			RowOffset:  f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.SupportCountTickets(ctx, db.SupportCountTicketsParams{
			CompanyID:  companyID,
			Status:     f.Status,
			DriverID:   pgconv.UUIDPtr(f.DriverID),
			Search:     f.Search,
			FromTs:     pgconv.TimePtr(f.From),
			ToTs:       pgconv.TimePtr(f.To),
			SelfUserID: pgconv.UUIDPtr(f.SelfUserID),
		})
		return err
	})
	return rows, total, err
}

// GetTicket implements Repo.
func (r *PgRepo) GetTicket(ctx context.Context, id uuid.UUID) (db.SupportGetTicketRow, error) {
	var out db.SupportGetTicketRow
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.SupportGetTicket(ctx, db.SupportGetTicketParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		return err
	})
	return out, err
}

// CreateTicket implements Repo.
func (r *PgRepo) CreateTicket(ctx context.Context, arg db.CreateSupportTicketParams,
	mk func(db.SupportTicket) []audit.Entry) (db.SupportGetTicketRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.SupportGetTicketRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		ticket, err := q.CreateSupportTicket(ctx, arg)
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(ticket)...); err != nil {
			return err
		}
		out, err = q.SupportGetTicket(ctx, db.SupportGetTicketParams{CompanyID: companyID, ID: ticket.ID})
		return err
	})
	return out, err
}

// SetTicketStatus implements Repo.
func (r *PgRepo) SetTicketStatus(ctx context.Context, id uuid.UUID, status string,
	mk func(before string, after db.SupportTicket) []audit.Entry) (db.SupportGetTicketRow, error) {
	companyID := tenant.CompanyID(ctx)

	var out db.SupportGetTicketRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		before, err := q.SupportGetTicket(ctx, db.SupportGetTicketParams{CompanyID: companyID, ID: id})
		if err != nil {
			return err
		}
		after, err := q.SetSupportTicketStatus(ctx, db.SetSupportTicketStatusParams{
			CompanyID: companyID, ID: id, Status: status,
		})
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(before.Status, after)...); err != nil {
			return err
		}
		out, err = q.SupportGetTicket(ctx, db.SupportGetTicketParams{CompanyID: companyID, ID: id})
		return err
	})
	return out, err
}

// ListMessages implements Repo.
func (r *PgRepo) ListMessages(ctx context.Context, f MessageFilter) ([]db.SupportListTicketMessagesRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.SupportListTicketMessagesRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.SupportListTicketMessages(ctx, db.SupportListTicketMessagesParams{
			CompanyID: companyID, TicketID: f.TicketID, Limit: f.Limit, Offset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.SupportCountTicketMessages(ctx, db.SupportCountTicketMessagesParams{
			CompanyID: companyID, TicketID: f.TicketID,
		})
		return err
	})
	return rows, total, err
}

// CreateMessage implements Repo.
func (r *PgRepo) CreateMessage(ctx context.Context, arg db.CreateTicketMessageParams,
	mk func(db.TicketMessage) []audit.Entry) (db.SupportGetTicketMessageRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.SupportGetTicketMessageRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		msg, err := q.CreateTicketMessage(ctx, arg)
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(msg)...); err != nil {
			return err
		}
		out, err = q.SupportGetTicketMessage(ctx, db.SupportGetTicketMessageParams{
			CompanyID: companyID, ID: msg.ID,
		})
		return err
	})
	return out, err
}

// ListFeedback implements Repo.
func (r *PgRepo) ListFeedback(ctx context.Context, f FeedbackFilter) ([]db.SupportListFeedbackRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.SupportListFeedbackRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.SupportListFeedback(ctx, db.SupportListFeedbackParams{
			CompanyID: companyID,
			DriverID:  pgconv.UUIDPtr(f.DriverID),
			MinRating: f.MinRating,
			FromTs:    pgconv.TimePtr(f.From),
			ToTs:      pgconv.TimePtr(f.To),
			SortBy:    f.Sort,
			SortDir:   f.Order,
			RowLimit:  f.Limit,
			RowOffset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.SupportCountFeedback(ctx, db.SupportCountFeedbackParams{
			CompanyID: companyID,
			DriverID:  pgconv.UUIDPtr(f.DriverID),
			MinRating: f.MinRating,
			FromTs:    pgconv.TimePtr(f.From),
			ToTs:      pgconv.TimePtr(f.To),
		})
		return err
	})
	return rows, total, err
}

// CreateFeedback implements Repo. Feedback carries no reply (Q80), so the row
// is returned in list shape straight away.
func (r *PgRepo) CreateFeedback(ctx context.Context, arg db.CreateFeedbackParams,
	mk func(db.Feedback) []audit.Entry) (db.SupportListFeedbackRow, error) {
	companyID := tenant.CompanyID(ctx)
	arg.CompanyID = companyID

	var out db.SupportListFeedbackRow
	err := r.write(ctx, func(q *db.Queries, tx pgx.Tx) error {
		fb, err := q.CreateFeedback(ctx, arg)
		if err != nil {
			return err
		}
		if err := r.recorder.RecordTx(ctx, tx, mk(fb)...); err != nil {
			return err
		}
		out = db.SupportListFeedbackRow{
			ID: fb.ID, CompanyID: fb.CompanyID, DriverID: fb.DriverID,
			AppRating: fb.AppRating, Text: fb.Text, SubmittedAt: fb.SubmittedAt,
			CreatedAt: fb.CreatedAt, UpdatedAt: fb.UpdatedAt,
		}
		return nil
	})
	return out, err
}

// DriverIDForUser implements Repo. A user without a driver row yields uuid.Nil
// and no error: office staff may file tickets too.
func (r *PgRepo) DriverIDForUser(ctx context.Context, userID uuid.UUID) (uuid.UUID, error) {
	var id uuid.UUID
	err := r.read(ctx, func(q *db.Queries) error {
		got, err := q.SupportGetDriverByUserID(ctx, db.SupportGetDriverByUserIDParams{
			CompanyID: tenant.CompanyID(ctx), UserID: userID,
		})
		if err != nil {
			if db.IsNoRows(err) {
				return nil
			}
			return err
		}
		id = got
		return nil
	})
	return id, err
}
