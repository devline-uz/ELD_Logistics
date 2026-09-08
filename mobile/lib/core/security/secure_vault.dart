/// Token va sirlar ombori (tz-mobile §17.1, mobile-security §1).
///
/// Qat'iy qoida:
///  * `access_token` — **faqat xotirada**, diskka hech qachon yozilmaydi;
///  * `refresh_token`, PIN hash + salt, `device_id` — `flutter_secure_storage`
///    (iOS Keychain `first_unlock_this_device`, Android EncryptedSharedPreferences).
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage kalitlari — string literal tarqatish taqiq.
abstract final class VaultKeys {
  const VaultKeys._();

  static const String refreshToken = 'auth.refresh_token';
  static const String refreshTokenCoDriver = 'auth.refresh_token.co_driver';
  static const String deviceId = 'device.id';
  static const String pinHash = 'auth.pin_hash';
  static const String pinSalt = 'auth.pin_salt';
  static const String pinLockUntil = 'auth.pin_lock_until';
  static const String pinFailedAttempts = 'auth.pin_failed_attempts';
  static const String activeUserId = 'auth.active_user_id';

  /// M9: ikki slotli sessiya holati (JSON) — status, `driver_id`, `session_id`.
  ///
  /// Nega secure storage: `driver_name` PII, `session_id` esa sessiyani bekor
  /// qilish uchun yetarli identifikator. Ikkalasi ham oddiy prefs'da yotmaydi.
  static const String sessionSlots = 'auth.session_slots';

  /// SQLCipher kaliti (64 ta hex belgi = 32 bayt). Faqat Keystore/Keychain da.
  static const String databaseKey = 'db.cipher_key';

  /// `'1'` — lokal baza fayli shifrlangan holatga o'tkazilgan.
  ///
  /// Kalitning mavjudligi yetarli emas: kalit yaratilib, migratsiya
  /// yiqilishi mumkin. Bayroq **faqat** migratsiya muvaffaqiyatli
  /// tugagandan keyin yoziladi.
  static const String databaseEncrypted = 'db.cipher_ready';
}

/// Haydovchi sloti — kabinada ikki haydovchi bo'lishi mumkin (§3.3).
/// Har slot **mustaqil** token to'plamiga va mustaqil refresh mutexiga ega.
enum DriverSlot {
  primary,
  coDriver;

  String get refreshTokenKey => switch (this) {
    DriverSlot.primary => VaultKeys.refreshToken,
    DriverSlot.coDriver => VaultKeys.refreshTokenCoDriver,
  };

  /// Ikkinchi slot — `Switch co-driver` va `Leave Truck` shu bo'yicha ishlaydi.
  DriverSlot get other => switch (this) {
    DriverSlot.primary => DriverSlot.coDriver,
    DriverSlot.coDriver => DriverSlot.primary,
  };

  /// Outbox `session_slot` ustuni va JSON kaliti uchun barqaror qiymat.
  String get wire => switch (this) {
    DriverSlot.primary => 'primary',
    DriverSlot.coDriver => 'co_driver',
  };

  static DriverSlot parse(String? value) =>
      value == DriverSlot.coDriver.wire ? DriverSlot.coDriver : DriverSlot.primary;
}

/// Sirlar bilan ishlashning yagona nuqtasi.
class SecureVault {
  SecureVault({FlutterSecureStorage? storage, Random? random})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // 11.x: Keystore + AES-GCM standart; `encryptedSharedPreferences`
            // parametri olib tashlangan.
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
          ),
      _random = random ?? Random.secure();

  final FlutterSecureStorage _storage;
  final Random _random;

  /// Access token **faqat shu yerda**, RAM'da. Ilova o'chsa yo'qoladi.
  final Map<DriverSlot, String?> _accessTokens = <DriverSlot, String?>{};

  /// Access token muddati (proaktiv refresh uchun, §4.7).
  final Map<DriverSlot, DateTime?> _accessExpiry = <DriverSlot, DateTime?>{};

  // --- Access token (xotira) -------------------------------------------------

  String? accessToken(DriverSlot slot) => _accessTokens[slot];

  DateTime? accessTokenExpiry(DriverSlot slot) => _accessExpiry[slot];

  void setAccessToken(DriverSlot slot, String? token, {DateTime? expiresAt}) {
    _accessTokens[slot] = token;
    _accessExpiry[slot] = expiresAt;
  }

  /// Muddat tugashiga [leeway] dan kam qolgan bo'lsa `true` (default 60 s).
  bool isAccessTokenExpiring(
    DriverSlot slot,
    DateTime now, {
    Duration leeway = const Duration(seconds: 60),
  }) {
    final DateTime? exp = _accessExpiry[slot];
    if (exp == null) {
      return false;
    }
    return !exp.subtract(leeway).isAfter(now);
  }

  // --- Refresh token (secure storage) ---------------------------------------

  Future<String?> readRefreshToken(DriverSlot slot) => _storage.read(key: slot.refreshTokenKey);

  /// Rotatsiya: eski token darhol yangisi bilan almashtiriladi (§4.7).
  Future<void> writeRefreshToken(DriverSlot slot, String token) =>
      _storage.write(key: slot.refreshTokenKey, value: token);

  Future<void> deleteRefreshToken(DriverSlot slot) => _storage.delete(key: slot.refreshTokenKey);

  // --- device_id -------------------------------------------------------------

  /// Barqaror qurilma identifikatori. Birinchi murojaatda `Random.secure()`
  /// bilan UUIDv4 generatsiya qilinadi va secure storage'da saqlanadi.
  Future<String> deviceId() async {
    final String? existing = await _storage.read(key: VaultKeys.deviceId);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final String generated = _uuidV4();
    await _storage.write(key: VaultKeys.deviceId, value: generated);
    return generated;
  }

  String _uuidV4() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256), growable: false);
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // versiya 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10x
    final String hex = bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  // --- SQLCipher kaliti (§17) -------------------------------------------------

  /// Lokal baza kaliti — birinchi murojaatda `Random.secure()` bilan 32 bayt
  /// generatsiya qilinadi va **faqat** secure storage'da saqlanadi.
  ///
  /// Kalit yo'qolsa baza ochilmaydi va qayta yaratilmaydi: haydovchi qayta
  /// login qiladi (flutter-drift §"Shifrlash").
  Future<String> databaseKey() async {
    final String? existing = await _storage.read(key: VaultKeys.databaseKey);
    if (existing != null && existing.length == 64) {
      return existing;
    }
    final String generated = _randomHex(32);
    await _storage.write(key: VaultKeys.databaseKey, value: generated);
    return generated;
  }

  /// Baza allaqachon shifrlangan holatga keltirilganmi.
  Future<bool> isDatabaseEncrypted() async =>
      await _storage.read(key: VaultKeys.databaseEncrypted) == '1';

  Future<void> markDatabaseEncrypted() =>
      _storage.write(key: VaultKeys.databaseEncrypted, value: '1');

  String _randomHex(int bytes) => List<int>.generate(
    bytes,
    (_) => _random.nextInt(256),
    growable: false,
  ).map((int b) => b.toRadixString(16).padLeft(2, '0')).join();

  // --- PIN (M155) ------------------------------------------------------------

  /// Yangi 32-baytli tasodifiy salt (base64). Har PIN o'rnatishda yangilanadi.
  String newPinSalt() {
    final List<int> bytes = List<int>.generate(32, (_) => _random.nextInt(256), growable: false);
    return base64Encode(bytes);
  }

  Future<void> writePin({required String hash, required String salt}) async {
    await _storage.write(key: VaultKeys.pinHash, value: hash);
    await _storage.write(key: VaultKeys.pinSalt, value: salt);
  }

  Future<({String hash, String salt})?> readPin() async {
    final String? hash = await _storage.read(key: VaultKeys.pinHash);
    final String? salt = await _storage.read(key: VaultKeys.pinSalt);
    if (hash == null || salt == null) {
      return null;
    }
    return (hash: hash, salt: salt);
  }

  Future<void> deletePin() async {
    await _storage.delete(key: VaultKeys.pinHash);
    await _storage.delete(key: VaultKeys.pinSalt);
    await _storage.delete(key: VaultKeys.pinLockUntil);
    await _storage.delete(key: VaultKeys.pinFailedAttempts);
  }

  // --- Ikki slotli sessiya holati (M9) ---------------------------------------

  /// Saqlangan sessiya holati (xom JSON). Yo'q bo'lsa `null`.
  Future<String?> readSessionSlots() => _storage.read(key: VaultKeys.sessionSlots);

  Future<void> writeSessionSlots(String json) =>
      _storage.write(key: VaultKeys.sessionSlots, value: json);

  Future<void> deleteSessionSlots() => _storage.delete(key: VaultKeys.sessionSlots);

  // --- Sessiya tozalash ------------------------------------------------------

  /// Bitta slot sessiyasini tugatadi. `device_id` **saqlanadi**, outbox
  /// tegilmaydi (M17), ikkinchi slot (co-driver) tokenlari tegilmaydi.
  ///
  /// Slotning **doimiy holati** (`auth.session_slots` dagi `driver_id`,
  /// `driver_name`, `session_id`) bu yerda o'chirilmaydi — u JSON hujjat
  /// bo'lgani uchun `SessionStore` orqali yangilanadi (`AuthRepositoryImpl`
  /// to'liq chiqishda slotni `vacant` qilib yozadi).
  Future<void> clearSession(DriverSlot slot) async {
    setAccessToken(slot, null);
    await deleteRefreshToken(slot);
    await _storage.delete(key: VaultKeys.activeUserId);
  }

  /// **S-M4** — qurilmada birorta ham haydovchi qolmaganda chaqiriladi:
  /// ikkala slot tokenlari, PIN hash + lockout, sessiya holati va faol
  /// foydalanuvchi kaliti o'chadi.
  ///
  /// **Saqlanadi:** `device_id` (barqaror bo'lishi shart) va
  /// `db.cipher_key` — kalit o'chsa mavjud shifrlangan baza o'qib
  /// bo'lmaydigan holga tushadi. Lokal jadvallarni (`chat`, `dvir`,
  /// `files_queue`) tozalash `core/db` zimmasida.
  Future<void> clearAllSecrets() async {
    for (final DriverSlot slot in DriverSlot.values) {
      setAccessToken(slot, null);
      await deleteRefreshToken(slot);
    }
    await deletePin();
    await deleteSessionSlots();
    await _storage.delete(key: VaultKeys.activeUserId);
  }
}
