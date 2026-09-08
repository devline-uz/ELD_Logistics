@Timeout(Duration(seconds: 60))
/// **#B-133** — modal tanasi uchun yagona `modalPane()` yordamchisi.
///
/// `TabletModal` `showDialog` orqali `Scaffold`dan tashqarida ochiladi:
/// tanada `InkWell`/`ListTile` bo'lsa `Material` ajdodi bo'lmasdi va
/// «No Material widget found» xatosi chiqardi. Ilgari har modal fayli buni
/// o'zining `_pane()` nusxasi bilan yopardi (7 ta dublikat).
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// `Scaffold`siz daraxt — dialog konteksti bilan bir xil shart.
Future<void> pumpBare(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.of(Brightness.light),
    home: Center(child: child),
  ),
);

void main() {
  testWidgets('modalPane `Material` ajdodi beradi (ListTile yiqilmaydi)', (
    WidgetTester tester,
  ) async {
    await pumpBare(tester, modalPane(const ListTile(title: Text('row')), 120));

    expect(tester.takeException(), isNull);
    expect(find.text('row'), findsOneWidget);
  });

  testWidgets('modalPane balandlikni bog\'laydi (ListView cheksiz o\'smaydi)', (
    WidgetTester tester,
  ) async {
    await pumpBare(
      tester,
      modalPane(
        ListView(
          children: const <Widget>[
            ListTile(title: Text('a')),
            ListTile(title: Text('b')),
          ],
        ),
        120,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ListView)).height, 120);
  });

  testWidgets('TabletModal tanasi Scaffoldsiz ham `Material` oladi', (WidgetTester tester) async {
    await pumpBare(
      tester,
      const TabletModal(
        title: 'Title',
        child: SizedBox(height: 80, child: ListTile(title: Text('x'))),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('x'), findsOneWidget);
  });
}
