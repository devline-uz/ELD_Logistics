@Timeout(Duration(seconds: 60))
/// `M-43 Notifications` goldenlari — light/dark × phone/tablet.
///
/// Figma: `1156-7135` (light) / `2665-35068` (dark), bo'sh holat `1156-7244`.
library;

import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/notifications/domain/app_notification.dart';
import 'package:eld_mobile/features/notifications/presentation/notification_providers.dart';
import 'package:eld_mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/core/helpers/test_clock.dart';
import '../../../test/features/notifications/notifications_test_harness.dart';
import '../golden_screen_host.dart';

final DateTime _t0 = DateTime.utc(2026, 9, 7, 12);

List<Override> _overrides({List<AppNotification> items = const <AppNotification>[]}) {
  final FakeNotificationRepository repository = FakeNotificationRepository()..emit(items);
  final TimeSource time = buildTestTimeSource(_t0).time..syncFromServer(_t0);
  return <Override>[
    notificationRepositoryProvider.overrideWithValue(repository),
    timeSourceProvider.overrideWithValue(time),
  ];
}

void main() {
  screenGoldenMatrix(
    'notifications_list',
    builder: NotificationsScreen.new,
    overrides: () => _overrides(
      items: <AppNotification>[
        testNotification('n1', _t0.subtract(const Duration(hours: 2))),
        testNotification(
          'n2',
          _t0.subtract(const Duration(hours: 5)),
          read: true,
          type: AlertType.uncertifiedLog,
        ),
        testNotification(
          'n3',
          _t0.subtract(const Duration(days: 1, hours: 2)),
          type: AlertType.chatMessage,
        ),
      ],
    ),
  );

  screenGoldenMatrix(
    'notifications_empty',
    builder: NotificationsScreen.new,
    overrides: _overrides,
  );
}
