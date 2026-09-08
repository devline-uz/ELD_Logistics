/// `telemetry_buffer` DAO — past ustuvorlikli navbat (§5.1, M27).
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

part 'telemetry_dao.g.dart';

@DriftAccessor(tables: <Type>[TelemetryBuffer])
class TelemetryDao extends DatabaseAccessor<AppDatabase> with _$TelemetryDaoMixin {
  TelemetryDao(super.db);

  /// `(unit_id, ts)` dublikati jimgina tashlanadi (eld-sync qoidasi #4).
  Future<void> insertPoint(TelemetryBufferCompanion point) =>
      into(telemetryBuffer).insert(point, mode: InsertMode.insertOrIgnore);

  Future<void> insertPoints(List<TelemetryBufferCompanion> points) =>
      batch((Batch b) => b.insertAll(telemetryBuffer, points, mode: InsertMode.insertOrIgnore));

  /// Yuborilmagan nuqtalar, vaqt o'sish tartibida.
  Future<List<TelemetryRow>> unsent({int limit = 5000}) =>
      (select(telemetryBuffer)
            ..where((TelemetryBuffer t) => t.sent.equals(false))
            ..orderBy(<OrderClauseGenerator<TelemetryBuffer>>[
              (TelemetryBuffer t) => OrderingTerm.asc(t.ts),
            ])
            ..limit(limit))
          .get();

  Future<void> markSent(List<int> ids) async {
    if (ids.isEmpty) {
      return;
    }
    await (update(telemetryBuffer)..where((TelemetryBuffer t) => t.id.isIn(ids))).write(
      const TelemetryBufferCompanion(sent: Value<bool>(true)),
    );
  }

  Stream<int> watchUnsentCount() {
    final Expression<int> count = telemetryBuffer.id.count();
    return (selectOnly(telemetryBuffer)
          ..addColumns(<Expression<Object>>[count])
          ..where(telemetryBuffer.sent.equals(false)))
        .map((TypedResult row) => row.read(count) ?? 0)
        .watchSingle();
  }

  Future<int> countAll() async {
    final Expression<int> count = telemetryBuffer.id.count();
    final TypedResult row = await (selectOnly(
      telemetryBuffer,
    )..addColumns(<Expression<Object>>[count])).getSingle();
    return row.read(count) ?? 0;
  }

  /// Retention: `sent=true` va [sentBefore] dan eski (§5.2).
  Future<int> deleteSentBefore(DateTime sentBefore) => (delete(
    telemetryBuffer,
  )..where((TelemetryBuffer t) => t.sent.equals(true) & t.ts.isSmallerThanValue(sentBefore))).go();

  /// Byudjet oshganda eng eski [rows] nuqtani o'chiradi (§5.2).
  ///
  /// Eventlarga **hech qachon** tegilmaydi (M23).
  Future<int> deleteOldest(int rows) async {
    if (rows <= 0) {
      return 0;
    }
    return customUpdate(
      'DELETE FROM telemetry_buffer WHERE id IN '
      '(SELECT id FROM telemetry_buffer ORDER BY ts ASC LIMIT ?)',
      variables: <Variable<Object>>[Variable<int>(rows)],
      updates: <TableInfo<Table, Object>>{telemetryBuffer},
      updateKind: UpdateKind.delete,
    );
  }
}
