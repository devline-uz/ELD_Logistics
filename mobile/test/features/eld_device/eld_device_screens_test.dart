@Timeout(Duration(seconds: 60))
/// `M-17 ELD not connected`, `M-18 Permissions`, `M-19 ELD connect/scan`
/// widget testlari (tz-mobile §10.2, §10.3, M69, M70, M72, M77).
library;

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/eld/eld_codes.dart';
import 'package:eld_mobile/core/eld/eld_connection_manager.dart';
import 'package:eld_mobile/core/eld/eld_models.dart';
import 'package:eld_mobile/core/eld/eld_permissions.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/eld_session.dart';
import 'package:eld_mobile/core/eld/mock_eld_permissions.dart';
import 'package:eld_mobile/core/eld/mock_eld_transport.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/eld_device/presentation/screens/eld_connect_screen.dart';
import 'package:eld_mobile/features/eld_device/presentation/screens/permissions_screen.dart';
import 'package:eld_mobile/features/eld_device/presentation/widgets/eld_not_connected_dialog.dart';
import 'package:eld_mobile/features/eld_device/presentation/widgets/eld_status_banner.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late TimeSource time;
  late MockEldTransport transport;
  late MockEldPermissionService permissions;

  setUp(() {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time..syncFromServer(t0);
    transport = MockEldTransport(time: time, scanDelay: Duration.zero, connectDelay: Duration.zero);
    permissions = MockEldPermissionService();
  });

  tearDown(() async {
    await transport.dispose();
    await permissions.dispose();
    await db.close();
    await time.dispose();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    List<Override> extraOverrides = const <Override>[],
  }) async {
    // Telefon profili (393 dp), lekin baland: `ListView` lazy quradi va
    // 600 dp standart sirtda pastdagi tugmalar umuman yaratilmaydi.
    tester.view.physicalSize = const Size(393, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          timeSourceProvider.overrideWithValue(time),
          eldTransportProvider.overrideWithValue(transport),
          eldPermissionServiceProvider.overrideWithValue(permissions),
          eldDeviceStoreProvider.overrideWithValue(InMemoryEldDeviceStore()),
          ...extraOverrides,
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
    // `pumpAndSettle` yo'q: skan spinneri cheksiz animatsiya beradi.
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  /// Barcha ruxsatlar berilgan mock (M-19 testlari M-17 dialogiga tushmasligi
  /// uchun — M70 tekshiruvi ulanishdan oldin ishlaydi).
  void grantAll() {
    permissions = MockEldPermissionService(
      initial: <EldPermission, EldPermissionStatus>{
        for (final EldPermission p in EldPermission.values) p: EldPermissionStatus.granted,
      },
    );
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  group('M-18 Permissions', () {
    testWidgets('to\'rt qator + ikki tizim toggle ko\'rsatiladi', (WidgetTester tester) async {
      await pump(tester, const PermissionsScreen());

      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Location always'), findsOneWidget);
      expect(find.text('Bluetooth'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Turn on GPS'), findsOneWidget);
      expect(find.text('Turn on bluetooth'), findsOneWidget);

      await unmount(tester);
    });

    // #B-62: Figma `1107:2310` da har qatorda leading ikonka bor.
    testWidgets('har qatorda leading ikonka bor', (WidgetTester tester) async {
      await pump(tester, const PermissionsScreen());

      for (final IconData icon in <IconData>[
        Icons.location_on_outlined,
        Icons.my_location_outlined,
        Icons.bluetooth,
        Icons.notifications_none,
        Icons.gps_fixed,
      ]) {
        expect(find.byIcon(icon), findsWidgets, reason: 'ikonka yo\'q: $icon');
      }

      await unmount(tester);
    });

    testWidgets('rad etilgan holatda Not allowed badge va M69 tushuntirishi', (
      WidgetTester tester,
    ) async {
      await pump(tester, const PermissionsScreen());

      expect(find.text('Not allowed'), findsNWidgets(EldPermission.screenRows.length));
      expect(find.text('Allow all permissions'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('§10.2 ketma-ketligi aynan shu tartibda so\'raladi', (WidgetTester tester) async {
      await pump(tester, const PermissionsScreen());

      await tester.ensureVisible(find.text('Allow all permissions'));
      await tester.pump();
      await tester.tap(find.text('Allow all permissions'));
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(permissions.requestLog, EldPermission.requestOrder);
      await unmount(tester);
    });

    testWidgets('hammasi berilgan bo\'lsa Allow all tugmasi yo\'q', (WidgetTester tester) async {
      permissions = MockEldPermissionService(
        initial: <EldPermission, EldPermissionStatus>{
          for (final EldPermission p in EldPermission.values) p: EldPermissionStatus.granted,
        },
      );
      await pump(tester, const PermissionsScreen());

      expect(find.text('Allowed'), findsNWidgets(EldPermission.screenRows.length));
      expect(find.text('Allow all permissions'), findsNothing);

      await unmount(tester);
    });

    // Riverpod 3 xatodan keyin avtomatik retry qiladi va holat
    // `AsyncLoading(retrying: true)` bo'ladi — `AsyncValue.when` uni loading
    // deb ko'rsatib `ErrorState` ni butunlay yashiradi. Ekran `asyncView`
    // ishlatishi shart.
    testWidgets('xato holatida skelet emas, ErrorState chiqadi', (WidgetTester tester) async {
      await pump(
        tester,
        const PermissionsScreen(),
        extraOverrides: <Override>[
          // `Exception` (masalan `ApiError`) da Riverpod 3 avtomatik retry
          // qo'yadi → holat `AsyncLoading(retrying: true)`. `Error` turlarida
          // retry yo'q, shuning uchun `StateError` bu tuzoqni ko'rsatmaydi.
          eldPermissionSnapshotProvider.overrideWith((Ref ref) => throw Exception('boom')),
        ],
      );

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.byType(SkeletonBox), findsNothing);

      await unmount(tester);
    });

    testWidgets('M69: «don\'t ask again» → tizim sozlamalari', (WidgetTester tester) async {
      permissions = MockEldPermissionService(
        initial: <EldPermission, EldPermissionStatus>{
          EldPermission.bluetooth: EldPermissionStatus.permanentlyDenied,
        },
      );
      await pump(tester, const PermissionsScreen());

      await tester.ensureVisible(find.text('Bluetooth'));
      await tester.pump();
      await tester.tap(find.text('Bluetooth'));
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(permissions.openSettingsCalls, 1);
      await unmount(tester);
    });
  });

  group('M-17 ELD not connected', () {
    testWidgets('M70 kanonik matni va ikki tugma', (WidgetTester tester) async {
      await pump(tester, const EldNotConnectedDialog());

      expect(
        find.text('In order to connect to the ELD, you must allow all the permissions.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Allow Permissions'), findsOneWidget);

      await unmount(tester);
    });
  });

  group('M-19 ELD device', () {
    testWidgets('boshlang\'ich holat — bo\'sh ro\'yxat va Scan tugmasi', (
      WidgetTester tester,
    ) async {
      grantAll();
      await pump(tester, const EldConnectScreen());

      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('No ELD devices found'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('skan natijasi va zaif signal yorlig\'i', (WidgetTester tester) async {
      grantAll();
      await pump(tester, const EldConnectScreen());

      await tester.tap(find.text('Scan'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(find.text('ONEBOOK-ELD-1021'), findsOneWidget);
      expect(find.text('ONEBOOK-ELD-2044'), findsOneWidget);
      // Ikkinchi mock qurilma −93 dBm → `< −90` ogohlantirishi.
      expect(find.text('Weak signal'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('ulanishdan keyin handshake maydonlari ko\'rinadi', (WidgetTester tester) async {
      grantAll();
      await pump(tester, const EldConnectScreen());

      await tester.tap(find.text('Scan'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      await tester.tap(find.text('ONEBOOK-ELD-1021'));
      for (int i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(find.text('Connected device'), findsOneWidget);
      expect(find.text('Firmware'), findsOneWidget);
      expect(find.text('VIN'), findsOneWidget);
      expect(find.text('Device clock'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);

      await unmount(tester);
    });
  });

  group('ELD banner (M68, M77)', () {
    Widget host(EldSessionState session) => MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<Object?>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: EldStatusBannerView(session: session, onAction: () {}),
      ),
    );

    testWidgets('M68 kanonik matn `ELD · Not connected`', (WidgetTester tester) async {
      await tester.pumpWidget(host(const EldSessionState()));
      await tester.pump();
      expect(find.text('ELD · Not connected'), findsOneWidget);
    });

    testWidgets('M77: malfunction matni kod bilan, dismiss yo\'q', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          EldSessionState(
            connection: EldConnectionState.connected,
            faults: <EldFaultCode, EldFault>{
              EldFaultCode.power: EldFault(
                code: EldFaultCode.power,
                kind: EldFaultKind.malfunction,
                detectedAt: t0,
              ),
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ELD malfunction (P) — keep paper logs'), findsOneWidget);
      // Dismiss va `Reconnect` amali malfunction bannerida bo'lmaydi.
      expect(find.text('Reconnect'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('Connected holatida banner chizilmaydi', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const EldSessionState(connection: EldConnectionState.connected)),
      );
      await tester.pump();
      expect(find.text('ELD · Connected'), findsNothing);
    });

    testWidgets('diagnostic — sariq banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          EldSessionState(
            connection: EldConnectionState.connected,
            faults: <EldFaultCode, EldFault>{
              EldFaultCode.timing: EldFault(
                code: EldFaultCode.timing,
                kind: EldFaultKind.diagnostic,
                detectedAt: t0,
              ),
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text('ELD diagnostic event'), findsOneWidget);
    });
  });
}
