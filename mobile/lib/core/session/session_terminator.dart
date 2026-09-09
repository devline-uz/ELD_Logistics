/// Sessiyani tugatishning **yagona** yo'li (§4.6, §4.7, M17/M18).
///
/// Ikki kirish nuqtasi bor:
///  * [SessionTerminator.signOut] — haydovchi `Logout` bosdi (`pause=false`);
///  * [SessionTerminator.terminateRevoked] — server tokenni bekor qildi
///    (`TOKEN_REVOKED` / `TOKEN_REUSED` / `TOKEN_INVALID`) → `M-56`.
///
/// Qat'iy shartlar:
///  * **best-effort** — hech qanday bosqich istisno tashlamaydi; server
///    chaqiruvi 401/tarmoq xatosi bersa ham lokal tozalash **baribir** bajariladi
///    (logout idempotent: server sessiyani allaqachon yopgan bo'lishi mumkin);
///  * tokenlar va lokal sessiya tozalanadi, **outbox tegilmaydi** (M17);
///  * fon xizmatlari (GPS, BLE) jimgina to'xtatiladi — platforma kanali
///    bo'lmasa ham (`MissingPluginException`) oqim uzilmaydi;
///  * oxirida `AuthStatus.unauthenticated` qo'yiladi — qo'riqchi (`app_router`)
///    shundan keyin `/login` yoki `/signed-out` ga o'tkazadi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/session_manager.dart';
import '../../features/auth/domain/session_state.dart';
import '../eld/eld_providers.dart';
import '../error/api_error.dart';
import '../location/location_models.dart';
import '../location/location_providers.dart';
import '../router/auth_state.dart';
import '../security/secure_vault.dart';

/// Sessiya nima uchun tugadi — qo'riqchi shunga qarab ekran tanlaydi.
enum SessionEndReason {
  /// Hech qachon kirilmagan yoki oddiy `Logout`.
  none,

  /// Server tokenni bekor qildi → `M-56 Signed out elsewhere`.
  revoked,
}

class SessionEndReasonNotifier extends Notifier<SessionEndReason> {
  @override
  SessionEndReason build() => SessionEndReason.none;

  void set(SessionEndReason reason) => state = reason;
}

/// Oxirgi sessiya tugash sababi (`app_router` o'qiydi).
final NotifierProvider<SessionEndReasonNotifier, SessionEndReason> sessionEndReasonProvider =
    NotifierProvider<SessionEndReasonNotifier, SessionEndReason>(SessionEndReasonNotifier.new);

class SessionTerminator {
  const SessionTerminator(this._ref);

  final Ref _ref;

  /// To'liq chiqish. Server chaqiruvi **ixtiyoriy va best-effort**.
  ///
  /// [serverLogout] — `POST /auth/logout {pause:false}` ni bajaradigan funksiya.
  /// U qanday xato tashlasa ham (401 `TOKEN_REVOKED`, tarmoq yo'q,
  /// `DioException`) natija **muvaffaqiyat** deb qaraladi.
  Future<void> signOut({DriverSlot? slot, Future<void> Function()? serverLogout}) async {
    final DriverSlot target = slot ?? _ref.read(sessionManagerProvider).activeSlot;
    if (serverLogout != null) {
      await _quietly(serverLogout);
    }
    await _clearLocal(target, SessionEndReason.none);
  }

  /// Refresh bekor qilindi — majburiy chiqish (`M-56`).
  Future<void> terminateRevoked(DriverSlot slot, ApiError error) =>
      _clearLocal(slot, SessionEndReason.revoked);

  Future<void> _clearLocal(DriverSlot slot, SessionEndReason reason) async {
    await _stopForegroundWork();
    // Tokenlar + slot holati. Outbox tegilmaydi (M17).
    await _quietly(() => _ref.read(sessionManagerProvider.notifier).signOut(slot));
    final DualSessionState next = _ref.read(sessionManagerProvider);
    if (!next.isSignedOut) {
      // Ikkinchi slotda haydovchi qoldi (co-driver) — ilova ochiq qoladi.
      return;
    }
    _ref.read(sessionEndReasonProvider.notifier).set(reason);
    _ref.read(authStatusProvider.notifier).set(AuthStatus.unauthenticated);
  }

  /// GPS va BLE — platforma kanali yo'q bo'lsa ham yiqilmaydi.
  Future<void> _stopForegroundWork() async {
    await _quietly(() => _ref.read(locationServiceProvider).start(LocationProfile.off));
    await _quietly(() => _ref.read(eldConnectionManagerProvider).disconnect());
  }

  static Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (_) {
      // Chiqish oqimi hech qachon to'xtamaydi.
      return;
    }
  }
}

final Provider<SessionTerminator> sessionTerminatorProvider = Provider<SessionTerminator>(
  SessionTerminator.new,
);
