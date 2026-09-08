package chat

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Driver is the thread owner as the chat needs it.
type Driver struct {
	ID        uuid.UUID
	UserID    uuid.UUID
	BranchID  *uuid.UUID
	Status    string
	FirstName string
	LastName  string
}

// ThreadFilter is the resolved GET /chat/threads query.
type ThreadFilter struct {
	BranchID *uuid.UUID
	// DriverID pins the list to one thread; a self scoped principal always
	// resolves to exactly its own.
	DriverID *uuid.UUID
	// IncludeEmpty keeps drivers that never exchanged a message; the admin
	// side needs them so a first message can be started.
	IncludeEmpty bool
	Limit        int32
	Offset       int32
}

// HistoryFilter is the resolved cursor page of one thread.
type HistoryFilter struct {
	DriverID uuid.UUID
	// Before is the exclusive upper bound of sent_at; nil starts at the newest.
	Before *time.Time
	Limit  int32
}

// NewMessage is one message about to be stored.
type NewMessage struct {
	DriverID uuid.UUID
	SenderID uuid.UUID
	Kind     string
	Text     *string
	FileKey  *string
	Lat      *float64
	Lng      *float64
}

// Repo is everything the chat service needs from storage.
type Repo interface {
	Driver(ctx context.Context, id uuid.UUID) (Driver, error)
	DriverByUser(ctx context.Context, userID uuid.UUID) (Driver, error)
	DriverOfMessage(ctx context.Context, messageID uuid.UUID) (Driver, error)
	CurrentDutyStatus(ctx context.Context, driverID uuid.UUID) (string, error)
	Threads(ctx context.Context, f ThreadFilter) ([]db.ListChatThreadsRow, []db.ListChatLastMessagesRow, int64, error)
	History(ctx context.Context, f HistoryFilter) ([]db.ChatMessage, error)
	Create(ctx context.Context, in NewMessage) (db.ChatMessage, error)
	MarkRead(ctx context.Context, id, readerID uuid.UUID) (db.ChatMessage, int64, error)
	Unread(ctx context.Context, driverID, viewerID uuid.UUID) (int64, error)
}

// PgRepo is the pgx/sqlc implementation of Repo.
type PgRepo struct {
	pool  *db.Pool
	audit audit.Recorder
}

// NewRepo builds the storage adapter.
func NewRepo(pool *db.Pool, rec audit.Recorder) *PgRepo {
	if rec == nil {
		rec = audit.NopRecorder{}
	}
	return &PgRepo{pool: pool, audit: rec}
}

func (r *PgRepo) read(ctx context.Context, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, tenant.CompanyID(ctx), func(tx pgx.Tx) error {
		return fn(db.New(tx))
	})
}

// Driver implements Repo. A driver of another tenant is simply not found.
func (r *PgRepo) Driver(ctx context.Context, id uuid.UUID) (Driver, error) {
	var out Driver
	err := r.read(ctx, func(q *db.Queries) error {
		row, err := q.ChatGetDriver(ctx, db.ChatGetDriverParams{
			CompanyID: tenant.CompanyID(ctx), ID: id,
		})
		if err != nil {
			return err
		}
		out = Driver{
			ID: row.ID, UserID: row.UserID, BranchID: pgconv.ToUUIDPtr(row.BranchID),
			Status: row.Status, FirstName: row.FirstName, LastName: row.LastName,
		}
		return nil
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return Driver{}, apierr.NotFound("driver")
	}
	return out, err
}

// DriverByUser implements Repo.
func (r *PgRepo) DriverByUser(ctx context.Context, userID uuid.UUID) (Driver, error) {
	var out Driver
	err := r.read(ctx, func(q *db.Queries) error {
		row, err := q.ChatGetDriverByUser(ctx, db.ChatGetDriverByUserParams{
			CompanyID: tenant.CompanyID(ctx), UserID: userID,
		})
		if err != nil {
			return err
		}
		out = Driver{
			ID: row.ID, UserID: row.UserID, BranchID: pgconv.ToUUIDPtr(row.BranchID),
			Status: row.Status, FirstName: row.FirstName, LastName: row.LastName,
		}
		return nil
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return Driver{}, apierr.NotFound("driver")
	}
	return out, err
}

// DriverOfMessage implements Repo: the thread owner a message belongs to. It
// resolves the scope of a message id before anything is written, so a caller
// that may not touch the thread is rejected instead of mutating it first. A
// message of another tenant is simply not found.
func (r *PgRepo) DriverOfMessage(ctx context.Context, messageID uuid.UUID) (Driver, error) {
	companyID := tenant.CompanyID(ctx)
	var out Driver
	err := r.read(ctx, func(q *db.Queries) error {
		msg, err := q.GetChatMessage(ctx, db.GetChatMessageParams{CompanyID: companyID, ID: messageID})
		if err != nil {
			return err
		}
		row, err := q.ChatGetDriver(ctx, db.ChatGetDriverParams{CompanyID: companyID, ID: msg.DriverID})
		if err != nil {
			return err
		}
		out = Driver{
			ID: row.ID, UserID: row.UserID, BranchID: pgconv.ToUUIDPtr(row.BranchID),
			Status: row.Status, FirstName: row.FirstName, LastName: row.LastName,
		}
		return nil
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return Driver{}, apierr.NotFound("message")
	}
	return out, err
}

// CurrentDutyStatus implements Repo. An empty string means the driver has no
// duty status event yet, which is never treated as driving.
func (r *PgRepo) CurrentDutyStatus(ctx context.Context, driverID uuid.UUID) (string, error) {
	var out string
	err := r.read(ctx, func(q *db.Queries) error {
		status, err := q.ChatDriverCurrentDutyStatus(ctx, db.ChatDriverCurrentDutyStatusParams{
			CompanyID: tenant.CompanyID(ctx), DriverID: pgconv.UUID(driverID),
		})
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		if err != nil {
			return err
		}
		out = pgconv.Deref(status)
		return nil
	})
	return out, err
}

// Threads implements Repo: the page of drivers plus the last message of each.
func (r *PgRepo) Threads(ctx context.Context, f ThreadFilter) ([]db.ListChatThreadsRow, []db.ListChatLastMessagesRow, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.ListChatThreadsRow
	var last []db.ListChatLastMessagesRow
	var total int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListChatThreads(ctx, db.ListChatThreadsParams{
			CompanyID: companyID, BranchID: pgconv.UUIDPtr(f.BranchID),
			DriverID:     pgconv.UUIDPtr(f.DriverID),
			IncludeEmpty: f.IncludeEmpty, RowLimit: f.Limit, RowOffset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountChatThreads(ctx, db.CountChatThreadsParams{
			CompanyID: companyID, BranchID: pgconv.UUIDPtr(f.BranchID),
			DriverID:     pgconv.UUIDPtr(f.DriverID),
			IncludeEmpty: f.IncludeEmpty,
		})
		if err != nil {
			return err
		}
		if len(rows) == 0 {
			return nil
		}
		ids := make([]uuid.UUID, 0, len(rows))
		for _, row := range rows {
			ids = append(ids, row.DriverID)
		}
		last, err = q.ListChatLastMessages(ctx, db.ListChatLastMessagesParams{
			CompanyID: companyID, Column2: ids,
		})
		return err
	})
	return rows, last, total, err
}

// History implements Repo.
func (r *PgRepo) History(ctx context.Context, f HistoryFilter) ([]db.ChatMessage, error) {
	var rows []db.ChatMessage
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListChatMessages(ctx, db.ListChatMessagesParams{
			CompanyID: tenant.CompanyID(ctx), DriverID: f.DriverID,
			Before: pgconv.TimePtr(f.Before), RowLimit: f.Limit,
		})
		return err
	})
	return rows, err
}

// Create implements Repo. Q: every write is audited.
func (r *PgRepo) Create(ctx context.Context, in NewMessage) (db.ChatMessage, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.ChatMessage
	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		row, err := db.New(tx).CreateChatMessage(ctx, db.CreateChatMessageParams{
			CompanyID: companyID, DriverID: in.DriverID, SenderID: in.SenderID,
			Kind: in.Kind, Text: in.Text, FileKey: in.FileKey,
			Lat: in.Lat, Lng: in.Lng,
		})
		if err != nil {
			return err
		}
		out = row
		// The message body is user content, not a change to a business record:
		// only the fact and the kind are audited, never the text.
		return r.audit.RecordTx(ctx, tx, audit.Entry{
			TableName: "chat_messages", RecordID: row.ID, Field: "kind",
			NewValue: row.Kind, Action: audit.ActionCreate,
			EditedBy: in.SenderID, CompanyID: companyID,
		})
	})
	return out, err
}

// MarkRead implements Repo. The reader may only acknowledge messages it did
// not write itself.
func (r *PgRepo) MarkRead(ctx context.Context, id, readerID uuid.UUID) (db.ChatMessage, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var msg db.ChatMessage
	var n int64
	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		// The read first proves the message exists inside this tenant, so a
		// foreign id maps to 404 instead of a silent no-op.
		if _, err := q.GetChatMessage(ctx, db.GetChatMessageParams{CompanyID: companyID, ID: id}); err != nil {
			return err
		}
		var err error
		n, err = q.MarkChatMessageRead(ctx, db.MarkChatMessageReadParams{
			CompanyID: companyID, ID: id, SenderID: readerID,
		})
		if err != nil {
			return err
		}
		msg, err = q.GetChatMessage(ctx, db.GetChatMessageParams{CompanyID: companyID, ID: id})
		return err
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return db.ChatMessage{}, 0, apierr.NotFound("message")
	}
	return msg, n, err
}

// Unread implements Repo: how many messages of this thread the viewer has not
// read yet.
func (r *PgRepo) Unread(ctx context.Context, driverID, viewerID uuid.UUID) (int64, error) {
	var n int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		n, err = q.CountUnreadChatForDriver(ctx, db.CountUnreadChatForDriverParams{
			CompanyID: tenant.CompanyID(ctx), DriverID: driverID, SenderID: viewerID,
		})
		return err
	})
	return n, err
}
