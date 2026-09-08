/// `Leave Truck` / `Return to truck` va to'liq `Logout` oqimi (§4.8, M18).
///
/// Qadamlar tartibi `domain/leave_truck_policy.dart` da; bu sinf faqat
/// bajaruvchi. Har qadam **oflayn ham** ishlaydi: OFF eventi outbox'ga
/// tushadi, `logout(pause)` ham navbatga o'tadi, lokal holat esa **darhol**
/// `paused` bo'ladi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_core/sync_core.dart';

import '../../../../core/db/daos/outbox_dao.dart';
import '../../../../core/db/db_providers.dart';
import '../../../../core/eld/eld_connection_manager.dart';
import '../../../../core/eld/eld_providers.dart';
import '../../../../core/error/api_error.dart';
import '../../../../core/security/secure_vault.dart';
import '../../../../core/session/session_terminator.dart';
import '../../../duty_status/data/duty_status_providers.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../data/auth_providers.dart';
import '../../data/session_manager.dart';
import '../../domain/auth_repository.dart';
import '../../domain/leave_truck_policy.dart';
import '../../domain/session_policy.dart';
import '../../domain/session_state.dart';

/// Ekran uchun kesim.
class LeaveTruckState {
  const LeaveTruckState({this.busy = false, this.error, this.outcome});

  final bool busy;
  final ApiError? error;

  /// Oqim tugagach: co-driver faol bo'ldimi yoki `M-03` ga o'tildimi.
  final LeaveTruckOutcome? outcome;

  LeaveTruckState copyWith({bool? busy, ApiError? error, LeaveTruckOutcome? outcome}) =>
      LeaveTruckState(busy: busy ?? this.busy, error: error, outcome: outcome ?? this.outcome);
}

class LeaveTruckController extends Notifier<LeaveTruckState> {
  @override
  LeaveTruckState build() => const LeaveTruckState();

  DualSessionState get _session => ref.read(sessionManagerProvider);

  SessionManager get _sessions => ref.read(sessionManagerProvider.notifier);

  AuthRepository get _auth => ref.read(activeAuthRepositoryProvider);

  /// Tasdiq modali matni: co-driver bo'lsa boshqa xabar (§4.8).
  LeaveTruckPrompt get prompt =>
      LeaveTruckPolicy.prompt(hasActiveCoDriver: _session.passive.isActive);

  /// **M18:** outbox bo'sh bo'lmasa `Logout` ogohlantiradi.
  LogoutPrompt logoutPrompt() => LeaveTruckPolicy.logoutPrompt(queuedRecords: queuedRecords);

  /// Navbatdagi yozuvlar soni — ogohlantirish matnida ko'rsatiladi.
  ///
  /// Outbox `core/db` da; u ochilmagan bo'lsa (masalan auth oqimi lokal baza
  /// tayyor bo'lishidan oldin) ogohlantirish ko'rsatilmaydi.
  int get queuedRecords {
    try {
      final OutboxQueueStats? stats = ref.read(outboxStatsProvider).value;
      return stats?.pendingTotal ?? 0;
    } on Object catch (_) {
      return 0;
    }
  }

  /// `Leave Truck` — §4.8 ketma-ketligi. Tarmoq xatosi oqimni **to'xtatmaydi**.
  Future<LeaveTruckOutcome> leaveTruck() async {
    state = const LeaveTruckState(busy: true);
    ApiError? failure;

    for (final LeaveTruckStep step in LeaveTruckPolicy.steps) {
      try {
        await _runStep(step);
      } on ApiError catch (error) {
        // Oflayn — kutilgan holat: yozuvlar outbox'da qoladi (M18).
        if (!error.isOffline) {
          failure = error;
        }
      }
    }

    final LeaveTruckOutcome outcome = await _sessions.leaveTruck();
    state = LeaveTruckState(error: failure, outcome: outcome);
    return outcome;
  }

  Future<void> _runStep(LeaveTruckStep step) async {
    switch (step) {
      case LeaveTruckStep.recordOffDuty:
        await ref
            .read(dutyStatusRepositoryProvider)
            .changeStatus(
              draft: const DutyStatusDraft(status: DutyStatusValue.off),
              origin: EventOrigin.driver,
            );
      case LeaveTruckStep.disconnectEld:
        await _withEld((EldConnectionManager eld) => eld.disconnect());
      case LeaveTruckStep.pauseSession:
        await _auth.logout(pause: true);
    }
  }

  /// ELD menejeriga xavfsiz murojaat: qurilma yo'q/ulanmagan bo'lsa yoki BLE
  /// mavjud bo'lmasa oqim **to'xtamaydi** (M-17 banneri ko'rsatiladi).
  Future<void> _withEld(Future<Object?> Function(EldConnectionManager eld) action) async {
    try {
      await action(ref.read(eldConnectionManagerProvider));
    } on Object catch (_) {
      return;
    }
  }

  /// To'liq chiqish (drawer'dagi qizil `Logout`, `pause=false`).
  ///
  /// Outbox **o'chirilmaydi** (M17) — yozuvlar keyingi login'da yuboriladi.
  /// #B-1: server chaqiruvi **best-effort** — `401 TOKEN_REVOKED` yoki tarmoq
  /// yo'qligi chiqishni to'xtatmaydi, lokal holat baribir tozalanadi.
  Future<void> logout() async {
    state = const LeaveTruckState(busy: true);
    final DriverSlot slot = _session.activeSlot;
    await ref
        .read(sessionTerminatorProvider)
        .signOut(slot: slot, serverLogout: () => _auth.logout(pause: false));
    state = const LeaveTruckState();
  }

  /// `Return to truck` — PIN tasdiqlangandan **keyin** chaqiriladi.
  ///
  /// Sessiya `active` bo'ladi; BLE qayta ulanadi va sync darhol yuritiladi.
  Future<void> returnToTruck() async {
    state = const LeaveTruckState(busy: true);
    await _sessions.returnToTruck();
    await _withEld((EldConnectionManager eld) => eld.connect());
    state = const LeaveTruckState();
  }
}

final NotifierProvider<LeaveTruckController, LeaveTruckState> leaveTruckControllerProvider =
    NotifierProvider<LeaveTruckController, LeaveTruckState>(LeaveTruckController.new);

/// Tasdiq matnida ko'rsatiladigan ikkinchi haydovchi ismi (§4.8).
final Provider<String> leaveTruckCoDriverNameProvider = Provider<String>(
  (Ref ref) => ref.watch(sessionManagerProvider).passive.driverName,
);
