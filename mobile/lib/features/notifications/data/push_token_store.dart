/// [PushTokenStore] va [DeviceIdentity] implementatsiyalari.
///
/// Token **credential** — u `settings` jadvalida saqlanmaydi; faqat
/// `sha256`-siz barmoq izi emas, balki oxirgi yuborilgan qiymatning
/// **hash**'i saqlanadi (PII/credential sizishining oldini olish, §17.5).
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/db/daos/settings_dao.dart';
import '../../../core/device/app_version.dart';
import '../../../core/security/secure_vault.dart';
import '../../../core/time/time_source.dart';
import '../domain/device_registration.dart';
import '../domain/push_token_registrar.dart';

/// `settings` kaliti (M144/§15.1).
const String kPushTokenFingerprintKey = 'push.token.fingerprint';

class SettingsPushTokenStore implements PushTokenStore {
  SettingsPushTokenStore({required this._dao, required this._time});

  final SettingsDao _dao;
  final TimeSource _time;

  @override
  Future<bool> matches(String fingerprint) async =>
      await _dao.get(kPushTokenFingerprintKey) == _hash(fingerprint);

  @override
  Future<void> save(String fingerprint) =>
      _dao.put(key: kPushTokenFingerprintKey, value: _hash(fingerprint), now: _time.now());

  @override
  Future<void> clear() => _dao.remove(kPushTokenFingerprintKey);

  /// Xom token diskka tushmaydi — faqat uning `sha256` i.
  static String _hash(String value) => sha256.convert(utf8.encode(value)).toString();
}

/// `SecureVault` + `PackageInfo` ustidagi port implementatsiyasi.
class VaultDeviceIdentity implements DeviceIdentity {
  VaultDeviceIdentity({
    required this._vault,
    required this._version,
    required this.platformResolver,
  });

  final SecureVault _vault;
  final Future<AppVersion> Function() _version;

  /// Joriy platforma (test/desktop da `null`).
  final PushPlatform? Function() platformResolver;

  String? _cachedDeviceId;
  String? _cachedVersion;

  @override
  Future<String> deviceId() async => _cachedDeviceId ??= await _vault.deviceId();

  @override
  Future<String> appVersion() async => _cachedVersion ??= (await _version()).version;

  @override
  PushPlatform? platform() => platformResolver();
}
