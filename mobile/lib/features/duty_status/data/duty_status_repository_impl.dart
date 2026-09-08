/// `DutyStatusRepository` ning Drift + outbox implementatsiyasi (M24).
///
/// Bu qatlam **yagona** yozuvchi: `OutboxRepository.enqueueDutyEvent` biznes
/// yozuvi va navbatni bitta tranzaksiyada yozadi, shuning uchun oflayn
/// stsenariy ham, sinxronlangan stsenariy ham bir xil yo'ldan yuradi.
library;

import 'dart:convert';

import 'package:hos_engine/hos_engine.dart';
import 'package:sync_core/sync_core.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/duty_events_dao.dart';
import '../../../core/db/daos/logs_dao.dart';
import '../../../core/db/daos/ref_dao.dart';
import '../../../core/db/daos/settings_dao.dart';
import '../../../core/sync/outbox_repository.dart';
import '../../../core/time/day_boundary.dart';
import '../../../core/time/time_source.dart';
import '../domain/duty_status_models.dart';
import '../domain/duty_status_repository.dart';
import '../domain/duty_status_rules.dart';

/// `kv_settings` kalitlari — `sync/pull` haydovchi/unit profilini shu yerga
/// yozadi (M5 bosqichi). Kalitlar `core/db` dagi `KvKeys` ni to'ldiradi.
abstract final class DutyKvKeys {
  const DutyKvKeys._();

  static const String driverId = 'driver_id';
  static const String driverName = 'driver_name';
  static const String driverEmail = 'driver_email';
  static const String driverPhone = 'driver_phone';
  static const String driverLicense = 'driver_license';
  static const String driverLicenseState = 'driver_license_state';
  static const String unitId = 'unit_id';
  static const String unitNumber = 'unit_number';
  static const String vehicleLabel = 'vehicle_label';

  /// Oxirgi ishlatilgan shipping document raqamlari (JSON massiv).
  static const String recentShippingDocs = 'recent_shipping_docs';

  /// Joriy smenaning shipping document raqamlari (JSON massiv).
  static const String currentShippingDocs = 'current_shipping_docs';
}

class DriftDutyStatusRepository implements DutyStatusRepository {
  DriftDutyStatusRepository({
    required DutyEventsDao events,
    required LogsDao logs,
    required SettingsDao settings,
    required OutboxRepository outbox,
    required TimeSource time,
  }) : this._(events, logs, settings, outbox, time);

  const DriftDutyStatusRepository._(
    this._events,
    this._logs,
    this._settings,
    this._outbox,
    this._time,
  );

  final DutyEventsDao _events;
  final LogsDao _logs;
  final SettingsDao _settings;
  final OutboxRepository _outbox;
  final TimeSource _time;

  @override
  Stream<DutyStatusContext> watchContext() =>
      _events.watchRecent(limit: 100).asyncMap(_buildContext);

  @override
  Future<DutyStatusContext> context() async {
    final DateTime now = _time.now();
    final List<DutyEventRow> rows = await _events.range(
      from: now.subtract(const Duration(days: 2)),
      to: now.add(const Duration(minutes: 1)),
    );
    return _buildContext(rows.reversed.toList(growable: false));
  }

  @override
  Future<List<HosEvent>> hosEvents({required DateTime now}) async {
    final HosPolicy policy = await _policy(now);
    final DateTime from = now.toUtc().subtract(Duration(days: policy.cycleDays + 1));
    final List<DutyEventRow> rows = await _events.range(
      from: from,
      to: now.toUtc().add(const Duration(minutes: 1)),
    );
    return _toHosEvents(rows);
  }

  @override
  Future<List<HosEvent>> dayEvents({
    required DateTime dayStartUtc,
    required DateTime dayEndUtc,
  }) async {
    final List<DutyEventRow> rows = await _events.range(
      // Kun boshidagi ochiq statusni ushlash uchun bir kun oldindan olamiz.
      from: dayStartUtc.toUtc().subtract(const Duration(days: 2)),
      to: dayEndUtc.toUtc(),
    );
    return _toHosEvents(rows);
  }

  @override
  Future<DutyChangeResult> changeStatus({
    required DutyStatusDraft draft,
    required EventOrigin origin,
    DateTime? at,
    double? speedKmh,
    int? odometerM,
    double? engineHours,
  }) async {
    final String? driverId = await _settings.get(DutyKvKeys.driverId);
    final String? unitId = await _settings.get(DutyKvKeys.unitId);
    final String tzName = await _settings.get(KvKeys.homeTerminalTz) ?? kFallbackTimeZone;
    final DateTime when = at ?? _time.now();

    final EnqueuedEvent enqueued = await _outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      status: draft.status.wire,
      special: draft.special.wire,
      origin: origin,
      eventTime: when,
      driverId: driverId,
      unitId: unitId,
      lat: draft.lat,
      lng: draft.lng,
      gpsAccuracyM: draft.accuracyM,
      locationText: draft.locationText.isEmpty ? null : draft.locationText,
      odometerM: odometerM,
      engineHours: engineHours,
      speedKmh: speedKmh,
      notes: dutyEventNotes(draft),
      trailerIds: draft.trailerIds,
      shippingDocIds: draft.shippingDocIds,
      logDate: logDateOf(when, tzName),
    );
    return DutyChangeResult(clientEventId: enqueued.clientEventId, eventTime: enqueued.eventTime);
  }

  @override
  Future<DutyChangeResult> updateDocuments({
    required List<String> trailerIds,
    required List<String> shippingDocIds,
    String? notes,
  }) async {
    final DutyStatusContext current = await context();
    final String? driverId = await _settings.get(DutyKvKeys.driverId);
    final String? unitId = await _settings.get(DutyKvKeys.unitId);
    final DateTime when = _time.now();
    final String tzName = await _settings.get(KvKeys.homeTerminalTz) ?? kFallbackTimeZone;

    // M53: `status_change` semantikasi, status **o'zgarmaydi**.
    final EnqueuedEvent enqueued = await _outbox.enqueueDutyEvent(
      eventType: SyncEventType.statusChange,
      status: current.current?.wire,
      special: current.special.wire,
      origin: EventOrigin.driver,
      eventTime: when,
      driverId: driverId,
      unitId: unitId,
      notes: (notes ?? '').trim().isEmpty ? null : notes!.trim(),
      trailerIds: trailerIds,
      shippingDocIds: shippingDocIds,
      logDate: logDateOf(when, tzName),
    );
    await _settings.put(
      key: DutyKvKeys.currentShippingDocs,
      value: jsonEncode(shippingDocIds),
      now: when,
    );
    return DutyChangeResult(clientEventId: enqueued.clientEventId, eventTime: enqueued.eventTime);
  }

  @override
  Future<DutyChangeResult> recordIntermediate({
    double? lat,
    double? lng,
    int? odometerM,
    double? engineHours,
    double? speedKmh,
  }) async {
    final String? driverId = await _settings.get(DutyKvKeys.driverId);
    final String? unitId = await _settings.get(DutyKvKeys.unitId);
    final DateTime when = _time.now();
    final String tzName = await _settings.get(KvKeys.homeTerminalTz) ?? kFallbackTimeZone;

    final EnqueuedEvent enqueued = await _outbox.enqueueDutyEvent(
      eventType: SyncEventType.intermediate,
      origin: EventOrigin.auto,
      eventTime: when,
      driverId: driverId,
      unitId: unitId,
      lat: lat,
      lng: lng,
      odometerM: odometerM,
      engineHours: engineHours,
      speedKmh: speedKmh,
      logDate: logDateOf(when, tzName),
    );
    return DutyChangeResult(clientEventId: enqueued.clientEventId, eventTime: enqueued.eventTime);
  }

  Future<HosPolicy> _policy(DateTime at) async {
    final HosPolicyRow? row = await _logs.policyAt(at);
    if (row == null) {
      return defaultPolicy();
    }
    final Object? decoded = jsonDecode(row.payload);
    if (decoded is! Map<String, Object?>) {
      return defaultPolicy();
    }
    return parsePolicy(Map<String, dynamic>.from(decoded));
  }

  Future<DriverContext> _driver() async {
    final Map<String, String?> values = <String, String?>{
      for (final String key in <String>[
        DutyKvKeys.driverId,
        DutyKvKeys.driverName,
        DutyKvKeys.driverEmail,
        DutyKvKeys.driverPhone,
        DutyKvKeys.driverLicense,
        DutyKvKeys.driverLicenseState,
        DutyKvKeys.unitId,
        DutyKvKeys.unitNumber,
        DutyKvKeys.vehicleLabel,
        KvKeys.homeTerminalTz,
      ])
        key: await _settings.get(key),
    };
    return DriverContext(
      driverId: values[DutyKvKeys.driverId] ?? '',
      driverName: values[DutyKvKeys.driverName] ?? '',
      email: values[DutyKvKeys.driverEmail],
      phone: values[DutyKvKeys.driverPhone],
      licenseNumber: values[DutyKvKeys.driverLicense],
      licenseState: values[DutyKvKeys.driverLicenseState],
      unitId: values[DutyKvKeys.unitId] ?? '',
      unitNumber: values[DutyKvKeys.unitNumber] ?? '',
      vehicleLabel: values[DutyKvKeys.vehicleLabel] ?? '',
      homeTerminalTz: values[KvKeys.homeTerminalTz] ?? kFallbackTimeZone,
    );
  }

  /// [rows] — vaqt **kamayish** tartibida (eng yangisi birinchi).
  Future<DutyStatusContext> _buildContext(List<DutyEventRow> rows) async {
    final DateTime now = _time.now();
    final HosPolicy policy = await _policy(now);
    final DriverContext driver = await _driver();

    DutyEventRow? last;
    for (final DutyEventRow row in rows) {
      if (row.eventType == SyncEventType.statusChange.wire ||
          row.eventType == SyncEventType.dutyStatus.wire) {
        last = row;
        break;
      }
    }
    if (last == null) {
      return DutyStatusContext(policy: policy, driver: driver);
    }
    return DutyStatusContext(
      policy: policy,
      driver: driver,
      current: DutyStatusValue.tryParse(last.status),
      special: DutySpecial.parse(last.special),
      since: last.eventTime,
      trailerIds: last.trailerIds,
      shippingDocIds: last.shippingDocIds,
      notes: last.notes ?? '',
      locationText: last.locationText ?? '',
    );
  }

  List<HosEvent> _toHosEvents(List<DutyEventRow> rows) => <HosEvent>[
    for (final DutyEventRow row in rows)
      HosEvent(
        time: row.eventTime,
        status: DutyStatus.tryParse(row.status),
        special: Special.parse(row.special),
        type: row.eventType,
      ),
  ];
}

/// Kataloglar: quick notes va trailerlar `ref_*` jadvallaridan.
class DriftDutyCatalogRepository implements DutyCatalogRepository {
  DriftDutyCatalogRepository({
    required RefDao ref,
    required SettingsDao settings,
    required TimeSource time,
  }) : this._(ref, settings, time);

  const DriftDutyCatalogRepository._(this._ref, this._settings, this._time);

  final RefDao _ref;
  final SettingsDao _settings;
  final TimeSource _time;

  @override
  Stream<List<QuickNoteOption>> watchQuickNotes() => _ref.watchQuickNotes().map(
    (List<RefQuickNoteRow> rows) => <QuickNoteOption>[
      for (final RefQuickNoteRow row in rows) QuickNoteOption(id: row.id, label: row.label),
    ],
  );

  @override
  Stream<List<TrailerOption>> watchTrailers() => _ref.watchTrailers().map(
    (List<RefTrailerRow> rows) => <TrailerOption>[
      for (final RefTrailerRow row in rows) TrailerOption(id: row.id, number: row.number),
    ],
  );

  @override
  Future<List<String>> recentShippingDocs() async {
    final String? raw = await _settings.get(DutyKvKeys.recentShippingDocs);
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }
    final Object? decoded = jsonDecode(raw);
    return decoded is List<Object?>
        ? <String>[for (final Object? item in decoded) '$item']
        : const <String>[];
  }

  @override
  Future<void> rememberShippingDoc(String number) async {
    final String trimmed = number.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final List<String> current = await recentShippingDocs();
    final List<String> next = <String>[
      trimmed,
      ...current.where((String value) => value != trimmed),
    ].take(10).toList(growable: false);
    await _settings.put(
      key: DutyKvKeys.recentShippingDocs,
      value: jsonEncode(next),
      now: _time.now(),
    );
  }
}
