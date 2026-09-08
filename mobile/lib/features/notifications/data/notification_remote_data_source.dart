/// `swagger.json` `/notifications*` chaqiruvlari.
///
/// TODO(M1): `eld_api` generatsiyasi yoqilgach shu sinf uning wrapper'iga
/// aylanadi — imzo o'zgarmaydi.
library;

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

abstract class NotificationRemoteDataSource {
  /// `GET /notifications?page&per_page`.
  Future<NotificationPage> fetch({int page = 1, int perPage = 25});

  /// `PATCH /notifications/{id}/read`.
  Future<void> markRead(String id);

  /// `POST /notifications/read-all`.
  Future<void> markAllRead();

  /// §15.1: `POST /devices/push-token`.
  Future<void> registerPushToken({
    required String token,
    required String platform,
    required String deviceId,
    required String appVersion,
  });
}

class HttpNotificationRemoteDataSource implements NotificationRemoteDataSource {
  HttpNotificationRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<NotificationPage> fetch({int page = 1, int perPage = 25}) => guardApiCall(() async {
    final Response<Map<String, Object?>> response = await _dio.get<Map<String, Object?>>(
      '/notifications',
      queryParameters: <String, Object?>{'page': page, 'per_page': perPage},
    );
    return _pageFrom(response.data, page);
  });

  @override
  Future<void> markRead(String id) =>
      guardApiCall(() => _dio.patch<Map<String, Object?>>('/notifications/$id/read'));

  @override
  Future<void> markAllRead() =>
      guardApiCall(() => _dio.post<Map<String, Object?>>('/notifications/read-all'));

  @override
  Future<void> registerPushToken({
    required String token,
    required String platform,
    required String deviceId,
    required String appVersion,
  }) => guardApiCall(
    () => _dio.post<Map<String, Object?>>(
      '/devices/push-token',
      data: <String, Object?>{
        'token': token,
        'platform': platform,
        'device_id': deviceId,
        'app_version': appVersion,
      },
    ),
  );

  // --- mapping (`notifications_dto.*` → domen) ----------------------------

  NotificationPage _pageFrom(Map<String, Object?>? body, int fallbackPage) {
    final Object? raw = body?['data'];
    final List<AppNotification> items = <AppNotification>[
      if (raw is List<Object?>)
        for (final Object? item in raw)
          if (item is Map<String, Object?>)
            if (notificationFromJson(item) case final AppNotification n) n,
    ];
    final Object? meta = body?['meta'];
    final Map<String, Object?> m = meta is Map<String, Object?> ? meta : const <String, Object?>{};
    return NotificationPage(
      items: items,
      page: m['page'] is int ? m['page']! as int : fallbackPage,
      total: m['total'] is int ? m['total']! as int : items.length,
      unread: m['unread'] is int ? m['unread']! as int : 0,
    );
  }
}

/// `notifications_dto.Notification` → domen. Test uchun ochiq, sof funksiya.
AppNotification? notificationFromJson(Map<String, Object?> json) {
  final Object? id = json['id'];
  if (id is! String || id.isEmpty) {
    return null;
  }
  return AppNotification(
    id: id,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    createdAt:
        _dateTime(json['created_at']) ??
        _dateTime(json['sent_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    read: json['read'] == true,
    type: AlertType.fromWire(json['alert_type'] as String?),
    entityType: json['entity_type'] as String?,
    entityId: json['entity_id'] as String?,
  );
}

DateTime? _dateTime(Object? value) => value is String ? DateTime.tryParse(value)?.toUtc() : null;
