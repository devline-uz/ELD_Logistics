/// Push payload validation: `event_type` enum (M32) and future-time guard (M41).
library;

import 'package:meta/meta.dart';

/// Values accepted by `swagger.json` for `EventPush.event_type` (M32).
///
/// A duty status change is always sent as [statusChange].
enum SyncEventType {
  statusChange('status_change'),
  dutyStatus('duty_status'),
  intermediate('intermediate'),
  login('login'),
  logout('logout'),
  powerOn('power_on'),
  powerOff('power_off'),
  engineOn('engine_on'),
  engineOff('engine_off'),
  malfunction('malfunction'),
  diagnostic('diagnostic'),
  certification('certification'),
  yardMoves('yard_moves'),
  personalUse('personal_use');

  const SyncEventType(this.wire);

  final String wire;

  static SyncEventType? tryParse(String? wire) {
    if (wire == null) {
      return null;
    }
    for (final SyncEventType type in SyncEventType.values) {
      if (type.wire == wire) {
        return type;
      }
    }
    return null;
  }
}

/// How the event was produced (`EventPush.origin`).
enum EventOrigin {
  auto('auto'),
  driver('driver'),

  /// Manual status entered with no ELD connection (M40).
  manualNoEld('manual_no_eld'),

  /// Event moved from the unidentified queue by a claim.
  assigned('assigned');

  const EventOrigin(this.wire);

  final String wire;

  static EventOrigin? tryParse(String? wire) {
    if (wire == null) {
      return null;
    }
    for (final EventOrigin origin in EventOrigin.values) {
      if (origin.wire == wire) {
        return origin;
      }
    }
    return null;
  }
}

/// Trusted source of `event_time` (§7.1), in descending priority.
enum EventTimeSource {
  eldRtc('eld_rtc'),
  server('server'),
  phone('phone');

  const EventTimeSource(this.wire);

  final String wire;

  /// Higher wins the "same instant, two devices" conflict (eld-sync rule #1).
  int get priority => switch (this) {
    EventTimeSource.eldRtc => 3,
    EventTimeSource.server => 2,
    EventTimeSource.phone => 1,
  };

  static EventTimeSource? tryParse(String? wire) {
    if (wire == null) {
      return null;
    }
    for (final EventTimeSource source in EventTimeSource.values) {
      if (source.wire == wire) {
        return source;
      }
    }
    return null;
  }
}

/// One validation failure; [field] matches the payload key.
@immutable
class ValidationIssue {
  const ValidationIssue(this.field, this.code);

  final String field;
  final String code;

  @override
  bool operator ==(Object other) =>
      other is ValidationIssue && other.field == field && other.code == code;

  @override
  int get hashCode => Object.hash(field, code);

  @override
  String toString() => '$field: $code';
}

/// Minimal event shape validated before it reaches the outbox.
@immutable
class EventDraft {
  const EventDraft({
    required this.clientEventId,
    required this.eventType,
    required this.eventTime,
    required this.deviceSeq,
    this.status,
    this.special,
    this.origin,
    this.timeSource,
    this.lat,
    this.lng,
    this.gpsAccuracyM,
    this.odometerM,
    this.engineHours,
    this.speedKmh,
    this.notes,
  });

  final String clientEventId;
  final SyncEventType eventType;
  final DateTime eventTime;
  final int deviceSeq;
  final String? status;
  final String? special;
  final EventOrigin? origin;
  final EventTimeSource? timeSource;
  final double? lat;
  final double? lng;
  final double? gpsAccuracyM;
  final int? odometerM;
  final double? engineHours;
  final double? speedKmh;
  final String? notes;
}

/// Server tolerance for clock drift: `event_time > server_time + 5 min` is
/// rejected with `time_in_future` (eld-sync conflict rule #3).
const Duration kFutureTimeTolerance = Duration(minutes: 5);

/// Longest accepted note (`swagger.json` `EventPush.notes`).
const int kMaxNotesLength = 500;

/// Validates [draft] against the push contract.
///
/// [serverTime] is the best known server instant from `TimeSource`; it is used
/// for the future-time guard only. Returns an empty list when the draft is valid.
List<ValidationIssue> validateEventDraft(EventDraft draft, {required DateTime serverTime}) {
  final List<ValidationIssue> issues = <ValidationIssue>[];

  if (!isUuidV4(draft.clientEventId)) {
    issues.add(const ValidationIssue('client_event_id', 'not_uuid_v4'));
  }
  if (draft.deviceSeq < 0) {
    issues.add(const ValidationIssue('device_seq', 'negative'));
  }
  if (draft.eventTime.toUtc().isAfter(serverTime.toUtc().add(kFutureTimeTolerance))) {
    issues.add(const ValidationIssue('event_time', 'time_in_future'));
  }
  final double? lat = draft.lat;
  if (lat != null && (lat < -90 || lat > 90)) {
    issues.add(const ValidationIssue('lat', 'out_of_range'));
  }
  final double? lng = draft.lng;
  if (lng != null && (lng < -180 || lng > 180)) {
    issues.add(const ValidationIssue('lng', 'out_of_range'));
  }
  final double? accuracy = draft.gpsAccuracyM;
  if (accuracy != null && accuracy < 0) {
    issues.add(const ValidationIssue('gps_accuracy_m', 'negative'));
  }
  final int? odometer = draft.odometerM;
  if (odometer != null && odometer < 0) {
    issues.add(const ValidationIssue('odometer_m', 'negative'));
  }
  final double? engineHours = draft.engineHours;
  if (engineHours != null && engineHours < 0) {
    issues.add(const ValidationIssue('engine_hours', 'negative'));
  }
  final double? speed = draft.speedKmh;
  if (speed != null && speed < 0) {
    issues.add(const ValidationIssue('speed_kmh', 'negative'));
  }
  final String? notes = draft.notes;
  if (notes != null && notes.length > kMaxNotesLength) {
    issues.add(const ValidationIssue('notes', 'too_long'));
  }
  return issues;
}

/// M41: pulls an event time back to `serverTime + tolerance` when the local
/// clock runs ahead, so the server never sees `time_in_future`.
///
/// Times at or behind the server are returned unchanged (always UTC).
DateTime clampEventTime({
  required DateTime eventTime,
  required DateTime serverTime,
  Duration tolerance = kFutureTimeTolerance,
}) {
  final DateTime event = eventTime.toUtc();
  final DateTime ceiling = serverTime.toUtc().add(tolerance);
  return event.isAfter(ceiling) ? ceiling : event;
}

final RegExp _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

/// True when [value] is a lower-case UUID v4 (M19).
bool isUuidV4(String value) => _uuidV4.hasMatch(value);
