/// Haydovchi almashganda lokal domen ma'lumotini tozalaydi (**S-M4**, §17.1).
///
/// Muammo: `chat_messages`, `dvir_*`, `files_queue`, `notifications` va
/// `log_edit_requests` jadvallarida `driver_id` ustuni yo'q, shuning uchun
/// ularni so'rovda filtrlab bo'lmaydi. Boshqa `user_id` login qilganda
/// oldingi haydovchining suhbatlari, DVIR fotolari va bildirishnomalari
/// ekranda ko'rinib qolar edi.
///
/// Yechim: sessiya almashganda **haydovchiga tegishli** jadvallar tozalanadi.
/// Server kanonik (M31) — yangi haydovchining ko'zgusi keyingi `sync/pull` da
/// qayta quriladi, shuning uchun bu yo'qotish emas.
///
/// **M17/M23 kafolati:** yuborilmagan navbat **hech qachon** o'chirilmaydi.
/// `outbox_items` butunligicha saqlanadi; `pending`/`inflight` element bilan
/// bog'langan biznes qatorlari (duty event, DVIR qoralamasi, chat navbati,
/// yuklanmagan fayl) ham qoldiriladi — aks holda element payload'i bor-u,
/// lokal ko'zgusi yo'q holat paydo bo'lardi.
library;

import 'package:drift/drift.dart';
import 'package:sync_core/sync_core.dart';

import 'app_database.dart';
import 'daos/settings_dao.dart';

/// Tozalash natijasi — diagnostika ekrani va testlar uchun.
class SessionResetReport {
  const SessionResetReport({
    required this.wiped,
    this.deletedRows = 0,
    this.preservedOutboxItems = 0,
  });

  /// `false` — bir xil haydovchi qayta kirdi, hech narsa o'chirilmadi.
  final bool wiped;

  /// O'chirilgan domen qatorlari soni (navbat kirmaydi).
  final int deletedRows;

  /// Saqlab qolingan yuborilmagan navbat elementlari (M17).
  final int preservedOutboxItems;

  @override
  String toString() =>
      'SessionResetReport(wiped: $wiped, deleted: $deletedRows, kept: $preservedOutboxItems)';
}

/// Sessiya almashuvida lokal bazani tozalovchi.
class SessionDataCleaner {
  const SessionDataCleaner(this._db);

  final AppDatabase _db;

  /// Login/logout oqimidan chaqiriladi.
  ///
  /// [driverId] — endi kirgan haydovchi (`logout` da `null`). `kv_settings`
  /// dagi oldingi `driver_id` bilan solishtiriladi: bir xil bo'lsa hech narsa
  /// qilinmaydi (oddiy qayta kirish), farq qilsa domen jadvallari tozalanadi.
  ///
  /// [stillSignedIn] — qurilmada **hali ham** sessiyasi bor haydovchilar
  /// (ikkala slot). Co-driver kabinada qolgan bo'lsa uning ma'lumoti
  /// o'chirilmaydi: bu haydovchi almashuvi emas, ikkinchi slotga login
  /// (`M-20` oqimi, tz-mobile §3.3).
  Future<SessionResetReport> switchDriver({
    required String? driverId,
    Set<String> stillSignedIn = const <String>{},
  }) async {
    final String? previous = await _db.settingsDao.get(KvKeys.driverId);
    if (previous == null || previous.isEmpty) {
      // Birinchi kirish — tozalash uchun hech narsa yo'q.
      return const SessionResetReport(wiped: false);
    }
    if (driverId != null && driverId == previous) {
      return const SessionResetReport(wiped: false);
    }
    if (stillSignedIn.contains(previous)) {
      return const SessionResetReport(wiped: false);
    }
    return wipe();
  }

  /// Domen jadvallarini so'zsiz tozalaydi (`switchDriver` ning ichki qismi).
  ///
  /// Bitta tranzaksiya: yo hammasi o'chadi, yo hech nima (yarim tozalangan
  /// baza ikki haydovchining ma'lumotini aralashtirib yuborardi).
  Future<SessionResetReport> wipe() => _db.transaction<SessionResetReport>(() async {
    final _LiveQueue live = await _liveQueue();
    int deleted = 0;

    // --- yuborilmagan navbat bilan bog'langan qatorlar saqlanadi (M17) ---
    deleted += await (_db.delete(
      _db.dutyEvents,
    )..where((DutyEvents t) => t.clientEventId.isNotIn(live.clientIds))).go();

    deleted += await (_db.delete(
      _db.dvirDrafts,
    )..where((DvirDrafts t) => t.clientId.isNotIn(live.clientIds))).go();

    deleted += await (_db.delete(
      _db.chatOutbox,
    )..where((ChatOutbox t) => t.clientId.isNotIn(live.clientIds))).go();

    // Faqat yuklab bo'lingan fayl o'chadi; yuklanmagani `certify`/`dvir`
    // navbatining bo'lagi (M149) va joyida qoladi.
    deleted += await (_db.delete(
      _db.filesQueue,
    )..where((FilesQueue t) => t.state.equals(_uploadedFileState))).go();

    // Yuborilmagan telemetriya ham navbat hisoblanadi.
    deleted += await (_db.delete(
      _db.telemetryBuffer,
    )..where((TelemetryBuffer t) => t.sent.equals(true))).go();

    // --- to'liq serverdan tiklanadigan ko'zgular ---
    for (final TableInfo<Table, Object> table in <TableInfo<Table, Object>>[
      _db.dailyLogs,
      _db.hosStates,
      _db.violations,
      _db.chatMessages,
      _db.notifications,
      _db.dvirReports,
      _db.logEditRequests,
      _db.unidentifiedEvents,
      _db.refDefectTypes,
      _db.refQuickNotes,
      _db.refTrailers,
    ]) {
      deleted += await _db.delete(table).go();
    }

    // --- PII `kv_settings` da qolmasin ---
    for (final String key in KvKeys.sessionProfile) {
      await _db.settingsDao.remove(key);
    }

    // Kursor yangi haydovchining oynasidan boshlanadi (M35).
    await _db.settingsDao.resetCursor();

    return SessionResetReport(
      wiped: true,
      deletedRows: deleted,
      preservedOutboxItems: live.clientIds.length,
    );
  });

  /// Hali serverga yetmagan navbat elementlarining `client_id` lari.
  Future<_LiveQueue> _liveQueue() async {
    final List<OutboxItemRow> rows =
        await (_db.select(_db.outboxItems)..where(
              ($OutboxItemsTable t) =>
                  t.state.equals(OutboxState.pending.wire) |
                  t.state.equals(OutboxState.inflight.wire),
            ))
            .get();
    return _LiveQueue(rows.map((OutboxItemRow r) => r.clientId).toList(growable: false));
  }
}

/// `files_queue` ning yakuniy holati — bunday qator navbatga bog'liq emas.
const String _uploadedFileState = 'uploaded';

class _LiveQueue {
  const _LiveQueue(this.clientIds);

  final List<String> clientIds;
}
