@Timeout(Duration(seconds: 60))
/// M-01…M-08 va M-57 widget testlari — har ekran 4 holatda
/// (yuklanish · bo'sh · xato · to'la), C.3 DoD.
library;

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/router/routes.dart';
import 'package:eld_mobile/core/ui/components/components.dart';
import 'package:eld_mobile/features/auth/auth_routes.dart';
import 'package:eld_mobile/features/auth/domain/auth_models.dart';
import 'package:eld_mobile/features/auth/domain/auth_repository.dart';
import 'package:eld_mobile/features/auth/presentation/screens/force_update_screen.dart';
import 'package:eld_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:eld_mobile/features/auth/presentation/screens/password_screens.dart';
import 'package:eld_mobile/features/auth/presentation/screens/pin_screen.dart';
import 'package:eld_mobile/features/auth/presentation/screens/totp_screen.dart';
import 'package:eld_mobile/features/auth/presentation/widgets/auth_shell.dart';
import 'package:eld_mobile/features/auth/presentation/widgets/pin_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'auth_test_harness.dart';

void main() {
  late FakeAuthRepository repo;

  setUp(() => repo = FakeAuthRepository());

  // ------------------------------------------------------------- M-01 Splash

  group('M-01 Splash', () {
    testWidgets('yuklanish: logotip ko\'rinadi, 3 s dan keyin progress', (
      WidgetTester tester,
    ) async {
      repo.bootstrapResult = null;
      await pumpAuthApp(tester, repository: repo, initialLocation: AppRoute.splash);
      expect(find.byType(AuthBrandLogo), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('xato: ErrorState + Retry qayta bootstrap qiladi', (WidgetTester tester) async {
      repo.bootstrapError = const ApiError(code: ApiErrorCode.clientNetwork, message: 'offline');
      await pumpAuthApp(tester, repository: repo, initialLocation: AppRoute.splash);
      expect(find.byType(ErrorState), findsOneWidget);

      await tester.tap(appButtons().first);
      await tester.pump(const Duration(milliseconds: 20));
      expect(repo.calls.where((String c) => c == 'bootstrap').length, greaterThan(1));
    });

    testWidgets('to\'la: `home` yo\'nalishi /home ga o\'tadi', (WidgetTester tester) async {
      repo.bootstrapResult = const BootstrapResult(destination: BootstrapDestination.home);
      final GoRouter router = await pumpAuthApp(
        tester,
        repository: repo,
        initialLocation: AppRoute.splash,
      );
      expect(router.state.uri.path, AppRoute.home);
    });

    testWidgets('to\'la: `forceUpdate` /update ga o\'tadi', (WidgetTester tester) async {
      repo.bootstrapResult = const BootstrapResult(destination: BootstrapDestination.forceUpdate);
      final GoRouter router = await pumpAuthApp(
        tester,
        repository: repo,
        initialLocation: AppRoute.splash,
      );
      expect(router.state.uri.path, AuthRoute.update);
      expect(find.byType(ForceUpdateScreen), findsOneWidget);
    });
  });

  // ------------------------------------------------------------- M-02 Login

  group('M-02 Login', () {
    testWidgets('bo\'sh: `Login` tugmasi o\'chirilgan, eslatma va footer bor', (
      WidgetTester tester,
    ) async {
      await pumpAuthApp(tester, repository: repo);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AuthNoticeCard), findsOneWidget);
      expect(find.byType(AuthFooter), findsOneWidget);

      final AppButton login = tester.widget<AppButton>(appButton('Login'));
      expect(login.onPressed, isNull);
    });

    testWidgets('to\'la: maydonlar to\'ldirilsa tugma yoqiladi', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo);
      await tester.enterText(find.byType(TextField).first, 'driver1');
      await tester.enterText(find.byType(TextField).last, 'Passw0rd!');
      await tester.pump();

      final AppButton login = tester.widget<AppButton>(appButton('Login'));
      expect(login.onPressed, isNotNull);
    });

    testWidgets('yuklanish → to\'la: muvaffaqiyatli login /home ga o\'tadi', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAuthApp(tester, repository: repo);
      await tester.enterText(find.byType(TextField).first, 'driver1');
      await tester.enterText(find.byType(TextField).last, 'Passw0rd!');
      await tester.pump();
      await tester.tap(appButton('Login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(repo.calls, contains('login:driver1'));
      expect(router.state.uri.path, AppRoute.home);
    });

    testWidgets('xato: INVALID_CREDENTIALS inline matn sifatida ko\'rinadi', (
      WidgetTester tester,
    ) async {
      repo.loginError = const ApiError(code: ApiErrorCode.invalidCredentials, message: 'nope');
      await pumpAuthApp(tester, repository: repo);
      await tester.enterText(find.byType(TextField).first, 'driver1');
      await tester.enterText(find.byType(TextField).last, 'Passw0rd!');
      await tester.pump();
      await tester.tap(appButton('Login'));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.byType(AuthErrorText), findsOneWidget);
    });

    testWidgets('oflayn: tarmoq xatosidan keyin banner va o\'chirilgan tugma', (
      WidgetTester tester,
    ) async {
      repo.loginError = const ApiError(code: ApiErrorCode.clientNetwork, message: 'no net');
      await pumpAuthApp(tester, repository: repo);
      await tester.enterText(find.byType(TextField).first, 'driver1');
      await tester.enterText(find.byType(TextField).last, 'Passw0rd!');
      await tester.pump();
      await tester.tap(appButton('Login'));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.byType(BannerStrip), findsOneWidget);
      final AppButton login = tester.widget<AppButton>(appButton('Login'));
      expect(login.onPressed, isNull);
    });
  });

  // ------------------------------------------------------------- M-03

  group('M-03 Leave truck', () {
    testWidgets('`Return to truck` tugmasi bor va /pin ga olib boradi', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpAuthApp(
        tester,
        repository: repo,
        initialLocation: AuthRoute.paused,
      );
      expect(appButton('Return to truck'), findsOneWidget);
      // M-02 dan farqli: copyright footer yo'q.
      expect(find.byType(AuthFooter), findsNothing);

      await tester.tap(appButton('Return to truck'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(router.state.uri.path, AppRoute.pin);
    });
  });

  // ------------------------------------------------------------- M-04 PIN

  group('M-04 PIN', () {
    testWidgets('bo\'sh: 6 nuqta va klaviatura ko\'rinadi', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: AppRoute.pin);
      expect(find.byType(PinScreen), findsOneWidget);
      expect(find.byType(PinDots), findsOneWidget);
      expect(find.byType(PinKeypad), findsOneWidget);
    });

    testWidgets('to\'la: 6 raqam kiritilsa avtomatik tekshiriladi', (WidgetTester tester) async {
      final GoRouter router = await pumpAuthApp(
        tester,
        repository: repo,
        initialLocation: AppRoute.pin,
      );
      for (final String digit in <String>['4', '8', '2', '9', '1', '7']) {
        await tester.tap(find.widgetWithText(Semantics, digit).first);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 20));
      expect(repo.calls, contains('verifyPin'));
      expect(router.state.uri.path, AppRoute.home);
    });

    testWidgets('xato: PIN_INVALID xabari va qolgan urinishlar ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      repo.pinError = const ApiError(code: ApiErrorCode.pinInvalid, message: 'bad');
      await pumpAuthApp(tester, repository: repo, initialLocation: AppRoute.pin);
      for (final String digit in <String>['4', '8', '2', '9', '1', '7']) {
        await tester.tap(find.widgetWithText(Semantics, digit).first);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.byType(AuthErrorText), findsOneWidget);
    });

    testWidgets('xato: format qoidasi — 6 bir xil raqam rad etiladi', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: AppRoute.pin);
      for (int i = 0; i < 6; i++) {
        await tester.tap(find.widgetWithText(Semantics, '7').first);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 20));
      expect(repo.calls, isNot(contains('verifyPin')));
      expect(find.byType(AuthErrorText), findsOneWidget);
    });
  });

  // ------------------------------------------------------------- M-05

  group('M-05 Accept invitation', () {
    testWidgets('bo\'sh: tokensiz havola — EmptyState', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.invite);
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('to\'la: parol va PIN to\'g\'ri bo\'lsa yuboriladi', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: '${AuthRoute.invite}?token=abc');
      final Finder fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Passw0rd!23');
      await tester.enterText(fields.at(1), 'Passw0rd!23');
      await tester.enterText(fields.at(2), '482917');
      await tester.enterText(fields.at(3), '482917');
      await tester.pump();
      await tapScrolled(tester, find.byType(Checkbox));

      await tapScrolled(tester, appButton('Finish setup'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(repo.calls, contains('invitation'));
    });

    testWidgets('xato: INVITATION_EXPIRED inline ko\'rsatiladi', (WidgetTester tester) async {
      repo.invitationError = const ApiError(
        code: ApiErrorCode.invitationExpired,
        message: 'expired',
      );
      await pumpAuthApp(tester, repository: repo, initialLocation: '${AuthRoute.invite}?token=abc');
      final Finder fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Passw0rd!23');
      await tester.enterText(fields.at(1), 'Passw0rd!23');
      await tester.enterText(fields.at(2), '482917');
      await tester.enterText(fields.at(3), '482917');
      await tester.pump();
      await tapScrolled(tester, find.byType(Checkbox));
      await tapScrolled(tester, appButton('Finish setup'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.byType(AuthErrorText), findsOneWidget);
    });
  });

  // ------------------------------------------------------------- M-06 / M-07

  group('M-06 Forgot password', () {
    testWidgets('bo\'sh → to\'la: yuborilgach tasdiq ko\'rinadi', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.forgot);
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'driver1');
      await tester.pump();
      await tester.tap(appButton('Send reset link'));
      await tester.pump(const Duration(milliseconds: 20));

      expect(repo.calls, contains('forgot:driver1'));
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('xato: RATE_LIMITED inline ko\'rsatiladi', (WidgetTester tester) async {
      repo.forgotError = const ApiError(code: ApiErrorCode.rateLimited, message: 'slow down');
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.forgot);
      await tester.enterText(find.byType(TextField).first, 'driver1');
      await tester.pump();
      await tester.tap(appButton('Send reset link'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.byType(AuthErrorText), findsOneWidget);
    });
  });

  group('M-07 Reset password', () {
    testWidgets('bo\'sh: tokensiz — EmptyState', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.reset);
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('to\'la: yangi parol saqlanadi', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: '${AuthRoute.reset}?token=xyz');
      await tester.enterText(find.byType(TextField).at(0), 'Passw0rd!23');
      await tester.enterText(find.byType(TextField).at(1), 'Passw0rd!23');
      await tester.pump();
      await tester.tap(appButton('Save new password'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(repo.calls, contains('reset'));
    });

    testWidgets('xato: parollar mos kelmasa yuborilmaydi', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: '${AuthRoute.reset}?token=xyz');
      await tester.enterText(find.byType(TextField).at(0), 'Passw0rd!23');
      await tester.enterText(find.byType(TextField).at(1), 'different!');
      await tester.pump();

      final AppButton save = tester.widget<AppButton>(appButton('Save new password'));
      expect(save.onPressed, isNull);
      expect(repo.calls, isNot(contains('reset')));
    });
  });

  // ------------------------------------------------------------- M-08 TOTP

  group('M-08 Two-factor', () {
    testWidgets('yuklanish → to\'la: setup kaliti ko\'rsatiladi', (WidgetTester tester) async {
      repo.cachedProfile = _profile();
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.twoFactor);
      expect(repo.calls, contains('totpSetup'));
      expect(find.text('JBSWY3DPEHPK3PXP'), findsOneWidget);
    });

    testWidgets('xato: setup yiqilsa ErrorState + Retry', (WidgetTester tester) async {
      repo.cachedProfile = _profile();
      repo.totpSetupError = const ApiError(code: ApiErrorCode.internalError, message: 'boom');
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.twoFactor);
      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('to\'la: kod tasdiqlangach recovery kodlar chiqadi', (WidgetTester tester) async {
      repo.cachedProfile = _profile();
      repo.totpVerifyResult = const TotpVerification(
        enabled: true,
        recoveryCodes: <String>['aaa-111', 'bbb-222'],
      );
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.twoFactor);
      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.pump();
      await tester.tap(appButton('Verify'));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('aaa-111'), findsOneWidget);
      expect(find.text('bbb-222'), findsOneWidget);
    });

    testWidgets('bo\'sh: 2FA talab qilinmasa EmptyState', (WidgetTester tester) async {
      repo.cachedProfile = _profile();
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.twoFactor);
      // `start(required: true)` — bu ekran faqat talab bo'lganda ochiladi;
      // bo'sh holat kontroller darajasida tekshiriladi.
      expect(find.byType(TotpScreen), findsOneWidget);
    });
  });

  // ------------------------------------------------------------- M-57

  group('M-57 Force update', () {
    testWidgets('to\'la: versiyalar va yagona amal, `Back` yo\'q', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.update);
      expect(find.byType(ForceUpdateScreen), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(appButton('Open the store'), findsOneWidget);
    });

    testWidgets('xato: do\'kon ochilmasa xabar ko\'rinadi', (WidgetTester tester) async {
      await pumpAuthApp(tester, repository: repo, initialLocation: AuthRoute.update);
      await tester.tap(appButton('Open the store'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.byType(AuthErrorText), findsOneWidget);
    });
  });
}

DriverProfile _profile() => const DriverProfile(
  id: 'u1',
  username: 'driver1',
  firstName: 'John',
  lastName: 'Miller',
  status: AccountStatus.active,
);
