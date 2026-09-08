/// Logs moduli DI simlari (M3: Riverpod).
///
/// `presentation` faqat domen interfeyslarini ko'radi (M5); bu fayl `data`
/// implementatsiyasini ularga bog'laydi. Testlar repozitoriyni override qiladi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/db_providers.dart';
import '../../../../core/session/session_context.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/time/time_providers.dart';
import '../../data/logs_repository_impl.dart';
import '../../domain/log_models.dart';
import '../../domain/logs_repository.dart';

final Provider<LogsRepository> logsRepositoryProvider = Provider<LogsRepository>((Ref ref) {
  final SessionContext session = ref.watch(sessionContextProvider);
  return DriftLogsRepository(
    logs: ref.watch(logsDaoProvider),
    events: ref.watch(dutyEventsDaoProvider),
    dvir: ref.watch(dvirDaoProvider),
    ref: ref.watch(refDaoProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    time: ref.watch(timeSourceProvider),
    driverId: session.driverId,
    timeZone: session.homeTerminalTz,
    driver: DriverDayInfo(
      driverName: session.driverName,
      unitNumber: session.unitNumber,
      homeTerminal: session.homeTerminal,
    ),
  );
});

/// 8 kunlik sana tasmasi (M96).
final StreamProvider<List<LogDayRef>> logStripProvider = StreamProvider<List<LogDayRef>>(
  (Ref ref) => ref.watch(logsRepositoryProvider).watchStrip(),
);

/// Tanlangan kunning to'liq ko'rinishi.
final logDayProvider = StreamProvider.family<LogDayView, DateTime>(
  (Ref ref, DateTime date) => ref.watch(logsRepositoryProvider).watchDay(date),
);

/// `DVIR` tabi (M-24).
final StreamProvider<List<DvirListItem>> logDvirProvider = StreamProvider<List<DvirListItem>>(
  (Ref ref) => ref.watch(logsRepositoryProvider).watchDvir(),
);
