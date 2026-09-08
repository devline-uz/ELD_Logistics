@Timeout(Duration(seconds: 60))
/// `M-43` domen testlari: M143 (qulflangan kanallar), M144 (kanal jadvali),
/// M145 (deep link mapping), M146 (lokal ogohlantirishlar) va M91 (vaqt yorlig'i).
library;

import 'package:eld_mobile/features/notifications/domain/app_notification.dart';
import 'package:eld_mobile/features/notifications/domain/device_registration.dart';
import 'package:eld_mobile/features/notifications/domain/local_alert.dart';
import 'package:eld_mobile/features/notifications/domain/notification_channels.dart';
import 'package:eld_mobile/features/notifications/domain/notification_deeplink.dart';
import 'package:eld_mobile/features/notifications/domain/push_gateway.dart';
import 'package:eld_mobile/features/notifications/domain/push_message_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('M144 kanallar', () {
    test('jadval to\'liq: compliance/logs/messages/general/foreground_service', () {
      expect(kNotificationChannels.map((NotificationChannelSpec s) => s.id).toList(), <String>[
        'compliance',
        'logs',
        'messages',
        'general',
        kForegroundServiceChannelId,
      ]);
    });

    test('alert turi to\'g\'ri kanalga tushadi', () {
      expect(pushChannelOf(AlertType.hosWarning), PushChannel.compliance);
      expect(pushChannelOf(AlertType.eldMalfunction), PushChannel.compliance);
      expect(pushChannelOf(AlertType.uncertifiedLog), PushChannel.logs);
      expect(pushChannelOf(AlertType.chatMessage), PushChannel.messages);
      expect(pushChannelOf(AlertType.routeAssigned), PushChannel.general);
      expect(pushChannelOf(null), PushChannel.general);
    });

    test('compliance — HIGH, ovoz va tebranish bilan', () {
      final NotificationChannelSpec spec = channelSpecOf(PushChannel.compliance);
      expect(spec.importance, ChannelImportance.high);
      expect(spec.sound, isTrue);
      expect(spec.vibration, isTrue);
    });
  });

  group('M143 qulflangan kanallar', () {
    test('compliance qulflangan, qolganlari yo\'q', () {
      expect(isChannelLocked(PushChannel.compliance), isTrue);
      expect(isChannelLocked(PushChannel.logs), isFalse);
      expect(isChannelLocked(PushChannel.messages), isFalse);
      expect(isChannelLocked(PushChannel.general), isFalse);
    });

    test('hos_* va eld_* o\'chirib bo\'lmaydi', () {
      for (final AlertType type in AlertType.values.where((AlertType t) => t.isMandatory)) {
        expect(canDisableAlert(type), isFalse, reason: type.wire);
      }
      expect(canDisableAlert(AlertType.chatMessage), isTrue);
    });

    test('compliance ni o\'chirishga urinish e\'tiborsiz qoldiriladi', () {
      const NotificationPreferences prefs = NotificationPreferences();
      final NotificationPreferences next = prefs.toggled(PushChannel.compliance, enabled: false);
      expect(next.disabled, isEmpty);
      expect(next.isEnabled(PushChannel.compliance), isTrue);
    });

    test('oddiy kanal o\'chadi va saqlanadi', () {
      final NotificationPreferences next = const NotificationPreferences().toggled(
        PushChannel.general,
        enabled: false,
      );
      expect(next.isEnabled(PushChannel.general), isFalse);
      expect(NotificationPreferences.decode(next.encode()).isEnabled(PushChannel.general), isFalse);
    });

    test('bo\'sh/buzuq satr xavfsiz o\'qiladi', () {
      expect(NotificationPreferences.decode(null).disabled, isEmpty);
      expect(NotificationPreferences.decode(' , ,logs').disabled, <String>{'logs'});
    });
  });

  group('M145 deep link', () {
    test('alert turi → marshrut (§15.2 jadvali)', () {
      expect(notificationDeepLink(AlertType.hosWarning), '/logs');
      expect(
        notificationDeepLink(AlertType.hosViolation, logDate: '2026-09-07'),
        '/logs?date=2026-09-07',
      );
      expect(notificationDeepLink(AlertType.uncertifiedLog), '/certify');
      expect(notificationDeepLink(AlertType.eldDisconnected), '/eld');
      expect(notificationDeepLink(AlertType.chatMessage), '/chat');
      expect(
        notificationDeepLink(AlertType.logEditRequest, entityId: 'e1'),
        '/logs/pending-edits/e1',
      );
      expect(notificationDeepLink(AlertType.routeAssigned), '/notifications');
    });

    test('haydovchiga taalluqsiz turlar navigatsiya bermaydi', () {
      expect(notificationDeepLink(AlertType.dvirCritical), isNull);
      expect(notificationDeepLink(AlertType.unidentifiedDriving), isNull);
      expect(notificationDeepLink(null), isNull);
    });

    test('onebookeld:// sxemasi parse qilinadi', () {
      expect(
        parseNotificationDeepLink(Uri.parse('onebookeld://logs?date=2026-09-07')),
        '/logs?date=2026-09-07',
      );
      expect(
        parseNotificationDeepLink(Uri.parse('onebookeld://logs/pending-edits/7')),
        '/logs/pending-edits/7',
      );
      expect(parseNotificationDeepLink(Uri.parse('https://example.com/logs')), isNull);
      expect(parseNotificationDeepLink(Uri.parse('onebookeld://')), isNull);
      expect(parseNotificationDeepLink(null), isNull);
    });

    test('payload: deep_link ustun, aks holda alert_type', () {
      expect(deepLinkFromPayload(<String, String>{'deep_link': 'onebookeld://chat'}), '/chat');
      expect(deepLinkFromPayload(<String, String>{'alert_type': 'uncertified_log'}), '/certify');
      expect(deepLinkFromPayload(<String, String>{}), isNull);
    });
  });

  group('M146 lokal ogohlantirishlar', () {
    test('har turning kanali va marshruti bor', () {
      expect(
        const LocalAlertRequest(kind: LocalAlertKind.hosWarning, minutesLeft: 30).channel,
        PushChannel.compliance,
      );
      expect(const LocalAlertRequest(kind: LocalAlertKind.idlePrompt).deepLink, '/duty/change');
      expect(
        const LocalAlertRequest(kind: LocalAlertKind.eldMalfunction, malfunctionCode: 'P').deepLink,
        '/eld',
      );
      expect(
        const LocalAlertRequest(kind: LocalAlertKind.syncConflict).channel,
        PushChannel.general,
      );
    });

    test('id lar tur bo\'yicha barqaror va unikal (dublikat bildirishnoma yo\'q)', () {
      final Set<int> ids = <int>{
        for (final LocalAlertKind kind in LocalAlertKind.values)
          LocalAlertRequest(kind: kind).notificationId,
      };
      expect(ids.length, LocalAlertKind.values.length);
      expect(
        const LocalAlertRequest(kind: LocalAlertKind.idlePrompt).notificationId,
        const LocalAlertRequest(kind: LocalAlertKind.idlePrompt).notificationId,
      );
    });
  });

  group('M91 vaqt yorlig\'i', () {
    final DateTime now = DateTime.utc(2026, 9, 7, 12);

    test('chegara qiymatlari', () {
      expect(notificationTimeLabel(now, now).kind, NotificationTimeKind.justNow);
      expect(
        notificationTimeLabel(now.subtract(const Duration(minutes: 12)), now),
        const NotificationTimeLabel(NotificationTimeKind.minutes, value: 12),
      );
      expect(
        notificationTimeLabel(now.subtract(const Duration(hours: 2)), now),
        const NotificationTimeLabel(NotificationTimeKind.hours, value: 2),
      );
      expect(
        notificationTimeLabel(now.subtract(const Duration(hours: 25)), now).kind,
        NotificationTimeKind.absolute,
      );
    });

    test('kelajakdagi vaqt ham `Just now`', () {
      expect(
        notificationTimeLabel(now.add(const Duration(minutes: 5)), now).kind,
        NotificationTimeKind.justNow,
      );
    });
  });

  group('kun bo\'yicha guruhlash', () {
    test('ketma-ket kunlar alohida bo\'limga tushadi', () {
      List<AppNotification> items = <AppNotification>[
        _n('a', DateTime.utc(2026, 9, 7, 10)),
        _n('b', DateTime.utc(2026, 9, 7, 9)),
        _n('c', DateTime.utc(2026, 9, 6, 23)),
      ];
      final List<NotificationDaySection> sections = groupNotificationsByDay(
        items,
        dayOf: (DateTime d) => DateTime.utc(d.year, d.month, d.day),
      );
      expect(sections.length, 2);
      expect(sections.first.items.length, 2);
      expect(sections.last.items.single.id, 'c');
      items = <AppNotification>[];
      expect(groupNotificationsByDay(items, dayOf: (DateTime d) => d), isEmpty);
    });
  });

  group('push payload → AppNotification', () {
    test('notification_id bo\'lsa keshga yoziladi', () {
      final AppNotification? mapped = notificationFromPush(
        const PushMessage(
          data: <String, String>{
            'notification_id': 'n1',
            'alert_type': 'hos_warning',
            'entity_id': 'x',
            'sent_at': '2026-09-07T10:00:00Z',
          },
          title: 'HOS',
          body: '30 minutes left',
        ),
        receivedAt: DateTime.utc(2026, 9, 7, 12),
      );
      expect(mapped, isNotNull);
      expect(mapped!.id, 'n1');
      expect(mapped.read, isFalse);
      expect(mapped.type, AlertType.hosWarning);
      expect(mapped.createdAt, DateTime.utc(2026, 9, 7, 10));
    });

    test('notification_id yo\'q — ro\'yxatga yozilmaydi', () {
      expect(
        notificationFromPush(
          const PushMessage(data: <String, String>{'alert_type': 'chat_message'}),
          receivedAt: DateTime.utc(2026, 9, 7),
        ),
        isNull,
      );
    });

    test('sent_at yo\'q — qabul vaqti ishlatiladi', () {
      final DateTime received = DateTime.utc(2026, 9, 7, 12);
      expect(
        notificationFromPush(
          const PushMessage(data: <String, String>{'notification_id': 'n2'}),
          receivedAt: received,
        )!.createdAt,
        received,
      );
    });
  });

  group('§15.1 qurilma ro\'yxati', () {
    test('payload swagger `PushTokenCreate` bilan mos, company_id yo\'q (M164)', () {
      const DeviceRegistration registration = DeviceRegistration(
        token: 'tkn',
        platform: PushPlatform.android,
        deviceId: 'dev-1',
        appVersion: '1.4.2',
      );
      expect(registration.toPayload(), <String, Object?>{
        'token': 'tkn',
        'platform': 'android',
        'device_id': 'dev-1',
        'app_version': '1.4.2',
      });
      expect(registration.toPayload().containsKey('company_id'), isFalse);
    });

    test('barmoq izi tokenning har o\'zgarishini ushlaydi', () {
      const DeviceRegistration a = DeviceRegistration(
        token: 'a',
        platform: PushPlatform.ios,
        deviceId: 'd',
        appVersion: '1.0.0',
      );
      const DeviceRegistration b = DeviceRegistration(
        token: 'b',
        platform: PushPlatform.ios,
        deviceId: 'd',
        appVersion: '1.0.0',
      );
      expect(a == b, isFalse);
      expect(PushPlatform.fromWire('ios'), PushPlatform.ios);
      expect(PushPlatform.fromWire('web'), isNull);
    });
  });
}

AppNotification _n(String id, DateTime createdAt) => AppNotification(
  id: id,
  title: 'T$id',
  body: 'B$id',
  createdAt: createdAt,
  read: false,
  type: AlertType.hosWarning,
);
