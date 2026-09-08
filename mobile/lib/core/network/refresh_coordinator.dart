/// Token refresh mutexi (tz-mobile §4.7, M152/M-44).
///
/// Parallel 401 lar uchun **bitta** refresh oqimi bo'ladi: birinchi so'rov
/// refreshni boshlaydi, qolganlari o'sha `Future` ni kutadi va yangi token
/// bilan **bir marta** takrorlanadi. Ikkinchi refresh ishga tushmaydi — aks
/// holda rotatsiya poygasi `token_reuse` ga va butun sessiya bekor bo'lishiga
/// olib keladi.
///
/// Har `DriverSlot` (asosiy / co-driver) uchun **mustaqil** mutex.
library;

import 'dart:async';

import '../error/api_error.dart';
import '../error/api_error_code.dart';
import '../security/secure_vault.dart';

/// Refresh natijasi.
sealed class RefreshOutcome {
  const RefreshOutcome();
}

/// Muvaffaqiyat: yangi access token (+ rotatsiyalangan refresh token).
class RefreshSucceeded extends RefreshOutcome {
  const RefreshSucceeded({required this.accessToken, required this.refreshToken, this.expiresAt});

  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;
}

/// Sessiya tugadi — qayta login talab qilinadi (M-44).
class RefreshRejected extends RefreshOutcome {
  const RefreshRejected(this.error);

  final ApiError error;
}

/// Vaqtinchalik xato (tarmoq yo'q) — sessiya saqlanadi, keyin qayta uriniladi.
class RefreshDeferred extends RefreshOutcome {
  const RefreshDeferred(this.error);

  final ApiError error;
}

/// `POST /auth/refresh` ni bajaruvchi. Implementatsiya `features/auth/data` da.
abstract interface class TokenRefreshClient {
  Future<RefreshOutcome> refresh({required DriverSlot slot, required String refreshToken});
}

/// Sessiya tugaganda chaqiriladigan qayta chaqiruv (outbox tegilmaydi — M17).
typedef SessionTerminationCallback = Future<void> Function(DriverSlot slot, ApiError error);

/// Refreshni ketma-ketlashtiruvchi koordinator.
class RefreshCoordinator {
  RefreshCoordinator({required this.vault, required this.client, this.onSessionTerminated});

  final SecureVault vault;
  final TokenRefreshClient client;
  final SessionTerminationCallback? onSessionTerminated;

  /// Slot bo'yicha jarayondagi refresh — mutex vazifasini bajaradi.
  final Map<DriverSlot, Future<RefreshOutcome>> _inFlight = <DriverSlot, Future<RefreshOutcome>>{};

  /// Jarayondagi refresh bormi (test va diagnostika uchun).
  bool isRefreshing(DriverSlot slot) => _inFlight.containsKey(slot);

  /// Refreshni bajaradi yoki jarayondagisini kutadi.
  ///
  /// Bir vaqtda faqat bitta HTTP `POST /auth/refresh` yuboriladi.
  Future<RefreshOutcome> refresh(DriverSlot slot) {
    final Future<RefreshOutcome>? pending = _inFlight[slot];
    if (pending != null) {
      return pending;
    }

    final Completer<RefreshOutcome> completer = Completer<RefreshOutcome>();
    _inFlight[slot] = completer.future;

    unawaited(
      _runRefresh(slot)
          .then(completer.complete)
          .catchError((Object error, StackTrace stackTrace) {
            completer.completeError(error, stackTrace);
          })
          .whenComplete(() {
            _inFlight.remove(slot);
          }),
    );

    return completer.future;
  }

  Future<RefreshOutcome> _runRefresh(DriverSlot slot) async {
    final String? refreshToken = await vault.readRefreshToken(slot);
    if (refreshToken == null || refreshToken.isEmpty) {
      const ApiError error = ApiError(
        code: ApiErrorCode.tokenInvalid,
        message: 'no refresh token stored',
      );
      await _terminate(slot, error);
      return const RefreshRejected(error);
    }

    final RefreshOutcome outcome = await client.refresh(slot: slot, refreshToken: refreshToken);

    switch (outcome) {
      case RefreshSucceeded(
        :final String accessToken,
        :final String refreshToken,
        :final DateTime? expiresAt,
      ):
        // Rotatsiya: eski token darhol almashtiriladi.
        await vault.writeRefreshToken(slot, refreshToken);
        vault.setAccessToken(slot, accessToken, expiresAt: expiresAt);
      case RefreshRejected(:final ApiError error):
        await _terminate(slot, error);
      case RefreshDeferred():
        break;
    }
    return outcome;
  }

  Future<void> _terminate(DriverSlot slot, ApiError error) async {
    await vault.clearSession(slot);
    await onSessionTerminated?.call(slot, error);
  }
}
