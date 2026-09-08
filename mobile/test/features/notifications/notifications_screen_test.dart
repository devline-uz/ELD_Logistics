@Timeout(Duration(seconds: 60))
/// `M-43 Notifications` widget testi: yuklanish · bo'sh · xato · to'la,
/// M143 banneri, `Mark all as read` va M145 deep link navigatsiyasi.
library;

import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/notifications/data/mock_push_gateway.dart';
import 'package:eld_mobile/features/notifications/domain/app_notification.dart';
import 'package:eld_mobile/features/notifications/domain/push_gateway.dart';
import 'package:eld_mobile/features/notifications/presentation/notification_providers.dart';
import 'package:eld_mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';
import 'notifications_test_harness.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);
  late FakeNotificationRepository repository;
  late MockPushGateway gateway;
  late TimeSource time;

  setUp(() {
    repository = FakeNotificationRepository();
    gateway = MockPushGateway();
    time = buildTestTimeSource(t0).time..syncFromServer(t0);
  });

  tearDown(() async {
    await gateway.dispose();
    await repository.dispose();
    await time.dispose();
  });

  Future<void> pump(WidgetTester tester, {List<String> routes = const <String>[]}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          notificationRepositoryProvider.overrideWithValue(repository),
          pushGatewayProvider.overrideWithValue(gateway),
          timeSourceProvider.overrideWithValue(time),
        ],
        child: MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<Object?>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationsScreen(onOpenDeepLink: routes.add),
        ),
      ),
    );
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  testWidgets('yuklanish: skeleton ko\'rinadi', (WidgetTester tester) async {
    repository.hold = true;
    await pump(tester);

    expect(find.byType(LoadingSkeleton), findsOneWidget);
    repository.release();
    await unmount(tester);
  });

  testWidgets('bo\'sh holat: Figma matnlari', (WidgetTester tester) async {
    await pump(tester);

    expect(find.text('No Notifications Yet'), findsOneWidget);
    expect(find.text('Stay tuned! Important updates and alerts will appear here.'), findsOneWidget);
    expect(find.text('Mark all as read'), findsNothing);
    await unmount(tester);
  });

  testWidgets('xato holati: ErrorState + Retry', (WidgetTester tester) async {
    repository.failLoad = true;
    await pump(tester);

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('to\'la holat: kun sarlavhasi, nisbiy vaqt, o\'qilmagan belgisi', (
    WidgetTester tester,
  ) async {
    repository.emit(<AppNotification>[
      testNotification('n1', t0.subtract(const Duration(hours: 2)), type: AlertType.uncertifiedLog),
      testNotification('n2', t0.subtract(const Duration(minutes: 12)), read: true),
      testNotification('n3', t0.subtract(const Duration(days: 1, hours: 3))),
    ]);
    await pump(tester);

    expect(find.text('2h ago'), findsOneWidget);
    expect(find.text('12m ago'), findsOneWidget);
    // Guruh sarlavhalari: bugun va kecha (M91 — `EEE, MMM d`).
    expect(find.text('Mon, Sep 7'), findsOneWidget);
    expect(find.text('Sun, Sep 6'), findsOneWidget);
    expect(find.text('Mark all as read'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('`Mark all as read` repozitoriyni chaqiradi', (WidgetTester tester) async {
    repository.emit(<AppNotification>[
      testNotification('n1', t0.subtract(const Duration(hours: 1))),
    ]);
    await pump(tester);

    await tester.tap(find.text('Mark all as read'));
    await tester.pump(const Duration(milliseconds: 20));

    expect(repository.allReadCalls, 1);
    await unmount(tester);
  });

  testWidgets('M145: element bosilganda o\'qildi + deep link', (WidgetTester tester) async {
    final List<String> routes = <String>[];
    repository.emit(<AppNotification>[
      testNotification('n1', t0.subtract(const Duration(hours: 1)), type: AlertType.chatMessage),
    ]);
    await pump(tester, routes: routes);

    await tester.tap(find.text('Tn1'));
    await tester.pump(const Duration(milliseconds: 20));

    expect(repository.readIds, <String>['n1']);
    expect(routes, <String>['/chat']);
    await unmount(tester);
  });

  testWidgets('M143: OS ruxsati o\'chirilgan — banner + Enable', (WidgetTester tester) async {
    gateway.setPermission(PushPermissionStatus.denied);
    await pump(tester);

    expect(find.byType(BannerStrip), findsOneWidget);
    expect(
      find.text('Notifications are disabled. HOS and ELD alerts require notifications.'),
      findsOneWidget,
    );
    expect(find.text('Enable'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('ruxsat berilgan — banner yo\'q', (WidgetTester tester) async {
    await pump(tester);
    expect(find.byType(BannerStrip), findsNothing);
    await unmount(tester);
  });
}
