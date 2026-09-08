/// `M-43` testlari uchun umumiy soxta repozitoriy (widget + golden).
library;

import 'dart:async';

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/features/notifications/domain/app_notification.dart';
import 'package:eld_mobile/features/notifications/domain/device_registration.dart';
import 'package:eld_mobile/features/notifications/domain/notification_repository.dart';

/// Test uchun bitta bildirishnoma.
AppNotification testNotification(
  String id,
  DateTime createdAt, {
  bool read = false,
  AlertType type = AlertType.hosWarning,
}) => AppNotification(
  id: id,
  title: 'T$id',
  body: 'B$id',
  createdAt: createdAt,
  read: read,
  type: type,
);

class FakeNotificationRepository implements NotificationRepository {
  final StreamController<List<AppNotification>> _items =
      StreamController<List<AppNotification>>.broadcast();

  List<AppNotification> _latest = const <AppNotification>[];
  final List<String> readIds = <String>[];
  int allReadCalls = 0;

  /// `load()` ni ushlab turadi (yuklanish holatini ko'rsatish uchun).
  bool hold = false;
  bool failLoad = false;

  final Completer<void> _gate = Completer<void>();

  void emit(List<AppNotification> items) {
    _latest = items;
    if (_items.hasListener) {
      _items.add(items);
    }
  }

  void release() {
    if (!_gate.isCompleted) {
      _gate.complete();
    }
  }

  Future<void> dispose() async {
    release();
    await _items.close();
  }

  @override
  Stream<List<AppNotification>> watch() async* {
    yield _latest;
    yield* _items.stream;
  }

  @override
  Stream<int> watchUnreadCount() =>
      watch().map((List<AppNotification> l) => l.where((AppNotification n) => !n.read).length);

  @override
  Future<NotificationPage> load({int page = 1, int perPage = 25}) async {
    if (hold) {
      await _gate.future;
    }
    if (failLoad) {
      throw const ApiError(code: ApiErrorCode.clientNetwork, message: 'offline');
    }
    return NotificationPage(items: _latest, page: page, total: _latest.length, unread: 0);
  }

  @override
  Future<void> markRead(String id) async => readIds.add(id);

  @override
  Future<void> markAllRead() async => allReadCalls++;

  @override
  Future<void> registerDevice(DeviceRegistration registration) async {}

  @override
  Future<void> ingest(AppNotification notification) async {}
}
