@Timeout(Duration(seconds: 60))
/// Regressiya #B-1 (`M-44 Profile`): `Logout` **idempotent va best-effort**.
///
/// Real qurilma logi: birinchi bosishda `204`, lekin lokal sessiya tozalanmadi
/// va ekran o'zgarmadi → haydovchi tugmani qayta bosdi → `401 TOKEN_REVOKED`
/// → `Unhandled Exception: DioException`.
library;

import 'package:eld_mobile/core/eld/eld_connection_manager.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/mock_eld_transport.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/router/auth_state.dart';
import 'package:eld_mobile/core/session/session_terminator.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:eld_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';
import '../auth/session_test_fakes.dart';
import 'm11_test_harness.dart';

ProviderContainer _container(FakeProfileRepository repo) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      ...m11Overrides(profile: repo),
      sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
      eldTransportProvider.overrideWithValue(
        MockEldTransport(
          time: buildTestTimeSource(DateTime.utc(2025, 5, 28, 19, 40)).time,
          scanDelay: Duration.zero,
          connectDelay: Duration.zero,
        ),
      ),
      eldDeviceStoreProvider.overrideWithValue(InMemoryEldDeviceStore()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logout 401 TOKEN_REVOKED da yiqilmaydi, lokal sessiya tozalanadi', () async {
    final FakeProfileRepository repo = FakeProfileRepository()
      ..logoutError = const ApiError(code: ApiErrorCode.tokenRevoked, message: 'revoked');
    final ProviderContainer container = _container(repo);
    await container.read(profileControllerProvider.future);

    await expectLater(container.read(profileControllerProvider.notifier).logout(), completes);

    expect(repo.calls, contains('logout'));
    expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
    // Qo'riqchi shu holatda `/login` ga o'tkazadi.
    expect(container.read(authStatusProvider), AuthStatus.unauthenticated);
    expect(container.read(sessionEndReasonProvider), SessionEndReason.none);
  });

  test('muvaffaqiyatli logout ham lokal sessiyani tozalaydi (tugma qayta bosilmaydi)', () async {
    final FakeProfileRepository repo = FakeProfileRepository();
    final ProviderContainer container = _container(repo);
    await container.read(profileControllerProvider.future);

    await container.read(profileControllerProvider.notifier).logout();

    expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
    expect(container.read(authStatusProvider), AuthStatus.unauthenticated);
  });
}
