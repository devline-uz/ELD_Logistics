package auditlog

import (
	"context"
	"net/netip"
	"strings"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/auditlog/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Service exposes the audit journal as a read model. It has no mutating method:
// `audit_log` is append-only (TZ A§17).
type Service struct {
	repo Repo
}

// NewService builds the audit log service.
func NewService(repo Repo) *Service { return &Service{repo: repo} }

// requireCompanyScope refuses the journal to a caller that is not company
// scoped.
//
// The journal cannot be partitioned by branch: an entry points at
// `table_name` + `record_id` across every audited table, and most of those
// tables (daily_logs, dvir_reports, companies, hos_policy_versions) carry no
// branch at all. Filtering on the actor instead (`edited_by` -> users.branch_id)
// would be semantically wrong in both directions — it would hide a head office
// edit of a row that does belong to the branch, and it would show an edit that
// a branch user made to a company wide setting. Serving the unfiltered journal
// to a branch role is the scope violation the audit found, so the endpoint
// requires `company` scope until audit_log carries a branch of its own.
func requireCompanyScope(ctx context.Context) error {
	f, ok := mw.ScopeFrom(ctx)
	if !ok {
		return nil
	}
	if f.Scope != tenant.ScopeBranch && f.Scope != tenant.ScopeSelf {
		return nil
	}
	return apierr.Forbidden("the audit journal requires a company scoped role")
}

// List returns one page of the audit trail with every value masked.
func (s *Service) List(ctx context.Context, f Filter) ([]dto.Entry, int64, error) {
	if err := requireCompanyScope(ctx); err != nil {
		return nil, 0, err
	}
	rows, total, err := s.repo.List(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "audit log")
	}
	out := make([]dto.Entry, 0, len(rows))
	for _, r := range rows {
		out = append(out, entryOf(r))
	}
	return out, total, nil
}

// Tables returns the audited table names of the tenant, for the filter
// dropdown of the audit journal screen.
func (s *Service) Tables(ctx context.Context) ([]string, error) {
	if err := requireCompanyScope(ctx); err != nil {
		return nil, err
	}
	out, err := s.repo.Tables(ctx)
	if err != nil {
		return nil, db.MapError(err, "audit log")
	}
	if out == nil {
		out = []string{}
	}
	return out, nil
}

func entryOf(r db.ListAuditLogRow) dto.Entry {
	field := pgconv.Deref(r.Field)
	oldValue, oldMasked := maskJSON(field, r.OldValue)
	newValue, newMasked := maskJSON(field, r.NewValue)

	return dto.Entry{
		ID:           r.ID.String(),
		TableName:    r.TableName,
		RecordID:     pgconv.UUIDString(r.RecordID),
		Field:        field,
		OldValue:     oldValue,
		NewValue:     newValue,
		Masked:       oldMasked || newMasked,
		Action:       r.Action,
		EditedBy:     pgconv.UUIDString(r.EditedBy),
		EditedByName: fullName(r.FirstName, r.LastName),
		Username:     pgconv.Deref(r.Username),
		IP:           addrString(r.Ip),
		UserAgent:    httpx.MaskSecrets(pgconv.Deref(r.UserAgent)),
		Reason:       httpx.MaskSecrets(pgconv.Deref(r.Reason)),
		TS:           r.Ts.UTC(),
	}
}

func fullName(first, last *string) string {
	return strings.TrimSpace(strings.TrimSpace(pgconv.Deref(first)) + " " + strings.TrimSpace(pgconv.Deref(last)))
}

func addrString(a *netip.Addr) string {
	if a == nil || !a.IsValid() {
		return ""
	}
	return a.String()
}
