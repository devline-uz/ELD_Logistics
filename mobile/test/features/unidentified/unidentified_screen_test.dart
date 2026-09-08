@Timeout(Duration(seconds: 60))
/// `M-28 Unidentified driving claim` widget testlari (M100).
library;

import 'package:eld_mobile/features/unidentified/domain/unidentified_models.dart';
import 'package:eld_mobile/features/unidentified/presentation/screens/unidentified_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../logs/m7_test_harness.dart';

UnidentifiedBlock _block({String id = 'u1', bool pendingSync = false}) => UnidentifiedBlock(
  id: id,
  unitId: '1021',
  start: DateTime(2026, 9, 7, 8),
  end: DateTime(2026, 9, 7, 9, 30),
  distanceM: 48280,
  status: UnidentifiedStatus.pending,
  pendingSync: pendingSync,
);

void main() {
  testWidgets('bo\'sh holat', (WidgetTester tester) async {
    await pumpM7(tester, const UnidentifiedScreen());
    expect(find.text('No unidentified driving'), findsOneWidget);
  });

  testWidgets('yuklanish holati', (WidgetTester tester) async {
    await pumpM7(
      tester,
      const UnidentifiedScreen(),
      unidentified: FakeUnidentifiedRepository(loading: true),
    );
    expect(find.text('No unidentified driving'), findsNothing);
  });

  testWidgets('to\'la holat: banner, maydonlar va ikkita amal', (WidgetTester tester) async {
    await pumpM7(
      tester,
      const UnidentifiedScreen(),
      unidentified: FakeUnidentifiedRepository(blocks: <UnidentifiedBlock>[_block()]),
    );

    expect(find.text('There are 1 unidentified driving events on this vehicle.'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('01:30:00'), findsOneWidget);
    expect(find.text('30.00 mi'), findsOneWidget);
    expect(find.text('This was me'), findsOneWidget);
    expect(find.text('Not mine'), findsOneWidget);
  });

  testWidgets('`This was me` claim ni navbatga qo\'yadi', (WidgetTester tester) async {
    final FakeUnidentifiedRepository repo = FakeUnidentifiedRepository(
      blocks: <UnidentifiedBlock>[_block()],
    );
    await pumpM7(tester, const UnidentifiedScreen(), unidentified: repo);

    await tester.tap(find.text('This was me'));
    await tester.pump();
    expect(repo.claimed, <String>['u1']);
  });

  testWidgets('409 ALREADY_ASSIGNED xabari ko\'rsatiladi', (WidgetTester tester) async {
    final FakeUnidentifiedRepository repo = FakeUnidentifiedRepository(
      blocks: <UnidentifiedBlock>[_block()],
    )..outcome = ClaimOutcome.alreadyAssigned;
    await pumpM7(tester, const UnidentifiedScreen(), unidentified: repo);

    await tester.tap(find.text('This was me'));
    await tester.pump();
    expect(find.text('This block was already assigned to another driver.'), findsOneWidget);
  });

  testWidgets('`Not mine` faqat lokal yashiradi', (WidgetTester tester) async {
    final FakeUnidentifiedRepository repo = FakeUnidentifiedRepository(
      blocks: <UnidentifiedBlock>[_block()],
    );
    await pumpM7(tester, const UnidentifiedScreen(), unidentified: repo);

    await tester.tap(find.text('Not mine'));
    await tester.pump();
    expect(repo.dismissed, <String>['u1']);
    expect(repo.claimed, isEmpty);
  });

  testWidgets('oflayn: `Pending sync` badge va claim bloklangan', (WidgetTester tester) async {
    await pumpM7(
      tester,
      const UnidentifiedScreen(),
      unidentified: FakeUnidentifiedRepository(
        blocks: <UnidentifiedBlock>[_block(pendingSync: true)],
      ),
    );
    expect(find.text('Pending sync'), findsOneWidget);
  });
}
