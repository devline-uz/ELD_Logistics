/// `NotificationRepository` implementatsiyasi (M-43).
///
/// Oflayn: `load()` yiqilsa lokal kesh baribir ko'rsatiladi; `markRead` avval
/// lokal yoziladi (optimistik), so'ng serverga uriniladi.
library;

import 'package:sync_core/sync_core.dart';

import '../../../core/error/api_error.dart';
import '../../../core/sync/outbox_repository.dart';
import '../domain/app_notification.dart';
import '../domain/device_registration.dart';
import '../domain/notification_repository.dart';
import 'notification_local_data_source.dart';
import 'notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required this._local, required this._remote, required this._outbox});

  final NotificationLocalDataSource _local;
  final NotificationRemoteDataSource _remote;
  final OutboxRepository _outbox;

  @override
  Stream<List<AppNotification>> watch() => _local.watch();

  @override
  Stream<int> watchUnreadCount() => _local.watchUnreadCount();

  @override
  Future<NotificationPage> load({int page = 1, int perPage = 25}) async {
    final NotificationPage result = await _remote.fetch(page: page, perPage: perPage);
    await _local.upsertAll(result.items);
    return result;
  }

  @override
  Future<void> markRead(String id) async {
    await _local.markRead(id);
    try {
      await _remote.markRead(id);
    } on ApiError {
      // Oflayn: keyingi `load()` da server holati bilan tenglashadi.
    }
  }

  @override
  Future<void> markAllRead() async {
    await _local.markAllRead();
    try {
      await _remote.markAllRead();
    } on ApiError {
      // Yuqoridagi bilan bir xil — lokal belgi saqlanib qoladi.
    }
  }

  /// §15.1: onlayn bo'lsa darhol `POST`, aks holda outbox (`push_token`).
  @override
  Future<void> registerDevice(DeviceRegistration registration) async {
    try {
      await _remote.registerPushToken(
        token: registration.token,
        platform: registration.platform.wire,
        deviceId: registration.deviceId,
        appVersion: registration.appVersion,
      );
    } on ApiError {
      await _outbox.enqueue(kind: OutboxKind.pushToken, payload: registration.toPayload());
    }
  }

  @override
  Future<void> ingest(AppNotification notification) => _local.upsert(notification);
}
