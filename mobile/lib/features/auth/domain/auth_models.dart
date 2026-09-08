/// Auth modulining domen modellari (tz-mobile §4).
///
/// **M5:** bu yerdagi tiplar `data/` da xom JSON dan yig'iladi; `eld_api`
/// (generatsiya) modellari `presentation` ga hech qachon chiqmaydi.
library;

/// Haydovchi sloti bo'yicha token to'plami (§4.7).
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    this.expiresAt,
    this.refreshExpiresAt,
  });

  final String accessToken;

  /// Rotatsiya qilinadigan token — faqat `SecureVault` ga yoziladi (M152).
  final String refreshToken;

  /// Server bergan xom TTL (`expires_in`, sekundlar).
  final Duration? expiresIn;

  /// Aniq muddat — `TimeSource.now()` ustiga [expiresIn] qo'shib hisoblanadi.
  final DateTime? expiresAt;

  final DateTime? refreshExpiresAt;

  /// [now] asosida aniq muddatni to'ldiradi (repozitoriy `TimeSource` dan beradi).
  AuthTokens resolveExpiry(DateTime now) => AuthTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresIn: expiresIn,
    expiresAt: expiresAt ?? (expiresIn == null ? null : now.add(expiresIn!)),
    refreshExpiresAt: refreshExpiresAt,
  );

  /// Log uchun — token qiymatlari **hech qachon** chiqmaydi (M159).
  @override
  String toString() => 'AuthTokens(expiresAt: $expiresAt)';
}

/// `device_type` (swagger enum) — sessiya siyosati shu bo'yicha ishlaydi (§4.6).
enum DeviceKind {
  phone('phone'),
  tablet('tablet');

  const DeviceKind(this.wire);

  final String wire;
}

/// Hisob holati (`swagger.json` `Profile.status`).
enum AccountStatus {
  invited,
  active,
  inactive;

  static AccountStatus parse(String? value) => switch (value) {
    'invited' => AccountStatus.invited,
    'inactive' => AccountStatus.inactive,
    _ => AccountStatus.active,
  };
}

/// `GET /me` natijasi — UI da ko'rsatiladigan haydovchi profili.
///
/// `company_id` **ataylab yo'q** (M164): u tokendan olinadi va mijozga kerak emas.
class DriverProfile {
  const DriverProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.status,
    this.email,
    this.roleName,
    this.permissions = const <String>[],
    this.pinSet = false,
    this.totpEnabled = false,
  });

  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final AccountStatus status;

  /// UI da maskalanadi (M159) — to'liq email logga chiqmaydi.
  final String? email;

  final String? roleName;

  /// M165: UI elementlari shu ro'yxatga qarab ko'rsatiladi/yashiriladi.
  final List<String> permissions;

  final bool pinSet;
  final bool totpEnabled;

  String get fullName {
    final String name = '$firstName $lastName'.trim();
    return name.isEmpty ? username : name;
  }

  bool can(String permission) => permissions.contains(permission);

  @override
  String toString() => 'DriverProfile($id)';
}

/// `POST /auth/login` natijasi.
class LoginOutcome {
  const LoginOutcome({
    required this.tokens,
    this.profile,
    this.sessionId,
    this.replacedSession = false,
    this.requiresTotpSetup = false,
    this.subscriptionReadonly = false,
  });

  final AuthTokens tokens;
  final DriverProfile? profile;
  final String? sessionId;

  /// §4.6: shu qurilma turidagi eski sessiya bekor qilindi.
  final bool replacedSession;

  /// `true` — `M-08` ga majburiy o'tiladi.
  final bool requiresTotpSetup;

  final bool subscriptionReadonly;
}

/// `GET /app/config` (public, keshlanadi).
class AppConfig {
  const AppConfig({
    this.minSupportedVersion,
    this.latestVersion,
    this.forceUpdate = false,
    this.serverTime,
    this.accessTokenTtlSeconds = 900,
    this.supportEmail,
    this.featureFlags = const <String, Object?>{},
  });

  final String? minSupportedVersion;
  final String? latestVersion;
  final bool forceUpdate;

  /// `TimeSource` ga offset sifatida yoziladi (§7).
  final DateTime? serverTime;

  final int accessTokenTtlSeconds;
  final String? supportEmail;
  final Map<String, Object?> featureFlags;
}

/// `POST /auth/pin/verify` `action` qiymati (swagger enum).
enum PinAction {
  switchDriver('switch_driver'),
  returnToTruck('return_to_truck');

  const PinAction(this.wire);

  final String wire;

  static PinAction parse(String? value) =>
      value == PinAction.switchDriver.wire ? PinAction.switchDriver : PinAction.returnToTruck;
}

/// PIN tekshiruvi natijasi.
class PinVerification {
  const PinVerification({
    required this.verified,
    required this.action,
    this.sessionResumed = false,
    this.offline = false,
  });

  final bool verified;
  final PinAction action;
  final bool sessionResumed;

  /// M16: lokal hash bilan tekshirildi, server keyin tasdiqlaydi.
  final bool offline;
}

/// `POST /auth/2fa/setup` natijasi.
class TotpSetup {
  const TotpSetup({
    required this.secret,
    this.otpauthUrl,
    this.issuer,
    this.digits = 6,
    this.period = 30,
  });

  /// Sir — logga **yozilmaydi** (M159).
  final String secret;

  final String? otpauthUrl;
  final String? issuer;
  final int digits;
  final int period;

  @override
  String toString() => 'TotpSetup(issuer: $issuer, digits: $digits)';
}

/// `POST /auth/2fa/verify` natijasi.
class TotpVerification {
  const TotpVerification({
    required this.enabled,
    this.recoveryCodes = const <String>[],
    this.tokens,
  });

  final bool enabled;
  final List<String> recoveryCodes;

  /// 2FA muvaffaqiyatli bo'lsa server to'liq token to'plamini qaytaradi.
  final AuthTokens? tokens;
}
