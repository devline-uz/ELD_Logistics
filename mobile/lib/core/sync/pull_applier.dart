/// `sync/pull` javobini **atomik** qo'llash: M36 tartibi, M31/M37 qoidalari.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/daos/settings_dao.dart';
import '../time/time_source.dart';

/// Xom `Map` dan xavfsiz o'qish yordamchilari (server maydoni yo'q bo'lsa ham
/// tranzaksiya yiqilmasin).
String? _str(Map<String, Object?> m, String key) => m[key]?.toString();

int _int(Map<String, Object?> m, String key, [int fallback = 0]) {
  final Object? v = m[key];
  if (v is int) {
    return v;
  }
  if (v is num) {
    return v.toInt();
  }
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

double? _double(Map<String, Object?> m, String key) {
  final Object? v = m[key];
  if (v is num) {
    return v.toDouble();
  }
  return double.tryParse(v?.toString() ?? '');
}

bool _bool(Map<String, Object?> m, String key, {bool fallback = false}) {
  final Object? v = m[key];
  return v is bool ? v : fallback;
}

DateTime? _dt(Map<String, Object?> m, String key) {
  final String? raw = _str(m, key);
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw)?.toUtc();
}

List<String> _strings(Map<String, Object?> m, String key) {
  final Object? v = m[key];
  return v is List
      ? v.whereType<Object>().map((Object e) => e.toString()).toList(growable: false)
      : const <String>[];
}

Map<String, Object?> _map(Map<String, Object?> m, String key) {
  final Object? v = m[key];
  return v is Map<String, Object?> ? v : const <String, Object?>{};
}

/// Pull natijasini lokal bazaga yozadi.
class PullApplier {
  const PullApplier({required AppDatabase db, required TimeSource time}) : this._(db, time);

  const PullApplier._(this._db, this._time);

  final AppDatabase _db;
  final TimeSource _time;

  /// **M36 tartibi:** `hos_policy` → kataloglar → `events` → `daily_logs` →
  /// `log_edit_requests` → `unidentified_events` → `chat` → kursor.
  ///
  /// Hammasi **bitta** Drift tranzaksiyasida: yarim qo'llangan holat bo'lmaydi
  /// (M35 — kursor faqat oxirida yoziladi).
  Future<void> apply({
    required Map<String, Object?>? hosPolicy,
    Map<String, Object?>? sessionProfile,
    required List<Map<String, Object?>> defectTypes,
    required List<Map<String, Object?>> quickNotes,
    required List<Map<String, Object?>> trailers,
    required List<Map<String, Object?>> events,
    required List<Map<String, Object?>> dailyLogs,
    required List<Map<String, Object?>> logEditRequests,
    required List<Map<String, Object?>> unidentifiedEvents,
    required List<Map<String, Object?>> chat,
    List<Map<String, Object?>> violations = const <Map<String, Object?>>[],
    required String nextSince,
  }) async {
    final DateTime now = _time.now();
    await _db.transaction(() async {
      if (hosPolicy != null && hosPolicy.isNotEmpty) {
        // M-HOS1: `payload` — `hos_engine.parsePolicy()` tushunadigan JSON
        // hujjat; transport uni kontraktdagi yassi obyektdan yig'adi.
        await _db.logsDao.upsertPolicy(
          HosPoliciesCompanion.insert(
            versionId: _str(hosPolicy, 'version_id') ?? 'unknown',
            effectiveFrom: _time0(hosPolicy, 'effective_from', now),
            payload: _policyDocument(hosPolicy),
          ),
        );
      }

      // Sessiya profili (`driver_name`, `carrier_name`, `home_terminal_*`, …)
      // — Home va oflayn Inspection Log Form shu kalitlardan o'qiydi.
      if (sessionProfile != null) {
        for (final MapEntry<String, Object?> entry in sessionProfile.entries) {
          final String value = entry.value?.toString() ?? '';
          if (value.isNotEmpty) {
            await _db.settingsDao.put(key: entry.key, value: value, now: now);
          }
        }
      }

      if (defectTypes.isNotEmpty) {
        await _db.refDao.replaceDefectTypes(
          defectTypes
              .map(
                (Map<String, Object?> m) => RefDefectTypesCompanion.insert(
                  id: _str(m, 'id') ?? '',
                  code: _str(m, 'code') ?? '',
                  label: _str(m, 'label') ?? '',
                  category: Value<String?>(_str(m, 'category')),
                  appliesTo: Value<String>(_str(m, 'applies_to') ?? 'vehicle'),
                  updatedAt: now,
                ),
              )
              .toList(growable: false),
        );
      }
      if (quickNotes.isNotEmpty) {
        await _db.refDao.replaceQuickNotes(
          quickNotes
              .map(
                (Map<String, Object?> m) => RefQuickNotesCompanion.insert(
                  id: _str(m, 'id') ?? '',
                  label: _str(m, 'text') ?? '',
                  category: Value<String?>(_str(m, 'category')),
                  updatedAt: now,
                ),
              )
              .toList(growable: false),
        );
      }
      if (trailers.isNotEmpty) {
        await _db.refDao.replaceTrailers(
          trailers
              .map(
                (Map<String, Object?> m) => RefTrailersCompanion.insert(
                  id: _str(m, 'id') ?? '',
                  number: _str(m, 'number') ?? '',
                  unitId: Value<String?>(_str(m, 'unit_id')),
                  updatedAt: now,
                ),
              )
              .toList(growable: false),
        );
      }

      // M31/M37: server versiyasi lokal ko'zguni almashtiradi.
      for (final Map<String, Object?> m in events) {
        final String? clientEventId = _str(m, 'client_event_id');
        if (clientEventId == null || clientEventId.isEmpty) {
          continue;
        }
        await _db.dutyEventsDao.upsertFromServer(
          DutyEventsCompanion.insert(
            clientEventId: clientEventId,
            eventType: _str(m, 'event_type') ?? 'status_change',
            eventTime: _time0(m, 'event_time', now),
            deviceSeq: _int(m, 'device_seq'),
            createdAt: now,
            serverId: Value<String?>(_str(m, 'id')),
            status: Value<String?>(_str(m, 'status')),
            special: Value<String>(_str(m, 'special') ?? 'none'),
            timeSource: Value<String>(_str(m, 'time_source') ?? 'server'),
            timeUnverified: Value<bool>(_bool(m, 'time_unverified')),
            clockSkewSec: Value<int>(_int(m, 'clock_skew_sec')),
            origin: Value<String>(_str(m, 'origin') ?? 'driver'),
            lat: Value<double?>(_double(m, 'lat')),
            lng: Value<double?>(_double(m, 'lng')),
            gpsAccuracyM: Value<double?>(_double(m, 'gps_accuracy_m')),
            locationText: Value<String?>(_str(m, 'location_text')),
            odometerM: Value<int?>(m['odometer_m'] == null ? null : _int(m, 'odometer_m')),
            engineHours: Value<double?>(_double(m, 'engine_hours')),
            speedKmh: Value<double?>(_double(m, 'speed_kmh')),
            notes: Value<String?>(_str(m, 'notes')),
            unitId: Value<String?>(_str(m, 'unit_id')),
            eldDeviceId: Value<String?>(_str(m, 'eld_device_id')),
            driverId: Value<String?>(_str(m, 'driver_id')),
            trailerIds: Value<List<String>>(_strings(m, 'trailer_ids')),
            shippingDocIds: Value<List<String>>(_strings(m, 'shipping_doc_ids')),
            syncState: const Value<String>('acked'),
            supersededBy: Value<String?>(_str(m, 'superseded_by')),
            locked: Value<bool>(_bool(m, 'locked')),
            logDate: Value<String?>(_str(m, 'log_date')),
          ),
        );
      }

      final String fallbackDriverId =
          _str(sessionProfile ?? const <String, Object?>{}, 'driver_id') ??
          await _db.settingsDao.get(KvKeys.driverId) ??
          '';
      for (final Map<String, Object?> m in dailyLogs) {
        await _db.logsDao.upsertLog(
          DailyLogsCompanion.insert(
            logDate: _str(m, 'log_date') ?? '',
            // `sync_dto.DailyLogSummary` da `driver_id` yo'q — sessiyadan.
            driverId: _str(m, 'driver_id') ?? fallbackDriverId,
            timezone: _str(m, 'timezone') ?? 'UTC',
            updatedAt: now,
            serverId: Value<String?>(_str(m, 'id')),
            certificationStatus: Value<String>(_str(m, 'certification_status') ?? 'uncertified'),
            signedAt: Value<DateTime?>(_dt(m, 'signed_at')),
            distanceM: Value<int>(_int(m, 'distance_m')),
            totals: Value<Map<String, Object?>>(_map(m, 'totals')),
            ready: Value<bool>(_bool(m, 'ready')),
          ),
        );
      }

      for (final Map<String, Object?> m in logEditRequests) {
        await _db.logsDao.upsertEditRequest(
          LogEditRequestsCompanion.insert(
            id: _str(m, 'id') ?? '',
            logDate: _str(m, 'log_date') ?? '',
            source: _str(m, 'source') ?? 'admin',
            status: _str(m, 'status') ?? 'pending',
            createdAt: _time0(m, 'created_at', now),
            dailyLogId: Value<String?>(_str(m, 'daily_log_id')),
            changes: Value<Map<String, Object?>>(_map(m, 'changes')),
          ),
        );
      }

      for (final Map<String, Object?> m in unidentifiedEvents) {
        await _db.logsDao.upsertUnidentified(
          UnidentifiedEventsCompanion.insert(
            id: _str(m, 'id') ?? '',
            unitId: _str(m, 'unit_id') ?? '',
            startAt: _time0(m, 'start_at', now),
            status: _str(m, 'status') ?? 'pending',
            endAt: Value<DateTime?>(_dt(m, 'end_at')),
            distanceM: Value<int>(_int(m, 'distance_m')),
          ),
        );
      }

      for (final Map<String, Object?> m in chat) {
        await _db.chatDao.upsertMessage(
          ChatMessagesCompanion.insert(
            id: _str(m, 'id') ?? '',
            kind: _str(m, 'kind') ?? 'text',
            createdAt: _time0(m, 'created_at', now),
            clientId: Value<String?>(_str(m, 'client_id')),
            conversationId: Value<String?>(_str(m, 'conversation_id')),
            senderId: Value<String?>(_str(m, 'sender_id')),
            body: Value<String?>(_str(m, 'text')),
            fileKey: Value<String?>(_str(m, 'file_key')),
            lat: Value<double?>(_double(m, 'lat')),
            lng: Value<double?>(_double(m, 'lng')),
            status: Value<String>(_str(m, 'status') ?? 'sent'),
          ),
        );
      }

      for (final Map<String, Object?> m in violations) {
        final String? id = _str(m, 'id');
        if (id == null || id.isEmpty) {
          continue;
        }
        await _db.logsDao.upsertViolation(
          ViolationsCompanion.insert(
            id: id,
            type: _str(m, 'type') ?? 'unknown',
            occurredAt: _time0(m, 'occurred_at', now),
            updatedAt: now,
            severity: Value<String>(_str(m, 'severity') ?? 'violation'),
            logDate: Value<String?>(_str(m, 'log_date')),
            dailyLogId: Value<String?>(_str(m, 'daily_log_id')),
            driverId: Value<String?>(_str(m, 'driver_id')),
            unitId: Value<String?>(_str(m, 'unit_id')),
            policyVersionId: Value<String?>(_str(m, 'policy_version_id')),
            details: Value<Map<String, Object?>>(_map(m, 'details')),
            resolvedAt: Value<DateTime?>(_dt(m, 'resolved_at')),
            resolvedReason: Value<String?>(_str(m, 'resolved_reason')),
          ),
        );
      }

      // M35: kursor **faqat** hamma narsa yozilgandan keyin.
      await _db.settingsDao.setNextSince(nextSince);
      await _db.settingsDao.markPull(now);
    });
  }

  DateTime _time0(Map<String, Object?> m, String key, DateTime fallback) => _dt(m, key) ?? fallback;

  /// Policy hujjati: transport `document` bo'limini beradi; eski/soddalashgan
  /// javoblar uchun `payload` satri yoki obyektning o'zi ishlatiladi.
  String _policyDocument(Map<String, Object?> policy) {
    final Object? document = policy['document'];
    if (document is Map<String, Object?>) {
      return jsonEncode(document);
    }
    final Object? payload = policy['payload'];
    if (payload is String && payload.isNotEmpty) {
      return payload;
    }
    if (payload is Map<String, Object?>) {
      return jsonEncode(payload);
    }
    return jsonEncode(<String, Object?>{...policy}..remove('version_id'));
  }
}
