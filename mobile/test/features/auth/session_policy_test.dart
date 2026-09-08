@Timeout(Duration(seconds: 60))
/// **M9** — ikki slotli sessiya qoidalari (tz-mobile §3.3, §4.6, §4.8).
///
/// `SessionPolicy` sof funksiyalar to'plami: tarmoq, DB va `DateTime.now()`
/// yo'q, shuning uchun barcha o'tishlar shu yerda qoplanadi.
library;

import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/features/auth/domain/session_policy.dart';
import 'package:eld_mobile/features/auth/domain/session_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ikki haydovchi kirgan tipik kabina holati.
DualSessionState _bothSignedIn() => SessionPolicy.signIn(
  SessionPolicy.signIn(
    const DualSessionState.signedOut(),
    slot: DriverSlot.primary,
    driverId: 'drv-1',
    driverName: 'John Smith',
    sessionId: 'sess-1',
  ),
  slot: DriverSlot.coDriver,
  driverId: 'drv-2',
  driverName: 'Maria Lopez',
  sessionId: 'sess-2',
);

void main() {
  group('signIn', () {
    test('birinchi login asosiy slotni egallaydi va faol bo\'ladi', () {
      final DualSessionState state = SessionPolicy.signIn(
        const DualSessionState.signedOut(),
        slot: DriverSlot.primary,
        driverId: 'drv-1',
        driverName: 'John Smith',
      );

      expect(state.activeSlot, DriverSlot.primary);
      expect(state.primary.isActive, isTrue);
      expect(state.coDriver.isEmpty, isTrue);
      expect(state.hasCoDriver, isFalse);
      expect(state.isSignedOut, isFalse);
    });

    test('ikkinchi login co-driver slotiga tushadi, birinchisi saqlanadi', () {
      final DualSessionState state = _bothSignedIn();

      expect(state.primary.driverId, 'drv-1');
      expect(state.coDriver.driverId, 'drv-2');
      // Endigina parol kiritgan haydovchi boshqaruvda.
      expect(state.activeSlot, DriverSlot.coDriver);
      expect(state.hasCoDriver, isTrue);
    });
  });

  group('switch co-driver (M-20)', () {
    test('ikkinchi slot bo\'sh — bloklanadi', () {
      final DualSessionState state = SessionPolicy.signIn(
        const DualSessionState.signedOut(),
        slot: DriverSlot.primary,
        driverId: 'drv-1',
        driverName: 'John Smith',
      );

      expect(SessionPolicy.switchBlockedBy(state), SwitchBlockReason.noCoDriver);
      expect(SessionPolicy.switchDrivers(state), state);
    });

    test('ikkinchi slot pauzada — bloklanadi', () {
      final DualSessionState paused = SessionPolicy.leaveTruck(_bothSignedIn()).state;
      // Faol — primary; passive (co_driver) `paused`.
      expect(paused.activeSlot, DriverSlot.primary);
      expect(SessionPolicy.switchBlockedBy(paused), SwitchBlockReason.coDriverPaused);
    });

    test('almashtirish faqat activeSlot ni o\'zgartiradi, tokenlar tegilmaydi', () {
      final DualSessionState before = _bothSignedIn();
      final DualSessionState after = SessionPolicy.switchDrivers(before);

      expect(after.activeSlot, DriverSlot.primary);
      expect(after.primary, before.primary);
      expect(after.coDriver, before.coDriver);
    });
  });

  group('Leave Truck (§4.8)', () {
    test('yolg\'iz haydovchi — slot paused, M-03 ga o\'tiladi', () {
      final DualSessionState signedIn = SessionPolicy.signIn(
        const DualSessionState.signedOut(),
        slot: DriverSlot.primary,
        driverId: 'drv-1',
        driverName: 'John Smith',
      );

      final ({DualSessionState state, LeaveTruckOutcome outcome}) result = SessionPolicy.leaveTruck(
        signedIn,
      );

      expect(result.outcome, LeaveTruckOutcome.paused);
      expect(result.state.primary.isPaused, isTrue);
      expect(result.state.isPaused, isTrue);
      // Slot bo'shatilmaydi — refresh token tirik qoladi (M18).
      expect(result.state.isSignedOut, isFalse);
    });

    test('co-driver bor — u avtomatik faol bo\'ladi, ekran Home\'da qoladi', () {
      final ({DualSessionState state, LeaveTruckOutcome outcome}) result = SessionPolicy.leaveTruck(
        _bothSignedIn(),
      );

      expect(result.outcome, LeaveTruckOutcome.coDriverPromoted);
      expect(result.state.activeSlot, DriverSlot.primary);
      expect(result.state.active.driverId, 'drv-1');
      expect(result.state.coDriver.isPaused, isTrue);
      expect(result.state.isPaused, isFalse);
    });
  });

  group('Return to truck', () {
    test('pauzadagi slot yana faol bo\'ladi va boshqaruvni oladi', () {
      final DualSessionState paused = SessionPolicy.leaveTruck(_bothSignedIn()).state;
      final DualSessionState resumed = SessionPolicy.returnToTruck(
        paused,
        slot: DriverSlot.coDriver,
      );

      expect(resumed.coDriver.isActive, isTrue);
      expect(resumed.activeSlot, DriverSlot.coDriver);
    });

    test('pauzada bo\'lmagan slot o\'zgarmaydi', () {
      final DualSessionState state = _bothSignedIn();
      expect(SessionPolicy.returnToTruck(state), state);
    });
  });

  group('signOut (M-56 / to\'liq logout)', () {
    test('faol slot bo\'shatilsa boshqaruv co-driver ga o\'tadi', () {
      final DualSessionState state = SessionPolicy.signOut(_bothSignedIn(), DriverSlot.coDriver);

      expect(state.coDriver.isEmpty, isTrue);
      expect(state.activeSlot, DriverSlot.primary);
      expect(state.isSignedOut, isFalse);
    });

    test('oxirgi slot ham bo\'shasa ilova Login ga qaytadi', () {
      DualSessionState state = SessionPolicy.signOut(_bothSignedIn(), DriverSlot.coDriver);
      state = SessionPolicy.signOut(state, DriverSlot.primary);

      expect(state.isSignedOut, isTrue);
      expect(state.activeSlot, DriverSlot.primary);
    });
  });

  group('JSON round-trip (SecureVault)', () {
    test('holat yozilib qayta o\'qilganda o\'zgarmaydi', () {
      final DualSessionState before = SessionPolicy.leaveTruck(_bothSignedIn()).state;
      final DualSessionState after = DualSessionState.fromJson(before.toJson());

      expect(after, before);
    });

    test('bo\'sh JSON — signedOut', () {
      expect(
        DualSessionState.fromJson(const <String, Object?>{}),
        const DualSessionState.signedOut(),
      );
    });
  });

  test('toString PII chiqarmaydi (M159)', () {
    expect(_bothSignedIn().toString(), isNot(contains('Maria')));
    expect(_bothSignedIn().toString(), contains('drv-2'));
  });
}
