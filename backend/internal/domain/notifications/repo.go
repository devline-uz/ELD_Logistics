package notifications

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// ListFilter is the resolved GET /notifications query.
type ListFilter struct {
	UserID uuid.UUID
	// Unread is nil for "everything", true for unread only, false for read only.
	Unread    *bool
	AlertType *string
	Limit     int32
	Offset    int32
}

// PushTokenInput is one device registration.
type PushTokenInput struct {
	UserID     uuid.UUID
	DeviceID   string
	Platform   string
	Token      string
	AppVersion *string
}

// Repo is everything the notification service needs from storage. It also
// satisfies notify.Store, so the dispatcher shares this implementation.
type Repo interface {
	List(ctx context.Context, f ListFilter) ([]db.Notification, int64, int64, error)
	MarkRead(ctx context.Context, userID, id uuid.UUID) (int64, error)
	MarkAllRead(ctx context.Context, userID uuid.UUID) (int64, error)
	Unread(ctx context.Context, userID uuid.UUID) (int64, error)
	RegisterPushToken(ctx context.Context, in PushTokenInput) (db.DevicePushToken, error)

	notify.Store
}

// PgRepo is the pgx/sqlc implementation. Every statement runs through the
// tenant aware pool, which issues `SET LOCAL app.company_id` so RLS backs the
// explicit company_id predicates.
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

func (r *PgRepo) write(ctx context.Context, companyID uuid.UUID, fn func(q *db.Queries, tx pgx.Tx) error) error {
	return r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		return fn(db.New(tx), tx)
	})
}

// List implements Repo: one page plus the filtered total and the unread total.
func (r *PgRepo) List(ctx context.Context, f ListFilter) ([]db.Notification, int64, int64, error) {
	companyID := tenant.CompanyID(ctx)
	var rows []db.Notification
	var total, unread int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		rows, err = q.ListNotifications(ctx, db.ListNotificationsParams{
			CompanyID: companyID, UserID: f.UserID,
			Unread: f.Unread, AlertType: f.AlertType,
			RowLimit: f.Limit, RowOffset: f.Offset,
		})
		if err != nil {
			return err
		}
		total, err = q.CountNotifications(ctx, db.CountNotificationsParams{
			CompanyID: companyID, UserID: f.UserID,
			Unread: f.Unread, AlertType: f.AlertType,
		})
		if err != nil {
			return err
		}
		unread, err = q.CountUnreadNotifications(ctx, db.CountUnreadNotificationsParams{
			CompanyID: companyID, UserID: f.UserID,
		})
		return err
	})
	return rows, total, unread, err
}

// MarkRead implements Repo. A notification of another user (or tenant) simply
// updates nothing, which the service reports as 404.
func (r *PgRepo) MarkRead(ctx context.Context, userID, id uuid.UUID) (int64, error) {
	companyID := tenant.CompanyID(ctx)
	var n int64
	err := r.write(ctx, companyID, func(q *db.Queries, _ pgx.Tx) error {
		var err error
		n, err = q.MarkNotificationRead(ctx, db.MarkNotificationReadParams{
			CompanyID: companyID, UserID: userID, ID: id,
		})
		return err
	})
	return n, err
}

// MarkAllRead implements Repo.
func (r *PgRepo) MarkAllRead(ctx context.Context, userID uuid.UUID) (int64, error) {
	companyID := tenant.CompanyID(ctx)
	var n int64
	err := r.write(ctx, companyID, func(q *db.Queries, _ pgx.Tx) error {
		var err error
		n, err = q.MarkAllNotificationsRead(ctx, db.MarkAllNotificationsReadParams{
			CompanyID: companyID, UserID: userID,
		})
		return err
	})
	return n, err
}

// Unread implements Repo.
func (r *PgRepo) Unread(ctx context.Context, userID uuid.UUID) (int64, error) {
	companyID := tenant.CompanyID(ctx)
	var n int64
	err := r.read(ctx, func(q *db.Queries) error {
		var err error
		n, err = q.CountUnreadNotifications(ctx, db.CountUnreadNotificationsParams{
			CompanyID: companyID, UserID: userID,
		})
		return err
	})
	return n, err
}

// RegisterPushToken implements Repo. Registering a token that already belongs
// to another user retires the old row: a handed over phone must not keep
// receiving the previous owner's alerts.
func (r *PgRepo) RegisterPushToken(ctx context.Context, in PushTokenInput) (db.DevicePushToken, error) {
	companyID := tenant.CompanyID(ctx)
	var out db.DevicePushToken
	err := r.write(ctx, companyID, func(q *db.Queries, tx pgx.Tx) error {
		if err := q.RevokeDevicePushTokenElsewhere(ctx, db.RevokeDevicePushTokenElsewhereParams{
			Token: in.Token, UserID: in.UserID, DeviceID: in.DeviceID,
		}); err != nil {
			return err
		}
		row, err := q.UpsertDevicePushToken(ctx, db.UpsertDevicePushTokenParams{
			CompanyID: companyID, UserID: in.UserID, DeviceID: in.DeviceID,
			Platform: in.Platform, Token: in.Token, AppVersion: in.AppVersion,
		})
		if err != nil {
			return err
		}
		out = row
		// The token value is a credential and is never audited.
		return r.audit.RecordTx(ctx, tx, audit.Entry{
			TableName: "device_push_tokens", RecordID: row.ID, Field: "platform",
			NewValue: row.Platform, Action: audit.ActionCreate,
			EditedBy: in.UserID, CompanyID: companyID,
		})
	})
	return out, err
}

// ------------------------------------------------------------- notify.Store

// Setting implements notify.Store.
func (r *PgRepo) Setting(ctx context.Context, companyID uuid.UUID, alertType string) (notify.Setting, error) {
	var out notify.Setting
	err := r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error {
		row, err := db.New(tx).GetNotificationSetting(ctx, db.GetNotificationSettingParams{
			CompanyID: companyID, AlertType: alertType,
		})
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		if err != nil {
			return err
		}
		out = notify.Setting{
			Channels: row.Channels, RecipientRoles: row.RecipientRoles,
			Enabled: row.Enabled, Found: true,
		}
		return nil
	})
	return out, err
}

// Recipients implements notify.Store.
func (r *PgRepo) Recipients(ctx context.Context, companyID uuid.UUID, userIDs []uuid.UUID) ([]notify.Recipient, error) {
	if len(userIDs) == 0 {
		return nil, nil
	}
	var out []notify.Recipient
	err := r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		rows, err := q.NotifyRecipientsByUsers(ctx, db.NotifyRecipientsByUsersParams{
			CompanyID: pgconv.UUID(companyID), Column2: userIDs,
		})
		if err != nil {
			return err
		}
		out, err = r.withDevices(ctx, q, companyID, toRecipients(rows))
		return err
	})
	return out, err
}

// RecipientsByRoles implements notify.Store.
func (r *PgRepo) RecipientsByRoles(ctx context.Context, companyID uuid.UUID, roleIDs []uuid.UUID) ([]notify.Recipient, error) {
	if len(roleIDs) == 0 {
		return nil, nil
	}
	var out []notify.Recipient
	err := r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error {
		q := db.New(tx)
		rows, err := q.NotifyRecipientsByRoles(ctx, db.NotifyRecipientsByRolesParams{
			CompanyID: pgconv.UUID(companyID), Column2: roleIDs,
		})
		if err != nil {
			return err
		}
		converted := make([]notify.Recipient, 0, len(rows))
		for _, row := range rows {
			converted = append(converted, notify.Recipient{
				UserID: row.ID, Email: pgconv.Deref(row.Email),
				Phone: pgconv.Deref(row.Phone), TelegramChatID: pgconv.Deref(row.TelegramChatID),
			})
		}
		out, err = r.withDevices(ctx, q, companyID, converted)
		return err
	})
	return out, err
}

// Insert implements notify.Store.
func (r *PgRepo) Insert(ctx context.Context, rec notify.Record) (uuid.UUID, error) {
	var id uuid.UUID
	err := r.pool.WithTx(ctx, rec.CompanyID, func(tx pgx.Tx) error {
		sentAt := rec.SentAt
		if sentAt.IsZero() {
			sentAt = time.Now().UTC()
		}
		row, err := db.New(tx).CreateNotification(ctx, db.CreateNotificationParams{
			CompanyID:  rec.CompanyID,
			UserID:     rec.UserID,
			AlertType:  rec.AlertType,
			Title:      rec.Title,
			Body:       pgconv.NilIfEmpty(rec.Body),
			EntityType: pgconv.NilIfEmpty(rec.EntityType),
			EntityID:   pgconv.UUIDPtr(rec.EntityID),
			Channels:   rec.Channels,
			SentAt:     pgconv.Time(sentAt),
		})
		if err != nil {
			return err
		}
		id = row.ID
		return nil
	})
	return id, err
}

func toRecipients(rows []db.NotifyRecipientsByUsersRow) []notify.Recipient {
	out := make([]notify.Recipient, 0, len(rows))
	for _, row := range rows {
		out = append(out, notify.Recipient{
			UserID: row.ID, Email: pgconv.Deref(row.Email),
			Phone: pgconv.Deref(row.Phone), TelegramChatID: pgconv.Deref(row.TelegramChatID),
		})
	}
	return out
}

// withDevices attaches the registered push endpoints to each recipient.
func (r *PgRepo) withDevices(ctx context.Context, q *db.Queries, companyID uuid.UUID, in []notify.Recipient) ([]notify.Recipient, error) {
	if len(in) == 0 {
		return in, nil
	}
	ids := make([]uuid.UUID, 0, len(in))
	for _, rec := range in {
		ids = append(ids, rec.UserID)
	}
	rows, err := q.ListPushTokensForUsers(ctx, db.ListPushTokensForUsersParams{
		CompanyID: companyID, Column2: ids,
	})
	if err != nil {
		return nil, err
	}
	byUser := make(map[uuid.UUID][]notify.Device, len(in))
	for _, row := range rows {
		byUser[row.UserID] = append(byUser[row.UserID], notify.Device{
			Platform: row.Platform, Token: row.Token, DeviceID: row.DeviceID,
		})
	}
	for i := range in {
		in[i].Devices = byUser[in[i].UserID]
	}
	return in, nil
}
