package support

import (
	"strings"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/support/dto"
	"github.com/devline/onebook-eld/internal/pgconv"
)

// fullName joins the two halves of a user name, tolerating NULL columns.
func fullName(first, last *string) string {
	return strings.TrimSpace(strings.TrimSpace(pgconv.Deref(first)) + " " + strings.TrimSpace(pgconv.Deref(last)))
}

// emptySlice keeps `attachments` a JSON array instead of null.
func emptySlice(v []string) []string {
	if v == nil {
		return []string{}
	}
	return v
}

func ticketFromList(r db.SupportListTicketsRow) dto.Ticket {
	return dto.Ticket{
		ID:           r.ID.String(),
		DriverID:     pgconv.UUIDString(r.DriverID),
		DriverName:   fullName(r.DriverFirstName, r.DriverLastName),
		CreatedBy:    pgconv.UUIDString(r.CreatedBy),
		CreatorName:  fullName(r.CreatorFirstName, r.CreatorLastName),
		Subject:      r.Subject,
		Description:  pgconv.Deref(r.Description),
		ContactOn:    pgconv.Deref(r.ContactOn),
		Status:       r.Status,
		Attachments:  emptySlice(r.Attachments),
		MessageCount: r.MessageCount,
		ResolvedAt:   pgconv.ToTimePtr(r.ResolvedAt),
		CreatedAt:    r.CreatedAt.UTC(),
		UpdatedAt:    r.UpdatedAt.UTC(),
	}
}

func ticketFromGet(r db.SupportGetTicketRow) dto.Ticket {
	return ticketFromList(db.SupportListTicketsRow(r))
}

func messageFromList(r db.SupportListTicketMessagesRow) dto.TicketMessage {
	return dto.TicketMessage{
		ID:          r.ID.String(),
		TicketID:    r.TicketID.String(),
		SenderID:    r.SenderID.String(),
		SenderName:  strings.TrimSpace(r.FirstName + " " + r.LastName),
		Text:        r.Text,
		Attachments: emptySlice(r.Attachments),
		CreatedAt:   r.CreatedAt.UTC(),
	}
}

func messageFromGet(r db.SupportGetTicketMessageRow) dto.TicketMessage {
	return messageFromList(db.SupportListTicketMessagesRow(r))
}

func feedbackFromList(r db.SupportListFeedbackRow) dto.Feedback {
	return dto.Feedback{
		ID:          r.ID.String(),
		DriverID:    pgconv.UUIDString(r.DriverID),
		DriverName:  fullName(r.FirstName, r.LastName),
		AppRating:   r.AppRating,
		Text:        pgconv.Deref(r.Text),
		SubmittedAt: r.SubmittedAt.UTC(),
	}
}
