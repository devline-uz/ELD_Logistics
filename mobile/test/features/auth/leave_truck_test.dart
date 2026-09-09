@Timeout(Duration(seconds: 60))
/// `Leave Truck` / `Return to truck` / to'liq `Logout` oqimi (§4.8, M18, M17).
///
/// Qadamlar tartibi `LeaveTruckPolicy.steps` da; bu yerda oqim uchdan-uchgacha
/// (OFF eventi → ELD uzilishi → `logout(pause:true)` → sessiya `paused`)
/// tekshiriladi, shu jumladan **oflayn** stsenariy.
library;

import 'package:eld_mobile/core/db/daos/outbox_dao.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/features/auth/data/auth_providers.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:eld_mobile/features/auth/domain/leave_truck_policy.dart';
import 'package:eld_mobile/features/auth/domain/session_policy.dart';
import 'package:eld_mobile/features/auth/presentation/controllers/leave_truck_controller.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../duty_status/duty_test_harness.dart';
import 'auth_test_harness.dart';
import 'session_test_fakes.dart';

ProviderContainer _container({
  required FakeDutyStatusRepository duty,
  required FakeAuthRepository auth,
  required bool paired,
  int queued = 0,
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      ...m4Overrides(duty: duty, queued: queued),
      authRepositoryProvider.overrideWithValue(auth),
      // Faol slot co-driver bo'lsa `activeAuthRepositoryProvider` shu
      // instansni oladi — tarmoq/`SecureVault` ga chiqilmaydi.
      slotAuthRepositoryProvider(DriverSlot.coDriver).overrideWithValue(auth),
      sessionManagerProvider.overrideWith(
        () => FakeSessionManager(paired ? pairedSession() : soloSession()),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// `outboxStatsProvider` — `StreamProvider`; birinchi qiymat kelmaguncha
/// `.value` `null` bo'ladi. Kontrollerni chaqirishdan oldin isitib olamiz.
Future<void> _warmOutbox(ProviderContainer container) async {
  container.listen<AsyncValue<OutboxQueueStats>>(
    outboxStatsProvider,
    (AsyncValue<OutboxQueueStats>? _, AsyncValue<OutboxQueueStats> _) {},
    fireImmediately: true,
  );
  await Future<void>.delayed(Duration.zero);
}

void main() {
  group('LeaveTruckPolicy (sof qoidalar)', () {
    test('qadamlar tartibi §4.8 ga mos', () {
      expect(LeaveTruckPolicy.steps, <LeaveTruckStep>[
        LeaveTruckStep.recordOffDuty,
        LeaveTruckStep.disconnectEld,
        LeaveTruckStep.pauseSession,
      ]);
    });

    test('co-driver bo\'lsa boshqa tasdiq matni ko\'rsatiladi', () {
      expect(LeaveTruckPolicy.prompt(hasActiveCoDriver: true), LeaveTruckPrompt.coDriverTakesOver);
      expect(LeaveTruckPolicy.prompt(hasActiveCoDriver: false), LeaveTruckPrompt.offDutyWarning);
    });

    test('M18: outbox bo\'sh bo\'lmasa logout ogohlantiradi', () {
      expect(LeaveTruckPolicy.logoutPrompt(queuedRecords: 0), LogoutPrompt.plain);
      expect(LeaveTruckPolicy.logoutPrompt(queuedRecords: 3), LogoutPrompt.unsyncedRecords);
    });
  });

  group('Leave Truck oqimi', () {
    test('yolg\'iz haydovchi: OFF eventi yoziladi va sessiya paused bo\'ladi', () async {
      final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
      addTearDown(duty.dispose);
      final FakeAuthRepository auth = FakeAuthRepository();

      final ProviderContainer container = _container(duty: duty, auth: auth, paired: false);
      final LeaveTruckOutcome outcome = await container
          .read(leaveTruckControllerProvider.notifier)
          .leaveTruck();

      expect(outcome, LeaveTruckOutcome.paused);
      expect(duty.changes.single.draft.status, DutyStatusValue.off);
      expect(auth.calls, contains('logout:true'));
      expect(container.read(sessionManagerProvider).isPaused, isTrue);
      // M18: slot bo'shatilmaydi — refresh token tirik qoladi.
      expect(container.read(sessionManagerProvider).isSignedOut, isFalse);
    });

    test('co-driver bor: u avtomatik faol bo\'ladi, ekran Home\'da qoladi', () async {
      final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
      addTearDown(duty.dispose);
      final FakeAuthRepository auth = FakeAuthRepository();

      final ProviderContainer container = _container(duty: duty, auth: auth, paired: true);
      final LeaveTruckOutcome outcome = await container
          .read(leaveTruckControllerProvider.notifier)
          .leaveTruck();

      expect(outcome, LeaveTruckOutcome.coDriverPromoted);
      expect(container.read(sessionManagerProvider).activeSlot, DriverSlot.primary);
      expect(container.read(sessionManagerProvider).active.driverName, 'John Smith');
      expect(container.read(sessionManagerProvider).isPaused, isFalse);
    });

    test('oflayn: `logout` yiqilsa ham lokal holat darhol paused', () async {
      final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
      addTearDown(duty.dispose);
      final FakeAuthRepository auth = FakeAuthRepository()
        ..logoutError = const ApiError(code: ApiErrorCode.clientNetwork, message: 'offline');

      final ProviderContainer container = _container(duty: duty, auth: auth, paired: false);
      final LeaveTruckOutcome outcome = await container
          .read(leaveTruckControllerProvider.notifier)
          .leaveTruck();

      expect(outcome, LeaveTruckOutcome.paused);
      expect(container.read(sessionManagerProvider).isPaused, isTrue);
      // Oflayn xato foydalanuvchiga ko'rsatilmaydi — bu kutilgan holat.
      expect(container.read(leaveTruckControllerProvider).error, isNull);
    });
  });

  group('Return to truck', () {
    test('PIN dan keyin sessiya yana faol bo\'ladi', () async {
      final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
      addTearDown(duty.dispose);
      final FakeAuthRepository auth = FakeAuthRepository();

      final ProviderContainer container = _container(duty: duty, auth: auth, paired: false);
      final LeaveTruckController controller = container.read(leaveTruckControllerProvider.notifier);

      await controller.leaveTruck();
      expect(container.read(sessionManagerProvider).isPaused, isTrue);

      await controller.returnToTruck();
      expect(container.read(sessionManagerProvider).active.isActive, isTrue);
    });
  });

  group('To\'liq Logout (M17/M18)', () {
    test('sessiya bo\'shatiladi, outbox tegilmaydi', () async {
      final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
      addTearDown(duty.dispose);
      final FakeAuthRepository auth = FakeAuthRepository();

      final ProviderContainer container = _container(
        duty: duty,
        auth: auth,
        paired: false,
        queued: 4,
      );
      await _warmOutbox(container);
      final LeaveTruckController controller = container.read(leaveTruckControllerProvider.notifier);

      expect(controller.logoutPrompt(), LogoutPrompt.unsyncedRecords);
      expect(controller.queuedRecords, 4);

      await controller.logout();

      expect(auth.calls, contains('logout:false'));
      expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
      // Outbox statistikasi o'zgarmaydi — yozuvlar saqlanadi (M17).
      expect(controller.queuedRecords, 4);
    });

    // #B-1: avval server xatosi chiqishni to'xtatardi va haydovchi tugmani
    // qayta bosib `401 TOKEN_REVOKED` ga tushardi. Endi `Logout` **best-effort**
    // va **idempotent** — server javobi qanday bo'lsa ham lokal sessiya
    // tozalanadi (outbox tegilmaydi, M17).
    test('server xatosi (TOKEN_REVOKED/5xx) chiqishni to\'xtatmaydi', () async {
      final FakeDutyStatusRepository duty = FakeDutyStatusRepository();
      addTearDown(duty.dispose);
      final FakeAuthRepository auth = FakeAuthRepository()
        ..logoutError = const ApiError(code: ApiErrorCode.tokenRevoked, message: 'revoked');

      final ProviderContainer container = _container(duty: duty, auth: auth, paired: false);
      await expectLater(container.read(leaveTruckControllerProvider.notifier).logout(), completes);

      expect(auth.calls, contains('logout:false'));
      expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
      expect(container.read(leaveTruckControllerProvider).error, isNull);
    });
  });
}
