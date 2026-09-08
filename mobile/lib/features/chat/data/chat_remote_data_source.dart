/// `swagger.json` `/chat/*` chaqiruvlari. `eld_api` generatsiyasi yoqilgach
/// shu sinf uning wrapper'iga aylanadi (M1) — imzo o'zgarmaydi.
library;

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/request_options_x.dart';
import '../domain/chat_message.dart';

/// Server javobi kutilgan shaklda emas (`data.id` yo'q).
class ChatResponseFormatException implements Exception {
  const ChatResponseFormatException();

  @override
  String toString() => 'ChatResponseFormatException: malformed chat message envelope';
}

abstract class ChatRemoteDataSource {
  /// `GET /chat/threads/{driver_id}/messages?before&limit`.
  Future<ChatPage> fetchMessages({required String driverId, DateTime? before, int limit = 50});

  /// `POST /chat/threads/{driver_id}/messages`.
  ///
  /// `409 DRIVING_MODE_BLOCKED` (M141) `ApiError` sifatida ko'tariladi.
  Future<ChatMessage> sendMessage({
    required String driverId,
    required String clientId,
    required ChatDraft draft,
    String? fileKey,
  });

  /// `POST /chat/messages/{id}/read`.
  Future<void> markRead(String messageId);
}

class HttpChatRemoteDataSource implements ChatRemoteDataSource {
  HttpChatRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<ChatPage> fetchMessages({required String driverId, DateTime? before, int limit = 50}) =>
      guardApiCall(() async {
        final Response<Map<String, Object?>> response = await _dio.get<Map<String, Object?>>(
          '/chat/threads/$driverId/messages',
          queryParameters: <String, Object?>{
            'limit': limit,
            if (before != null) 'before': before.toUtc().toIso8601String(),
          },
        );
        return _pageFrom(response.data, driverId);
      });

  @override
  Future<ChatMessage> sendMessage({
    required String driverId,
    required String clientId,
    required ChatDraft draft,
    String? fileKey,
  }) => guardApiCall(() async {
    final Response<Map<String, Object?>> response = await _dio.post<Map<String, Object?>>(
      '/chat/threads/$driverId/messages',
      data: <String, Object?>{
        'kind': draft.kind.wire,
        if (draft.text != null) 'text': draft.text,
        'file_key': ?fileKey,
        if (draft.lat != null) 'lat': draft.lat,
        if (draft.lng != null) 'lng': draft.lng,
      },
      // M19/M33: `client_id` idempotentlik kaliti — takroriy POST dublikat
      // yaratmaydi (tarmoq uzilib qayta urinilganda).
      options: Options(
        extra: <String, Object?>{
          RequestExtra.idempotent: true,
          RequestExtra.idempotencyKey: clientId,
        },
      ),
    );
    final ChatMessage? sent = _messageFrom(_envelope(response.data), driverId);
    if (sent == null) {
      throw const ChatResponseFormatException();
    }
    return sent;
  });

  @override
  Future<void> markRead(String messageId) =>
      guardApiCall(() => _dio.post<Map<String, Object?>>('/chat/messages/$messageId/read'));

  // --- Mapping (`chat_dto.*` → domen) -------------------------------------

  static Map<String, Object?> _envelope(Map<String, Object?>? body) {
    final Object? data = body?['data'];
    return data is Map<String, Object?> ? data : const <String, Object?>{};
  }

  ChatPage _pageFrom(Map<String, Object?>? body, String driverId) {
    final Object? raw = body?['data'];
    final List<ChatMessage> messages = <ChatMessage>[
      if (raw is List<Object?>)
        for (final Object? item in raw)
          if (item is Map<String, Object?>)
            if (_messageFrom(item, driverId) case final ChatMessage m) m,
    ]..sort((ChatMessage a, ChatMessage b) => a.createdAt.compareTo(b.createdAt));

    final Object? meta = body?['meta'];
    final Map<String, Object?> m = meta is Map<String, Object?> ? meta : const <String, Object?>{};
    return ChatPage(
      messages: messages,
      hasMore: m['has_more'] == true,
      nextBefore: _dateTime(m['next_before']),
      unread: m['unread'] is int ? m['unread']! as int : 0,
    );
  }

  ChatMessage? _messageFrom(Map<String, Object?> json, String driverId) {
    final Object? id = json['id'];
    if (id is! String || id.isEmpty) {
      return null;
    }
    final DateTime? sentAt = _dateTime(json['sent_at']);
    return ChatMessage(
      id: id,
      clientId: json['client_id'] is String ? json['client_id']! as String : null,
      kind: ChatMessageKind.fromWire(json['kind'] as String?),
      side: json['sender_side'] == 'driver' || json['sender_id'] == driverId
          ? ChatSenderSide.driver
          : ChatSenderSide.office,
      status: ChatMessageStatus.fromWire(json['status'] as String?),
      createdAt: sentAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      text: json['text'] as String?,
      fileKey: json['file_key'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  static DateTime? _dateTime(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toUtc() : null;
}
