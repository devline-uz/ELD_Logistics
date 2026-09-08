@Timeout(Duration(seconds: 60))
/// **S-C1** — `Leave Truck` pauzasi diskda saqlanadi (M18 / §4.8).
///
/// Regressiya: ilgari `AuthRepositoryImpl._paused` faqat RAM da edi — ilovani
/// o'ldirib qayta ochish PIN qulfini **butunlay chetlab o'tar** edi. Bu yerda
/// «qayta ishga tushirish» yangi repozitoriy instansi (yangi RAM) bilan, lekin
/// **o'sha** secure storage bilan modellashtiriladi.
///
/// Shu faylda `S-M4` (to'liq chiqishda vault tozalanishi) ham tekshiriladi.
library;

import 'package:dio/dio.dart';
import 'package:eld_mobile/core/device/app_version.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/auth/data/auth_api.dart';
import 'package:eld_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:eld_mobile/features/auth/data/pin_lockout_store.dart';
import 'package:eld_mobile/features/auth/data/session_store.dart';
import 'package:eld_mobile/features/auth/domain/auth_models.dart';
import 'package:eld_mobile/features/auth/domain/auth_repository.dart';
import 'package:eld_mobile/features/auth/domain/session_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';
import 'secure_storage_mock.dart';

/// Har so'rovni tarmoqsiz rad etadigan adapter — bootstrap «oflayn» yo'lidan
/// ketadi, lekin pauza tekshiruvi undan **oldin** bo'ladi.
class _OfflineAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    throw DioException.connectionError(requestOptions: options, reason: 'offline test');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> storage;
  late SecureVault vault;
  late SessionStore sessions;
  late _OfflineAdapter adapter;
  late TimeSource time;

  AuthRepository buildRepository() => AuthRepositoryImpl(
    api: AuthApi(
      Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))..httpClientAdapter = adapter,
    ),
    vault: vault,
    lockoutStore: PinLockoutStore(storage: const FlutterSecureStorage()),
    sessionStore: sessions,
    timeSource: time,
    appVersion: const AppVersion(version: '1.0.0', buildNumber: '1', packageName: 'test'),
    deviceKind: DeviceKind.phone,
  );

  setUp(() {
    storage = installMockSecureStorage();
    vault = SecureVault(storage: const FlutterSecureStorage());
    sessions = SessionStore(vault);
    adapter = _OfflineAdapter();
    time = buildTestTimeSource(DateTime.utc(2026, 9, 8, 12)).time;
    addTearDown(time.dispose);
  });

  group('S-C1 pauza doimiy saqlanadi', () {
    test('Leave Truck → ilovani qayta ishga tushirish → PIN ekrani', () async {
      await vault.writeRefreshToken(DriverSlot.primary, 'refresh-token');
      await sessions.write(
        const DualSessionState.signedOut().withSlot(
          const SessionSlotState(
            slot: DriverSlot.primary,
            status: SessionStatus.active,
            driverId: 'drv-1',
            driverName: 'John Smith',
          ),
        ),
      );

      // 1. Leave Truck (tarmoq yo'q — oflayn ham holat darhol o'zgaradi).
      await buildRepository().logout(pause: true);

      // Diskda `paused` turibdi, refresh token esa TIRIK (M18).
      expect((await sessions.read()).primary.status, SessionStatus.paused);
      expect(await vault.readRefreshToken(DriverSlot.primary), 'refresh-token');

      // 2. «Ilovani o'ldirib qayta ochamiz»: yangi vault + yangi repozitoriy,
      //    o'sha secure storage.
      final SecureVault restarted = SecureVault(storage: const FlutterSecureStorage());
      sessions = SessionStore(restarted);
      vault = restarted;

      final BootstrapResult result = await buildRepository().bootstrap();

      expect(result.destination, BootstrapDestination.paused);
      expect(result.pausedDriverName, 'John Smith');
    });

    test('pauzani diskka yozib bo\'lmasa refresh token o\'chadi (fail-closed)', () async {
      await vault.writeRefreshToken(DriverSlot.primary, 'refresh-token');
      failMockSecureStorageWrites(VaultKeys.sessionSlots);

      await buildRepository().logout(pause: true);

      expect(await vault.readRefreshToken(DriverSlot.primary), isNull);
      // Token yo'q → bootstrap Login ga oladi, PIN chetlab o'tilmaydi.
      expect((await buildRepository().bootstrap()).destination, BootstrapDestination.login);
    });

    test('pauzalanmagan slot uy ekraniga o\'tadi', () async {
      await vault.writeRefreshToken(DriverSlot.primary, 'refresh-token');
      await sessions.write(
        const DualSessionState.signedOut().withSlot(
          const SessionSlotState(
            slot: DriverSlot.primary,
            status: SessionStatus.active,
            driverId: 'drv-1',
            driverName: 'John Smith',
          ),
        ),
      );

      final BootstrapResult result = await buildRepository().bootstrap();

      expect(result.destination, BootstrapDestination.home);
      expect(result.offline, isTrue);
    });

    test('co-driver sloti pauzada bo\'lsa asosiy slot ta\'sirlanmaydi', () async {
      await vault.writeRefreshToken(DriverSlot.primary, 'primary-token');
      await vault.writeRefreshToken(DriverSlot.coDriver, 'co-token');
      await sessions.write(
        const DualSessionState.signedOut()
            .withSlot(
              const SessionSlotState(
                slot: DriverSlot.primary,
                status: SessionStatus.active,
                driverId: 'drv-1',
              ),
            )
            .withSlot(
              const SessionSlotState(
                slot: DriverSlot.coDriver,
                status: SessionStatus.paused,
                driverId: 'drv-2',
              ),
            ),
      );

      expect((await buildRepository().bootstrap()).destination, BootstrapDestination.home);
    });
  });

  group('S-M4 to\'liq chiqishda vault tozalanadi', () {
    test('oxirgi haydovchi chiqsa PIN, sessiya va tokenlar o\'chadi', () async {
      await vault.writeRefreshToken(DriverSlot.primary, 'refresh-token');
      await vault.writePin(hash: 'h', salt: 's');
      await sessions.write(
        const DualSessionState.signedOut().withSlot(
          const SessionSlotState(
            slot: DriverSlot.primary,
            status: SessionStatus.active,
            driverId: 'drv-1',
            driverName: 'John Smith',
          ),
        ),
      );

      await buildRepository().logout(pause: false);

      expect(await vault.readRefreshToken(DriverSlot.primary), isNull);
      expect(await vault.readPin(), isNull);
      expect(storage[VaultKeys.sessionSlots], isNull);
      // `device_id` va baza kaliti saqlanadi.
      expect(storage.containsKey(VaultKeys.databaseKey), isFalse);
    });

    test('co-driver qolsa uning PIN hashi va tokeni saqlanadi', () async {
      await vault.writeRefreshToken(DriverSlot.primary, 'primary-token');
      await vault.writeRefreshToken(DriverSlot.coDriver, 'co-token');
      await vault.writePin(hash: 'h', salt: 's');
      await sessions.write(
        const DualSessionState.signedOut()
            .withSlot(
              const SessionSlotState(
                slot: DriverSlot.primary,
                status: SessionStatus.active,
                driverId: 'drv-1',
              ),
            )
            .withSlot(
              const SessionSlotState(
                slot: DriverSlot.coDriver,
                status: SessionStatus.active,
                driverId: 'drv-2',
              ),
            ),
      );

      await buildRepository().logout(pause: false);

      expect(await vault.readRefreshToken(DriverSlot.primary), isNull);
      expect(await vault.readRefreshToken(DriverSlot.coDriver), 'co-token');
      expect(await vault.readPin(), isNotNull);
      expect((await sessions.read()).coDriver.status, SessionStatus.active);
      expect((await sessions.read()).primary.status, SessionStatus.empty);
    });

    test('clearAllSecrets device_id ni saqlaydi', () async {
      final String id = await vault.deviceId();
      await vault.writeRefreshToken(DriverSlot.coDriver, 'co-token');

      await vault.clearAllSecrets();

      expect(await vault.deviceId(), id);
      expect(await vault.readRefreshToken(DriverSlot.coDriver), isNull);
    });
  });
}
