/// Retention job va 100 MB byudjet nazorati (§5.2, M23).
library;

import 'dart:io';

import 'package:sync_core/sync_core.dart';

import '../time/time_source.dart';
import 'app_database.dart';

/// Bitta yurishning natijasi — diagnostika ekraniga chiqadi.
class RetentionReport {
  const RetentionReport({
    required this.deletedEvents,
    required this.deletedTelemetry,
    required this.deletedTrimmedTelemetry,
    required this.deletedDailyLogs,
    required this.deletedDvirReports,
    required this.deletedChatMessages,
    required this.deletedNotifications,
    required this.deletedLogEdits,
    required this.deletedFiles,
    required this.sizeBytesBefore,
    required this.sizeBytesAfter,
  });

  final int deletedEvents;
  final int deletedTelemetry;

  /// Byudjet oshgani uchun o'chirilgan qo'shimcha telemetriya.
  final int deletedTrimmedTelemetry;

  final int deletedDailyLogs;
  final int deletedDvirReports;
  final int deletedChatMessages;
  final int deletedNotifications;
  final int deletedLogEdits;
  final int deletedFiles;
  final int sizeBytesBefore;
  final int sizeBytesAfter;

  int get deletedTotal =>
      deletedEvents +
      deletedTelemetry +
      deletedTrimmedTelemetry +
      deletedDailyLogs +
      deletedDvirReports +
      deletedChatMessages +
      deletedNotifications +
      deletedLogEdits +
      deletedFiles;
}

/// Retention siyosatini bazaga qo'llaydi.
///
/// **M23:** eventlar faqat `sync_state=acked` **va** 30 kundan eski bo'lsa
/// o'chadi. Byudjet oshganda ham eventlarga tegilmaydi — faqat telemetriya
/// qisqaradi («0 event yo'qotish» NFR).
class RetentionService {
  RetentionService({
    required AppDatabase db,
    required TimeSource time,
    RetentionPolicy policy = const RetentionPolicy(),
    StorageBudget budget = const StorageBudget(),
    Future<void> Function(String path)? deleteFile,
  }) : this._(db, time, policy, budget, deleteFile ?? _defaultDeleteFile);

  RetentionService._(this._db, this._time, this._policy, this._budget, this._deleteFile);

  final AppDatabase _db;
  final TimeSource _time;
  final RetentionPolicy _policy;
  final StorageBudget _budget;
  final Future<void> Function(String path) _deleteFile;

  static Future<void> _defaultDeleteFile(String path) async {
    final File file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<RetentionReport> run() async {
    final DateTime now = _time.now();
    final RetentionPlan plan = planRetention(now: now, policy: _policy);
    final int sizeBefore = await _db.databaseSizeBytes();

    final int events = await _db.dutyEventsDao.deleteAcked(before: plan.ackedEventsBefore);
    final int telemetry = await _db.telemetryDao.deleteSentBefore(plan.sentTelemetryBefore);
    final int logs = await _db.logsDao.deleteLogsBefore(_logDateBefore(plan.dailyLogsBefore));
    final int dvir = await _db.dvirDao.deleteReportsBefore(plan.dvirReportsBefore);
    final int chat = await _db.chatDao.trimMessages(
      before: plan.chatBefore,
      keep: plan.chatMaxMessages,
    );
    final int notifications = await _db.chatDao.deleteNotificationsBefore(plan.notificationsBefore);
    final int edits = await _db.logsDao.deleteEditsBefore(plan.dailyLogsBefore);
    // Buzilishlar kunlik loglar bilan bir xil oynada saqlanadi (§5.2).
    await _db.logsDao.deleteViolationsBefore(plan.dailyLogsBefore);
    final int files = await _cleanUploadedFiles(plan.uploadedFilesBefore);

    // §5.2: 90 MB dan oshsa telemetriyaning eng eski 10% i o'chadi.
    final int size = await _db.databaseSizeBytes();
    final BudgetVerdict verdict = evaluateBudget(
      usedBytes: size,
      telemetryRows: await _db.telemetryDao.countAll(),
      budget: _budget,
    );
    final int trimmed = verdict.requiresTrim
        ? await _db.telemetryDao.deleteOldest(verdict.telemetryRowsToDrop)
        : 0;

    return RetentionReport(
      deletedEvents: events,
      deletedTelemetry: telemetry,
      deletedTrimmedTelemetry: trimmed,
      deletedDailyLogs: logs,
      deletedDvirReports: dvir,
      deletedChatMessages: chat,
      deletedNotifications: notifications,
      deletedLogEdits: edits,
      deletedFiles: files,
      sizeBytesBefore: sizeBefore,
      sizeBytesAfter: await _db.databaseSizeBytes(),
    );
  }

  /// Joriy hajm byudjet chegarasidan oshgan-oshmaganini tekshiradi.
  Future<BudgetVerdict> checkBudget() async => evaluateBudget(
    usedBytes: await _db.databaseSizeBytes(),
    telemetryRows: await _db.telemetryDao.countAll(),
    budget: _budget,
  );

  Future<int> _cleanUploadedFiles(DateTime before) async {
    final List<FileQueueRow> rows = await _db.dvirDao.uploadedBefore(before);
    for (final FileQueueRow row in rows) {
      await _deleteFile(row.localPath);
    }
    return _db.dvirDao.deleteFiles(rows.map((FileQueueRow r) => r.id).toList(growable: false));
  }

  /// `daily_logs.log_date` — matn ustuni, shuning uchun chegara ham matn.
  static String _logDateBefore(DateTime before) =>
      '${before.year.toString().padLeft(4, '0')}-'
      '${before.month.toString().padLeft(2, '0')}-'
      '${before.day.toString().padLeft(2, '0')}';
}
