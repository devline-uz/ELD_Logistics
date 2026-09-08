/// `LogEditsRepository` ning Drift + outbox implementatsiyasi (M135).
///
/// Approve/Reject **darhol** lokal holatga yoziladi va outbox'ga tushadi
/// (`kind=log_edit`); server `409` qaytarsa lokal holat pull'da
/// tenglashtiriladi (M135).
library;

import 'package:sync_core/sync_core.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/logs_dao.dart';
import '../../../core/sync/outbox_repository.dart';
import '../domain/log_edit_models.dart';
import '../domain/log_edits_repository.dart';

class DriftLogEditsRepository implements LogEditsRepository {
  DriftLogEditsRepository({required this._logs, required this._outbox, required this._driverId});

  final LogsDao _logs;
  final OutboxRepository _outbox;
  final String _driverId;

  @override
  Stream<List<LogEditRequestView>> watchPending() => _logs.watchPendingEdits().map(
    (List<LogEditRequestRow> rows) => <LogEditRequestView>[
      for (final LogEditRequestRow row in rows) logEditFromRow(row),
    ],
  );

  @override
  Stream<LogEditRequestView?> watchById(String id) =>
      watchPending().map((List<LogEditRequestView> list) {
        for (final LogEditRequestView item in list) {
          if (item.id == id) {
            return item;
          }
        }
        return null;
      });

  @override
  Future<void> approve(String id) => _decide(id: id, decision: LogEditDecision.approved);

  @override
  Future<void> reject({required String id, required String reason}) =>
      _decide(id: id, decision: LogEditDecision.rejected, reason: reason);

  Future<void> _decide({
    required String id,
    required LogEditDecision decision,
    String? reason,
  }) async {
    await _outbox.enqueue(
      kind: OutboxKind.logEdit,
      userId: _driverId,
      payload: compactPayload(<String, Object?>{
        'request_id': id,
        'decision': decision.wire,
        'reason': reason,
      }),
      writeBusinessRow: (String _, int _) =>
          _logs.setLocalDecision(id: id, decision: decision.wire),
    );
  }
}

/// Drift qatorini domen ko'rinishiga o'giradi (`changes` JSON tolerant).
LogEditRequestView logEditFromRow(LogEditRequestRow row) {
  final Object? rawChanges = row.changes['changes'] ?? row.changes['items'];
  final List<LogEditChange> changes = <LogEditChange>[
    if (rawChanges is List<Object?>)
      for (final Object? item in rawChanges)
        if (_changeFrom(item) case final LogEditChange change) change,
  ];
  final LogEditDecision decision = LogEditDecision.fromWire(row.localDecision);

  return LogEditRequestView(
    id: row.id,
    logDate: row.logDate,
    createdAt: row.createdAt,
    source: LogEditSource.fromWire(row.source),
    requestedBy: row.changes['requested_by'] is String
        ? row.changes['requested_by']! as String
        : null,
    changes: changes,
    decision: decision,
    pendingSync: decision != LogEditDecision.none && row.status == 'pending',
  );
}

LogEditChange? _changeFrom(Object? raw) {
  if (raw is! Map<String, Object?>) {
    return null;
  }
  final DateTime? from = _dt(raw['from']);
  final DateTime? to = _dt(raw['to']);
  if (from == null || to == null) {
    return null;
  }
  return LogEditChange(
    from: from,
    to: to,
    proposedStatus: _str(raw['status']) ?? '',
    proposedSpecial: _str(raw['special']) ?? 'none',
    currentStatus: _str(raw['current_status']),
    currentSpecial: _str(raw['current_special']) ?? 'none',
    note: _str(raw['note']),
    eventType: _str(raw['event_type']) ?? 'status_change',
    currentOrigin: _str(raw['current_origin']),
  );
}

DateTime? _dt(Object? raw) => raw is String ? DateTime.tryParse(raw)?.toUtc() : null;

String? _str(Object? raw) => raw is String && raw.isNotEmpty ? raw : null;
