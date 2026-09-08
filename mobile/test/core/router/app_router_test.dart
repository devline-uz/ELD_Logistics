@Timeout(Duration(seconds: 60))
library;

import 'dart:async';

import 'package:eld_mobile/app.dart';
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/motion_detector.dart';
import 'package:eld_mobile/core/router/app_router.dart';
import 'package:eld_mobile/core/router/auth_state.dart';
import 'package:eld_mobile/core/router/routes.dart';
import 'package:eld_mobile/core/session/session_context.dart';
import 'package:eld_mobile/core/session/session_terminator.dart';
import 'package:eld_mobile/core/ui/components/app_nav_bar.dart';
import 'package:eld_mobile/features/auth/data/auth_providers.dart';
import 'package:eld_mobile/features/auth/presentation/controllers/splash_controller.dart';
import 'package:eld_mobile/features/auth/presentation/screens/signed_out_screen.dart';
import 'package:eld_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:eld_mobile/features/auth/presentation/widgets/auth_shell.dart';
import 'package:eld_mobile/features/duty_status/data/duty_status_providers.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/auth/auth_test_harness.dart';
import '../../features/duty_status/duty_test_harness.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester,
  AuthStatus status, {
  bool settle = true,
  FakeAuthRepository? repository,
  SessionEndReason endReason = SessionEndReason.none,
}) async {
  // Haqiqiy `AuthRepository` tarmoq/Keychain ga chiqadi — testda soxtasi.
  // Shell shoxlarida endi haqiqiy ekranlar turadi (Home, Logs, Chat, Profile),
  // shuning uchun ularning manbalari ham beriladi: in-memory Drift, sessiya va
  // harakat oqimi (aks holda `MotionDetectorRunner` taymer qoldiradi).
  final AppDatabase db = AppDatabase.memory();
  addTearDown(db.close);
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      authRepositoryProvider.overrideWithValue(repository ?? FakeAuthRepository()),
      appDatabaseProvider.overrideWithValue(db),
      motionEventsProvider.overrideWith((Ref ref) => const Stream<MotionEvent>.empty()),
      sessionContextProvider.overrideWithValue(const SessionContext(driverId: 'driver-1')),
      // Home ning 30 s lik HOS taymeri testda osilib qolmasin.
      hosSnapshotProvider.overrideWith((Ref ref) async => testSnapshot()),
    ],
  );
  addTearDown(container.dispose);
  container.read(sessionEndReasonProvider.notifier).set(endReason);
  container.read(authStatusProvider.notifier).set(status);

  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const EldApp()));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // Splash'dagi cheksiz progress animatsiyasi `pumpAndSettle` ni osadi;
    // GoRouter birinchi marshrutni qurishi uchun bir necha kadr kerak.
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }
  return container;
}

void main() {
  testWidgets('unknown holatida splash ko\'rsatiladi', (WidgetTester tester) async {
    // `bootstrap()` tugamaydi — splash «yuklanmoqda» holatida qoladi.
    await _pump(
      tester,
      AuthStatus.unknown,
      settle: false,
      repository: FakeAuthRepository(bootstrapGate: Completer<void>()),
    );

    // M-01: dastlab faqat logotip; progress `kSplashProgressThreshold` dan keyin.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(AuthBrandLogo), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pump(kSplashProgressThreshold + const Duration(milliseconds: 50));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('autentifikatsiyalanmagan foydalanuvchi login ga yo\'naltiriladi', (
    WidgetTester tester,
  ) async {
    await _pump(tester, AuthStatus.unauthenticated);

    expect(find.byType(AppNavBar), findsNothing);
  });

  testWidgets('#B-3: refresh bekor qilingan sessiya `M-56` ekraniga tushadi', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pump(
      tester,
      AuthStatus.unauthenticated,
      endReason: SessionEndReason.revoked,
    );
    // Splash `publicPaths` da — qo'riqchi haydovchi ekranga o'tishga
    // urinmaguncha aralashmaydi (haqiqiy oqimda u `/home` da turadi).
    container.read(routerProvider).go(AppRoute.home);
    await tester.pumpAndSettle();

    expect(find.byType(SignedOutScreen), findsOneWidget);
    expect(find.byType(AppNavBar), findsNothing);
  });

  testWidgets('autentifikatsiyalangan holatda 4 tab li shell ochiladi', (
    WidgetTester tester,
  ) async {
    await _pump(tester, AuthStatus.authenticated);

    expect(find.byType(AppNavBar), findsOneWidget);
    final AppNavBar bar = tester.widget<AppNavBar>(find.byType(AppNavBar));
    expect(bar.items.length, 4);
  });

  testWidgets('tab almashtirish indexedStack ni yangilaydi', (WidgetTester tester) async {
    await _pump(tester, AuthStatus.authenticated);

    // #B-06: yorliq faqat faol elementda ko'rinadi — nofaol tab ikonka
    // bo'yicha bosiladi.
    await tester.tap(find.byIcon(Icons.article_outlined));
    await tester.pumpAndSettle();

    final AppNavBar bar = tester.widget<AppNavBar>(find.byType(AppNavBar));
    expect(bar.currentIndex, 1);
    final AppLocalizations l10n = AppLocalizations.of(tester.element(find.byType(AppNavBar)));
    expect(find.text(l10n.navLogs), findsWidgets);
  });
}
