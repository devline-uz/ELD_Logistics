/// Slot-aware batching for the two-session (co-driver) cabin (§3.3, B-120).
///
/// Two drivers share one device but **not** one token pair. Every queued item
/// carries `outbox_items.session_slot`, so the push worker must never mix the
/// two: each slice is sent on its own session. These rules are pure so the
/// grouping can be tested without a database or a network stack.
library;

import 'package:meta/meta.dart';

import 'batch.dart';
import 'outbox_item.dart';

/// `session_slot` value of the primary driver.
const int kPrimarySlot = 0;

/// `session_slot` value of the co-driver.
const int kCoDriverSlot = 1;

/// One slot's share of the outbox, ready to be sent on that slot's session.
@immutable
class SlotBatch {
  const SlotBatch({required this.sessionSlot, required this.batch});

  /// `outbox_items.session_slot` every item in [batch] shares.
  final int sessionSlot;

  /// Items in ascending `device_seq` order (M25) within this slot.
  final OutboxBatch batch;

  bool get isEmpty => batch.isEmpty;

  bool get isNotEmpty => batch.isNotEmpty;

  int get length => batch.length;

  int get bytes => batch.bytes;

  @override
  String toString() => 'SlotBatch(slot=$sessionSlot, ${batch.length} items)';
}

/// Distinct `session_slot` values among items that are due at [now], ascending.
List<int> dueSlots({required List<OutboxRecord> candidates, required DateTime now}) {
  final Set<int> slots = <int>{
    for (final OutboxRecord item in candidates)
      if (item.isDueAt(now)) item.sessionSlot,
  };
  return slots.toList(growable: false)..sort();
}

/// Splits the due queue per `session_slot` (**B-120**).
///
/// Rules:
/// 1. items are grouped by [OutboxRecord.sessionSlot] — a batch never mixes
///    slots, so it can be sent with exactly one driver's token;
/// 2. [BatchLimits] apply **per group**, because every group becomes its own
///    `POST /sync/push` request;
/// 3. [allowedSlots] `null` means "no gate"; otherwise slots outside the set
///    are skipped entirely — their items stay `pending` and are picked up as
///    soon as that session has a token again (M23: nothing is ever dropped);
/// 4. [firstSlot] (the active slot) is sent first; the remaining slots follow
///    in ascending order, so the driver looking at the screen wins the race for
///    the connection.
List<SlotBatch> selectBatchesBySlot({
  required List<OutboxRecord> candidates,
  required DateTime now,
  BatchLimits limits = const BatchLimits.standard(),
  Set<int>? allowedSlots,
  int? firstSlot,
}) {
  final Map<int, List<OutboxRecord>> bySlot = <int, List<OutboxRecord>>{};
  for (final OutboxRecord item in candidates) {
    if (!item.isDueAt(now)) {
      continue;
    }
    if (allowedSlots != null && !allowedSlots.contains(item.sessionSlot)) {
      continue;
    }
    bySlot.putIfAbsent(item.sessionSlot, () => <OutboxRecord>[]).add(item);
  }
  if (bySlot.isEmpty) {
    return const <SlotBatch>[];
  }

  final List<int> order = bySlot.keys.toList()..sort();
  if (firstSlot != null && order.remove(firstSlot)) {
    order.insert(0, firstSlot);
  }

  final List<SlotBatch> groups = <SlotBatch>[];
  for (final int slot in order) {
    final OutboxBatch batch = selectBatch(candidates: bySlot[slot]!, now: now, limits: limits);
    if (batch.isNotEmpty) {
      groups.add(SlotBatch(sessionSlot: slot, batch: batch));
    }
  }
  return List<SlotBatch>.unmodifiable(groups);
}
