@Timeout(Duration(seconds: 60))
/// **S-H5 / M157** — `FLAG_SECURE` aynan kerakli ekranlarda yoqiladi.
///
/// M-04 PIN, M-05 Invite, M-08 2FA — himoya `initState` da yoqilib, ekrandan
/// chiqishda o'chishi shart. M-02 Login kabi oddiy ekranlarda himoya
/// yoqilmaydi (support skrinshotlari ishlashi kerak).
library;

import 'package:eld_mobile/core/router/routes.dart';
import 'package:eld_mobile/core/security/screen_protection.dart';
import 'package:eld_mobile/features/auth/auth_routes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'auth_test_harness.dart';

/// Kanalga chiqmaydigan, chaqiruvlarni yozib boradigan dublyor.
class _RecordingScreenProtection implements ScreenProtection {
  final List<bool> calls = <bool>[];

  bool get secure => calls.isNotEmpty && calls.last;

  @override
  PlatformException? lastError;

  @override
  Future<void> setSecure(bool enabled) async => calls.add(enabled);

  @override
  Future<bool> isSecure() async => secure;

  @override
  Stream<ScreenCaptureEvent> captureEvents() => const Stream<ScreenCaptureEvent>.empty();
}

void main() {
  late _RecordingScreenProtection protection;

  setUp(() => protection = _RecordingScreenProtection());

  List<Override> overrides() => <Override>[screenProtectionProvider.overrideWithValue(protection)];

  testWidgets('M-04 PIN ekranida himoya yoqiladi va chiqishda o\'chadi', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repo = FakeAuthRepository();

    final GoRouter router = await pumpAuthApp(
      tester,
      repository: repo,
      initialLocation: AppRoute.pin,
      overrides: overrides(),
    );
    expect(protection.secure, isTrue, reason: 'PIN ekrani FLAG_SECURE bilan ochilishi kerak');

    router.go(AppRoute.login);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(protection.secure, isFalse, reason: 'M157: chiqishda flag tozalanishi shart');
  });

  testWidgets('M-05 Invite ekranida himoya yoqiladi', (WidgetTester tester) async {
    await pumpAuthApp(
      tester,
      repository: FakeAuthRepository(),
      initialLocation: '${AuthRoute.invite}?token=abc',
      overrides: overrides(),
    );

    expect(protection.secure, isTrue);
  });

  testWidgets('M-08 2FA ekranida himoya yoqiladi', (WidgetTester tester) async {
    await pumpAuthApp(
      tester,
      repository: FakeAuthRepository(),
      initialLocation: AuthRoute.twoFactor,
      overrides: overrides(),
    );

    expect(protection.secure, isTrue);
  });

  testWidgets('M-02 Login ekranida himoya yoqilmaydi', (WidgetTester tester) async {
    await pumpAuthApp(
      tester,
      repository: FakeAuthRepository(),
      initialLocation: AppRoute.login,
      overrides: overrides(),
    );

    expect(protection.calls, isEmpty);
  });
}
