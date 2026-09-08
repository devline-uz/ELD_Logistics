@Timeout(Duration(seconds: 60))
/// M143 kanal toggle'lari va Android 13+ ruxsat tushuntirishi widget testlari.
library;

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/notifications/data/mock_push_gateway.dart';
import 'package:eld_mobile/features/notifications/domain/app_notification.dart';
import 'package:eld_mobile/features/notifications/domain/push_gateway.dart';
import 'package:eld_mobile/features/notifications/presentation/controllers/notification_preferences_controller.dart';
import 'package:eld_mobile/features/notifications/presentation/notification_providers.dart';
import 'package:eld_mobile/features/notifications/presentation/widgets/notification_channel_toggles.dart';
import 'package:eld_mobile/features/notifications/presentation/widgets/notification_permission_sheet.dart';
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
  late MockPushGateway gateway;

  setUp(() {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time..syncFromServer(t0);
    gateway = MockPushGateway();
  });

  tearDown(() async {
    await gateway.dispose();
    await db.close();
    await time.dispose();
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(db),
          timeSourceProvider.overrideWithValue(time),
          pushGatewayProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<Object?>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: child)),
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

  Switch switchFor(WidgetTester tester, PushChannel channel) {
    final int index = PushChannel.values.indexOf(channel);
    return tester.widgetList<Switch>(find.byType(Switch)).elementAt(index);
  }

  group('M143 kanal toggle\'lari', () {
    testWidgets('compliance toggle o\'chirilgan va yoqilgan holatda qotgan', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NotificationChannelToggles());

      expect(find.text('Compliance alerts'), findsOneWidget);
      expect(find.text('Required for compliance'), findsWidgets);

      final Switch compliance = switchFor(tester, PushChannel.compliance);
      expect(compliance.onChanged, isNull);
      expect(compliance.value, isTrue);
      await unmount(tester);
    });

    testWidgets('oddiy kanal o\'chiriladi va saqlanadi', (WidgetTester tester) async {
      await pump(tester, const NotificationChannelToggles());

      expect(switchFor(tester, PushChannel.general).value, isTrue);
      await tester.tap(find.byType(Switch).last);
      await tester.pump(const Duration(milliseconds: 20));

      expect(switchFor(tester, PushChannel.general).value, isFalse);
      expect(await db.settingsDao.get(kNotificationPrefsKey), PushChannel.general.id);
      await unmount(tester);
    });
  });

  group('Android 13+ ruxsat tushuntirishi', () {
    testWidgets('`Allow` bosilganda gateway dan ruxsat so\'raladi', (WidgetTester tester) async {
      gateway.setPermission(PushPermissionStatus.notDetermined);
      PushPermissionStatus? result;

      await pump(
        tester,
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? _) => TextButton(
            onPressed: () async => result = await showNotificationPermissionSheet(context, ref),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Turn on notifications'), findsOneWidget);
      expect(
        find.textContaining('HOS warnings, ELD alerts and dispatcher messages'),
        findsOneWidget,
      );

      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();

      expect(result, PushPermissionStatus.notDetermined);
      await unmount(tester);
    });

    testWidgets('ruxsat allaqachon berilgan — oyna ochilmaydi', (WidgetTester tester) async {
      PushPermissionStatus? result;

      await pump(
        tester,
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? _) => TextButton(
            onPressed: () async => result = await showNotificationPermissionSheet(context, ref),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Turn on notifications'), findsNothing);
      expect(result, PushPermissionStatus.granted);
      await unmount(tester);
    });
  });
}
