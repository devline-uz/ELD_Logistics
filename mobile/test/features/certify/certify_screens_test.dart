@Timeout(Duration(seconds: 60))
/// `M-29 Certify` · `M-30 Sign` · `M-31 Not Ready` widget testlari.
library;

import 'package:eld_mobile/features/certify/domain/certify_models.dart';
import 'package:eld_mobile/features/certify/presentation/screens/certify_screen.dart';
import 'package:eld_mobile/features/certify/presentation/screens/certify_sign_screen.dart';
import 'package:eld_mobile/features/certify/presentation/widgets/certify_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../logs/m7_test_harness.dart';

void main() {
  final DateTime today = DateTime(2026, 9, 7);
  final DateTime yesterday = DateTime(2026, 9, 6);

  group('M-29 Certify (Last 8 days)', () {
    testWidgets('sarlavha doim 8 kunlik oyna (M124)', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const CertifyScreen(),
        certify: FakeCertifyRepository(
          days: <CertifyDay>[CertifyDay(date: today, status: CertifyStatus.uncertified)],
        ),
      );
      expect(find.text('Certify (Last 8 days)'), findsOneWidget);
    });

    testWidgets('yuklanish holati', (WidgetTester tester) async {
      await pumpM7(tester, const CertifyScreen(), certify: FakeCertifyRepository(loading: true));
      expect(find.byType(CertifyDayTile), findsNothing);
    });

    testWidgets('bo\'sh holat: tanlanadigan kun yo\'q', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const CertifyScreen(),
        certify: FakeCertifyRepository(
          days: <CertifyDay>[CertifyDay(date: today, status: CertifyStatus.certified)],
        ),
      );
      expect(find.text('Nothing to certify'), findsOneWidget);
    });

    testWidgets('tanlov yo\'q → Certify All, bitta kun tanlansa → Certify Selected (1)', (
      WidgetTester tester,
    ) async {
      await pumpM7(
        tester,
        const CertifyScreen(),
        certify: FakeCertifyRepository(
          days: <CertifyDay>[
            CertifyDay(date: yesterday, status: CertifyStatus.uncertified),
            CertifyDay(date: today, status: CertifyStatus.needsRecertify),
          ],
        ),
      );

      expect(find.text('Certify All'), findsOneWidget);
      await tester.tap(find.byType(CertifyDayTile).first);
      await tester.pump();
      expect(find.text('Certify Selected (1)'), findsOneWidget);
    });

    testWidgets('M-31 Not Ready va Certified kunlar belgilanmaydi (M123/M125)', (
      WidgetTester tester,
    ) async {
      await pumpM7(
        tester,
        const CertifyScreen(),
        certify: FakeCertifyRepository(
          days: <CertifyDay>[
            CertifyDay(date: today, status: CertifyStatus.notReady),
            CertifyDay(date: yesterday, status: CertifyStatus.uncertified),
          ],
        ),
      );

      expect(find.text('Not Ready'), findsOneWidget);
      // `Not Ready` (birinchi satr) bosilsa ham tanlov o'zgarmaydi (M125).
      await tester.tap(find.byType(CertifyDayTile).first);
      await tester.pump();
      expect(find.text('Certify Selected (1)'), findsNothing);
      expect(find.text('Certify All'), findsOneWidget);
    });
  });

  group('M-30 Sign', () {
    testWidgets('huquqiy matn va imzosiz Confirm o\'chirilgan', (WidgetTester tester) async {
      await pumpM7(
        tester,
        CertifySignScreen(date: today),
        certify: FakeCertifyRepository(
          days: <CertifyDay>[CertifyDay(date: today, status: CertifyStatus.uncertified)],
        ),
      );

      expect(find.textContaining('I hereby certify'), findsOneWidget);
      expect(find.text('Driver Signature'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('saqlangan imzo bo\'lsa `Use my signature` ko\'rinadi (M127)', (
      WidgetTester tester,
    ) async {
      await pumpM7(
        tester,
        CertifySignScreen(date: today),
        signatures: FakeSignatureStore(id: 'sig-1'),
      );
      expect(find.text('Use my signature'), findsOneWidget);
    });

    testWidgets('M-31: Not Ready kunda tugma `Not Ready` bo\'lib bloklanadi', (
      WidgetTester tester,
    ) async {
      await pumpM7(
        tester,
        CertifySignScreen(date: today),
        certify: FakeCertifyRepository(
          days: <CertifyDay>[CertifyDay(date: today, status: CertifyStatus.notReady)],
        ),
      );
      expect(find.text('Not Ready'), findsWidgets);
      expect(find.text('Confirm'), findsNothing);
    });
  });
}
