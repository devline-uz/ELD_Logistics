// Support ticket endpoints (TZ A§15 Q77-Q79): the help desk queue, the ticket
// detail and its message thread. Split out of http.go to keep each file under
// the 400 line ceiling of the Go conventions.
package support

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/domain/support/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// listTickets godoc
//
//	@Summary      List support tickets
//	@Description  Q77 — the company help desk queue. A driver (`self` scope) only ever sees the tickets it filed or that were filed for it, whatever `driver_id` says.
//	@Tags         support
//	@Produce      json
//	@Param        page      query     int     false  "Page number"                        default(1)
//	@Param        per_page  query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        sort      query     string  false  "Sort field"  Enums(created_at, status, subject)
//	@Param        order     query     string  false  "Sort order"  Enums(asc, desc)
//	@Param        status    query     string  false  "Lifecycle filter"  Enums(new, in_progress, resolved, closed)
//	@Param        driver_id query     string  false  "Driver filter (uuid), ignored for a driver principal"
//	@Param        search    query     string  false  "Matches the subject"
//	@Param        from      query     string  false  "Created at or after (RFC3339)"
//	@Param        to        query     string  false  "Created before (RFC3339)"
//	@Success      200  {object}  dto.TicketListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "support.read"
//	@Router       /support-tickets [get]
func (m *Module) listTickets(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, ticketSorts, httpx.Sort{Field: "created_at", Order: "desc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	status, err := queryEnum(r, "status", dto.StatusNew, dto.StatusInProgress, dto.StatusResolved, dto.StatusClosed)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driverID, err := httpx.QueryUUID(r, "driver_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	from, err := httpx.QueryTime(r, "from")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	to, err := httpx.QueryTime(r, "to")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}

	tickets, total, err := m.svc.ListTickets(r.Context(), TicketFilter{
		Status:   status,
		DriverID: driverID,
		Search:   queryText(r, "search"),
		From:     from,
		To:       to,
		Sort:     sort.Field,
		Order:    sort.Order,
		Limit:    page.Limit(),
		Offset:   page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, tickets, page.Meta(total))
}

// createTicket godoc
//
//	@Summary      Create support ticket
//	@Description  Q77 — required: subject. `contact_on` picks the answer channel (Q78) and `attachments` carries at most three storage file keys returned by the upload endpoint. The reporter is taken from the access token: `driver_id` is resolved from the caller and never accepted from the body.
//	@Tags         support
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string            false  "Replay protection key"
//	@Param        body             body    dto.TicketCreate  true   "Ticket payload"
//	@Success      201  {object}  dto.TicketEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN, SUBSCRIPTION_READONLY"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "support.create"
//	@Router       /support-tickets [post]
func (m *Module) createTicket(w http.ResponseWriter, r *http.Request) {
	var in dto.TicketCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateTicket(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// getTicket godoc
//
//	@Summary      Get support ticket
//	@Description  Cross-tenant identifiers and another driver's ticket both answer 404, never 403, so ids cannot be probed.
//	@Tags         support
//	@Produce      json
//	@Param        id   path      string  true  "Ticket id"
//	@Success      200  {object}  dto.TicketEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "support.read"
//	@Router       /support-tickets/{id} [get]
func (m *Module) getTicket(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.GetTicket(r.Context(), id)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// setTicketStatus godoc
//
//	@Summary      Change support ticket status
//	@Description  Q77 — the lifecycle only moves forward: `new → in_progress → resolved`. Any backward or repeated transition answers 409 INVALID_STATE. Every change is written to `audit_log`.
//	@Tags         support
//	@Accept       json
//	@Produce      json
//	@Param        id    path  string                  true  "Ticket id"
//	@Param        body  body  dto.TicketStatusUpdate  true  "New status"
//	@Success      200  {object}  dto.TicketEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN, SUBSCRIPTION_READONLY"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      409  {object}  dto.ErrorResponse  "INVALID_STATE"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "support.update_status"
//	@Router       /support-tickets/{id}/status [patch]
func (m *Module) setTicketStatus(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.TicketStatusUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.SetStatus(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// listMessages godoc
//
//	@Summary      List ticket thread messages
//	@Description  Q77 [SHOULD] — the admin answer lives inside the ticket. Oldest first.
//	@Tags         support
//	@Produce      json
//	@Param        id        path      string  true   "Ticket id"
//	@Param        page      query     int     false  "Page number"                        default(1)
//	@Param        per_page  query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Success      200  {object}  dto.TicketMessageListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "support.read"
//	@Router       /support-tickets/{id}/messages [get]
func (m *Module) listMessages(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	msgs, total, err := m.svc.ListMessages(r.Context(), MessageFilter{
		TicketID: id, Limit: page.Limit(), Offset: page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, msgs, page.Meta(total))
}

// addMessage godoc
//
//	@Summary      Reply inside a support ticket
//	@Description  Q77 [SHOULD] — appends one entry to the ticket thread; at most three attachments. A driver may only write into a ticket it owns; every other ticket answers 404.
//	@Tags         support
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string                   false  "Replay protection key"
//	@Param        id               path    string                   true   "Ticket id"
//	@Param        body             body    dto.TicketMessageCreate  true   "Message payload"
//	@Success      201  {object}  dto.TicketMessageEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN, SUBSCRIPTION_READONLY"
//	@Failure      404  {object}  dto.ErrorResponse  "NOT_FOUND"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "support.create"
//	@Router       /support-tickets/{id}/messages [post]
func (m *Module) addMessage(w http.ResponseWriter, r *http.Request) {
	id, err := pathUUID(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	var in dto.TicketMessageCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.AddMessage(r.Context(), id, in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}
