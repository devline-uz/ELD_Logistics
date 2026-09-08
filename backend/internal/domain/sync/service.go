package sync

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/duty"
	"github.com/devline/onebook-eld/internal/domain/sync/dto"
	telemetrydto "github.com/devline/onebook-eld/internal/domain/telemetry/dto"
	syncrules "github.com/devline/onebook-eld/internal/sync"
)

// pullLimit bounds every cursor list of one /sync/pull response.
const pullLimit = 500

// defaultPullWindow is how far back a pull without a cursor reaches. It matches
// the 8 day log window the driver app keeps.
const defaultPullWindow = 8 * 24 * time.Hour

// DutyService is the duty status half of the protocol. internal/domain/duty
// owns the rules; this module only routes the batch to it.
type DutyService interface {
	DriverByUser(ctx context.Context, companyID, userID uuid.UUID) (duty.Context, error)
	Ingest(ctx context.Context, in duty.IngestInput) (*duty.IngestResult, error)
	Policy(ctx context.Context, companyID uuid.UUID, at time.Time) (duty.PolicyVersion, error)
}

// TelemetryIngestor is the telemetry half. internal/domain/telemetry owns the
// trip segmentation and the unidentified driving buffer.
type TelemetryIngestor interface {
	Ingest(ctx context.Context, in telemetrydto.Batch) (*telemetrydto.Result, error)
}

// Service is the offline sync protocol. It validates the batch ceilings, splits
// the payload and delegates each half to the domain that owns it.
type Service struct {
	repo      Repo
	dutySvc   DutyService
	telemetry TelemetryIngestor
	now       func() time.Time
	log       *slog.Logger
}

// NewService builds the sync service. now is injectable so `server_time` and
// the pull cursor are testable.
func NewService(repo Repo, dutySvc DutyService, telemetry TelemetryIngestor,
	now func() time.Time, log *slog.Logger,
) *Service {
	s := &Service{repo: repo, dutySvc: dutySvc, telemetry: telemetry, now: now, log: log}
	if s.now == nil {
		s.now = time.Now
	}
	if s.log == nil {
		s.log = slog.Default()
	}
	return s
}

// PushInput is one authenticated /sync/push call.
type PushInput struct {
	CompanyID uuid.UUID
	// UserID is the authenticated caller; the driver record is resolved from
	// it, never from the request body.
	UserID  uuid.UUID
	Request dto.PushRequest
}

// Push applies one upload batch.
//
// Every half is independent: a rejected event never costs the driver their
// telemetry, and a telemetry failure never rolls back accepted events. The
// batch ceilings are the only whole-batch failure (422 BATCH_TOO_LARGE).
func (s *Service) Push(ctx context.Context, in PushInput) (*dto.PushResponse, error) {
	if err := checkCeilings(in.Request); err != nil {
		return nil, err
	}
	driver, err := s.dutySvc.DriverByUser(ctx, in.CompanyID, in.UserID)
	if err != nil {
		return nil, err
	}

	out := &dto.PushResponse{
		ServerTime: s.now().UTC(),
		Events:     make([]dto.ElementResult, 0, len(in.Request.Events)),
		Dvir:       acknowledge(dvirIDs(in.Request.Dvir)),
		Chat:       acknowledge(chatIDs(in.Request.Chat)),
	}

	if len(in.Request.Events) > 0 {
		res, ierr := s.dutySvc.Ingest(ctx, duty.IngestInput{
			CompanyID:     in.CompanyID,
			DriverID:      driver.DriverID,
			ActorID:       in.UserID,
			Events:        toRuleEvents(in.Request.Events),
			Clock:         toRuleClock(in.Request.Clock),
			DefaultUnitID: unitOrDefault(in.Request.UnitID, driver.DefaultUnitID),
		})
		if ierr != nil {
			return nil, ierr
		}
		out.Clock = toClockVerdict(res.Integrity)
		for _, d := range res.Decisions {
			out.Events = append(out.Events, dto.ElementResult{
				ClientEventID: d.ClientEventID,
				Result:        d.Result,
				Reason:        d.Reason,
				Field:         d.Field,
				SupersededBy:  d.SupersededBy,
			})
		}
	} else {
		out.Clock = toClockVerdict(syncrules.EvaluateClock(toRuleClock(in.Request.Clock), out.ServerTime))
	}

	if len(in.Request.Telemetry) > 0 {
		res, terr := s.pushTelemetry(ctx, in, driver)
		if terr != nil {
			return nil, terr
		}
		out.Telemetry = res
	}
	return out, nil
}

// pushTelemetry hands the telemetry half to the ingestion pipeline, which owns
// trips, the unidentified buffer and the live map.
func (s *Service) pushTelemetry(ctx context.Context, in PushInput, driver duty.Context) (dto.TelemetryResult, error) {
	unitID := unitOrDefault(in.Request.UnitID, driver.DefaultUnitID)
	if unitID == nil {
		return dto.TelemetryResult{}, apierr.Validation("unit_id is required when telemetry is present",
			apierr.FieldError{Field: "unit_id", Message: "required"})
	}
	if s.telemetry == nil {
		return dto.TelemetryResult{}, apierr.New(apierr.CodeUnavailable, http.StatusServiceUnavailable,
			"telemetry ingestion is not wired")
	}

	// Stamp the authenticated driver on every sample that does not name one,
	// so an identified upload never opens an unidentified driving buffer.
	driverID := driver.DriverID.String()
	points := make([]telemetrydto.Point, 0, len(in.Request.Telemetry))
	for _, p := range in.Request.Telemetry {
		if p.DriverID == nil {
			id := driverID
			p.DriverID = &id
		}
		points = append(points, p)
	}

	res, err := s.telemetry.Ingest(ctx, telemetrydto.Batch{
		UnitID: unitID.String(),
		Source: telemetrydto.SourcePhone,
		Points: points,
	})
	if err != nil {
		return dto.TelemetryResult{}, err
	}
	return dto.TelemetryResult{
		Accepted:  res.Accepted,
		Duplicate: res.Duplicate,
		DistanceM: res.DistanceM,
	}, nil
}

// checkCeilings enforces the four batch limits before anything is parsed
// further, so an oversized upload costs one cheap rejection.
func checkCeilings(r dto.PushRequest) error {
	err := syncrules.ValidateBatch(syncrules.Batch{
		Events:    make([]syncrules.Event, len(r.Events)),
		Telemetry: make([]syncrules.TelemetryPoint, len(r.Telemetry)),
		DvirCount: len(r.Dvir),
		ChatCount: len(r.Chat),
	})
	if err != nil {
		return apierr.New(apierr.CodeBatchTooLarge, http.StatusUnprocessableEntity, err.Error())
	}
	return nil
}

// toRuleEvents converts the wire payload into the pure rule layer's shape.
func toRuleEvents(in []dto.EventPush) []syncrules.Event {
	out := make([]syncrules.Event, 0, len(in))
	for _, e := range in {
		out = append(out, syncrules.Event{
			ClientEventID:  e.ClientEventID,
			EventType:      e.EventType,
			Status:         e.Status,
			Special:        e.Special,
			Origin:         e.Origin,
			EventTime:      e.EventTime.UTC(),
			TimeSource:     e.TimeSource,
			DeviceSeq:      e.DeviceSeq,
			Lat:            e.Lat,
			Lng:            e.Lng,
			GPSAccuracyM:   e.GPSAccuracyM,
			LocationText:   e.LocationText,
			OdometerM:      e.OdometerM,
			EngineHours:    e.EngineHours,
			SpeedKmh:       e.SpeedKmh,
			Notes:          e.Notes,
			TrailerIDs:     e.TrailerIDs,
			ShippingDocIDs: e.ShippingDocIDs,
			UnitID:         e.UnitID,
			ELDDeviceID:    e.ELDDeviceID,
		})
	}
	return out
}

func toRuleClock(c dto.Clock) syncrules.Clock {
	var out syncrules.Clock
	if c.Phone != nil {
		out.Phone = c.Phone.UTC()
	}
	if c.ELDRTC != nil {
		out.ELDRTC = c.ELDRTC.UTC()
	}
	return out
}

func toClockVerdict(in syncrules.Integrity) dto.ClockVerdict {
	return dto.ClockVerdict{
		Source:          in.Source,
		SkewSec:         in.SkewSec,
		TimeUnverified:  in.Unverified,
		Warning:         in.Warn,
		MalfunctionCode: in.MalfunctionCode(),
	}
}

// acknowledge marks every element of a stage 5-6 batch as accepted.
//
// TODO(stage 5-6): chat delivery and DVIR processing replace this stub. The
// elements are acknowledged so the device can drain its queue in order without
// retrying forever; nothing is stored yet.
func acknowledge(ids []string) []dto.ElementResult {
	out := make([]dto.ElementResult, 0, len(ids))
	for _, id := range ids {
		out = append(out, dto.ElementResult{ClientEventID: id, Result: syncrules.ResultAccepted})
	}
	return out
}

func dvirIDs(in []dto.DvirPush) []string {
	out := make([]string, 0, len(in))
	for _, v := range in {
		out = append(out, v.ClientID)
	}
	return out
}

func chatIDs(in []dto.ChatPush) []string {
	out := make([]string, 0, len(in))
	for _, v := range in {
		out = append(out, v.ClientID)
	}
	return out
}

// unitOrDefault resolves the unit of a push: the explicit one, else the
// driver's default unit.
func unitOrDefault(raw string, fallback *uuid.UUID) *uuid.UUID {
	if raw != "" {
		if id, err := uuid.Parse(raw); err == nil {
			return &id
		}
	}
	return fallback
}
