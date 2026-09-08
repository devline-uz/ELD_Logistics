import 'package:sync_core/sync_core.dart';
import 'package:test/test.dart';

void main() {
  group('PushResultKind', () {
    test('round-trips wire values', () {
      for (final PushResultKind kind in PushResultKind.values) {
        expect(PushResultKind.fromWire(kind.wire), kind);
      }
      expect(() => PushResultKind.fromWire('maybe'), throwsArgumentError);
    });
  });

  group('RejectReason', () {
    test('round-trips every §5.6 reason', () {
      for (final RejectReason reason in RejectReason.values) {
        expect(RejectReason.fromWire(reason.wire), reason);
      }
    });

    test('degrades unknown and null reasons instead of throwing', () {
      expect(RejectReason.fromWire('brand_new_reason'), RejectReason.unknown);
      expect(RejectReason.fromWire(null), RejectReason.unknown);
    });
  });

  group('presentationFor', () {
    test('covers every reason with a message key and an action', () {
      for (final RejectReason reason in RejectReason.values) {
        final ConflictPresentation p = presentationFor(reason);
        expect(p.reason, reason);
        expect(p.messageKey, startsWith('conflict'));
        expect(p.fallbackText, isNotEmpty);
      }
    });

    test('matches the §5.6 action column', () {
      expect(presentationFor(RejectReason.timeInFuture).action, ConflictAction.resend);
      expect(presentationFor(RejectReason.timeOutOfRange).action, ConflictAction.viewOnly);
      expect(presentationFor(RejectReason.logLocked).action, ConflictAction.contactSupport);
      expect(presentationFor(RejectReason.superseded).action, ConflictAction.informational);
      expect(presentationFor(RejectReason.invalidPayload).action, ConflictAction.sendDiagnostics);
      expect(presentationFor(RejectReason.pcNotAllowed).action, ConflictAction.hideToggle);
      expect(presentationFor(RejectReason.ymNotAllowed).action, ConflictAction.hideToggle);
      expect(
        presentationFor(RejectReason.sleeperBerthUnavailable).action,
        ConflictAction.disableSleeperBerth,
      );
      expect(presentationFor(RejectReason.driveNotManual).action, ConflictAction.none);
      expect(presentationFor(RejectReason.autoDrive).action, ConflictAction.none);
      expect(presentationFor(RejectReason.yardMoveEnded).action, ConflictAction.none);
    });

    test('PC and YM share one message, auto-drive reasons share another', () {
      expect(
        presentationFor(RejectReason.pcNotAllowed).messageKey,
        presentationFor(RejectReason.ymNotAllowed).messageKey,
      );
      expect(
        presentationFor(RejectReason.driveNotManual).messageKey,
        presentationFor(RejectReason.autoDrive).messageKey,
      );
    });
  });

  group('resolvePushResult', () {
    test('accepted and duplicate both ack the item', () {
      for (final PushResultKind kind in <PushResultKind>[
        PushResultKind.accepted,
        PushResultKind.duplicate,
      ]) {
        final PushOutcome outcome = resolvePushResult(result: kind);
        expect(outcome.outcome, OutboxOutcome.acked);
        expect(outcome.reason, isNull);
        expect(outcome.isError, isFalse);
        expect(outcome.showsInConflicts, isFalse);
      }
    });

    test('superseded acks the item and records the winner (M29)', () {
      final PushOutcome outcome = resolvePushResult(
        result: PushResultKind.rejected,
        reason: 'superseded',
        supersededBy: 'srv-1',
      );
      expect(outcome.outcome, OutboxOutcome.acked);
      expect(outcome.reason, RejectReason.superseded);
      expect(outcome.supersededBy, 'srv-1');
      expect(outcome.isError, isFalse);
      expect(outcome.showsInConflicts, isTrue);
    });

    test('other reasons reject the item and surface on M-55', () {
      final PushOutcome outcome = resolvePushResult(
        result: PushResultKind.rejected,
        reason: 'log_locked',
      );
      expect(outcome.outcome, OutboxOutcome.rejected);
      expect(outcome.reason, RejectReason.logLocked);
      expect(outcome.isError, isTrue);
      expect(outcome.showsInConflicts, isTrue);
    });

    test('a rejection without a reason becomes unknown', () {
      final PushOutcome outcome = resolvePushResult(result: PushResultKind.rejected);
      expect(outcome.outcome, OutboxOutcome.rejected);
      expect(outcome.reason, RejectReason.unknown);
    });

    test('value equality and toString', () {
      const PushOutcome a = PushOutcome(outcome: OutboxOutcome.acked, reason: null);
      const PushOutcome b = PushOutcome(outcome: OutboxOutcome.acked, reason: null);
      const PushOutcome c = PushOutcome(
        outcome: OutboxOutcome.rejected,
        reason: RejectReason.logLocked,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(c.toString(), contains('log_locked'));
    });
  });
}
