@Timeout(Duration(seconds: 60))
/// `T-11 Certify (Last 8 days)` · `T-12 Sign` · `T-13 Not Ready` — planshet
/// modallari (tz-mobile 1545–1547, sarlavha qatori M122).
///
/// **A3:** modal `M-29`/`M-30` bilan bir xil `certifyRepositoryProvider` dan
/// oziqlanadi; test bir xil soxta repozitoriy bilan ikkala qobiqni tekshiradi.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/certify/domain/certify_models.dart';
import 'package:eld_mobile/features/certify/presentation/screens/certify_screen.dart';
import 'package:eld_mobile/features/certify/presentation/screens/certify_sign_screen.dart';
import 'package:eld_mobile/features/certify/presentation/widgets/certify_modals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../logs/m7_test_harness.dart';
import '../shared/modal_host.dart';

void main() {
  final DateTime day = DateTime(2026, 9, 6);

  FakeCertifyRepository repo() => FakeCertifyRepository(
    days: <CertifyDay>[CertifyDay(date: day, status: CertifyStatus.uncertified)],
  );

  group('T-11 Certify modal', () {
    testWidgets('planshetda TabletModal, sarlavha qatorida Cancel (M122)', (
      WidgetTester tester,
    ) async {
      await pumpM7(
        tester,
        const ModalHost(open: showCertifyDaysModal),
        certify: repo(),
        surface: kTabletSurface,
      );
      await openModal(tester);

      expect(find.byType(TabletModal), findsOneWidget);
      expect(find.byType(AppBottomSheet), findsNothing);
      final TabletModal modal = tester.widget<TabletModal>(find.byType(TabletModal));
      expect(modal.cancelLabel, isNotNull);
      expect(modal.title, isNotEmpty);
      expect(find.byType(CertifyDaysBody), findsOneWidget);
      expect(tester.widget<CertifyDaysBody>(find.byType(CertifyDaysBody)).twoColumn, isTrue);
    });

    testWidgets('telefonda AppBottomSheet (bir xil tana)', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const ModalHost(open: showCertifyDaysModal),
        certify: repo(),
        surface: kPhoneSurface,
      );
      await openModal(tester);

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.byType(TabletModal), findsNothing);
      expect(tester.widget<CertifyDaysBody>(find.byType(CertifyDaysBody)).twoColumn, isFalse);
    });
  });

  group('T-12 Sign modal', () {
    testWidgets('planshetda TabletModal va imzo paneli', (WidgetTester tester) async {
      await pumpM7(
        tester,
        ModalHost(open: (BuildContext c) => showCertifySignModal(c, day)),
        certify: repo(),
        surface: kTabletSurface,
      );
      await openModal(tester);

      expect(find.byType(TabletModal), findsOneWidget);
      expect(find.byType(CertifySignPane), findsOneWidget);
    });
  });

  group('T-13 Not Ready', () {
    testWidgets('alohida modal emas — ro\'yxat ichidagi holat (M125)', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const ModalHost(open: showCertifyDaysModal),
        certify: FakeCertifyRepository(
          days: <CertifyDay>[CertifyDay(date: day, status: CertifyStatus.notReady)],
        ),
        surface: kTabletSurface,
      );
      await openModal(tester);

      expect(find.byType(TabletModal), findsOneWidget);
      expect(find.byType(CertifyDaysBody), findsOneWidget);
    });
  });
}
