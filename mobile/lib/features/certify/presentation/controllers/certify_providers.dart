/// Certify moduli DI simlari (M3).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/db_providers.dart';
import '../../../../core/session/session_context.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/time/time_providers.dart';
import '../../data/certify_repository_impl.dart';
import '../../domain/certify_models.dart';
import '../../domain/certify_repository.dart';

final Provider<SignatureStore> signatureStoreProvider = Provider<SignatureStore>(
  (Ref ref) => DriftSignatureStore(
    files: ref.watch(dvirDaoProvider),
    settings: ref.watch(settingsDaoProvider),
    time: ref.watch(timeSourceProvider),
  ),
);

final Provider<CertifyRepository> certifyRepositoryProvider = Provider<CertifyRepository>(
  (Ref ref) => DriftCertifyRepository(
    db: ref.watch(appDatabaseProvider),
    logs: ref.watch(logsDaoProvider),
    settings: ref.watch(settingsDaoProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    signatures: ref.watch(signatureStoreProvider),
    time: ref.watch(timeSourceProvider),
    driverId: ref.watch(sessionContextProvider).driverId,
    timeZone: ref.watch(homeTerminalTzProvider),
  ),
);

/// `M-29` ro'yxati (M124: 8 kun).
final StreamProvider<List<CertifyDay>> certifyWindowProvider = StreamProvider<List<CertifyDay>>(
  (Ref ref) => ref.watch(certifyRepositoryProvider).watchWindow(),
);

/// M130: `Log Report` dan ochilgan alohida kun.
final certifyDayProvider = StreamProvider.family<CertifyDay, DateTime>(
  (Ref ref, DateTime date) => ref.watch(certifyRepositoryProvider).watchDay(date),
);

/// Saqlangan imzo mavjudmi (`Use my signature`).
final FutureProvider<String?> savedSignatureIdProvider = FutureProvider<String?>(
  (Ref ref) => ref.watch(signatureStoreProvider).savedSignatureId(),
);
