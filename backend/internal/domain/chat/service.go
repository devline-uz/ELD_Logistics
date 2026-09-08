package chat

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/chat/dto"
	"github.com/devline/onebook-eld/internal/notify"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
)

// StatusDriving is the duty status that blocks the driver's chat (TZ §15.4 —
// driver distraction policy).
const StatusDriving = "DR"

// Chat channel events.
const (
	EventMessageCreated = "chat_message"
	EventMessageRead    = "chat_message_read"
)

// Presence reports whether a user holds a live WebSocket connection. The hub
// implements it; without one every message also raises a push.
type Presence interface {
	IsOnline(companyID, userID uuid.UUID) bool
}

// Alerts is the notification surface the chat needs: a direct push to the
// driver and a role addressed alert for the office side. *notify.Dispatcher
// implements it.
type Alerts interface {
	Send(ctx context.Context, n notify.Notification) error
	Broadcast(ctx context.Context, ev notify.Event) error
}

// nopAlerts drops every alert; used when the module runs without a dispatcher.
type nopAlerts struct{}

func (nopAlerts) Send(context.Context, notify.Notification) error { return nil }
func (nopAlerts) Broadcast(context.Context, notify.Event) error   { return nil }

// Service is the chat business layer.
type Service struct {
	repo     Repo
	pub      ws.Publisher
	alerts   Alerts
	presence Presence
	log      *slog.Logger
	now      func() time.Time
}

// NewService builds the chat service.
func NewService(repo Repo, pub ws.Publisher, alerts Alerts, presence Presence, log *slog.Logger, now func() time.Time) *Service {
	if pub == nil {
		pub = ws.NopPublisher{}
	}
	if alerts == nil {
		alerts = nopAlerts{}
	}
	if log == nil {
		log = slog.Default()
	}
	if now == nil {
		now = time.Now
	}
	return &Service{repo: repo, pub: pub, alerts: alerts, presence: presence, log: log, now: now}
}

// Threads returns the admin side conversation list.
func (s *Service) Threads(ctx context.Context, f ThreadFilter) ([]dto.Thread, int64, error) {
	rows, last, total, err := s.repo.Threads(ctx, f)
	if err != nil {
		return nil, 0, err
	}
	byDriver := make(map[uuid.UUID]db.ListChatLastMessagesRow, len(last))
	for _, m := range last {
		byDriver[m.DriverID] = m
	}
	out := make([]dto.Thread, 0, len(rows))
	for _, row := range rows {
		t := dto.Thread{
			DriverID:     row.DriverID.String(),
			DriverName:   strings.TrimSpace(row.FirstName + " " + row.LastName),
			DriverStatus: row.DriverStatus,
			UnreadCount:  row.UnreadCount,
		}
		if m, ok := byDriver[row.DriverID]; ok {
			msg := lastToDTO(m, row.DriverUserID)
			t.LastMessage = &msg
		}
		out = append(out, t)
	}
	return out, total, nil
}

// Thread resolves one driver's thread header, enforcing the caller's scope.
func (s *Service) Thread(ctx context.Context, driverID uuid.UUID) (Driver, error) {
	return s.repo.Driver(ctx, driverID)
}

// DriverOf resolves the driver record of a self scoped principal.
func (s *Service) DriverOf(ctx context.Context, userID uuid.UUID) (Driver, error) {
	return s.repo.DriverByUser(ctx, userID)
}

// History returns one cursor page of a thread, newest first.
func (s *Service) History(ctx context.Context, driver Driver, f HistoryFilter, viewerID uuid.UUID) ([]dto.Message, dto.CursorMeta, error) {
	// One extra row tells us whether an older page exists.
	limit := f.Limit
	f.Limit = limit + 1
	rows, err := s.repo.History(ctx, f)
	if err != nil {
		return nil, dto.CursorMeta{}, err
	}
	meta := dto.CursorMeta{PerPage: int(limit)}
	if int32(len(rows)) > limit { //nolint:gosec // G115: rows is capped at limit+1 (<=maxHistoryLimit) above
		rows = rows[:limit]
		meta.HasMore = true
	}
	out := make([]dto.Message, 0, len(rows))
	for _, row := range rows {
		out = append(out, toDTO(row, driver.UserID))
	}
	if len(rows) > 0 {
		oldest := rows[len(rows)-1].SentAt.UTC()
		meta.NextBefore = &oldest
	}
	unread, err := s.repo.Unread(ctx, driver.ID, viewerID)
	if err != nil {
		return nil, dto.CursorMeta{}, err
	}
	meta.Unread = unread
	return out, meta, nil
}

// Send stores one message and fans it out over WebSocket and push.
func (s *Service) Send(ctx context.Context, driver Driver, senderID uuid.UUID, in dto.MessageCreate) (dto.Message, error) {
	msg, err := s.validate(ctx, in)
	if err != nil {
		return dto.Message{}, err
	}
	// TZ §15.4 — chat is blocked while the driver is driving. The rule applies
	// to what the driver writes; the office may still queue a message, which
	// the app shows once the driver leaves DR.
	if senderID == driver.UserID {
		status, err := s.repo.CurrentDutyStatus(ctx, driver.ID)
		if err != nil {
			return dto.Message{}, err
		}
		if status == StatusDriving {
			return dto.Message{}, apierr.New(apierr.CodeDrivingModeBlocked, http.StatusConflict,
				"chat is blocked while the driver is in driving status")
		}
	}
	msg.DriverID = driver.ID
	msg.SenderID = senderID

	row, err := s.repo.Create(ctx, msg)
	if err != nil {
		return dto.Message{}, err
	}
	out := toDTO(row, driver.UserID)
	s.publish(ctx, EventMessageCreated, driver, out)
	s.push(ctx, driver, senderID, row.ID, out)
	return out, nil
}

// ThreadOf resolves the thread a message belongs to, so the caller's scope can
// be checked before the receipt is written.
func (s *Service) ThreadOf(ctx context.Context, messageID uuid.UUID) (Driver, error) {
	return s.repo.DriverOfMessage(ctx, messageID)
}

// MarkRead records a read receipt and republishes the message state. driver is
// the already authorised thread owner (see ThreadOf).
func (s *Service) MarkRead(ctx context.Context, driver Driver, id, readerID uuid.UUID) (dto.ReadResult, dto.Message, error) {
	row, n, err := s.repo.MarkRead(ctx, id, readerID)
	if err != nil {
		return dto.ReadResult{}, dto.Message{}, err
	}
	out := toDTO(row, driver.UserID)
	if n > 0 {
		s.publish(ctx, EventMessageRead, driver, out)
	}
	unread, err := s.repo.Unread(ctx, row.DriverID, readerID)
	if err != nil {
		return dto.ReadResult{}, dto.Message{}, err
	}
	return dto.ReadResult{Updated: n, Unread: unread}, out, nil
}

// validate turns the request body into a storable message.
func (s *Service) validate(ctx context.Context, in dto.MessageCreate) (NewMessage, error) {
	text := strings.TrimSpace(in.Text)
	if utf8.RuneCountInString(text) > dto.MaxTextLen {
		return NewMessage{}, apierr.New(apierr.CodeMessageTooLong, http.StatusUnprocessableEntity,
			"a chat message may not exceed 2000 characters")
	}
	out := NewMessage{Kind: in.Kind, Text: pgconv.NilIfEmpty(text)}
	switch in.Kind {
	case dto.KindText:
		if text == "" {
			return NewMessage{}, apierr.Validation("text is required",
				apierr.FieldError{Field: "text", Message: "required"})
		}
	case dto.KindImage, dto.KindFile:
		key := strings.TrimSpace(in.FileKey)
		if key == "" {
			return NewMessage{}, apierr.Validation("file_key is required",
				apierr.FieldError{Field: "file_key", Message: "required"})
		}
		// The upload itself is bounded by POST /files/presign (kind `chat`,
		// max 10 MB); here the reference is checked to be this tenant's own
		// object, so a foreign key can never be stored and later presigned.
		if !storage.OwnsKey(tenant.CompanyID(ctx), key) {
			return NewMessage{}, apierr.Validation("file_key does not belong to this company",
				apierr.FieldError{Field: "file_key", Message: "unknown object key"})
		}
		out.FileKey = &key
	case dto.KindLocation:
		if in.Lat == nil || in.Lng == nil {
			return NewMessage{}, apierr.Validation("lat and lng are required",
				apierr.FieldError{Field: "lat", Message: "required"})
		}
		out.Lat, out.Lng = in.Lat, in.Lng
	default:
		return NewMessage{}, apierr.Validation("unsupported kind",
			apierr.FieldError{Field: "kind", Message: "must be one of: text, image, file, location"})
	}
	return out, nil
}

// publish pushes the message onto the WebSocket chat channel. A thread has
// exactly two sides, so the event is addressed: the driver that owns it and the
// dispatch side of its branch. `chat.read` is held by every driver, so a plain
// company broadcast would hand every conversation to all of them.
func (s *Service) publish(ctx context.Context, event string, driver Driver, msg dto.Message) {
	payload, err := json.Marshal(msg)
	if err != nil {
		return
	}
	owner := driver.UserID
	if err := s.pub.Publish(ctx, ws.Message{
		Channel:   ws.ChannelChat,
		Event:     event,
		CompanyID: tenant.CompanyID(ctx),
		Payload:   payload,
		SentAt:    s.now().UTC(),
		To:        ws.Audience{UserID: &owner, Office: true, BranchID: driver.BranchID},
	}); err != nil {
		s.log.WarnContext(ctx, "chat: websocket publish failed", slog.String("error", err.Error()))
	}
}

// push raises the chat_message alert for the other side. TZ A§19: chat_message
// notifies both directions; a recipient that is connected over the WebSocket
// already has the message, so no push is sent to it.
func (s *Service) push(ctx context.Context, driver Driver, senderID, messageID uuid.UUID, msg dto.Message) {
	companyID := tenant.CompanyID(ctx)
	body := preview(msg)
	data := map[string]string{"driver_id": driver.ID.String()}

	if senderID == driver.UserID {
		// The driver wrote: the office side is role addressed.
		if err := s.alerts.Broadcast(ctx, notify.Event{
			CompanyID: companyID, AlertType: notify.AlertChatMessage,
			Title: "New message from " + strings.TrimSpace(driver.FirstName+" "+driver.LastName),
			Body:  body, EntityType: "chat_messages", EntityID: &messageID, Data: data,
		}); err != nil {
			s.log.WarnContext(ctx, "chat: office alert failed", slog.String("error", err.Error()))
		}
		return
	}
	if s.presence != nil && s.presence.IsOnline(companyID, driver.UserID) {
		return
	}
	if err := s.alerts.Send(ctx, notify.Notification{
		CompanyID: companyID, UserID: driver.UserID, AlertType: notify.AlertChatMessage,
		Title: "New message from dispatch", Body: body,
		EntityType: "chat_messages", EntityID: &messageID, Data: data,
	}); err != nil {
		s.log.WarnContext(ctx, "chat: push failed", slog.String("error", err.Error()))
	}
}

// previewLen bounds the push preview.
const previewLen = 120

func preview(msg dto.Message) string {
	switch msg.Kind {
	case dto.KindImage:
		return "Photo"
	case dto.KindFile:
		return "Attachment"
	case dto.KindLocation:
		return "Location"
	}
	text := msg.Text
	if utf8.RuneCountInString(text) > previewLen {
		runes := []rune(text)
		return string(runes[:previewLen]) + "…"
	}
	return text
}

// toDTO maps a stored message onto the wire shape.
func toDTO(row db.ChatMessage, driverUserID uuid.UUID) dto.Message {
	out := dto.Message{
		ID:          row.ID.String(),
		DriverID:    row.DriverID.String(),
		SenderID:    row.SenderID.String(),
		SenderSide:  side(row.SenderID, driverUserID),
		Kind:        row.Kind,
		Text:        pgconv.Deref(row.Text),
		FileKey:     pgconv.Deref(row.FileKey),
		Lat:         row.Lat,
		Lng:         row.Lng,
		Status:      state(row.DeliveredAt.Valid, row.ReadAt.Valid),
		SentAt:      row.SentAt.UTC(),
		DeliveredAt: pgconv.ToTimePtr(row.DeliveredAt),
		ReadAt:      pgconv.ToTimePtr(row.ReadAt),
	}
	return out
}

func lastToDTO(row db.ListChatLastMessagesRow, driverUserID uuid.UUID) dto.Message {
	return dto.Message{
		ID:          row.ID.String(),
		DriverID:    row.DriverID.String(),
		SenderID:    row.SenderID.String(),
		SenderSide:  side(row.SenderID, driverUserID),
		Kind:        row.Kind,
		Text:        pgconv.Deref(row.Text),
		FileKey:     pgconv.Deref(row.FileKey),
		Status:      state(row.DeliveredAt.Valid, row.ReadAt.Valid),
		SentAt:      row.SentAt.UTC(),
		DeliveredAt: pgconv.ToTimePtr(row.DeliveredAt),
		ReadAt:      pgconv.ToTimePtr(row.ReadAt),
	}
}

func side(senderID, driverUserID uuid.UUID) string {
	if senderID == driverUserID {
		return dto.SideDriver
	}
	return dto.SideOffice
}

func state(delivered, read bool) string {
	switch {
	case read:
		return dto.StatusRead
	case delivered:
		return dto.StatusDelivered
	default:
		return dto.StatusSent
	}
}
