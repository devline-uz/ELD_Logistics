/// `UnidentifiedRepository` ning Drift + outbox implementatsiyasi.
///
/// Claim **doim** outbox orqali ketadi (`kind=claim`, M100 oflayn qatori);
/// `Not mine` faqat lokal belgidir.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sync_core/sync_core.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/logs_dao.dart';
import '../../../core/sync/outbox_repository.dart';
import '../../../core/util/stream_combine.dart';
import '../domain/unidentified_models.dart';

class DriftUnidentifiedRepository implements UnidentifiedRepository {
  DriftUnidentifiedRepository({
    required this._db,
    required this._logs,
    required this._outbox,
    required this._driverId,
  });

  final AppDatabase _db;
  final LogsDao _logs;
  final OutboxRepository _outbox;
  final String _driverId;

  @override
  Stream<List<UnidentifiedBlock>> watchClaimable() =>
      combineLatest2<List<UnidentifiedEventRow>, Set<String>, List<UnidentifiedBlock>>(
        _logs.watchClaimable(),
        _watchPendingClaims(),
        (List<UnidentifiedEventRow> rows, Set<String> pending) => <UnidentifiedBlock>[
          for (final UnidentifiedEventRow row in rows)
            UnidentifiedBlock(
              id: row.id,
              unitId: row.unitId,
              start: row.startAt,
              end: row.endAt,
              distanceM: row.distanceM,
              status: UnidentifiedStatus.fromWire(row.status),
              pendingSync: pending.contains(row.id),
            ),
        ],
      );

  @override
  Future<ClaimOutcome> claim(String id) async {
    final UnidentifiedEventRow? row = await _rowOf(id);
    if (row != null && UnidentifiedStatus.fromWire(row.status) != UnidentifiedStatus.pending) {
      // Pull allaqachon boshqa haydovchiga biriktirilganini ko'rsatgan.
      await _logs.dismissUnidentified(id);
      return ClaimOutcome.alreadyAssigned;
    }
    await _outbox.enqueue(
      kind: OutboxKind.claim,
      userId: _driverId,
      payload: compactPayload(<String, Object?>{'event_id': id, 'driver_id': _driverId}),
    );
    return ClaimOutcome.queued;
  }

  @override
  Future<void> dismiss(String id) => _logs.dismissUnidentified(id);

  Future<UnidentifiedEventRow?> _rowOf(String id) async {
    final List<UnidentifiedEventRow> rows = await _logs.watchClaimable().first;
    for (final UnidentifiedEventRow row in rows) {
      if (row.id == id) {
        return row;
      }
    }
    return null;
  }

  Stream<Set<String>> _watchPendingClaims() =>
      (_db.select(_db.outboxItems)..where(
            ($OutboxItemsTable t) =>
                t.kind.equals(OutboxKind.claim.wire) &
                t.state.isIn(<String>[OutboxState.pending.wire, OutboxState.inflight.wire]),
          ))
          .watch()
          .map(
            (List<OutboxItemRow> rows) => <String>{
              for (final OutboxItemRow row in rows)
                if (_eventIdOf(row.payload) case final String id) id,
            },
          );

  String? _eventIdOf(String payloadJson) {
    final Object? decoded = jsonDecode(payloadJson);
    if (decoded is Map<String, Object?> && decoded['event_id'] is String) {
      return decoded['event_id']! as String;
    }
    return null;
  }
}
