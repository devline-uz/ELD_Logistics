@Timeout(Duration(seconds: 60))
/// `M-15` va `M-16` testlari (tz-mobile §9.4–§9.7).
library;

import 'dart:async';

import 'package:eld_mobile/core/eld/motion_detector.dart';
import 'package:eld_mobile/core/location/location_models.dart';
import 'package:eld_mobile/core/ui/components/components.dart';
import 'package:eld_mobile/features/drive_mode/domain/idle_alert.dart';
import 'package:eld_mobile/features/drive_mode/presentation/controllers/drive_mode_controller.dart';
import 'package:eld_mobile/features/drive_mode/presentation/screens/drive_mode_screen.dart';
import 'package:eld_mobile/features/drive_mode/presentation/widgets/idle_prompt_dialog.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../duty_status/duty_test_harness.dart';

/// Riverpod oqim obunasi va `await` zanjiri yakunlanishini kutadi.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

Finder appButton(String label) =>
    find.ancestor(of: find.text(label), matching: find.bySubtype<AppButton>());

void main() {
  late FakeDutyStatusRepository duty;
  late StreamController<MotionEvent> motion;
  late NoopIdleAlertNotifier alerts;

  setUp(() {
    duty = FakeDutyStatusRepository(context: testContext(status: DutyStatusValue.driving));
    motion = StreamController<MotionEvent>.broadcast();
    alerts = NoopIdleAlertNotifier();
  });

  tearDown(() async {
    await motion.close();
    await duty.dispose();
  });

  ProviderContainer buildContainer({DutyStatusContext? context}) {
    final ProviderContainer container = ProviderContainer(
      overrides: m4Overrides(duty: duty, context: context, motion: motion.stream, alerts: alerts),
    );
    addTearDown(container.dispose);
    return container;
  }

  group('M-15 Drive mode', () {
    testWidgets('to\'la: `In-motion`, qolgan haydash vaqti va joylashuv', (
      WidgetTester tester,
    ) async {
      await pumpM4(
        tester,
        child: const DriveModeScreen(),
        overrides: m4Overrides(
          duty: duty,
          context: testContext(status: DutyStatusValue.driving),
          motion: motion.stream,
          alerts: alerts,
          place: const GeocodedPlace(label: '342, Plot B'),
        ),
      );
      expect(find.text('Duty Hours'), findsOneWidget);
      expect(find.text('Driving Time Left'), findsOneWidget);
      // `drivingTimeLeftMin: 152` → `02:32:00`.
      expect(find.text('02:32:00'), findsOneWidget);
      expect(find.text('342, Plot B'), findsOneWidget);
    });

    testWidgets('bo\'sh: joylashuv yo\'q — `N/A`', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const DriveModeScreen(),
        overrides: m4Overrides(duty: duty, motion: motion.stream, alerts: alerts),
      );
      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('M58: faqat `Off Duty` va `On Duty` tugmalari bor', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const DriveModeScreen(),
        overrides: m4Overrides(duty: duty, motion: motion.stream, alerts: alerts),
      );
      expect(appButton('Off Duty'), findsOneWidget);
      expect(appButton('On Duty'), findsOneWidget);
      expect(find.text('Sleeper Berth'), findsNothing);
    });

    testWidgets('M59: to\'xtash aniqlanganda `You have stopped`', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const DriveModeScreen(),
        overrides: m4Overrides(
          duty: duty,
          context: testContext(status: DutyStatusValue.driving),
          motion: motion.stream,
          alerts: alerts,
        ),
      );
      expect(find.text('In-motion'), findsOneWidget);

      motion.add(MotionEvent(type: MotionEventType.stopped, at: kTestNow));
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.text('You have stopped'), findsOneWidget);
    });
  });

  group('M-16 Idle prompt', () {
    testWidgets('to\'la: modal va M61 kanonik tugma matni', (WidgetTester tester) async {
      await pumpM4(
        tester,
        child: const DriveModeScreen(),
        overrides: m4Overrides(
          duty: duty,
          context: testContext(status: DutyStatusValue.driving),
          motion: motion.stream,
          alerts: alerts,
        ),
      );
      motion.add(MotionEvent(type: MotionEventType.idlePromptDue, at: kTestNow));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.byType(IdlePromptOverlay), findsOneWidget);
      expect(find.text("You've been idle for 5 minutes. Are you still driving?"), findsOneWidget);
      expect(find.text('Yes, driving'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(alerts.shown, hasLength(1));
    });

    testWidgets('`Yes, driving` modalni yopadi, status `DR` da qoladi', (
      WidgetTester tester,
    ) async {
      await pumpM4(
        tester,
        child: const DriveModeScreen(),
        overrides: m4Overrides(
          duty: duty,
          context: testContext(status: DutyStatusValue.driving),
          motion: motion.stream,
          alerts: alerts,
        ),
      );
      motion.add(MotionEvent(type: MotionEventType.idlePromptDue, at: kTestNow));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.tap(appButton('Yes, driving'));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.byType(IdlePromptOverlay), findsNothing);
      expect(duty.changes, isEmpty);
    });
  });

  group('Kontroller mantiqi', () {
    test('M56: harakat tasdiqlanganda `DR` avtomatik yoziladi', () async {
      final ProviderContainer container = buildContainer(
        context: testContext(status: DutyStatusValue.on),
      );
      container.listen<DriveModeState>(
        driveModeControllerProvider,
        (DriveModeState? previous, DriveModeState next) {},
      );
      await settle();
      motion.add(MotionEvent(type: MotionEventType.movingConfirmed, at: kTestNow, speedKmh: 20));
      await settle();

      expect(duty.changes, hasLength(1));
      expect(duty.changes.single.draft.status, DutyStatusValue.driving);
      expect(duty.changes.single.origin, EventOrigin.auto);
    });

    test('PC rejimida harakat `DR` yozmaydi (tz-mobile §9.4)', () async {
      final ProviderContainer container = buildContainer(
        context: testContext(status: DutyStatusValue.off, special: DutySpecial.personalConveyance),
      );
      container.listen<DriveModeState>(
        driveModeControllerProvider,
        (DriveModeState? previous, DriveModeState next) {},
      );
      await settle();
      motion.add(MotionEvent(type: MotionEventType.movingConfirmed, at: kTestNow, speedKmh: 30));
      await settle();

      expect(duty.changes, isEmpty);
    });

    test('M60: javob bo\'lmasa `ON` eventi so\'rov chiqqan paytga yoziladi', () async {
      final DateTime issuedAt = kTestNow.subtract(const Duration(minutes: 1));
      final ProviderContainer container = buildContainer(
        context: testContext(status: DutyStatusValue.driving),
      );
      container.listen<DriveModeState>(
        driveModeControllerProvider,
        (DriveModeState? previous, DriveModeState next) {},
      );
      await settle();
      motion.add(
        MotionEvent(type: MotionEventType.idleNoAnswer, at: kTestNow, promptIssuedAt: issuedAt),
      );
      await settle();

      expect(duty.changes, hasLength(1));
      expect(duty.changes.single.draft.status, DutyStatusValue.on);
      expect(duty.changes.single.at, issuedAt);
    });

    test('M60: `No` javobi ham so\'rov chiqqan paytni ishlatadi', () async {
      final DateTime issuedAt = kTestNow.subtract(const Duration(minutes: 3));
      final ProviderContainer container = buildContainer(
        context: testContext(status: DutyStatusValue.driving),
      );
      container.listen<DriveModeState>(
        driveModeControllerProvider,
        (DriveModeState? previous, DriveModeState next) {},
      );
      await settle();
      motion.add(MotionEvent(type: MotionEventType.idlePromptDue, at: issuedAt));
      await settle();

      await container.read(driveModeControllerProvider.notifier).answerNotDriving();

      expect(duty.changes.single.draft.status, DutyStatusValue.on);
      expect(duty.changes.single.at, issuedAt);
      expect(alerts.visible, isFalse);
    });

    test('M58: qo\'lda `Off Duty` ga o\'tish ruxsat etiladi', () async {
      final ProviderContainer container = buildContainer(
        context: testContext(status: DutyStatusValue.driving),
      );
      await container.read(driveModeControllerProvider.notifier).changeStatus(DutyStatusValue.off);

      expect(duty.changes.single.draft.status, DutyStatusValue.off);
    });

    test('M51: `DR` ni qo\'lda tanlash e\'tiborsiz qoldiriladi', () async {
      final ProviderContainer container = buildContainer(
        context: testContext(status: DutyStatusValue.on),
      );
      await container
          .read(driveModeControllerProvider.notifier)
          .changeStatus(DutyStatusValue.driving);

      expect(duty.changes, isEmpty);
    });
  });
}
