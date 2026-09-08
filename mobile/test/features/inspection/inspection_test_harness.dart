/// Inspection ekranlari uchun test qobig'i: soxta repozitoriy + PIN tekshiruvi.
library;

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/ui/components/app_button.dart';
import 'package:eld_mobile/core/ui/theme.dart';
import 'package:eld_mobile/features/inspection/domain/inspection_models.dart';
import 'package:eld_mobile/features/inspection/domain/inspection_repository.dart';
import 'package:eld_mobile/features/inspection/presentation/controllers/inspection_providers.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus;

class FakeInspectionRepository implements InspectionRepository {
  FakeInspectionRepository({this.session, this.report});

  InspectionSession? session;
  InspectionReport? report;

  ApiError? beginError;
  ApiError? logsError;
  ApiError? emailError;
  ApiError? transferError;

  InspectionTransferResult transferResult = const InspectionTransferResult(
    format: InspectionOutputFormat.csvPdfZip,
    fileKey: 'k',
    sizeBytes: 48213,
  );

  final List<String> calls = <String>[];

  @override
  Future<InspectionSession?> begin() async {
    calls.add('begin');
    if (beginError != null) {
      throw beginError!;
    }
    return session;
  }

  @override
  Future<InspectionReport> logs({DateTime? date}) async {
    calls.add('logs');
    if (logsError != null) {
      throw logsError!;
    }
    return report ?? buildTestInspectionReport();
  }

  @override
  Future<void> sendEmail(InspectionEmailRequest request) async {
    calls.add('email:${request.email}');
    if (emailError != null) {
      throw emailError!;
    }
  }

  @override
  Future<InspectionTransferResult> transfer({DateTime? date, String? comment}) async {
    calls.add('transfer');
    if (transferError != null) {
      throw transferError!;
    }
    return transferResult;
  }
}

class FakeInspectionPinVerifier implements InspectionPinVerifier {
  FakeInspectionPinVerifier({this.correctPin = '123456', this.locked = false});

  final String correctPin;
  bool locked;
  final List<String> calls = <String>[];

  @override
  Future<bool> verify(String pin) async {
    calls.add(pin);
    if (locked) {
      throw const InspectionPinLocked();
    }
    return pin == correctPin;
  }
}

/// 7 kun + bugun, oxirgi kunda ikkita event.
InspectionReport buildTestInspectionReport({
  InspectionSource source = InspectionSource.server,
  int dayCount = 8,
  bool withEvents = true,
}) {
  final DateTime to = DateTime.utc(2026, 9, 7);
  if (dayCount == 0) {
    return InspectionReport(
      from: to,
      to: to,
      days: const <InspectionDay>[],
      timezone: 'UTC',
      source: source,
    );
  }
  final List<InspectionDay> days = <InspectionDay>[
    for (int i = dayCount - 1; i >= 0; i--)
      InspectionDay(
        date: to.subtract(Duration(days: i)),
        timezone: 'UTC',
        certification: i == 0
            ? InspectionCertification.uncertified
            : InspectionCertification.certified,
        distanceMeters: 412000,
        form: const InspectionLogForm(
          driverName: 'Ali Karimov',
          carrierName: 'ONEBOOK Logistics',
          homeTerminalAddress: '1200 Industrial Rd, Dallas, TX',
          unitNumbers: <String>['1021'],
          trailerNumbers: <String>['TR-7'],
          shippingDocs: <String>['BOL-42'],
          distanceMeters: 412000,
        ),
        events: i == 0 && withEvents
            ? <InspectionEvent>[
                InspectionEvent(
                  at: DateTime.utc(2026, 9, 7, 6),
                  status: DutyStatus.on,
                  locationText: 'Dallas, TX',
                  odometerMeters: 1609344,
                ),
                InspectionEvent(
                  at: DateTime.utc(2026, 9, 7, 8),
                  status: DutyStatus.dr,
                  locationText: 'Waco, TX',
                  odometerMeters: 1700000,
                ),
              ]
            : const <InspectionEvent>[],
      ),
  ];

  return InspectionReport(
    from: days.first.date,
    to: to,
    days: days,
    driverId: 'drv-1',
    driverName: 'Ali Karimov',
    carrierName: 'ONEBOOK Logistics',
    homeTerminalAddress: '1200 Industrial Rd, Dallas, TX',
    timezone: 'UTC',
    regulationProfile: 'generic',
    source: source,
    lastSyncedAt: DateTime.utc(2026, 9, 7, 5),
  );
}

/// Modal (bottom sheet / dialog) ni haqiqiy kontekstdagidek chegaralangan
/// balandlikda ko'rsatadi — `home:` ga to'g'ridan-to'g'ri qo'yilsa `Column`
/// cheksiz balandlik oladi.
Widget sheetHost(Widget sheet) => Scaffold(
  body: Align(
    alignment: Alignment.bottomCenter,
    child: SingleChildScrollView(child: sheet),
  ),
);

Future<void> pumpInspectionScreen(
  WidgetTester tester,
  Widget screen, {
  required FakeInspectionRepository repository,
  FakeInspectionPinVerifier? pin,
  Size surface = const Size(393, 852),
  Brightness brightness = Brightness.light,
  List<Override> extraOverrides = const <Override>[],
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = surface;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        inspectionRepositoryProvider.overrideWithValue(repository),
        inspectionPinVerifierProvider.overrideWithValue(pin ?? FakeInspectionPinVerifier()),
        ...extraOverrides,
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
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// `AppButton.primary/secondary/text` yopiq subklass qaytaradi —
/// `find.byType(AppButton)` ishlamaydi, faqat `find.bySubtype`.
Finder appButtons() => find.bySubtype<AppButton>();

/// Yorlig'i [label] bo'lgan `AppButton`.
Finder appButton(String label) =>
    find.ancestor(of: find.text(label), matching: find.bySubtype<AppButton>());
