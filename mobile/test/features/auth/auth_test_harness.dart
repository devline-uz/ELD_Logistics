/// Auth ekranlari uchun umumiy test qobig'i: soxta repozitoriy + router.
library;

import 'dart:async';

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/router/routes.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/core/ui/components/components.dart';
import 'package:eld_mobile/core/ui/theme.dart';
import 'package:eld_mobile/features/auth/auth_routes.dart';
import 'package:eld_mobile/features/auth/data/auth_providers.dart';
import 'package:eld_mobile/features/auth/domain/auth_models.dart';
import 'package:eld_mobile/features/auth/domain/auth_policies.dart';
import 'package:eld_mobile/features/auth/domain/auth_repository.dart';
import 'package:eld_mobile/features/auth/domain/driver_session.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../core/helpers/test_clock.dart';

/// Test uchun to'liq boshqariladigan `AuthRepository`.
///
/// Har metod uchun natija yoki tashlanadigan xato oldindan beriladi —
/// tarmoq/soat/`SecureVault` ga umuman tegilmaydi.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.bootstrapResult, this.bootstrapError, this.bootstrapGate});

  BootstrapResult? bootstrapResult;
  ApiError? bootstrapError;

  /// Berilsa — `bootstrap()` shu `Completer` ochilmaguncha tugamaydi.
  /// Splash ekranini «yuklanmoqda» holatida ushlab turish uchun.
  final Completer<void>? bootstrapGate;

  LoginOutcome? loginResult;
  ApiError? loginError;

  PinVerification? pinResult;
  ApiError? pinError;
  PinLockoutState lockout = const PinLockoutState();

  /// `logout()` shu xatoni tashlaydi (oflayn / server xatosi stsenariylari).
  ApiError? logoutError;

  ApiError? forgotError;
  ApiError? resetError;
  ApiError? invitationError;

  /// `M-58 Sessions` uchun.
  List<DriverSession> sessionList = const <DriverSession>[];
  ApiError? sessionsError;
  final List<String> revokedSessions = <String>[];

  TotpSetup? totpSetupResult;
  ApiError? totpSetupError;
  TotpVerification? totpVerifyResult;
  ApiError? totpVerifyError;

  @override
  AppConfig? cachedConfig = const AppConfig(latestVersion: '2.0.0');

  @override
  DriverProfile? cachedProfile;

  @override
  DriverRecord? cachedDriverRecord;

  @override
  Future<DriverRecord?> loadDriverRecord() async => cachedDriverRecord;

  /// Har chaqiruvni sanaydi — testlar tekshiradi.
  final List<String> calls = <String>[];

  @override
  Future<List<DriverSession>> sessions() async {
    calls.add('sessions');
    if (sessionsError != null) {
      throw sessionsError!;
    }
    return sessionList;
  }

  @override
  Future<void> revokeSession(String id) async {
    calls.add('revokeSession');
    if (sessionsError != null) {
      throw sessionsError!;
    }
    revokedSessions.add(id);
  }

  @override
  Future<BootstrapResult> bootstrap() async {
    calls.add('bootstrap');
    if (bootstrapGate != null) {
      await bootstrapGate!.future;
    }
    if (bootstrapError != null) {
      throw bootstrapError!;
    }
    return bootstrapResult ?? const BootstrapResult(destination: BootstrapDestination.login);
  }

  @override
  Future<LoginOutcome> login({
    required String username,
    required String password,
    String? totpCode,
  }) async {
    calls.add('login:$username');
    if (loginError != null) {
      throw loginError!;
    }
    return loginResult ??
        const LoginOutcome(
          tokens: AuthTokens(accessToken: 'a', refreshToken: 'r'),
        );
  }

  @override
  Future<void> logout({required bool pause}) async {
    calls.add('logout:$pause');
    if (logoutError != null) {
      throw logoutError!;
    }
  }

  @override
  Future<PinVerification> verifyPin({required String pin, required PinAction action}) async {
    calls.add('verifyPin');
    if (pinError != null) {
      throw pinError!;
    }
    return pinResult ?? PinVerification(verified: true, action: action);
  }

  @override
  Future<PinLockoutState> pinLockout() async => lockout;

  @override
  Future<void> requestPasswordReset({required String login}) async {
    calls.add('forgot:$login');
    if (forgotError != null) {
      throw forgotError!;
    }
  }

  @override
  Future<void> resetPassword({required String token, required String password}) async {
    calls.add('reset');
    if (resetError != null) {
      throw resetError!;
    }
  }

  @override
  Future<void> acceptInvitation({
    required String token,
    required String password,
    required String pin,
  }) async {
    calls.add('invitation');
    if (invitationError != null) {
      throw invitationError!;
    }
  }

  @override
  Future<TotpSetup> startTotpSetup() async {
    calls.add('totpSetup');
    if (totpSetupError != null) {
      throw totpSetupError!;
    }
    return totpSetupResult ?? const TotpSetup(secret: 'JBSWY3DPEHPK3PXP');
  }

  @override
  Future<TotpVerification> verifyTotp({String? code, String? recoveryCode}) async {
    calls.add('totpVerify');
    if (totpVerifyError != null) {
      throw totpVerifyError!;
    }
    return totpVerifyResult ?? const TotpVerification(enabled: true);
  }

  @override
  Future<DriverProfile> me() async => cachedProfile!;
}

/// Auth marshrutlari + `/home` zaxira sahifasi bilan router.
GoRouter buildAuthRouter({String initialLocation = AppRoute.login}) => GoRouter(
  initialLocation: initialLocation,
  routes: <RouteBase>[
    ...authRoutes,
    GoRoute(
      path: AppRoute.home,
      builder: (BuildContext context, GoRouterState state) =>
          const Scaffold(body: Center(child: Text('home-stub'))),
    ),
  ],
);

/// Ekranni to'liq ilova kontekstida ko'taradi (tema, l10n, router, DI).
Future<GoRouter> pumpAuthApp(
  WidgetTester tester, {
  required FakeAuthRepository repository,
  String initialLocation = AppRoute.login,
  Size surface = const Size(393, 852),
  Brightness brightness = Brightness.light,
  List<Override> overrides = const <Override>[],
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final TimeSource time = buildTestTimeSource(DateTime.utc(2026, 9, 7, 12)).time;
  addTearDown(time.dispose);

  final GoRouter router = buildAuthRouter(initialLocation: initialLocation);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(repository),
        timeSourceProvider.overrideWithValue(time),
        ...overrides,
      ],
      child: MaterialApp.router(
        theme: AppTheme.of(brightness),
        localizationsDelegates: const <LocalizationsDelegate<Object?>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  // `pumpAndSettle` emas: spinnerlar cheksiz animatsiya beradi.
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  return router;
}

// ---------------------------------------------------------------- Finderlar
//
// `AppButton.primary/secondary/text` — yopiq subklasslarni (`_PrimaryButton`,
// `_SecondaryButton`, `_TextButton`) qaytaruvchi fabrika konstruktorlari.
// `find.byType` **aniq** `runtimeType` ni solishtiradi, shuning uchun
// `find.byType(AppButton)` hech qachon topmaydi — subtip finder shart.

/// Daraxtdagi barcha `AppButton` variantlari.
Finder appButtons() => find.bySubtype<AppButton>();

/// Matni [label] bo'lgan yagona `AppButton`.
Finder appButton(String label) =>
    find.ancestor(of: find.text(label), matching: find.bySubtype<AppButton>());

/// Uzun formada (M-05) tugma ekran ostida qoladi — avval `Scrollable` bilan
/// ko'rinadigan qilamiz, keyin bosamiz (haqiqiy foydalanuvchi ham shunday
/// qiladi). `tap()` o'zi skroll qilmaydi va hit-test dan o'tmaydi.
Future<void> tapScrolled(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}
