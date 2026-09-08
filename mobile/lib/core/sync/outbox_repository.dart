/// Outbox patterni: biznes yozuvi + navbat yozuvi **bitta tranzaksiyada** (M24).
library;

import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:sync_core/sync_core.dart';

import '../db/app_database.dart';
import '../db/daos/outbox_dao.dart';
import '../security/active_slot.dart';
import '../security/secure_vault.dart';
import '../time/clock_verdict.dart';
import '../time/time_source.dart';
import 'session_slot.dart';

/// `enqueueDutyEvent` natijasi — UI ni optimistik yangilash uchun.
class EnqueuedEvent {
  const EnqueuedEvent({
    required this.clientEventId,
    required this.deviceSeq,
    required this.eventTime,
    required this.outboxId,
  });

  final String clientEventId;
  final int deviceSeq;
  final DateTime eventTime;
  final int outboxId;
}

/// `null` maydonlarni tashlab yuboradi — server ularni «yo'q» deb qabul qiladi.
Map<String, Object?> compactPayload(Map<String, Object?> payload) =>
    Map<String, Object?>.fromEntries(
      payload.entries.where((MapEntry<String, Object?> e) => e.value != null),
    );

/// Domen validatsiyasi yiqilganda tashlanadi — yozuv **umuman** bo'lmaydi.
class OutboxValidationException implements Exception {
  const OutboxValidationException(this.issues);

  final List<ValidationIssue> issues;

  @override
  String toString() => 'OutboxValidationException(${issues.join(', ')})';
}

/// Lokal navbat va uning biznes ko'zgusi ustidagi yagona yozuvchi.
class OutboxRepository {
  OutboxRepository({
    required AppDatabase db,
    required TimeSource time,
    ActiveSlotHolder? activeSlot,
    Random? random,
  }) : this._(db, time, activeSlot ?? ActiveSlotHolder(), random ?? Random.secure());

  OutboxRepository._(this._db, this._time, this._activeSlot, this._random);

  final AppDatabase _db;
  final TimeSource _time;

  /// **B-121:** chaqiruvchilar slotni bilmaydi — `session_slot` shu yerda,
  /// yozuv paytida, faol slotdan olinadi. `SessionManager` holderni yangilaydi.
  final ActiveSlotHolder _activeSlot;

  final Random _random;

  /// Yozuv tegishli bo'lgan slot: aniq berilgan bo'lsa o'sha, aks holda faol.
  int _resolveSlot(int? explicit) => explicit ?? slotColumn(_activeSlot.value);

  /// Faol haydovchi sloti (diagnostika va chaqiruvchilar uchun).
  DriverSlot get activeSlot => _activeSlot.value;

  /// Yangi barqaror `client_id` / `client_event_id` (M19).
  String newClientId() =>
      formatUuidV4(List<int>.generate(16, (int _) => _random.nextInt(256), growable: false));

  /// Batch uchun barqaror `Idempotency-Key` (M33.3).
  String newIdempotencyKey() => newClientId();

  /// **M24 + M20:** duty event va uning outbox yozuvi bitta tranzaksiyada.
  ///
  /// `device_seq` tranzaksiya ichida atomik oshiriladi, event vaqti M41 bo'yicha
  /// server oynasiga qisiladi. Validatsiya yiqilsa hech narsa yozilmaydi.
  Future<EnqueuedEvent> enqueueDutyEvent({
    required SyncEventType eventType,
    String? clientEventId,
    String? status,
    String special = 'none',
    EventOrigin origin = EventOrigin.driver,
    DateTime? eventTime,
    String? driverId,
    String? unitId,
    String? eldDeviceId,
    double? lat,
    double? lng,
    double? gpsAccuracyM,
    String? locationText,
    int? odometerM,
    double? engineHours,
    double? speedKmh,
    String? notes,
    List<String> trailerIds = const <String>[],
    List<String> shippingDocIds = const <String>[],
    String? logDate,
    int? sessionSlot,
  }) async {
    final String eventId = clientEventId ?? newClientId();
    final TimeReading reading = _time.reading();
    final DateTime when = _time.clampToServer(eventTime ?? reading.utc);

    return _db.transaction<EnqueuedEvent>(() async {
      final int seq = await _db.settingsDao.nextDeviceSeq(reading.utc);
      final int slot = _resolveSlot(sessionSlot);

      final EventDraft draft = EventDraft(
        clientEventId: eventId,
        eventType: eventType,
        eventTime: when,
        deviceSeq: seq,
        status: status,
        special: special,
        origin: origin,
        timeSource: reading.source,
        lat: lat,
        lng: lng,
        gpsAccuracyM: gpsAccuracyM,
        odometerM: odometerM,
        engineHours: engineHours,
        speedKmh: speedKmh,
        notes: notes,
      );
      final List<ValidationIssue> issues = validateEventDraft(draft, serverTime: reading.utc);
      if (issues.isNotEmpty) {
        throw OutboxValidationException(issues);
      }

      await _db
          .into(_db.dutyEvents)
          .insert(
            DutyEventsCompanion.insert(
              clientEventId: eventId,
              eventType: eventType.wire,
              eventTime: when,
              deviceSeq: seq,
              createdAt: reading.utc,
              status: Value<String?>(status),
              special: Value<String>(special),
              timeSource: Value<String>(reading.source.wire),
              timeUnverified: Value<bool>(reading.unverified),
              clockSkewSec: Value<int>(reading.clockSkewSec),
              origin: Value<String>(origin.wire),
              lat: Value<double?>(lat),
              lng: Value<double?>(lng),
              gpsAccuracyM: Value<double?>(gpsAccuracyM),
              locationText: Value<String?>(locationText),
              odometerM: Value<int?>(odometerM),
              engineHours: Value<double?>(engineHours),
              speedKmh: Value<double?>(speedKmh),
              notes: Value<String?>(notes),
              unitId: Value<String?>(unitId),
              eldDeviceId: Value<String?>(eldDeviceId),
              driverId: Value<String?>(driverId),
              trailerIds: Value<List<String>>(trailerIds),
              shippingDocIds: Value<List<String>>(shippingDocIds),
              logDate: Value<String?>(logDate),
            ),
          );

      final int outboxId = await _insertOutbox(
        kind: OutboxKind.event,
        clientId: eventId,
        deviceSeq: seq,
        now: reading.utc,
        sessionSlot: slot,
        userId: driverId,
        payload: compactPayload(<String, Object?>{
          'client_event_id': eventId,
          'event_type': eventType.wire,
          'event_time': when.toIso8601String(),
          'device_seq': seq,
          'time_source': reading.source.wire,
          'time_unverified': reading.unverified,
          'clock_skew_sec': reading.clockSkewSec,
          'origin': origin.wire,
          'status': status,
          'special': special,
          'lat': lat,
          'lng': lng,
          'gps_accuracy_m': gpsAccuracyM,
          'location_text': locationText,
          'odometer_m': odometerM,
          'engine_hours': engineHours,
          'speed_kmh': speedKmh,
          'notes': notes,
          'eld_device_id': eldDeviceId,
          'trailer_ids': trailerIds,
          'shipping_doc_ids': shippingDocIds,
        }),
      );

      return EnqueuedEvent(
        clientEventId: eventId,
        deviceSeq: seq,
        eventTime: when,
        outboxId: outboxId,
      );
    });
  }

  /// Boshqa turdagi element (`dvir`, `chat`, `certify`, `claim`, …).
  ///
  /// [writeBusinessRow] shu **tranzaksiya ichida** chaqiriladi: biznes jadvali
  /// va navbat birga yoziladi yoki birga qaytariladi (M24).
  Future<int> enqueue({
    required OutboxKind kind,
    required Map<String, Object?> payload,
    String? clientId,
    String? userId,
    int? sessionSlot,
    Future<void> Function(String clientId, int deviceSeq)? writeBusinessRow,
  }) async {
    final String id = clientId ?? newClientId();
    final DateTime now = _time.now();
    final int slot = _resolveSlot(sessionSlot);
    return _db.transaction<int>(() async {
      final int seq = await _db.settingsDao.nextDeviceSeq(now);
      if (writeBusinessRow != null) {
        await writeBusinessRow(id, seq);
      }
      return _insertOutbox(
        kind: kind,
        clientId: id,
        deviceSeq: seq,
        now: now,
        sessionSlot: slot,
        userId: userId,
        payload: payload,
      );
    });
  }

  Future<int> _insertOutbox({
    required OutboxKind kind,
    required String clientId,
    required int deviceSeq,
    required DateTime now,
    required Map<String, Object?> payload,
    required int sessionSlot,
    String? userId,
  }) => _db
      .into(_db.outboxItems)
      .insert(
        OutboxItemsCompanion.insert(
          kind: kind.wire,
          payload: jsonEncode(payload),
          clientId: clientId,
          deviceSeq: deviceSeq,
          createdAt: now,
          nextAttemptAt: now,
          updatedAt: now,
          sessionSlot: Value<int>(sessionSlot),
          userId: Value<String?>(userId),
        ),
      );

  /// **M31/M25:** push javobini bitta tranzaksiyada qo'llaydi.
  ///
  /// `event` turidagi elementlar uchun `duty_events.sync_state` ham yangilanadi,
  /// shuning uchun UI darhol to'g'ri holatni ko'radi.
  Future<void> applyPushOutcomes(Map<String, PushOutcome> byClientId) async {
    if (byClientId.isEmpty) {
      return;
    }
    final DateTime now = _time.now();
    await _db.transaction(() async {
      for (final MapEntry<String, PushOutcome> entry in byClientId.entries) {
        final List<OutboxItemRow> rows = await (_db.select(
          _db.outboxItems,
        )..where(($OutboxItemsTable t) => t.clientId.equals(entry.key))).get();
        for (final OutboxItemRow row in rows) {
          await _db.outboxDao.applyOutcome(id: row.id, outcome: entry.value, now: now);
          if (row.kind == OutboxKind.event.wire) {
            await _db.dutyEventsDao.markSyncState(
              clientEventId: entry.key,
              syncState: entry.value.outcome == OutboxOutcome.acked
                  ? OutboxState.acked.wire
                  : OutboxState.rejected.wire,
              supersededBy: entry.value.supersededBy,
            );
          }
        }
      }
    });
  }

  /// Ilova ishga tushganda: `inflight` da osilib qolganlarni qaytaradi.
  Future<int> recoverAfterRestart() => _db.outboxDao.recoverInflight(_time.now());

  /// Navbat holati oqimi (`M-54`, app bar indikatori).
  Stream<OutboxQueueStats> watchStats() => _db.outboxDao.watchStats();
}

/// `outbox_items.payload` ni `Map` ga qaytaradi.
Map<String, Object?> decodePayload(OutboxRecord record) {
  final Object? decoded = jsonDecode(record.payloadJson);
  return decoded is Map<String, Object?> ? decoded : <String, Object?>{};
}
