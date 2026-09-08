/// Katalog keshlari DAO'si — `sync/pull` dan yangilanadi (§5.1, M36).
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

part 'ref_dao.g.dart';

@DriftAccessor(tables: <Type>[RefDefectTypes, RefQuickNotes, RefTrailers])
class RefDao extends DatabaseAccessor<AppDatabase> with _$RefDaoMixin {
  RefDao(super.db);

  Stream<List<RefDefectTypeRow>> watchDefectTypes({String? appliesTo}) {
    final SimpleSelectStatement<RefDefectTypes, RefDefectTypeRow> query = select(refDefectTypes)
      ..orderBy(<OrderClauseGenerator<RefDefectTypes>>[
        (RefDefectTypes t) => OrderingTerm.asc(t.label),
      ]);
    if (appliesTo != null) {
      query.where((RefDefectTypes t) => t.appliesTo.equals(appliesTo));
    }
    return query.watch();
  }

  Stream<List<RefQuickNoteRow>> watchQuickNotes() =>
      (select(refQuickNotes)..orderBy(<OrderClauseGenerator<RefQuickNotes>>[
            (RefQuickNotes t) => OrderingTerm.asc(t.label),
          ]))
          .watch();

  Stream<List<RefTrailerRow>> watchTrailers() =>
      (select(refTrailers)..orderBy(<OrderClauseGenerator<RefTrailers>>[
            (RefTrailers t) => OrderingTerm.asc(t.number),
          ]))
          .watch();

  Future<void> replaceDefectTypes(List<RefDefectTypesCompanion> rows) async {
    await batch((Batch b) {
      b.deleteWhere(refDefectTypes, (RefDefectTypes t) => const Constant<bool>(true));
      b.insertAll(refDefectTypes, rows);
    });
  }

  Future<void> replaceQuickNotes(List<RefQuickNotesCompanion> rows) async {
    await batch((Batch b) {
      b.deleteWhere(refQuickNotes, (RefQuickNotes t) => const Constant<bool>(true));
      b.insertAll(refQuickNotes, rows);
    });
  }

  Future<void> replaceTrailers(List<RefTrailersCompanion> rows) async {
    await batch((Batch b) {
      b.deleteWhere(refTrailers, (RefTrailers t) => const Constant<bool>(true));
      b.insertAll(refTrailers, rows);
    });
  }
}
