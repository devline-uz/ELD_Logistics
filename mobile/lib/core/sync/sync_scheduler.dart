/// `SyncScheduler` — trigger'lar, mutex (M26), backoff + jitter, M34 pauzasi (§5.4).
library;

import 'dart:async';
import 'dart:math';

import 'package:sync_core/sync_core.dart';

import '../time/time_source.dart';
import 'sync_engine.dart';

/// Sync sikli qanday sabab bilan boshlangani (§5.4 jadvali).
enum SyncTrigger {
  /// Ilova foreground'ga chiqdi.
  foreground,

  /// Tarmoq paydo bo'ldi (2 s debounce).
  connectivity,

  /// Doimiy taymer: onlayn 60 s, haydash rejimida 30 s.
  timer,

  /// Kritik event (`certify`, `dvir`, `duty_status`, `claim`).
  critical,

  /// Android foreground service.
  background,

  /// Foydalanuvchi `Refresh` bosdi.
  manual,
}

/// UI indikatori holati (§5.5).
enum SyncStatus { synced, pending, syncing, offline, conflict }

/// Doimiy taymer intervallari.
const Duration kTimerIntervalOnline = Duration(seconds: 60);
const Duration kTimerIntervalDriving = Duration(seconds: 30);

/// Tarmoq paydo bo'lganda debounce (§5.4).
const Duration kConnectivityDebounce = Duration(seconds: 2);

/// M34: ketma-ket 3 ta `403` dan keyin push 15 daqiqaga to'xtaydi.
const int kForbiddenLimit = 3;
const Duration kForbiddenCooldown = Duration(minutes: 15);

/// Sync siklini rejalashtiradi va bir vaqtda faqat bittasini yuritadi.
class SyncScheduler {
  SyncScheduler({
    required SyncEngine engine,
    required TimeSource time,
    required SyncContext Function() context,
    BackoffPolicy policy = const BackoffPolicy(),
    Random? random,
  }) : this._(engine, time, context, BackoffState(policy: policy), random ?? Random.secure());

  SyncScheduler._(this._engine, this._time, this._context, this._backoff, this._random);

  final SyncEngine _engine;
  final TimeSource _time;
  final SyncContext Function() _context;
  final BackoffState _backoff;
  final Random _random;

  final StreamController<SyncCycleResult> _results = StreamController<SyncCycleResult>.broadcast();

  Timer? _timer;
  Timer? _debounce;
  Future<SyncCycleResult>? _running;
  bool _rerunRequested = false;
  int _consecutiveForbidden = 0;
  DateTime? _blockedUntil;
  bool _online = true;
  bool _disposed = false;

  /// Har tugagan siklning natijasi (`M-54` va telemetriya uchun).
  Stream<SyncCycleResult> get results => _results.stream;

  /// Sikl hozir ishlayaptimi.
  bool get isRunning => _running != null;

  /// Backoff yoki M34 pauzasi tugaydigan vaqt.
  DateTime? get blockedUntil => _blockedUntil;

  /// Tarmoq holati; `false` bo'lsa taymer urinmaydi (§5.4).
  set online(bool value) {
    if (_online == value) {
      return;
    }
    _online = value;
    if (value) {
      // 2 s debounce: tarmoq «titrasa» ketma-ket push bo'lmasin.
      _debounce?.cancel();
      _debounce = Timer(kConnectivityDebounce, () {
        unawaited(request(SyncTrigger.connectivity));
      });
    }
  }

  bool get online => _online;

  /// Doimiy taymerni yoqadi. [driving] o'zgarganda qayta chaqiriladi.
  void start({bool driving = false}) {
    _timer?.cancel();
    _timer = Timer.periodic(
      driving ? kTimerIntervalDriving : kTimerIntervalOnline,
      (Timer _) => unawaited(request(SyncTrigger.timer)),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _debounce?.cancel();
    _debounce = null;
  }

  /// **M26:** bir vaqtda faqat bitta sikl. Ikkinchi trigger navbatga qo'yiladi —
  /// joriy sikl tugagach **bir marta** qayta yuriladi, parallel push bo'lmaydi.
  Future<SyncCycleResult> request(SyncTrigger trigger) {
    final Future<SyncCycleResult>? current = _running;
    if (current != null) {
      _rerunRequested = true;
      return current;
    }
    final Future<SyncCycleResult> started = _runGuarded(trigger);
    _running = started;
    return started;
  }

  Future<SyncCycleResult> _runGuarded(SyncTrigger trigger) async {
    try {
      return await _runCycle(trigger);
    } finally {
      _running = null;
      if (_rerunRequested && !_disposed) {
        _rerunRequested = false;
        unawaited(request(trigger));
      }
    }
  }

  Future<SyncCycleResult> _runCycle(SyncTrigger trigger) async {
    final DateTime now = _time.now();

    // Oflayn: taymer va fon triggeri urinmaydi; qo'lda/kritik urinish o'tadi.
    final bool passive = trigger == SyncTrigger.timer || trigger == SyncTrigger.background;
    if (!_online && passive) {
      return _publish(const SyncCycleResult(ok: false, errorCode: 'CLIENT_OFFLINE'));
    }

    final DateTime? blocked = _blockedUntil;
    if (blocked != null && now.isBefore(blocked) && trigger != SyncTrigger.manual) {
      return _publish(const SyncCycleResult(ok: false, errorCode: 'CLIENT_BACKOFF'));
    }

    if (trigger == SyncTrigger.manual) {
      // `Retry now` backoff kechikishini ham bekor qiladi (M28).
      await _engine.releaseQueueNow();
    }

    final SyncCycleResult result = await _engine.runCycle(_context());

    if (result.ok) {
      _backoff.onSuccess();
      _consecutiveForbidden = 0;
      _blockedUntil = null;
      return _publish(result);
    }

    if (result.forbidden) {
      _consecutiveForbidden++;
      if (_consecutiveForbidden >= kForbiddenLimit) {
        // M34: serverni «bombardimon» qilmaymiz.
        _blockedUntil = now.add(kForbiddenCooldown);
        return _publish(result);
      }
    } else {
      _consecutiveForbidden = 0;
    }

    final DateTime until = _backoff.onFailure(
      now: now,
      random: _random.nextDouble,
      retryAfter: result.retryAfter,
    );
    _blockedUntil = until;
    // Kechikish faqat xotirada emas, `outbox_items.next_attempt_at` da ham.
    await _engine.deferQueue(until);
    return _publish(result);
  }

  SyncCycleResult _publish(SyncCycleResult result) {
    if (!_results.isClosed) {
      _results.add(result);
    }
    return result;
  }

  /// Joriy urinishlar soni (backoff pog'onasi) — diagnostika uchun.
  int get attempt => _backoff.attempt;

  Future<void> dispose() async {
    _disposed = true;
    stop();
    await _results.close();
  }
}
