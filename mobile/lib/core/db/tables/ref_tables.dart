/// Katalog keshlari, sync kursori va kalit-qiymat sozlamalari (§5.1).
library;

import 'package:drift/drift.dart';

@DataClassName('RefDefectTypeRow')
class RefDefectTypes extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get label => text()();
  TextColumn get category => text().nullable()();

  /// `vehicle`/`trailer`.
  TextColumn get appliesTo => text().withDefault(const Constant<String>('vehicle'))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('RefQuickNoteRow')
class RefQuickNotes extends Table {
  TextColumn get id => text()();

  /// Getter nomi `label`, SQL ustuni `text` (drift `text()` quruvchisi bilan
  /// to'qnashmasligi uchun).
  TextColumn get label => text().named('text')();
  TextColumn get category => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('RefTrailerRow')
class RefTrailers extends Table {
  TextColumn get id => text()();
  TextColumn get number => text()();
  TextColumn get unitId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Bitta qatorli jadval (`id = 1`): pull kursori va oxirgi sikl statistikasi (M28, M35).
@DataClassName('SyncCursorRow')
class SyncCursorTable extends Table {
  @override
  String get tableName => 'sync_cursor';

  IntColumn get id => integer().withDefault(const Constant<int>(1))();

  /// Server bergan kursor; mijoz **hech qachon** o'zi hisoblamaydi (M35).
  TextColumn get nextSince => text().nullable()();

  DateTimeColumn get lastPushAt => dateTime().nullable()();
  DateTimeColumn get lastPullAt => dateTime().nullable()();

  /// Oxirgi xato kodi (`M-54` diagnostikasi).
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get lastErrorAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// `device_id`, `device_seq`, `home_terminal_tz`, tema, zoom, til, oxirgi trailer.
@DataClassName('KvSettingRow')
class KvSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
