// M173/P5 — 35/35 golden vektor. Bu test Go `TestGoldenVectors` bilan bir xil
// faylni, bir xil tekshiruvlar bilan o'qiydi. Bitta vektor yiqilsa bosqich
// yopilmagan hisoblanadi; `skip` yoki vektorni o'chirish TAQIQ.
import 'package:hos_engine/hos_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'vectors.dart';

void main() {
  tzdata.initializeTimeZones();
  final source = loadVectors();

  test('vektor fayli kontrakti', () {
    expect(source.version, 1, reason: 'vector file version');
    expect(source.vectors.length, 35, reason: '35/35 talab qilinadi (P5); ${source.path}');
    final names = source.vectors.map((v) => v['name'] as String).toList();
    expect(names.toSet().length, names.length, reason: 'nomlar unikal');
  });

  group('golden vectors', () {
    for (final v in source.vectors) {
      final name = v['name'] as String;
      test(name, () {
        final location = tz.getLocation(v['timezone'] as String);
        final policy = parsePolicy((v['policy'] as Map?)?.cast<String, dynamic>());
        final now = DateTime.parse(v['now'] as String).toUtc();
        final dayStr = v['day'] as String?;
        final DateTime day;
        if (dayStr != null && dayStr.isNotEmpty) {
          final parts = dayStr.split('-').map(int.parse).toList();
          day = tz.TZDateTime(location, parts[0], parts[1], parts[2]);
        } else {
          day = now;
        }
        final events = (v['events'] as List)
            .map((e) => HosEvent.fromJson((e as Map).cast<String, dynamic>()))
            .toList(growable: false);
        final before = events.length;
        final identities = List<HosEvent>.of(events);

        final expect_ = (v['expect'] as Map).cast<String, dynamic>();
        final wantCounters = (expect_['counters'] as Map).cast<String, dynamic>();
        final wantTotals = (expect_['totals'] as Map).cast<String, dynamic>();
        final wantViolations = (expect_['violations'] as List)
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList(growable: false);

        final got = computeCounters(events, policy, now, location);
        expect(got.breakLeftMin, wantCounters['break_left_min'], reason: 'break_left_min');
        expect(got.driveLeftMin, wantCounters['drive_left_min'], reason: 'drive_left_min');
        expect(got.shiftLeftMin, wantCounters['shift_left_min'], reason: 'shift_left_min');
        expect(got.cycleLeftMin, wantCounters['cycle_left_min'], reason: 'cycle_left_min');
        if (wantCounters.containsKey('driving_time_left_min')) {
          expect(
            got.drivingTimeLeftMin,
            wantCounters['driving_time_left_min'],
            reason: 'driving_time_left_min',
          );
        }

        final totals = dayTotals(events, day, location, policy: policy);
        expect(totals.offMin, wantTotals['off_min'], reason: 'off_min');
        expect(totals.sbMin, wantTotals['sb_min'], reason: 'sb_min');
        expect(totals.driveMin, wantTotals['drive_min'], reason: 'drive_min');
        expect(totals.onMin, wantTotals['on_min'], reason: 'on_min');

        // Go: totals must add up to the real length of the log day (23h/25h).
        final range = dayRange(day, location);
        expect(
          totals.total,
          utcOf(range.end).difference(utcOf(range.start)),
          reason: 'totals sum must equal the log day length',
        );

        final vio = violations(events, policy, day, location);
        expect(
          vio.map((e) => '${e.type}/${e.severity}').toList(),
          wantViolations.map((e) => '${e['type']}/${e['severity']}').toList(),
          reason: 'violations (tartibi bilan)',
        );
        for (final e in vio) {
          expect(e.occurredAt, isNotNull, reason: '${e.type} vaqtsiz');
        }

        // Go: TestOutOfOrderEventsAreNotMutated ekvivalenti.
        expect(events.length, before, reason: 'kirish ro\'yxati o\'zgardi');
        for (var i = 0; i < events.length; i++) {
          expect(
            identical(events[i], identities[i]),
            isTrue,
            reason: 'kirish elementi almashtirildi',
          );
        }
      });
    }
  });
}
