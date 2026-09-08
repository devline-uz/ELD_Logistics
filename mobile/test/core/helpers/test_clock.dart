/// Testlar uchun boshqariladigan soat — `TimeSource` ni deterministik qiladi.
library;

import 'package:eld_mobile/core/time/time_source.dart';

/// Qo'lda suriladigan devor soati.
class FakeWallClock {
  FakeWallClock(this._now);

  DateTime _now;

  DateTime call() => _now;

  void advance(Duration by) => _now = _now.add(by);

  set value(DateTime next) => _now = next;
}

/// Sun'iy monoton soat: `Stopwatch` ni `FakeWallClock` bilan bog'laydi.
class FakeStopwatch implements Stopwatch {
  FakeStopwatch(this._clock, this._origin);

  final FakeWallClock _clock;
  final DateTime _origin;

  @override
  int get elapsedMicroseconds => _clock().difference(_origin).inMicroseconds;

  @override
  Duration get elapsed => Duration(microseconds: elapsedMicroseconds);

  @override
  int get elapsedMilliseconds => elapsed.inMilliseconds;

  @override
  int get elapsedTicks => elapsedMicroseconds;

  @override
  int get frequency => 1000000;

  @override
  bool get isRunning => true;

  @override
  void reset() {}

  @override
  void start() {}

  @override
  void stop() {}
}

/// Fiksatsiya qilingan vaqtdan boshlanadigan `TimeSource`.
({TimeSource time, FakeWallClock clock}) buildTestTimeSource(DateTime start) {
  final FakeWallClock clock = FakeWallClock(start.toUtc());
  final TimeSource time = TimeSource(
    wallClock: clock.call,
    monotonic: FakeStopwatch(clock, start.toUtc()),
  );
  return (time: time, clock: clock);
}
