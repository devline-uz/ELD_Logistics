/// Batch selection and splitting for `POST /sync/push` (M33, M25, M27).
library;

import 'package:meta/meta.dart';

import 'outbox_item.dart';

/// Per-kind and total size caps of one push request (§6.1).
@immutable
class BatchLimits {
  const BatchLimits({
    this.events = 500,
    this.telemetry = 5000,
    this.dvir = 100,
    this.chat = 500,
    this.other = 500,
    this.maxBytes = 4 * 1024 * 1024,
  });

  /// Wi-Fi / unmetered defaults from §6.1.
  const BatchLimits.standard() : this();

  /// Metered (cellular) profile: telemetry capped at 1000 points (M27).
  /// Events are never throttled.
  const BatchLimits.metered() : this(telemetry: 1000);

  final int events;
  final int telemetry;
  final int dvir;
  final int chat;

  /// Cap for `certify`/`claim`/`log_edit`/`push_token`/`feedback`/`support`.
  final int other;
  final int maxBytes;

  /// Cap that applies to [kind].
  int capFor(OutboxKind kind) => switch (kind) {
    OutboxKind.event => events,
    OutboxKind.telemetry => telemetry,
    OutboxKind.dvir => dvir,
    OutboxKind.chat => chat,
    _ => other,
  };

  BatchLimits copyWith({int? events, int? telemetry, int? dvir, int? chat, int? maxBytes}) =>
      BatchLimits(
        events: events ?? this.events,
        telemetry: telemetry ?? this.telemetry,
        dvir: dvir ?? this.dvir,
        chat: chat ?? this.chat,
        other: other,
        maxBytes: maxBytes ?? this.maxBytes,
      );
}

/// An ordered, size-bounded slice of the outbox ready to be sent.
@immutable
class OutboxBatch {
  const OutboxBatch(this.items);

  const OutboxBatch.empty() : items = const <OutboxRecord>[];

  /// Items in ascending `device_seq` order (M25).
  final List<OutboxRecord> items;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get length => items.length;

  /// Sum of payload sizes; used for the 4 MB budget and for telemetry.
  int get bytes => items.fold(0, (int sum, OutboxRecord i) => sum + i.payloadBytes);

  /// Items of one [kind], order preserved.
  List<OutboxRecord> ofKind(OutboxKind kind) =>
      items.where((OutboxRecord i) => i.kind == kind).toList(growable: false);

  /// Item counts per kind — feeds the `M-54` queue breakdown.
  Map<OutboxKind, int> get countsByKind {
    final Map<OutboxKind, int> counts = <OutboxKind, int>{};
    for (final OutboxRecord item in items) {
      counts[item.kind] = (counts[item.kind] ?? 0) + 1;
    }
    return counts;
  }

  /// Highest `device_seq` in the batch, or `null` when empty.
  int? get maxDeviceSeq => items.isEmpty
      ? null
      : items.map((OutboxRecord i) => i.deviceSeq).reduce((int a, int b) => a > b ? a : b);

  @override
  String toString() => 'OutboxBatch(${items.length} items, $bytes B)';
}

/// Picks the next batch out of [candidates].
///
/// Rules (M33.1–M33.2):
/// 1. only `pending` items whose `next_attempt_at <= now` are eligible;
/// 2. eligible items are ordered by `device_seq` ascending (M25);
/// 3. an item is skipped when its kind cap is full or it would overflow the
///    byte budget — skipping never reorders the remaining items of a kind;
/// 4. a single item larger than the whole budget is still sent alone, so an
///    oversized payload can be rejected by the server instead of wedging the
///    queue forever (M23: nothing is dropped locally).
OutboxBatch selectBatch({
  required List<OutboxRecord> candidates,
  required DateTime now,
  BatchLimits limits = const BatchLimits.standard(),
}) {
  final List<OutboxRecord> eligible =
      candidates.where((OutboxRecord i) => i.isDueAt(now)).toList(growable: false)
        ..sort(_byDeviceSeq);

  if (eligible.isEmpty) {
    return const OutboxBatch.empty();
  }

  final Map<OutboxKind, int> taken = <OutboxKind, int>{};
  final List<OutboxRecord> picked = <OutboxRecord>[];
  int bytes = 0;

  for (final OutboxRecord item in eligible) {
    final int used = taken[item.kind] ?? 0;
    if (used >= limits.capFor(item.kind)) {
      continue;
    }
    if (bytes + item.payloadBytes > limits.maxBytes) {
      continue;
    }
    picked.add(item);
    taken[item.kind] = used + 1;
    bytes += item.payloadBytes;
  }

  if (picked.isEmpty) {
    // Oversized head-of-line item: send it alone (M33 "min 1 element").
    return OutboxBatch(<OutboxRecord>[eligible.first]);
  }
  return OutboxBatch(List<OutboxRecord>.unmodifiable(picked));
}

/// Splits [batch] in half after `413 PAYLOAD_TOO_LARGE` (§6.1).
///
/// Returns the batch itself when it holds a single item — recursion stops there
/// and the item is reported as rejected instead of being retried forever.
List<OutboxBatch> splitBatch(OutboxBatch batch) {
  if (batch.length <= 1) {
    return <OutboxBatch>[batch];
  }
  final int mid = batch.length ~/ 2;
  return <OutboxBatch>[
    OutboxBatch(List<OutboxRecord>.unmodifiable(batch.items.sublist(0, mid))),
    OutboxBatch(List<OutboxRecord>.unmodifiable(batch.items.sublist(mid))),
  ];
}

int _byDeviceSeq(OutboxRecord a, OutboxRecord b) {
  final int bySeq = a.deviceSeq.compareTo(b.deviceSeq);
  return bySeq != 0 ? bySeq : a.id.compareTo(b.id);
}
