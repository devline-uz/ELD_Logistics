/// Lokal Drift bazasi: sxema, forward-only migratsiya va DAO'lar (§5.1, M21, M22).
library;

import 'package:drift/drift.dart';

import 'connection.dart';
import 'converters.dart';
import 'daos/chat_dao.dart';
import 'daos/duty_events_dao.dart';
import 'daos/dvir_dao.dart';
import 'daos/logs_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/ref_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/telemetry_dao.dart';
import 'tables/chat_tables.dart';
import 'tables/dvir_tables.dart';
import 'tables/event_tables.dart';
import 'tables/log_tables.dart';
import 'tables/outbox_tables.dart';
import 'tables/ref_tables.dart';

export 'tables/chat_tables.dart';
export 'tables/dvir_tables.dart';
export 'tables/event_tables.dart';
export 'tables/log_tables.dart';
export 'tables/outbox_tables.dart';
export 'tables/ref_tables.dart';

part 'app_database.g.dart';

/// Joriy sxema versiyasi.
///
/// **P10 / M21 — forward-only:** bu raqam faqat oshadi, chiqarilgan migratsiya
/// hech qachon tahrirlanmaydi. Yangi o'zgarish = `schemaVersion + 1` va
/// [AppDatabase._migrationSteps] ga yangi qadam.
const int kSchemaVersion = 2;

@DriftDatabase(
  tables: <Type>[
    OutboxItems,
    DutyEvents,
    TelemetryBuffer,
    DailyLogs,
    HosStates,
    HosPolicies,
    DvirDrafts,
    DvirReports,
    FilesQueue,
    ChatOutbox,
    ChatMessages,
    Notifications,
    LogEditRequests,
    UnidentifiedEvents,
    Violations,
    RefDefectTypes,
    RefQuickNotes,
    RefTrailers,
    SyncCursorTable,
    KvSettings,
  ],
  daos: <Type>[
    OutboxDao,
    DutyEventsDao,
    TelemetryDao,
    LogsDao,
    DvirDao,
    ChatDao,
    RefDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Test uchun: fayl yozmaydigan in-memory baza.
  AppDatabase.memory() : super(openInMemoryConnection());

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: stepByStep(),
    beforeOpen: (OpeningDetails details) async {
      // FK majburlash faqat ochilishda yoqiladi (Drift talabi).
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      if (details.wasCreated) {
        await into(syncCursorTable).insert(
          const SyncCursorTableCompanion(id: Value<int>(1)),
          mode: InsertMode.insertOrIgnore,
        );
      }
    },
  );

  /// Har `schemaVersion` uchun alohida qadam. v1 — boshlang'ich sxema,
  /// qadam yo'q. Keyingi versiyalar shu yerga **qo'shiladi**, mavjudi
  /// o'zgartirilmaydi (M21).
  OnUpgrade stepByStep() => (Migrator m, int from, int to) async {
    for (int target = from + 1; target <= to; target++) {
      final Future<void> Function(Migrator)? step = _migrationSteps[target];
      if (step == null) {
        throw StateError('drift: $target versiyasi uchun migratsiya qadami yo\'q');
      }
      await step(m);
    }
  };

  Map<int, Future<void> Function(Migrator)> get _migrationSteps =>
      <int, Future<void> Function(Migrator)>{
        // v2: `violations` jadvali (`GET /violations` keshi). Faqat qo'shish —
        // mavjud jadvallarga tegilmaydi.
        2: (Migrator m) async => m.createTable(violations),
      };

  /// Ma'lumotlar fayli hajmi (bayt) — 100 MB byudjet nazorati uchun (§5.2).
  Future<int> databaseSizeBytes() async {
    final QueryRow row = await customSelect(
      'SELECT page_count * page_size AS size FROM pragma_page_count(), pragma_page_size()',
    ).getSingle();
    return row.read<int>('size');
  }

  /// Bo'shatilgan sahifalarni faylga qaytaradi (retention job dan keyin).
  Future<void> compact() => customStatement('VACUUM');
}
