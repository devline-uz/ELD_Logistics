/// DVIR qoralamalari/hisobotlari va fayl navbati DAO'si (§5.1, §16).
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

part 'dvir_dao.g.dart';

@DriftAccessor(tables: <Type>[DvirDrafts, DvirReports, FilesQueue])
class DvirDao extends DatabaseAccessor<AppDatabase> with _$DvirDaoMixin {
  DvirDao(super.db);

  // --- dvir_drafts --------------------------------------------------------

  Stream<List<DvirDraftRow>> watchDrafts() =>
      (select(dvirDrafts)
            ..where((DvirDrafts t) => t.state.isNotValue('sent'))
            ..orderBy(<OrderClauseGenerator<DvirDrafts>>[
              (DvirDrafts t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .watch();

  Future<DvirDraftRow?> draft(String clientId) =>
      (select(dvirDrafts)..where((DvirDrafts t) => t.clientId.equals(clientId))).getSingleOrNull();

  Future<void> upsertDraft(DvirDraftsCompanion draft) =>
      into(dvirDrafts).insertOnConflictUpdate(draft);

  Future<void> setDraftState({
    required String clientId,
    required String state,
    required DateTime now,
  }) => (update(dvirDrafts)..where((DvirDrafts t) => t.clientId.equals(clientId))).write(
    DvirDraftsCompanion(state: Value<String>(state), updatedAt: Value<DateTime>(now)),
  );

  // --- dvir_reports -------------------------------------------------------

  Stream<List<DvirReportRow>> watchReports({int limit = 50}) =>
      (select(dvirReports)
            ..orderBy(<OrderClauseGenerator<DvirReports>>[
              (DvirReports t) => OrderingTerm.desc(t.createdAt),
            ])
            ..limit(limit))
          .watch();

  Future<void> upsertReport(DvirReportsCompanion report) =>
      into(dvirReports).insertOnConflictUpdate(report);

  Future<int> deleteReportsBefore(DateTime before) =>
      (delete(dvirReports)..where((DvirReports t) => t.createdAt.isSmallerThanValue(before))).go();

  // --- files_queue --------------------------------------------------------

  Stream<List<FileQueueRow>> watchPendingFiles() =>
      (select(filesQueue)
            ..where((FilesQueue t) => t.state.isNotValue('uploaded'))
            ..orderBy(<OrderClauseGenerator<FilesQueue>>[
              (FilesQueue t) => OrderingTerm.asc(t.createdAt),
            ]))
          .watch();

  Future<int> enqueueFile(FilesQueueCompanion file) =>
      into(filesQueue).insert(file, mode: InsertMode.insertOrIgnore);

  Future<void> setFileState({
    required int id,
    required String state,
    DateTime? uploadedAt,
    int? attempts,
  }) => (update(filesQueue)..where((FilesQueue t) => t.id.equals(id))).write(
    FilesQueueCompanion(
      state: Value<String>(state),
      uploadedAt: uploadedAt == null
          ? const Value<DateTime?>.absent()
          : Value<DateTime?>(uploadedAt),
      attempts: attempts == null ? const Value<int>.absent() : Value<int>(attempts),
    ),
  );

  /// Fayl boshqa katalogga ko'chirilganda navbatdagi yo'lni yangilaydi
  /// (S-M2 migratsiyasi: `documents/` → `app_support/`).
  Future<int> relocateFile({required String from, required String to}) =>
      (update(filesQueue)..where((FilesQueue t) => t.localPath.equals(from))).write(
        FilesQueueCompanion(localPath: Value<String>(to)),
      );

  /// Yuklangan va [before] dan eski fayllar (§5.2: yuklangandan keyin 7 kun).
  Future<List<FileQueueRow>> uploadedBefore(DateTime before) =>
      (select(filesQueue)..where(
            (FilesQueue t) => t.state.equals('uploaded') & t.uploadedAt.isSmallerThanValue(before),
          ))
          .get();

  Future<int> deleteFiles(List<int> ids) async {
    if (ids.isEmpty) {
      return 0;
    }
    return (delete(filesQueue)..where((FilesQueue t) => t.id.isIn(ids))).go();
  }
}
