/// **M9** — ikki sessiya menejeri (tz-mobile §3.3, §4.6, §4.8).
///
/// Vazifasi: `SessionPolicy` (sof qoidalar) natijasini `SecureVault` ga
/// yozish, faol slotni `ActiveSlotHolder` ga uzatish va UI ga kuzatiladigan
/// holat berish. **Biznes qoidasi bu yerda yozilmaydi** — u
/// `domain/session_policy.dart` da.
///
/// Nima bu sinfda **yo'q**:
///  * tokenlar — `SecureVault` da, slot bo'yicha ajratilgan;
///  * refresh mutexi — `RefreshCoordinator`, har slot uchun mustaqil;
///  * outbox — `core/sync`, `session_slot` ustuni bilan ajratilgan;
///  * `device_seq` — `settingsDao.nextDeviceSeq()`, **qurilma bo'yicha yagona**
///    monoton hisoblagich (slotlar bo'linmaydi).
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/db/session_data_cleaner.dart';
import '../../../core/security/active_slot.dart';
import '../../../core/security/secure_vault.dart';
import '../../../core/session/session_profile.dart';
import '../domain/session_policy.dart';
import '../domain/session_state.dart';
import 'auth_providers.dart';
import 'session_store.dart';

class SessionManager extends Notifier<DualSessionState> {
  @override
  DualSessionState build() {
    unawaited(restore());
    return const DualSessionState.signedOut();
  }

  SessionStore get _store => ref.read(sessionStoreProvider);

  SecureVault get _vault => ref.read(secureVaultProvider);

  ActiveSlotHolder get _holder => ref.read(activeSlotHolderProvider);

  /// Ilova ishga tushganda diskdagi holatni tiklaydi (`M-01 Splash`).
  ///
  /// Secure storage o'qilmasa (qurilma qulflangan, Keystore buzilgan yoki
  /// test muhitida plagin yo'q) — ilova **yiqilmaydi**: bo'sh holat qoladi va
  /// haydovchi qayta login qiladi. Outbox tegilmaydi (M17).
  /// Faol slot profilini `kv_settings` ga ko'chiradi.
  Future<void> _syncSessionProfile(DualSessionState next) async {
    final SessionSlotState active = next.active;
    if (active.driverId.isEmpty) {
      return;
    }
    try {
      await ref
          .read(sessionProfileProvider.notifier)
          .write(SessionProfile(driverId: active.driverId, driverName: active.driverName));
    } on Object catch (_) {
      return;
    }
  }

  Future<void> restore() async {
    try {
      final DualSessionState restored = await _store.read();
      // Tiklash `build()` da fonda boshlanadi. Shu orada login bo'lib qolsa
      // (masalan `M-02` darhol yuborilsa) diskdagi eski holat **ustidan
      // yozilmaydi** — aks holda yangi sessiya yo'qoladi.
      if (!state.isSignedOut) {
        return;
      }
      await _apply(restored, persist: false);
    } on Object catch (_) {
      return;
    }
  }

  /// Slotga login qilingan haydovchini yozadi (`M-02`, co-driver logini ham).
  ///
  /// **S-M4 (#B-130):** yangi `driver_id` ma'lum bo'lgach, `_apply` dan
  /// **oldin** `SessionDataCleaner` chaqiriladi — aks holda oldingi
  /// haydovchining loglari, chati va bildirishnomalari ekranda qolar edi.
  Future<void> signIn({
    required DriverSlot slot,
    required String driverId,
    required String driverName,
    String? sessionId,
  }) async {
    final DualSessionState next = SessionPolicy.signIn(
      state,
      slot: slot,
      driverId: driverId,
      driverName: driverName,
      sessionId: sessionId,
    );
    await _cleanIfDriverChanged(next);
    await _apply(next);
  }

  /// `M-20 Switch co-driver` — **PIN tasdiqlangandan keyin** chaqiriladi.
  ///
  /// Bloklangan bo'lsa sababni qaytaradi va holat o'zgarmaydi.
  Future<SwitchBlockReason?> switchDrivers() async {
    final SwitchBlockReason? blocked = SessionPolicy.switchBlockedBy(state);
    if (blocked != null) {
      return blocked;
    }
    await _apply(SessionPolicy.switchDrivers(state));
    return null;
  }

  /// `Leave Truck` (§4.8) — faol slot `paused`, co-driver bo'lsa u faol bo'ladi.
  ///
  /// Refresh token **o'chirilmaydi** (M18) va outbox tegilmaydi (M17).
  Future<LeaveTruckOutcome> leaveTruck() async {
    final ({DualSessionState state, LeaveTruckOutcome outcome}) next = SessionPolicy.leaveTruck(
      state,
    );
    await _apply(next.state);
    return next.outcome;
  }

  /// `Return to truck` — PIN tasdiqlangandan keyin.
  Future<void> returnToTruck({DriverSlot? slot}) =>
      _apply(SessionPolicy.returnToTruck(state, slot: slot));

  /// To'liq chiqish (`pause=false`) yoki `TOKEN_REVOKED` → `M-56`.
  ///
  /// Tokenlar o'chiriladi, **outbox saqlanadi** (M17).
  Future<void> signOut(DriverSlot slot) async {
    await _vault.clearSession(slot);
    final DualSessionState next = SessionPolicy.signOut(state, slot);
    // S-M4: chiqqan haydovchining lokal ko'zgusi qoladigan bo'lsa, keyingi
    // haydovchi uni ko'rar edi. Tartib muhim — tozalovchi `kv_settings` dagi
    // HOZIRGI `driver_id` bilan solishtiradi, `_apply` esa uni almashtiradi.
    await _cleanIfDriverChanged(next);
    await _apply(next);
  }

  /// **S-M4 / #B-130** — haydovchi almashganda lokal domen jadvallarini
  /// tozalaydi.
  ///
  /// **M17 saqlanadi:** yuborilmagan (`pending`/`inflight`) outbox va u
  /// bog'langan yozuvlar tegilmaydi — buni [SessionDataCleaner] ta'minlaydi,
  /// bu yerda faqat chaqiruv tartibi to'g'ri bo'lishi kerak.
  ///
  /// Ikkinchi slotda qolgan haydovchi (`co-driver`) ma'lumoti o'chirilmaydi:
  /// [DualSessionState.occupiedDriverIds] tozalovchiga uzatiladi.
  Future<void> _cleanIfDriverChanged(DualSessionState next) async {
    try {
      final String activeId = next.active.driverId;
      final SessionResetReport report = await ref
          .read(sessionDataCleanerProvider)
          .switchDriver(
            driverId: activeId.isEmpty ? null : activeId,
            stillSignedIn: next.occupiedDriverIds,
          );
      if (report.wiped) {
        // Tozalovchi `kv_settings` dan PII ni o'chirdi; xotiradagi nusxa ham
        // tashlanadi, aks holda oldingi haydovchining emaili/litsenziyasi
        // yangi sessiyaga «yopishib» qolardi (S-M4).
        ref.read(sessionProfileProvider.notifier).clearInMemory();
      }
    } on Object catch (_) {
      // Baza hali ochilmagan (bootstrapdan oldin yoki test muhitida) —
      // login/logout oqimi shu sababdan bloklanmaydi.
      return;
    }
  }

  Future<void> _apply(DualSessionState next, {bool persist = true}) async {
    final DriverSlot previousActive = state.activeSlot;
    _holder.value = next.activeSlot;
    if (next == state) {
      return;
    }
    state = next;
    // Faol haydovchi almashsa `SessionContext`/`currentDriverIdProvider` ham
    // yangilanadi — outbox yozuvlari va kunlik log **to'g'ri** haydovchiga
    // biriktirilishi shunga bog'liq (`tz.md` Q45.1).
    if (previousActive != next.activeSlot || persist) {
      await _syncSessionProfile(next);
    }
    if (!persist) {
      return;
    }
    try {
      await _store.write(next);
    } on Object catch (_) {
      // Diskka yozib bo'lmadi — xotiradagi holat baribir to'g'ri.
      return;
    }
  }
}

final Provider<SessionStore> sessionStoreProvider = Provider<SessionStore>(
  (Ref ref) => SessionStore(ref.watch(secureVaultProvider)),
);

/// Ikki sessiya menejeri — `keepAlive` (ilova umri davomida yashaydi).
final NotifierProvider<SessionManager, DualSessionState> sessionManagerProvider =
    NotifierProvider<SessionManager, DualSessionState>(SessionManager.new);
