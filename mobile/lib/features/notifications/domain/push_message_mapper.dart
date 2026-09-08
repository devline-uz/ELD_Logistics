/// Push `data` payload → [AppNotification] (M145).
///
/// **Sof funksiya** — vaqt chaqiruvchidan (`TimeSource`) keladi.
library;

import 'app_notification.dart';
import 'push_gateway.dart';

/// Payload kalitlari (`tz-mobile.md` §15.2, backend `notifications` publisher).
abstract final class PushPayloadKeys {
  const PushPayloadKeys._();

  static const String id = 'notification_id';
  static const String alertType = 'alert_type';
  static const String entityType = 'entity_type';
  static const String entityId = 'entity_id';
  static const String deepLink = 'deep_link';
  static const String logDate = 'log_date';
  static const String sentAt = 'sent_at';
}

/// `null` — payload'da `notification_id` yo'q (ko'rsatiladigan, lekin
/// ro'yxatga yozilmaydigan xabar: masalan `chat_message` signali).
AppNotification? notificationFromPush(PushMessage message, {required DateTime receivedAt}) {
  final String? id = message.data[PushPayloadKeys.id];
  if (id == null || id.isEmpty) {
    return null;
  }
  final String? sentAt = message.data[PushPayloadKeys.sentAt];
  return AppNotification(
    id: id,
    title: message.title ?? '',
    body: message.body ?? '',
    createdAt: DateTime.tryParse(sentAt ?? '')?.toUtc() ?? receivedAt.toUtc(),
    read: false,
    type: AlertType.fromWire(message.data[PushPayloadKeys.alertType]),
    entityType: message.data[PushPayloadKeys.entityType],
    entityId: message.data[PushPayloadKeys.entityId],
  );
}
