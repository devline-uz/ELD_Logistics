@Timeout(Duration(seconds: 60))
/// `T-14 Log Report — Main` · `T-15 Logs` · `T-16 DVIR` — planshet tartibi
/// (tz-mobile 1548–1550).
///
/// **A3:** planshet ko'rinishi telefon bilan bir xil `LogReportController` va
/// `logsRepositoryProvider` dan oziqlanadi — test shuni tekshiradi
/// (bir xil soxta repozitoriy, ikki xil tartib).
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/logs/domain/log_models.dart';
import 'package:eld_mobile/features/logs/presentation/screens/log_report_screen.dart';
import 'package:eld_mobile/features/logs/presentation/widgets/log_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'm7_test_harness.dart';

const Size _tablet = Size(1366, 1024);
const Size _phone = Size(393, 852);

void main() {
  DvirListItem dvir(String id) => DvirListItem(
    id: id,
    createdAt: DateTime(2026, 9, 7, 8),
    type: 'pre_trip',
    trailerNumber: 'TR-9',
  );

  group('T-14 Main', () {
    testWidgets('planshetda ikki karta yonma-yon (Row), telefonda ustma-ust', (
      WidgetTester tester,
    ) async {
      await pumpM7(tester, const LogReportScreen(initialTab: 'main'), surface: _tablet);

      final Finder cards = find.byType(AppCard);
      expect(cards, findsNWidgets(2));
      // #B-21: ikkinchi karta ustida bo'lim sarlavhasi bor, shuning uchun
      // dy teng emas — yonma-yonlik dx bilan tekshiriladi.
      expect(tester.getTopLeft(cards.at(1)).dx, greaterThan(tester.getTopLeft(cards.at(0)).dx));
      expect(find.byType(LogSectionTitle), findsOneWidget);
    });

    testWidgets('telefonda kartalar vertikal', (WidgetTester tester) async {
      await pumpM7(tester, const LogReportScreen(initialTab: 'main'), surface: _phone);

      final Finder cards = find.byType(AppCard);
      expect(cards, findsNWidgets(2));
      expect(tester.getTopLeft(cards.at(1)).dy, greaterThan(tester.getTopLeft(cards.at(0)).dy));
      expect(tester.getTopLeft(cards.at(1)).dx, tester.getTopLeft(cards.at(0)).dx);
    });
  });

  group('T-16 DVIR', () {
    testWidgets('planshetda ikki ustunli grid', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const LogReportScreen(initialTab: 'dvir'),
        logs: FakeLogsRepository(dvir: <DvirListItem>[dvir('d1'), dvir('d2')]),
        surface: _tablet,
      );

      expect(find.byType(GridView), findsOneWidget);
      final Finder tiles = find.byType(DvirListTile);
      expect(tiles, findsNWidgets(2));
      expect(
        tester.getTopLeft(tiles.at(0)).dy,
        tester.getTopLeft(tiles.at(1)).dy,
        reason: 'ikkinchi element birinchi qator ikkinchi ustunida',
      );
    });

    testWidgets('telefonda oddiy ro\'yxat', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const LogReportScreen(initialTab: 'dvir'),
        logs: FakeLogsRepository(dvir: <DvirListItem>[dvir('d1'), dvir('d2')]),
        surface: _phone,
      );

      expect(find.byType(GridView), findsNothing);
      expect(find.byType(DvirListTile), findsNWidgets(2));
    });
  });

  group('#B-64 maxContentWidth', () {
    testWidgets('planshetda tana 1040 dp dan keng emas', (WidgetTester tester) async {
      await pumpM7(tester, const LogReportScreen(initialTab: 'main'), surface: _tablet);

      final Finder box = find.byType(ContentMaxWidth);
      expect(box, findsOneWidget);
      expect(tester.widget<ContentMaxWidth>(box).maxWidth, ContentWidth.wide);
      // `ContentMaxWidth` o'zi `Align` — to'liq kenglikni egallaydi; cheklov
      // uning bolasiga (`AdaptiveView`) tegishli.
      final Finder inner = find.descendant(of: box, matching: find.byType(AdaptiveView));
      expect(tester.getSize(inner).width, lessThanOrEqualTo(ContentWidth.wide));
    });

    testWidgets('telefonda cheklov qo\'llanmaydi', (WidgetTester tester) async {
      await pumpM7(tester, const LogReportScreen(initialTab: 'main'), surface: _phone);

      final Finder inner = find.descendant(
        of: find.byType(ContentMaxWidth),
        matching: find.byType(AdaptiveView),
      );
      expect(tester.getSize(inner).width, _phone.width);
    });
  });
}
