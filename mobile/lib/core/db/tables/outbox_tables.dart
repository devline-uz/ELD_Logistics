/// `outbox_items` — universal chiqish navbati (§5.1, M24, M25).
library;

import 'package:drift/drift.dart';

@DataClassName('OutboxItemRow')
@TableIndex(name: 'idx_outbox_ready', columns: <Symbol>{#state, #nextAttemptAt, #deviceSeq})
@TableIndex(name: 'idx_outbox_kind_state', columns: <Symbol>{#kind, #state})
@TableIndex(name: 'idx_outbox_reject_seen', columns: <Symbol>{#state, #rejectSeen})
class OutboxItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `event`/`telemetry`/`dvir`/`chat`/`certify`/`claim`/`log_edit`/
  /// `push_token`/`feedback`/`support` — `OutboxKind.wire`.
  TextColumn get kind => text().withLength(min: 1, max: 32)();

  /// Serializatsiya qilingan so'rov tanasi.
  TextColumn get payload => text()();

  /// Qurilmada generatsiya qilingan barqaror UUID v4 (M19).
  TextColumn get clientId => text().withLength(min: 1, max: 64)();

  /// Yuborish tartibi shu ustun bo'yicha (M20, M25).
  IntColumn get deviceSeq => integer()();

  /// 0 — asosiy haydovchi, 1 — co-driver (§3).
  IntColumn get sessionSlot => integer().withDefault(const Constant<int>(0))();

  TextColumn get userId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  IntColumn get attempts => integer().withDefault(const Constant<int>(0))();

  DateTimeColumn get nextAttemptAt => dateTime()();

  /// `pending`/`inflight`/`acked`/`rejected` — `OutboxState.wire`.
  TextColumn get state => text().withDefault(const Constant<String>('pending'))();

  /// M33.6: batch kaliti saqlanadi, timeout dan keyin **aynan o'sha** kalit ketadi.
  TextColumn get idempotencyKey => text().nullable()();

  /// §5.6 `reason`; `superseded` bo'lsa element `acked` bo'ladi (M29).
  TextColumn get rejectReason => text().nullable()();

  /// `M-55` da qizil nuqta uchun (M30).
  BoolColumn get rejectSeen => boolean().withDefault(const Constant<bool>(false))();

  /// `superseded` natijadagi yutgan event server id si.
  TextColumn get supersededBy => text().nullable()();

  /// Oxirgi transport xatosi kodi (diagnostika, `M-54`).
  TextColumn get lastError => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{kind, clientId},
  ];
}
