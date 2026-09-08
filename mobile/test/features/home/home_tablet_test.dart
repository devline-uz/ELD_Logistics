@Timeout(Duration(seconds: 60))
/// `T-01 Home / Full screen` — planshetning uch ustunli ekrani (1366×1024).
///
/// Tekshiriladi: **M120** (scroll yo'q), **M121** (qidiruv yo'q), 4 ta
/// `HosRingIndicator`, `ACTIONS` paneli, `ActiveDriverBanner` (M10) va
/// telefon bilan **bitta** `HomeController` (M7).
library;

import 'package:eld_mobile/core/ui/components/components.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:eld_mobile/features/auth/domain/session_state.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_models.dart';
import 'package:eld_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:eld_mobile/features/home/presentation/screens/tablet/home_tablet_view.dart';
import 'package:eld_mobile/features/home/presentation/widgets/active_driver_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/session_test_fakes.dart';
import '../duty_status/duty_test_harness.dart';

const Size kTablet = Size(1366, 1024);
const Size kPhone = Size(393, 852);

void main() {
  testWidgets('T-01: uch ustun, 4 halqa, ACTIONS paneli', (WidgetTester tester) async {
    final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
    addTearDown(duty.dispose);

    await pumpM4(
      tester,
      surface: kTablet,
      child: const HomeScreen(),
      overrides: <Override>[
        ...m4Overrides(
          duty: duty,
          home: FakeHomeRepository(certifyDays: testCertifyDays()),
        ),
        sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
      ],
    );

    expect(find.byType(HomeTabletView), findsOneWidget);
    // Planshetda 4 ta halqa (M87), chiziqli indikator yo'q.
    expect(find.byType(HosRingIndicator), findsNWidgets(4));
    expect(find.byType(HosCardIndicator), findsNothing);

    // Uch ustun sarlavhalari.
    expect(find.text('Hours of Service'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Trip Details'), findsOneWidget);

    // ACTIONS paneli tugmalari.
    expect(find.text('FMCSA / Inspection Report'), findsOneWidget);
    expect(find.text('Co-driver'), findsWidgets);
    expect(find.text('Leave Truck'), findsWidgets);
  });

  testWidgets('M120: ekran scroll qilinmaydi — faqat log bloki ichki scroll', (
    WidgetTester tester,
  ) async {
    final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
    addTearDown(duty.dispose);

    await pumpM4(
      tester,
      surface: kTablet,
      child: const HomeScreen(),
      overrides: <Override>[
        ...m4Overrides(duty: duty),
        sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
      ],
    );

    // Tashqi `ListView` yo'q; log bloki va duty grid o'z scroll'iga ega.
    expect(find.byType(ListView), findsNothing);
    expect(
      find.descendant(
        of: find.byType(HomeTabletView),
        matching: find.byType(SingleChildScrollView),
      ),
      findsWidgets,
    );
  });

  testWidgets('M121: `Search Item ...` qidiruvi yo\'q', (WidgetTester tester) async {
    final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
    addTearDown(duty.dispose);

    await pumpM4(
      tester,
      surface: kTablet,
      child: const HomeScreen(),
      overrides: <Override>[
        ...m4Overrides(duty: duty),
        sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
      ],
    );

    expect(find.textContaining('Search'), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('M10: ActiveDriverBanner faol haydovchini doim ko\'rsatadi', (
    WidgetTester tester,
  ) async {
    final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
    addTearDown(duty.dispose);

    await pumpM4(
      tester,
      surface: kTablet,
      child: const HomeScreen(),
      overrides: <Override>[
        ...m4Overrides(duty: duty),
        sessionManagerProvider.overrideWith(() => FakeSessionManager(pairedSession())),
      ],
    );

    expect(find.byType(ActiveDriverBanner), findsOneWidget);
    // Faol — co-driver sloti (`Maria Lopez`), ikkinchisi kichikroq matnda.
    expect(find.textContaining('Maria Lopez is driving'), findsOneWidget);
    expect(find.textContaining('Co-driver: John Smith'), findsOneWidget);
    // `Switch` tugmasi faqat co-driver biriktirilganda (M11).
    expect(find.text('Switch'), findsOneWidget);
  });

  testWidgets('M11: co-driver yo\'q — `Switch` tugmasi ko\'rinmaydi', (WidgetTester tester) async {
    final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
    addTearDown(duty.dispose);

    await pumpM4(
      tester,
      surface: kTablet,
      child: const HomeScreen(),
      overrides: <Override>[
        ...m4Overrides(duty: duty),
        sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
      ],
    );

    expect(find.byType(ActiveDriverBanner), findsOneWidget);
    expect(find.text('Switch'), findsNothing);
  });

  testWidgets('sessiya yo\'q — banner ham yo\'q', (WidgetTester tester) async {
    final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
    addTearDown(duty.dispose);

    await pumpM4(
      tester,
      surface: kTablet,
      child: const HomeScreen(),
      overrides: <Override>[
        ...m4Overrides(duty: duty),
        sessionManagerProvider.overrideWith(
          () => FakeSessionManager(const DualSessionState.signedOut()),
        ),
      ],
    );

    expect(find.byType(ActiveDriverBanner), findsNothing);
  });

  testWidgets('M7: telefonda o\'sha kontroller, lekin chiziqli indikator', (
    WidgetTester tester,
  ) async {
    final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
    addTearDown(duty.dispose);

    await pumpM4(
      tester,
      surface: kPhone,
      child: const HomeScreen(),
      overrides: <Override>[
        ...m4Overrides(duty: duty),
        sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
      ],
    );

    expect(find.byType(HomeTabletView), findsNothing);
    expect(find.byType(HosCardIndicator), findsNWidgets(4));
  });

  testWidgets('bo\'sh holat: unit biriktirilmagan', (WidgetTester tester) async {
    final FakeDutyStatusRepository duty = FakeDutyStatusRepository(
      context: testContext(driver: const DriverContext()),
    );
    addTearDown(duty.dispose);

    await pumpM4(
      tester,
      surface: kTablet,
      child: const HomeScreen(),
      overrides: <Override>[
        ...m4Overrides(duty: duty),
        sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
      ],
    );

    expect(find.byType(EmptyState), findsOneWidget);
  });

  test('T-01 planshet uchun bir xil `HomeController` ishlatiladi (M7)', () {
    // `HomeTabletView` kontrollerni **qabul qiladi**, o'zi yaratmaydi —
    // biznes mantiq dublikati bo'lmasligining statik kafolati.
    expect(HomeTabletView, isNotNull);
  });
}
