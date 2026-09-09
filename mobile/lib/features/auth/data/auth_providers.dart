/// Auth modulining DI si (Riverpod; `get_it` YO'Q — M3).
///
/// **TODO(core):** `apiClientProvider` mantiqan `core/network` ga tegishli.
/// Hozircha `core/` boshqa agent qo'lida, shuning uchun u shu yerda yig'iladi
/// va nomi `auth*` prefiksi bilan ajratilgan (nom to'qnashuvi bo'lmasin).
library;

import 'dart:ui' show FlutterView, PlatformDispatcher;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/device/app_version.dart';
import '../../../core/device/device_profile.dart';
import '../../../core/error/api_error.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/refresh_coordinator.dart';
import '../../../core/security/active_slot.dart';
import '../../../core/security/secure_vault.dart';
import '../../../core/session/session_terminator.dart';
import '../../../core/time/time_providers.dart';
import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';
import '../domain/session_state.dart';
import 'auth_api.dart';
import 'auth_repository_impl.dart';
import 'pin_lockout_store.dart';
import 'session_manager.dart';

/// Sirlar ombori — butun ilova uchun yagona instans.
final Provider<SecureVault> secureVaultProvider = Provider<SecureVault>((Ref ref) => SecureVault());

final Provider<PinLockoutStore> pinLockoutStoreProvider = Provider<PinLockoutStore>(
  (Ref ref) => PinLockoutStore(),
);

/// M163: prod build'da log yozilmaydi (`LoggingInterceptor` ham o'chadi).
final Provider<Logger> authLoggerProvider = Provider<Logger>(
  (Ref ref) => Logger(printer: SimplePrinter(printTime: true)),
);

/// `package_info_plus` dan versiya. Test/golden'da override qilinadi.
final FutureProvider<AppVersion> appVersionProvider = FutureProvider<AppVersion>(
  (Ref ref) => AppVersion.load(),
);

/// M6/M7: `device_type` `shortestSide` bo'yicha aniqlanadi, `BuildContext`
/// kerak emas — `PlatformDispatcher` birinchi ko'rinishi yetarli.
final Provider<DeviceKind> deviceKindProvider = Provider<DeviceKind>((Ref ref) {
  final FlutterView view = PlatformDispatcher.instance.views.first;
  final DeviceProfile profile = DeviceProfile.fromSize(view.physicalSize / view.devicePixelRatio);
  return profile.isTablet ? DeviceKind.tablet : DeviceKind.phone;
});

/// Refresh mutexi (§4.7).
///
/// Graf **bir yo'nalishli**: `authDio → refreshCoordinator →
/// tokenRefreshClient → refreshAuthApi → authRefreshDio`. Refresh o'zining
/// alohida, `AuthInterceptor` siz transportida ketgani uchun sikl yo'q
/// (avvalgi `Dio → coordinator → AuthApi → Dio` zanjiri `CircularDependencyError`
/// bergan edi va har bir autentifikatsiyalangan so'rovni yiqitgan).
final Provider<RefreshCoordinator> refreshCoordinatorProvider = Provider<RefreshCoordinator>((
  Ref ref,
) {
  return RefreshCoordinator(
    vault: ref.watch(secureVaultProvider),
    client: ref.watch(authTokenRefreshClientProvider),
    // #B-3: refresh `TOKEN_REVOKED` qaytarsa sessiya majburiy tugatiladi —
    // aks holda ilova tokensiz «login qilingan» holatda osilib qolardi.
    // `ref.read` chaqiruv paytida bajariladi, shuning uchun grafda sikl yo'q.
    onSessionTerminated: (DriverSlot slot, ApiError error) =>
        ref.read(sessionTerminatorProvider).terminateRevoked(slot, error),
  );
});

/// `POST /auth/refresh` uchun sof transport — `refreshCoordinator` ga
/// bog'liq emas, shu sababli grafda qaytish yoyi hosil qilmaydi.
final Provider<Dio> authRefreshDioProvider = Provider<Dio>(
  (Ref ref) => ApiClient.createRefreshTransport(
    vault: ref.watch(secureVaultProvider),
    appVersion: ref.watch(resolvedAppVersionProvider).header,
    logger: ref.watch(authLoggerProvider),
  ),
);

/// Faqat refresh uchun `AuthApi` (interceptorsiz Dio ustida).
final Provider<AuthApi> authRefreshApiProvider = Provider<AuthApi>(
  (Ref ref) => AuthApi(ref.watch(authRefreshDioProvider)),
);

final Provider<TokenRefreshClient> authTokenRefreshClientProvider = Provider<TokenRefreshClient>(
  (Ref ref) => AuthTokenRefreshClient(
    api: ref.watch(authRefreshApiProvider),
    appVersion: ref.watch(resolvedAppVersionProvider),
    timeSource: ref.watch(timeSourceProvider),
  ),
);

/// `AppVersion` sinxron ko'rinishi. Yuklanmagan bo'lsa `pubspec` qiymati
/// o'rniga bo'sh emas, xavfsiz zaxira ishlatiladi.
final Provider<AppVersion> resolvedAppVersionProvider = Provider<AppVersion>(
  (Ref ref) =>
      ref.watch(appVersionProvider).value ??
      const AppVersion(version: '0.0.0', buildNumber: '0', packageName: 'unknown'),
);

/// Yagona `Dio` — `http` paketi taqiq.
final Provider<Dio> authDioProvider = Provider<Dio>(
  (Ref ref) => ApiClient.create(
    vault: ref.watch(secureVaultProvider),
    refreshCoordinator: ref.watch(refreshCoordinatorProvider),
    appVersion: ref.watch(resolvedAppVersionProvider).header,
    logger: ref.watch(authLoggerProvider),
    // M9: aniq slot berilmagan so'rovlar faol haydovchi nomidan ketadi.
    activeSlot: ref.watch(activeSlotHolderProvider),
  ).dio,
);

final Provider<AuthApi> authApiProvider = Provider<AuthApi>(
  (Ref ref) => AuthApi(ref.watch(authDioProvider)),
);

/// Slot bo'yicha repozitoriy (**M9**): har slotning o'z tokeni, o'z
/// `paused` bayrog'i va o'z profil keshi bo'ladi — ular aralashmaydi.
final Provider<AuthRepository> Function(DriverSlot) slotAuthRepositoryProvider =
    Provider.family<AuthRepository, DriverSlot>(
      (Ref ref, DriverSlot slot) => AuthRepositoryImpl(
        api: ref.watch(authApiProvider),
        vault: ref.watch(secureVaultProvider),
        lockoutStore: ref.watch(pinLockoutStoreProvider),
        // S-C1: `paused` holati diskda — `SessionManager` bilan bitta manba.
        sessionStore: ref.watch(sessionStoreProvider),
        timeSource: ref.watch(timeSourceProvider),
        appVersion: ref.watch(resolvedAppVersionProvider),
        deviceKind: ref.watch(deviceKindProvider),
        slot: slot,
      ),
    );

/// Asosiy slot repozitoriysi (`M-01`…`M-08` oqimlari shu bilan ishlaydi).
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) => ref.watch(slotAuthRepositoryProvider(DriverSlot.primary)),
);

/// Faol haydovchi repozitoriysi — `Leave Truck`, `Switch co-driver`, `M-58`.
///
/// Testda `authRepositoryProvider` override qilinsa ham ishlashi uchun
/// asosiy slotda aynan o'sha instans qaytariladi.
final Provider<AuthRepository> activeAuthRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final DriverSlot slot = ref.watch(
    sessionManagerProvider.select((DualSessionState s) => s.activeSlot),
  );
  return slot == DriverSlot.primary
      ? ref.watch(authRepositoryProvider)
      : ref.watch(slotAuthRepositoryProvider(slot));
});
