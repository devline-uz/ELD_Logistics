@Timeout(Duration(seconds: 60))
/// `M-20 / T-07 Switch co-driver` · `M-21 / T-08 Select Shipping Document` ·
/// `M-56 Signed out elsewhere` · `M-58 Sessions`.
///
/// Har ekran 4 holatda tekshiriladi (yuklanish · bo'sh · xato · to'la) va
/// telefon/planshet profillari bitta kontrollerni ulashishi qotiriladi (M7).
library;

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/ui/components/components.dart';
import 'package:eld_mobile/core/ui/theme.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:eld_mobile/features/auth/domain/driver_session.dart';
import 'package:eld_mobile/features/auth/domain/session_policy.dart';
import 'package:eld_mobile/features/auth/domain/session_state.dart';
import 'package:eld_mobile/features/auth/presentation/controllers/co_driver_controller.dart';
import 'package:eld_mobile/features/auth/presentation/controllers/sessions_controller.dart';
import 'package:eld_mobile/features/auth/presentation/controllers/shipping_document_controller.dart';
import 'package:eld_mobile/features/auth/presentation/screens/sessions_screen.dart';
import 'package:eld_mobile/features/auth/presentation/screens/signed_out_screen.dart';
import 'package:eld_mobile/features/auth/presentation/widgets/co_driver_switch_modal.dart';
import 'package:eld_mobile/features/auth/presentation/widgets/shipping_document_modal.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_test_harness.dart';
import 'session_test_fakes.dart';

/// Referens o'lchamlar (tz-mobile §3).
const Size kPhone = Size(393, 852);
const Size kTablet = Size(1366, 1024);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size surface = kPhone,
  List<Override> overrides = const <Override>[],
}) async {
  // M7: `DeviceProfile` `MediaQuery.size` dan hisoblanadi, shuning uchun
  // `setSurfaceSize` yetarli emas — o'lcham aniq `MediaQuery` bilan beriladi.
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.of(Brightness.light),
        localizationsDelegates: const <LocalizationsDelegate<Object?>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (BuildContext context, Widget? inner) => MediaQuery(
          data: MediaQueryData(size: surface, textScaler: TextScaler.noScaling),
          child: inner!,
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  group('M-20 / T-07 Switch co-driver', () {
    testWidgets('bo\'sh: co-driver login qilmagan — EmptyState + Sign in', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CoDriverSwitchModal(),
        overrides: <Override>[
          sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
        ],
      );

      expect(find.text('No co-driver signed in'), findsOneWidget);
      expect(appButton('Sign in co-driver'), findsOneWidget);
    });

    testWidgets('to\'la: ikki haydovchi ko\'rinadi, almashtirish mumkin', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CoDriverSwitchModal(),
        overrides: <Override>[
          sessionManagerProvider.overrideWith(() => FakeSessionManager(pairedSession())),
        ],
      );

      expect(find.text('Active driver'), findsOneWidget);
      expect(find.text('Co-driver'), findsWidgets);
      expect(find.text('Maria Lopez'), findsOneWidget);
      expect(find.textContaining('will become the active driver'), findsOneWidget);
    });

    testWidgets('bloklangan: co-driver pauzada — ogohlantirish banneri', (
      WidgetTester tester,
    ) async {
      final DualSessionState paused = SessionPolicy.leaveTruck(pairedSession()).state;
      await _pump(
        tester,
        const CoDriverSwitchModal(),
        overrides: <Override>[
          sessionManagerProvider.overrideWith(() => FakeSessionManager(paused)),
        ],
      );

      expect(find.byType(BannerStrip), findsOneWidget);
      expect(find.textContaining('return to truck'), findsOneWidget);
    });

    testWidgets('planshetda TabletModal sarlavha qatori (M122)', (WidgetTester tester) async {
      await _pump(
        tester,
        const CoDriverSwitchModal(),
        surface: kTablet,
        overrides: <Override>[
          sessionManagerProvider.overrideWith(() => FakeSessionManager(pairedSession())),
        ],
      );

      expect(find.byType(TabletModal), findsOneWidget);
      expect(find.byType(AppBottomSheet), findsNothing);
      // Cancel · sarlavha · amal
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Switch'), findsOneWidget);
    });

    testWidgets('telefonda AppBottomSheet ishlatiladi', (WidgetTester tester) async {
      await _pump(
        tester,
        const CoDriverSwitchModal(),
        overrides: <Override>[
          sessionManagerProvider.overrideWith(() => FakeSessionManager(pairedSession())),
        ],
      );

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.byType(TabletModal), findsNothing);
    });
  });

  group('M-21 / T-08 Select Shipping Document', () {
    testWidgets('bo\'sh: hujjat yo\'q — EmptyState', (WidgetTester tester) async {
      await _pump(
        tester,
        ShippingDocumentBody(
          state: const ShippingDocumentState(loading: false),
          onOwnerChanged: (_, _) {},
        ),
      );

      expect(find.text('No shipping documents yet'), findsOneWidget);
    });

    testWidgets('yuklanish: skeleton', (WidgetTester tester) async {
      await _pump(
        tester,
        ShippingDocumentBody(state: const ShippingDocumentState(), onOwnerChanged: (_, _) {}),
      );

      expect(find.byType(LoadingSkeleton), findsOneWidget);
    });

    testWidgets('to\'la: Myself / Co-driver tanlovi har hujjat uchun', (WidgetTester tester) async {
      final List<(String, ShippingDocOwner)> changes = <(String, ShippingDocOwner)>[];
      await _pump(
        tester,
        ShippingDocumentBody(
          state: const ShippingDocumentState(
            documents: <String>['SD-42', 'SD-43'],
            mine: <String>{'SD-42'},
            loading: false,
          ),
          onOwnerChanged: (String doc, ShippingDocOwner owner) => changes.add((doc, owner)),
        ),
      );

      expect(find.text('SD-42'), findsOneWidget);
      expect(find.text('SD-43'), findsOneWidget);
      expect(find.text('Myself'), findsNWidgets(2));

      await tester.tap(find.text('Co-driver').first);
      await tester.pump();
      expect(changes.single, ('SD-42', ShippingDocOwner.coDriver));
    });

    testWidgets('xato: server xabari ko\'rsatiladi', (WidgetTester tester) async {
      await _pump(
        tester,
        ShippingDocumentBody(
          state: const ShippingDocumentState(
            documents: <String>['SD-42'],
            loading: false,
            error: ApiError(code: ApiErrorCode.internalError, message: 'boom'),
          ),
          onOwnerChanged: (_, _) {},
        ),
      );

      expect(find.textContaining('The server is having trouble'), findsOneWidget);
    });
  });

  group('M-56 Signed out elsewhere', () {
    testWidgets('qurilma turiga mos xabar + outbox eslatmasi (M17)', (WidgetTester tester) async {
      await _pump(tester, const SignedOutScreen(replacedBy: SessionDeviceType.tablet));

      expect(find.text('Signed out'), findsOneWidget);
      expect(find.textContaining('another tablet'), findsOneWidget);
      expect(find.textContaining('unsynced records are kept'), findsOneWidget);
      expect(appButton('Sign in again'), findsOneWidget);
    });

    testWidgets('planshetda ham bir xil ekran (M7)', (WidgetTester tester) async {
      await _pump(tester, const SignedOutScreen(), surface: kTablet);

      expect(find.textContaining('another phone'), findsOneWidget);
    });
  });

  group('M-58 Sessions', () {
    DriverSession session({
      String id = 'sess-1',
      SessionDeviceType type = SessionDeviceType.phone,
      bool current = false,
    }) => DriverSession(
      id: id,
      deviceType: type,
      status: ServerSessionStatus.active,
      ip: '203.0.113.0',
      lastSeenAt: DateTime.utc(2026, 9, 7, 10, 4),
      current: current,
    );

    testWidgets('yuklanish: skeleton', (WidgetTester tester) async {
      await _pump(tester, SessionsList(state: const SessionsState(), onRevoke: (_) {}));

      expect(find.byType(LoadingSkeleton), findsOneWidget);
    });

    testWidgets('bo\'sh: EmptyState', (WidgetTester tester) async {
      await _pump(
        tester,
        SessionsList(state: const SessionsState(loading: false), onRevoke: (_) {}),
      );

      expect(find.text('No active sessions'), findsOneWidget);
    });

    testWidgets('xato: ErrorState + Retry', (WidgetTester tester) async {
      await _pump(
        tester,
        SessionsList(
          state: const SessionsState(
            loading: false,
            error: ApiError(code: ApiErrorCode.internalError, message: 'boom'),
          ),
          onRevoke: (_) {},
        ),
      );

      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('to\'la: joriy sessiyada `Current` badge, `Sign out` yo\'q', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        SessionsList(
          state: SessionsState(
            loading: false,
            sessions: <DriverSession>[
              session(current: true),
              session(id: 'sess-2', type: SessionDeviceType.tablet),
            ],
          ),
          onRevoke: (_) {},
        ),
        surface: kTablet,
      );

      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Tablet'), findsOneWidget);
      // Faqat joriy bo'lmagan sessiyada chiqarish tugmasi bor.
      expect(appButton('Sign out'), findsOneWidget);
      expect(find.textContaining('203.0.113.0'), findsNWidgets(2));
    });

    testWidgets('`Sign out` tasdiqlangach onRevoke chaqiriladi', (WidgetTester tester) async {
      final List<String> revoked = <String>[];
      await _pump(
        tester,
        SessionsList(
          state: SessionsState(loading: false, sessions: <DriverSession>[session(id: 'sess-9')]),
          onRevoke: revoked.add,
        ),
        surface: kTablet,
      );

      await tester.tap(appButton('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out').last);
      await tester.pumpAndSettle();

      expect(revoked, <String>['sess-9']);
    });
  });

  group('CoDriverController (M7: telefon va planshet bitta kontroller)', () {
    test('bo\'sh slot — needsCoDriverLogin', () {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
        ],
      );
      addTearDown(container.dispose);

      final CoDriverState state = container.read(coDriverControllerProvider);
      expect(state.needsCoDriverLogin, isTrue);
      expect(state.canSwitch, isFalse);
      expect(state.blockedBy, SwitchBlockReason.noCoDriver);
    });

    test('ikki haydovchi — almashtirish mumkin va faol slot o\'zgaradi', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          sessionManagerProvider.overrideWith(() => FakeSessionManager(pairedSession())),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(coDriverControllerProvider).canSwitch, isTrue);
      expect(await container.read(coDriverControllerProvider.notifier).confirmSwitch(), isNull);
      expect(container.read(sessionManagerProvider).activeSlot, DriverSlot.primary);
    });
  });
}
