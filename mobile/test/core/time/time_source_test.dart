/// `TimeSource`: manba ustuvorligi, monotonlik, skew (§7.1, §7.2, M39–M41).

library;

import 'package:eld_mobile/core/time/clock_verdict.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late TimeSource time;
  late FakeWallClock clock;

  setUp(() {
    final ({FakeWallClock clock, TimeSource time}) built = buildTestTimeSource(t0);
    time = built.time;
    clock = built.clock;
  });

  tearDown(() => time.dispose());

  test('langarsiz holatda telefon soati ishlatiladi', () {
    expect(time.now(), t0);
    expect(time.source, EventTimeSource.phone);
    expect(time.clockSkewSec, 0);
    expect(time.reading().unverified, isTrue);
  });

  test('server sinxroni langar qo\'yadi va monoton soatga tayanadi', () {
    clock.advance(const Duration(minutes: 5));
    time.syncFromServer(t0.add(const Duration(minutes: 5, seconds: 30)));
    expect(time.source, EventTimeSource.server);

    clock.advance(const Duration(seconds: 10));
    expect(time.now(), t0.add(const Duration(minutes: 5, seconds: 40)));
    expect(time.clockSkewSec, 30);
  });

  test('ELD RTC serverdan ustun, server RTC ni almashtirmaydi (§7.1)', () {
    time.syncFromEldRtc(t0.add(const Duration(seconds: 7)));
    expect(time.source, EventTimeSource.eldRtc);

    time.syncFromServer(t0.add(const Duration(minutes: 4)));
    expect(time.source, EventTimeSource.eldRtc);
    expect(time.now(), t0.add(const Duration(seconds: 7)));

    // ELD uzilgach server langari o'rnatiladi.
    time.dropEldAnchor();
    time.syncFromServer(t0.add(const Duration(minutes: 4)));
    expect(time.source, EventTimeSource.server);
  });

  test('telefon soati orqaga surilsa event vaqti sakramaydi', () {
    time.syncFromServer(t0);
    clock.advance(const Duration(minutes: 1));
    final DateTime before = time.now();

    clock.value = t0.subtract(const Duration(hours: 5));
    final DateTime after = time.now();
    expect(after.isBefore(before), isFalse);
  });

  test('skew darajalari §7.2 chegaralariga mos', () {
    expect(ClockSkewLevel.of(const Duration(seconds: 119)), ClockSkewLevel.normal);
    expect(ClockSkewLevel.of(const Duration(seconds: 121)), ClockSkewLevel.warning);
    expect(ClockSkewLevel.of(const Duration(seconds: 601)), ClockSkewLevel.malfunction);
    expect(ClockSkewLevel.of(const Duration(seconds: -601)), ClockSkewLevel.malfunction);
  });

  test('skew darajasi o\'zgarganda oqimga xabar chiqadi', () async {
    final Future<ClockSkewLevel> next = time.skewLevelChanges.first;
    time.syncFromServer(t0.add(const Duration(minutes: 5)));
    expect(await next, ClockSkewLevel.warning);
  });

  test('M39: server verdikti kanonik — lokal hisob almashtiriladi', () {
    time.syncFromServer(t0);
    time.applyVerdict(
      const ClockVerdict(
        source: EventTimeSource.eldRtc,
        clockSkewSec: 900,
        timeUnverified: true,
        malfunctionCode: 'T',
      ),
    );
    final TimeReading reading = time.reading();
    expect(reading.source, EventTimeSource.eldRtc);
    expect(reading.clockSkewSec, 900);
    expect(reading.unverified, isTrue);
    expect(reading.level, ClockSkewLevel.malfunction);
    expect(time.verdict!.hasMalfunction, isTrue);
  });

  test('M41: clampToServer kelajakdagi vaqtni qisadi', () {
    time.syncFromServer(t0);
    expect(
      time.clampToServer(t0.add(const Duration(hours: 1))),
      t0.add(const Duration(minutes: 5)),
    );
    expect(
      time.clampToServer(t0.subtract(const Duration(hours: 1))),
      t0.subtract(const Duration(hours: 1)),
    );
  });

  test('offset saqlanadi va restartdan keyin tiklanadi', () {
    time.syncFromServer(t0.add(const Duration(seconds: 45)));
    expect(time.offset, const Duration(seconds: 45));

    final ({FakeWallClock clock, TimeSource time}) restarted = buildTestTimeSource(t0);
    addTearDown(restarted.time.dispose);
    restarted.time.restoreOffset(const Duration(seconds: 45));
    expect(restarted.time.now(), t0.add(const Duration(seconds: 45)));
    expect(restarted.time.source, EventTimeSource.server);
  });

  test('ClockVerdict qiymat tengligi', () {
    const ClockVerdict a = ClockVerdict(
      source: EventTimeSource.server,
      clockSkewSec: 3,
      timeUnverified: false,
    );
    const ClockVerdict b = ClockVerdict(
      source: EventTimeSource.server,
      clockSkewSec: 3,
      timeUnverified: false,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a.level, ClockSkewLevel.normal);
    expect(a.hasMalfunction, isFalse);
    expect(a.toString(), contains('server'));
    expect(
      TimeReading(
        utc: t0,
        source: EventTimeSource.phone,
        unverified: true,
        clockSkewSec: 0,
      ).toString(),
      contains('phone'),
    );
  });
}
