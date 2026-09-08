@Timeout(Duration(seconds: 60))
/// `T-33 Unidentified claim` — planshet modali (tz-mobile 1567).
///
/// **A3:** modal `M-28` ekrani bilan bir xil `unidentifiedRepositoryProvider`
/// va `unidentifiedControllerProvider` dan oziqlanadi.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/unidentified/presentation/screens/unidentified_screen.dart';
import 'package:eld_mobile/features/unidentified/presentation/widgets/unidentified_modal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../logs/m7_test_harness.dart';
import '../shared/modal_host.dart';

void main() {
  group('T-33', () {
    testWidgets('planshetda TabletModal (M122) + ikki ustunli tana', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const ModalHost(open: showUnidentifiedClaimModal),
        surface: kTabletSurface,
      );
      await openModal(tester);

      expect(find.byType(TabletModal), findsOneWidget);
      expect(tester.widget<TabletModal>(find.byType(TabletModal)).cancelLabel, isNotNull);
      expect(tester.widget<UnidentifiedBody>(find.byType(UnidentifiedBody)).twoColumn, isTrue);
    });

    testWidgets('telefonda AppBottomSheet + bir ustun', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const ModalHost(open: showUnidentifiedClaimModal),
        surface: kPhoneSurface,
      );
      await openModal(tester);

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(tester.widget<UnidentifiedBody>(find.byType(UnidentifiedBody)).twoColumn, isFalse);
    });
  });
}
