@Timeout(Duration(seconds: 60))
library;

import 'package:sync_core/sync_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('dueSlots', () {
    test('returns distinct slots of due items, ascending', () {
      final List<int> slots = dueSlots(
        candidates: <OutboxRecord>[rec(id: 1, slot: 1), rec(id: 2, slot: 0), rec(id: 3, slot: 1)],
        now: t0,
      );
      expect(slots, <int>[0, 1]);
    });

    test('ignores items that are not due yet', () {
      final List<int> slots = dueSlots(
        candidates: <OutboxRecord>[
          rec(id: 1, slot: 0),
          rec(id: 2, slot: 1, nextAttemptAt: t0.add(const Duration(minutes: 5))),
          rec(id: 3, slot: 1, state: OutboxState.inflight),
        ],
        now: t0,
      );
      expect(slots, <int>[kPrimarySlot]);
    });

    test('empty queue yields no slots', () {
      expect(dueSlots(candidates: const <OutboxRecord>[], now: t0), isEmpty);
    });
  });

  group('selectBatchesBySlot', () {
    test('B-120: a batch never mixes two slots', () {
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: <OutboxRecord>[
          rec(id: 1, slot: 0),
          rec(id: 2, slot: 1),
          rec(id: 3, slot: 0),
          rec(id: 4, slot: 1),
        ],
        now: t0,
      );
      expect(groups, hasLength(2));
      for (final SlotBatch group in groups) {
        expect(
          group.batch.items.every((OutboxRecord i) => i.sessionSlot == group.sessionSlot),
          isTrue,
        );
      }
      expect(groups.map((SlotBatch g) => g.sessionSlot), <int>[0, 1]);
      expect(groups.first.length, 2);
      expect(groups.last.length, 2);
    });

    test('M25: order inside a slot stays device_seq ascending', () {
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: <OutboxRecord>[
          rec(id: 9, seq: 30, slot: 1),
          rec(id: 7, seq: 10, slot: 1),
          rec(id: 8, seq: 20, slot: 1),
        ],
        now: t0,
      );
      expect(groups.single.batch.items.map((OutboxRecord i) => i.deviceSeq), <int>[10, 20, 30]);
    });

    test('firstSlot (active driver) is sent first', () {
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: <OutboxRecord>[rec(id: 1, slot: 0), rec(id: 2, slot: 1)],
        now: t0,
        firstSlot: kCoDriverSlot,
      );
      expect(groups.map((SlotBatch g) => g.sessionSlot), <int>[1, 0]);
    });

    test('unknown firstSlot does not disturb the ascending order', () {
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: <OutboxRecord>[rec(id: 1, slot: 1), rec(id: 2, slot: 0)],
        now: t0,
        firstSlot: 7,
      );
      expect(groups.map((SlotBatch g) => g.sessionSlot), <int>[0, 1]);
    });

    test('allowedSlots gates a token-less slot; its items stay queued', () {
      final List<OutboxRecord> candidates = <OutboxRecord>[
        rec(id: 1, slot: 0),
        rec(id: 2, slot: 1),
      ];
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: candidates,
        now: t0,
        allowedSlots: <int>{kPrimarySlot},
      );
      expect(groups, hasLength(1));
      expect(groups.single.sessionSlot, kPrimarySlot);
      // M23: the co-driver item is not consumed — it is simply not selected.
      expect(candidates.where((OutboxRecord i) => i.sessionSlot == kCoDriverSlot), hasLength(1));
    });

    test('empty allowedSlots blocks every group', () {
      expect(
        selectBatchesBySlot(
          candidates: <OutboxRecord>[rec(id: 1, slot: 0)],
          now: t0,
          allowedSlots: const <int>{},
        ),
        isEmpty,
      );
    });

    test('null allowedSlots means no gate', () {
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: <OutboxRecord>[rec(id: 1, slot: 0), rec(id: 2, slot: 1)],
        now: t0,
      );
      expect(groups, hasLength(2));
    });

    test('limits apply per slot, not across the whole queue', () {
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: <OutboxRecord>[
          rec(id: 1, slot: 0),
          rec(id: 2, slot: 0),
          rec(id: 3, slot: 1),
          rec(id: 4, slot: 1),
        ],
        now: t0,
        limits: const BatchLimits(events: 1),
      );
      expect(groups.map((SlotBatch g) => g.length), <int>[1, 1]);
    });

    test('not-due and non-pending items are excluded', () {
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: <OutboxRecord>[
          rec(id: 1, slot: 0, state: OutboxState.acked),
          rec(id: 2, slot: 1, nextAttemptAt: t0.add(const Duration(seconds: 1))),
        ],
        now: t0,
      );
      expect(groups, isEmpty);
    });

    test('empty candidate list yields an empty, const-like result', () {
      expect(selectBatchesBySlot(candidates: const <OutboxRecord>[], now: t0), isEmpty);
    });

    test('result is unmodifiable', () {
      final List<SlotBatch> groups = selectBatchesBySlot(
        candidates: <OutboxRecord>[rec(id: 1, slot: 0)],
        now: t0,
      );
      expect(
        () => groups.add(const SlotBatch(sessionSlot: 1, batch: OutboxBatch.empty())),
        throwsUnsupportedError,
      );
    });

    test('SlotBatch exposes size helpers and a readable toString', () {
      final SlotBatch group = selectBatchesBySlot(
        candidates: <OutboxRecord>[rec(id: 1, slot: 1, bytes: 40)],
        now: t0,
      ).single;
      expect(group.isEmpty, isFalse);
      expect(group.isNotEmpty, isTrue);
      expect(group.length, 1);
      expect(group.bytes, 40);
      expect(group.toString(), contains('slot=1'));
      expect(const SlotBatch(sessionSlot: 0, batch: OutboxBatch.empty()).isEmpty, isTrue);
    });

    test('1000 events across two slots keep device_seq order per slot', () {
      final List<OutboxRecord> candidates = <OutboxRecord>[
        for (int i = 0; i < 1000; i++)
          rec(id: i + 1, seq: i + 1, slot: i.isEven ? 0 : 1, bytes: 10),
      ];
      final List<SlotBatch> groups = selectBatchesBySlot(candidates: candidates, now: t0);
      expect(groups, hasLength(2));
      for (final SlotBatch group in groups) {
        final List<int> seqs = group.batch.items
            .map((OutboxRecord i) => i.deviceSeq)
            .toList(growable: false);
        expect(seqs, orderedEquals(<int>[...seqs]..sort()));
        expect(seqs, hasLength(500));
      }
    });
  });
}
