@Timeout(Duration(seconds: 60))
/// `T-24 Feedback` — planshet modali (tz-mobile 1558).
///
/// **A3:** modal `M-48` ekrani bilan bir xil `FeedbackPane` va
/// `feedbackRepositoryProvider` dan foydalanadi.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/feedback/presentation/screens/feedback_screen.dart';
import 'package:eld_mobile/features/feedback/presentation/widgets/feedback_modal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/m11_test_harness.dart';
import '../shared/modal_host.dart';

void main() {
  group('T-24', () {
    testWidgets('planshetda TabletModal (M122) va planshet savol matni (M113)', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(
        tester,
        const ModalHost(open: showFeedbackModal),
        overrides: m11Overrides(),
        surface: kTabletSurface,
      );
      await openModal(tester);

      expect(find.byType(TabletModal), findsOneWidget);
      expect(tester.widget<TabletModal>(find.byType(TabletModal)).cancelLabel, isNotNull);
      expect(tester.widget<FeedbackPane>(find.byType(FeedbackPane)).tablet, isTrue);
    });

    testWidgets('telefonda AppBottomSheet — bir xil panel', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const ModalHost(open: showFeedbackModal),
        overrides: m11Overrides(),
        surface: kPhoneSurface,
      );
      await openModal(tester);

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.byType(TabletModal), findsNothing);
      expect(tester.widget<FeedbackPane>(find.byType(FeedbackPane)).tablet, isFalse);
    });
  });
}
