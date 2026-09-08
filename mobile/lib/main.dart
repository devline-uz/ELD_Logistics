/// Bootstrap. Faqat ishga tushirish ketma-ketligi — biznes mantiq yo'q.
///
/// Bu fayl **yagona kompozitsiya ildizi**: `core` `features` ga import qila
/// olmaydi (M5), shuning uchun modul provayderlarini `core` provayderlariga
/// bog'lash aynan shu yerda (va `app.dart` bootstrap qatlamida) bajariladi.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/db/app_database.dart';
import 'core/db/daos/settings_dao.dart';
import 'core/db/database_bootstrap.dart';
import 'core/db/db_providers.dart';
import 'core/db/kv_store.dart';
import 'core/device/orientation_lock.dart';
import 'core/files/app_file_directories.dart';
import 'core/security/secure_vault.dart';
import 'core/session/session_profile.dart';
import 'core/sync/session_slot.dart';
import 'core/sync/sync_providers.dart';
import 'core/time/time_providers.dart';
import 'features/auth/data/auth_providers.dart';
import 'features/chat/data/driving_mode_source_impl.dart';
import 'features/chat/presentation/chat_providers.dart';
import 'features/drive_mode/presentation/controllers/drive_mode_controller.dart';
import 'features/duty_status/domain/duty_status_models.dart';
import 'features/dvir/presentation/controllers/dvir_providers.dart';
import 'features/notifications/presentation/notification_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muhit noto'g'ri sozlangan bo'lsa ishga tushirishdan oldin yiqiladi.
  Env.validate();

  // §3 (M6): telefon — portret, planshet — landshaft.
  await OrientationLock.apply();

  final SecureVault vault = SecureVault();

  // §17: lokal baza SQLCipher bilan ochiladi; prod/stage da shifrlash
  // yo'q bo'lsa ishga tushirish **to'xtaydi** (fail-closed).
  final ({AppDatabase db, CipherMigration migration}) database = await openEncryptedDatabase(
    vault: vault,
    requireCipher: Env.current != AppFlavor.dev,
  );
  final String deviceId = await vault.deviceId();

  runApp(
    ProviderScope(
      overrides: <Override>[
        secureVaultProvider.overrideWithValue(vault),
        appDatabaseProvider.overrideWithValue(database.db),
        syncDeviceIdProvider.overrideWithValue(deviceId),
        ...bootstrapOverrides(database.db),
      ],
      child: const EldApp(),
    ),
  );

  // S-M2: eski `documents/` dagi imzo PNG va DVIR fotolari (iCloud zaxirasiga
  // tushadigan joy) `app_support` ga ko'chiriladi. Fon amali — ishga tushishni
  // bloklamaydi, xatolar yutiladi.
  unawaited(migrateLegacyFileDirectories(dao: database.db.dvirDao));

  // `device_id` `kv_settings` da ham turadi (outbox va diagnostikaga kerak).
  // Bu yagona joyda `DateTime.now()` ruxsat etilgan: kompozitsiya ildizida
  // `TimeSource` hali qurilmagan, qiymat esa faqat `updated_at` ustuni.
  await database.db.settingsDao.put(
    key: KvKeys.deviceId,
    value: deviceId,
    now: DateTime.now().toUtc(), // ignore: eld_time_source
  );
}

/// `core` provayderlarining modul implementatsiyalariga bog'lanishi.
///
/// Alohida funksiya: integration testlar `main()` ni chaqirmasdan aynan shu
/// ro'yxatni ishlatadi.
List<Override> bootstrapOverrides(AppDatabase db) => <Override>[
  // `kv_settings` — tema/zoom (M94) va sessiya profili shu do'kondan.
  kvStoreProvider.overrideWith(
    (Ref ref) => DriftKvStore(settings: db.settingsDao, now: ref.watch(timeSourceProvider).now),
  ),

  // Yagona autentifikatsiyalangan `Dio` (M5: `core` `features/auth` ga
  // import qila olmaydi, shuning uchun bog'lanish shu yerda).
  syncDioProvider.overrideWith((Ref ref) => ref.watch(authDioProvider)),
  chatDioProvider.overrideWith((Ref ref) => ref.watch(authDioProvider)),
  dvirDioProvider.overrideWith((Ref ref) => ref.watch(authDioProvider)),
  notificationsDioProvider.overrideWith((Ref ref) => ref.watch(authDioProvider)),

  // Sync konteksti (`device_id`, `app_version`).
  syncAppVersionProvider.overrideWith((Ref ref) => ref.watch(resolvedAppVersionProvider).header),

  // #B-136: slot token probe umumiy vault'dan o'qiydi — aks holda
  // `core/sync` o'ziga alohida `SecureVault()` qurar va bootstrap'dagi
  // (SQLCipher kaliti bilan bir xil) nusxa bilan mos kelmasdi.
  slotTokenProbeProvider.overrideWith(
    (Ref ref) => vaultSlotTokenProbe(ref.watch(secureVaultProvider)),
  ),

  // #B-24: M7 modullari sessiyani `core/session/driverSessionProvider` dan
  // oladi — u `sessionProfileProvider` ustidan o'zi hosil bo'ladi, bu yerda
  // override kerak emas.
  currentDriverIdProvider.overrideWith((Ref ref) => ref.watch(sessionProfileProvider).driverId),

  // M140: chat «driving mode» manbai — haqiqiy duty status (`DR`).
  drivingModeSourceProvider.overrideWith((Ref ref) {
    final InMemoryDrivingModeSource source = InMemoryDrivingModeSource();
    source.set(isDriving: ref.read(driveModeControllerProvider).status == DutyStatusValue.driving);
    ref.listen<DriveModeState>(driveModeControllerProvider, (
      DriveModeState? _,
      DriveModeState next,
    ) {
      source.set(isDriving: next.status == DutyStatusValue.driving);
    });
    ref.onDispose(source.dispose);
    return source;
  }),
];
