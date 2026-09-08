@Timeout(Duration(seconds: 60))
/// `M-37`…`M-41` widget testlari: yuklanish · bo'sh · xato · to'la holatlar.
library;

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/inspection/domain/inspection_grid.dart';
import 'package:eld_mobile/features/inspection/domain/inspection_models.dart';
import 'package:eld_mobile/features/inspection/presentation/controllers/inspection_controller.dart';
import 'package:eld_mobile/features/inspection/presentation/controllers/inspection_providers.dart';
import 'package:eld_mobile/features/inspection/presentation/controllers/inspection_send_controller.dart';
import 'package:eld_mobile/features/inspection/presentation/inspection_routes.dart';
import 'package:eld_mobile/features/inspection/presentation/screens/inspection_kiosk_screen.dart';
import 'package:eld_mobile/features/inspection/presentation/screens/inspection_report_screen.dart';
import 'package:eld_mobile/features/inspection/presentation/widgets/exit_pin_dialog.dart';
import 'package:eld_mobile/features/inspection/presentation/widgets/send_email_sheet.dart';
import 'package:eld_mobile/features/inspection/presentation/widgets/send_file_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import 'inspection_test_harness.dart';

void main() {
  const ApiError offline = ApiError(code: ApiErrorCode.clientNetwork, message: 'offline');

  group('M-37 Inspection Report', () {
    testWidgets('uch amal ko\'rinadi (M108: «to the DOT officer»)', (WidgetTester tester) async {
      await pumpInspectionScreen(
        tester,
        const InspectionReportScreen(),
        repository: FakeInspectionRepository(),
      );

      expect(find.text('Begin Inspection'), findsOneWidget);
      expect(find.text('Send via email'), findsOneWidget);
      expect(find.text('Send the file'), findsOneWidget);
      expect(find.text('Send the ELD output file to the DOT officer'), findsOneWidget);
    });

    testWidgets('xato holati: banner + Try again', (WidgetTester tester) async {
      final FakeInspectionRepository repo = FakeInspectionRepository()..beginError = offline;
      await pumpInspectionScreen(tester, const InspectionReportScreen(), repository: repo);

      await tester.tap(find.text('Begin Inspection'));
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(repo.calls, contains('begin'));
      expect(find.byType(BannerStrip), findsOneWidget);
    });
  });

  group('M-38 kiosk rejimi', () {
    testWidgets('to\'la holat: Log Form, grid va eventlar jadvali', (WidgetTester tester) async {
      await pumpInspectionScreen(
        tester,
        const InspectionKioskScreen(),
        repository: FakeInspectionRepository(),
        surface: const Size(1366, 1024),
      );

      expect(find.text('ONEBOOK Logistics'), findsOneWidget);
      expect(find.text('1200 Industrial Rd, Dallas, TX'), findsOneWidget);
      expect(find.byType(DutyGrid24h), findsOneWidget);
      expect(find.text('Waco, TX'), findsOneWidget);
      // M-38: navigatsiya yo'q.
      expect(find.byType(AppBarPrimary), findsNothing);
    });

    testWidgets('bo\'sh holat: kunlar yo\'q', (WidgetTester tester) async {
      final FakeInspectionRepository repo = FakeInspectionRepository(
        report: buildTestInspectionReport(dayCount: 0),
      );
      await pumpInspectionScreen(
        tester,
        const InspectionKioskScreen(),
        repository: repo,
        surface: const Size(1366, 1024),
      );

      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('xato holati: ErrorState', (WidgetTester tester) async {
      final FakeInspectionRepository repo = FakeInspectionRepository()..logsError = offline;
      await pumpInspectionScreen(
        tester,
        const InspectionKioskScreen(),
        repository: repo,
        surface: const Size(1366, 1024),
      );

      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('oflayn nusxa izohi ko\'rsatiladi', (WidgetTester tester) async {
      final FakeInspectionRepository repo = FakeInspectionRepository(
        report: buildTestInspectionReport(source: InspectionSource.local),
      );
      await pumpInspectionScreen(
        tester,
        const InspectionKioskScreen(),
        repository: repo,
        surface: const Size(1366, 1024),
      );

      expect(find.textContaining('Offline copy'), findsOneWidget);
    });
  });

  group('M-39 Exit PIN', () {
    testWidgets('noto\'g\'ri PIN xato matnini beradi', (WidgetTester tester) async {
      final FakeInspectionPinVerifier pin = FakeInspectionPinVerifier();
      await pumpInspectionScreen(
        tester,
        const ExitPinDialog(),
        repository: FakeInspectionRepository(),
        pin: pin,
      );

      await tester.enterText(find.byType(TextField).first, '000000');
      await tester.pump(const Duration(milliseconds: 20));
      await tester.tap(find.text('Exit inspection').last);
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(pin.calls, contains('000000'));
      expect(find.text('Incorrect PIN.'), findsOneWidget);
    });

    testWidgets('to\'liq bo\'lmagan PIN da tugma o\'chiq', (WidgetTester tester) async {
      await pumpInspectionScreen(
        tester,
        const ExitPinDialog(),
        repository: FakeInspectionRepository(),
      );

      await tester.enterText(find.byType(TextField).first, '123');
      await tester.pump(const Duration(milliseconds: 20));

      final AppButton confirm = tester.widget<AppButton>(
        find
            .ancestor(of: find.text('Exit inspection'), matching: find.bySubtype<AppButton>())
            .first,
      );
      expect(confirm.onPressed, isNull);
    });
  });

  group('M-40 Send via email', () {
    testWidgets('noto\'g\'ri email da validatsiya xabari', (WidgetTester tester) async {
      final FakeInspectionRepository repo = FakeInspectionRepository();
      await pumpInspectionScreen(tester, sheetHost(const SendEmailSheet()), repository: repo);

      await tester.enterText(find.byType(TextField).first, 'not-an-email');
      await tester.pump(const Duration(milliseconds: 20));
      await tester.tap(find.text('Send Logs'));
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(repo.calls, isEmpty);
    });

    testWidgets('to\'g\'ri email yuboriladi', (WidgetTester tester) async {
      final FakeInspectionRepository repo = FakeInspectionRepository();
      await pumpInspectionScreen(tester, sheetHost(const SendEmailSheet()), repository: repo);

      await tester.enterText(find.byType(TextField).first, 'inspector@dot.gov');
      await tester.pump(const Duration(milliseconds: 20));
      await tester.tap(find.text('Send Logs'));
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(repo.calls, contains('email:inspector@dot.gov'));
    });
  });

  group('M-41 Send the file', () {
    testWidgets('Web service: transfer chaqiriladi', (WidgetTester tester) async {
      final FakeInspectionRepository repo = FakeInspectionRepository();
      await pumpInspectionScreen(tester, sheetHost(const SendFileSheet()), repository: repo);

      await tester.tap(find.text('Send'));
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(repo.calls, contains('transfer'));
    });

    testWidgets('Email tanlansa Email Address maydoni chiqadi', (WidgetTester tester) async {
      await pumpInspectionScreen(
        tester,
        sheetHost(const SendFileSheet()),
        repository: FakeInspectionRepository(),
      );

      expect(find.text('Email Address'), findsNothing);

      await tester.tap(find.text('Email'));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('Email Address'), findsOneWidget);
    });
  });

  group('domen va kontroller', () {
    test('marshrutlar registrga mos', () {
      expect(InspectionRoute.report, '/inspection');
      expect(InspectionRoute.kiosk, '/inspection/view');
    });

    test('email validatsiyasi', () {
      expect(InspectionEmailRequest.isValidEmail('inspector@dot.gov'), isTrue);
      expect(InspectionEmailRequest.isValidEmail('no-at-sign'), isFalse);
      expect(InspectionEmailRequest.isValidEmail('a@b'), isFalse);
    });

    test('kun oraliqlari eventlardan quriladi', () {
      final InspectionReport report = buildTestInspectionReport();
      final InspectionDay day = report.days.last;
      final List<InspectionSpan> spans = inspectionSpans(
        day: day,
        dayStart: DateTime.utc(2026, 9, 7),
      );

      expect(spans, hasLength(2));
      expect(spans.first.status, DutyStatus.on);
      expect(spans.first.start, const Duration(hours: 6));
      expect(spans.last.end, const Duration(hours: 24));
    });

    test('sessiya muddati tugashi aniqlanadi', () {
      final InspectionSession session = InspectionSession(
        token: 't',
        expiresAt: DateTime.utc(2026, 9, 7, 20),
      );
      expect(session.isExpiredAt(DateTime.utc(2026, 9, 7, 19)), isFalse);
      expect(session.isExpiredAt(DateTime.utc(2026, 9, 7, 20)), isTrue);
    });

    test('M-41: Email tanlangan yo\'l /inspection/email ga tushadi (M2)', () async {
      final FakeInspectionRepository repo = FakeInspectionRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[inspectionRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final InspectionTransferController controller =
          container.read(inspectionTransferControllerProvider.notifier)
            ..setType(InspectionTransferType.email)
            ..setEmail('inspector@dot.gov');
      await controller.send();

      expect(repo.calls, contains('email:inspector@dot.gov'));
      expect(repo.calls, isNot(contains('transfer')));
    });

    test('M-39: qulflangan PIN holati', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          inspectionPinVerifierProvider.overrideWithValue(FakeInspectionPinVerifier(locked: true)),
          inspectionRepositoryProvider.overrideWithValue(FakeInspectionRepository()),
        ],
      );
      addTearDown(container.dispose);

      final InspectionExitPinController controller = container.read(
        inspectionExitPinControllerProvider.notifier,
      )..setPin('123456');
      final bool ok = await controller.submit();

      expect(ok, isFalse);
      expect(container.read(inspectionExitPinControllerProvider).locked, isTrue);
    });
  });
}
