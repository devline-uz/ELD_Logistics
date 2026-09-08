import 'package:sync_core/sync_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('BatchLimits', () {
    test('standard limits match §6.1', () {
      const BatchLimits limits = BatchLimits.standard();
      expect(limits.capFor(OutboxKind.event), 500);
      expect(limits.capFor(OutboxKind.telemetry), 5000);
      expect(limits.capFor(OutboxKind.dvir), 100);
      expect(limits.capFor(OutboxKind.chat), 500);
      expect(limits.capFor(OutboxKind.certify), 500);
      expect(limits.maxBytes, 4 * 1024 * 1024);
    });

    test('metered profile only throttles telemetry (M27)', () {
      const BatchLimits metered = BatchLimits.metered();
      expect(metered.capFor(OutboxKind.telemetry), 1000);
      expect(metered.capFor(OutboxKind.event), 500);
    });

    test('copyWith overrides selected caps', () {
      final BatchLimits limits = const BatchLimits.standard().copyWith(
        events: 2,
        telemetry: 3,
        dvir: 4,
        chat: 5,
        maxBytes: 6,
      );
      expect(limits.capFor(OutboxKind.event), 2);
      expect(limits.capFor(OutboxKind.telemetry), 3);
      expect(limits.capFor(OutboxKind.dvir), 4);
      expect(limits.capFor(OutboxKind.chat), 5);
      expect(limits.maxBytes, 6);
    });
  });

  group('selectBatch', () {
    test('returns an empty batch when nothing is due', () {
      final OutboxBatch batch = selectBatch(
        candidates: <OutboxRecord>[
          rec(id: 1, nextAttemptAt: t0.add(const Duration(seconds: 30))),
          rec(id: 2, state: OutboxState.inflight),
          rec(id: 3, state: OutboxState.rejected),
        ],
        now: t0,
      );
      expect(batch.isEmpty, isTrue);
      expect(batch.isNotEmpty, isFalse);
      expect(batch.bytes, 0);
      expect(batch.maxDeviceSeq, isNull);
      expect(const OutboxBatch.empty().items, isEmpty);
    });

    test('orders by device_seq ascending (M25) regardless of insertion order', () {
      final OutboxBatch batch = selectBatch(
        candidates: <OutboxRecord>[rec(id: 3, seq: 30), rec(id: 1, seq: 10), rec(id: 2, seq: 20)],
        now: t0,
      );
      expect(batch.items.map((OutboxRecord i) => i.deviceSeq), <int>[10, 20, 30]);
      expect(batch.maxDeviceSeq, 30);
      expect(batch.length, 3);
    });

    test('breaks device_seq ties by id so the order is total', () {
      final OutboxBatch batch = selectBatch(
        candidates: <OutboxRecord>[rec(id: 9, seq: 5), rec(id: 4, seq: 5)],
        now: t0,
      );
      expect(batch.items.map((OutboxRecord i) => i.id), <int>[4, 9]);
    });

    test('applies the per-kind cap and keeps the other kinds flowing', () {
      final List<OutboxRecord> candidates = <OutboxRecord>[
        rec(id: 1, kind: OutboxKind.event, seq: 1),
        rec(id: 2, kind: OutboxKind.event, seq: 2),
        rec(id: 3, kind: OutboxKind.event, seq: 3),
        rec(id: 4, kind: OutboxKind.chat, seq: 4),
      ];
      final OutboxBatch batch = selectBatch(
        candidates: candidates,
        now: t0,
        limits: const BatchLimits.standard().copyWith(events: 2),
      );
      expect(batch.ofKind(OutboxKind.event).map((OutboxRecord i) => i.deviceSeq), <int>[1, 2]);
      expect(batch.ofKind(OutboxKind.chat).length, 1);
      expect(batch.countsByKind, <OutboxKind, int>{OutboxKind.event: 2, OutboxKind.chat: 1});
    });

    test('respects the total byte budget', () {
      final OutboxBatch batch = selectBatch(
        candidates: <OutboxRecord>[
          rec(id: 1, seq: 1, bytes: 60),
          rec(id: 2, seq: 2, bytes: 60),
          rec(id: 3, seq: 3, bytes: 30),
        ],
        now: t0,
        limits: const BatchLimits.standard().copyWith(maxBytes: 100),
      );
      // #2 overflows and is skipped; #3 still fits.
      expect(batch.items.map((OutboxRecord i) => i.id), <int>[1, 3]);
      expect(batch.bytes, 90);
    });

    test('sends an oversized head-of-line item alone instead of wedging (M23)', () {
      final OutboxBatch batch = selectBatch(
        candidates: <OutboxRecord>[rec(id: 1, seq: 1, bytes: 500), rec(id: 2, seq: 2, bytes: 10)],
        now: t0,
        limits: const BatchLimits.standard().copyWith(maxBytes: 5),
      );
      expect(batch.length, 1);
      expect(batch.items.single.id, 1);
    });

    test('metered telemetry cap is honoured while events are not delayed', () {
      final List<OutboxRecord> candidates = <OutboxRecord>[
        for (int i = 0; i < 1200; i++)
          rec(id: i + 1, kind: OutboxKind.telemetry, seq: i + 1, bytes: 10),
        rec(id: 5000, kind: OutboxKind.event, seq: 5000, bytes: 10),
      ];
      final OutboxBatch batch = selectBatch(
        candidates: candidates,
        now: t0,
        limits: const BatchLimits.metered(),
      );
      expect(batch.ofKind(OutboxKind.telemetry).length, 1000);
      expect(batch.ofKind(OutboxKind.event).length, 1);
    });

    test('toString reports size', () {
      final OutboxBatch batch = selectBatch(
        candidates: <OutboxRecord>[rec(id: 1, bytes: 7)],
        now: t0,
      );
      expect(batch.toString(), 'OutboxBatch(1 items, 7 B)');
    });
  });

  group('splitBatch', () {
    test('halves the batch preserving order', () {
      final OutboxBatch batch = OutboxBatch(<OutboxRecord>[
        rec(id: 1, seq: 1),
        rec(id: 2, seq: 2),
        rec(id: 3, seq: 3),
        rec(id: 4, seq: 4),
        rec(id: 5, seq: 5),
      ]);
      final List<OutboxBatch> halves = splitBatch(batch);
      expect(halves, hasLength(2));
      expect(halves[0].items.map((OutboxRecord i) => i.id), <int>[1, 2]);
      expect(halves[1].items.map((OutboxRecord i) => i.id), <int>[3, 4, 5]);
    });

    test('stops at a single element', () {
      final OutboxBatch one = OutboxBatch(<OutboxRecord>[rec(id: 1)]);
      expect(splitBatch(one).single.length, 1);
      expect(splitBatch(const OutboxBatch.empty()).single.isEmpty, isTrue);
    });
  });
}
