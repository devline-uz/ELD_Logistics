package notifications

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/jobs"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// AlertRepo backs the cron alerts of internal/jobs. It implements both
// jobs.TenantDirectory (a platform scoped read: the cron tick belongs to no
// tenant) and jobs.AlertSource (per tenant, company_id taken from the context).
type AlertRepo struct {
	pool *db.Pool
}

// NewAlertRepo builds the background job storage adapter.
func NewAlertRepo(pool *db.Pool) *AlertRepo { return &AlertRepo{pool: pool} }

// maxTenantsPerSweep bounds the platform scoped listings.
const maxTenantsPerSweep = 1000

// Tenants implements jobs.TenantDirectory.
func (r *AlertRepo) Tenants(ctx context.Context) ([]jobs.Tenant, error) {
	var out []jobs.Tenant
	err := r.pool.WithAuthTx(ctx, func(tx pgx.Tx) error {
		rows, err := db.New(tx).AlertsActiveCompanies(ctx, maxTenantsPerSweep)
		if err != nil {
			return err
		}
		out = make([]jobs.Tenant, 0, len(rows))
		for _, row := range rows {
			out = append(out, jobs.Tenant{ID: row.ID, Timezone: row.Timezone})
		}
		return nil
	})
	return out, err
}

// ExpiringOn implements jobs.TenantDirectory.
func (r *AlertRepo) ExpiringOn(ctx context.Context, day time.Time) ([]jobs.ExpiringCompany, error) {
	var out []jobs.ExpiringCompany
	err := r.pool.WithAuthTx(ctx, func(tx pgx.Tx) error {
		q := db.New(tx)
		rows, err := q.AlertsCompaniesExpiringOn(ctx, db.AlertsCompaniesExpiringOnParams{
			Column1: pgtype.Date{
				Time:  time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, time.UTC),
				Valid: true,
			},
			Limit: maxTenantsPerSweep,
		})
		if err != nil {
			return err
		}
		out = make([]jobs.ExpiringCompany, 0, len(rows))
		for _, row := range rows {
			admins, err := q.AlertsCompanyAdministrators(ctx, pgconv.UUID(row.ID))
			if err != nil {
				return err
			}
			c := jobs.ExpiringCompany{ID: row.ID, Name: row.Name, AdminUserIDs: admins}
			if row.SubscriptionEndAt.Valid {
				c.EndsAt = row.SubscriptionEndAt.Time.UTC()
			}
			out = append(out, c)
		}
		return nil
	})
	return out, err
}

// UncertifiedLogDrivers implements jobs.AlertSource.
func (r *AlertRepo) UncertifiedLogDrivers(ctx context.Context, before time.Time, limit int32) ([]jobs.UncertifiedDriver, error) {
	companyID := tenant.CompanyID(ctx)
	var out []jobs.UncertifiedDriver
	err := r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error {
		rows, err := db.New(tx).AlertsUncertifiedLogDrivers(ctx, db.AlertsUncertifiedLogDriversParams{
			CompanyID: companyID,
			Column2:   pgtype.Date{Time: dayOf(before), Valid: true},
			Limit:     limit,
		})
		if err != nil {
			return err
		}
		out = make([]jobs.UncertifiedDriver, 0, len(rows))
		for _, row := range rows {
			d := jobs.UncertifiedDriver{DriverID: row.DriverID, UserID: row.UserID, Logs: row.LogCount}
			if row.OldestLogDate.Valid {
				d.Oldest = row.OldestLogDate.Time.UTC()
			}
			out = append(out, d)
		}
		return nil
	})
	return out, err
}

// StaleUnidentifiedCount implements jobs.AlertSource.
func (r *AlertRepo) StaleUnidentifiedCount(ctx context.Context, before time.Time) (int64, error) {
	companyID := tenant.CompanyID(ctx)
	var n int64
	err := r.pool.WithConn(ctx, companyID, func(tx pgx.Tx) error {
		var err error
		n, err = db.New(tx).AlertsStaleUnidentifiedCount(ctx, db.AlertsStaleUnidentifiedCountParams{
			CompanyID: companyID, StartAt: before.UTC(),
		})
		return err
	})
	return n, err
}

// PurgeChat implements jobs.AlertSource (TZ §15.4 — one year retention).
func (r *AlertRepo) PurgeChat(ctx context.Context, before time.Time) (int64, error) {
	companyID := tenant.CompanyID(ctx)
	var n int64
	err := r.pool.WithTx(ctx, companyID, func(tx pgx.Tx) error {
		var err error
		n, err = db.New(tx).DeleteOldChatMessages(ctx, db.DeleteOldChatMessagesParams{
			CompanyID: companyID, SentAt: before.UTC(),
		})
		return err
	})
	return n, err
}

func dayOf(t time.Time) time.Time {
	t = t.UTC()
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
}
