package support

import (
	"context"
	"net/http"
	"strings"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/support/dto"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Audited table names.
const (
	tableTickets  = "support_tickets"
	tableMessages = "ticket_messages"
	tableFeedback = "feedback"
)

// statusRank orders the Q77 lifecycle. A transition is only accepted when it
// moves forward: new → in_progress → resolved.
var statusRank = map[string]int{
	dto.StatusNew:        0,
	dto.StatusInProgress: 1,
	dto.StatusResolved:   2,
	dto.StatusClosed:     3,
}

// Service holds the support business rules.
type Service struct {
	repo Repo
}

// NewService builds the support service.
func NewService(repo Repo) *Service { return &Service{repo: repo} }

// ListTickets returns one page of tickets. A `self` scoped caller (driver app)
// only ever sees the tickets it owns, whatever the query says.
func (s *Service) ListTickets(ctx context.Context, f TicketFilter) ([]dto.Ticket, int64, error) {
	s.applySelfScope(ctx, &f)
	rows, total, err := s.repo.ListTickets(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "support ticket")
	}
	out := make([]dto.Ticket, 0, len(rows))
	for _, r := range rows {
		out = append(out, ticketFromList(r))
	}
	return out, total, nil
}

// GetTicket returns one ticket. Cross-tenant and out-of-scope rows are 404, so
// a driver cannot probe another driver's ticket ids.
func (s *Service) GetTicket(ctx context.Context, id uuid.UUID) (*dto.Ticket, error) {
	row, err := s.repo.GetTicket(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "support ticket")
	}
	if !s.visible(ctx, row) {
		return nil, apierr.NotFound("support ticket")
	}
	t := ticketFromGet(row)
	return &t, nil
}

// CreateTicket files a new ticket. The reporter is always taken from the
// context: `driver_id` is resolved from the caller's driver row, never sent.
func (s *Service) CreateTicket(ctx context.Context, in dto.TicketCreate) (*dto.Ticket, error) {
	attachments, err := normalizeAttachments(tenant.CompanyID(ctx), in.Attachments)
	if err != nil {
		return nil, err
	}
	userID := tenant.UserID(ctx)
	driverID, err := s.repo.DriverIDForUser(ctx, userID)
	if err != nil {
		return nil, db.MapError(err, "driver")
	}

	arg := db.CreateSupportTicketParams{
		DriverID:    pgconv.UUID(driverID),
		CreatedBy:   pgconv.UUID(userID),
		Subject:     strings.TrimSpace(in.Subject),
		Description: pgconv.NilIfEmpty(strings.TrimSpace(in.Description)),
		ContactOn:   pgconv.NilIfEmpty(strings.TrimSpace(in.ContactOn)),
		Status:      dto.StatusNew,
		Attachments: attachments,
	}

	row, err := s.repo.CreateTicket(ctx, arg, func(t db.SupportTicket) []audit.Entry {
		return []audit.Entry{{
			TableName: tableTickets, RecordID: t.ID, Field: "status",
			OldValue: nil, NewValue: t.Status, Action: audit.ActionCreate,
		}}
	})
	if err != nil {
		return nil, db.MapError(err, "support ticket")
	}
	t := ticketFromGet(row)
	return &t, nil
}

// SetStatus moves a ticket along the Q77 lifecycle. Only a forward transition
// is accepted; anything else is 409 INVALID_STATE.
func (s *Service) SetStatus(ctx context.Context, id uuid.UUID, in dto.TicketStatusUpdate) (*dto.Ticket, error) {
	current, err := s.repo.GetTicket(ctx, id)
	if err != nil {
		return nil, db.MapError(err, "support ticket")
	}
	// A `self` scoped caller may only move its own ticket; anything else is
	// invisible (404), never 403.
	if !s.visible(ctx, current) {
		return nil, apierr.NotFound("support ticket")
	}
	next := strings.TrimSpace(in.Status)
	from, ok := statusRank[current.Status]
	to, ok2 := statusRank[next]
	if !ok || !ok2 || to <= from {
		return nil, apierr.New(apierr.CodeInvalidState, http.StatusConflict,
			"a support ticket only moves forward: new → in_progress → resolved")
	}

	row, err := s.repo.SetTicketStatus(ctx, id, next, func(before string, after db.SupportTicket) []audit.Entry {
		return []audit.Entry{{
			TableName: tableTickets, RecordID: after.ID, Field: "status",
			OldValue: before, NewValue: after.Status, Action: audit.ActionUpdate,
		}}
	})
	if err != nil {
		return nil, db.MapError(err, "support ticket")
	}
	t := ticketFromGet(row)
	return &t, nil
}

// ListMessages returns one page of the ticket thread.
func (s *Service) ListMessages(ctx context.Context, f MessageFilter) ([]dto.TicketMessage, int64, error) {
	if _, err := s.GetTicket(ctx, f.TicketID); err != nil {
		return nil, 0, err
	}
	rows, total, err := s.repo.ListMessages(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "ticket message")
	}
	out := make([]dto.TicketMessage, 0, len(rows))
	for _, r := range rows {
		out = append(out, messageFromList(r))
	}
	return out, total, nil
}

// AddMessage appends one entry to the ticket thread. A driver may only write
// into its own ticket; every other ticket is invisible (404).
func (s *Service) AddMessage(ctx context.Context, ticketID uuid.UUID, in dto.TicketMessageCreate) (*dto.TicketMessage, error) {
	if _, err := s.GetTicket(ctx, ticketID); err != nil {
		return nil, err
	}
	attachments, err := normalizeAttachments(tenant.CompanyID(ctx), in.Attachments)
	if err != nil {
		return nil, err
	}
	text := strings.TrimSpace(in.Text)
	if text == "" {
		return nil, apierr.Validation("validation failed",
			apierr.FieldError{Field: "text", Message: "required"})
	}

	row, err := s.repo.CreateMessage(ctx, db.CreateTicketMessageParams{
		TicketID: ticketID,
		SenderID: tenant.UserID(ctx),
		Text:     text,
		Column5:  attachments,
	}, func(m db.TicketMessage) []audit.Entry {
		return []audit.Entry{{
			TableName: tableMessages, RecordID: m.ID, Field: "ticket_id",
			OldValue: nil, NewValue: m.TicketID.String(), Action: audit.ActionCreate,
		}}
	})
	if err != nil {
		return nil, db.MapError(err, "ticket message")
	}
	m := messageFromGet(row)
	return &m, nil
}

// ListFeedback returns one page of app feedback (Q80). Feedback is never
// answered, so there is no detail or update endpoint.
func (s *Service) ListFeedback(ctx context.Context, f FeedbackFilter) ([]dto.Feedback, int64, error) {
	rows, total, err := s.repo.ListFeedback(ctx, f)
	if err != nil {
		return nil, 0, db.MapError(err, "feedback")
	}
	out := make([]dto.Feedback, 0, len(rows))
	for _, r := range rows {
		out = append(out, feedbackFromList(r))
	}
	return out, total, nil
}

// CreateFeedback stores one rating. At least one of app_rating / text must be
// present, otherwise the submission carries no information.
func (s *Service) CreateFeedback(ctx context.Context, in dto.FeedbackCreate) (*dto.Feedback, error) {
	text := strings.TrimSpace(in.Text)
	if in.AppRating == nil && text == "" {
		return nil, apierr.Validation("validation failed",
			apierr.FieldError{Field: "app_rating", Message: "app_rating or text is required"})
	}
	driverID, err := s.repo.DriverIDForUser(ctx, tenant.UserID(ctx))
	if err != nil {
		return nil, db.MapError(err, "driver")
	}

	row, err := s.repo.CreateFeedback(ctx, db.CreateFeedbackParams{
		DriverID:  pgconv.UUID(driverID),
		AppRating: in.AppRating,
		Text:      pgconv.NilIfEmpty(text),
	}, func(f db.Feedback) []audit.Entry {
		return []audit.Entry{{
			TableName: tableFeedback, RecordID: f.ID, Field: "app_rating",
			OldValue: nil, NewValue: f.AppRating, Action: audit.ActionCreate,
		}}
	})
	if err != nil {
		return nil, db.MapError(err, "feedback")
	}
	fb := feedbackFromList(row)
	return &fb, nil
}

// applySelfScope pins a `self` scoped principal to its own rows.
func (s *Service) applySelfScope(ctx context.Context, f *TicketFilter) {
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok || p.Scope != tenant.ScopeSelf {
		return
	}
	id := p.UserID
	f.SelfUserID = &id
	// A self scoped caller may not widen the filter to another driver.
	f.DriverID = nil
}

// visible reports whether the caller may see a ticket row.
func (s *Service) visible(ctx context.Context, row db.SupportGetTicketRow) bool {
	p, ok := tenant.PrincipalFrom(ctx)
	if !ok || p.Scope != tenant.ScopeSelf {
		return true
	}
	if created := pgconv.ToUUIDPtr(row.CreatedBy); created != nil && *created == p.UserID {
		return true
	}
	if owner := pgconv.ToUUIDPtr(row.DriverUserID); owner != nil && *owner == p.UserID {
		return true
	}
	return false
}

// normalizeAttachments trims the file keys and enforces the Q77 budget of
// three. Empty entries are dropped rather than stored.
//
// Every remaining key must be one this tenant produced through
// POST /files/presign: the key is the only thing between a stored reference
// and another company's object, and a presigned GET issued later would honour
// whatever was stored (TZ B§3.4).
func normalizeAttachments(companyID uuid.UUID, in []string) ([]string, error) {
	out := make([]string, 0, len(in))
	for _, k := range in {
		k = strings.TrimSpace(k)
		if k == "" {
			continue
		}
		if !storage.OwnsKey(companyID, k) {
			return nil, apierr.Validation("validation failed",
				apierr.FieldError{Field: "attachments", Message: "unknown object key"})
		}
		out = append(out, k)
	}
	if len(out) > dto.MaxAttachments {
		return nil, apierr.Validation("validation failed",
			apierr.FieldError{Field: "attachments", Message: "at most 3 files"})
	}
	return out, nil
}
