import 'package:sync_core/sync_core.dart';

/// Fixed instant used by every test — `DateTime.now()` is forbidden here.
final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

OutboxRecord rec({
  required int id,
  OutboxKind kind = OutboxKind.event,
  int? seq,
  int bytes = 100,
  OutboxState state = OutboxState.pending,
  DateTime? nextAttemptAt,
  int attempts = 0,
  int slot = 0,
  String? userId,
}) => OutboxRecord(
  id: id,
  kind: kind,
  clientId: 'c$id',
  deviceSeq: seq ?? id,
  payloadJson: 'x' * bytes,
  createdAt: t0,
  nextAttemptAt: nextAttemptAt ?? t0,
  state: state,
  attempts: attempts,
  sessionSlot: slot,
  userId: userId,
);

/// Deterministic `random()` stub for the backoff jitter.
double Function() fixedRandom(double value) =>
    () => value;
