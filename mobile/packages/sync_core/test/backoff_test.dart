import 'package:sync_core/sync_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  const BackoffPolicy policy = BackoffPolicy();

  group('BackoffPolicy', () {
    test('follows the 1/2/5/15/60/300 s ladder', () {
      expect(List<int>.generate(6, (int i) => policy.baseDelay(i).inSeconds), <int>[
        1,
        2,
        5,
        15,
        60,
        300,
      ]);
    });

    test('saturates at 5 minutes', () {
      expect(policy.baseDelay(6), const Duration(minutes: 5));
      expect(policy.baseDelay(99), policy.maxDelay);
    });

    test('rejects a negative attempt', () {
      expect(() => policy.baseDelay(-1), throwsArgumentError);
    });

    test('jitter stays inside ±20%', () {
      expect(policy.delay(2, random: fixedRandom(0.0)), const Duration(seconds: 4));
      expect(policy.delay(2, random: fixedRandom(0.5)), const Duration(seconds: 5));
      expect(policy.delay(2, random: fixedRandom(0.999999)).inMilliseconds, closeTo(6000, 5));
    });

    test('rejects a random source outside [0, 1)', () {
      expect(() => policy.delay(0, random: fixedRandom(1.0)), throwsArgumentError);
      expect(() => policy.delay(0, random: fixedRandom(-0.1)), throwsArgumentError);
    });

    test('Retry-After wins over the ladder and jitter', () {
      final DateTime next = policy.nextAttemptAt(
        now: t0,
        attempt: 5,
        random: fixedRandom(0.0),
        retryAfter: const Duration(seconds: 42),
      );
      expect(next, t0.add(const Duration(seconds: 42)));
    });

    test('a negative Retry-After is clamped to zero', () {
      final DateTime next = policy.nextAttemptAt(
        now: t0,
        attempt: 0,
        random: fixedRandom(0.5),
        retryAfter: const Duration(seconds: -5),
      );
      expect(next, t0);
    });

    test('nextAttemptAt without Retry-After uses the ladder', () {
      expect(
        policy.nextAttemptAt(now: t0, attempt: 1, random: fixedRandom(0.5)),
        t0.add(const Duration(seconds: 2)),
      );
    });

    test('a custom policy can disable jitter', () {
      const BackoffPolicy flat = BackoffPolicy(
        steps: <Duration>[Duration(seconds: 3)],
        jitterFraction: 0,
      );
      expect(flat.delay(0, random: fixedRandom(0.0)), const Duration(seconds: 3));
      expect(flat.maxDelay, const Duration(seconds: 3));
    });
  });

  group('BackoffState', () {
    test('escalates on failure and resets on success', () {
      final BackoffState state = BackoffState();
      expect(state.attempt, 0);

      expect(
        state.onFailure(now: t0, random: fixedRandom(0.5)),
        t0.add(const Duration(seconds: 1)),
      );
      expect(state.attempt, 1);
      expect(
        state.onFailure(now: t0, random: fixedRandom(0.5)),
        t0.add(const Duration(seconds: 2)),
      );
      expect(state.attempt, 2);

      state.onSuccess();
      expect(state.attempt, 0);
      expect(
        state.onFailure(now: t0, random: fixedRandom(0.5)),
        t0.add(const Duration(seconds: 1)),
      );
    });

    test('never grows past the last ladder step', () {
      final BackoffState state = BackoffState();
      for (int i = 0; i < 20; i++) {
        state.onFailure(now: t0, random: fixedRandom(0.5));
      }
      expect(state.attempt, BackoffPolicy.defaultSteps.length);
      expect(
        state.onFailure(now: t0, random: fixedRandom(0.5)),
        t0.add(const Duration(minutes: 5)),
      );
    });

    test('passes Retry-After through', () {
      final BackoffState state = BackoffState();
      expect(
        state.onFailure(now: t0, random: fixedRandom(0.5), retryAfter: const Duration(seconds: 7)),
        t0.add(const Duration(seconds: 7)),
      );
    });
  });
}
