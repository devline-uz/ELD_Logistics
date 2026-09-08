/// Exponential backoff with jitter for the sync scheduler (§5.4).
library;

import 'package:meta/meta.dart';

/// `1 s → 2 s → 5 s → 15 s → 60 s → 300 s`, capped at 5 minutes, ±20% jitter.
@immutable
class BackoffPolicy {
  const BackoffPolicy({this.steps = defaultSteps, this.jitterFraction = 0.2});

  static const List<Duration> defaultSteps = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 60),
    Duration(seconds: 300),
  ];

  final List<Duration> steps;

  /// Relative jitter amplitude; 0.2 means the delay lands in `[0.8x, 1.2x]`.
  final double jitterFraction;

  /// Maximum delay (last step) before jitter.
  Duration get maxDelay => steps.last;

  /// Base delay for a zero-based [attempt] (0 = first retry), without jitter.
  Duration baseDelay(int attempt) {
    if (attempt < 0) {
      throw ArgumentError.value(attempt, 'attempt', 'must be >= 0');
    }
    return attempt >= steps.length ? steps.last : steps[attempt];
  }

  /// Delay for [attempt] with jitter applied.
  ///
  /// [random] must return a value in `[0, 1)`; the caller injects it so tests
  /// stay deterministic. `Random()` is forbidden inside this package.
  Duration delay(int attempt, {required double Function() random}) {
    final Duration base = baseDelay(attempt);
    final double roll = random();
    if (roll < 0 || roll >= 1) {
      throw ArgumentError.value(roll, 'random', 'must be in [0, 1)');
    }
    final double factor = 1 + jitterFraction * (roll * 2 - 1);
    final int micros = (base.inMicroseconds * factor).round();
    return Duration(microseconds: micros);
  }

  /// Instant to write into `outbox_items.next_attempt_at`.
  ///
  /// [retryAfter] (HTTP `Retry-After` on `429 RATE_LIMITED`) always wins and is
  /// used verbatim, without jitter.
  DateTime nextAttemptAt({
    required DateTime now,
    required int attempt,
    required double Function() random,
    Duration? retryAfter,
  }) {
    if (retryAfter != null) {
      return now.add(retryAfter.isNegative ? Duration.zero : retryAfter);
    }
    return now.add(delay(attempt, random: random));
  }
}

/// Mutable retry counter of a single sync loop; reset to zero on success.
class BackoffState {
  BackoffState({this.policy = const BackoffPolicy()});

  final BackoffPolicy policy;

  int _attempt = 0;

  /// Number of consecutive failures so far.
  int get attempt => _attempt;

  /// Registers a failure and returns the instant of the next attempt.
  DateTime onFailure({
    required DateTime now,
    required double Function() random,
    Duration? retryAfter,
  }) {
    final DateTime next = policy.nextAttemptAt(
      now: now,
      attempt: _attempt,
      random: random,
      retryAfter: retryAfter,
    );
    if (_attempt < policy.steps.length) {
      _attempt++;
    }
    return next;
  }

  /// Backoff drops to zero after a successful cycle (§5.4).
  void onSuccess() => _attempt = 0;
}
