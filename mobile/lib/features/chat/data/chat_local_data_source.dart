/// Drift ↔ domen o'girish (M5: Drift qatori `presentation` ga chiqmaydi).
///
/// **Navbat modeli (M138):** yuborilgan xabar ikki joyga yoziladi — bitta
/// tranzaksiyada (M24):
/// * `outbox_items` (`kind=chat`) — transport, `SyncEngine` shu yerdan oladi;
/// * `chat_messages` (`id = client_id`) — optimistik UI qatori (`queued`).
///
/// Server nusxasi `pull` orqali kelganda uning `client_id` si optimistik
/// qatorning `id` siga teng bo'ladi — [watchMessages] dublikatni tashlaydi.
library;

import 'package:drift/drift.dart' show Value;
import 'package:sync_core/sync_core.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/chat_dao.dart';
import '../../../core/sync/outbox_repository.dart';
import '../domain/chat_message.dart';

class ChatLocalDataSource {
  ChatLocalDataSource({required this._dao, required this._outbox, this.currentDriverId});

  final ChatDao _dao;
  final OutboxRepository _outbox;

  /// TODO(M-42): auth moduli tayyor bo'lgach sessiyadan olinadi. `null` bo'lsa
  /// «meniki» faqat `client_id` bo'yicha aniqlanadi (optimistik qatorlar).
  final String? currentDriverId;

  /// Eskidan yangiga tartiblangan xabarlar.
  Stream<List<ChatMessage>> watchMessages({int limit = 500}) =>
      _dao.watchMessages(limit: limit).map(toDomainList);

  /// Sof o'girish — test uchun ochiq.
  List<ChatMessage> toDomainList(List<ChatMessageRow> rows) {
    final Set<String> serverEchoes = <String>{
      for (final ChatMessageRow r in rows)
        if (r.clientId != null && r.clientId != r.id) r.clientId!,
    };
    final List<ChatMessage> messages = <ChatMessage>[
      for (final ChatMessageRow r in rows)
        if (!serverEchoes.contains(r.id)) _toDomain(r),
    ];
    messages.sort((ChatMessage a, ChatMessage b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  ChatMessage _toDomain(ChatMessageRow row) => ChatMessage(
    id: row.id,
    clientId: row.clientId,
    kind: ChatMessageKind.fromWire(row.kind),
    side: _sideOf(row),
    status: ChatMessageStatus.fromWire(row.status),
    createdAt: row.createdAt,
    text: row.body,
    fileKey: row.fileKey,
    lat: row.lat,
    lng: row.lng,
  );

  /// Optimistik qator (`client_id` bor) — har doim meniki; server qatori uchun
  /// `sender_id` solishtiriladi.
  ChatSenderSide _sideOf(ChatMessageRow row) {
    if (row.clientId != null) {
      return ChatSenderSide.driver;
    }
    final String? driverId = currentDriverId;
    if (driverId != null && row.senderId == driverId) {
      return ChatSenderSide.driver;
    }
    return ChatSenderSide.office;
  }

  /// Oflayn banneri uchun (`Offline — n messages queued`).
  Stream<int> watchQueuedCount() => _dao
      .watchMessages(limit: 500)
      .map(
        (List<ChatMessageRow> rows) =>
            rows.where((ChatMessageRow r) => r.status == ChatMessageStatus.queued.wire).length,
      );

  /// M138 + M24. Qaytadi: yaratilgan `client_id`.
  Future<String> enqueue({
    required ChatDraft draft,
    required DateTime createdAt,
    String? fileKey,
  }) async {
    final String clientId = _outbox.newClientId();
    await _outbox.enqueue(
      kind: OutboxKind.chat,
      clientId: clientId,
      payload: <String, Object?>{
        'client_id': clientId,
        'kind': draft.kind.wire,
        if (draft.text != null) 'text': draft.text,
        'file_key': ?fileKey,
        if (draft.lat != null) 'lat': draft.lat,
        if (draft.lng != null) 'lng': draft.lng,
      },
      writeBusinessRow: (String id, int _) => _dao.upsertMessage(
        ChatMessagesCompanion.insert(
          id: id,
          kind: draft.kind.wire,
          createdAt: createdAt,
          clientId: Value<String?>(id),
          body: Value<String?>(draft.text),
          fileKey: Value<String?>(fileKey),
          lat: Value<double?>(draft.lat),
          lng: Value<double?>(draft.lng),
          status: Value<String>(ChatMessageStatus.queued.wire),
        ),
      ),
    );
    return clientId;
  }

  /// Optimistik qator holatini almashtiradi (`queued` → `blocked`/`failed`).
  ///
  /// `ChatDao` da qisman `UPDATE` yo'q, shuning uchun to'liq qator qayta
  /// yoziladi — chaqiruvchi domen obyektini ushlab turadi.
  Future<void> setStatus(ChatMessage message, ChatMessageStatus status) =>
      upsert(message.copyWith(status: status));

  /// Domen obyektini keshga yozadi (server javobi yoki holat o'zgarishi).
  Future<void> upsert(ChatMessage message) => _dao.upsertMessage(
    ChatMessagesCompanion.insert(
      id: message.id,
      kind: message.kind.wire,
      createdAt: message.createdAt,
      clientId: Value<String?>(message.clientId),
      senderId: Value<String?>(message.side == ChatSenderSide.driver ? currentDriverId : null),
      body: Value<String?>(message.text),
      fileKey: Value<String?>(message.fileKey),
      lat: Value<double?>(message.lat),
      lng: Value<double?>(message.lng),
      status: Value<String>(message.status.wire),
    ),
  );

  /// To'g'ridan-to'g'ri REST muvaffaqiyatli bo'lganda navbat elementi yopiladi —
  /// `SyncEngine` uni qayta yubormaydi.
  Future<void> ackOutbox(String clientId) => _outbox.applyPushOutcomes(<String, PushOutcome>{
    clientId: const PushOutcome(outcome: OutboxOutcome.acked, reason: null),
  });
}
