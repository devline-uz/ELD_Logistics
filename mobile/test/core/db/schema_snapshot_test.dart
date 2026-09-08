/// **M22:** sxema snapshot'i repoda saqlanadi va CI da tekshiriladi.
///
/// `drift_dev schema dump` hozircha ishlamaydi (drift_dev 2.34.0 ↔ drift 2.34.4
/// `GeneratedDatabase.allSchemaEntities` nomuvofiqligi), shuning uchun snapshot
/// `sqlite_master` dan olinadi va shu test bilan solishtiriladi.
///
/// Yangilash: `UPDATE_DRIFT_SCHEMA=1 flutter test test/core/db/schema_snapshot_test.dart`
/// — **faqat** `schemaVersion` oshirilganda va yangi fayl nomi bilan (forward-only, P10).

library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String> dumpSchema(AppDatabase db) async {
  final List<QueryRow> rows = await db
      .customSelect(
        'SELECT type, name, sql FROM sqlite_master '
        "WHERE sql IS NOT NULL AND name NOT LIKE 'sqlite_%' "
        'ORDER BY type, name',
      )
      .get();
  final StringBuffer out = StringBuffer()
    ..writeln('-- ONEBOOK ELD lokal sxemasi, schemaVersion = ${db.schemaVersion}.')
    ..writeln('-- Generatsiya: test/core/db/schema_snapshot_test.dart. Qo\'lda tahrirlanmaydi.')
    ..writeln();
  for (final QueryRow row in rows) {
    out
      ..writeln('${row.read<String>('sql').trim()};')
      ..writeln();
  }
  return out.toString();
}

void main() {
  test('sxema snapshot\'i o\'zgarmagan (M22)', () async {
    final AppDatabase db = AppDatabase.memory();
    addTearDown(db.close);

    final String actual = await dumpSchema(db);
    final File snapshot = File('drift_schemas/schema_v${db.schemaVersion}.sql');

    if (Platform.environment['UPDATE_DRIFT_SCHEMA'] == '1' || !snapshot.existsSync()) {
      snapshot.parent.createSync(recursive: true);
      snapshot.writeAsStringSync(actual);
    }

    expect(
      actual,
      snapshot.readAsStringSync(),
      reason:
          'Sxema snapshot bilan mos emas. Yangi `schemaVersion` va yangi '
          'snapshot fayli kerak (forward-only, migratsiyani tahrirlash taqiq).',
    );
  });
}
