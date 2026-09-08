/// Ikki sessiya menejerining test dublyori (M9).
///
/// Haqiqiy `SessionManager` `SecureVault` ga (platforma kanali) boradi —
/// widget va golden testlarida bu kerak emas: holat oldindan beriladi.
library;

import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:eld_mobile/features/auth/domain/session_policy.dart';
import 'package:eld_mobile/features/auth/domain/session_state.dart';

/// Diskka yozmaydigan menejer: `SessionPolicy` ni qo'llaydi, holat xotirada.
class FakeSessionManager extends SessionManager {
  FakeSessionManager(this._initial);

  final DualSessionState _initial;

  @override
  DualSessionState build() => _initial;

  @override
  Future<void> restore() async {}

  @override
  Future<void> signIn({
    required DriverSlot slot,
    required String driverId,
    required String driverName,
    String? sessionId,
  }) async {
    state = SessionPolicy.signIn(
      state,
      slot: slot,
      driverId: driverId,
      driverName: driverName,
      sessionId: sessionId,
    );
  }

  @override
  Future<SwitchBlockReason?> switchDrivers() async {
    final SwitchBlockReason? blocked = SessionPolicy.switchBlockedBy(state);
    if (blocked == null) {
      state = SessionPolicy.switchDrivers(state);
    }
    return blocked;
  }

  @override
  Future<LeaveTruckOutcome> leaveTruck() async {
    final ({DualSessionState state, LeaveTruckOutcome outcome}) next = SessionPolicy.leaveTruck(
      state,
    );
    state = next.state;
    return next.outcome;
  }

  @override
  Future<void> returnToTruck({DriverSlot? slot}) async {
    state = SessionPolicy.returnToTruck(state, slot: slot);
  }

  @override
  Future<void> signOut(DriverSlot slot) async {
    state = SessionPolicy.signOut(state, slot);
  }
}

/// Yolg'iz haydovchi (`John Smith`, asosiy slot).
DualSessionState soloSession() => SessionPolicy.signIn(
  const DualSessionState.signedOut(),
  slot: DriverSlot.primary,
  driverId: 'drv-1',
  driverName: 'John Smith',
  sessionId: 'sess-1',
);

/// Kabinadagi ikki haydovchi; faol — `Maria Lopez` (co-driver sloti).
DualSessionState pairedSession() => SessionPolicy.signIn(
  soloSession(),
  slot: DriverSlot.coDriver,
  driverId: 'drv-2',
  driverName: 'Maria Lopez',
  sessionId: 'sess-2',
);
