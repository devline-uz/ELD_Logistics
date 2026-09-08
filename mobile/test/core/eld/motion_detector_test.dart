@Timeout(Duration(seconds: 60))
/// Auto-DR detektori (tz-mobile §9, M56–M62).
///
/// Detektor **taymersiz**: `onFrame` va `tick` qo'lda chaqiriladi, shuning
/// uchun testlar deterministik.
library;

import 'package:eld_mobile/core/eld/eld_models.dart';
import 'package:eld_mobile/core/eld/motion_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late MotionDetector detector;
  late List<MotionEvent> events;

  setUp(() {
    detector = MotionDetector();
    events = <MotionEvent>[];
    detector.events.listen(events.add);
  });

  tearDown(() => detector.dispose());

  EldTelemetryFrame frame(int second, double speed) => EldTelemetryFrame(
    at: t0.add(Duration(seconds: second)),
    speedKmh: speed,
    lat: 41.311081,
    lng: 69.240562,
    odometerM: 812_450_000 + second * 10,
    engineHours: 4821.5,
  );

  /// Oqim `broadcast` — hodisalar mikrotaskda yetib boradi.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('harakat (M56)', () {
    test('8 km/h dan yuqori tezlik 3 s tasdiqlansa DR', () async {
      for (int s = 0; s <= 3; s++) {
        detector.onFrame(frame(s, 24));
      }
      await settle();

      expect(detector.phase, MotionPhase.moving);
      expect(events.map((MotionEvent e) => e.type), <MotionEventType>[
        MotionEventType.movingConfirmed,
      ]);
      expect(events.single.speedKmh, 24);
      expect(events.single.odometerM, isNotNull);
    });

    test('3 s dan qisqa harakat DR bermaydi', () async {
      detector.onFrame(frame(0, 24));
      detector.onFrame(frame(2, 24));
      await settle();

      expect(detector.phase, MotionPhase.movingPending);
      expect(events, isEmpty);
    });

    test('chegaradan past tezlik hisoblanmaydi', () async {
      for (int s = 0; s <= 5; s++) {
        detector.onFrame(frame(s, 6));
      }
      await settle();
      expect(events, isEmpty);
    });

    test('siyosat chegarasi sync/pull dan yangilanadi', () async {
      detector.policy = const MotionPolicy(motionThresholdKmh: 30);
      for (int s = 0; s <= 4; s++) {
        detector.onFrame(frame(s, 24));
      }
      await settle();
      expect(events, isEmpty);
    });

    test('M57: PC rejimida harakat DR yozmaydi', () async {
      detector.suppressed = true;
      for (int s = 0; s <= 4; s++) {
        detector.onFrame(frame(s, 40));
      }
      await settle();

      expect(detector.phase, MotionPhase.moving);
      expect(events, isEmpty);
    });
  });

  group('to\'xtash (M59)', () {
    test('tezlik 0 va 3 s — stopped', () async {
      for (int s = 0; s <= 3; s++) {
        detector.onFrame(frame(s, 24));
      }
      for (int s = 4; s <= 7; s++) {
        detector.onFrame(frame(s, 0));
      }
      await settle();

      expect(detector.phase, MotionPhase.stopped);
      expect(events.map((MotionEvent e) => e.type), <MotionEventType>[
        MotionEventType.movingConfirmed,
        MotionEventType.stopped,
      ]);
      expect(events.last.speedKmh, 0);
    });

    test('0 dan katta, chegaradan kichik tezlik to\'xtash emas', () async {
      for (int s = 0; s <= 3; s++) {
        detector.onFrame(frame(s, 24));
      }
      for (int s = 4; s <= 10; s++) {
        detector.onFrame(frame(s, 3));
      }
      await settle();

      expect(events.map((MotionEvent e) => e.type), <MotionEventType>[
        MotionEventType.movingConfirmed,
      ]);
    });
  });

  group('idle prompt (M60–M62)', () {
    /// To'xtagan holatga olib keladigan umumiy boshlanish.
    void driveThenStop() {
      for (int s = 0; s <= 3; s++) {
        detector.onFrame(frame(s, 24));
      }
      for (int s = 4; s <= 7; s++) {
        detector.onFrame(frame(s, 0));
      }
    }

    test('5 daqiqadan keyin so\'rov chiqadi', () async {
      driveThenStop();
      detector.tick(t0.add(const Duration(seconds: 7, minutes: 5)));
      await settle();

      expect(events.last.type, MotionEventType.idlePromptDue);
    });

    test('M60: javob bo\'lmasa event vaqti = so\'rov chiqqan payt', () async {
      driveThenStop();
      final DateTime promptAt = t0.add(const Duration(seconds: 7, minutes: 5));
      detector.tick(promptAt);
      detector.tick(promptAt.add(const Duration(minutes: 1)));
      await settle();

      final MotionEvent last = events.last;
      expect(last.type, MotionEventType.idleNoAnswer);
      expect(last.at, promptAt, reason: 'FMCSA 5+1: vaqt to\'xtash payti EMAS');
      expect(last.promptIssuedAt, promptAt);
    });

    test('`Yes, driving` taymerni nolga tushiradi', () async {
      driveThenStop();
      final DateTime promptAt = t0.add(const Duration(seconds: 7, minutes: 5));
      detector.tick(promptAt);
      detector.answerStillDriving();
      detector.tick(promptAt.add(const Duration(minutes: 2)));
      await settle();

      expect(events.map((MotionEvent e) => e.type), isNot(contains(MotionEventType.idleNoAnswer)));
    });

    test('`No` javobidan keyin avtomatik ON yozilmaydi', () async {
      driveThenStop();
      final DateTime promptAt = t0.add(const Duration(seconds: 7, minutes: 5));
      detector.tick(promptAt);
      detector.answerNotDriving();
      detector.tick(promptAt.add(const Duration(minutes: 5)));
      await settle();

      expect(events.map((MotionEvent e) => e.type), isNot(contains(MotionEventType.idleNoAnswer)));
    });

    test('qayta harakat boshlansa idle hisoblagichi tozalanadi', () async {
      driveThenStop();
      for (int s = 8; s <= 12; s++) {
        detector.onFrame(frame(s, 30));
      }
      detector.tick(t0.add(const Duration(minutes: 10)));
      await settle();

      expect(events.map((MotionEvent e) => e.type), isNot(contains(MotionEventType.idlePromptDue)));
    });

    test('reset() holatni tozalaydi', () async {
      driveThenStop();
      detector.reset();
      detector.tick(t0.add(const Duration(minutes: 30)));
      await settle();

      expect(detector.phase, MotionPhase.idle);
      expect(events.map((MotionEvent e) => e.type), isNot(contains(MotionEventType.idlePromptDue)));
    });
  });
}
