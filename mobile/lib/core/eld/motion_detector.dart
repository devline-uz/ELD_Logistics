/// Auto-DR harakat detektori (tz-mobile §9, M56–M62).
///
/// **Faqat detektor:** duty status yozish, drive ekrani va modal — `duty_status`
/// moduli (M4) zimmasida. Bu sinf faqat [MotionEvent] oqimini beradi.
///
/// ```
/// speed >= motion_threshold_kmh, uzluksiz >= 3 s  → movingConfirmed
/// speed == 0, uzluksiz >= 3 s                      → stopped
/// stopped + 5 daq                                  → idlePromptDue
/// idlePromptDue + 1 daq javobsiz                   → idleNoAnswer (ON, M60)
/// ```
library;

import 'dart:async';

import 'eld_models.dart';

/// Detektor chiqaradigan hodisa turlari.
enum MotionEventType {
  /// `motion_threshold_kmh` dan yuqori tezlik 3 s tasdiqlandi → `DR` (M56).
  movingConfirmed,

  /// Tezlik 0 va 3 s tasdiqlandi → drive ekranidan chiqiladi, status `DR` da
  /// **qoladi** (M59).
  stopped,

  /// To'xtashdan 5 daqiqa o'tdi → «Are you still driving?» modali (M61).
  idlePromptDue,

  /// So'rovga 1 daqiqa javob bo'lmadi → `ON`.
  ///
  /// **M60:** event vaqti = [MotionEvent.promptIssuedAt] (so'rov chiqqan payt),
  /// to'xtash vaqti emas.
  idleNoAnswer,
}

class MotionEvent {
  const MotionEvent({
    required this.type,
    required this.at,
    this.speedKmh,
    this.lat,
    this.lng,
    this.odometerM,
    this.engineHours,
    this.promptIssuedAt,
  });

  final MotionEventType type;

  /// Hodisa vaqti (UTC).
  final DateTime at;

  final double? speedKmh;
  final double? lat;
  final double? lng;
  final int? odometerM;
  final double? engineHours;

  /// `idleNoAnswer` uchun — so'rov chiqqan payt (M60).
  final DateTime? promptIssuedAt;

  @override
  String toString() => 'MotionEvent(${type.name}, $at, $speedKmh)';
}

/// Detektor sozlamalari — `hos_policy` dan keladi.
class MotionPolicy {
  const MotionPolicy({
    this.motionThresholdKmh = 8,
    this.confirmWindow = const Duration(seconds: 3),
    this.stopWindow = const Duration(seconds: 3),
    this.idlePrompt = const Duration(minutes: 5),
    this.idleAnswerWindow = const Duration(minutes: 1),
  });

  /// `hos_policy.motion_threshold_kmh`, default 8 km/h (M56).
  final double motionThresholdKmh;

  /// Harakatni tasdiqlash oynasi — 3 s.
  final Duration confirmWindow;

  /// To'xtashni tasdiqlash oynasi — 3 s.
  final Duration stopWindow;

  /// To'xtashdan modalgacha — 5 daqiqa (M61).
  final Duration idlePrompt;

  /// Modaldan `ON` gacha — 1 daqiqa (M62).
  final Duration idleAnswerWindow;

  MotionPolicy copyWith({double? motionThresholdKmh}) => MotionPolicy(
    motionThresholdKmh: motionThresholdKmh ?? this.motionThresholdKmh,
    confirmWindow: confirmWindow,
    stopWindow: stopWindow,
    idlePrompt: idlePrompt,
    idleAnswerWindow: idleAnswerWindow,
  );
}

/// Harakat holati.
enum MotionPhase { idle, movingPending, moving, stopPending, stopped }

/// Auto-DR detektori.
///
/// Testlarda [onFrame] va [tick] qo'lda chaqiriladi (taymer yo'q), ilovada
/// `MotionDetectorRunner` telemetriya oqimi va 1 s taymerni ulaydi.
class MotionDetector {
  MotionDetector({this._policy = const MotionPolicy()});

  MotionPolicy _policy;

  final StreamController<MotionEvent> _events = StreamController<MotionEvent>.broadcast();

  MotionPhase _phase = MotionPhase.idle;
  DateTime? _aboveSince;
  DateTime? _zeroSince;
  DateTime? _stoppedAt;
  DateTime? _promptIssuedAt;
  bool _promptAnswered = false;
  EldTelemetryFrame? _last;

  Stream<MotionEvent> get events => _events.stream;

  MotionPhase get phase => _phase;

  /// Joriy siyosat. Maydon `_policy` yopiq qoladi — o'zgartirish faqat
  /// setter orqali, `sync/pull` dan keladi.
  // ignore: unnecessary_getters_setters
  MotionPolicy get policy => _policy;

  /// `hos_policy` yangilanganda (sync/pull) chaqiriladi.
  set policy(MotionPolicy value) => _policy = value;

  /// PC rejimida harakat `DR` yozmaydi (M57) — kontroller shu bayroqni beradi.
  bool suppressed = false;

  /// Telemetriya kadri keldi.
  void onFrame(EldTelemetryFrame frame) {
    _last = frame;
    final DateTime now = frame.at;
    final double speed = frame.speedKmh;

    if (speed >= _policy.motionThresholdKmh) {
      _zeroSince = null;
      _aboveSince ??= now;
      if (_phase != MotionPhase.moving) {
        _phase = MotionPhase.movingPending;
        if (now.difference(_aboveSince!) >= _policy.confirmWindow) {
          _confirmMoving(now, frame);
        }
      }
    } else {
      _aboveSince = null;
      if (speed == 0) {
        _zeroSince ??= now;
        if (_phase == MotionPhase.moving) {
          _phase = MotionPhase.stopPending;
        }
        if (_phase == MotionPhase.stopPending &&
            now.difference(_zeroSince!) >= _policy.stopWindow) {
          _confirmStop(now, frame);
        }
      } else {
        // 0 < speed < threshold — na harakat, na to'xtash.
        _zeroSince = null;
        if (_phase == MotionPhase.movingPending) {
          _phase = MotionPhase.idle;
        }
      }
    }
    tick(now);
  }

  /// Taymer qadami — kadr kelmasa ham idle hisoblagichi ishlashi uchun.
  void tick(DateTime now) {
    final DateTime? above = _aboveSince;
    if (above != null &&
        _phase == MotionPhase.movingPending &&
        now.difference(above) >= _policy.confirmWindow) {
      _confirmMoving(now, _last);
    }

    final DateTime? zero = _zeroSince;
    if (zero != null &&
        _phase == MotionPhase.stopPending &&
        now.difference(zero) >= _policy.stopWindow) {
      _confirmStop(now, _last);
    }

    final DateTime? stoppedAt = _stoppedAt;
    if (stoppedAt != null && _promptIssuedAt == null && !_promptAnswered) {
      if (now.difference(stoppedAt) >= _policy.idlePrompt) {
        _promptIssuedAt = now;
        _emit(MotionEvent(type: MotionEventType.idlePromptDue, at: now));
      }
    }

    final DateTime? prompt = _promptIssuedAt;
    if (prompt != null && !_promptAnswered && now.difference(prompt) >= _policy.idleAnswerWindow) {
      _promptAnswered = true;
      _emit(
        MotionEvent(
          // M60: event vaqti = so'rov chiqqan payt.
          type: MotionEventType.idleNoAnswer,
          at: prompt,
          promptIssuedAt: prompt,
          lat: _last?.lat,
          lng: _last?.lng,
          odometerM: _last?.odometerM,
          engineHours: _last?.engineHours,
        ),
      );
      _resetIdle();
    }
  }

  /// Haydovchi `Yes, driving` bosdi — taymer nolga tushadi (M61).
  void answerStillDriving() {
    _promptAnswered = true;
    _resetIdle();
    _stoppedAt = _last?.at;
  }

  /// Haydovchi `No` bosdi — kontroller `ON` yozadi, detektor tozalanadi.
  void answerNotDriving() {
    _promptAnswered = true;
    _resetIdle();
  }

  /// Status qo'lda o'zgartirildi — detektor holati tozalanadi.
  void reset() {
    _phase = MotionPhase.idle;
    _aboveSince = null;
    _zeroSince = null;
    _resetIdle();
  }

  Future<void> dispose() => _events.close();

  void _confirmMoving(DateTime now, EldTelemetryFrame? frame) {
    _phase = MotionPhase.moving;
    _resetIdle();
    if (suppressed) {
      return; // PC rejimi (M57): DR yozilmaydi.
    }
    _emit(
      MotionEvent(
        type: MotionEventType.movingConfirmed,
        at: now,
        speedKmh: frame?.speedKmh,
        lat: frame?.lat,
        lng: frame?.lng,
        odometerM: frame?.odometerM,
        engineHours: frame?.engineHours,
      ),
    );
  }

  void _confirmStop(DateTime now, EldTelemetryFrame? frame) {
    _phase = MotionPhase.stopped;
    _stoppedAt = now;
    _promptIssuedAt = null;
    _promptAnswered = false;
    _emit(
      MotionEvent(
        type: MotionEventType.stopped,
        at: now,
        speedKmh: 0,
        lat: frame?.lat,
        lng: frame?.lng,
        odometerM: frame?.odometerM,
        engineHours: frame?.engineHours,
      ),
    );
  }

  void _resetIdle() {
    _stoppedAt = null;
    _promptIssuedAt = null;
    _promptAnswered = false;
  }

  void _emit(MotionEvent event) {
    if (!_events.isClosed) {
      _events.add(event);
    }
  }
}

/// Telemetriya oqimi va 1 s taymerni [MotionDetector] ga ulaydi.
class MotionDetectorRunner {
  MotionDetectorRunner({
    required this._detector,
    required Stream<EldTelemetryFrame> telemetry,
    required DateTime Function() now,
    Duration tickInterval = const Duration(seconds: 1),
  }) {
    _sub = telemetry.listen(_detector.onFrame);
    _timer = Timer.periodic(tickInterval, (_) => _detector.tick(now()));
  }

  final MotionDetector _detector;
  late final StreamSubscription<EldTelemetryFrame> _sub;
  late final Timer _timer;

  Stream<MotionEvent> get events => _detector.events;

  Future<void> dispose() async {
    _timer.cancel();
    await _sub.cancel();
  }
}
