/// Outbox, transport va scheduler provayderlari (§5.3, §5.4).
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../db/db_providers.dart';
import '../files/file_upload.dart';
import '../security/active_slot.dart';
import '../security/secure_vault.dart';
import '../session/session_profile.dart';
import '../time/time_providers.dart';
import 'dio_sync_transport.dart';
import 'mock_sync_transport.dart';
import 'outbox_repository.dart';
import 'session_slot.dart';
import 'sync_engine.dart';
import 'sync_scheduler.dart';
import 'sync_side_channel.dart';
import 'sync_transport.dart';

/// **B-121:** navbat yozuvi faol slotni shu holderdan oladi.
final Provider<OutboxRepository> outboxRepositoryProvider = Provider<OutboxRepository>(
  (Ref ref) => OutboxRepository(
    db: ref.watch(appDatabaseProvider),
    time: ref.watch(timeSourceProvider),
    activeSlot: ref.watch(activeSlotHolderProvider),
  ),
);

/// **B-120:** qaysi slotda tirik sessiya (refresh token) borligi.
///
/// Standart implementatsiya `SecureVault` ni o'qiydi; `readRefreshToken`
/// faqat secure storage'ga boradi, shuning uchun bu yerdagi nusxa
/// `features/auth` dagi nusxa bilan bir xil natija beradi (M5: `core`
/// `features` ga import qila olmaydi). Testlar bu provayderni override qiladi.
final Provider<SlotTokenProbe> slotTokenProbeProvider = Provider<SlotTokenProbe>(
  (Ref ref) => vaultSlotTokenProbe(SecureVault()),
);

/// Autentifikatsiyalangan `Dio`. Bootstrap (`main.dart`) `authDioProvider`
/// bilan override qiladi — `core` `features/auth` ga import qila olmaydi (M5).
final Provider<Dio> syncDioProvider = Provider<Dio>(
  (Ref ref) => throw UnimplementedError('syncDioProvider bootstrap da override qilinadi'),
);

final Provider<FilesApi> filesApiProvider = Provider<FilesApi>(
  (Ref ref) => FilesApi(dio: ref.watch(syncDioProvider)),
);

final Provider<FileUploader> fileUploaderProvider = Provider<FileUploader>(
  (Ref ref) =>
      FileUploader(api: ref.watch(filesApiProvider), now: ref.watch(timeSourceProvider).now),
);

/// M-SYNC1: `certify`/`claim`/`log_edit`/`feedback`/`support` uchun kanal.
final Provider<SyncSideChannel> syncSideChannelProvider = Provider<SyncSideChannel>(
  (Ref ref) =>
      SyncSideChannel(dio: ref.watch(syncDioProvider), uploader: ref.watch(fileUploaderProvider)),
);

/// **stage/prod** — `DioSyncTransport`. **dev** — backend manzili berilmagan
/// bo'lsa (testlar, `--dart-define-from-file` siz ishga tushirish) mock.
///
/// M163: mock transport prod/stage build'da hech qachon tanlanmaydi —
/// `Env.validate()` u yerda bo'sh `API_BASE_URL` ni o'tkazmaydi.
final Provider<SyncTransport> syncTransportProvider = Provider<SyncTransport>((Ref ref) {
  if (Env.current == AppFlavor.dev && Env.apiBaseUrl.isEmpty) {
    return MockSyncTransport(serverTime: ref.watch(timeSourceProvider).now());
  }
  return DioSyncTransport(
    dio: ref.watch(syncDioProvider),
    sideChannel: ref.watch(syncSideChannelProvider),
  );
});

/// Qurilma konteksti — bootstrap `device_id`/`unit_id`/tarmoq holatidan to'ldiradi.
final Provider<SyncContext> syncContextProvider = Provider<SyncContext>(
  (Ref ref) => SyncContext(
    deviceId: ref.watch(syncDeviceIdProvider),
    appVersion: ref.watch(syncAppVersionProvider),
    unitId: ref.watch(sessionProfileProvider).unitId,
    activeSlot: ref.watch(activeSlotHolderProvider).value,
  ),
);

/// Bootstrap `SecureVault.deviceId()` natijasi bilan override qiladi.
final Provider<String> syncDeviceIdProvider = Provider<String>((Ref ref) => 'unknown-device');

/// Bootstrap `package_info_plus` versiyasi bilan override qiladi.
final Provider<String> syncAppVersionProvider = Provider<String>((Ref ref) => '0.0.0');

final Provider<SyncEngine> syncEngineProvider = Provider<SyncEngine>(
  (Ref ref) => SyncEngine(
    db: ref.watch(appDatabaseProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    transport: ref.watch(syncTransportProvider),
    time: ref.watch(timeSourceProvider),
    slotTokens: ref.watch(slotTokenProbeProvider),
  ),
);

/// keepAlive: scheduler ilova hayoti davomida yashaydi (§2 qatlam qoidasi #4).
final Provider<SyncScheduler> syncSchedulerProvider = Provider<SyncScheduler>((Ref ref) {
  final SyncScheduler scheduler = SyncScheduler(
    engine: ref.watch(syncEngineProvider),
    time: ref.watch(timeSourceProvider),
    context: () => ref.read(syncContextProvider),
  );
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

/// Oxirgi sikl natijasi — `M-54` da ko'rsatiladi.
final StreamProvider<SyncCycleResult> syncCycleResultsProvider = StreamProvider<SyncCycleResult>(
  (Ref ref) => ref.watch(syncSchedulerProvider).results,
);
