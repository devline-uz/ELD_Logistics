@Timeout(Duration(seconds: 60))
/// `M-12`, `M-13`, `M-14` widget testlari — har ekran 4 holatda
/// (yuklanish · bo'sh · xato · to'la), C.3 DoD.
library;

import 'package:eld_mobile/core/eld/eld_models.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/ui/components/components.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_models.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_rules.dart';
import 'package:eld_mobile/features/duty_status/presentation/screens/change_duty_status_screen.dart';
import 'package:eld_mobile/features/duty_status/presentation/widgets/location_inaccurate_dialog.dart';
import 'package:eld_mobile/features/duty_status/presentation/widgets/quick_notes_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hos_engine/hos_engine.dart';
import 'package:sync_core/sync_core.dart';

import 'duty_test_harness.dart';

Finder appButton(String label) =>
    find.ancestor(of: find.text(label), matching: find.bySubtype<AppButton>());

void main() {
  late FakeDutyStatusRepository duty;

  setUp(() => duty = FakeDutyStatusRepository());
  tearDown(() => duty.dispose());

  group('M-12 Change duty status', () {
    testWidgets('yuklanish: skeleton ko\'rsatiladi', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const ChangeDutyStatusScreen(),
        overrides: m4Overrides(duty: duty, contextLoading: true),
      );
      expect(find.byType(LoadingSkeleton), findsOneWidget);
    });

    testWidgets('to\'la: uchta status tugmasi va HOS indikatorlari (M52)', (
      WidgetTester tester,
    ) async {
      await pumpM4(
        tester,
        child: const ChangeDutyStatusScreen(),
        overrides: m4Overrides(duty: duty),
      );
      expect(find.text('Off Duty'), findsOneWidget);
      // Figma `1083:10550`: yorliq `Sleep` (bir qatorga sig'adi).
      expect(find.text('Sleep'), findsOneWidget);
      expect(find.text('On Duty'), findsOneWidget);
      // M51: `Driving` tugmasi umuman yo'q.
      expect(find.text('Driving'), findsNothing);
      // #B-22: M-12 da halqa gauge'lar.
      expect(find.byType(HosRingIndicator), findsNWidgets(4));
    });

    testWidgets('bo\'sh: status o\'zgarmasa Save o\'chirilgan', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const ChangeDutyStatusScreen(),
        overrides: m4Overrides(duty: duty),
      );
      final AppButton save = tester.widget<AppButton>(appButton('Save'));
      expect(save.onPressed, isNull);
    });

    testWidgets('to\'la: statusni almashtirib saqlaydi (ELD ulangan → driver)', (
      WidgetTester tester,
    ) async {
      await pumpM4(
        tester,
        child: const ChangeDutyStatusScreen(),
        overrides: m4Overrides(duty: duty),
      );
      await tester.tap(find.text('Off Duty'));
      await tester.pump();
      await tester.tap(appButton('Save'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(duty.changes, hasLength(1));
      expect(duty.changes.single.draft.status, DutyStatusValue.off);
      expect(duty.changes.single.origin, EventOrigin.driver);
    });

    testWidgets('M66: ELD ulanmagan — banner va origin=manual_no_eld', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const ChangeDutyStatusScreen(),
        overrides: m4Overrides(duty: duty, eld: EldConnectionState.notConnected),
      );
      expect(find.byType(BannerStrip), findsOneWidget);

      await tester.tap(find.text('Off Duty'));
      await tester.pump();
      // #B-80: AppChip teginish maydoni 48 dp ga kengaydi — Save pastroqda.
      await tester.ensureVisible(appButton('Save'));
      await tester.pumpAndSettle();
      await tester.tap(appButton('Save'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(duty.changes.single.origin, EventOrigin.manualNoEld);
    });

    testWidgets('xato: repozitoriy xatosi ekranda ko\'rsatiladi', (WidgetTester tester) async {
      duty.error = const ApiError(code: ApiErrorCode.internalError, message: 'boom');
      await pumpM4(
        tester,
        child: const ChangeDutyStatusScreen(),
        overrides: m4Overrides(duty: duty),
      );
      await tester.tap(find.text('Off Duty'));
      await tester.pump();
      await tester.tap(appButton('Save'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(duty.changes, isEmpty);
      expect(find.byType(ChangeDutyStatusScreen), findsOneWidget);
      expect(
        tester.widgetList<Text>(find.byType(Text)).any((Text t) => t.style?.color != null),
        isTrue,
      );
    });

    testWidgets('M64: allow_pc=false bo\'lsa PC toggle yashiriladi', (WidgetTester tester) async {
      final FakeDutyStatusRepository repo = FakeDutyStatusRepository(
        context: testContext(
          status: DutyStatusValue.off,
          policy: parsePolicy(<String, dynamic>{'allow_pc': false}),
        ),
      );
      addTearDown(repo.dispose);
      await pumpM4(
        tester,
        child: const ChangeDutyStatusScreen(),
        overrides: m4Overrides(duty: repo),
      );
      expect(find.text('Personal conveyance'), findsNothing);
    });
  });

  group('M-13 Quick notes', () {
    testWidgets('bo\'sh server ro\'yxati: M54 fallback 10 band', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const Scaffold(body: QuickNotesPicker()),
        overrides: m4Overrides(duty: duty),
      );
      expect(find.text('PTI'), findsOneWidget);
      expect(find.text('Drop off'), findsOneWidget);
      expect(find.text('Check out'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(10));
    });

    testWidgets('to\'la: server ro\'yxati fallback ustidan ustun (M55)', (
      WidgetTester tester,
    ) async {
      await pumpM4(
        tester,
        child: const Scaffold(body: QuickNotesPicker()),
        overrides: m4Overrides(
          duty: duty,
          catalog: FakeDutyCatalogRepository(
            quickNotes: const <QuickNoteOption>[QuickNoteOption(id: 'x', label: 'Server note')],
          ),
        ),
      );
      expect(find.text('Server note'), findsOneWidget);
      expect(find.text('PTI'), findsNothing);
    });

    testWidgets('tanlov `Add Notes` bilan qaytariladi', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const Scaffold(body: QuickNotesPicker()),
        overrides: m4Overrides(duty: duty),
      );
      final AppButton disabled = tester.widget<AppButton>(appButton('Add Notes'));
      expect(disabled.onPressed, isNull);

      await tester.tap(find.text('Fueling'));
      await tester.pump();
      final AppButton enabled = tester.widget<AppButton>(appButton('Add Notes'));
      expect(enabled.onPressed, isNotNull);
    });
  });

  group('M-14 Location inaccurate', () {
    testWidgets('to\'la: matn va ikkita amal', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const Scaffold(body: LocationInaccurateDialog()),
        overrides: m4Overrides(duty: duty),
      );
      expect(
        find.text('It looks like your location might be inaccurate. Want to update it?'),
        findsOneWidget,
      );
      expect(find.text('It might take a few moments to proceed!'), findsOneWidget);
      expect(appButton('Update Now'), findsOneWidget);
    });
  });

  group('Domen qoidalari (tz-mobile §9)', () {
    test('M52: sleeper berth bo\'lmasa tanlash rad etiladi', () {
      final DutyStatusContext context = testContext(
        status: DutyStatusValue.on,
        policy: parsePolicy(<String, dynamic>{'sleeper_berth_available': false}),
      );
      final List<DutyIssue> issues = validateDutyDraft(
        draft: const DutyStatusDraft(status: DutyStatusValue.sleeper),
        context: context,
      );
      expect(issues, contains(DutyIssue.sleeperUnavailable));
    });

    test('PC uchun sabab majburiy', () {
      final List<DutyIssue> issues = validateDutyDraft(
        draft: const DutyStatusDraft(
          status: DutyStatusValue.off,
          special: DutySpecial.personalConveyance,
        ),
        context: testContext(),
      );
      expect(issues, contains(DutyIssue.reasonRequired));
    });

    test('M51: `DR` qo\'lda tanlanmaydi', () {
      final List<DutyIssue> issues = validateDutyDraft(
        draft: const DutyStatusDraft(status: DutyStatusValue.driving),
        context: testContext(),
      );
      expect(issues, contains(DutyIssue.drivingNotManual));
    });

    test('M55: quick note qo\'shiladi va 60 belgida kesiladi', () {
      expect(appendQuickNote('PTI', 'Hook'), 'PTI, Hook');
      final String long = appendQuickNotes('', List<String>.filled(10, 'Inspection'));
      expect(long.length, kMaxDutyNotesLength);
      expect(quickNotesTruncated('', List<String>.filled(10, 'Inspection')), isTrue);
    });

    test('aniqlik 150 m dan yomon bo\'lsa M-14 taklif qilinadi', () {
      expect(locationNeedsConfirmation(120), isFalse);
      expect(locationNeedsConfirmation(151), isTrue);
      expect(locationNeedsConfirmation(null), isFalse);
    });

    test('M66: ELD yo\'q — origin `manual_no_eld`', () {
      expect(dutyEventOrigin(eldConnected: false), EventOrigin.manualNoEld);
      expect(dutyEventOrigin(eldConnected: true), EventOrigin.driver);
      expect(dutyEventOrigin(eldConnected: true, auto: true), EventOrigin.auto);
    });

    test('YM tezlik chegarasidan oshsa tugaydi', () {
      expect(
        yardMoveExpired(special: DutySpecial.yardMove, speedKmh: 40, policy: defaultPolicy()),
        isTrue,
      );
      expect(
        yardMoveExpired(special: DutySpecial.yardMove, speedKmh: 10, policy: defaultPolicy()),
        isFalse,
      );
    });
  });
}
