/// Chat navbati/tarixi va bildirishnomalar keshi (§5.1, §14, §15).
library;

import 'package:drift/drift.dart';

@DataClassName('ChatOutboxRow')
@TableIndex(name: 'idx_chat_outbox_status', columns: <Symbol>{#status, #createdAt})
class ChatOutbox extends Table {
  TextColumn get clientId => text()();

  TextColumn get conversationId => text().nullable()();

  /// `text`/`file`/`location`.
  TextColumn get kind => text()();

  /// Getter nomi `body`, SQL ustuni `text`: `text()` quruvchisi bilan
  /// nom to'qnashuvi bo'lmasin (drift_dev buni tahlil qila olmaydi).
  TextColumn get body => text().nullable().named('text')();

  TextColumn get fileKey => text().nullable()();

  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();

  /// `queued`/`sent`/`delivered`/`read`/`failed`.
  TextColumn get status => text().withDefault(const Constant<String>('queued'))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{clientId};
}

@DataClassName('ChatMessageRow')
@TableIndex(name: 'idx_chat_messages_created', columns: <Symbol>{#createdAt})
class ChatMessages extends Table {
  TextColumn get id => text()();

  /// Optimistik yozuvni server nusxasi bilan bog'laydi.
  TextColumn get clientId => text().nullable()();

  TextColumn get conversationId => text().nullable()();

  TextColumn get senderId => text().nullable()();

  TextColumn get kind => text()();

  /// Getter nomi `body`, SQL ustuni `text`: `text()` quruvchisi bilan
  /// nom to'qnashuvi bo'lmasin (drift_dev buni tahlil qila olmaydi).
  TextColumn get body => text().nullable().named('text')();

  TextColumn get fileKey => text().nullable()();

  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();

  /// `queued`/`sent`/`delivered`/`read`/`failed`.
  TextColumn get status => text().withDefault(const Constant<String>('sent'))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('NotificationRow')
@TableIndex(name: 'idx_notifications_read', columns: <Symbol>{#read, #createdAt})
class Notifications extends Table {
  TextColumn get id => text()();

  TextColumn get alertType => text()();

  TextColumn get title => text()();

  TextColumn get body => text()();

  TextColumn get entityType => text().nullable()();

  TextColumn get entityId => text().nullable()();

  BoolColumn get read => boolean().withDefault(const Constant<bool>(false))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
