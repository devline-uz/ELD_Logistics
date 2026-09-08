/// **M72:** ELD buferini o'qib outbox'ga deduplikatsiya bilan yozadi.
///
/// Takroriy o'qishda `client_event_id` **o'zgarmaydi** (deterministik UUID v5),
/// shuning uchun:
/// 1. `duty_events` da shu ID bo'lsa — event tashlab yuboriladi;
/// 2. bo'lmasa — `OutboxRepository.enqueueDutyEvent` chaqiriladi va ID
///    tashqaridan beriladi.
library;

import 'package:sync_core/sync_core.dart';

import '../db/app_database.dart';
import '../db/daos/duty_events_dao.dart';
import '../sync/outbox_repository.dart';
import 'eld_client_event_id.dart';
import 'eld_models.dart';

/// Import natijasi — M-19 va diagnostikada ko'rsatiladi.
class EldBufferImportResult {
  const EldBufferImportResult({
    required this.imported,
    required this.skipped,
    required this.clientEventIds,
  });

  /// Outbox'ga yangi yozilganlar soni.
  final int imported;

  /// Dublikat sifatida tashlab yuborilganlar soni.
  final int skipped;

  /// Ko'rilgan barcha ID lar (tartibi buferdagidek).
  final List<String> clientEventIds;

  bool get isEmpty => imported == 0 && skipped == 0;

  @override
  String toString() => 'EldBufferImportResult(imported: $imported, skipped: $skipped)';
}

/// Bufer importi.
class EldBufferImporter {
  const EldBufferImporter({required this._events, required this._outbox});

  final DutyEventsDao _events;
  final OutboxRepository _outbox;

  /// [events] ni deduplikatsiya bilan yozadi.
  ///
  /// [deviceId] — ELD qurilma ID si (`client_event_id` urug'ining bir qismi).
  Future<EldBufferImportResult> import({
    required String deviceId,
    required List<EldBufferedEvent> events,
    String? driverId,
    String? unitId,
  }) async {
    int imported = 0;
    int skipped = 0;
    final List<String> ids = <String>[];

    for (final EldBufferedEvent event in events) {
      final String clientEventId = eldClientEventId(deviceId: deviceId, event: event);
      ids.add(clientEventId);

      final DutyEventRow? existing = await _events.byClientEventId(clientEventId);
      if (existing != null) {
        skipped++;
        continue;
      }

      await _outbox.enqueueDutyEvent(
        eventType: eldBufferEventTypeToSync(event.type),
        clientEventId: clientEventId,
        origin: EventOrigin.auto,
        eventTime: event.recordedAt,
        driverId: driverId,
        unitId: unitId,
        eldDeviceId: deviceId,
        lat: event.lat,
        lng: event.lng,
        odometerM: event.odometerM,
        engineHours: event.engineHours,
        speedKmh: event.speedKmh,
        notes: event.faultCode?.letter,
      );
      imported++;
    }

    return EldBufferImportResult(
      imported: imported,
      skipped: skipped,
      clientEventIds: List<String>.unmodifiable(ids),
    );
  }
}

/// Bufer event turini `sync_core` enumiga o'giradi.
SyncEventType eldBufferEventTypeToSync(EldBufferedEventType type) => switch (type) {
  EldBufferedEventType.powerOn => SyncEventType.powerOn,
  EldBufferedEventType.powerOff => SyncEventType.powerOff,
  EldBufferedEventType.motionStart => SyncEventType.statusChange,
  EldBufferedEventType.motionStop => SyncEventType.statusChange,
  EldBufferedEventType.malfunction => SyncEventType.malfunction,
  EldBufferedEventType.diagnostic => SyncEventType.diagnostic,
};
