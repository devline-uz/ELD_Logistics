/// Chat navbati/tarixi va bildirishnomalar DAO'si (§5.1, §14, §15).
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: <Type>[ChatOutbox, ChatMessages, Notifications])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  // --- chat ---------------------------------------------------------------

  Stream<List<ChatMessageRow>> watchMessages({String? conversationId, int limit = 200}) {
    final SimpleSelectStatement<ChatMessages, ChatMessageRow> query = select(chatMessages)
      ..orderBy(<OrderClauseGenerator<ChatMessages>>[
        (ChatMessages t) => OrderingTerm.desc(t.createdAt),
      ])
      ..limit(limit);
    if (conversationId != null) {
      query.where((ChatMessages t) => t.conversationId.equals(conversationId));
    }
    return query.watch();
  }

  Future<void> upsertMessage(ChatMessagesCompanion message) =>
      into(chatMessages).insertOnConflictUpdate(message);

  Future<void> enqueueMessage(ChatOutboxCompanion message) =>
      into(chatOutbox).insertOnConflictUpdate(message);

  Future<void> setOutboxStatus({required String clientId, required String status}) =>
      (update(chatOutbox)..where((ChatOutbox t) => t.clientId.equals(clientId))).write(
        ChatOutboxCompanion(status: Value<String>(status)),
      );

  /// §5.2 LRU: 30 kundan eski **va** oxirgi [keep] tadan tashqaridagilar.
  Future<int> trimMessages({required DateTime before, required int keep}) => customUpdate(
    'DELETE FROM chat_messages WHERE created_at < ? AND id NOT IN '
    '(SELECT id FROM chat_messages ORDER BY created_at DESC LIMIT ?)',
    variables: <Variable<Object>>[Variable<DateTime>(before), Variable<int>(keep)],
    updates: <TableInfo<Table, Object>>{chatMessages},
    updateKind: UpdateKind.delete,
  );

  // --- notifications ------------------------------------------------------

  Stream<List<NotificationRow>> watchNotifications({int limit = 100}) =>
      (select(notifications)
            ..orderBy(<OrderClauseGenerator<Notifications>>[
              (Notifications t) => OrderingTerm.desc(t.createdAt),
            ])
            ..limit(limit))
          .watch();

  Stream<int> watchUnreadCount() {
    final Expression<int> count = notifications.id.count();
    return (selectOnly(notifications)
          ..addColumns(<Expression<Object>>[count])
          ..where(notifications.read.equals(false)))
        .map((TypedResult row) => row.read(count) ?? 0)
        .watchSingle();
  }

  Future<void> upsertNotification(NotificationsCompanion notification) =>
      into(notifications).insertOnConflictUpdate(notification);

  Future<void> markRead(String id) =>
      (update(notifications)..where((Notifications t) => t.id.equals(id))).write(
        const NotificationsCompanion(read: Value<bool>(true)),
      );

  Future<int> deleteNotificationsBefore(DateTime before) => (delete(
    notifications,
  )..where((Notifications t) => t.createdAt.isSmallerThanValue(before))).go();
}
