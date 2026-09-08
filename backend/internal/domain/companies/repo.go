package companies

import (
	"context"
	"strings"
	"time"

	"github.com/devline/onebook-eld/internal/pgconv"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/company"
)

// The platform window. `app.platform` is set with SET LOCAL inside the
// transactions of this module only; migration 00014 defines the matching RLS
// policy on `companies`, which is otherwise visible to its own tenant alone.
const (
	setPlatformSQL = `SELECT set_config('app.platform', 'on', true)`
	setCompanySQL  = `SELECT set_config('app.company_id', $1, true)`
)

// ListFilter is the parsed GET /companies query.
type ListFilter struct {
	Search  *string
	Status  *string
	Region  *string
	SortBy  string
	SortDir string
	Limit   int32
	Offset  int32
}

// AdminUser is the Administrator account created together with a tenant.
type AdminUser struct {
	FirstName string
	LastName  string
	Email     string
	Phone     string
	Username  string
}

// ProvisionInput is everything one POST /companies transaction writes.
type ProvisionInput struct {
	Company            db.CreateCompanyParams
	Settings           []byte
	SubscriptionStatus string
	SubscriptionEndAt  *time.Time
	HosPolicy          []byte
	Admin              AdminUser
	InvitationHash     string
	InvitationChannel  string
	InvitationExpires  time.Time
	AlertDefaults      []company.AlertDefault
	CreatedBy          uuid.UUID
	IP                 string
}

// ProvisionResult reports what the provisioning transaction produced.
type ProvisionResult struct {
	Company      db.Company
	AdminUserID  uuid.UUID
	AdminRoleID  uuid.UUID
	RolesCreated int
}

// UpdateInput patches one tenant.
type UpdateInput struct {
	ID     uuid.UUID
	Params db.UpdateCompanyParams
	Audit  []audit.Entry
}

// SubscriptionInput moves one tenant between billing states.
type SubscriptionInput struct {
	ID     uuid.UUID
	Params db.UpdateCompanySubscriptionParams
	Audit  []audit.Entry
}

// Repo is everything the platform company service needs from storage.
type Repo interface {
	List(ctx context.Context, f ListFilter) ([]db.Company, int64, error)
	Get(ctx context.Context, id uuid.UUID) (db.Company, error)
	Provision(ctx context.Context, in ProvisionInput) (ProvisionResult, error)
	Update(ctx context.Context, in UpdateInput) (db.Company, error)
	UpdateSubscription(ctx context.Context, in SubscriptionInput) (db.Company, error)
}

// PgRepo is the pgx/sqlc implementation of Repo.
type PgRepo struct {
	pool *db.Pool
	rec  audit.Recorder
}

// NewRepo builds the storage adapter.
func NewRepo(pool *db.Pool, rec audit.Recorder) *PgRepo {
	if rec == nil {
		rec = audit.NopRecorder{}
	}
	return &PgRepo{pool: pool, rec: rec}
}

// platformRead opens a read only transaction that may see every tenant row.
func (r *PgRepo) platformRead(ctx context.Context, fn func(q *db.Queries) error) error {
	return r.pool.WithConn(ctx, uuid.Nil, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, setPlatformSQL); err != nil {
			return err
		}
		return fn(db.New(tx))
	})
}

// platformWrite opens a read/write transaction in the platform window. When
// companyID is set the tenant scope is opened as well, so the rows written
// into the tenant tables (and audit_log) pass their own RLS policy.
func (r *PgRepo) platformWrite(ctx context.Context, companyID uuid.UUID, fn func(tx pgx.Tx, q *db.Queries) error) error {
	return r.pool.WithTx(ctx, uuid.Nil, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, setPlatformSQL); err != nil {
			return err
		}
		if companyID != uuid.Nil {
			if _, err := tx.Exec(ctx, setCompanySQL, companyID.String()); err != nil {
				return err
			}
		}
		return fn(tx, db.New(tx))
	})
}

// List implements Repo.
func (r *PgRepo) List(ctx context.Context, f ListFilter) ([]db.Company, int64, error) {
	var (
		rows  []db.Company
		total int64
	)
	err := r.platformRead(ctx, func(q *db.Queries) error {
		var err error
		if total, err = q.CountCompanies(ctx, db.CountCompaniesParams{
			Search: f.Search, Status: f.Status, Region: f.Region,
		}); err != nil {
			return err
		}
		rows, err = q.ListCompanies(ctx, db.ListCompaniesParams{
			Search: f.Search, Status: f.Status, Region: f.Region,
			SortBy: f.SortBy, SortDir: f.SortDir,
			RowLimit: f.Limit, RowOffset: f.Offset,
		})
		return err
	})
	return rows, total, db.MapError(err, "company")
}

// Get implements Repo.
func (r *PgRepo) Get(ctx context.Context, id uuid.UUID) (db.Company, error) {
	var out db.Company
	err := r.platformRead(ctx, func(q *db.Queries) error {
		var err error
		out, err = q.GetCompany(ctx, id)
		return err
	})
	return out, db.MapError(err, "company")
}

// Update implements Repo.
func (r *PgRepo) Update(ctx context.Context, in UpdateInput) (db.Company, error) {
	var out db.Company
	err := r.platformWrite(ctx, in.ID, func(tx pgx.Tx, q *db.Queries) error {
		var err error
		if out, err = q.UpdateCompany(ctx, in.Params); err != nil {
			return err
		}
		return r.recordAll(ctx, tx, in.ID, out.ID, in.Audit)
	})
	return out, db.MapError(err, "company")
}

// UpdateSubscription implements Repo.
func (r *PgRepo) UpdateSubscription(ctx context.Context, in SubscriptionInput) (db.Company, error) {
	var out db.Company
	err := r.platformWrite(ctx, in.ID, func(tx pgx.Tx, q *db.Queries) error {
		var err error
		if out, err = q.UpdateCompanySubscription(ctx, in.Params); err != nil {
			return err
		}
		return r.recordAll(ctx, tx, in.ID, out.ID, in.Audit)
	})
	return out, db.MapError(err, "company")
}

// provisionCompanyRow creates the company row and applies the optional
// settings/subscription overrides supplied at signup.
func provisionCompanyRow(ctx context.Context, q *db.Queries, in ProvisionInput) (db.Company, error) {
	created, err := q.CreateCompany(ctx, in.Company)
	if err != nil {
		return db.Company{}, err
	}
	if len(in.Settings) > 0 {
		if created, err = q.UpdateCompanySettings(ctx, db.UpdateCompanySettingsParams{
			ID: created.ID, Column2: in.Settings,
		}); err != nil {
			return db.Company{}, err
		}
	}
	if in.SubscriptionStatus != "" || in.SubscriptionEndAt != nil {
		if created, err = q.UpdateCompanySubscription(ctx, db.UpdateCompanySubscriptionParams{
			ID:                 created.ID,
			SubscriptionStatus: optStr(in.SubscriptionStatus),
			SubscriptionEndAt:  pgconv.TimePtr(in.SubscriptionEndAt),
		}); err != nil {
			return db.Company{}, err
		}
	}
	return created, nil
}

// provisionRoles copies the system role templates onto the new tenant and
// returns a lower-cased name lookup for the notification/admin steps below.
func provisionRoles(ctx context.Context, q *db.Queries, companyID uuid.UUID) (map[string]uuid.UUID, int, error) {
	roles, err := q.ProvisionCompanyRoles(ctx, pgconv.UUID(companyID))
	if err != nil {
		return nil, 0, err
	}
	if err := q.ProvisionCompanyRolePermissions(ctx, pgconv.UUID(companyID)); err != nil {
		return nil, 0, err
	}
	roleByName := make(map[string]uuid.UUID, len(roles))
	for _, role := range roles {
		roleByName[strings.ToLower(role.Name)] = role.ID
	}
	return roleByName, len(roles), nil
}

// provisionNotificationDefaults seeds the A§19 alert defaults, resolving each
// recipient role name against the tenant's freshly copied roles.
func provisionNotificationDefaults(
	ctx context.Context, q *db.Queries, companyID uuid.UUID, defaults []company.AlertDefault, roleByName map[string]uuid.UUID,
) error {
	for _, d := range defaults {
		recipients := make([]uuid.UUID, 0, len(d.RoleNames))
		for _, name := range d.RoleNames {
			if id, ok := roleByName[strings.ToLower(name)]; ok {
				recipients = append(recipients, id)
			}
		}
		if err := q.InsertNotificationSettingDefault(ctx, db.InsertNotificationSettingDefaultParams{
			CompanyID:      companyID,
			AlertType:      d.AlertType,
			Channels:       d.Channels,
			RecipientRoles: recipients,
		}); err != nil {
			return err
		}
	}
	return nil
}

// provisionAdmin creates the invited Administrator account and its
// invitation, returning the account and the role id it was granted.
func provisionAdmin(
	ctx context.Context, q *db.Queries, companyID uuid.UUID, in ProvisionInput, roleByName map[string]uuid.UUID,
) (db.User, uuid.UUID, error) {
	adminRoleID, ok := roleByName[strings.ToLower(roleAdministrator)]
	if !ok {
		return db.User{}, uuid.Nil, apierr.Internal(nil, "the Administrator role template is missing")
	}

	user, err := q.CreateUser(ctx, db.CreateUserParams{
		CompanyID: pgconv.UUID(companyID),
		FirstName: in.Admin.FirstName,
		LastName:  in.Admin.LastName,
		Email:     optStr(in.Admin.Email),
		Phone:     optStr(in.Admin.Phone),
		Username:  in.Admin.Username,
		RoleID:    adminRoleID,
		Status:    statusInvited,
		InvitedAt: pgtype.Timestamptz{Time: time.Now().UTC(), Valid: true},
	})
	if err != nil {
		return db.User{}, uuid.Nil, err
	}

	if _, err := q.CreateInvitation(ctx, db.CreateInvitationParams{
		CompanyID: pgconv.UUID(companyID),
		UserID:    user.ID,
		TokenHash: in.InvitationHash,
		Channel:   in.InvitationChannel,
		Purpose:   purposeInvitation,
		ExpiresAt: in.InvitationExpires,
	}); err != nil {
		return db.User{}, uuid.Nil, err
	}
	return user, adminRoleID, nil
}

// provisionAuditEntries builds the audit trail of one Provision call.
func provisionAuditEntries(created db.Company, user db.User, in ProvisionInput) []audit.Entry {
	return []audit.Entry{
		{
			TableName: tableCompanies, RecordID: created.ID, Field: "name",
			NewValue: created.Name, Action: audit.ActionCreate,
			EditedBy: in.CreatedBy, IP: in.IP, CompanyID: created.ID,
		},
		{
			TableName: tableCompanies, RecordID: created.ID, Field: "subscription_status",
			NewValue: created.SubscriptionStatus, Action: audit.ActionCreate,
			EditedBy: in.CreatedBy, IP: in.IP, CompanyID: created.ID,
		},
		{
			TableName: tableUsers, RecordID: user.ID, Field: "status",
			NewValue: statusInvited, Action: audit.ActionCreate,
			EditedBy: in.CreatedBy, IP: in.IP, CompanyID: created.ID,
			Reason: "administrator invitation",
		},
	}
}

// Provision implements Repo: one transaction creates the company, its default
// HOS policy version, its copy of the system roles, the notification defaults,
// the Administrator account and the invitation, plus the audit trail.
func (r *PgRepo) Provision(ctx context.Context, in ProvisionInput) (ProvisionResult, error) {
	var out ProvisionResult

	err := r.pool.WithTx(ctx, uuid.Nil, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, setPlatformSQL); err != nil {
			return err
		}
		q := db.New(tx)

		created, err := provisionCompanyRow(ctx, q, in)
		if err != nil {
			return err
		}
		// Everything below belongs to the new tenant: open its scope so the
		// tenant RLS policies accept the rows.
		if _, err := tx.Exec(ctx, setCompanySQL, created.ID.String()); err != nil {
			return err
		}

		if _, err := q.CreateHosPolicyVersion(ctx, db.CreateHosPolicyVersionParams{
			CompanyID:     created.ID,
			EffectiveFrom: pgtype.Timestamptz{Time: created.CreatedAt.UTC(), Valid: true},
			Policy:        in.HosPolicy,
			CreatedBy:     pgconv.UUID(in.CreatedBy),
		}); err != nil {
			return err
		}

		roleByName, rolesCreated, err := provisionRoles(ctx, q, created.ID)
		if err != nil {
			return err
		}
		if err := provisionNotificationDefaults(ctx, q, created.ID, in.AlertDefaults, roleByName); err != nil {
			return err
		}

		user, adminRoleID, err := provisionAdmin(ctx, q, created.ID, in, roleByName)
		if err != nil {
			return err
		}

		if err := r.rec.RecordTx(ctx, tx, provisionAuditEntries(created, user, in)...); err != nil {
			return err
		}

		out = ProvisionResult{
			Company: created, AdminUserID: user.ID,
			AdminRoleID: adminRoleID, RolesCreated: rolesCreated,
		}
		return nil
	})

	return out, db.MapError(err, "company")
}

func (r *PgRepo) recordAll(ctx context.Context, tx pgx.Tx, companyID, recordID uuid.UUID, entries []audit.Entry) error {
	if len(entries) == 0 {
		return nil
	}
	out := make([]audit.Entry, 0, len(entries))
	for _, e := range entries {
		if e.RecordID == uuid.Nil {
			e.RecordID = recordID
		}
		e.CompanyID = companyID
		out = append(out, e)
	}
	return r.rec.RecordTx(ctx, tx, out...)
}

func optStr(v string) *string {
	s := strings.TrimSpace(v)
	if s == "" {
		return nil
	}
	return &s
}
