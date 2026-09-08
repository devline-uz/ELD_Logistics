// NFR — 14 kunlik eventlarni to'liq qayta hisoblash <= 50 ms (hos-parity skill,
// tz-mobile §19). O'lchov: computeCounters + dayTotals + violations + recap.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'helpers.dart';

/// 14 kun x 24 event/kun = 336 duty event + har soatda `intermediate`.
List<HosEvent> _fourteenDays() {
  final events = <HosEvent>[];
  final base = at('2026-01-02T00:00:00Z');
  const cycle = <DutyStatus>[
    DutyStatus.off,
    DutyStatus.on,
    DutyStatus.dr,
    DutyStatus.dr,
    DutyStatus.off,
    DutyStatus.dr,
    DutyStatus.sb,
    DutyStatus.off,
  ];
  for (var d = 0; d < 14; d++) {
    for (var i = 0; i < 24; i++) {
      final t = base.add(Duration(days: d, hours: i));
      events.add(
        HosEvent(time: t, status: cycle[(d + i) % cycle.length], type: EventType.statusChange),
      );
      // Haydash paytidagi 60 daqiqalik `intermediate` eventlar — duty
      // mashinasiga ta'sir qilmaydi, lekin filtrlanishi kerak.
      events.add(
        HosEvent(
          time: t.add(const Duration(minutes: 30)),
          status: DutyStatus.dr,
          type: EventType.intermediate,
        ),
      );
    }
  }
  return events;
}

void main() {
  tzdata.initializeTimeZones();

  test('14 days of events recompute in <= 50 ms', () {
    final events = _fourteenDays();
    expect(events.length, 14 * 24 * 2);
    final p = defaultPolicy();
    final now = at('2026-01-16T00:00:00Z');
    final day = at('2026-01-15T12:00:00Z');

    void run() {
      computeCounters(events, p, now, chicago);
      dayTotals(events, day, chicago, policy: p);
      violations(events, p, day, chicago);
      recap(events, p, day, chicago);
    }

    // Isitish (JIT) — o'lchov barqaror bo'lishi uchun.
    for (var i = 0; i < 5; i++) {
      run();
    }

    final sw = Stopwatch()..start();
    const iterations = 20;
    for (var i = 0; i < iterations; i++) {
      run();
    }
    sw.stop();
    final perRun = sw.elapsedMicroseconds / iterations / 1000.0;
    // ignore: avoid_print
    printOnFailure('full recompute: ${perRun.toStringAsFixed(2)} ms');
    expect(
      perRun,
      lessThanOrEqualTo(50.0),
      reason: '14 kunlik to\'liq qayta hisoblash ${perRun}ms > 50ms',
    );
  });

  test('out-of-order input is sorted without mutating the caller list', () {
    final events = _fourteenDays().reversed.toList();
    final snapshot = List<HosEvent>.of(events);
    computeCounters(events, defaultPolicy(), at('2026-01-16T00:00:00Z'), chicago);
    for (var i = 0; i < events.length; i++) {
      expect(identical(events[i], snapshot[i]), isTrue);
    }
  });
}
