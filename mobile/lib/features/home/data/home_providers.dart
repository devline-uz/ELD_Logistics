/// Home moduli DI si (M3).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/time/time_providers.dart';
import '../../duty_status/data/duty_status_providers.dart';
import '../../duty_status/domain/hos_snapshot.dart';
import '../domain/home_models.dart';
import '../domain/home_repository.dart';
import 'home_repository_impl.dart';

final Provider<HomeRepository> homeRepositoryProvider = Provider<HomeRepository>(
  (Ref ref) => DriftHomeRepository(
    logs: ref.watch(logsDaoProvider),
    settings: ref.watch(settingsDaoProvider),
    duty: ref.watch(dutyStatusRepositoryProvider),
  ),
);

/// `Certify (Last 8 days)`.
final StreamProvider<List<CertifyDay>> certifyDaysProvider = StreamProvider<List<CertifyDay>>(
  (Ref ref) => ref.watch(homeRepositoryProvider).watchCertifyDays(),
);

/// Sariq karta: `Pending edits (n)`.
final StreamProvider<int> pendingEditCountProvider = StreamProvider<int>(
  (Ref ref) => ref.watch(homeRepositoryProvider).watchPendingEditCount(),
);

/// Sariq karta: `Unidentified driving (n)`.
final StreamProvider<int> unidentifiedCountProvider = StreamProvider<int>(
  (Ref ref) => ref.watch(homeRepositoryProvider).watchUnidentifiedCount(),
);

/// Log bloki uchun bugungi 24 soatlik segmentlar.
final FutureProvider<List<DutyDaySegment>> todaySegmentsProvider =
    FutureProvider<List<DutyDaySegment>>((Ref ref) async {
      // HOS kesimi yangilanganda grid ham qayta chiziladi (30 s, M-09).
      ref.watch(hosSnapshotProvider);
      return ref
          .watch(homeRepositoryProvider)
          .todaySegments(now: ref.watch(timeSourceProvider).now());
    });
