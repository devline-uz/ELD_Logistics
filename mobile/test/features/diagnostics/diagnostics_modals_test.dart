@Timeout(Duration(seconds: 60))
/// `T-21 Check Network` · `T-23 Diagnosis of Device` — planshet modallari
/// (tz-mobile 1555, 1557).
///
/// **A3:** modallar `M-46`/`M-47` ekranlari bilan bir xil `CheckNetworkBody` /
/// `DiagnosisBody` va bir xil provayderlardan foydalanadi.
library;

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/eld/eld_connection_manager.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/mock_eld_transport.dart';
import 'package:eld_mobile/core/location/location_providers.dart';
import 'package:eld_mobile/core/location/mock_location_service.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/diagnostics/data/network_probe.dart';
import 'package:eld_mobile/features/diagnostics/domain/diagnostics_models.dart';
import 'package:eld_mobile/features/diagnostics/presentation/screens/check_network_screen.dart';
import 'package:eld_mobile/features/diagnostics/presentation/screens/diagnosis_screen.dart';
import 'package:eld_mobile/features/diagnostics/presentation/widgets/diagnostics_modals.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';
import '../shared/modal_host.dart';

/// Testda `Dio` ga chiqmaydigan o'lchov (aks holda real tarmoq so'rovi).
class _FakeProbe implements NetworkProbe {
  @override
  Future<NetworkMeasurement> measure() async =>
      const NetworkMeasurement(mbps: 14, roundTrip: Duration(milliseconds: 180));
}

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late TimeSource time;
  late MockEldTransport transport;
  late MockLocationService location;

  setUp(() {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time..syncFromServer(t0);
    transport = MockEldTransport(time: time, scanDelay: Duration.zero, connectDelay: Duration.zero);
    location = MockLocationService(now: () => t0);
  });

  tearDown(() async {
    await transport.dispose();
    await location.dispose();
    await db.close();
    await time.dispose();
  });

  Future<void> pump(
    WidgetTester tester,
    Future<void> Function(BuildContext) open, {
    required Size surface,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = surface;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(db),
          timeSourceProvider.overrideWithValue(time),
          eldTransportProvider.overrideWithValue(transport),
          eldDeviceStoreProvider.overrideWithValue(InMemoryEldDeviceStore()),
          locationServiceProvider.overrideWithValue(location),
          networkProbeProvider.overrideWithValue(_FakeProbe()),
        ],
        child: MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<Object?>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ModalHost(open: open),
        ),
      ),
    );
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await openModal(tester);
  }

  /// Drift oqimlari yopilishi uchun daraxtni bo'shatamiz (kutilayotgan taymer).
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  group('T-23 Diagnosis', () {
    testWidgets('planshetda TabletModal (M122)', (WidgetTester tester) async {
      await pump(tester, showDiagnosisModal, surface: kTabletSurface);

      expect(find.byType(TabletModal), findsOneWidget);
      expect(tester.widget<TabletModal>(find.byType(TabletModal)).cancelLabel, isNotNull);
      expect(find.byType(DiagnosisBody), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('telefonda AppBottomSheet — bir xil tana', (WidgetTester tester) async {
      await pump(tester, showDiagnosisModal, surface: kPhoneSurface);

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.byType(TabletModal), findsNothing);
      expect(find.byType(DiagnosisBody), findsOneWidget);

      await unmount(tester);
    });
  });

  group('T-21 Check Network', () {
    testWidgets('planshetda TabletModal (M122)', (WidgetTester tester) async {
      await pump(tester, showCheckNetworkModal, surface: kTabletSurface);

      expect(find.byType(TabletModal), findsOneWidget);
      expect(find.byType(CheckNetworkBody), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('telefonda AppBottomSheet', (WidgetTester tester) async {
      await pump(tester, showCheckNetworkModal, surface: kPhoneSurface);

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.byType(CheckNetworkBody), findsOneWidget);

      await unmount(tester);
    });
  });
}
