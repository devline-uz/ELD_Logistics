/// Push transporti porti (§15.1, M143–M146).
///
/// **Firebase/APNs sozlash bu bosqichda YO'Q** — ilova faqat shu abstraksiyaga
/// bog'lanadi. TODO(M0.x): `FirebasePushGateway` (firebase_messaging) va
/// lokal bildirishnomalar plagini keyingi bosqichda ulanadi.
library;

import 'app_notification.dart';
import 'notification_channels.dart';

/// OS darajasidagi ruxsat holati (M143 banneri shundan).
enum PushPermissionStatus {
  granted,

  /// Foydalanuvchi rad etdi yoki tizim sozlamalarida o'chirgan.
  denied,

  /// Hali so'ralmagan.
  notDetermined,
}

/// Serverdan kelgan push xabari.
class PushMessage {
  const PushMessage({required this.data, this.title, this.body, this.receivedAt});

  /// `data` payload (`alert_type`, `entity_type`, `entity_id`, `deep_link`).
  final Map<String, String> data;

  final String? title;
  final String? body;
  final DateTime? receivedAt;
}

/// M146: server ishtirokisiz, qurilmada tug'iladigan bildirishnoma
/// (HOS chegarasi, idle prompt, sync konflikti, ELD uzilishi, malfunction).
class LocalNotification {
  const LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.deepLink,
  });

  final int id;
  final String title;
  final String body;
  final AlertType type;
  final String? deepLink;

  /// M144: kanal turdan hisoblanadi.
  PushChannel get channel => pushChannelOf(type);
}

abstract class PushGateway {
  /// **M144**: kanallarni platformada yaratadi (Android `NotificationChannel`;
  /// iOS da no-op). Bootstrap'da bir marta, ruxsatdan **oldin** chaqiriladi.
  Future<void> ensureChannels(List<NotificationChannelSpec> channels);

  /// §15.1: FCM/APNs tokeni. Ruxsat yo'q bo'lsa `null`.
  Future<String?> token();

  /// Token yangilanishi (`onTokenRefresh`).
  Stream<String> tokenRefresh();

  Future<PushPermissionStatus> permissionStatus();

  Future<PushPermissionStatus> requestPermission();

  /// M143: OS sozlamalari ekranini ochadi.
  Future<void> openSystemSettings();

  /// Ilova ochiq turganda kelgan xabarlar.
  Stream<PushMessage> messages();

  /// Bildirishnoma bosilib ilova ochilgan hodisa (M145).
  Stream<PushMessage> opened();

  /// Ilova yopiq bo'lganda bosilgan bildirishnoma (bootstrap'da o'qiladi).
  Future<PushMessage?> initialMessage();

  /// M146.
  Future<void> showLocal(LocalNotification notification);

  /// Chiqishda (`logout`) lokal tokenni o'chirish (§15.1: server DELETE yo'q).
  Future<void> deleteToken();
}
