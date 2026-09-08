/// `core/ui/components` widget testlari — 18 komponent.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_test_harness.dart';

void main() {
  group('AppButton', () {
    testWidgets('primary bosilganda callback ishlaydi', (WidgetTester tester) async {
      int taps = 0;
      await pumpUi(tester, AppButton.primary(label: 'Save', onPressed: () => taps++));
      await tester.tap(find.text('Save'));
      expect(taps, 1);
    });

    testWidgets('onPressed null — bosilmaydi va disabled ranglarda', (WidgetTester tester) async {
      await pumpUi(tester, const AppButton.primary(label: 'Save'));
      await tester.tap(find.text('Save'));
      final Text label = tester.widget(find.text('Save'));
      expect(label.style!.color, AppColors.light.textDisabled);
    });

    // #B-63: M-47 `Check Network` — Figma da fon `#1C1E24`, brend qizil emas.
    testWidgets('neutral — fon neutralStrong, matn onNeutralStrong', (WidgetTester tester) async {
      await pumpUi(tester, AppButton.neutral(label: 'Check Network', onPressed: () {}));
      final Material m = tester.widget(
        find.ancestor(of: find.text('Check Network'), matching: find.byType(Material)).first,
      );
      expect(m.color, AppColors.light.neutralStrong);
      final Text label = tester.widget(find.text('Check Network'));
      expect(label.style!.color, AppColors.light.onNeutralStrong);
    });

    testWidgets('busy — spinner ko\'rinadi, matn yo\'q', (WidgetTester tester) async {
      await pumpUi(tester, AppButton.primary(label: 'Save', busy: true, onPressed: () {}));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('destructive — matn error rangida (secondary)', (WidgetTester tester) async {
      await pumpUi(
        tester,
        AppButton.secondary(label: 'Delete', destructive: true, onPressed: () {}),
      );
      final Text label = tester.widget(find.text('Delete'));
      expect(label.style!.color, AppColors.light.error);
    });

    testWidgets('telefon 48, planshet 56, haydash 64 dp', (WidgetTester tester) async {
      // AppButton — sealed bo'lmagan bazaviy sinf; variantlar yopiq subclass'lar.
      final Finder button = find.byWidgetPredicate((Widget w) => w is AppButton);

      await pumpUi(tester, AppButton.primary(label: 'A', onPressed: () {}));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(TouchTarget.phone));

      await pumpUi(
        tester,
        AppButton.primary(label: 'A', onPressed: () {}),
        size: kTabletSize,
      );
      expect(tester.getSize(button).height, greaterThanOrEqualTo(TouchTarget.tablet));

      await pumpUi(tester, AppButton.primary(label: 'A', drivingMode: true, onPressed: () {}));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(TouchTarget.driving));
    });
  });

  group('AppTextField', () {
    testWidgets('xato matni ko\'rinadi va error rangida', (WidgetTester tester) async {
      await pumpUi(tester, const AppTextField(label: 'Odometer', errorText: 'Required'));
      expect(find.text('Odometer'), findsOneWidget);
      final Text err = tester.widget(find.text('Required'));
      expect(err.style!.color, AppColors.light.error);
    });

    testWidgets('helper faqat xato yo\'qligida ko\'rinadi', (WidgetTester tester) async {
      await pumpUi(tester, const AppTextField(helperText: 'Miles only'));
      expect(find.text('Miles only'), findsOneWidget);

      await pumpUi(tester, const AppTextField(helperText: 'Miles only', errorText: 'Bad'));
      expect(find.text('Miles only'), findsNothing);
      expect(find.text('Bad'), findsOneWidget);
    });

    testWidgets('kiritish onChanged ga uzatiladi', (WidgetTester tester) async {
      String value = '';
      await pumpUi(tester, AppTextField(onChanged: (String v) => value = v));
      await tester.enterText(find.byType(TextField), '1042');
      expect(value, '1042');
    });
  });

  group('AppChip', () {
    Color pillColor(WidgetTester tester) {
      final DecoratedBox box = tester.widget(
        find.ancestor(of: find.text('All'), matching: find.byType(DecoratedBox)).first,
      );
      return (box.decoration as BoxDecoration).color!;
    }

    testWidgets('tanlanganda primary fon, aks holda surfaceAlt', (WidgetTester tester) async {
      await pumpUi(tester, const AppChip(label: 'All', selected: true));
      expect(pillColor(tester), AppColors.light.primary);

      await pumpUi(tester, const AppChip(label: 'All'));
      expect(pillColor(tester), AppColors.light.surfaceAlt);
    });

    testWidgets('count ko\'rsatiladi', (WidgetTester tester) async {
      await pumpUi(tester, const AppChip(label: 'DVIR', count: 4));
      expect(find.text('4'), findsOneWidget);
    });

    // #B-80 (M8): teginish maydoni ≥48 dp, ko'rinadigan «tabletka» esa ~34 dp.
    testWidgets('interaktiv chip teginish maydoni ≥48 dp', (WidgetTester tester) async {
      await pumpUi(tester, AppChip(label: 'All', onTap: () {}));
      final Size hit = tester.getSize(find.byType(AppChip));
      expect(hit.height, greaterThanOrEqualTo(48));
      expect(hit.width, greaterThanOrEqualTo(48));

      final Size pill = tester.getSize(
        find.ancestor(of: find.text('All'), matching: find.byType(DecoratedBox)).first,
      );
      expect(pill.height, lessThan(hit.height));
    });

    testWidgets('kengaytirilgan maydonning cheti ham bosiladi', (WidgetTester tester) async {
      int taps = 0;
      await pumpUi(tester, AppChip(label: 'All', onTap: () => taps++));
      final Rect box = tester.getRect(find.byType(AppChip));
      await tester.tapAt(Offset(box.center.dx, box.top + 2));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('interaktiv bo\'lmagan chip o\'lchamini o\'zgartirmaydi', (
      WidgetTester tester,
    ) async {
      await pumpUi(tester, const AppChip(label: 'All'));
      expect(tester.getSize(find.byType(AppChip)).height, lessThan(48));
    });
  });

  group('StatusBadge', () {
    testWidgets('tone bo\'yicha matn rangi', (WidgetTester tester) async {
      for (final (StatusTone tone, Color expected) in <(StatusTone, Color)>[
        // PARITY #B-17: to'ldirilgan badge — matn oq.
        (StatusTone.success, AppColors.light.onPrimary),
        (StatusTone.warning, AppColors.light.onPrimary),
        (StatusTone.error, AppColors.light.onPrimary),
        (StatusTone.neutral, AppColors.light.textSecondary),
        (StatusTone.accent, AppColors.light.onPrimary),
      ]) {
        await pumpUi(tester, StatusBadge(label: 'S', tone: tone));
        final Text t = tester.widget(find.text('S'));
        expect(t.style!.color, expected, reason: '$tone');
      }
    });

    testWidgets('M81: dark temada ham bir xil rang', (WidgetTester tester) async {
      await pumpUi(
        tester,
        const StatusBadge(label: 'S', tone: StatusTone.success),
        brightness: Brightness.dark,
      );
      final Text t = tester.widget(find.text('S'));
      expect(t.style!.color, AppColors.light.onPrimary);
    });
  });

  group('HOS indikatorlari', () {
    const HosGaugeData gauge = HosGaugeData(
      bucket: HosBucket.drive,
      label: 'DRIVE',
      remaining: Duration(hours: 8, minutes: 30),
      total: Duration(hours: 11),
    );

    test('progress va HH:mm format', () {
      expect(gauge.progress, closeTo(8.5 / 11, 1e-9));
      expect(gauge.formatted, '08:30');
      expect(gauge.exhausted, isFalse);
    });

    test('limit tugagan holat', () {
      const HosGaugeData g = HosGaugeData(
        bucket: HosBucket.cycle,
        label: 'CYCLE',
        remaining: Duration.zero,
        total: Duration(hours: 70),
      );
      expect(g.progress, 0);
      expect(g.formatted, '00:00');
      expect(g.exhausted, isTrue);
    });

    test('total nol bo\'lsa progress 0 (nolga bo\'lish yo\'q)', () {
      const HosGaugeData g = HosGaugeData(
        bucket: HosBucket.shift,
        label: 'SHIFT',
        remaining: Duration(hours: 1),
        total: Duration.zero,
      );
      expect(g.progress, 0);
    });

    testWidgets('linear: nom va vaqt ko\'rinadi', (WidgetTester tester) async {
      await pumpUi(tester, const HosLinearIndicator(data: gauge));
      expect(find.text('DRIVE'), findsOneWidget);
      expect(find.text('08:30'), findsOneWidget);
    });

    testWidgets('ring: markazda vaqt, ostida nom', (WidgetTester tester) async {
      await pumpUi(tester, const HosRingIndicator(data: gauge), size: kTabletSize);
      expect(find.text('08:30'), findsOneWidget);
      expect(find.text('DRIVE'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('DutyGrid24h', () {
    testWidgets('bo\'sh kunda ham chiziladi', (WidgetTester tester) async {
      await pumpUi(
        tester,
        const DutyGrid24h(
          segments: <DutySegment>[],
          rowLabels: <DutySlot, String>{
            DutySlot.offDuty: 'OFF',
            DutySlot.sleeper: 'SB',
            DutySlot.driving: 'D',
            DutySlot.onDuty: 'ON',
          },
        ),
      );
      expect(find.byType(DutyGrid24h), findsOneWidget);
    });

    test('geometriya barqaror', () {
      expect(DutyGridMetrics.gridWidth, 24 * DutyGridMetrics.hourWidth);
      expect(DutyGridMetrics.gridHeight, 4 * DutyGridMetrics.rowHeight);
    });

    test('DutySegment uzunligi', () {
      const DutySegment s = DutySegment(
        slot: DutySlot.driving,
        start: Duration(hours: 7),
        end: Duration(hours: 12),
      );
      expect(s.length, const Duration(hours: 5));
    });

    test('M65: segment yorlig\'i ixtiyoriy va standart null', () {
      const DutySegment plain = DutySegment(
        slot: DutySlot.driving,
        start: Duration(hours: 1),
        end: Duration(hours: 2),
      );
      const DutySegment labelled = DutySegment(
        slot: DutySlot.onDuty,
        start: Duration(hours: 2),
        end: Duration(hours: 4),
        label: 'YM',
      );
      expect(plain.label, isNull);
      expect(labelled.label, 'YM');
    });

    testWidgets('M65: PC/YM yorliqli segmentlar chiziladi', (WidgetTester tester) async {
      await pumpUi(
        tester,
        const DutyGrid24h(
          segments: <DutySegment>[
            DutySegment(
              slot: DutySlot.offDuty,
              start: Duration(hours: 1),
              end: Duration(hours: 5),
              label: 'PC',
            ),
            DutySegment(
              slot: DutySlot.onDuty,
              start: Duration(hours: 5),
              end: Duration(hours: 9),
              label: 'YM',
            ),
            // Yorliqsiz segment — mavjud chaqiruvlar buzilmaydi.
            DutySegment(
              slot: DutySlot.driving,
              start: Duration(hours: 9),
              end: Duration(hours: 12),
            ),
          ],
          rowLabels: <DutySlot, String>{
            DutySlot.offDuty: 'OFF',
            DutySlot.sleeper: 'SB',
            DutySlot.driving: 'D',
            DutySlot.onDuty: 'ON',
          },
        ),
      );

      expect(find.byType(DutyGrid24h), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DateStrip8Day', () {
    testWidgets('8 kun chiziladi, tanlangan kun bosilganda callback', (WidgetTester tester) async {
      DateTime? picked;
      final List<DateStripDay> days = <DateStripDay>[
        for (int i = 0; i < 8; i++) DateStripDay(date: DateTime.utc(2025, 5, 14 + i)),
      ];
      await pumpUi(
        tester,
        SizedBox(
          width: 393,
          child: DateStrip8Day(
            days: days,
            selected: DateTime.utc(2025, 5, 18),
            onSelected: (DateTime d) => picked = d,
          ),
        ),
      );
      // PARITY #B-16: ikki qator — `Wed` va `14`.
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      await tester.tap(find.text('14'));
      expect(picked, DateTime.utc(2025, 5, 14));
    });
  });

  group('EmptyState / ErrorState / LoadingSkeleton', () {
    testWidgets('EmptyState sarlavha, matn va amal', (WidgetTester tester) async {
      int taps = 0;
      await pumpUi(
        tester,
        EmptyState(
          title: 'No DVIR Found',
          message: 'There is no data to show you right now.',
          actionLabel: 'Add',
          onAction: () => taps++,
        ),
      );
      expect(find.text('No DVIR Found'), findsOneWidget);
      await tester.tap(find.text('Add'));
      expect(taps, 1);
    });

    testWidgets('ErrorState Retry bosiladi', (WidgetTester tester) async {
      int retries = 0;
      await pumpUi(
        tester,
        ErrorState(message: 'Failed', retryLabel: 'Retry', onRetry: () => retries++),
      );
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    });

    testWidgets('ErrorState onRetry yo\'q — tugma chizilmaydi', (WidgetTester tester) async {
      await pumpUi(tester, const ErrorState(message: 'Failed', retryLabel: 'Retry'));
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('LoadingSkeleton berilgan sonda karta chizadi', (WidgetTester tester) async {
      await pumpUi(
        tester,
        const SizedBox(
          height: 600,
          width: 393,
          child: LoadingSkeleton(itemCount: 3, animate: false),
        ),
      );
      expect(find.byType(SkeletonBox), findsWidgets);
    });
  });

  group('BannerStrip', () {
    testWidgets('balandligi 32 dp va matn ko\'rinadi', (WidgetTester tester) async {
      await pumpUi(
        tester,
        const SizedBox(
          width: 393,
          child: BannerStrip(message: 'Offline — 3 records queued', tone: BannerTone.offline),
        ),
      );
      expect(find.text('Offline — 3 records queued'), findsOneWidget);
      expect(tester.getSize(find.byType(BannerStrip)).height, kBannerHeight);
    });

    testWidgets('amal bosiladi', (WidgetTester tester) async {
      int taps = 0;
      await pumpUi(
        tester,
        SizedBox(
          width: 393,
          child: BannerStrip(
            message: 'ELD disconnected',
            tone: BannerTone.eld,
            actionLabel: 'Reconnect',
            onAction: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('Reconnect'));
      expect(taps, 1);
    });
  });

  group('SyncIndicator', () {
    testWidgets('holatlarga mos ikonka', (WidgetTester tester) async {
      await pumpUi(tester, const SyncIndicator(status: SyncStatus.idle));
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await pumpUi(tester, const SyncIndicator(status: SyncStatus.error));
      expect(find.byIcon(Icons.sync_problem), findsOneWidget);

      await pumpUi(tester, const SyncIndicator(status: SyncStatus.offline));
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });
  });

  group('ConfirmDialog', () {
    testWidgets('Confirm true, Cancel false qaytaradi', (WidgetTester tester) async {
      bool? result;
      await pumpUi(
        tester,
        Builder(
          builder: (BuildContext context) => AppButton.primary(
            label: 'Open',
            onPressed: () async {
              result = await showConfirmDialog(
                context: context,
                title: 'Are you absolutely sure?',
                message: 'This cannot be undone.',
                cancelLabel: 'Cancel',
                confirmLabel: 'Confirm',
                destructive: true,
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Are you absolutely sure?'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });

  group('AppBarPrimary', () {
    testWidgets('sarlavha markazda, hamburger callback', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            appBar: AppBarPrimary(title: 'OneBook ELD', onLeadingPressed: () => taps++),
          ),
        ),
      );
      expect(find.text('OneBook ELD'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.menu));
      expect(taps, 1);
    });
  });

  group('SignaturePad', () {
    testWidgets('bo\'sh holatda Save/Clear o\'chirilgan, chizgandan keyin yoqiladi', (
      WidgetTester tester,
    ) async {
      await pumpUi(
        tester,
        SizedBox(
          width: 393,
          child: SignaturePad(
            clearLabel: 'Clear',
            saveLabel: 'Save',
            hint: 'Sign here',
            onSaved: (_) {},
          ),
        ),
      );
      expect(find.text('Sign here'), findsOneWidget);
      Text save = tester.widget(find.text('Save'));
      expect(save.style!.color, AppColors.light.textDisabled);

      await tester.drag(find.byType(GestureDetector).first, const Offset(40, 20));
      await tester.pump();
      save = tester.widget(find.text('Save'));
      expect(save.style!.color, AppColors.light.onNeutralStrong);
      expect(find.text('Sign here'), findsNothing);
    });
  });

  group('Adaptivlik (M7)', () {
    testWidgets('AdaptiveView profil bo\'yicha tanlaydi', (WidgetTester tester) async {
      Widget view() => AdaptiveView(
        phone: (BuildContext _) => const Text('phone'),
        tablet: (BuildContext _) => const Text('tablet'),
      );

      await pumpUi(tester, view());
      expect(find.text('phone'), findsOneWidget);

      await pumpUi(tester, view(), size: kTabletSize);
      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('screenPaddingH: telefon 24, planshet 24', (WidgetTester tester) async {
      await pumpUi(tester, const SizedBox.shrink());
      expect(screenPaddingH(contextOf(tester)), 24);

      await pumpUi(tester, const SizedBox.shrink(), size: kTabletSize);
      expect(screenPaddingH(contextOf(tester)), 24);
    });

    // #B-64: planshetda tana cheklovsiz cho'zilmaydi, telefonda tegilmaydi.
    testWidgets('ContentMaxWidth planshetda cheklaydi, telefonda yo\'q', (
      WidgetTester tester,
    ) async {
      Widget view() => const ContentMaxWidth(maxWidth: ContentWidth.single, child: Text('body'));

      Finder cap() =>
          find.descendant(of: find.byType(ContentMaxWidth), matching: find.byType(ConstrainedBox));

      await pumpUi(tester, view());
      expect(cap(), findsNothing);

      await pumpUi(tester, view(), size: kTabletSize);
      final ConstrainedBox box = tester.widget(cap().first);
      expect(box.constraints.maxWidth, ContentWidth.single);
    });

    testWidgets('ContentMaxWidth unbounded — shaffof', (WidgetTester tester) async {
      await pumpUi(
        tester,
        const ContentMaxWidth(maxWidth: ContentWidth.unbounded, child: Text('body')),
        size: kTabletSize,
      );
      expect(
        find.descendant(of: find.byType(ContentMaxWidth), matching: find.byType(ConstrainedBox)),
        findsNothing,
      );
    });
  });
}
