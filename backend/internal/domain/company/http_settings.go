package company

import (
	"net/http"
	"strings"

	"github.com/devline/onebook-eld/internal/domain/company/dto"
	"github.com/devline/onebook-eld/internal/httpx"
)

// getHosPolicy godoc
//
//	@Summary		Get the effective HOS policy
//	@Description	Q10.1 — the hos_policy_versions row whose effective_from is the latest one not in the future. A company without a stored version falls back to the FMCSA 70/8 defaults.
//	@Tags			company
//	@Produce		json
//	@Success		200	{object}	dto.HosPolicyEnvelope
//	@Failure		401	{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403	{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		429	{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"hos_policy.read"
//	@Router			/company/hos-policy [get]
func (m *Module) getHosPolicy(w http.ResponseWriter, r *http.Request) {
	out, err := m.svc.HosPolicy(r.Context())
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// createHosPolicy godoc
//
//	@Summary		Publish a new HOS policy version
//	@Description	Q10.1 — a policy change is never retroactive: `effective_from` must not be in the past and days before it keep being evaluated with the previous version. Keys left out of `policy` inherit the currently effective value.
//	@Tags			company
//	@Accept			json
//	@Produce		json
//	@Param			Idempotency-Key	header		string					false	"Repeat safe key"
//	@Param			body			body		dto.HosPolicyCreate		true	"Policy version"
//	@Success		201				{object}	dto.HosPolicyEnvelope
//	@Failure		400				{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401				{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403				{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		409				{object}	dto.ErrorResponse	"IDEMPOTENCY_CONFLICT"
//	@Failure		422				{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429				{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"hos_policy.update"
//	@Router			/company/hos-policy [post]
func (m *Module) createHosPolicy(w http.ResponseWriter, r *http.Request) {
	var in dto.HosPolicyCreate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.CreateHosPolicy(r.Context(), in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusCreated, out)
}

// getNotificationSettings godoc
//
//	@Summary		Get the notification settings
//	@Description	TZ A§19 — one entry per alert type with its delivery channels and the recipient role ids. Alert types the company never customised are returned with the defaults of the specification table.
//	@Tags			company
//	@Produce		json
//	@Success		200	{object}	dto.NotificationSettingsEnvelope
//	@Failure		401	{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403	{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		429	{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"notification_settings.read"
//	@Router			/company/notification-settings [get]
func (m *Module) getNotificationSettings(w http.ResponseWriter, r *http.Request) {
	out, err := m.svc.NotificationSettings(r.Context())
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// updateNotificationSettings godoc
//
//	@Summary		Update the notification settings
//	@Description	Q89 — only the listed alert types are written; the rest keep their configuration. `channels` replaces the previous list, an empty list mutes the alert for every channel.
//	@Tags			company
//	@Accept			json
//	@Produce		json
//	@Param			body	body		dto.NotificationSettingsUpdate	true	"Alert configuration"
//	@Success		200		{object}	dto.NotificationSettingsEnvelope
//	@Failure		400		{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429		{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"notification_settings.update"
//	@Router			/company/notification-settings [patch]
func (m *Module) updateNotificationSettings(w http.ResponseWriter, r *http.Request) {
	var in dto.NotificationSettingsUpdate
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UpdateNotificationSettings(r.Context(), in, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// history godoc
//
//	@Summary		Company configuration history
//	@Description	The audit_log rows of the caller's company. The client IP is never returned.
//	@Tags			company
//	@Produce		json
//	@Param			page		query		int		false	"Page number"	default(1)
//	@Param			per_page	query		int		false	"Page size"		default(25)
//	@Param			table		query		string	false	"Audited table name"
//	@Param			action		query		string	false	"Audited action"
//	@Param			record_id	query		string	false	"Audited record id"
//	@Param			user		query		string	false	"Editor user id"
//	@Param			from		query		string	false	"From timestamp (RFC3339)"
//	@Param			to			query		string	false	"To timestamp, exclusive (RFC3339)"
//	@Success		200			{object}	dto.HistoryListEnvelope
//	@Failure		401			{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403			{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		422			{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Failure		429			{object}	dto.ErrorResponse	"RATE_LIMITED"
//	@Security		BearerAuth
//	@x-permission	"company.history.view"
//	@Router			/company/history [get]
func (m *Module) history(w http.ResponseWriter, r *http.Request) {
	page, err := httpx.ParsePagination(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	recordID, err := httpx.QueryUUID(r, "record_id")
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	user, err := httpx.QueryUUID(r, "user")
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

	q := HistoryQuery{
		Table:    strings.TrimSpace(r.URL.Query().Get("table")),
		Action:   strings.TrimSpace(r.URL.Query().Get("action")),
		RecordID: recordID,
		User:     user,
		From:     from,
		To:       to,
	}
	rows, total, err := m.svc.History(r.Context(), q, page)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteList(w, rows, page.Meta(total))
}
