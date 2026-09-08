@Timeout(Duration(seconds: 60))
/// Fon rejimi (tz-mobile §10.4): **M73** haydashda to'xtamaslik,
/// **M74** state restoration, adaptiv GPS profili (risk R6).
library;

import 'package:eld_mobile/core/background/background_coordinator.dart';
import 'package:eld_mobile/core/background/background_service.dart';
import 'package:eld_mobile/core/background/eld_task_handler.dart';
import 'package:eld_mobile/core/background/state_restoration.dart';
import 'package:eld_mobile/core/eld/eld_models.dart';
import 'package:eld_mobile/core/eld/motion_detector.dart';
import 'package:eld_mobile/core/location/location_models.dart';
import 'package:eld_mobile/core/location/mock_location_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  const BackgroundNotification offDuty = BackgroundNotification(
    title: 'Off Duty',
    body: 'Driving Time Left — 11:00',
  );
  const BackgroundNotification driving = BackgroundNotification(
    title: 'Driving',
    body: 'Driving Time Left — 08:00',
  );

  group('M73 — haydashda xizmat to\'xtamaydi', () {
    late NoopBackgroundService service;
    late MockLocationService location;
    late BackgroundCoordinator coordinator;

    setUp(() {
      service = NoopBackgroundService();
      location = MockLocationService(now: () => t0);
      coordinator = BackgroundCoordinator(service: service, location: location);
    });

    tearDown(() async {
      await coordinator.dispose();
      await location.dispose();
      await service.dispose();
    });

    test('haydash rejimida stop() rad etiladi', () async {
      await coordinator.start(driving);
      await coordinator.setDriving(true);

      expect(await coordinator.stop(), isFalse);
      expect(service.refusedStops, 1);
      expect(await service.isRunning, isTrue);
    });

    test('haydash tugagach to\'xtatish mumkin', () async {
      await coordinator.start(driving);
      await coordinator.setDriving(true);
      await coordinator.setDriving(false);

      expect(await coordinator.stop(), isTrue);
      expect(await service.isRunning, isFalse);
    });

    test('bildirishnoma matni yangilanadi', () async {
      await coordinator.start(offDuty);
      expect(service.lastNotification, offDuty);

      await coordinator.updateNotification(driving);
      expect(service.lastNotification, driving);
    });

    test('R6: GPS profili haydash holatiga qarab almashadi', () async {
      await coordinator.start(offDuty);
      expect(coordinator.locationProfile, LocationProfile.stationary);

      await coordinator.setDriving(true);
      expect(coordinator.locationProfile, LocationProfile.driving);
      expect(location.profile, LocationProfile.driving);
    });

    test('auto-DR oqimi haydash bayrog\'ini yoqadi', () async {
      final MotionDetector detector = MotionDetector();
      addTearDown(detector.dispose);
      coordinator.attachMotion(detector.events);
      await coordinator.start(offDuty);

      for (int s = 0; s <= 4; s++) {
        detector.onFrame(EldTelemetryFrameStub.moving(t0.add(Duration(seconds: s))));
      }
      await Future<void>.delayed(Duration.zero);

      expect(coordinator.driving, isTrue);
      expect(await coordinator.stop(), isFalse, reason: 'M73');
    });
  });

  group('M74 — state restoration', () {
    test('tiklanishda callback bir marta ishlaydi', () async {
      final List<RestoreReason> seen = <RestoreReason>[];
      final StateRestorationCoordinator coordinator = StateRestorationCoordinator(
        onRestored: (RestoreReason reason) async => seen.add(reason),
      );
      addTearDown(coordinator.dispose);

      await coordinator.notify(RestoreReason.iosBleRestore);
      await coordinator.notify(RestoreReason.iosBleRestore);

      expect(seen, <RestoreReason>[RestoreReason.iosBleRestore]);
      expect(coordinator.handled(RestoreReason.iosBleRestore), isTrue);
      expect(coordinator.handledCount, 1);
    });

    test('turli sabablar alohida ishlanadi', () async {
      final List<RestoreReason> seen = <RestoreReason>[];
      final StateRestorationCoordinator coordinator = StateRestorationCoordinator(
        onRestored: (RestoreReason reason) async => seen.add(reason),
      );
      addTearDown(coordinator.dispose);

      await coordinator.notify(RestoreReason.androidServiceRestart);
      await coordinator.notify(RestoreReason.coldStart);

      expect(seen, hasLength(2));
    });

    test('reset() yangi sessiya uchun hisobni tozalaydi', () async {
      int calls = 0;
      final StateRestorationCoordinator coordinator = StateRestorationCoordinator(
        onRestored: (RestoreReason _) async => calls++,
      );
      addTearDown(coordinator.dispose);

      await coordinator.notify(RestoreReason.iosBleRestore);
      coordinator.reset();
      await coordinator.notify(RestoreReason.iosBleRestore);

      expect(calls, 2);
    });

    test('M74: callback kutiladi (unawaited emas)', () async {
      bool finished = false;
      final StateRestorationCoordinator coordinator = StateRestorationCoordinator(
        onRestored: (RestoreReason _) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          finished = true;
        },
      );
      addTearDown(coordinator.dispose);

      await coordinator.notify(RestoreReason.iosBleRestore);
      expect(finished, isTrue);
    });
  });

  group('isolate xabarlari', () {
    test('bildirishnoma kodlanadi va qayta o\'qiladi', () {
      final String encoded = EldTaskMessage.encodeNotification('On Duty', 'Left — 08:00');
      expect(EldTaskMessage.decodeNotification(encoded), ('On Duty', 'Left — 08:00'));
    });

    test('tick ISO-8601 UTC da', () {
      final String encoded = EldTaskMessage.encodeTick(t0);
      expect(EldTaskMessage.decodeTick(encoded), t0);
    });

    test('noto\'g\'ri format null qaytaradi', () {
      expect(EldTaskMessage.decodeNotification('rubbish'), isNull);
      expect(EldTaskMessage.decodeTick(42), isNull);
    });

    test('R6: fon tiki 30 s — telemetriya batchlanadi', () {
      expect(kEldForegroundTickInterval, const Duration(seconds: 30));
    });
  });
}

/// Testda ishlatiladigan minimal telemetriya kadri.
abstract final class EldTelemetryFrameStub {
  const EldTelemetryFrameStub._();

  static EldTelemetryFrame moving(DateTime at) =>
      EldTelemetryFrame(at: at, speedKmh: 40, lat: 41.3, lng: 69.2);
}
