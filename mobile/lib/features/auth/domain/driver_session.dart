/// `M-58 Sessions (my devices)` domen modeli (tz-mobile 1524).
///
/// Manba: `GET /auth/sessions` → `auth_dto.Session`. IP serverda allaqachon
/// qisqartirilgan (`203.0.113.0`) — mijoz uni **hech qachon** logga yozmaydi.
library;

/// Sessiya turi (`device_type` enum).
enum SessionDeviceType {
  web,
  phone,
  tablet;

  static SessionDeviceType parse(String? value) => switch (value) {
    'phone' => SessionDeviceType.phone,
    'tablet' => SessionDeviceType.tablet,
    _ => SessionDeviceType.web,
  };
}

/// Server tomonidagi sessiya holati.
enum ServerSessionStatus {
  active,
  paused,
  revoked;

  static ServerSessionStatus parse(String? value) => switch (value) {
    'paused' => ServerSessionStatus.paused,
    'revoked' => ServerSessionStatus.revoked,
    _ => ServerSessionStatus.active,
  };
}

class DriverSession {
  const DriverSession({
    required this.id,
    required this.deviceType,
    required this.status,
    this.deviceId,
    this.appVersion,
    this.ip,
    this.userAgent,
    this.createdAt,
    this.lastSeenAt,
    this.expiresAt,
    this.current = false,
  });

  final String id;
  final SessionDeviceType deviceType;
  final ServerSessionStatus status;
  final String? deviceId;
  final String? appVersion;

  /// Serverda qisqartirilgan IP — to'liq manzil faqat audit izida.
  final String? ip;

  final String? userAgent;
  final DateTime? createdAt;
  final DateTime? lastSeenAt;
  final DateTime? expiresAt;

  /// Shu qurilmadagi joriy sessiya — `current` badge va `Revoke` yashiriladi.
  final bool current;

  /// Bekor qilish mumkinmi: joriy sessiya o'chirilmaydi (o'zini uzib qo'ymaslik).
  bool get revocable => !current && status != ServerSessionStatus.revoked;

  @override
  String toString() => 'DriverSession($id, ${deviceType.name}, ${status.name})';
}
