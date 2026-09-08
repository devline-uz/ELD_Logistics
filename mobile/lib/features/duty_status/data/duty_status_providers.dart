/// Duty status moduli DI si (M3: Riverpod).
///
/// `presentation` domen interfeyslarini oladi, `data` implementatsiyani
/// ulaydi. Testlar shu provayderlarni `overrideWithValue` qiladi.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hos_engine/hos_engine.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/db/db_providers.dart';
import '../../../core/eld/eld_providers.dart';
import '../../../core/eld/eld_session.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/time/day_boundary.dart';
import '../../../core/time/time_providers.dart';
import '../../../core/time/time_source.dart';
import '../domain/duty_status_models.dart';
import '../domain/duty_status_repository.dart';
import '../domain/hos_snapshot.dart';
import 'duty_status_repository_impl.dart';

final Provider<DutyStatusRepository> dutyStatusRepositoryProvider = Provider<DutyStatusRepository>(
  (Ref ref) => DriftDutyStatusRepository(
    events: ref.watch(dutyEventsDaoProvider),
    logs: ref.watch(logsDaoProvider),
    settings: ref.watch(settingsDaoProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    time: ref.watch(timeSourceProvider),
  ),
);

final Provider<DutyCatalogRepository> dutyCatalogRepositoryProvider =
    Provider<DutyCatalogRepository>(
      (Ref ref) => DriftDutyCatalogRepository(
        ref: ref.watch(refDaoProvider),
        settings: ref.watch(settingsDaoProvider),
        time: ref.watch(timeSourceProvider),
      ),
    );

/// Joriy duty konteksti — Home, `M-12` va `M-15` shundan oziqlanadi.
final StreamProvider<DutyStatusContext> dutyStatusContextProvider =
    StreamProvider<DutyStatusContext>(
      (Ref ref) => ref.watch(dutyStatusRepositoryProvider).watchContext(),
    );

/// **M66:** ELD ulanganmi — event `origin` i shunga bog'liq.
final Provider<bool> eldConnectedProvider = Provider<bool>((Ref ref) {
  final EldSessionState? state = ref.watch(eldSessionProvider).value;
  return state?.connection.isConnected ?? false;
});

/// Home Terminal zonasi (M42).
final Provider<tz.Location> homeTerminalLocationProvider = Provider<tz.Location>((Ref ref) {
  final DutyStatusContext? context = ref.watch(dutyStatusContextProvider).value;
  return resolveLocation(context?.driver.homeTerminalTz ?? kFallbackTimeZone);
});

/// **M55:** server ro'yxati ustun, birinchi pull'gacha fallback (M54).
final StreamProvider<List<QuickNoteOption>> quickNotesProvider =
    StreamProvider<List<QuickNoteOption>>(
      (Ref ref) => ref.watch(dutyCatalogRepositoryProvider).watchQuickNotes(),
    );

final StreamProvider<List<TrailerOption>> trailersProvider = StreamProvider<List<TrailerOption>>(
  (Ref ref) => ref.watch(dutyCatalogRepositoryProvider).watchTrailers(),
);

/// 1 soniyalik taymer — ekrandagi hisoblagichlar (tz-mobile 1236).
///
/// Vaqt `TimeSource` dan keladi; testlarda provayder override qilinadi.
final StreamProvider<DateTime> secondTickProvider = StreamProvider<DateTime>((Ref ref) {
  final TimeSource time = ref.watch(timeSourceProvider);
  return Stream<DateTime>.periodic(const Duration(seconds: 1), (int _) => time.now());
});

/// HOS kesimi — 30 soniyada bir marta qayta hisoblanadi (tz-mobile 1236).
///
/// Hisoblashning o'zi `hos_engine` (sof Dart) da; bu yerda faqat ma'lumot
/// yig'iladi.
final FutureProvider<HosSnapshot> hosSnapshotProvider = FutureProvider<HosSnapshot>((
  Ref ref,
) async {
  final Timer timer = Timer.periodic(
    const Duration(seconds: 30),
    (Timer _) => ref.invalidateSelf(),
  );
  ref.onDispose(timer.cancel);
  final DutyStatusRepository repository = ref.watch(dutyStatusRepositoryProvider);
  final DutyStatusContext? context = ref.watch(dutyStatusContextProvider).value;
  final DateTime now = ref.watch(timeSourceProvider).now();
  final HosPolicy policy = context?.policy ?? defaultPolicy();
  final List<HosEvent> events = await repository.hosEvents(now: now);
  return computeHosSnapshot(
    events: events,
    policy: policy,
    now: now,
    location: ref.watch(homeTerminalLocationProvider),
  );
});
