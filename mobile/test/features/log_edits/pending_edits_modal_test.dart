@Timeout(Duration(seconds: 60))
/// `T-32 Pending edits` — planshet modali (tz-mobile 1566).
///
/// **A3:** modal `M-26` ekrani bilan bir xil `logEditsRepositoryProvider` dan
/// oziqlanadi.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/log_edits/presentation/screens/pending_edits_screen.dart';
import 'package:eld_mobile/features/log_edits/presentation/widgets/pending_edits_modal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../logs/m7_test_harness.dart';
import '../shared/modal_host.dart';

void main() {
  group('T-32', () {
    testWidgets('planshetda TabletModal + ikki ustunli tana', (WidgetTester tester) async {
      await pumpM7(tester, const ModalHost(open: showPendingEditsModal), surface: kTabletSurface);
      await openModal(tester);

      expect(find.byType(TabletModal), findsOneWidget);
      expect(find.byType(AppBottomSheet), findsNothing);
      final TabletModal modal = tester.widget<TabletModal>(find.byType(TabletModal));
      expect(modal.cancelLabel, isNotNull, reason: 'M122: sarlavha qatorida Cancel');
      expect(tester.widget<PendingEditsBody>(find.byType(PendingEditsBody)).twoColumn, isTrue);
    });

    testWidgets('telefonda AppBottomSheet + bir ustun', (WidgetTester tester) async {
      await pumpM7(tester, const ModalHost(open: showPendingEditsModal), surface: kPhoneSurface);
      await openModal(tester);

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.byType(TabletModal), findsNothing);
      expect(tester.widget<PendingEditsBody>(find.byType(PendingEditsBody)).twoColumn, isFalse);
    });
  });
}
