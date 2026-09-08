/// Sertifikatsiyaning oflayn-first implementatsiyasi (M128).
///
/// Kunlar lokal `daily_logs` dan o'qiladi; `certify` **doim** outbox orqali
/// ketadi (`kind=certify`), imzo esa `files_queue` ga tushadi — tarmoq
/// qaytganda avval fayl yuklanadi, keyin `POST /daily-logs/{id}/certify`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sync_core/sync_core.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/dvir_dao.dart';
import '../../../core/db/daos/logs_dao.dart';
import '../../../core/db/daos/settings_dao.dart';
import '../../../core/files/signature_file_store.dart';
import '../../../core/sync/outbox_repository.dart';
import '../../../core/time/day_boundary.dart';
import '../../../core/time/time_source.dart';
import '../../../core/util/stream_combine.dart';
import '../domain/certify_models.dart';
import '../domain/certify_repository.dart';

/// `files_queue.kind` (§16) — yagona manba `core/files` da (#B-33).
final String kCertifySignatureKind = kSignatureFileKind;

/// Saqlangan imzo (`Save my signature`) KV kalitlari.
const String kSavedSignatureIdKey = 'certify.signature_id';
const String kSavedSignaturePathKey = 'certify.signature_path';

class DriftCertifyRepository implements CertifyRepository {
  DriftCertifyRepository({
    required this._db,
    required this._logs,
    required this._settings,
    required this._outbox,
    required this._signatures,
    required this._time,
    required this._driverId,
    this._timeZone = kFallbackTimeZone,
  });

  final AppDatabase _db;
  final LogsDao _logs;
  final SettingsDao _settings;
  final OutboxRepository _outbox;
  final SignatureStore _signatures;
  final TimeSource _time;
  final String _driverId;

  /// Home Terminal IANA zonasi — kun chegarasi **faqat** shundan (M42, #B-32).
  final String _timeZone;

  @override
  Stream<List<CertifyDay>> watchWindow({int days = kCertificationWindowDays}) {
    // #B-32: kunlar Home Terminal TZ kalendarida sanaladi. `subtract(1 kun)`
    // DST chegarasida 23/25 soatga tushib kunni siljitardi.
    final List<String> keys = recentLogDates(now: _time.now(), timeZoneName: _timeZone, days: days);
    return combineLatest2<List<DailyLogRow>, Set<String>, List<CertifyDay>>(
      _logs.watchRecentLogs(driverId: _driverId, days: days * 2),
      _watchPendingCertifyDates(),
      (List<DailyLogRow> rows, Set<String> pending) {
        final Map<String, DailyLogRow> byDate = <String, DailyLogRow>{
          for (final DailyLogRow row in rows) row.logDate: row,
        };
        final List<CertifyDay> result = <CertifyDay>[
          for (final String key in keys) _dayOf(calendarDateOf(key), byDate[key], pending),
        ];
        result.sort((CertifyDay a, CertifyDay b) {
          final int byPriority = a.sortPriority.compareTo(b.sortPriority);
          return byPriority != 0 ? byPriority : b.date.compareTo(a.date);
        });
        return result;
      },
    );
  }

  @override
  Stream<CertifyDay> watchDay(DateTime date) {
    // [date] — allaqachon Home Terminal kalendar sanasi (marshrutdan).
    final DateTime day = normalizeCalendarDate(date);
    return combineLatest2<DailyLogRow?, Set<String>, CertifyDay>(
      _logs.watchLog(driverId: _driverId, logDate: formatLogDate(day)),
      _watchPendingCertifyDates(),
      (DailyLogRow? row, Set<String> pending) => _dayOf(day, row, pending),
    );
  }

  @override
  Future<CertifyOutcome> certify({
    required List<DateTime> dates,
    required SignatureInput signature,
  }) async {
    if (dates.isEmpty || signature.isEmpty) {
      return const CertifyOutcome(queued: <DateTime>[], failed: <DateTime, String>{});
    }

    // M126: bitta imzo — barcha kunlar uchun bitta `signature_key`.
    String? localPath;
    final String? signatureId = signature.savedSignatureId;
    if (signature.png != null) {
      localPath = await _signatures.enqueue(signature.png!, remember: signature.save);
    }

    final String? deviceId = await _settings.get(KvKeys.deviceId);
    final List<DateTime> queued = <DateTime>[];
    final Map<DateTime, String> failed = <DateTime, String>{};

    for (final DateTime raw in dates) {
      final DateTime date = normalizeCalendarDate(raw);
      final DailyLogRow? row = await _logs
          .watchLog(driverId: _driverId, logDate: formatLogDate(date))
          .first;
      if (row != null && !row.ready) {
        // M125: `ready` — serverning maydoni; mobil o'zi hisoblamaydi.
        failed[date] = 'LOG_NOT_READY';
        continue;
      }
      await _outbox.enqueue(
        kind: OutboxKind.certify,
        userId: _driverId,
        payload: compactPayload(<String, Object?>{
          'log_date': formatLogDate(date),
          'daily_log_id': row?.serverId,
          'signature_id': signatureId,
          'signature_local_path': localPath,
          'device_id': deviceId,
        }),
      );
      queued.add(date);
    }

    return CertifyOutcome(queued: queued, failed: failed);
  }

  // --- ichki ---------------------------------------------------------------

  CertifyDay _dayOf(DateTime date, DailyLogRow? row, Set<String> pending) {
    final String key = formatLogDate(date);
    if (pending.contains(key)) {
      return CertifyDay(date: date, status: CertifyStatus.pendingSync, signedAt: row?.signedAt);
    }
    if (row == null) {
      return CertifyDay(date: date, status: CertifyStatus.notReady);
    }
    final CertifyStatus status = switch (row.certificationStatus) {
      'certified' => CertifyStatus.certified,
      'recertify_required' => CertifyStatus.needsRecertify,
      _ => row.ready ? CertifyStatus.uncertified : CertifyStatus.notReady,
    };
    return CertifyDay(date: date, status: status, signedAt: row.signedAt);
  }

  /// Outbox'da turgan `certify` yozuvlaridagi kunlar (M128 `pending sync`).
  Stream<Set<String>> _watchPendingCertifyDates() =>
      (_db.select(_db.outboxItems)..where(
            ($OutboxItemsTable t) =>
                t.kind.equals(OutboxKind.certify.wire) &
                t.state.isIn(<String>[OutboxState.pending.wire, OutboxState.inflight.wire]),
          ))
          .watch()
          .map(
            (List<OutboxItemRow> rows) => <String>{
              for (final OutboxItemRow row in rows)
                if (_logDateOf(row.payload) case final String date) date,
            },
          );

  String? _logDateOf(String payloadJson) {
    final Object? decoded = jsonDecode(payloadJson);
    if (decoded is Map<String, Object?> && decoded['log_date'] is String) {
      return decoded['log_date']! as String;
    }
    return null;
  }
}

/// Imzo PNG ini saqlab `files_queue` ga qo'yadi (M149) + «Save my signature».
///
/// **#B-33:** fayl yozish va navbatga qo'yish `core/files/SignatureFileStore`
/// da — DVIR imzosi bilan bir xil kod ikki nusxada emas. Bu sinf faqat
/// certify'ga xos qismni (saqlangan imzo KV kalitlari) qo'shadi.
class DriftSignatureStore implements SignatureStore {
  DriftSignatureStore({
    required DvirDao files,
    required this._settings,
    required TimeSource time,
    Future<Directory> Function()? baseDirectory,
    Uuid uuid = const Uuid(),
  }) : _time = time,
       _store = SignatureFileStore(
         files: files,
         time: time,
         baseDirectory: baseDirectory ?? getApplicationDocumentsDirectory,
         uuid: uuid,
       );

  final SettingsDao _settings;
  final TimeSource _time;
  final SignatureFileStore _store;

  @override
  Future<String?> savedSignatureId() => _settings.get(kSavedSignatureIdKey);

  @override
  Future<String?> savedSignaturePath() => _settings.get(kSavedSignaturePathKey);

  @override
  Future<String> enqueue(Uint8List png, {required bool remember}) async {
    final String path = await _store.enqueue(png);
    if (remember) {
      await _settings.put(key: kSavedSignaturePathKey, value: path, now: _time.now());
    }
    return path;
  }
}
