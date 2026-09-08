@Timeout(Duration(seconds: 60))
/// `P/E/T/L/R/S/O` detektori (tz-mobile §10.6, M77, M78).
library;

import 'package:eld_mobile/core/eld/eld_codes.dart';
import 'package:eld_mobile/core/eld/eld_malfunction_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const EldMalfunctionDetector detector = EldMalfunctionDetector();
  final DateTime now = DateTime.utc(2026, 9, 7, 12);

  /// «Hammasi joyida» bazasi — har test faqat bitta shartni buzadi.
  EldFaultSnapshot healthy({
    bool connected = true,
    bool moving = false,
    Duration skew = Duration.zero,
    DateTime? push,
    double storage = 1,
    bool? ignition,
    Set<EldFaultCode> reported = const <EldFaultCode>{},
  }) => EldFaultSnapshot(
    now: now,
    connected: connected,
    moving: moving,
    clockSkew: skew,
    lastEcmFrameAt: now.subtract(const Duration(seconds: 5)),
    lastPositionAt: now.subtract(const Duration(seconds: 5)),
    lastPowerFrameAt: now.subtract(const Duration(seconds: 5)),
    lastSuccessfulPushAt: push ?? now.subtract(const Duration(minutes: 1)),
    storageFreeFraction: storage,
    ignitionOn: ignition,
    deviceReported: reported,
  );

  test('sog\'lom holatda kod yo\'q', () {
    expect(detector.evaluate(healthy(ignition: true)), isEmpty);
  });

  group('T — timing (§7.2)', () {
    test('10 daqiqadan katta skew — malfunction', () {
      final EldFault? fault = detector.evaluate(
        healthy(skew: const Duration(minutes: 11)),
      )[EldFaultCode.timing];
      expect(fault?.kind, EldFaultKind.malfunction);
      expect(fault?.notes, 'T:11m');
    });

    test('1–10 daqiqa — diagnostic', () {
      final EldFault? fault = detector.evaluate(
        healthy(skew: const Duration(minutes: 3)),
      )[EldFaultCode.timing];
      expect(fault?.kind, EldFaultKind.diagnostic);
    });

    test('manfiy skew ham hisoblanadi', () {
      expect(
        detector.evaluate(healthy(skew: const Duration(minutes: -20)))[EldFaultCode.timing]?.kind,
        EldFaultKind.malfunction,
      );
    });
  });

  group('S — data transfer (M78)', () {
    test('8 kundan ortiq push yo\'q — malfunction', () {
      final EldFault? fault = detector.evaluate(
        healthy(push: now.subtract(const Duration(days: 9))),
      )[EldFaultCode.dataTransfer];
      expect(fault?.kind, EldFaultKind.malfunction);
      expect(fault?.detail, '9');
    });

    test('3–8 kun — diagnostic', () {
      expect(
        detector
            .evaluate(
              healthy(push: now.subtract(const Duration(days: 4))),
            )[EldFaultCode.dataTransfer]
            ?.kind,
        EldFaultKind.diagnostic,
      );
    });

    test('ELD ulanmagan bo\'lsa ham hisoblanadi', () {
      expect(
        detector.evaluate(healthy(connected: false, push: now.subtract(const Duration(days: 30)))),
        contains(EldFaultCode.dataTransfer),
      );
    });
  });

  test('R — bo\'sh joy 2% dan kam', () {
    expect(
      detector.evaluate(healthy(storage: 0.01))[EldFaultCode.dataRecording]?.kind,
      EldFaultKind.malfunction,
    );
    expect(detector.evaluate(healthy(storage: 0.05)), isNot(contains(EldFaultCode.dataRecording)));
  });

  test('E — ulangan, lekin ECM kadri 5 daqiqadan uzoq yo\'q', () {
    final EldFaultSnapshot snapshot = EldFaultSnapshot(
      now: now,
      connected: true,
      lastEcmFrameAt: now.subtract(const Duration(minutes: 6)),
      lastPositionAt: now,
      lastPowerFrameAt: now,
      lastSuccessfulPushAt: now,
    );
    expect(detector.evaluate(snapshot), contains(EldFaultCode.engineSync));
  });

  test('L — harakatda pozitsiya yo\'q; to\'xtaganda kod chiqmaydi', () {
    EldFaultSnapshot snapshot({required bool moving}) => EldFaultSnapshot(
      now: now,
      connected: true,
      moving: moving,
      lastEcmFrameAt: now,
      lastPositionAt: now.subtract(const Duration(minutes: 6)),
      lastPowerFrameAt: now,
      lastSuccessfulPushAt: now,
    );

    expect(detector.evaluate(snapshot(moving: true)), contains(EldFaultCode.positioning));
    expect(detector.evaluate(snapshot(moving: false)), isNot(contains(EldFaultCode.positioning)));
  });

  test('P — ignition yoqiq, quvvat kadri 30 daqiqadan uzoq yo\'q', () {
    final EldFaultSnapshot snapshot = EldFaultSnapshot(
      now: now,
      connected: true,
      ignitionOn: true,
      lastEcmFrameAt: now,
      lastPositionAt: now,
      lastPowerFrameAt: now.subtract(const Duration(minutes: 31)),
      lastSuccessfulPushAt: now,
    );
    expect(detector.evaluate(snapshot)[EldFaultCode.power]?.kind, EldFaultKind.malfunction);
  });

  test('O — qurilma o\'zi xabar qilgan kod har doim malfunction', () {
    final Map<EldFaultCode, EldFault> out = detector.evaluate(
      healthy(reported: <EldFaultCode>{EldFaultCode.other}),
    );
    expect(out[EldFaultCode.other]?.kind, EldFaultKind.malfunction);
  });

  test('malfunction diagnostic ustidan ustun', () {
    // Qurilma `T` ni malfunction deb bergan, skew esa faqat diagnostic.
    final Map<EldFaultCode, EldFault> out = detector.evaluate(
      healthy(skew: const Duration(minutes: 3), reported: <EldFaultCode>{EldFaultCode.timing}),
    );
    expect(out[EldFaultCode.timing]?.kind, EldFaultKind.malfunction);
  });

  test('ulanmagan holda E/L/P tekshirilmaydi', () {
    final EldFaultSnapshot snapshot = EldFaultSnapshot(
      now: now,
      moving: true,
      ignitionOn: true,
      lastSuccessfulPushAt: now,
    );
    final Map<EldFaultCode, EldFault> out = detector.evaluate(snapshot);
    expect(out, isNot(contains(EldFaultCode.engineSync)));
    expect(out, isNot(contains(EldFaultCode.positioning)));
    expect(out, isNot(contains(EldFaultCode.power)));
  });

  test('kod harflari wire formatda o\'zgarmaydi', () {
    expect(
      EldFaultCode.values.map((EldFaultCode c) => c.letter).join(),
      'PETLRSO',
      reason: 'harflar FMCSA Appendix A dan — o\'zgartirish taqiq',
    );
    expect(EldFaultCode.fromLetter('t'), EldFaultCode.timing);
    expect(EldFaultCode.fromLetter('X'), isNull);
  });
}
