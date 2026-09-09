/// Auth repozitoriysi — `presentation` faqat shu interfeysni ko'radi (M5).
///
/// Implementatsiya `data/auth_repository_impl.dart` da; xatolar har doim
/// `core/error/ApiError` sifatida uchadi.
library;

import 'auth_models.dart';
import 'auth_policies.dart';
import 'driver_session.dart';

/// Bootstrap natijasi (§4.2, `M-01 Splash`).
enum BootstrapDestination {
  /// `force_update` yoki versiya `min_supported_version` dan past — `M-57`.
  forceUpdate,

  /// Refresh token bor va amal qiladi (yoki oflayn) — `/home`.
  home,

  /// Sessiya `paused` (Leave Truck) — `M-03`.
  paused,

  /// Refresh token yo'q yoki bekor qilingan — `M-02`.
  login,
}

class BootstrapResult {
  const BootstrapResult({
    required this.destination,
    this.config,
    this.offline = false,
    this.pausedDriverName,
  });

  final BootstrapDestination destination;
  final AppConfig? config;

  /// M13: tarmoq yo'q — oflayn kirildi, bu **xato emas**.
  final bool offline;

  /// `M-03` sarlavhasi uchun.
  final String? pausedDriverName;
}

abstract interface class AuthRepository {
  /// §4.2 ketma-ketligi: `app/config` → versiya darvozasi → `TimeSource`
  /// offseti → refresh → yo'nalish.
  Future<BootstrapResult> bootstrap();

  /// Keshlangan yoki oxirgi olingan konfiguratsiya (`M-57` uchun).
  AppConfig? get cachedConfig;

  /// `POST /auth/login`. `device_id`/`device_type`/`app_version` avtomatik
  /// qo'shiladi; `company_id` **yuborilmaydi** (M164).
  Future<LoginOutcome> login({
    required String username,
    required String password,
    String? totpCode,
  });

  /// `POST /auth/logout`. [pause] `true` — Leave Truck (M18), refresh token tirik qoladi.
  Future<void> logout({required bool pause});

  /// `POST /auth/pin/verify` (+ M16 oflayn lokal tekshiruv).
  Future<PinVerification> verifyPin({required String pin, required PinAction action});

  /// Lokal blok holati (secure storage).
  Future<PinLockoutState> pinLockout();

  /// `POST /auth/password/forgot`.
  Future<void> requestPasswordReset({required String login});

  /// `POST /auth/password/reset`.
  Future<void> resetPassword({required String token, required String password});

  /// `POST /auth/invitation/accept` — muvaffaqiyatdan keyin lokal PIN hash yoziladi.
  Future<void> acceptInvitation({
    required String token,
    required String password,
    required String pin,
  });

  /// `POST /auth/2fa/setup`.
  Future<TotpSetup> startTotpSetup();

  /// `POST /auth/2fa/verify`.
  Future<TotpVerification> verifyTotp({String? code, String? recoveryCode});

  /// `GET /me`.
  Future<DriverProfile> me();

  /// Oxirgi ma'lum profil (oflayn ko'rsatish uchun).
  DriverProfile? get cachedProfile;

  /// Oxirgi ma'lum haydovchi yozuvi (`drivers.id`, tayinlangan unit).
  ///
  /// `null` — hali o'qilmagan yoki oflayn login qilingan.
  DriverRecord? get cachedDriverRecord;

  /// `GET /drivers` dan haydovchi yozuvini o'qiydi va keshlaydi.
  ///
  /// Tarmoq yo'q yoki ruxsat bo'lmasa `null` qaytaradi — login oqimi
  /// **hech qachon** shu sababdan yiqilmaydi.
  Future<DriverRecord?> loadDriverRecord();

  /// `M-58` — `GET /auth/sessions` (1 web + 1 phone + 1 tablet, §4.6).
  Future<List<DriverSession>> sessions();

  /// `M-58` — `DELETE /auth/sessions/{id}`; joriy sessiya o'chirilmaydi.
  Future<void> revokeSession(String id);
}
