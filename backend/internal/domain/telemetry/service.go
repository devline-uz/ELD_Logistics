package telemetry

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	"github.com/devline/onebook-eld/internal/cache"
	"github.com/devline/onebook-eld/internal/db"
	"github.com/devline/onebook-eld/internal/domain/telemetry/dto"
	"github.com/devline/onebook-eld/internal/pgconv"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/ws"
	"github.com/devline/onebook-eld/pkg/eldproto"
)

// ELD connectivity states of unit_last_state.online_status (TZ §10.1).
// `malfunction` is never stored: it is derived when reading, from
// eld_devices.status / malfunction_codes, so the two sources cannot diverge.
const (
	StatusOnline       = "online"
	StatusIdle         = "idle"
	StatusOffline      = "offline"
	StatusDisconnected = "disconnected"
	StatusMalfunction  = "malfunction"
)

// WebSocket channel and event used by the live map (docs/websocket.md).
const (
	ChannelTracking    = "tracking"
	EventUnitLastState = "unit_last_state"
)

// OnlineWindow is the freshness window of the Online state (TZ §10.1).
const OnlineWindow = 5 * time.Minute

// LastStateTTL is the lifetime of the Redis `unit:last:<unit_id>` mirror.
const LastStateTTL = 10 * time.Minute

// StaleThresholdMinutes is the default argument of the periodic offline sweep.
const StaleThresholdMinutes = 5

// tableDevices is the audited table of ELD status changes.
const tableDevices = "eld_devices"

// LastStateKey is the Redis key of the cached last state.
func LastStateKey(unitID uuid.UUID) string { return "unit:last:" + unitID.String() }

// Deps are the telemetry ingestion dependencies. Only Repo is required; the
// cache, object storage and WebSocket publisher degrade to no-ops so the
// pipeline keeps writing telemetry when they are unavailable.
type Deps struct {
	Repo Repo
	// Store mirrors the last state into Redis for the live map.
	Store cache.Store
	// Objects persists trip and unidentified polylines.
	Objects storage.Putter
	// Publisher pushes the last state to the WebSocket `tracking` channel.
	Publisher ws.Publisher
	// Now is injectable so the online window is testable.
	Now func() time.Time
	Log *slog.Logger
}

// Service is the telemetry ingestion pipeline. It has no HTTP surface:
// /sync/push and the device gateway call it directly.
type Service struct {
	repo    Repo
	store   cache.Store
	objects storage.Putter
	pub     ws.Publisher
	now     func() time.Time
	log     *slog.Logger
}

// New builds the ingestion service.
func New(deps Deps) *Service {
	s := &Service{
		repo:    deps.Repo,
		store:   deps.Store,
		objects: deps.Objects,
		pub:     deps.Publisher,
		now:     deps.Now,
		log:     deps.Log,
	}
	if s.now == nil {
		s.now = time.Now
	}
	if s.objects == nil {
		s.objects = storage.NopPutter{}
	}
	if s.pub == nil {
		s.pub = ws.NopPublisher{}
	}
	if s.log == nil {
		s.log = slog.Default()
	}
	return s
}

// Ingest stores one unit's batch and applies the trip, unidentified driving and
// ELD health rules. Telemetry itself is never audited (volume); an ELD status
// change is.
func (s *Service) Ingest(ctx context.Context, in dto.Batch) (*dto.Result, error) {
	if len(in.Points) == 0 {
		return nil, apierr.Validation("points must not be empty",
			apierr.FieldError{Field: "points", Message: "required"})
	}
	if len(in.Points) > dto.MaxBatchPoints {
		return nil, apierr.New(apierr.CodeBatchTooLarge, http.StatusUnprocessableEntity,
			"telemetry batch exceeds 5000 points")
	}
	unitID, err := uuid.Parse(in.UnitID)
	if err != nil {
		return nil, apierr.Validation("unit_id must be a uuid",
			apierr.FieldError{Field: "unit_id", Message: "invalid"})
	}
	if _, err := s.repo.UnitBrief(ctx, unitID); err != nil {
		return nil, db.MapError(err, "unit")
	}

	points, err := convertPoints(in)
	if err != nil {
		return nil, err
	}
	points = Normalize(points)
	if len(points) == 0 {
		return &dto.Result{}, nil
	}

	device, err := s.resolveDevice(ctx, unitID, in)
	if err != nil {
		return nil, err
	}

	state, err := s.repo.State(ctx, unitID)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	plan := BuildPlan(state, points)

	last := plan.Last
	input := IngestInput{
		UnitID:       unitID,
		DeviceID:     device.id,
		Source:       source(in.Source),
		Points:       plan.Points,
		Last:         last,
		OnlineStatus: s.onlineStatus(last),
		Trips:        s.withTracks(ctx, unitID, "trips", plan.Trips),
		Unidentified: s.withTracks(ctx, unitID, "unidentified", plan.Unidentified),
		Device:       deviceHealth(device, points),
	}
	// A trip inherits the driver that was at the wheel when it opened.
	for i := range input.Trips {
		input.Trips[i].DriverID = driverAt(plan.Points, input.Trips[i].Start)
	}

	outcome, err := s.repo.Ingest(ctx, input, func(before, after db.EldDevice) []audit.Entry {
		return audit.Changes(tableDevices, after.ID, audit.ActionUpdate,
			map[string]any{"status": before.Status, "malfunction_codes": before.MalfunctionCodes},
			map[string]any{"status": after.Status, "malfunction_codes": after.MalfunctionCodes})
	})
	if err != nil {
		return nil, db.MapError(err, "telemetry")
	}

	res := &dto.Result{
		Accepted:           int(outcome.Accepted),
		Duplicate:          int(outcome.Duplicate),
		DistanceM:          plan.DistanceM,
		TripsOpened:        outcome.TripsOpened,
		TripsClosed:        outcome.TripsClosed,
		UnidentifiedOpened: outcome.UnidentifiedOpened,
		UnidentifiedClosed: outcome.UnidentifiedClosed,
		OnlineStatus:       input.OnlineStatus,
	}
	if last != nil {
		ts := last.TS
		res.LastSeenAt = &ts
	}
	if outcome.LastState != nil {
		s.publishLastState(ctx, *outcome.LastState)
	}
	return res, nil
}

// MarkStaleOffline demotes units of the caller tenant that stopped reporting
// (TZ §10.1: Online means telemetry within five minutes). It is the body of the
// periodic internal/jobs task.
func (s *Service) MarkStaleOffline(ctx context.Context, thresholdMinutes int32) (int64, error) {
	if thresholdMinutes <= 0 {
		thresholdMinutes = StaleThresholdMinutes
	}
	n, err := s.repo.MarkStaleOffline(ctx, thresholdMinutes)
	if err != nil {
		return 0, db.MapError(err, "unit")
	}
	return n, nil
}

// onlineStatus derives the stored connectivity state from the newest sample.
func (s *Service) onlineStatus(last *Point) string {
	if last == nil {
		return StatusOffline
	}
	if last.Disconnected {
		return StatusDisconnected
	}
	if s.now().UTC().Sub(last.TS) > OnlineWindow {
		return StatusOffline
	}
	return StatusOnline
}

// deviceInfo is the ELD resolved for a batch.
type deviceInfo struct {
	id       *uuid.UUID
	status   string
	codes    []string
	firmware string
}

func (s *Service) resolveDevice(ctx context.Context, unitID uuid.UUID, in dto.Batch) (deviceInfo, error) {
	var out deviceInfo
	row, err := s.repo.ActiveDevice(ctx, unitID)
	if err == nil {
		id := row.ID
		out = deviceInfo{id: &id, status: row.Status, codes: row.MalfunctionCodes}
		if row.Firmware != nil {
			out.firmware = *row.Firmware
		}
	}
	if in.DeviceID == nil {
		return out, nil
	}
	id, err := uuid.Parse(*in.DeviceID)
	if err != nil {
		return out, apierr.Validation("device_id must be a uuid",
			apierr.FieldError{Field: "device_id", Message: "invalid"})
	}
	// A device_id that does not belong to this unit is ignored rather than
	// trusted: the wiring is owned by the fleet module.
	if out.id == nil || *out.id != id {
		return out, nil
	}
	if in.Firmware != "" {
		out.firmware = in.Firmware
	}
	return out, nil
}

// deviceHealth turns the Appendix A letters of a batch into the eld_devices
// update (TZ §10.5). Codes are only cleared when the device explicitly reported
// an empty set; silence never clears them.
func deviceHealth(d deviceInfo, points []Point) *DeviceHealth {
	if d.id == nil {
		return nil
	}
	h := &DeviceHealth{DeviceID: *d.id, LastSeenAt: points[len(points)-1].TS}
	if d.firmware != "" {
		fw := d.firmware
		h.Firmware = &fw
	}

	reported := false
	var codes []string
	for _, p := range points {
		if !p.DiagnosticsReported {
			continue
		}
		reported = true
		codes = append(codes, p.Diagnostics...)
	}
	if !reported {
		return h
	}
	h.MalfunctionCodes = eldproto.NormalizeCodes(codes)

	status := "active"
	if len(h.MalfunctionCodes) > 0 {
		status = StatusMalfunction
	}
	// An operator disabled device stays disabled; telemetry never revives it.
	if d.status == "inactive" {
		status = "inactive"
	}
	h.Status = &status
	return h
}

// withTracks uploads the polyline of every closed segment and returns the
// segments carrying their storage key. Uploads happen before the ingest
// transaction opens, so no network call is held inside a transaction.
func (s *Service) withTracks(ctx context.Context, unitID uuid.UUID, kind string, segs []Segment) []SegmentApply {
	out := make([]SegmentApply, 0, len(segs))
	for _, seg := range segs {
		item := SegmentApply{Segment: seg}
		if seg.Closed && len(seg.Points) > 1 {
			key := storage.BuildKey(tenant.CompanyID(ctx), kind+"/"+unitID.String(), "track.polyline", seg.Start)
			body := []byte(EncodePolyline(seg.Points))
			if err := s.objects.PutObject(ctx, key, body, "text/plain; charset=utf-8"); err != nil {
				// A missing track must never lose the trip itself.
				s.log.WarnContext(ctx, "telemetry: polyline upload failed",
					slog.String("kind", kind), slog.String("error", err.Error()))
			} else {
				item.TrackKey = &key
			}
		}
		out = append(out, item)
	}
	return out
}

// publishLastState mirrors the state into Redis and the `tracking` channel.
func (s *Service) publishLastState(ctx context.Context, row db.UnitLastState) {
	state := dto.LastState{
		UnitID:       row.UnitID.String(),
		Lat:          row.Lat,
		Lng:          row.Lng,
		SpeedKmh:     row.SpeedKmh,
		HeadingDeg:   row.Heading,
		OdometerM:    row.OdometerM,
		OnlineStatus: row.OnlineStatus,
		DriverID:     pgconv.UUIDString(row.DriverID),
	}
	if row.Ts.Valid {
		state.TS = row.Ts.Time.UTC()
	}
	if row.DutyStatus != nil {
		state.DutyStatus = *row.DutyStatus
	}
	if v, ok := numericFloat(row.EngineHours); ok {
		state.EngineHours = &v
	}
	updated := row.UpdatedAt.UTC()
	state.UpdatedAt = &updated

	payload, err := json.Marshal(state)
	if err != nil {
		return
	}
	if s.store != nil {
		if err := s.store.Set(ctx, LastStateKey(row.UnitID), string(payload), LastStateTTL); err != nil {
			s.log.WarnContext(ctx, "telemetry: last state cache write failed", slog.String("error", err.Error()))
		}
	}
	if err := s.pub.Publish(ctx, ws.Message{
		Channel:   ChannelTracking,
		Event:     EventUnitLastState,
		CompanyID: row.CompanyID,
		Payload:   payload,
		SentAt:    s.now().UTC(),
	}); err != nil {
		s.log.WarnContext(ctx, "telemetry: tracking publish failed", slog.String("error", err.Error()))
	}
}

// convertPoints maps the wire payload onto the internal sample type.
func convertPoints(in dto.Batch) ([]Point, error) {
	out := make([]Point, 0, len(in.Points))
	for _, p := range in.Points {
		if p.TS.IsZero() {
			return nil, apierr.Validation("ts is required",
				apierr.FieldError{Field: "points.ts", Message: "required"})
		}
		point := Point{
			TS:              p.TS.UTC(),
			Lat:             p.Lat,
			Lng:             p.Lng,
			SpeedKmh:        p.SpeedKmh,
			Heading:         p.HeadingDeg,
			OdometerM:       p.OdometerM,
			EngineHours:     p.EngineHours,
			FuelPct:         p.FuelPct,
			CoolantTempC:    p.CoolantTempC,
			CoolantLevelPct: p.CoolantLevelPct,
			OilLevelPct:     p.OilLevelPct,
			BatteryPct:      p.BatteryPct,
			BatteryVoltageV: p.BatteryVoltageV,
			Ignition:        p.Ignition,
			DutyStatus:      p.DutyStatus,
			Diagnostics:     eldproto.NormalizeCodes(p.Diagnostics),
			// A nil slice means "not reported"; an empty array clears the codes.
			DiagnosticsReported: p.Diagnostics != nil,
			Disconnected:        p.Disconnected,
			Source:              source(in.Source),
		}
		if p.DriverID != nil {
			id, err := uuid.Parse(*p.DriverID)
			if err != nil {
				return nil, apierr.Validation("driver_id must be a uuid",
					apierr.FieldError{Field: "points.driver_id", Message: "invalid"})
			}
			point.DriverID = &id
		}
		out = append(out, point)
	}
	return out, nil
}

func source(v string) string {
	if v == "" {
		return dto.SourceELD
	}
	return v
}

// driverAt is the driver reported at or after a segment start.
func driverAt(points []Point, at time.Time) *uuid.UUID {
	for _, p := range points {
		if p.TS.Before(at) {
			continue
		}
		if p.DriverID != nil {
			return p.DriverID
		}
		break
	}
	return nil
}
