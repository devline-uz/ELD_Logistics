/// `data` qatlami: auth endpointlari (`contracts/swagger.json`).
///
/// **TODO(M1):** `packages/eld_api` (dart-dio generatsiya) `pubspec.yaml` da
/// hozircha izohda turibdi (`# eld_api: path: packages/eld_api`) — shu sababli
/// so'rov/javob shu yerda xom JSON sifatida yig'iladi. `eld_api` yoqilganda bu
/// fayl generatsiya qilingan `AuthApi` ustidagi yupqa wrapper'ga aylanadi;
/// domen modellari (`domain/auth_models.dart`) o'zgarmaydi, ya'ni
/// `presentation` qatlamiga ta'sir qilmaydi (M5).
///
/// Bu yerda `company_id` **hech qachon** so'rov tanasiga qo'yilmaydi (M164).
library;

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/request_options_x.dart';
import '../../../core/security/secure_vault.dart';
import '../domain/auth_models.dart';
import '../domain/driver_session.dart';

/// Endpoint yo'llari — string literal tarqatish taqiq.
abstract final class AuthPath {
  const AuthPath._();

  static const String appConfig = '/app/config';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String pinVerify = '/auth/pin/verify';
  static const String passwordForgot = '/auth/password/forgot';
  static const String passwordReset = '/auth/password/reset';
  static const String invitationAccept = '/auth/invitation/accept';
  static const String totpSetup = '/auth/2fa/setup';
  static const String totpVerify = '/auth/2fa/verify';
  static const String me = '/me';

  /// `M-58 Sessions` — `GET` ro'yxat, `DELETE /auth/sessions/{id}` bekor qilish.
  static const String sessions = '/auth/sessions';
}

class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Options _anonymous({DriverSlot slot = DriverSlot.primary}) =>
      Options(extra: <String, Object?>{RequestExtra.anonymous: true, RequestExtra.slot: slot});

  Options _authorized({DriverSlot slot = DriverSlot.primary}) =>
      Options(extra: <String, Object?>{RequestExtra.slot: slot});

  // --- Bootstrap -------------------------------------------------------------

  Future<AppConfig> appConfig() => guardApiCall(() async {
    final Response<Object?> response = await _dio.get<Object?>(
      AuthPath.appConfig,
      options: _anonymous(),
    );
    return AuthDecoder.appConfig(AuthDecoder.envelope(response.data));
  });

  // --- Login / token ---------------------------------------------------------

  Future<LoginOutcome> login({
    required String username,
    required String password,
    required DeviceKind deviceType,
    required String appVersion,
    required String deviceId,
    String? totpCode,
  }) => guardApiCall(() async {
    final Response<Object?> response = await _dio.post<Object?>(
      AuthPath.login,
      data: <String, Object?>{
        'username': username,
        'password': password,
        'device_type': deviceType.wire,
        'device_id': deviceId,
        'app_version': appVersion,
        if (totpCode != null && totpCode.isNotEmpty) 'totp_code': totpCode,
      },
      options: _anonymous(),
    );
    return AuthDecoder.loginOutcome(AuthDecoder.envelope(response.data));
  });

  /// `POST /auth/refresh` — **har doim** anonim (interceptor sikliga tushmasin).
  Future<AuthTokens> refresh({
    required String refreshToken,
    required String appVersion,
    required DriverSlot slot,
  }) => guardApiCall(() async {
    final Response<Object?> response = await _dio.post<Object?>(
      AuthPath.refresh,
      data: <String, Object?>{'refresh_token': refreshToken, 'app_version': appVersion},
      options: _anonymous(slot: slot),
    );
    return AuthDecoder.tokens(AuthDecoder.envelope(response.data))!;
  });

  /// `pause: true` — Leave Truck (M18): refresh token tirik qoladi.
  Future<void> logout({required bool pause, String? refreshToken, required DriverSlot slot}) =>
      guardApiCall(() async {
        await _dio.post<Object?>(
          AuthPath.logout,
          data: <String, Object?>{'pause': pause, 'refresh_token': ?refreshToken},
          options: _authorized(slot: slot),
        );
      });

  // --- PIN -------------------------------------------------------------------

  Future<PinVerification> verifyPin({
    required String pin,
    required PinAction action,
    required DriverSlot slot,
  }) => guardApiCall(() async {
    final Response<Object?> response = await _dio.post<Object?>(
      AuthPath.pinVerify,
      data: <String, Object?>{'pin': pin, 'action': action.wire},
      options: _authorized(slot: slot),
    );
    return AuthDecoder.pinVerification(AuthDecoder.envelope(response.data), action);
  });

  // --- Parol tiklash ---------------------------------------------------------

  Future<void> requestPasswordReset({required String login}) => guardApiCall(() async {
    await _dio.post<Object?>(
      AuthPath.passwordForgot,
      data: <String, Object?>{'login': login},
      options: _anonymous(),
    );
  });

  Future<void> resetPassword({required String token, required String password}) =>
      guardApiCall(() async {
        await _dio.post<Object?>(
          AuthPath.passwordReset,
          data: <String, Object?>{'token': token, 'password': password},
          options: _anonymous(),
        );
      });

  // --- Taklif ----------------------------------------------------------------

  Future<void> acceptInvitation({
    required String token,
    required String password,
    required String pin,
  }) => guardApiCall(() async {
    await _dio.post<Object?>(
      AuthPath.invitationAccept,
      data: <String, Object?>{'token': token, 'password': password, 'pin': pin},
      options: _anonymous(),
    );
  });

  // --- 2FA -------------------------------------------------------------------

  Future<TotpSetup> startTotpSetup({required DriverSlot slot}) => guardApiCall(() async {
    final Response<Object?> response = await _dio.post<Object?>(
      AuthPath.totpSetup,
      options: _authorized(slot: slot),
    );
    return AuthDecoder.totpSetup(AuthDecoder.envelope(response.data));
  });

  Future<TotpVerification> verifyTotp({
    String? code,
    String? recoveryCode,
    required DriverSlot slot,
  }) => guardApiCall(() async {
    final Response<Object?> response = await _dio.post<Object?>(
      AuthPath.totpVerify,
      data: <String, Object?>{
        if (code != null && code.isNotEmpty) 'code': code,
        if (recoveryCode != null && recoveryCode.isNotEmpty) 'recovery_code': recoveryCode,
      },
      options: _authorized(slot: slot),
    );
    return AuthDecoder.totpVerification(AuthDecoder.envelope(response.data));
  });

  // --- Profil ----------------------------------------------------------------

  Future<DriverProfile> me({required DriverSlot slot}) => guardApiCall(() async {
    final Response<Object?> response = await _dio.get<Object?>(
      AuthPath.me,
      options: _authorized(slot: slot),
    );
    return AuthDecoder.profile(AuthDecoder.envelope(response.data))!;
  });

  // --- M-58 Sessions ---------------------------------------------------------

  /// `GET /auth/sessions` — `1 web + 1 phone + 1 tablet` siyosati ko'rinishi.
  Future<List<DriverSession>> sessions({DriverSlot slot = DriverSlot.primary}) =>
      guardApiCall(() async {
        final Response<Object?> response = await _dio.get<Object?>(
          AuthPath.sessions,
          options: _authorized(slot: slot),
        );
        return AuthDecoder.sessions(response.data);
      });

  /// `DELETE /auth/sessions/{id}` — boshqa qurilmani chiqarish.
  Future<void> revokeSession(String id, {DriverSlot slot = DriverSlot.primary}) =>
      guardApiCall(() async {
        await _dio.delete<Object?>('${AuthPath.sessions}/$id', options: _authorized(slot: slot));
      });
}

/// JSON → domen. `presentation` bu funksiyalarni ko'rmaydi.
abstract final class AuthDecoder {
  const AuthDecoder._();

  /// Backend konverti: `{"data": {...}}`.
  static Map<String, Object?> envelope(Object? raw) {
    if (raw is Map) {
      final Object? data = raw['data'];
      if (data is Map) {
        return data.cast<String, Object?>();
      }
      return raw.cast<String, Object?>();
    }
    return const <String, Object?>{};
  }

  static AppConfig appConfig(Map<String, Object?> json) => AppConfig(
    minSupportedVersion: _string(json['min_supported_version']),
    latestVersion: _string(json['latest_version']),
    forceUpdate: json['force_update'] == true,
    serverTime: _dateTime(json['server_time']),
    accessTokenTtlSeconds: _int(json['access_token_ttl_seconds']) ?? 900,
    supportEmail: _string(json['support_email']),
    featureFlags: json['feature_flags'] is Map
        ? (json['feature_flags']! as Map).cast<String, Object?>()
        : const <String, Object?>{},
  );

  static AuthTokens? tokens(Map<String, Object?> json) {
    final String? access = _string(json['access_token']);
    final String? refresh = _string(json['refresh_token']);
    if (access == null || refresh == null) {
      return null;
    }
    final int? expiresIn = _int(json['expires_in']);
    return AuthTokens(
      accessToken: access,
      refreshToken: refresh,
      // `expires_in` — xom TTL; aniq muddat `TimeSource` bilan
      // `AuthRepositoryImpl.resolveExpiry` da hisoblanadi (M-time).
      expiresIn: expiresIn == null ? null : Duration(seconds: expiresIn),
      refreshExpiresAt: _dateTime(json['refresh_expires_at']),
    );
  }

  static LoginOutcome loginOutcome(Map<String, Object?> json) => LoginOutcome(
    tokens: tokens(json)!,
    profile: profile(json['user']),
    sessionId: _string(json['session_id']),
    replacedSession: json['replaced_session'] == true,
    requiresTotpSetup: json['requires_totp_setup'] == true,
    subscriptionReadonly: json['subscription_readonly'] == true,
  );

  static DriverProfile? profile(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final Map<String, Object?> json = raw.cast<String, Object?>();
    final String? id = _string(json['id']);
    if (id == null) {
      return null;
    }
    return DriverProfile(
      id: id,
      username: _string(json['username']) ?? '',
      firstName: _string(json['first_name']) ?? '',
      lastName: _string(json['last_name']) ?? '',
      status: AccountStatus.parse(_string(json['status'])),
      email: _string(json['email']),
      roleName: _string(json['role_name']),
      permissions: json['permissions'] is List
          ? (json['permissions']! as List)
                .map((Object? e) => e?.toString() ?? '')
                .where((String e) => e.isNotEmpty)
                .toList(growable: false)
          : const <String>[],
      pinSet: json['pin_set'] == true,
      totpEnabled: json['totp_enabled'] == true,
    );
  }

  static PinVerification pinVerification(Map<String, Object?> json, PinAction requested) =>
      PinVerification(
        verified: json['verified'] == true,
        action: PinAction.parse(_string(json['action'])) == PinAction.switchDriver
            ? PinAction.switchDriver
            : requested,
        sessionResumed: json['session_resumed'] == true,
      );

  static TotpSetup totpSetup(Map<String, Object?> json) => TotpSetup(
    secret: _string(json['secret']) ?? '',
    otpauthUrl: _string(json['otpauth_url']),
    issuer: _string(json['issuer']),
    digits: _int(json['digits']) ?? 6,
    period: _int(json['period']) ?? 30,
  );

  static TotpVerification totpVerification(Map<String, Object?> json) => TotpVerification(
    enabled: json['enabled'] == true,
    recoveryCodes: json['recovery_codes'] is List
        ? (json['recovery_codes']! as List)
              .map((Object? e) => e?.toString() ?? '')
              .where((String e) => e.isNotEmpty)
              .toList(growable: false)
        : const <String>[],
    tokens: json['tokens'] is Map ? tokens((json['tokens']! as Map).cast<String, Object?>()) : null,
  );

  /// `{"data": [ ... ]}` konverti (ro'yxat).
  static List<DriverSession> sessions(Object? raw) {
    final Object? data = raw is Map ? raw['data'] : raw;
    if (data is! List) {
      return const <DriverSession>[];
    }
    return data
        .whereType<Map<Object?, Object?>>()
        .map((Map<Object?, Object?> e) => session(e.cast<String, Object?>()))
        .toList(growable: false);
  }

  static DriverSession session(Map<String, Object?> json) => DriverSession(
    id: _string(json['id']) ?? '',
    deviceType: SessionDeviceType.parse(_string(json['device_type'])),
    status: ServerSessionStatus.parse(_string(json['status'])),
    deviceId: _string(json['device_id']),
    appVersion: _string(json['app_version']),
    ip: _string(json['ip']),
    userAgent: _string(json['user_agent']),
    createdAt: _dateTime(json['created_at']),
    lastSeenAt: _dateTime(json['last_seen_at']),
    expiresAt: _dateTime(json['expires_at']),
    current: json['current'] == true,
  );

  static String? _string(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static int? _int(Object? value) => switch (value) {
    final int v => v,
    final num v => v.toInt(),
    final String v => int.tryParse(v),
    _ => null,
  };

  static DateTime? _dateTime(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toUtc() : null;
}
