@Timeout(Duration(seconds: 60))
/// Regressiya (#B-1, #B-2, #B-3): chiqish oqimi **hech qachon** istisno
/// tashlamaydi va lokal sessiya har holda tozalanadi.
///
/// Real qurilma logi: `POST /auth/logout → 204`, keyin ikkinchi bosishda
/// `401 TOKEN_REVOKED` → `Unhandled Exception: DioException`. Sabab: 204 dan
/// keyin lokal holat tozalanmagan (tugma qayta bosilgan) va `logout` da xato
/// ushlanmagan.
library;

import 'package:dio/dio.dart';
import 'package:eld_mobile/core/eld/eld_connection_manager.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/mock_eld_transport.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/location/location_models.dart';
import 'package:eld_mobile/core/location/location_providers.dart';
import 'package:eld_mobile/core/location/location_service.dart';
import 'package:eld_mobile/core/router/auth_state.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/session/session_terminator.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/auth/session_test_fakes.dart';
import '../helpers/test_clock.dart';

/// Platforma kanali yo'q qurilma (#B-2) — har chaqiruv yiqiladi.
final class _BrokenLocationService extends BaseLocationService {
  _BrokenLocationService() : super(now: DateTime.now);

  int startCalls = 0;

  @override
  Future<void> start(LocationProfile profile) async {
    startCalls++;
    throw MissingPluginException(
      'No implementation found for method start on channel eld/location',
    );
  }

  @override
  Future<void> stop() async {
    throw MissingPluginException('No implementation found for method stop on channel eld/location');
  }
}

ProviderContainer _container({_BrokenLocationService? location}) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
      // BLE va Drift ga chiqilmaydi: chiqish oqimi ELD ni ham to'xtatadi.
      eldTransportProvider.overrideWithValue(
        MockEldTransport(
          time: buildTestTimeSource(DateTime.utc(2025, 5, 28, 19, 40)).time,
          scanDelay: Duration.zero,
          connectDelay: Duration.zero,
        ),
      ),
      eldDeviceStoreProvider.overrideWithValue(InMemoryEldDeviceStore()),
      if (location != null) locationServiceProvider.overrideWithValue(location),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logout 401 TOKEN_REVOKED da ham lokal sessiya tozalanadi va login ochiladi', () async {
    final ProviderContainer container = _container();
    expect(container.read(sessionManagerProvider).isSignedOut, isFalse);

    await container
        .read(sessionTerminatorProvider)
        .signOut(
          serverLogout: () async =>
              throw const ApiError(code: ApiErrorCode.tokenRevoked, message: 'revoked'),
        );

    expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
    expect(container.read(authStatusProvider), AuthStatus.unauthenticated);
    // Oddiy chiqish — `M-56` emas, `/login`.
    expect(container.read(sessionEndReasonProvider), SessionEndReason.none);
  });

  test('xom DioException ham yutiladi — unhandled exception yo\'q', () async {
    final ProviderContainer container = _container();

    await expectLater(
      container
          .read(sessionTerminatorProvider)
          .signOut(
            serverLogout: () async => throw DioException(
              requestOptions: RequestOptions(path: '/auth/logout'),
              response: Response<Object?>(
                requestOptions: RequestOptions(path: '/auth/logout'),
                statusCode: 401,
              ),
            ),
          ),
      completes,
    );
    expect(container.read(authStatusProvider), AuthStatus.unauthenticated);
  });

  test('logout ikki marta bosilsa ikkinchisi ham xavfsiz', () async {
    final ProviderContainer container = _container();
    final SessionTerminator terminator = container.read(sessionTerminatorProvider);
    int calls = 0;

    await terminator.signOut(serverLogout: () async => calls++);
    await expectLater(
      terminator.signOut(
        serverLogout: () async {
          calls++;
          throw const ApiError(code: ApiErrorCode.tokenRevoked, message: 'revoked');
        },
      ),
      completes,
    );

    expect(calls, 2);
    expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
    expect(container.read(authStatusProvider), AuthStatus.unauthenticated);
  });

  test('MissingPluginException(eld/location) chiqish oqimini to\'xtatmaydi', () async {
    final _BrokenLocationService location = _BrokenLocationService();
    final ProviderContainer container = _container(location: location);

    await expectLater(
      container.read(sessionTerminatorProvider).signOut(serverLogout: () async {}),
      completes,
    );

    expect(location.startCalls, 1, reason: 'GPS to\'xtatishga urinilgan');
    expect(container.read(authStatusProvider), AuthStatus.unauthenticated);
  });

  test('refresh TOKEN_REVOKED → majburiy chiqish, sabab `revoked`', () async {
    final ProviderContainer container = _container();

    await container
        .read(sessionTerminatorProvider)
        .terminateRevoked(
          DriverSlot.primary,
          const ApiError(code: ApiErrorCode.tokenRevoked, message: 'revoked'),
        );

    expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
    expect(container.read(authStatusProvider), AuthStatus.unauthenticated);
    expect(container.read(sessionEndReasonProvider), SessionEndReason.revoked);
  });
}
