// Driver app feedback endpoints (TZ A§15 Q80).
package support

import (
	"net/http"

	"github.com/devline/onebook-eld/internal/domain/support/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// listFeedback godoc
//
//	@Summary      List app feedback
//	@Description  Q80 — the driver app rating stream. Feedback is never answered, so there is no detail, update or delete route.
//	@Tags         support
//	@Produce      json
//	@Param        page       query     int     false  "Page number"                        default(1)
//	@Param        per_page   query     int     false  "Rows per page (10/25/50, max 100)"  default(25)
//	@Param        sort       query     string  false  "Sort field"  Enums(submitted_at, app_rating)
//	@Param        order      query     string  false  "Sort order"  Enums(asc, desc)
//	@Param        driver_id  query     string  false  "Driver filter (uuid)"
//	@Param        min_rating query     int     false  "Minimum star rating (1..5)"
//	@Param        from       query     string  false  "Submitted at or after (RFC3339)"
//	@Param        to         query     string  false  "Submitted before (RFC3339)"
//	@Success      200  {object}  dto.FeedbackListEnvelope
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Security     BearerAuth
//	@x-permission "feedback.read"
//	@Router       /feedback [get]
func (m *Module) listFeedback(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	sort, err := httpx.ParseSort(r, feedbackSorts, httpx.Sort{Field: "submitted_at", Order: "desc"})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	driverID, err := httpx.QueryUUID(r, "driver_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	minRating, err := queryRating(r, "min_rating")
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

	items, total, err := m.svc.ListFeedback(r.Context(), FeedbackFilter{
		DriverID:  driverID,
		MinRating: minRating,
		From:      from,
		To:        to,
		Sort:      sort.Field,
		Order:     sort.Order,
		Limit:     page.Limit(),
		Offset:    page.Offset(),
	})
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, items, page.Meta(total))
}

// createFeedback godoc
//
//	@Summary      Submit app feedback
//	@Description  Q80 — the driver rates the app (1..5) and/or leaves a note; at least one of the two is required. The submission gets no reply. `driver_id` is resolved from the access token.
//	@Tags         support
//	@Accept       json
//	@Produce      json
//	@Param        Idempotency-Key  header  string              false  "Replay protection key"
//	@Param        body             body    dto.FeedbackCreate  true   "Feedback payload"
//	@Success      201  {object}  dto.FeedbackEnvelope
//	@Failure      400  {object}  dto.ErrorResponse  "BAD_REQUEST"
//	@Failure      401  {object}  dto.ErrorResponse  "UNAUTHORIZED"
//	@Failure      403  {object}  dto.ErrorResponse  "FORBIDDEN"
//	@Failure      422  {object}  dto.ErrorResponse  "VALIDATION_ERROR"
//	@Failure      429  {object}  dto.ErrorResponse  "RATE_LIMITED"
//	@Security     BearerAuth
//	@x-permission "feedback.create"
//	@Router       /feedback [post]
func (m *Module) createFeedback(w http.ResponseWriter, r *http.Request) {
	var in dto.FeedbackCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateFeedback(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}
