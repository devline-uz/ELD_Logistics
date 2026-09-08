// 14 kunlik eventlar uchun to'liq qayta hisoblash vaqtini o'lchaydi (NFR <=50ms).
// Ishlatish: dart run tool/bench.dart
import 'package:hos_engine/hos_engine.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();
  final loc = tz.getLocation('America/Chicago');
  final base = DateTime.utc(2026, 1, 2);
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
  final events = <HosEvent>[];
  for (var d = 0; d < 14; d++) {
    for (var i = 0; i < 24; i++) {
      final t = base.add(Duration(days: d, hours: i));
      events
        ..add(
          HosEvent(time: t, status: cycle[(d + i) % cycle.length], type: EventType.statusChange),
        )
        ..add(
          HosEvent(
            time: t.add(const Duration(minutes: 30)),
            status: DutyStatus.dr,
            type: EventType.intermediate,
          ),
        );
    }
  }

  final p = defaultPolicy();
  final now = DateTime.utc(2026, 1, 16);
  final day = DateTime.utc(2026, 1, 15, 12);
  void run() {
    computeCounters(events, p, now, loc);
    dayTotals(events, day, loc, policy: p);
    violations(events, p, day, loc);
    recap(events, p, day, loc);
  }

  for (var i = 0; i < 20; i++) {
    run();
  }
  final sw = Stopwatch()..start();
  const n = 100;
  for (var i = 0; i < n; i++) {
    run();
  }
  sw.stop();
  final ms = sw.elapsedMicroseconds / n / 1000.0;
  // ignore: avoid_print
  print(
    'events=${events.length} full recompute=${ms.toStringAsFixed(2)} ms '
    '(limit 50 ms)',
  );
}
