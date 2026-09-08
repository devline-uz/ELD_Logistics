/// Drift ↔ domen o'girish (M5: Drift qatori `presentation` ga chiqmaydi).
///
/// Oflayn: ro'yxat lokal keshdan o'qiladi, `read` belgisi optimistik yoziladi.
library;

import 'package:drift/drift.dart' show Value;

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/chat_dao.dart';
import '../domain/app_notification.dart';

class NotificationLocalDataSource {
  NotificationLocalDataSource(this._dao);

  final ChatDao _dao;

  /// Yangidan eskiga (`created_at DESC`) — dizayndagi tartib.
  Stream<List<AppNotification>> watch({int limit = 100}) =>
      _dao.watchNotifications(limit: limit).map(toDomainList);

  Stream<int> watchUnreadCount() => _dao.watchUnreadCount();

  /// Sof o'girish — test uchun ochiq.
  List<AppNotification> toDomainList(List<NotificationRow> rows) => <AppNotification>[
    for (final NotificationRow row in rows) _toDomain(row),
  ];

  AppNotification _toDomain(NotificationRow row) => AppNotification(
    id: row.id,
    title: row.title,
    body: row.body,
    createdAt: row.createdAt,
    read: row.read,
    type: AlertType.fromWire(row.alertType),
    entityType: row.entityType,
    entityId: row.entityId,
  );

  Future<void> upsert(AppNotification notification) => _dao.upsertNotification(
    NotificationsCompanion.insert(
      id: notification.id,
      // Noma'lum tur ham saqlanadi (server enum'i kengaysa yo'qotmaslik uchun).
      alertType: notification.type?.wire ?? '',
      title: notification.title,
      body: notification.body,
      createdAt: notification.createdAt,
      entityType: Value<String?>(notification.entityType),
      entityId: Value<String?>(notification.entityId),
      read: Value<bool>(notification.read),
    ),
  );

  Future<void> upsertAll(List<AppNotification> items) async {
    for (final AppNotification item in items) {
      await upsert(item);
    }
  }

  Future<void> markRead(String id) => _dao.markRead(id);

  Future<void> markAllRead() async {
    final List<AppNotification> items = await watch().first;
    for (final AppNotification item in items) {
      if (!item.read) {
        await _dao.markRead(item.id);
      }
    }
  }
}
