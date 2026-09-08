/// Outbox value types shared by the batching, backoff and conflict rules.
///
/// Source: `tz-mobile.md` §5.1 (`outbox_items`), §5.3 (M24, M25).
library;

import 'package:meta/meta.dart';

/// Kind of a queued item. Wire names match `outbox_items.kind`.
enum OutboxKind {
  event('event'),
  telemetry('telemetry'),
  dvir('dvir'),
  chat('chat'),
  certify('certify'),
  claim('claim'),
  logEdit('log_edit'),
  pushToken('push_token'),
  feedback('feedback'),
  support('support');

  const OutboxKind(this.wire);

  /// Value persisted in SQLite and sent to the server.
  final String wire;

  /// Parses [wire], throwing [ArgumentError] for unknown values.
  static OutboxKind fromWire(String wire) {
    for (final OutboxKind kind in OutboxKind.values) {
      if (kind.wire == wire) {
        return kind;
      }
    }
    throw ArgumentError.value(wire, 'wire', 'unknown outbox kind');
  }

  /// Kinds pushed immediately regardless of the periodic timer (§5.4).
  bool get isCritical =>
      this == OutboxKind.event ||
      this == OutboxKind.certify ||
      this == OutboxKind.dvir ||
      this == OutboxKind.claim;
}

/// Lifecycle of a queued item.
enum OutboxState {
  pending('pending'),
  inflight('inflight'),
  acked('acked'),
  rejected('rejected');

  const OutboxState(this.wire);

  final String wire;

  static OutboxState fromWire(String wire) {
    for (final OutboxState state in OutboxState.values) {
      if (state.wire == wire) {
        return state;
      }
    }
    throw ArgumentError.value(wire, 'wire', 'unknown outbox state');
  }

  /// `acked` and `rejected` items never leave the queue again.
  bool get isTerminal => this == OutboxState.acked || this == OutboxState.rejected;
}

/// Immutable projection of one `outbox_items` row.
///
/// Deliberately storage-agnostic: the Drift row is mapped into this type so the
/// batching rules stay pure and testable without a database.
@immutable
class OutboxRecord {
  const OutboxRecord({
    required this.id,
    required this.kind,
    required this.clientId,
    required this.deviceSeq,
    required this.payloadJson,
    required this.createdAt,
    required this.nextAttemptAt,
    this.state = OutboxState.pending,
    this.attempts = 0,
    this.idempotencyKey,
    this.sessionSlot = 0,
    this.userId,
  });

  final int id;
  final OutboxKind kind;

  /// Stable client-generated UUID v4 — the only idempotency key (M19).
  final String clientId;

  /// Device-unique monotonic sequence; defines send order (M20, M25).
  final int deviceSeq;

  /// Serialized item body. Byte size is measured from this string.
  final String payloadJson;

  final DateTime createdAt;
  final DateTime nextAttemptAt;
  final OutboxState state;
  final int attempts;

  /// Idempotency key of the batch this item was last sent with (M33.6).
  final String? idempotencyKey;

  /// 0 = primary driver, 1 = co-driver (§3).
  final int sessionSlot;
  final String? userId;

  /// UTF-8 payload size used for the 4 MB batch budget.
  int get payloadBytes => payloadJson.length;

  /// True when the scheduler may pick this item up at [now].
  bool isDueAt(DateTime now) => state == OutboxState.pending && !nextAttemptAt.isAfter(now);

  OutboxRecord copyWith({
    OutboxState? state,
    int? attempts,
    DateTime? nextAttemptAt,
    String? idempotencyKey,
  }) => OutboxRecord(
    id: id,
    kind: kind,
    clientId: clientId,
    deviceSeq: deviceSeq,
    payloadJson: payloadJson,
    createdAt: createdAt,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    sessionSlot: sessionSlot,
    userId: userId,
  );

  @override
  String toString() => 'OutboxRecord(#$id ${kind.wire} seq=$deviceSeq ${state.wire})';
}
