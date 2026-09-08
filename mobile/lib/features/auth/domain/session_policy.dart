/// Ikki slotli sessiya o'tishlarining **sof** qoidalari (tz-mobile §3.3, §4.8).
///
/// Bu fayl `flutter` ga bog'liq emas va `DateTime.now()` ishlatmaydi — barcha
/// qaror faqat kirish holatidan chiqadi, shuning uchun unit test bilan
/// to'liq qoplanadi. `SessionManager` (data qatlami) shu funksiyalarni
/// chaqiradi va natijani `SecureVault` ga yozadi.
library;

import '../../../core/security/secure_vault.dart';
import 'session_state.dart';

/// `Switch co-driver` ni bloklaydigan sabablar (M-20).
enum SwitchBlockReason {
  /// Ikkinchi slot bo'sh — avval co-driver login qilishi kerak.
  noCoDriver,

  /// Ikkinchi slot `paused`: u avval `Return to truck` qilishi kerak.
  coDriverPaused,
}

/// `Leave Truck` natijasi — UI qayerga ketishini shundan biladi (§4.8).
enum LeaveTruckOutcome {
  /// Co-driver avtomatik `active` bo'ldi — ekran `Home` da qoladi.
  coDriverPromoted,

  /// Almashtiriladigan haydovchi yo'q — `M-03 Leave truck` ekrani.
  paused,
}

/// Sessiya o'tishlari. Har metod **yangi** holat qaytaradi, mutatsiya yo'q.
abstract final class SessionPolicy {
  const SessionPolicy._();

  /// Slotga login qilingan haydovchini yozadi.
  ///
  /// Slot bo'shligidan qat'i nazar birinchi login **doim** `activeSlot` ni
  /// o'ziga oladi: haydovchi endigina parol kiritgan, u boshqaruvda.
  static DualSessionState signIn(
    DualSessionState state, {
    required DriverSlot slot,
    required String driverId,
    required String driverName,
    String? sessionId,
  }) => state
      .withSlot(
        SessionSlotState(
          slot: slot,
          status: SessionStatus.active,
          driverId: driverId,
          driverName: driverName,
          sessionId: sessionId,
        ),
      )
      .withActive(slot);

  /// `Switch co-driver` (M-20) mumkinmi. `null` — mumkin.
  static SwitchBlockReason? switchBlockedBy(DualSessionState state) {
    final SessionSlotState target = state.passive;
    if (target.isEmpty) {
      return SwitchBlockReason.noCoDriver;
    }
    if (target.isPaused) {
      return SwitchBlockReason.coDriverPaused;
    }
    return null;
  }

  /// PIN tasdiqlangandan keyin slotlarni almashtiradi.
  ///
  /// Tokenlar tegilmaydi (har slot o'zinikini saqlaydi) — faqat `activeSlot`.
  /// Bloklangan holatda holat **o'zgarmaydi** (chaqiruvchi avval
  /// [switchBlockedBy] ni tekshiradi).
  static DualSessionState switchDrivers(DualSessionState state) =>
      switchBlockedBy(state) != null ? state : state.withActive(state.activeSlot.other);

  /// `Leave Truck` (§4.8): faol slot `paused`, co-driver bo'lsa u faol bo'ladi.
  static ({DualSessionState state, LeaveTruckOutcome outcome}) leaveTruck(DualSessionState state) {
    final DualSessionState paused = state.withSlot(
      state.active.copyWith(status: SessionStatus.paused),
    );
    final SessionSlotState candidate = paused.passive;
    if (candidate.isActive) {
      return (
        state: paused.withActive(candidate.slot),
        outcome: LeaveTruckOutcome.coDriverPromoted,
      );
    }
    return (state: paused, outcome: LeaveTruckOutcome.paused);
  }

  /// `Return to truck` — PIN tasdiqlangandan keyin slot yana `active`.
  ///
  /// Qaytgan haydovchi boshqaruvni ham qaytarib oladi (§4.8: BLE qayta ulanadi,
  /// sync darhol yuritiladi — bu faol slot nomidan bo'ladi).
  static DualSessionState returnToTruck(DualSessionState state, {DriverSlot? slot}) {
    final DriverSlot target = slot ?? state.activeSlot;
    final SessionSlotState current = state.of(target);
    if (!current.isPaused) {
      return state;
    }
    return state.withSlot(current.copyWith(status: SessionStatus.active)).withActive(target);
  }

  /// To'liq chiqish (`pause=false`) yoki `TOKEN_REVOKED` (M-56).
  ///
  /// Slot bo'shatiladi; agar u faol bo'lgan bo'lsa va ikkinchi slotda tirik
  /// haydovchi bo'lsa — boshqaruv unga o'tadi.
  static DualSessionState signOut(DualSessionState state, DriverSlot slot) {
    final DualSessionState cleared = state.withSlot(SessionSlotState.vacant(slot));
    if (slot != state.activeSlot) {
      return cleared;
    }
    final SessionSlotState candidate = cleared.of(slot.other);
    return candidate.isActive ? cleared.withActive(slot.other) : cleared;
  }
}
