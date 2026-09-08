/// §15.1 **[MUST]** — push tokenini ro'yxatga olish va yangilash.
///
/// ```
/// Login muvaffaqiyatli → token olinadi
///    → POST /devices/push-token
///    → onTokenRefresh da qayta yuboriladi
///    → logout(pause=false): server DELETE yo'q, faqat lokal `deleteToken()`
/// ```
/// Oflayn bo'lsa — outbox (`kind=push_token`), buni [NotificationRepository]
/// bajaradi (bu qatlam faqat **qachon** yuborishni biladi).
library;

import 'dart:async';

import 'device_registration.dart';
import 'notification_repository.dart';
import 'push_gateway.dart';

/// Oxirgi muvaffaqiyatli ro'yxatdan o'tish barmoq izini saqlaydigan port
/// (`SettingsDao` ustidagi yupqa qatlam) — takroriy `POST` bo'lmasligi uchun.
abstract class PushTokenStore {
  /// Oxirgi muvaffaqiyatli yuborilgan ro'yxatdan o'tish shu barmoq iziga
  /// mos keladimi (implementatsiya qiymatni **hash** ko'rinishida saqlaydi).
  Future<bool> matches(String fingerprint);

  Future<void> save(String fingerprint);

  Future<void> clear();
}

class PushTokenRegistrar {
  PushTokenRegistrar({
    required this._gateway,
    required this._repository,
    required this._identity,
    required this._store,
  });

  final PushGateway _gateway;
  final NotificationRepository _repository;
  final DeviceIdentity _identity;
  final PushTokenStore _store;

  StreamSubscription<String>? _refreshSub;

  /// Login'dan keyin: joriy tokenni yuboradi va `onTokenRefresh` ga obuna
  /// bo'ladi. Ruxsat berilmagan bo'lsa token `null` — hech nima yuborilmaydi.
  Future<void> start() async {
    _refreshSub ??= _gateway.tokenRefresh().listen((String token) {
      unawaited(_send(token, force: true));
    });
    final String? token = await _gateway.token();
    if (token != null && token.isNotEmpty) {
      await _send(token);
    }
  }

  /// Test/dev uchun: tokenni majburan qayta yuborish.
  Future<void> refreshNow() async {
    final String? token = await _gateway.token();
    if (token != null && token.isNotEmpty) {
      await _send(token, force: true);
    }
  }

  /// §15.1: `logout(pause=false)` — server tarafda `DELETE` yo'q, faqat lokal.
  Future<void> stop() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    await _gateway.deleteToken();
    await _store.clear();
  }

  Future<void> dispose() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
  }

  Future<void> _send(String token, {bool force = false}) async {
    final PushPlatform? platform = _identity.platform();
    if (platform == null) {
      // Desktop/test muhiti — `platform` enum'ida qiymat yo'q (M164 emas).
      return;
    }
    final DeviceRegistration registration = DeviceRegistration(
      token: token,
      platform: platform,
      deviceId: await _identity.deviceId(),
      appVersion: await _identity.appVersion(),
    );
    if (!force && await _store.matches(registration.fingerprint)) {
      return;
    }
    await _repository.registerDevice(registration);
    await _store.save(registration.fingerprint);
  }
}
