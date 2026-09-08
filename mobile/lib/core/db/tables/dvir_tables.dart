/// DVIR qoralamalari/hisobotlari va fayl navbati (§5.1, §16).
library;

import 'package:drift/drift.dart';

import '../converters.dart';

@DataClassName('DvirDraftRow')
@TableIndex(name: 'idx_dvir_drafts_state', columns: <Symbol>{#state, #updatedAt})
class DvirDrafts extends Table {
  TextColumn get clientId => text()();

  TextColumn get unitId => text()();

  /// `pre_trip`/`post_trip`.
  TextColumn get type => text()();

  /// Aniqlangan nuqsonlar ro'yxati — JSON.
  TextColumn get defects =>
      text().map(const JsonMapConverter()).withDefault(const Constant<String>('{}'))();

  TextColumn get trailerIds =>
      text().map(const StringListConverter()).withDefault(const Constant<String>('[]'))();

  TextColumn get notes => text().nullable()();

  /// Object storage kaliti (imzo yuklangandan keyin to'ladi).
  TextColumn get driverSignatureKey => text().nullable()();

  TextColumn get localPhotoPaths =>
      text().map(const StringListConverter()).withDefault(const Constant<String>('[]'))();

  /// `draft`/`queued`/`sent`.
  TextColumn get state => text().withDefault(const Constant<String>('draft'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{clientId};
}

@DataClassName('DvirReportRow')
@TableIndex(name: 'idx_dvir_reports_created', columns: <Symbol>{#createdAt})
class DvirReports extends Table {
  TextColumn get id => text()();

  /// `open`/`resolved`/`certified`.
  TextColumn get status => text()();

  /// `driver`/`mechanic`.
  TextColumn get kind => text()();

  /// `pre_trip`/`post_trip`.
  TextColumn get type => text()();

  TextColumn get unitId => text()();

  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get hasCriticalDefect => boolean().withDefault(const Constant<bool>(false))();

  BoolColumn get outOfService => boolean().withDefault(const Constant<bool>(false))();

  /// To'liq server javobi — ekranga chiqarish uchun.
  TextColumn get payload =>
      text().map(const JsonMapConverter()).withDefault(const Constant<String>('{}'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('FileQueueRow')
@TableIndex(name: 'idx_files_queue_state', columns: <Symbol>{#state, #attempts})
class FilesQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get localPath => text().unique()();

  /// `dvir_photo`/`signature`/`chat_file`/`feedback`.
  TextColumn get kind => text()();

  TextColumn get contentType => text()();

  IntColumn get sizeBytes => integer()();

  TextColumn get presignedKey => text().nullable()();

  TextColumn get uploadUrl => text().nullable()();

  DateTimeColumn get expiresAt => dateTime().nullable()();

  /// `pending`/`uploading`/`uploaded`/`failed`.
  TextColumn get state => text().withDefault(const Constant<String>('pending'))();

  IntColumn get attempts => integer().withDefault(const Constant<int>(0))();

  DateTimeColumn get createdAt => dateTime()();

  /// Retention: yuklangandan keyin 7 kun saqlanadi (§5.2).
  DateTimeColumn get uploadedAt => dateTime().nullable()();
}
