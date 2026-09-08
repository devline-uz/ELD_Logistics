import 'package:sync_core/sync_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

const String kId = '3f2504e0-4f89-41d3-9a0c-0305e82c3301';

EventDraft draft({
  String clientEventId = kId,
  DateTime? eventTime,
  int deviceSeq = 1,
  double? lat,
  double? lng,
  double? gpsAccuracyM,
  int? odometerM,
  double? engineHours,
  double? speedKmh,
  String? notes,
}) => EventDraft(
  clientEventId: clientEventId,
  eventType: SyncEventType.statusChange,
  eventTime: eventTime ?? t0,
  deviceSeq: deviceSeq,
  lat: lat,
  lng: lng,
  gpsAccuracyM: gpsAccuracyM,
  odometerM: odometerM,
  engineHours: engineHours,
  speedKmh: speedKmh,
  notes: notes,
);

void main() {
  group('enums', () {
    test('SyncEventType covers the M32 list', () {
      expect(SyncEventType.values, hasLength(14));
      for (final SyncEventType type in SyncEventType.values) {
        expect(SyncEventType.tryParse(type.wire), type);
      }
      expect(SyncEventType.tryParse('driving'), isNull);
      expect(SyncEventType.tryParse(null), isNull);
      expect(SyncEventType.statusChange.wire, 'status_change');
    });

    test('EventOrigin parses the swagger values', () {
      for (final EventOrigin origin in EventOrigin.values) {
        expect(EventOrigin.tryParse(origin.wire), origin);
      }
      expect(EventOrigin.tryParse('robot'), isNull);
      expect(EventOrigin.tryParse(null), isNull);
      expect(EventOrigin.manualNoEld.wire, 'manual_no_eld');
    });

    test('EventTimeSource ranks eld_rtc > server > phone (§7.1)', () {
      expect(EventTimeSource.eldRtc.priority, greaterThan(EventTimeSource.server.priority));
      expect(EventTimeSource.server.priority, greaterThan(EventTimeSource.phone.priority));
      for (final EventTimeSource s in EventTimeSource.values) {
        expect(EventTimeSource.tryParse(s.wire), s);
      }
      expect(EventTimeSource.tryParse('gps'), isNull);
      expect(EventTimeSource.tryParse(null), isNull);
    });
  });

  group('isUuidV4', () {
    test('accepts a canonical v4', () {
      expect(isUuidV4(kId), isTrue);
    });

    test('rejects wrong version, variant, case and shape', () {
      expect(isUuidV4('3f2504e0-4f89-11d3-9a0c-0305e82c3301'), isFalse);
      expect(isUuidV4('3f2504e0-4f89-41d3-1a0c-0305e82c3301'), isFalse);
      expect(isUuidV4(kId.toUpperCase()), isFalse);
      expect(isUuidV4('not-a-uuid'), isFalse);
      expect(isUuidV4(''), isFalse);
    });
  });

  group('validateEventDraft', () {
    test('accepts a well-formed draft', () {
      expect(validateEventDraft(draft(), serverTime: t0), isEmpty);
    });

    test('flags a non-UUID client_event_id (M19)', () {
      expect(
        validateEventDraft(draft(clientEventId: 'abc'), serverTime: t0),
        contains(const ValidationIssue('client_event_id', 'not_uuid_v4')),
      );
    });

    test('flags a negative device_seq', () {
      expect(
        validateEventDraft(draft(deviceSeq: -1), serverTime: t0),
        contains(const ValidationIssue('device_seq', 'negative')),
      );
    });

    test('flags a time beyond server + 5 min but tolerates the window', () {
      expect(
        validateEventDraft(draft(eventTime: t0.add(const Duration(minutes: 6))), serverTime: t0),
        contains(const ValidationIssue('event_time', 'time_in_future')),
      );
      expect(
        validateEventDraft(draft(eventTime: t0.add(const Duration(minutes: 5))), serverTime: t0),
        isEmpty,
      );
      expect(
        validateEventDraft(draft(eventTime: t0.subtract(const Duration(days: 3))), serverTime: t0),
        isEmpty,
      );
    });

    test('flags out-of-range coordinates', () {
      expect(
        validateEventDraft(draft(lat: 91), serverTime: t0),
        contains(const ValidationIssue('lat', 'out_of_range')),
      );
      expect(
        validateEventDraft(draft(lat: -91), serverTime: t0),
        contains(const ValidationIssue('lat', 'out_of_range')),
      );
      expect(
        validateEventDraft(draft(lng: 181), serverTime: t0),
        contains(const ValidationIssue('lng', 'out_of_range')),
      );
      expect(
        validateEventDraft(draft(lng: -181), serverTime: t0),
        contains(const ValidationIssue('lng', 'out_of_range')),
      );
      expect(validateEventDraft(draft(lat: 31.5, lng: 74.3), serverTime: t0), isEmpty);
    });

    test('flags negative measurements', () {
      final List<ValidationIssue> issues = validateEventDraft(
        draft(gpsAccuracyM: -1, odometerM: -1, engineHours: -1, speedKmh: -1),
        serverTime: t0,
      );
      expect(issues, hasLength(4));
      expect(issues.map((ValidationIssue i) => i.field), <String>[
        'gps_accuracy_m',
        'odometer_m',
        'engine_hours',
        'speed_kmh',
      ]);
    });

    test('flags overlong notes', () {
      expect(
        validateEventDraft(draft(notes: 'n' * 501), serverTime: t0),
        contains(const ValidationIssue('notes', 'too_long')),
      );
      expect(validateEventDraft(draft(notes: 'n' * 500), serverTime: t0), isEmpty);
    });

    test('ValidationIssue has value equality', () {
      expect(const ValidationIssue('a', 'b'), const ValidationIssue('a', 'b'));
      expect(const ValidationIssue('a', 'b').hashCode, const ValidationIssue('a', 'b').hashCode);
      expect(const ValidationIssue('a', 'b'), isNot(const ValidationIssue('a', 'c')));
      expect(const ValidationIssue('a', 'b').toString(), 'a: b');
    });

    test('optional fields default to null', () {
      final EventDraft bare = EventDraft(
        clientEventId: kId,
        eventType: SyncEventType.login,
        eventTime: t0,
        deviceSeq: 0,
      );
      expect(bare.status, isNull);
      expect(bare.special, isNull);
      expect(bare.origin, isNull);
      expect(bare.timeSource, isNull);
    });
  });

  group('clampEventTime (M41)', () {
    test('pulls a future time back to the ceiling', () {
      expect(
        clampEventTime(eventTime: t0.add(const Duration(hours: 2)), serverTime: t0),
        t0.add(const Duration(minutes: 5)),
      );
    });

    test('leaves past and in-window times untouched', () {
      final DateTime past = t0.subtract(const Duration(minutes: 30));
      expect(clampEventTime(eventTime: past, serverTime: t0), past);
      final DateTime inWindow = t0.add(const Duration(minutes: 4));
      expect(clampEventTime(eventTime: inWindow, serverTime: t0), inWindow);
    });

    test('always returns UTC and honours a custom tolerance', () {
      final DateTime clamped = clampEventTime(
        eventTime: t0.add(const Duration(minutes: 10)).toLocal(),
        serverTime: t0,
        tolerance: Duration.zero,
      );
      expect(clamped.isUtc, isTrue);
      expect(clamped, t0);
    });
  });
}
