/// Baza va DAO provayderlari — UI `watch()` oqimlarini shulardan oladi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../time/time_providers.dart';
import 'app_database.dart';
import 'daos/chat_dao.dart';
import 'daos/duty_events_dao.dart';
import 'daos/dvir_dao.dart';
import 'daos/logs_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/ref_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/telemetry_dao.dart';
import 'retention_service.dart';
import 'session_data_cleaner.dart';

/// Yagona `AppDatabase`. `main()` da `overrideWithValue` bilan almashtiriladi
/// (SQLCipher kaliti Keystore'dan olinganidan keyin).
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  throw UnimplementedError('appDatabaseProvider bootstrap da override qilinadi (main.dart)');
});

final Provider<OutboxDao> outboxDaoProvider = Provider<OutboxDao>(
  (Ref ref) => ref.watch(appDatabaseProvider).outboxDao,
);

final Provider<DutyEventsDao> dutyEventsDaoProvider = Provider<DutyEventsDao>(
  (Ref ref) => ref.watch(appDatabaseProvider).dutyEventsDao,
);

final Provider<TelemetryDao> telemetryDaoProvider = Provider<TelemetryDao>(
  (Ref ref) => ref.watch(appDatabaseProvider).telemetryDao,
);

final Provider<LogsDao> logsDaoProvider = Provider<LogsDao>(
  (Ref ref) => ref.watch(appDatabaseProvider).logsDao,
);

final Provider<DvirDao> dvirDaoProvider = Provider<DvirDao>(
  (Ref ref) => ref.watch(appDatabaseProvider).dvirDao,
);

final Provider<ChatDao> chatDaoProvider = Provider<ChatDao>(
  (Ref ref) => ref.watch(appDatabaseProvider).chatDao,
);

final Provider<RefDao> refDaoProvider = Provider<RefDao>(
  (Ref ref) => ref.watch(appDatabaseProvider).refDao,
);

final Provider<SettingsDao> settingsDaoProvider = Provider<SettingsDao>(
  (Ref ref) => ref.watch(appDatabaseProvider).settingsDao,
);

/// Retention job (§5.2) — `main()` da 1 soatlik taymerdan chaqiriladi.
final Provider<RetentionService> retentionServiceProvider = Provider<RetentionService>(
  (Ref ref) =>
      RetentionService(db: ref.watch(appDatabaseProvider), time: ref.watch(timeSourceProvider)),
);

/// **S-M4:** login/logout oqimi shu tozalovchini chaqiradi — boshqa
/// `user_id` kirganda oldingi haydovchining domen ma'lumoti qolmaydi.
/// Yuborilmagan navbat tegilmaydi (M17).
final Provider<SessionDataCleaner> sessionDataCleanerProvider = Provider<SessionDataCleaner>(
  (Ref ref) => SessionDataCleaner(ref.watch(appDatabaseProvider)),
);

/// Navbat holati (`M-54`, app bar indikatori).
final StreamProvider<OutboxQueueStats> outboxStatsProvider = StreamProvider<OutboxQueueStats>(
  (Ref ref) => ref.watch(outboxDaoProvider).watchStats(),
);

/// `M-55` ro'yxati: rad etilgan va almashtirilgan elementlar.
final StreamProvider<List<OutboxItemRow>> syncConflictsProvider =
    StreamProvider<List<OutboxItemRow>>((Ref ref) => ref.watch(outboxDaoProvider).watchConflicts());

/// Sync kursori va oxirgi push/pull vaqti (`M-54` diagnostikasi, M28).
final StreamProvider<SyncCursorRow?> syncCursorProvider = StreamProvider<SyncCursorRow?>(
  (Ref ref) => ref.watch(settingsDaoProvider).watchCursor(),
);
