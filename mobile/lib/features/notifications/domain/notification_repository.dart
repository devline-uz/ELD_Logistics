/// `M-43` porti — `presentation` faqat shu interfeysga bog'lanadi.
library;

import 'app_notification.dart';
import 'device_registration.dart';

/// Bir sahifa (`GET /notifications?page&per_page`).
class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.page,
    required this.total,
    required this.unread,
  });

  static const NotificationPage empty = NotificationPage(
    items: <AppNotification>[],
    page: 1,
    total: 0,
    unread: 0,
  );

  final List<AppNotification> items;
  final int page;
  final int total;

  /// `meta.unread` — app bar badge'i.
  final int unread;
}

abstract class NotificationRepository {
  /// Lokal keshdagi bildirishnomalar (yangidan eskiga). Oflayn ham to'la.
  Stream<List<AppNotification>> watch();

  /// O'qilmaganlar soni (app bar qo'ng'irog'i, M89).
  Stream<int> watchUnreadCount();

  /// `GET /notifications` — natija keshga yoziladi.
  Future<NotificationPage> load({int page = 1, int perPage = 25});

  /// `PATCH /notifications/{id}/read` (optimistik: avval lokal).
  Future<void> markRead(String id);

  /// `POST /notifications/read-all`.
  Future<void> markAllRead();

  /// §15.1: `POST /devices/push-token`. Oflayn bo'lsa outbox
  /// (`kind=push_token`) ga tushadi va sync push'da yuboriladi.
  Future<void> registerDevice(DeviceRegistration registration);

  /// Serverdan kelgan push xabarini lokal keshga yozadi (M145 — ro'yxat
  /// darhol yangilanadi, `GET /notifications` ni kutmasdan).
  Future<void> ingest(AppNotification notification);
}
