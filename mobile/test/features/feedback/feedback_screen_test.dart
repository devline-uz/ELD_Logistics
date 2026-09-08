@Timeout(Duration(seconds: 60))
/// **M-48 Give feedback** widget testlari — validatsiya (rating majburiy),
/// yuborish, oflayn navbat (M113 planshet matni), xato holati.
library;

import 'package:eld_mobile/core/error/api_error_messages.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/feedback/presentation/screens/feedback_screen.dart';
import 'package:eld_mobile/features/feedback/presentation/widgets/star_rating.dart';
import 'package:eld_mobile/features/profile/domain/submit_outcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/m11_test_harness.dart';

void main() {
  group('M-48 Give feedback', () {
    testWidgets('boshlang\'ich holat: intro + ikki savol + 5 yulduz', (WidgetTester tester) async {
      await pumpM11Screen(tester, const FeedbackScreen(), overrides: m11Overrides());

      expect(find.text(l10n.feedbackIntro), findsOneWidget);
      expect(find.text(l10n.feedbackRatingQuestion), findsOneWidget);
      expect(find.text(l10n.feedbackFeatureQuestion), findsOneWidget);
      expect(find.byType(StarRating), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(StarRating.maxStars));
      expect(appButton(l10n.feedbackSubmit), findsOneWidget);
    });

    testWidgets('baho tanlanmasa Submit xato ko\'rsatadi va so\'rov ketmaydi', (
      WidgetTester tester,
    ) async {
      final FakeFeedbackRepository repo = FakeFeedbackRepository();
      await pumpM11Screen(tester, const FeedbackScreen(), overrides: m11Overrides(feedback: repo));

      await tester.tap(find.text(l10n.feedbackSubmit));
      await settle(tester);
      expect(find.text(l10n.feedbackRatingRequired), findsOneWidget);
      expect(repo.submitted, isEmpty);
    });

    testWidgets('yulduz tanlanadi va `POST /feedback` yuboriladi', (WidgetTester tester) async {
      final FakeFeedbackRepository repo = FakeFeedbackRepository();
      await pumpM11Screen(tester, const FeedbackScreen(), overrides: m11Overrides(feedback: repo));

      await tester.tap(find.byIcon(Icons.star_rounded).at(3));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Add trailer presets');
      await settle(tester);
      await tester.tap(find.text(l10n.feedbackSubmit));
      await settle(tester);

      expect(repo.submitted, hasLength(1));
      expect(repo.submitted.single.rating, 4);
      expect(repo.submitted.single.text, 'Add trailer presets');
      expect(find.text(l10n.feedbackSent), findsOneWidget);
    });

    testWidgets('oflayn: navbatga qo\'yildi xabari (§5.3)', (WidgetTester tester) async {
      final FakeFeedbackRepository repo = FakeFeedbackRepository(outcome: SubmitOutcome.queued);
      await pumpM11Screen(tester, const FeedbackScreen(), overrides: m11Overrides(feedback: repo));

      await tester.tap(find.byIcon(Icons.star_rounded).last);
      await settle(tester);
      await tester.tap(find.text(l10n.feedbackSubmit));
      await settle(tester);
      expect(find.text(l10n.feedbackQueued), findsOneWidget);
    });

    testWidgets('xato holati: server xatosi matn sifatida ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(
        tester,
        const FeedbackScreen(),
        overrides: m11Overrides(feedback: FakeFeedbackRepository(error: kServerError)),
      );

      await tester.tap(find.byIcon(Icons.star_rounded).first);
      await settle(tester);
      await tester.tap(find.text(l10n.feedbackSubmit));
      await settle(tester);
      expect(find.text(l10n.feedbackSent), findsNothing);
      expect(find.text(l10n.feedbackQueued), findsNothing);
      // Xabar forma ichida `error` rangida chiqadi (`ErrorState` emas).
      expect(find.text(localizedApiError(l10n, kServerError)), findsOneWidget);
      expect(find.byType(ErrorState), findsNothing);
    });

    testWidgets('M113: planshetda savol matni «with the app?» ga o\'zgaradi', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(
        tester,
        const FeedbackScreen(),
        overrides: m11Overrides(),
        surface: const Size(1366, 1024),
      );
      expect(find.text(l10n.feedbackRatingQuestionTablet), findsOneWidget);
      expect(find.text(l10n.feedbackFeatureQuestionTablet), findsOneWidget);
      expect(find.text(l10n.feedbackRatingQuestion), findsNothing);
    });

    testWidgets('kirish imkoniyati: yulduzlar ≥48 dp va semantik yorliqli', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpM11Screen(tester, const FeedbackScreen(), overrides: m11Overrides());

      for (int i = 0; i < StarRating.maxStars; i++) {
        final Size size = tester.getSize(find.byIcon(Icons.star_rounded).at(i));
        expect(size.width, greaterThanOrEqualTo(TouchTarget.phone));
        expect(size.height, greaterThanOrEqualTo(TouchTarget.phone));
      }
      expect(find.bySemanticsLabel(l10n.feedbackStars(3)), findsOneWidget);
      handle.dispose();
    });
  });
}
