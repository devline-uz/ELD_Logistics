/// `M-20 / T-07 Switch co-driver` kontrolleri (M7: telefon + planshet bitta).
///
/// Biznes qoidalari `domain/session_policy.dart` da (sof funksiyalar). Bu
/// sinf faqat holatni yig'adi va menejerni chaqiradi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/secure_vault.dart';
import '../../data/session_manager.dart';
import '../../domain/session_policy.dart';
import '../../domain/session_state.dart';

/// Ekran ko'radigan kesim — ikki slot va almashtirish mumkinligi.
class CoDriverState {
  const CoDriverState({required this.session, this.busy = false, this.switched = false});

  final DualSessionState session;
  final bool busy;

  /// Oxirgi amal muvaffaqiyatli tugadi — snackbar/yopish uchun.
  final bool switched;

  SessionSlotState get activeDriver => session.active;

  SessionSlotState get coDriver => session.passive;

  /// `null` — almashtirish mumkin.
  SwitchBlockReason? get blockedBy => SessionPolicy.switchBlockedBy(session);

  bool get canSwitch => blockedBy == null;

  /// Ikkinchi slot bo'sh — «Sign in co-driver» ko'rsatiladi.
  bool get needsCoDriverLogin => blockedBy == SwitchBlockReason.noCoDriver;

  CoDriverState copyWith({DualSessionState? session, bool? busy, bool? switched}) => CoDriverState(
    session: session ?? this.session,
    busy: busy ?? this.busy,
    switched: switched ?? this.switched,
  );
}

class CoDriverController extends Notifier<CoDriverState> {
  @override
  CoDriverState build() => CoDriverState(session: ref.watch(sessionManagerProvider));

  /// PIN (`action=switch_driver`) tasdiqlangandan **keyin** chaqiriladi.
  ///
  /// PIN oqimining o'zi `M-04` da; bu yerda faqat slotlar almashadi.
  Future<SwitchBlockReason?> confirmSwitch() async {
    if (state.busy) {
      return null;
    }
    state = state.copyWith(busy: true);
    final SwitchBlockReason? blocked = await ref
        .read(sessionManagerProvider.notifier)
        .switchDrivers();
    state = state.copyWith(busy: false, switched: blocked == null);
    return blocked;
  }

  /// Ikkinchi slotga login qilish uchun bo'sh slotni qaytaradi.
  DriverSlot get vacantSlot => state.session.activeSlot.other;
}

final NotifierProvider<CoDriverController, CoDriverState> coDriverControllerProvider =
    NotifierProvider<CoDriverController, CoDriverState>(CoDriverController.new);
