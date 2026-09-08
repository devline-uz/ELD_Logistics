import 'package:sync_core/sync_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('OutboxKind', () {
    test('round-trips every wire value', () {
      for (final OutboxKind kind in OutboxKind.values) {
        expect(OutboxKind.fromWire(kind.wire), kind);
      }
    });

    test('rejects an unknown wire value', () {
      expect(() => OutboxKind.fromWire('nope'), throwsArgumentError);
    });

    test('critical kinds trigger an immediate push', () {
      expect(OutboxKind.event.isCritical, isTrue);
      expect(OutboxKind.certify.isCritical, isTrue);
      expect(OutboxKind.dvir.isCritical, isTrue);
      expect(OutboxKind.claim.isCritical, isTrue);
      expect(OutboxKind.telemetry.isCritical, isFalse);
      expect(OutboxKind.chat.isCritical, isFalse);
    });
  });

  group('OutboxState', () {
    test('round-trips every wire value', () {
      for (final OutboxState state in OutboxState.values) {
        expect(OutboxState.fromWire(state.wire), state);
      }
      expect(() => OutboxState.fromWire('gone'), throwsArgumentError);
    });

    test('acked and rejected are terminal', () {
      expect(OutboxState.acked.isTerminal, isTrue);
      expect(OutboxState.rejected.isTerminal, isTrue);
      expect(OutboxState.pending.isTerminal, isFalse);
      expect(OutboxState.inflight.isTerminal, isFalse);
    });
  });

  group('OutboxRecord', () {
    test('isDueAt honours state and next_attempt_at', () {
      final OutboxRecord due = rec(id: 1);
      expect(due.isDueAt(t0), isTrue);
      expect(due.isDueAt(t0.add(const Duration(minutes: 1))), isTrue);

      final OutboxRecord later = rec(id: 2, nextAttemptAt: t0.add(const Duration(seconds: 5)));
      expect(later.isDueAt(t0), isFalse);

      expect(rec(id: 3, state: OutboxState.inflight).isDueAt(t0), isFalse);
      expect(rec(id: 4, state: OutboxState.acked).isDueAt(t0), isFalse);
    });

    test('payloadBytes measures the payload', () {
      expect(rec(id: 1, bytes: 42).payloadBytes, 42);
    });

    test('copyWith keeps identity fields and toString is stable', () {
      final OutboxRecord updated = rec(id: 7, seq: 9).copyWith(
        state: OutboxState.inflight,
        attempts: 3,
        idempotencyKey: 'key',
        nextAttemptAt: t0.add(const Duration(seconds: 1)),
      );
      expect(updated.id, 7);
      expect(updated.deviceSeq, 9);
      expect(updated.clientId, 'c7');
      expect(updated.state, OutboxState.inflight);
      expect(updated.attempts, 3);
      expect(updated.idempotencyKey, 'key');
      expect(updated.sessionSlot, 0);
      expect(updated.userId, isNull);
      expect(updated.toString(), contains('#7'));
      expect(updated.toString(), contains('seq=9'));
    });
  });
}
