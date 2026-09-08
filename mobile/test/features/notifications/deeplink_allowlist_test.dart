@Timeout(Duration(seconds: 60))
/// **S-M3 / M162** — deep link oq ro'yxati.
///
/// Ilgari faqat sxema tekshirilardi: `onebookeld://` ni istalgan ilova yoki
/// veb-sahifa yuborishi mumkin, ya'ni push payload orqali ixtiyoriy marshrutga
/// (va `../` bilan router chetiga) o'tish mumkin edi.
library;

import 'package:eld_mobile/features/notifications/domain/app_notification.dart';
import 'package:eld_mobile/features/notifications/domain/notification_deeplink.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ruxsat etilgan marshrutlar', () {
    test('registrdagi ekranlar ochiladi', () {
      for (final String route in <String>[
        '/logs',
        '/logs?date=2026-09-07',
        '/certify',
        '/eld',
        '/chat',
        '/notifications',
        '/logs/pending-edits',
        '/logs/pending-edits/7',
        '/duty/change',
        '/sync/conflicts',
      ]) {
        expect(isAllowedNotificationRoute(route), isTrue, reason: route);
      }
    });

    test('onebookeld:// linklari marshrutga aylanadi', () {
      expect(
        parseNotificationDeepLink(Uri.parse('onebookeld://logs?date=2026-09-07')),
        '/logs?date=2026-09-07',
      );
      expect(
        parseNotificationDeepLink(Uri.parse('onebookeld://logs/pending-edits/7')),
        '/logs/pending-edits/7',
      );
    });

    test('M162: faqat eld.stackyard.uz hostidagi https link ochiladi', () {
      expect(parseNotificationDeepLink(Uri.parse('https://eld.stackyard.uz/chat')), '/chat');
      expect(parseNotificationDeepLink(Uri.parse('https://evil.example.com/chat')), isNull);
      expect(
        parseNotificationDeepLink(Uri.parse('https://eld.stackyard.uz.evil.com/chat')),
        isNull,
      );
    });
  });

  group('bloklanadigan linklar', () {
    test('ro\'yxatda yo\'q marshrut ochilmaydi', () {
      expect(parseNotificationDeepLink(Uri.parse('onebookeld://settings/dev')), isNull);
      expect(parseNotificationDeepLink(Uri.parse('onebookeld://admin')), isNull);
      expect(isAllowedNotificationRoute('/profile'), isFalse);
    });

    test('yo\'l manipulyatsiyasi rad etiladi', () {
      expect(isAllowedNotificationRoute('/logs/../admin'), isFalse);
      expect(isAllowedNotificationRoute('//evil.example.com'), isFalse);
      expect(isAllowedNotificationRoute('logs'), isFalse);
      expect(isAllowedNotificationRoute(null), isFalse);
      expect(
        parseNotificationDeepLink(Uri.parse('onebookeld://logs/pending-edits/../../admin')),
        isNull,
      );
    });

    test('notanish query kaliti va xavfli qiymat rad etiladi', () {
      expect(isAllowedNotificationRoute('/logs?redirect=https://evil.example.com'), isFalse);
      expect(isAllowedNotificationRoute('/chat?token=abc'), isFalse);
      expect(isAllowedNotificationRoute('/logs?date=2026-09-07'), isTrue);
    });

    test('boshqa sxemalar rad etiladi', () {
      expect(parseNotificationDeepLink(Uri.parse('http://eld.stackyard.uz/chat')), isNull);
      expect(parseNotificationDeepLink(Uri.parse('javascript:alert(1)')), isNull);
      expect(parseNotificationDeepLink(Uri.parse('onebookeld://')), isNull);
      expect(parseNotificationDeepLink(null), isNull);
    });
  });

  group('server payload sanitizatsiyasi', () {
    test('buzuq entity_id marshrutga tushmaydi', () {
      expect(notificationDeepLink(AlertType.logEditRequest, entityId: '../../admin'), isNull);
      expect(
        notificationDeepLink(AlertType.logEditRequest, entityId: 'edit-42'),
        '/logs/pending-edits/edit-42',
      );
    });

    test('buzuq log_date marshrutga tushmaydi', () {
      expect(notificationDeepLink(AlertType.hosViolation, logDate: 'x&redirect=y'), isNull);
      expect(
        notificationDeepLink(AlertType.hosViolation, logDate: '2026-09-07'),
        '/logs?date=2026-09-07',
      );
    });

    test('push payload ishonchsiz deep_link ni ochmaydi', () {
      expect(
        deepLinkFromPayload(<String, String>{'deep_link': 'onebookeld://settings/dev'}),
        isNull,
      );
      expect(deepLinkFromPayload(<String, String>{'deep_link': 'onebookeld://chat'}), '/chat');
    });
  });
}
