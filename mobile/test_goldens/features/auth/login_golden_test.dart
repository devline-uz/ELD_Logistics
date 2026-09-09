@Timeout(Duration(seconds: 120))
/// `M-02 Login` goldenlari (Figma `958:44` / dark `2665:32374`).
///
/// 4 holat: bo'sh (tugma o'chirilgan) · to'la · yuklanish (spinner) · xato.
/// Yangilash: `flutter test test_goldens/features/auth --update-goldens`.
library;

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/features/auth/presentation/controllers/form_status.dart';
import 'package:eld_mobile/features/auth/presentation/controllers/login_controller.dart';
import 'package:eld_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/core/helpers/test_clock.dart';
import '../../golden_harness.dart';
import '../golden_screen_host.dart';

class _FixedLoginController extends LoginController {
  _FixedLoginController(this._initial);

  final LoginState _initial;

  @override
  LoginState build() => _initial;
}

List<Override> _overrides(LoginState state) => <Override>[
  loginControllerProvider.overrideWith(() => _FixedLoginController(state)),
  timeSourceProvider.overrideWithValue(buildTestTimeSource(DateTime.utc(2026, 9, 8)).time),
];

void main() {
  screenGoldenMatrix(
    'm02_login_empty',
    builder: () => const LoginScreen(mode: LoginMode.signIn),
    overrides: () => _overrides(const LoginState()),
  );

  screenGoldenMatrix(
    'm02_login_filled',
    builder: () => const LoginScreen(mode: LoginMode.signIn),
    overrides: () => _overrides(
      const LoginState(username: 'driver@example.com', password: 'secret123'),
    ),
  );

  screenGoldenMatrix(
    'm02_login_loading',
    builder: () => const LoginScreen(mode: LoginMode.signIn),
    overrides: () => _overrides(
      const LoginState(
        username: 'driver@example.com',
        password: 'secret123',
        status: FormStatus.submitting(),
      ),
    ),
    pumpBeforeTest: pumpOnce,
  );

  screenGoldenMatrix(
    'm02_login_error',
    builder: () => const LoginScreen(mode: LoginMode.signIn),
    overrides: () => _overrides(
      LoginState(
        username: 'driver@example.com',
        password: 'secret123',
        showFieldErrors: true,
        status: FormStatus.failure(
          const ApiError(code: ApiErrorCode.invalidCredentials, message: 'invalid credentials'),
        ),
      ),
    ),
  );
}
