package dashboard

import (
	"context"
	"encoding/json"
	"log/slog"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/dashboard/dto"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
)

// Defaults of the dashboard payload.
const (
	// DefaultRouteLimit bounds the "Route's Details" block.
	DefaultRouteLimit = 50
	// UncertifiedDays is the age at which a log counts as uncertified
	// (TZ A§20 — two days or more).
	UncertifiedDays = 2
	// DefaultTimezone is used when the company row carries none.
	DefaultTimezone = "America/Chicago"
)

// EventSummary is the dashboard channel event name.
const EventSummary = "dashboard_summary"

// Service builds the dashboard payload.
type Service struct {
	repo Repo
	pub  ws.Publisher
	log  *slog.Logger
	now  func() time.Time
}

// NewService builds the service. now is injectable so the company timezone day
// boundary is testable.
func NewService(repo Repo, pub ws.Publisher, log *slog.Logger, now func() time.Time) *Service {
	if pub == nil {
		pub = ws.NopPublisher{}
	}
	if log == nil {
		log = slog.Default()
	}
	if now == nil {
		now = time.Now
	}
	return &Service{repo: repo, pub: pub, log: log, now: now}
}

// Summary assembles the KPI cards, the duty status block and today's routes.
func (s *Service) Summary(ctx context.Context, branchID *uuid.UUID) (dto.Summary, error) {
	tz, err := s.repo.CompanyTimezone(ctx)
	if err != nil {
		return dto.Summary{}, err
	}
	loc := location(tz)
	windows := Boundaries(s.now().In(loc), loc)
	windows.BranchID = branchID
	windows.RouteLimit = DefaultRouteLimit

	kpi, err := s.repo.KPI(ctx, windows)
	if err != nil {
		return dto.Summary{}, err
	}
	routes, err := s.repo.Routes(ctx, windows)
	if err != nil {
		return dto.Summary{}, err
	}

	out := dto.Summary{
		Timezone: loc.String(),
		Day:      dto.Window{From: windows.DayStart, To: windows.DayEnd},
		Week:     dto.Window{From: windows.WeekStart, To: windows.WeekEnd},
		KPI: dto.KPI{
			ActiveUnits:       kpi.ActiveUnits,
			DriversOnDuty:     kpi.DriversOnDuty,
			Violations:        kpi.Violations,
			DisconnectedELD:   kpi.DisconnectedEld,
			MalfunctionELD:    kpi.MalfunctionEld,
			UncertifiedLogs:   kpi.UncertifiedLogs,
			UnassignedDriving: kpi.UnassignedDriving,
			ActiveDrivers:     kpi.ActiveDrivers,
			PendingLogEdits:   kpi.PendingLogEdits,
		},
		Status: dto.StatusBlock{
			Off: kpi.StatusOff, SB: kpi.StatusSb, DR: kpi.StatusDr, On: kpi.StatusOn,
		},
		Routes:      toRoutes(routes),
		GeneratedAt: s.now().UTC(),
	}
	return out, nil
}

// Publish pushes a freshly built summary onto the WebSocket dashboard channel.
// It is used by the background refresh; the HTTP handler answers directly.
func (s *Service) Publish(ctx context.Context, summary dto.Summary) {
	payload, err := json.Marshal(summary)
	if err != nil {
		return
	}
	if err := s.pub.Publish(ctx, ws.Message{
		Channel:   ws.ChannelDashboard,
		Event:     EventSummary,
		CompanyID: tenant.CompanyID(ctx),
		Payload:   payload,
		SentAt:    summary.GeneratedAt,
	}); err != nil {
		s.log.WarnContext(ctx, "dashboard: publish failed", slog.String("error", err.Error()))
	}
}

// Boundaries cuts the company day and the current ISO week (Monday–Sunday)
// around now, returning UTC instants. now must already be in loc.
func Boundaries(now time.Time, loc *time.Location) Windows {
	dayStart := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc)
	dayEnd := dayStart.AddDate(0, 0, 1)

	// ISO week: Monday is day one, so Sunday has to reach back six days.
	offset := (int(dayStart.Weekday()) + 6) % 7
	weekStart := dayStart.AddDate(0, 0, -offset)
	weekEnd := weekStart.AddDate(0, 0, 7)

	return Windows{
		DayStart:          dayStart.UTC(),
		DayEnd:            dayEnd.UTC(),
		WeekStart:         weekStart.UTC(),
		WeekEnd:           weekEnd.UTC(),
		UncertifiedBefore: dayStart.AddDate(0, 0, -UncertifiedDays),
	}
}

// location resolves a company timezone, falling back to the default when the
// stored name is unknown to the runtime.
func location(tz string) *time.Location {
	tz = strings.TrimSpace(tz)
	if tz == "" {
		tz = DefaultTimezone
	}
	loc, err := time.LoadLocation(tz)
	if err != nil || loc == nil {
		if loc, err = time.LoadLocation(DefaultTimezone); err == nil && loc != nil {
			return loc
		}
		return time.UTC
	}
	return loc
}

func toRoutes(rows []db.DashboardTodayRoutesRow) []dto.Route {
	out := make([]dto.Route, 0, len(rows))
	for _, row := range rows {
		out = append(out, dto.Route{
			ID:          row.ID.String(),
			Status:      row.Status,
			Sequence:    row.Sequence,
			Origin:      pgconv.Deref(row.OriginText),
			Destination: pgconv.Deref(row.DestText),
			UnitID:      row.UnitID.String(),
			UnitNumber:  row.UnitNumber,
			DriverID:    row.DriverID.String(),
			DriverName:  strings.TrimSpace(row.FirstName + " " + row.LastName),
			StartedAt:   pgconv.ToTimePtr(row.StartedAt),
			CompletedAt: pgconv.ToTimePtr(row.CompletedAt),
			CreatedAt:   row.CreatedAt.UTC(),
		})
	}
	return out
}
