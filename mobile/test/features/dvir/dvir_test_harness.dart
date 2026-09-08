/// DVIR ekranlari uchun umumiy test qobig'i: soxta repozitoriylar + router.
///
/// Tarmoq, Drift va `files_queue` ga umuman tegilmaydi — hamma narsa
/// domen interfeyslari darajasida override qilinadi (M5).
library;

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/ui/components/app_button.dart';
import 'package:eld_mobile/core/ui/theme.dart';
import 'package:eld_mobile/features/dvir/domain/dvir_models.dart';
import 'package:eld_mobile/features/dvir/domain/dvir_repository.dart';
import 'package:eld_mobile/features/dvir/presentation/controllers/dvir_providers.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Katalog: `is_critical` bandi bilan (M106 tekshiruvi uchun).
const List<DefectType> kTestCatalog = <DefectType>[
  DefectType(id: 'd1', name: 'Brakes', category: DefectCategory.truck, isCritical: true),
  DefectType(id: 'd2', name: 'Lights', category: DefectCategory.truck),
  DefectType(id: 'd3', name: 'Tires', category: DefectCategory.trailer),
];

class FakeDefectCatalogRepository implements DefectCatalogRepository {
  FakeDefectCatalogRepository({this.catalog = kTestCatalog, this.error});

  List<DefectType> catalog;
  ApiError? error;

  @override
  Future<List<DefectType>> load({bool forceRefresh = false}) async {
    if (error != null) {
      throw error!;
    }
    return catalog;
  }
}

class FakeTrailerRepository implements TrailerRepository {
  FakeTrailerRepository({this.trailers = const <TrailerRef>[]});

  List<TrailerRef> trailers;

  @override
  Future<List<TrailerRef>> search(String query) async => trailers;
}

class FakeDvirRepository implements DvirRepository {
  FakeDvirRepository({this.context, this.report, this.pending = const <DvirReport>[]});

  DvirContext? context;
  DvirReport? report;
  List<DvirReport> pending;

  ApiError? contextError;
  ApiError? reportError;
  ApiError? submitError;
  ApiError? certifyError;

  bool queued = false;
  final List<String> calls = <String>[];

  @override
  Future<DvirContext> currentContext() async {
    calls.add('context');
    if (contextError != null) {
      throw contextError!;
    }
    return context ??
        DvirContext(
          unitId: 'u1',
          unitNumber: '1021',
          locationText: 'Dallas, TX',
          odometerMeters: 1609344,
          capturedAt: DateTime.utc(2026, 9, 7, 12),
        );
  }

  @override
  Future<DvirReport?> byId(String id) async {
    calls.add('byId:$id');
    if (reportError != null) {
      throw reportError!;
    }
    return report;
  }

  @override
  Future<DvirSubmitResult> submit(DvirDraft draft) async {
    calls.add('submit');
    if (submitError != null) {
      throw submitError!;
    }
    return DvirSubmitResult(queued: queued, report: report);
  }

  @override
  Future<List<DvirReport>> pendingCertification({String? unitId}) async {
    calls.add('pending');
    return pending;
  }

  @override
  Future<DvirSubmitResult> certify({required String reportId, required String signatureKey}) async {
    calls.add('certify:$reportId');
    if (certifyError != null) {
      throw certifyError!;
    }
    return DvirSubmitResult(queued: queued);
  }

  @override
  Future<String> downloadPdf(String id) async {
    calls.add('pdf:$id');
    throw const ApiError(code: 'CLIENT_NETWORK', message: 'offline');
  }
}

class FakeDvirFileRepository implements DvirFileRepository {
  final List<String> calls = <String>[];

  @override
  bool get isPhotoCaptureAvailable => true;

  @override
  Future<String?> capturePhoto({required bool fromCamera}) async => '/tmp/photo.jpg';

  @override
  Future<String> enqueuePhoto(String sourcePath) async {
    calls.add('photo');
    return '/tmp/queued.jpg';
  }

  @override
  Future<String> enqueueSignature(List<int> pngBytes) async {
    calls.add('signature');
    return '/tmp/signature.png';
  }
}

/// Namunaviy server hisoboti (`M-35` / `M-36`).
DvirReport buildTestReport({
  DvirKind? kind = DvirKind.defectsNotFixed,
  DvirStatus status = DvirStatus.submittedDefectsFound,
  bool isLocalDraft = false,
  List<DvirReportDefect> defects = const <DvirReportDefect>[
    DvirReportDefect(
      name: 'Brakes',
      category: DefectCategory.truck,
      note: 'Worn pads',
      isCritical: true,
    ),
  ],
}) => DvirReport(
  id: 'r1',
  status: status,
  kind: kind,
  type: DvirType.preTrip,
  unitId: 'u1',
  unitNumber: '1021',
  createdAt: DateTime.utc(2026, 9, 7, 12),
  locationText: 'Dallas, TX',
  odometerMeters: 1609344,
  defects: defects,
  notes: 'Checked',
  driverSignatureKey: 'sig',
  mechanicNote: 'Replaced pads',
  mechanicSignatureKey: 'msig',
  invoiceKey: 'inv-1',
  repairedAt: DateTime.utc(2026, 9, 7, 10),
  isLocalDraft: isLocalDraft,
);

/// Ekranni to'liq ilova kontekstida ko'taradi (tema, l10n, DI).
Future<void> pumpDvirScreen(
  WidgetTester tester,
  Widget screen, {
  required FakeDvirRepository repository,
  FakeDefectCatalogRepository? catalog,
  FakeTrailerRepository? trailers,
  FakeDvirFileRepository? files,
  Size surface = const Size(393, 852),
  Brightness brightness = Brightness.light,
}) async {
  // `setSurfaceSize` fizik o'lchamni beradi; dpr=3 bo'lsa mantiqiy kenglik
  // 131 dp ga tushib ketadi — shuning uchun dpr aniq 1 ga qo'yiladi.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = surface;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        dvirRepositoryProvider.overrideWithValue(repository),
        defectCatalogRepositoryProvider.overrideWithValue(catalog ?? FakeDefectCatalogRepository()),
        trailerRepositoryProvider.overrideWithValue(trailers ?? FakeTrailerRepository()),
        dvirFileRepositoryProvider.overrideWithValue(files ?? FakeDvirFileRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.of(brightness),
        localizationsDelegates: const <LocalizationsDelegate<Object?>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  // `pumpAndSettle` emas: spinner va shimmer cheksiz animatsiya beradi.
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// `AppButton.primary/secondary/text` — yopiq subklass qaytaruvchi fabrika
/// konstruktorlari, shuning uchun `find.byType(AppButton)` va
/// `find.widgetWithText(AppButton, …)` **hech qachon topmaydi**.
Finder appButtons() => find.bySubtype<AppButton>();

/// Yorlig'i [label] bo'lgan `AppButton`.
Finder appButton(String label) =>
    find.ancestor(of: find.text(label), matching: find.bySubtype<AppButton>());
