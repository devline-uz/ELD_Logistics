@Timeout(Duration(seconds: 60))
/// `M-09`, `M-10`, `M-11` widget testlari — har ekran 4 holatda
/// (yuklanish · bo'sh · xato/oflayn · to'la), C.3 DoD.
library;

import 'package:eld_mobile/core/eld/eld_codes.dart';
import 'package:eld_mobile/core/eld/eld_models.dart';
import 'package:eld_mobile/core/eld/eld_session.dart';
import 'package:eld_mobile/core/ui/components/components.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_models.dart';
import 'package:eld_mobile/features/home/domain/home_models.dart';
import 'package:eld_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:eld_mobile/features/home/presentation/widgets/edit_documents_sheet.dart';
import 'package:eld_mobile/features/home/presentation/widgets/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../duty_status/duty_test_harness.dart';

Finder appButton(String label) =>
    find.ancestor(of: find.text(label), matching: find.bySubtype<AppButton>());

/// `ListView` lazy quradi — scroll ostidagi kartalarni ko'rinishga chiqaradi.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 240, scrollable: find.byType(Scrollable).first);
  await tester.pump();
}

void main() {
  late FakeDutyStatusRepository duty;
  late FakeHomeRepository home;

  setUp(() {
    duty = FakeDutyStatusRepository();
    home = FakeHomeRepository(certifyDays: testCertifyDays());
  });
  tearDown(() => duty.dispose());

  group('M-09 Home', () {
    testWidgets('yuklanish: skeleton', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const HomeScreen(),
        overrides: m4Overrides(duty: duty, home: home, contextLoading: true),
      );
      expect(find.byType(LoadingSkeleton), findsOneWidget);
    });

    testWidgets('bo\'sh: unit biriktirilmagan (tz-mobile 1240)', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const HomeScreen(),
        overrides: m4Overrides(
          duty: duty,
          home: home,
          context: testContext(
            driver: const DriverContext(driverId: 'd', driverName: 'John'),
          ),
        ),
      );
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No unit assigned. Contact your fleet manager.'), findsOneWidget);
    });

    testWidgets('to\'la: M88 bloklari va 4 ta HOS indikatori', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const HomeScreen(),
        overrides: m4Overrides(duty: duty, home: home),
      );
      expect(find.text('Hours of Service'), findsOneWidget);
      // #B-22: Figma `2177:12192` — 2x2 karta grid (chiziqli ro'yxat emas).
      expect(find.byType(HosCardIndicator), findsNWidgets(4));
      expect(find.text('1021'), findsOneWidget);
      expect(find.text('Inspection Report'), findsOneWidget);
      expect(find.text('Leave Truck'), findsOneWidget);
    });

    testWidgets('to\'la: ELD ulanmagan banneri', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const HomeScreen(),
        overrides: m4Overrides(duty: duty, home: home, eld: EldConnectionState.notConnected),
      );
      expect(find.text('ELD not connected'), findsOneWidget);
    });

    testWidgets('oflayn: navbat banneri ko\'rinadi', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const HomeScreen(),
        overrides: m4Overrides(duty: duty, home: home, queued: 12),
      );
      expect(find.text('Offline — 12 records queued'), findsOneWidget);
    });

    testWidgets('shartli kartalar: pending edits va unidentified', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const HomeScreen(),
        overrides: m4Overrides(
          duty: duty,
          home: FakeHomeRepository(
            certifyDays: testCertifyDays(),
            pendingEdits: 2,
            unidentified: 3,
          ),
        ),
      );
      await scrollTo(tester, find.text('Pending edits (2)'));
      expect(find.text('Pending edits (2)'), findsOneWidget);
      expect(find.text('Unidentified driving (3)'), findsOneWidget);
    });

    testWidgets('certify: sertifikatlanmagan kun bo\'lsa `Not Signed`', (
      WidgetTester tester,
    ) async {
      await pumpM4(
        tester,
        child: const HomeScreen(),
        overrides: m4Overrides(duty: duty, home: home),
      );
      // Figma: `Signature` kartasida badge yo'q — holat 8 ta rangli nuqta
      // bilan ko'rsatiladi (sertifikatlanmagan kun = `error`).
      await scrollTo(tester, find.text('Certify (Last 8 days)'));
      expect(find.text('Certify (Last 8 days)'), findsOneWidget);
    });
  });

  group('M-10 Drawer', () {
    testWidgets('to\'la: TZ bandlari, `Maintenance` yo\'q (M95)', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: Scaffold(
          body: HomeDrawer(driver: kTestDriver, onAction: (HomeDrawerAction _) {}),
        ),
        overrides: m4Overrides(duty: duty, home: home),
      );
      expect(find.text('Permissions'), findsOneWidget);
      expect(find.text('Check Network'), findsOneWidget);
      expect(find.text('Diagnosis of Device'), findsOneWidget);
      expect(find.text('App Updates'), findsOneWidget);
      expect(find.text('Zoom'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Maintenance'), findsNothing);
    });

    testWidgets('bandni bosganda amal chiqadi', (WidgetTester tester) async {
      HomeDrawerAction? tapped;
      await pumpM4(
        tester,
        child: Scaffold(
          body: HomeDrawer(
            driver: kTestDriver,
            onAction: (HomeDrawerAction action) => tapped = action,
          ),
        ),
        overrides: m4Overrides(duty: duty, home: home),
      );
      await tester.tap(find.text('Check Network'));
      await tester.pump();
      expect(tapped, HomeDrawerAction.checkNetwork);
    });
  });

  group('M-11 Edit documents', () {
    testWidgets('to\'la: maydonlar to\'ldirilgan', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const Scaffold(
          body: EditDocumentsForm(
            trip: TripDetails(
              shippingDocs: <String>['SD-42'],
              trailers: <String>['T-880'],
              notes: 'Lorem',
            ),
          ),
        ),
        overrides: m4Overrides(duty: duty, home: home),
      );
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('T-880'), findsOneWidget);
      expect(find.text('SD-42'), findsOneWidget);
    });

    testWidgets('M53: saqlaganda status o\'zgarmaydi', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const Scaffold(
          body: EditDocumentsForm(
            trip: TripDetails(shippingDocs: <String>['SD-42'], trailers: <String>['T-880']),
          ),
        ),
        overrides: m4Overrides(duty: duty, home: home),
      );
      await tester.tap(appButton('Save'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(duty.documentUpdates, hasLength(1));
      expect(duty.documentUpdates.single.trailers, <String>['T-880']);
      expect(duty.changes, isEmpty);
    });
  });

  group('Malfunction banneri (M77)', () {
    testWidgets('malfunction bo\'lsa qizil banner chiqadi', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const HomeScreen(),
        overrides: m4Overrides(duty: duty, home: home, session: malfunctionSession()),
      );
      expect(find.textContaining('ELD malfunction'), findsOneWidget);
    });
  });
}

/// Malfunction holatidagi ELD sessiyasi.
EldSessionState malfunctionSession() => EldSessionState(
  connection: EldConnectionState.connected,
  faults: <EldFaultCode, EldFault>{
    EldFaultCode.timing: EldFault(
      code: EldFaultCode.timing,
      kind: EldFaultKind.malfunction,
      detectedAt: kTestNow,
    ),
  },
);
