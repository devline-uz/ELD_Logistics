@Timeout(Duration(seconds: 60))
/// `M-46 Diagnosis of device` va `M-47 Check network` testlari
/// (tz-mobile §10.5, M75, M76).
library;

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/eld/eld_connection_manager.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/mock_eld_transport.dart';
import 'package:eld_mobile/core/location/location_models.dart';
import 'package:eld_mobile/core/location/location_providers.dart';
import 'package:eld_mobile/core/location/mock_location_service.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/diagnostics/data/network_probe.dart';
import 'package:eld_mobile/features/diagnostics/domain/diagnostics_models.dart';
import 'package:eld_mobile/features/diagnostics/presentation/screens/check_network_screen.dart';
import 'package:eld_mobile/features/diagnostics/presentation/screens/diagnosis_screen.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';

/// Testda `Dio` ga chiqmaydigan o'lchov.
class _FakeProbe implements NetworkProbe {
  _FakeProbe({this.result, this.error});

  final NetworkMeasurement? result;
  final Object? error;

  int calls = 0;

  @override
  Future<NetworkMeasurement> measure() async {
    calls++;
    final Object? failure = error;
    if (failure != null) {
      throw failure;
    }
    return result!;
  }
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

  Future<void> pump(WidgetTester tester, Widget child, {NetworkProbe? probe}) async {
    tester.view.physicalSize = const Size(393, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          timeSourceProvider.overrideWithValue(time),
          eldTransportProvider.overrideWithValue(transport),
          eldDeviceStoreProvider.overrideWithValue(InMemoryEldDeviceStore()),
          locationServiceProvider.overrideWithValue(location),
          if (probe != null) networkProbeProvider.overrideWithValue(probe),
        ],
        child: MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<Object?>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    );
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  group('domen', () {
    test('network quality sync kechikishidan hisoblanadi', () {
      expect(
        NetworkQuality.fromSyncLag(const Duration(seconds: 30), online: true),
        NetworkQuality.good,
      );
      expect(
        NetworkQuality.fromSyncLag(const Duration(minutes: 5), online: true),
        NetworkQuality.fair,
      );
      expect(
        NetworkQuality.fromSyncLag(const Duration(hours: 2), online: true),
        NetworkQuality.poor,
      );
      expect(NetworkQuality.fromSyncLag(null, online: true), NetworkQuality.poor);
      expect(NetworkQuality.fromSyncLag(Duration.zero, online: false), NetworkQuality.offline);
    });

    test('o\'lchagich shkalasi dizayndagi belgilarga mos', () {
      expect(kNetworkGaugeTicks, <double>[0, 1, 5, 10, 20, 30, 40, 50, 75, 100]);
      expect(gaugeFraction(0), 0);
      expect(gaugeFraction(100), 1);
      // 20 mbps — to'rtinchi belgi (indeks 4) → 4/9.
      expect(gaugeFraction(20), closeTo(4 / 9, 1e-9));
      // Chegaradan tashqarida qiymat qirqiladi.
      expect(gaugeFraction(500), 1);
      expect(gaugeFraction(-5), 0);
    });

    test('M76: o\'lchov sukut bo\'yicha taxminiy', () {
      const NetworkMeasurement m = NetworkMeasurement(
        mbps: 14,
        roundTrip: Duration(milliseconds: 180),
      );
      expect(m.approximate, isTrue);
      expect(m.fraction, closeTo(gaugeFraction(14), 1e-9));
    });
  });

  group('M-46 Diagnosis', () {
    testWidgets('uch qator ko\'rsatiladi', (WidgetTester tester) async {
      await pump(tester, const DiagnosisScreen());

      expect(find.text('ELD coordinates'), findsOneWidget);
      expect(find.text('GPS coordinates'), findsOneWidget);
      expect(find.text('Network quality'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('ELD ulanmagan va GPS fiksatsiyasi yo\'q → Not working', (
      WidgetTester tester,
    ) async {
      await pump(tester, const DiagnosisScreen());

      expect(find.text('Not working'), findsNWidgets(2));
      expect(find.text('No active malfunctions or diagnostic events.'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('GPS fiksatsiyasi bo\'lsa Working', (WidgetTester tester) async {
      await location.start(LocationProfile.driving);
      location.emit();
      await pump(tester, const DiagnosisScreen());

      expect(find.text('Working'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('M-47 Check network', () {
    testWidgets('boshlang\'ich holat — o\'lchov yo\'q', (WidgetTester tester) async {
      await pump(tester, const CheckNetworkScreen(), probe: _FakeProbe());

      expect(find.text('Tap Check Network to measure the connection.'), findsOneWidget);
      expect(find.text('mbps · approx.'), findsOneWidget);
      // #B-70 / M92: bo'sh qiymat — `N/A`, tire emas.
      expect(find.text('N/A'), findsOneWidget);
      expect(find.text('\u2014'), findsNothing);

      await unmount(tester);
    });

    testWidgets('o\'lchovdan keyin qiymat va kechikish ko\'rinadi', (WidgetTester tester) async {
      final _FakeProbe probe = _FakeProbe(
        result: const NetworkMeasurement(mbps: 14, roundTrip: Duration(milliseconds: 180)),
      );
      await pump(tester, const CheckNetworkScreen(), probe: probe);

      await tester.tap(
        find.descendant(of: find.byType(ListView), matching: find.text('Check Network')),
      );
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(probe.calls, 1);
      expect(find.text('14.00'), findsOneWidget);
      expect(find.text('Round trip 180 ms'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('xato holatida xabar chiqadi', (WidgetTester tester) async {
      await pump(
        tester,
        const CheckNetworkScreen(),
        probe: _FakeProbe(error: StateError('offline')),
      );

      await tester.tap(
        find.descendant(of: find.byType(ListView), matching: find.text('Check Network')),
      );
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(
        find.text('The measurement failed. Check your connection and try again.'),
        findsOneWidget,
      );

      await unmount(tester);
    });

    testWidgets('M75: tashqi xizmat emasligi izohda', (WidgetTester tester) async {
      await pump(tester, const CheckNetworkScreen(), probe: _FakeProbe());

      expect(
        find.text('Measured against the OneBook API — external speed test services are not used.'),
        findsOneWidget,
      );

      await unmount(tester);
    });
  });
}
