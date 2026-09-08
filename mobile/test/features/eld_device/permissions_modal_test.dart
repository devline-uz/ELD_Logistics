@Timeout(Duration(seconds: 60))
/// `T-22 Permissions` — planshet modali (tz-mobile 1556).
///
/// **A3:** modal `M-18` ekrani bilan bir xil `PermissionsBody` va
/// `eldPermissionServiceProvider` dan foydalanadi.
library;

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/eld/eld_connection_manager.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/mock_eld_permissions.dart';
import 'package:eld_mobile/core/eld/mock_eld_transport.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/eld_device/presentation/screens/permissions_screen.dart';
import 'package:eld_mobile/features/eld_device/presentation/widgets/permissions_modal.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';
import '../shared/modal_host.dart';

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
    await db.close();
    await time.dispose();
  });

  Future<void> pump(WidgetTester tester, {required Size surface}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = surface;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(db),
          timeSourceProvider.overrideWithValue(time),
          eldTransportProvider.overrideWithValue(transport),
          eldPermissionServiceProvider.overrideWithValue(permissions),
          eldDeviceStoreProvider.overrideWithValue(InMemoryEldDeviceStore()),
        ],
        child: const MaterialApp(
          localizationsDelegates: <LocalizationsDelegate<Object?>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ModalHost(open: showPermissionsModal),
        ),
      ),
    );
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await openModal(tester);
  }

  testWidgets('planshetda TabletModal, sarlavha qatorida Cancel (M122)', (
    WidgetTester tester,
  ) async {
    await pump(tester, surface: kTabletSurface);

    expect(find.byType(TabletModal), findsOneWidget);
    expect(find.byType(AppBottomSheet), findsNothing);
    expect(tester.widget<TabletModal>(find.byType(TabletModal)).cancelLabel, isNotNull);
    expect(find.byType(PermissionsBody), findsOneWidget);
  });

  testWidgets('telefonda AppBottomSheet — bir xil tana', (WidgetTester tester) async {
    await pump(tester, surface: kPhoneSurface);

    expect(find.byType(AppBottomSheet), findsOneWidget);
    expect(find.byType(TabletModal), findsNothing);
    expect(find.byType(PermissionsBody), findsOneWidget);
  });
}
