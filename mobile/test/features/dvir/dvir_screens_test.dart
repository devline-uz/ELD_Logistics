@Timeout(Duration(seconds: 60))
/// `M-32`…`M-36` widget testlari: yuklanish · bo'sh · xato · to'la holatlar.
library;

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/dvir/domain/dvir_badge.dart';
import 'package:eld_mobile/features/dvir/domain/dvir_models.dart';
import 'package:eld_mobile/features/dvir/presentation/controllers/dvir_form_controller.dart';
import 'package:eld_mobile/features/dvir/presentation/controllers/dvir_providers.dart';
import 'package:eld_mobile/features/dvir/presentation/dvir_routes.dart';
import 'package:eld_mobile/features/dvir/presentation/screens/dvir_add_screen.dart';
import 'package:eld_mobile/features/dvir/presentation/screens/dvir_defect_picker_screen.dart';
import 'package:eld_mobile/features/dvir/presentation/screens/dvir_details_screen.dart';
import 'package:eld_mobile/features/dvir/presentation/screens/dvir_review_screen.dart';
import 'package:eld_mobile/features/dvir/presentation/widgets/dvir_widgets.dart';
import 'package:eld_mobile/features/dvir/presentation/widgets/previous_defects_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dvir_test_harness.dart';

void main() {
  const ApiError offline = ApiError(code: ApiErrorCode.clientNetwork, message: 'offline');

  group('M-32 Add DVIR', () {
    testWidgets('to\'la holat: Driver Information va Unit Number ko\'rinadi', (
      WidgetTester tester,
    ) async {
      final FakeDvirRepository repo = FakeDvirRepository();
      await pumpDvirScreen(tester, const DvirAddScreen(), repository: repo);

      expect(find.text('1021'), findsWidgets);
      expect(find.text('Dallas, TX'), findsOneWidget);
      expect(repo.calls, contains('context'));
    });

    testWidgets('yuklanish holati: skeleton', (WidgetTester tester) async {
      final FakeDvirRepository repo = FakeDvirRepository();
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpDvirScreen(tester, const DvirAddScreen(), repository: repo);
      // Yuklanish tugagach skeleton yo'qoladi.
      expect(find.byType(LoadingSkeleton), findsNothing);
    });

    testWidgets('xato holati: ErrorState + Retry', (WidgetTester tester) async {
      final FakeDvirRepository repo = FakeDvirRepository()..contextError = offline;
      await pumpDvirScreen(tester, const DvirAddScreen(), repository: repo);

      expect(find.byType(ErrorState), findsOneWidget);
    });
  });

  group('M-33 Defect picker', () {
    testWidgets('katalog ko\'rinadi va qidiruv filtrlaydi', (WidgetTester tester) async {
      await pumpDvirScreen(
        tester,
        const DvirDefectPickerScreen(category: DefectCategory.truck),
        repository: FakeDvirRepository(),
      );

      expect(find.text('Brakes'), findsOneWidget);
      expect(find.text('Lights'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Bra');
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('Lights'), findsNothing);
    });

    testWidgets('bo\'sh katalog: EmptyState', (WidgetTester tester) async {
      await pumpDvirScreen(
        tester,
        const DvirDefectPickerScreen(category: DefectCategory.truck),
        repository: FakeDvirRepository(),
        catalog: FakeDefectCatalogRepository(catalog: const <DefectType>[]),
      );

      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('xato holati: ErrorState', (WidgetTester tester) async {
      await pumpDvirScreen(
        tester,
        const DvirDefectPickerScreen(category: DefectCategory.truck),
        repository: FakeDvirRepository(),
        catalog: FakeDefectCatalogRepository(error: offline),
      );

      expect(find.byType(ErrorState), findsOneWidget);
    });
  });

  group('M-34 Review + signature', () {
    testWidgets('imzosiz Confirm o\'chiq, imzo bo\'lgach yoqiladi', (WidgetTester tester) async {
      final FakeDvirRepository repo = FakeDvirRepository();
      final FakeDvirFileRepository files = FakeDvirFileRepository();
      await pumpDvirScreen(tester, const DvirReviewScreen(), repository: repo, files: files);

      expect(find.byType(SignaturePad), findsOneWidget);
      expect(find.text('A driver signature is required.'), findsOneWidget);

      // Imzosiz `Save signature` o'chiq. `AppButton` fabrika konstruktorlari
      // yopiq subklass qaytaradi — faqat `find.bySubtype` topadi.
      expect(tester.widget<AppButton>(appButton('Save signature').first).onPressed, isNull);

      // Imzo chizilgach tugma yoqiladi (PNG kodlash `runAsync` talab qiladi,
      // shuning uchun `files_queue` ga yozish provayder testida tekshiriladi).
      final Offset canvas = tester.getTopLeft(find.byType(SignaturePad)) + const Offset(60, 60);
      await tester.dragFrom(canvas, const Offset(40, 20));
      await tester.pump();

      expect(tester.widget<AppButton>(appButton('Save signature').first).onPressed, isNotNull);
      expect(files.calls, isEmpty);
    });

    testWidgets('nuqson tanlanmagan bo\'lsa xulosa bo\'sh matnini ko\'rsatadi', (
      WidgetTester tester,
    ) async {
      await pumpDvirScreen(tester, const DvirReviewScreen(), repository: FakeDvirRepository());

      expect(find.text('No defects were selected.'), findsOneWidget);
    });
  });

  group('M-35 DVIR details', () {
    testWidgets('to\'la holat: badge `kind` dan, mexanik izohi ko\'rinadi', (
      WidgetTester tester,
    ) async {
      final FakeDvirRepository repo = FakeDvirRepository(report: buildTestReport());
      await pumpDvirScreen(tester, const DvirDetailsScreen(reportId: 'r1'), repository: repo);

      expect(find.text('Replaced pads'), findsOneWidget);
      expect(find.byType(DvirBadgeView), findsOneWidget);
      expect(find.text('Submitted DVIRs cannot be edited or deleted (M107).'), findsOneWidget);
    });

    testWidgets('bo\'sh holat: hisobot topilmadi', (WidgetTester tester) async {
      await pumpDvirScreen(
        tester,
        const DvirDetailsScreen(reportId: 'r1'),
        repository: FakeDvirRepository(),
      );

      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('xato holati: ErrorState', (WidgetTester tester) async {
      final FakeDvirRepository repo = FakeDvirRepository()..reportError = offline;
      await pumpDvirScreen(tester, const DvirDetailsScreen(reportId: 'r1'), repository: repo);

      expect(find.byType(ErrorState), findsOneWidget);
    });
  });

  group('M-36 Previous defects', () {
    testWidgets('kutayotgan hisobot bo\'lsa xabar va imzo maydoni ko\'rinadi', (
      WidgetTester tester,
    ) async {
      final FakeDvirRepository repo = FakeDvirRepository(
        pending: <DvirReport>[buildTestReport(kind: DvirKind.defectsUncertified)],
      );
      await pumpDvirScreen(tester, const PreviousDefectsDialog(), repository: repo);

      expect(find.textContaining('Confirm the repairs are satisfactory.'), findsOneWidget);
      expect(find.byType(SignaturePad), findsOneWidget);
      expect(repo.calls, contains('pending'));
    });

    testWidgets('bo\'sh ro\'yxat: EmptyState', (WidgetTester tester) async {
      await pumpDvirScreen(tester, const PreviousDefectsDialog(), repository: FakeDvirRepository());

      expect(find.byType(EmptyState), findsOneWidget);
    });
  });

  group('DvirFormController (M7: telefon va planshet ulashadi)', () {
    ProviderContainer buildContainer({
      required FakeDvirRepository repo,
      required FakeDvirFileRepository files,
    }) {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          dvirRepositoryProvider.overrideWithValue(repo),
          dvirFileRepositoryProvider.overrideWithValue(files),
          defectCatalogRepositoryProvider.overrideWithValue(FakeDefectCatalogRepository()),
          trailerRepositoryProvider.overrideWithValue(FakeTrailerRepository()),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('imzo `files_queue` ga qo\'yiladi va Confirm yoqiladi', () async {
      final FakeDvirFileRepository files = FakeDvirFileRepository();
      final ProviderContainer container = buildContainer(repo: FakeDvirRepository(), files: files);
      final DvirFormController controller = container.read(dvirFormControllerProvider.notifier);
      await controller.load();
      await controller.saveSignature(const <int>[1, 2, 3]);

      expect(files.calls, contains('signature'));
      expect(container.read(dvirFormControllerProvider).canConfirm, isTrue);
    });

    test('oflayn yuborish `queued` natijasini beradi', () async {
      final FakeDvirRepository repo = FakeDvirRepository()..queued = true;
      final ProviderContainer container = buildContainer(
        repo: repo,
        files: FakeDvirFileRepository(),
      );
      final DvirFormController controller = container.read(dvirFormControllerProvider.notifier);
      await controller.load();
      await controller.saveSignature(const <int>[1]);
      await controller.submit();

      expect(repo.calls, contains('submit'));
      expect(container.read(dvirFormControllerProvider).outcome, DvirSubmitOutcome.queued);
    });

    test('M106: kritik nuqson tanlansa ogohlantirish bayrog\'i yonadi', () async {
      final ProviderContainer container = buildContainer(
        repo: FakeDvirRepository(),
        files: FakeDvirFileRepository(),
      );
      final DvirFormController controller = container.read(dvirFormControllerProvider.notifier);
      await controller.load();
      controller.applyDefects(DefectCategory.truck, <DvirDefect>[
        DvirDefect(type: kTestCatalog.first),
      ]);

      expect(container.read(dvirFormControllerProvider).showCriticalWarning, isTrue);
    });
  });

  group('marshrutlar va badge mapping', () {
    test('M-33/M-35 havolalari', () {
      expect(DvirRoute.defectsFor(DefectCategory.trailer), '/dvir/new/defects?category=trailer');
      expect(DvirRoute.detailsFor('r1'), '/dvir/r1');
      expect(DvirRoute.review, '/dvir/new/confirm');
    });

    test('M103: badge faqat `kind` dan', () {
      expect(dvirBadgeOf(kind: null, status: DvirStatus.draft).label, DvirBadgeLabel.draft);
      expect(
        dvirBadgeOf(kind: DvirKind.defectsUncertified, status: DvirStatus.repaired).suffix,
        DvirBadgeSuffix.awaitingCertification,
      );
    });
  });
}
