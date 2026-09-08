@Timeout(Duration(seconds: 60))
/// **M-52 Privacy Policy** / **M-53 Terms of Use** widget testlari.
///
/// ❓**M117** — huquqiy matnlar buyurtmachidan kelmagan. Asset bo'lmasa ekran
/// placeholder + `support_email` + `Contact support` havolasini ko'rsatadi;
/// soxta huquqiy matn yozilmaydi.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/legal/presentation/screens/legal_screen.dart';
import 'package:eld_mobile/features/profile/domain/app_config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/m11_test_harness.dart';

List<Override> _withDocument(String? text) => <Override>[
  ...m11Overrides(),
  legalDocumentProvider(LegalDocumentKind.privacy).overrideWith((Ref ref) async => text),
  legalDocumentProvider(LegalDocumentKind.terms).overrideWith((Ref ref) async => text),
];

void main() {
  group('M-52 / M-53 Legal', () {
    testWidgets('M117: matn yo\'q → placeholder + support_email', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const LegalScreen(document: LegalDocumentKind.privacy),
        overrides: _withDocument(null),
      );

      expect(find.text(l10n.legalPrivacyTitle), findsOneWidget);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text(l10n.legalPendingTitle), findsOneWidget);
      expect(find.text(l10n.legalPendingMessage('help@example.com')), findsOneWidget);
      expect(appButton(l10n.legalContactSupport), findsOneWidget);
    });

    testWidgets('`support_email` bo\'lmasa `N/A` (M92)', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const LegalScreen(document: LegalDocumentKind.terms),
        overrides: <Override>[
          ...m11Overrides(config: FakeAppConfigRepository(config: const AppConfigInfo())),
          legalDocumentProvider(LegalDocumentKind.terms).overrideWith((Ref ref) async => null),
        ],
      );
      expect(find.text(l10n.legalTermsTitle), findsOneWidget);
      expect(find.text(l10n.legalPendingMessage('N/A')), findsOneWidget);
    });

    testWidgets('matn bo\'lsa ko\'rsatiladi: sarlavha + paragraf', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const LegalScreen(document: LegalDocumentKind.privacy),
        overrides: _withDocument('# 1. Overview\n\nData we collect.'),
      );
      // `#` prefiksi sarlavhada ko'rinmaydi.
      expect(find.text('1. Overview'), findsOneWidget);
      expect(find.text('Data we collect.'), findsOneWidget);
      expect(find.byType(EmptyState), findsNothing);
    });

    testWidgets('asset o\'qish xatosi ham placeholder bilan tugaydi', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const LegalScreen(document: LegalDocumentKind.privacy),
        overrides: <Override>[
          ...m11Overrides(),
          legalDocumentProvider(
            LegalDocumentKind.privacy,
          ).overrideWith((Ref ref) async => throw StateError('asset missing')),
        ],
      );
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.byType(ErrorState), findsNothing);
    });

    testWidgets('planshetda ham bir xil ko\'rinadi (M7)', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const LegalScreen(document: LegalDocumentKind.terms),
        overrides: _withDocument(null),
        surface: const Size(1366, 1024),
      );
      expect(find.text(l10n.legalTermsTitle), findsOneWidget);
      expect(find.byType(EmptyState), findsOneWidget);
    });
  });
}
