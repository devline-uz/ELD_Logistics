/// §15.1 — `POST /devices/push-token` uchun qurilma ma'lumoti.
///
/// `swagger.json` `notifications_dto.PushTokenCreate`: `token`, `platform`,
/// `device_id`, `app_version` (`company_id` **yuborilmaydi** — M164).
library;

/// `platform` enum'i (`swagger.json`): mobil ilova faqat `android`/`ios`.
enum PushPlatform {
  android('android'),
  ios('ios');

  const PushPlatform(this.wire);

  final String wire;

  static PushPlatform? fromWire(String? wire) {
    for (final PushPlatform value in PushPlatform.values) {
      if (value.wire == wire) {
        return value;
      }
    }
    return null;
  }
}

/// Bitta o'rnatma (`device_id` bo'yicha kalitlanadi — qayta o'rnatishda
/// yangilanadi, dublikat yaratilmaydi).
class DeviceRegistration {
  const DeviceRegistration({
    required this.token,
    required this.platform,
    required this.deviceId,
    required this.appVersion,
  });

  final String token;
  final PushPlatform platform;
  final String deviceId;

  /// `1.4.2` (semver, `maxLength=32`).
  final String appVersion;

  Map<String, Object?> toPayload() => <String, Object?>{
    'token': token,
    'platform': platform.wire,
    'device_id': deviceId,
    'app_version': appVersion,
  };

  /// Serverga takroriy yuborishning oldini olish uchun barmoq izi
  /// (`SettingsDao` da saqlanadi).
  String get fingerprint => '${platform.wire}|$deviceId|$appVersion|$token';

  @override
  bool operator ==(Object other) => other is DeviceRegistration && other.fingerprint == fingerprint;

  @override
  int get hashCode => fingerprint.hashCode;
}

/// Qurilma identifikatori manbai (port) — `SecureVault` va `PackageInfo`
/// ustidagi yupqa qatlam, testda mock qilinadi.
abstract class DeviceIdentity {
  /// `SecureVault.deviceId()` — o'chirilmaydi, logout'dan keyin ham saqlanadi.
  Future<String> deviceId();

  Future<String> appVersion();

  /// Joriy platforma; noma'lum (test/desktop) bo'lsa `null`.
  PushPlatform? platform();
}
