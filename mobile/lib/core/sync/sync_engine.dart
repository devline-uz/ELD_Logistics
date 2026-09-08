/// Bitta sync sikli: vaqt → push → pull → kursor (§6.3, M38).
library;

import 'dart:async';

import 'package:sync_core/sync_core.dart';

import '../db/app_database.dart';
import '../security/secure_vault.dart';
import '../time/clock_verdict.dart';
import '../time/time_source.dart';
import 'outbox_repository.dart';
import 'pull_applier.dart';
import 'session_slot.dart';
import 'sync_transport.dart';

/// Push timeouti: haydash rejimida qisqaroq (M33.4).
const Duration kPushTimeout = Duration(seconds: 30);
const Duration kPushTimeoutDriving = Duration(seconds: 15);

/// `truncated` drenaj sikli chegarasi (M35).
const int kMaxPullIterations = 20;

/// Sikl natijasi — scheduler backoff qarorini shundan oladi.
class SyncCycleResult {
  const SyncCycleResult({
    required this.ok,
    this.pushedItems = 0,
    this.acceptedItems = 0,
    this.rejectedItems = 0,
    this.pulledBatches = 0,
    this.errorCode,
    this.retryAfter,
    this.forbidden = false,
  });

  final bool ok;
  final int pushedItems;
  final int acceptedItems;
  final int rejectedItems;
  final int pulledBatches;
  final String? errorCode;
  final Duration? retryAfter;

  /// `403` — M34 hisoblagichini oshiradi.
  final bool forbidden;
}

/// Qurilma konteksti — M5 da `device`/`session` provayderlaridan keladi.
class SyncContext {
  const SyncContext({
    required this.deviceId,
    required this.appVersion,
    this.unitId,
    this.activeSlot = DriverSlot.primary,
    this.driving = false,
    this.metered = false,
  });

  final String deviceId;
  final String appVersion;
  final String? unitId;

  /// **B-120:** ekranda turgan haydovchi. Uning navbati birinchi yuboriladi,
  /// telemetriya (qurilma darajasidagi ma'lumot) ham shu sessiyadan ketadi.
  final DriverSlot activeSlot;

  /// Haydash rejimi: timeout 15 s, taymer 30 s.
  final bool driving;

  /// Mobil (metered) tarmoq: telemetriya ≤1000 nuqta (M27).
  final bool metered;

  BatchLimits get limits => metered ? const BatchLimits.metered() : const BatchLimits.standard();

  Duration get pushTimeout => driving ? kPushTimeoutDriving : kPushTimeout;
}

/// Push/pull siklini bajaradi. Trigger va backoff — [SyncScheduler] zimmasida.
class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required OutboxRepository outbox,
    required SyncTransport transport,
    required TimeSource time,
    SlotTokenProbe? slotTokens,
  }) : this._(db, outbox, transport, time, PullApplier(db: db, time: time), slotTokens);

  SyncEngine._(
    this._db,
    this._outbox,
    this._transport,
    this._time,
    this._applier,
    this._slotTokens,
  );

  final AppDatabase _db;
  final OutboxRepository _outbox;
  final SyncTransport _transport;
  final TimeSource _time;
  final PullApplier _applier;

  /// **B-120:** qaysi slotda tirik sessiya borligini bildiradi. `null` — darvoza
  /// yo'q (testlar va dev mock): barcha slotlar yuboriladi.
  final SlotTokenProbe? _slotTokens;

  /// §6.3 ning 1–6 qadamlari **shu tartibda**; push'dan oldin pull qilinmaydi (M38).
  Future<SyncCycleResult> runCycle(SyncContext context) async {
    try {
      final _PushSummary push = await _push(context);
      final int batches = await _pullDrain(context);
      await _db.settingsDao.clearError();
      return SyncCycleResult(
        ok: true,
        pushedItems: push.sent,
        acceptedItems: push.accepted,
        rejectedItems: push.rejected,
        pulledBatches: batches,
      );
    } on SyncTransportException catch (e) {
      await _db.settingsDao.markError(code: e.code, at: _time.now());
      return SyncCycleResult(
        ok: false,
        errorCode: e.code,
        retryAfter: e.retryAfter,
        forbidden: e.isForbidden,
      );
    } on TimeoutException {
      await _db.settingsDao.markError(code: 'CLIENT_TIMEOUT', at: _time.now());
      return const SyncCycleResult(ok: false, errorCode: 'CLIENT_TIMEOUT');
    }
  }

  // --- push ---------------------------------------------------------------

  /// **B-120:** navbat `session_slot` bo'yicha guruhlanadi va har guruh
  /// **o'z** haydovchisining tokeni bilan yuboriladi. Tokeni yo'q slotning
  /// navbati tegilmaydi — u `pending` bo'lib qoladi (M17/M23).
  Future<_PushSummary> _push(SyncContext context) async {
    final DateTime now = _time.now();
    final Set<int>? allowed = await _allowedSlots();
    final List<OutboxRecord> candidates = await _db.outboxDao.dueRecords(now: now, slots: allowed);
    final int activeSlot = slotColumn(context.activeSlot);

    final List<SlotBatch> groups = selectBatchesBySlot(
      candidates: candidates,
      now: now,
      limits: context.limits,
      allowedSlots: allowed,
      firstSlot: activeSlot,
    );

    // Telemetriya qurilma darajasida — faol slot sessiyasidan ketadi.
    final List<TelemetryRow> telemetry = allowed == null || allowed.contains(activeSlot)
        ? await _db.telemetryDao.unsent(limit: context.limits.telemetry)
        : const <TelemetryRow>[];

    final List<_PushJob> jobs = _jobs(groups: groups, telemetry: telemetry, activeSlot: activeSlot);
    if (jobs.isEmpty) {
      return const _PushSummary(sent: 0, accepted: 0, rejected: 0);
    }

    _PushSummary total = const _PushSummary(sent: 0, accepted: 0, rejected: 0);
    Object? failure;
    StackTrace? trace;
    for (final _PushJob job in jobs) {
      try {
        total = total + await _sendBatch(context, job.slot, job.batch, job.telemetry);
      } on Object catch (error, stack) {
        failure ??= error;
        trace ??= stack;
        // Tarmoq umuman yo'q bo'lsa qolgan slotlarni urinish behuda; server
        // javob bergan bo'lsa (401/403/422) — ikkinchi slot hali ishlashi
        // mumkin, shuning uchun sikl davom etadi.
        if (!_isSlotScoped(error)) {
          break;
        }
      }
    }
    if (failure != null) {
      Error.throwWithStackTrace(failure, trace!);
    }
    return total;
  }

  /// Guruhlarni yuboriladigan ishlarga aylantiradi; telemetriya faol slot
  /// ishiga qo'shiladi, faol slotda navbat bo'lmasa — alohida ish.
  List<_PushJob> _jobs({
    required List<SlotBatch> groups,
    required List<TelemetryRow> telemetry,
    required int activeSlot,
  }) {
    final List<_PushJob> jobs = <_PushJob>[
      for (final SlotBatch group in groups)
        _PushJob(
          slot: slotFromColumn(group.sessionSlot),
          batch: group.batch,
          telemetry: group.sessionSlot == activeSlot ? telemetry : const <TelemetryRow>[],
        ),
    ];
    final bool telemetryPlaced = groups.any((SlotBatch g) => g.sessionSlot == activeSlot);
    if (telemetry.isNotEmpty && !telemetryPlaced) {
      jobs.add(
        _PushJob(
          slot: slotFromColumn(activeSlot),
          batch: const OutboxBatch.empty(),
          telemetry: telemetry,
        ),
      );
    }
    return jobs;
  }

  /// Tokeni bor slotlar. Zond berilmagan bo'lsa `null` — darvoza yo'q.
  Future<Set<int>?> _allowedSlots() async {
    final SlotTokenProbe? probe = _slotTokens;
    return probe == null ? null : resolveAllowedSlots(probe);
  }

  /// Xato faqat shu slotga tegishlimi (server javob berdi) yoki umumiy
  /// tarmoq muammosimi.
  static bool _isSlotScoped(Object error) =>
      error is SyncTransportException && error.statusCode != null;

  Future<_PushSummary> _sendBatch(
    SyncContext context,
    DriverSlot slot,
    OutboxBatch batch,
    List<TelemetryRow> telemetry, {
    bool retriedAfterConflict = false,
  }) async {
    final DateTime now = _time.now();
    final List<int> ids = batch.items.map((OutboxRecord i) => i.id).toList(growable: false);

    // M33.6: mavjud kalit saqlanadi — timeout dan keyin aynan o'sha ketadi.
    final String key = _stableKey(batch);
    await _db.outboxDao.markInflight(ids: ids, idempotencyKey: key, now: now);

    final Map<OutboxKind, List<Map<String, Object?>>> byKind = _groupPayloads(batch);
    final PushRequest request = PushRequest(
      deviceId: context.deviceId,
      appVersion: context.appVersion,
      unitId: context.unitId,
      slot: slot,
      idempotencyKey: key,
      phoneTime: _time.phoneNow(),
      eldRtcTime: _time.source == EventTimeSource.eldRtc ? _time.now() : null,
      events: byKind[OutboxKind.event] ?? const <Map<String, Object?>>[],
      dvir: byKind[OutboxKind.dvir] ?? const <Map<String, Object?>>[],
      chat: byKind[OutboxKind.chat] ?? const <Map<String, Object?>>[],
      other: <OtherPushItem>[
        for (final OutboxRecord item in batch.items)
          if (item.kind != OutboxKind.event &&
              item.kind != OutboxKind.dvir &&
              item.kind != OutboxKind.chat)
            OtherPushItem(kind: item.kind, clientId: item.clientId, payload: decodePayload(item)),
      ],
      telemetry: telemetry.map(_telemetryPayload).toList(growable: false),
    );

    try {
      final PushResponse response = await _transport.push(request, timeout: context.pushTimeout);

      final ClockVerdictSink sink = _applyClock(response);
      final Map<String, PushOutcome> outcomes = <String, PushOutcome>{
        for (final PushItemResult item in response.items)
          item.clientId: resolvePushResult(
            result: PushResultKind.fromWire(item.result),
            reason: item.reason,
            supersededBy: item.supersededBy,
          ),
      };
      await _outbox.applyPushOutcomes(outcomes);
      await _db.telemetryDao.markSent(
        telemetry.map((TelemetryRow r) => r.id).toList(growable: false),
      );
      await _db.settingsDao.markPush(_time.now());
      _time.syncFromServer(response.serverTime);

      final int rejected = outcomes.values
          .where((PushOutcome o) => o.outcome == OutboxOutcome.rejected)
          .length;
      return _PushSummary(
        sent: batch.length + telemetry.length,
        accepted: outcomes.length - rejected + sink.telemetryAccepted,
        rejected: rejected,
      );
    } on SyncTransportException catch (e) {
      if (e.isIdempotencyConflict && !retriedAfterConflict) {
        // M33.7: kalit boshqa payload bilan ishlatilgan — yangi kalit, qayta yig'ish.
        await _db.outboxDao.resetIdempotencyKey(ids: ids, now: _time.now());
        return _sendBatch(context, slot, batch, telemetry, retriedAfterConflict: true);
      }
      if (e.isPayloadTooLarge && batch.length > 1) {
        // §6.1: batchni ikkiga bo'lib qayta urinish (rekursiv, min 1 element).
        final List<OutboxBatch> halves = splitBatch(batch);
        await _releaseInflight(ids, e.code);
        _PushSummary total = const _PushSummary(sent: 0, accepted: 0, rejected: 0);
        for (final OutboxBatch half in halves) {
          total = total + await _sendBatch(context, slot, half, const <TelemetryRow>[]);
        }
        return total;
      }
      // M33.6: element `inflight` da osilib qolmaydi — `pending` ga qaytadi,
      // `idempotency_key` esa **saqlanadi** (server 24 soat replay qiladi).
      await _releaseInflight(ids, e.code);
      rethrow;
    } on TimeoutException {
      await _releaseInflight(ids, 'CLIENT_TIMEOUT');
      rethrow;
    } on Object {
      // DB/parse xatosi ham navbatni bloklamasligi kerak (0 event yo'qotish).
      await _releaseInflight(ids, 'CLIENT_ERROR');
      rethrow;
    }
  }

  /// `inflight → pending`, kalit saqlanadi; aniq kechikishni scheduler
  /// [deferQueue] orqali yozadi.
  Future<void> _releaseInflight(List<int> ids, String code) async {
    final DateTime now = _time.now();
    await _db.outboxDao.releaseInflight(ids: ids, nextAttemptAt: now, now: now, lastError: code);
  }

  /// Backoff kechikishini navbatga yozadi (§5.4).
  Future<void> deferQueue(DateTime until) =>
      _db.outboxDao.deferPending(until: until, now: _time.now());

  /// `Retry now`: kechikish bekor qilinadi (M28).
  Future<void> releaseQueueNow() => _db.outboxDao.releaseQueueNow(_time.now());

  /// Batchdagi barcha elementlar bir xil saqlangan kalitga ega bo'lsa — o'sha
  /// kalit; aks holda yangisi (M33.3/M33.6).
  String _stableKey(OutboxBatch batch) {
    final Set<String?> keys = batch.items.map((OutboxRecord i) => i.idempotencyKey).toSet();
    if (keys.length == 1) {
      final String? existing = keys.first;
      if (existing != null && existing.isNotEmpty) {
        return existing;
      }
    }
    return _outbox.newIdempotencyKey();
  }

  Map<OutboxKind, List<Map<String, Object?>>> _groupPayloads(OutboxBatch batch) {
    final Map<OutboxKind, List<Map<String, Object?>>> byKind =
        <OutboxKind, List<Map<String, Object?>>>{};
    for (final OutboxRecord item in batch.items) {
      byKind.putIfAbsent(item.kind, () => <Map<String, Object?>>[]).add(decodePayload(item));
    }
    return byKind;
  }

  ClockVerdictSink _applyClock(PushResponse response) {
    final ClockVerdict? verdict = response.clock;
    if (verdict != null) {
      _time.applyVerdict(verdict); // M39: server verdikti kanonik.
    }
    return ClockVerdictSink(telemetryAccepted: response.telemetryAccepted);
  }

  // --- pull ---------------------------------------------------------------

  Future<int> _pullDrain(SyncContext context) async {
    int iterations = 0;
    bool more = true;
    while (more && iterations < kMaxPullIterations) {
      final SyncCursorRow? cursor = await _db.settingsDao.cursor();
      final PullResponse response = await _transport.pull(
        since: cursor?.nextSince,
        unitId: context.unitId,
        // M31: pull faol haydovchining lokal ko'zgusini qayta quradi.
        slot: context.activeSlot,
        timeout: context.pushTimeout,
      );
      await _applier.apply(
        hosPolicy: response.hosPolicy,
        sessionProfile: response.sessionProfile,
        defectTypes: response.defectTypes,
        quickNotes: response.quickNotes,
        trailers: response.trailers,
        events: response.events,
        dailyLogs: response.dailyLogs,
        logEditRequests: response.logEditRequests,
        unidentifiedEvents: response.unidentifiedEvents,
        chat: response.chat,
        violations: response.violations,
        nextSince: response.nextSince,
      );
      _time.syncFromServer(response.serverTime);
      iterations++;
      more = response.truncated;
    }
    return iterations;
  }
}

/// Telemetriya hisobini push xulosasiga olib o'tuvchi kichik konteyner.
class ClockVerdictSink {
  const ClockVerdictSink({required this.telemetryAccepted});

  final int telemetryAccepted;
}

/// Bitta slot uchun yuboriladigan ish.
class _PushJob {
  const _PushJob({required this.slot, required this.batch, required this.telemetry});

  final DriverSlot slot;
  final OutboxBatch batch;
  final List<TelemetryRow> telemetry;
}

class _PushSummary {
  const _PushSummary({required this.sent, required this.accepted, required this.rejected});

  final int sent;
  final int accepted;
  final int rejected;

  _PushSummary operator +(_PushSummary other) => _PushSummary(
    sent: sent + other.sent,
    accepted: accepted + other.accepted,
    rejected: rejected + other.rejected,
  );
}

Map<String, Object?> _telemetryPayload(TelemetryRow row) => compactPayload(<String, Object?>{
  'ts': row.ts.toIso8601String(),
  'unit_id': row.unitId,
  'lat': row.lat,
  'lng': row.lng,
  'speed_kmh': row.speedKmh,
  'heading_deg': row.headingDeg,
  'odometer_m': row.odometerM,
  'engine_hours': row.engineHours,
  'ignition': row.ignition,
  'fuel_pct': row.fuelPct,
  'disconnected': row.disconnected,
  'duty_status': row.dutyStatus,
  'driver_id': row.driverId,
});
