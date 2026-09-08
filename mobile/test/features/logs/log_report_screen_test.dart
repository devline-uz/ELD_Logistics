@Timeout(Duration(seconds: 60))
/// `M-22 Main` · `M-23 Logs` · `M-24 DVIR` · `M-25 detail` widget testlari.
///
/// Har ekran uchun 4 holat: yuklanish · bo'sh · xato · to'la.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/logs/domain/log_models.dart';
import 'package:eld_mobile/features/logs/presentation/screens/log_report_screen.dart';
import 'package:eld_mobile/features/logs/presentation/widgets/log_event_detail_sheet.dart';
import 'package:eld_mobile/features/logs/presentation/widgets/log_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hos_engine/hos_engine.dart' show ViolationType;

import 'm7_test_harness.dart';

void main() {
  group('M-22 Log Report — Main', () {
    testWidgets('to\'la holat: kun ma\'lumoti va Driver Information', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const LogReportScreen(),
        logs: FakeLogsRepository(day: sampleDay(), strip: <LogDayRef>[]),
      );

      expect(find.text('Log Report'), findsOneWidget);
      expect(find.text('Shipping documents'), findsOneWidget);
      // M97: kanonik `Home Terminal` (dizayndagi `Main Terminal` emas).
      expect(find.text('Home Terminal'), findsOneWidget);
      expect(find.text('Main Terminal'), findsNothing);
      expect(find.text('Not Signed'), findsOneWidget);
    });

    testWidgets('yuklanish holati: skelet', (WidgetTester tester) async {
      await pumpM7(tester, const LogReportScreen(), logs: FakeLogsRepository(loading: true));
      expect(find.byType(AppCard), findsNothing);
    });

    testWidgets('xato holati: Retry tugmasi', (WidgetTester tester) async {
      await pumpM7(tester, const LogReportScreen(), logs: FakeLogsRepository(failing: true));
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('14 kundan eski kun: oflayn xabari', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const LogReportScreen(),
        logs: FakeLogsRepository(day: sampleDay(available: false)),
      );
      expect(find.text('Connect to the internet to load older logs'), findsOneWidget);
    });
  });

  group('M-23 Log Report — Logs', () {
    testWidgets('grid, jamilar va jadval ko\'rinadi', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const LogReportScreen(initialTab: 'logs'),
        logs: FakeLogsRepository(
          day: sampleDay(
            alerts: const <LogAlert>[
              LogAlert(level: LogAlertLevel.warning, type: ViolationType.formMannerTrailer),
              LogAlert(level: LogAlertLevel.violation, type: ViolationType.driveLimit),
            ],
          ),
        ),
      );

      // M98: kanonik format `OFF hh:mm · SB … · DR … · ON …`.
      expect(find.textContaining('OFF 03:06'), findsOneWidget);
      // #B-05: matn `violations.type` dan lokalizatsiya qilinadi (server
      // `message` yubormaydi), shuning uchun `app_en.arb` dagi satrlar.
      expect(find.text('Warning: Missing trailer number'), findsOneWidget);
      expect(find.text('Violation: Driving limit exceeded'), findsOneWidget);
      // Figma jadvalida `Action` ustuni yo'q (M-23) — qulf/tahrirlash
      // belgisi M-25 kengaytirilgan ko'rinishida (M99).
      expect(find.text('Action'), findsNothing);
    });

    testWidgets('bo\'sh holat: eventlar yo\'q', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const LogReportScreen(initialTab: 'logs'),
        logs: FakeLogsRepository(day: sampleDay(events: const <LogEventView>[])),
      );
      expect(find.text('No log records'), findsOneWidget);
    });

    testWidgets('locked event: qulf ikonkasi, tahrirlash o\'chirilgan', (
      WidgetTester tester,
    ) async {
      await pumpM7(
        tester,
        const LogReportScreen(initialTab: 'logs'),
        logs: FakeLogsRepository(day: sampleDay(events: <LogEventView>[sampleEvent(locked: true)])),
      );

      await tester.tap(find.byType(LogTableRow).first);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('satr bosilganda M-25 bottom-sheet ochiladi', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const LogReportScreen(initialTab: 'logs'),
        logs: FakeLogsRepository(day: sampleDay(events: <LogEventView>[sampleEvent(edited: true)])),
      );

      await tester.tap(find.byType(LogTableRow).first);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(LogEventDetailView), findsOneWidget);
      expect(find.text('Engine hours'), findsOneWidget);
      // M137: tahrirlangan event belgisi va asl qiymat.
      expect(find.text('Edited'), findsOneWidget);
      expect(find.text('Original: DR 13:00-15:00'), findsOneWidget);
    });
  });

  group('M-24 Log Report — DVIR', () {
    testWidgets('bo\'sh holat dizayn matnlari', (WidgetTester tester) async {
      await pumpM7(tester, const LogReportScreen(initialTab: 'dvir'));
      expect(find.text('No DVIR Found'), findsOneWidget);
      expect(find.text('There is no data to show you right now'), findsOneWidget);
    });

    testWidgets('to\'la holat: DVIR satri', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const LogReportScreen(initialTab: 'dvir'),
        logs: FakeLogsRepository(
          dvir: <DvirListItem>[
            DvirListItem(
              id: 'd1',
              createdAt: DateTime(2026, 9, 6, 14, 24),
              type: 'pre_trip',
              trailerNumber: 'TR-9',
            ),
          ],
        ),
      );
      expect(find.text('TR-9'), findsOneWidget);
      expect(find.textContaining('pre_trip'), findsOneWidget);
    });
  });
}
