/// `TimeSource` — ELD RTC → server → telefon ustuvorligi (§7.1, M39–M41).
///
/// **`DateTime.now()` butun kodbazada faqat shu faylda chaqiriladi.** Boshqa
/// hamma joyda (DAO, repozitoriy, scheduler, domen, testlar) vaqt shu sinf
/// orqali olinadi; `tool/check_forbidden.sh` buni tekshiradi.
library;

import 'dart:async';

import 'package:sync_core/sync_core.dart';

import 'clock_verdict.dart';

/// Ishonchli vaqt langari: `wall` — manba bergan UTC, `monotonic` — o'sha
/// paytdagi monoton soat qiymati.
class _TimeAnchor {
  const _TimeAnchor({required this.wall, required this.monotonicMicros, required this.source});

  final DateTime wall;
  final int monotonicMicros;
  final EventTimeSource source;
}

/// Vaqt manbai.
///
/// Monoton soat (`Stopwatch`) + oxirgi ishonchli langarga tayanadi: foydalanuvchi
/// telefon soatini o'zgartirsa ham event vaqti sakramaydi (§7.1).
class TimeSource {
  TimeSource({DateTime Function()? wallClock, Stopwatch? monotonic})
    : _wallClock = wallClock ?? _systemWallClock,
      _monotonic = (monotonic ?? Stopwatch())..start();

  /// Kodbazadagi yagona `DateTime.now()`.
  static DateTime _systemWallClock() => DateTime.now().toUtc(); // ignore: eld_time_source

  final DateTime Function() _wallClock;
  final Stopwatch _monotonic;

  _TimeAnchor? _anchor;
  DateTime? _lastIssued;
  ClockVerdict? _verdict;

  final StreamController<ClockSkewLevel> _skewLevels = StreamController<ClockSkewLevel>.broadcast();

  /// Skew darajasi o'zgarganda banner ko'rsatish uchun (§7.2).
  Stream<ClockSkewLevel> get skewLevelChanges => _skewLevels.stream;

  ClockSkewLevel _lastLevel = ClockSkewLevel.normal;

  /// Telefon soati (xom). Faqat skew hisoblash uchun.
  DateTime phoneNow() => _wallClock().toUtc();

  /// Eng ishonchli joriy vaqt (UTC), hech qachon orqaga ketmaydi.
  DateTime now() {
    final _TimeAnchor? anchor = _anchor;
    DateTime candidate;
    if (anchor == null) {
      candidate = phoneNow();
    } else {
      final Duration elapsed = Duration(
        microseconds: _monotonic.elapsedMicroseconds - anchor.monotonicMicros,
      );
      candidate = anchor.wall.add(elapsed);
    }
    final DateTime? last = _lastIssued;
    if (last != null && candidate.isBefore(last)) {
      candidate = last;
    }
    _lastIssued = candidate;
    return candidate;
  }

  /// Joriy manba: langar bo'lmasa `phone`.
  EventTimeSource get source => _anchor?.source ?? EventTimeSource.phone;

  /// `|telefon − ishonchli manba|`, sekundda (eventga yoziladi).
  int get clockSkewSec {
    if (_anchor == null) {
      return 0;
    }
    return now().difference(phoneNow()).inSeconds.abs();
  }

  ClockSkewLevel get skewLevel => ClockSkewLevel.of(Duration(seconds: clockSkewSec));

  /// Server bergan oxirgi verdikt (M39); oflayn bo'lsa `null`.
  ClockVerdict? get verdict => _verdict;

  /// Eventga yoziladigan to'liq vaqt to'plami.
  ///
  /// `time_unverified` — manba `phone` bo'lsa, yoki server shunday degan bo'lsa,
  /// yoki skew ogohlantirish chegarasidan oshsa (M40).
  TimeReading reading() {
    final DateTime utc = now();
    final int skew = clockSkewSec;
    final ClockVerdict? verdict = _verdict;
    final bool unverified =
        verdict?.timeUnverified ??
        (source == EventTimeSource.phone ||
            ClockSkewLevel.of(Duration(seconds: skew)) != ClockSkewLevel.normal);
    return TimeReading(
      utc: utc,
      source: verdict?.source ?? source,
      unverified: unverified,
      clockSkewSec: verdict?.clockSkewSec ?? skew,
    );
  }

  /// **1-ustuvorlik:** ELD RTC (GPS bilan sinxron).
  void syncFromEldRtc(DateTime rtcUtc) => _setAnchor(rtcUtc, EventTimeSource.eldRtc);

  /// **2-ustuvorlik:** server vaqti (`server_time` yoki `Date` sarlavhasi).
  ///
  /// ELD RTC allaqachon langar bo'lsa e'tiborsiz qoldiriladi — pastroq ustuvorlik
  /// yuqorisini almashtirmaydi.
  void syncFromServer(DateTime serverUtc) {
    if (_anchor?.source == EventTimeSource.eldRtc) {
      return;
    }
    _setAnchor(serverUtc, EventTimeSource.server);
  }

  /// ELD uzilganda RTC langarini bekor qiladi — keyingi server sinxroni ustun bo'ladi.
  void dropEldAnchor() {
    if (_anchor?.source == EventTimeSource.eldRtc) {
      _anchor = null;
    }
  }

  /// **M39:** server verdikti kanonik — lokal hisob almashtiriladi.
  void applyVerdict(ClockVerdict verdict) {
    _verdict = verdict;
    _emitLevel(verdict.level);
  }

  /// Ilova qayta ishga tushganda saqlangan offsetni tiklaydi.
  ///
  /// Monoton soat jarayon bilan birga nolga tushadi, shuning uchun langar
  /// telefon soati + saqlangan offset bo'ladi; manba `server` deb belgilanadi,
  /// lekin birinchi muvaffaqiyatli sync uni yangilaydi.
  void restoreOffset(Duration offset) => _setAnchor(phoneNow().add(offset), EventTimeSource.server);

  /// `kv_settings` ga saqlash uchun joriy offset (`ishonchli − telefon`).
  Duration get offset => _anchor == null ? Duration.zero : now().difference(phoneNow());

  /// M41: event vaqti server oynasidan chiqib ketmasligini kafolatlaydi.
  DateTime clampToServer(DateTime eventTime) =>
      clampEventTime(eventTime: eventTime, serverTime: now());

  void _setAnchor(DateTime wall, EventTimeSource source) {
    _anchor = _TimeAnchor(
      wall: wall.toUtc(),
      monotonicMicros: _monotonic.elapsedMicroseconds,
      source: source,
    );
    _lastIssued = null;
    _emitLevel(skewLevel);
  }

  void _emitLevel(ClockSkewLevel level) {
    if (level != _lastLevel) {
      _lastLevel = level;
      if (!_skewLevels.isClosed) {
        _skewLevels.add(level);
      }
    }
  }

  Future<void> dispose() => _skewLevels.close();
}
