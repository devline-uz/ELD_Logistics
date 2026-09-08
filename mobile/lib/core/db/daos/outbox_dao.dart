/// `outbox_items` DAO — navbatni o'qish va natijalarni yozish (§5.3).
library;

import 'package:drift/drift.dart';
import 'package:sync_core/sync_core.dart';

import '../app_database.dart';

part 'outbox_dao.g.dart';

/// Turlar bo'yicha navbat kesimi — `M-54` uchun (M28).
class OutboxQueueStats {
  const OutboxQueueStats({
    required this.pendingByKind,
    required this.inflight,
    required this.rejected,
    required this.unseenRejected,
  });

  final Map<OutboxKind, int> pendingByKind;
  final int inflight;
  final int rejected;
  final int unseenRejected;

  int get pendingTotal => pendingByKind.values.fold(0, (int a, int b) => a + b);

  bool get hasConflicts => rejected > 0;
}

@DriftAccessor(tables: <Type>[OutboxItems])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  /// Yuborishga tayyor elementlar, `device_seq` bo'yicha o'sish tartibida (M25).
  ///
  /// [limit] — SQL darajasidagi qo'pol chegara; aniq batch
  /// [selectBatchesBySlot] bilan `sync_core` da yig'iladi.
  ///
  /// **B-120:** [slots] berilgan bo'lsa faqat o'sha `session_slot` lar
  /// o'qiladi — tokeni yo'q sessiyaning yozuvlari navbatda **qoladi**, ular
  /// hech qachon boshqa haydovchining tokeni bilan yuborilmaydi.
  Future<List<OutboxItemRow>> dueItems({
    required DateTime now,
    int limit = 6000,
    Set<int>? slots,
  }) =>
      (select(outboxItems)
            ..where((OutboxItems t) {
              final Expression<bool> due =
                  t.state.equals(OutboxState.pending.wire) &
                  t.nextAttemptAt.isSmallerOrEqualValue(now);
              return slots == null ? due : due & t.sessionSlot.isIn(slots);
            })
            ..orderBy(<OrderClauseGenerator<OutboxItems>>[
              (OutboxItems t) => OrderingTerm.asc(t.deviceSeq),
              (OutboxItems t) => OrderingTerm.asc(t.id),
            ])
            ..limit(limit))
          .get();

  /// `dueItems` natijasini `sync_core` yozuvlariga o'giradi.
  Future<List<OutboxRecord>> dueRecords({
    required DateTime now,
    int limit = 6000,
    Set<int>? slots,
  }) async =>
      (await dueItems(now: now, limit: limit, slots: slots)).map(toRecord).toList(growable: false);

  /// Slot bo'yicha kutayotgan elementlar soni — `M-54` diagnostikasi va
  /// «co-driver navbati yo'qolmadi» tekshiruvi uchun.
  Future<Map<int, int>> pendingCountBySlot() async {
    final List<OutboxItemRow> rows = await (select(
      outboxItems,
    )..where((OutboxItems t) => t.state.equals(OutboxState.pending.wire))).get();
    final Map<int, int> counts = <int, int>{};
    for (final OutboxItemRow row in rows) {
      counts[row.sessionSlot] = (counts[row.sessionSlot] ?? 0) + 1;
    }
    return counts;
  }

  /// Drift qatorini sof Dart yozuviga aylantiradi.
  static OutboxRecord toRecord(OutboxItemRow row) => OutboxRecord(
    id: row.id,
    kind: OutboxKind.fromWire(row.kind),
    clientId: row.clientId,
    deviceSeq: row.deviceSeq,
    payloadJson: row.payload,
    createdAt: row.createdAt,
    nextAttemptAt: row.nextAttemptAt,
    state: OutboxState.fromWire(row.state),
    attempts: row.attempts,
    idempotencyKey: row.idempotencyKey,
    sessionSlot: row.sessionSlot,
    userId: row.userId,
  );

  /// Navbat holati oqimi — `StreamProvider` uchun.
  Stream<OutboxQueueStats> watchStats() {
    final Stream<List<OutboxItemRow>> rows = (select(
      outboxItems,
    )..where((OutboxItems t) => t.state.isNotValue(OutboxState.acked.wire))).watch();
    return rows.map((List<OutboxItemRow> items) {
      final Map<OutboxKind, int> pending = <OutboxKind, int>{};
      int inflight = 0;
      int rejected = 0;
      int unseen = 0;
      for (final OutboxItemRow row in items) {
        switch (OutboxState.fromWire(row.state)) {
          case OutboxState.pending:
            final OutboxKind kind = OutboxKind.fromWire(row.kind);
            pending[kind] = (pending[kind] ?? 0) + 1;
          case OutboxState.inflight:
            inflight++;
          case OutboxState.rejected:
            rejected++;
            if (!row.rejectSeen) {
              unseen++;
            }
          case OutboxState.acked:
            break;
        }
      }
      return OutboxQueueStats(
        pendingByKind: pending,
        inflight: inflight,
        rejected: rejected,
        unseenRejected: unseen,
      );
    });
  }

  /// `M-55` ro'yxati: rad etilgan va almashtirilgan elementlar (M30).
  Stream<List<OutboxItemRow>> watchConflicts() =>
      (select(outboxItems)
            ..where(
              (OutboxItems t) =>
                  t.state.equals(OutboxState.rejected.wire) |
                  t.supersededBy.isNotNull() |
                  t.rejectReason.isNotNull(),
            )
            ..orderBy(<OrderClauseGenerator<OutboxItems>>[
              (OutboxItems t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .watch();

  /// Backoff kechikishini navbatga yozadi (§5.4 — kechikish
  /// `next_attempt_at` da saqlanadi, xotirada emas).
  Future<int> deferPending({required DateTime until, required DateTime now}) =>
      (update(outboxItems)..where(
            (OutboxItems t) =>
                t.state.equals(OutboxState.pending.wire) &
                t.nextAttemptAt.isSmallerThanValue(until),
          ))
          .write(
            OutboxItemsCompanion(
              nextAttemptAt: Value<DateTime>(until),
              updatedAt: Value<DateTime>(now),
            ),
          );

  /// `Retry now` (M28): backoff kechikishi bekor qilinadi, navbat darhol tayyor.
  Future<int> releaseQueueNow(DateTime now) =>
      (update(outboxItems)..where(
            (OutboxItems t) =>
                t.state.equals(OutboxState.pending.wire) & t.nextAttemptAt.isBiggerThanValue(now),
          ))
          .write(
            OutboxItemsCompanion(
              nextAttemptAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );

  /// Batch elementlarini `inflight` qiladi va kalitni saqlaydi (M33.3).
  Future<void> markInflight({
    required List<int> ids,
    required String idempotencyKey,
    required DateTime now,
  }) async {
    if (ids.isEmpty) {
      return;
    }
    await (update(outboxItems)..where((OutboxItems t) => t.id.isIn(ids))).write(
      OutboxItemsCompanion(
        state: Value<String>(OutboxState.inflight.wire),
        idempotencyKey: Value<String>(idempotencyKey),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  /// Javob kelmadi: `inflight → pending`, kalit **saqlanadi** (M33.6).
  Future<void> releaseInflight({
    required List<int> ids,
    required DateTime nextAttemptAt,
    required DateTime now,
    String? lastError,
  }) async {
    if (ids.isEmpty) {
      return;
    }
    // `attempts` SQL da oshiriladi: o'qib-yozish poygasi bo'lmasin.
    await (update(outboxItems)..where((OutboxItems t) => t.id.isIn(ids))).write(
      OutboxItemsCompanion.custom(
        state: Constant<String>(OutboxState.pending.wire),
        nextAttemptAt: Variable<DateTime>(nextAttemptAt),
        attempts: outboxItems.attempts + const Constant<int>(1),
        lastError: Variable<String>(lastError),
        updatedAt: Variable<DateTime>(now),
      ),
    );
  }

  /// `409 IDEMPOTENCY_CONFLICT`: eski kalit tashlanadi, batch qayta yig'iladi (M33.7).
  Future<void> resetIdempotencyKey({required List<int> ids, required DateTime now}) async {
    if (ids.isEmpty) {
      return;
    }
    await (update(outboxItems)..where((OutboxItems t) => t.id.isIn(ids))).write(
      OutboxItemsCompanion(
        state: Value<String>(OutboxState.pending.wire),
        idempotencyKey: const Value<String?>(null),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  /// Bitta element uchun server verdiktini yozadi.
  Future<void> applyOutcome({
    required int id,
    required PushOutcome outcome,
    required DateTime now,
  }) async {
    final bool acked = outcome.outcome == OutboxOutcome.acked;
    await (update(outboxItems)..where((OutboxItems t) => t.id.equals(id))).write(
      OutboxItemsCompanion(
        state: Value<String>(acked ? OutboxState.acked.wire : OutboxState.rejected.wire),
        rejectReason: Value<String?>(outcome.reason?.wire),
        supersededBy: Value<String?>(outcome.supersededBy),
        rejectSeen: Value<bool>(!outcome.showsInConflicts),
        lastError: const Value<String?>(null),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  /// `M-55` ochilganda qizil nuqta o'chadi (M30).
  Future<void> markConflictsSeen(DateTime now) =>
      (update(outboxItems)..where((OutboxItems t) => t.rejectSeen.equals(false))).write(
        OutboxItemsCompanion(rejectSeen: const Value<bool>(true), updatedAt: Value<DateTime>(now)),
      );

  /// Foydalanuvchi `M-55` da «qayta yuborish» bosdi (`time_in_future`).
  Future<void> requeue({required int id, required DateTime now}) =>
      (update(outboxItems)..where((OutboxItems t) => t.id.equals(id))).write(
        OutboxItemsCompanion(
          state: Value<String>(OutboxState.pending.wire),
          nextAttemptAt: Value<DateTime>(now),
          rejectReason: const Value<String?>(null),
          idempotencyKey: const Value<String?>(null),
          attempts: const Value<int>(0),
          updatedAt: Value<DateTime>(now),
        ),
      );

  /// Ilova ishga tushganda osilib qolgan `inflight` larni qaytaradi.
  ///
  /// Jarayon o'ldirilgan bo'lsa element `inflight` bo'lib qolishi mumkin;
  /// kalit saqlanadi, shuning uchun qayta yuborish server tomonida dublikat
  /// bo'ladi, event **yo'qolmaydi** (M33.6).
  Future<int> recoverInflight(DateTime now) =>
      (update(
        outboxItems,
      )..where((OutboxItems t) => t.state.equals(OutboxState.inflight.wire))).write(
        OutboxItemsCompanion(
          state: Value<String>(OutboxState.pending.wire),
          nextAttemptAt: Value<DateTime>(now),
          updatedAt: Value<DateTime>(now),
        ),
      );
}
