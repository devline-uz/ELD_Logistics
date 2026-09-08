/// `GET/POST /support-tickets`, `GET /support-tickets/{id}`,
/// `GET/POST /support-tickets/{id}/messages` (`contracts/swagger.json`).
///
/// Javob konverti: `{"data": …, "meta": …}`. Xatolar `guardApiCall` orqali
/// `ApiError` ga aylanadi; oflayn yozish amallari outbox'ga tushadi (§5.3).
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_core/sync_core.dart';

import '../../../core/error/api_error.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/request_options_x.dart';
import '../../../core/sync/outbox_repository.dart';
import '../../../core/sync/sync_providers.dart';
import '../../profile/data/api_providers.dart';
import '../../profile/domain/submit_outcome.dart';
import '../domain/support_repository.dart';
import '../domain/support_ticket.dart';
import '../domain/ticket_draft.dart';

class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl({required this._dio, required this._outbox});

  final Dio _dio;
  final OutboxRepository _outbox;

  @override
  Future<List<SupportTicket>> list() => guardApiCall<List<SupportTicket>>(() async {
    final Response<Map<String, Object?>> res = await _dio.get<Map<String, Object?>>(
      '/support-tickets',
    );
    return _listData(res.data).map(_ticket).toList(growable: false);
  });

  @override
  Future<TicketThread> thread(String id) => guardApiCall<TicketThread>(() async {
    final Response<Map<String, Object?>> ticketRes = await _dio.get<Map<String, Object?>>(
      '/support-tickets/$id',
    );
    final Response<Map<String, Object?>> messagesRes = await _dio.get<Map<String, Object?>>(
      '/support-tickets/$id/messages',
    );
    return TicketThread(
      ticket: _ticket(_objectData(ticketRes.data)),
      messages: _listData(messagesRes.data).map(_message).toList(growable: false),
    );
  });

  @override
  Future<SubmitOutcome> create(TicketDraft draft) async {
    final Map<String, Object?> payload = draft.toPayload();
    final String key = _outbox.newIdempotencyKey();
    try {
      await guardApiCall<void>(
        () => _dio.post<Map<String, Object?>>(
          '/support-tickets',
          data: payload,
          options: _idempotent(key),
        ),
      );
      return SubmitOutcome.sent;
    } on ApiError catch (error) {
      if (!error.isOffline) {
        rethrow;
      }
      await _outbox.enqueue(kind: OutboxKind.support, payload: payload, clientId: key);
      return SubmitOutcome.queued;
    }
  }

  @override
  Future<SubmitOutcome> reply({required String ticketId, required String text}) async {
    final Map<String, Object?> payload = <String, Object?>{
      'text': text.trim(),
      'attachments': const <String>[],
    };
    final String key = _outbox.newIdempotencyKey();
    try {
      await guardApiCall<void>(
        () => _dio.post<Map<String, Object?>>(
          '/support-tickets/$ticketId/messages',
          data: payload,
          options: _idempotent(key),
        ),
      );
      return SubmitOutcome.sent;
    } on ApiError catch (error) {
      if (!error.isOffline) {
        rethrow;
      }
      await _outbox.enqueue(
        kind: OutboxKind.support,
        payload: <String, Object?>{'ticket_id': ticketId, ...payload},
        clientId: key,
      );
      return SubmitOutcome.queued;
    }
  }

  Options _idempotent(String key) => Options(
    extra: <String, Object?>{RequestExtra.idempotent: true, RequestExtra.idempotencyKey: key},
  );
}

SupportTicket _ticket(Map<String, Object?> data) => SupportTicket(
  id: _str(data['id']) ?? '',
  status: TicketStatus.fromWire(_str(data['status'])),
  subject: _str(data['subject']) ?? '',
  description: _str(data['description']) ?? '',
  contactOn: data['contact_on'] == null ? null : ContactChannel.fromWire(_str(data['contact_on'])),
  createdAt: _date(data['created_at']),
  messageCount: data['message_count'] is int ? data['message_count']! as int : 0,
  attachments: _strings(data['attachments']),
);

SupportMessage _message(Map<String, Object?> data) => SupportMessage(
  id: _str(data['id']) ?? '',
  text: _str(data['text']) ?? '',
  senderName: _str(data['sender_name']),
  createdAt: _date(data['created_at']),
  attachments: _strings(data['attachments']),
);

List<Map<String, Object?>> _listData(Map<String, Object?>? body) => <Map<String, Object?>>[
  ...?(body?['data'] as List<Object?>?)?.whereType<Map<String, Object?>>(),
];

Map<String, Object?> _objectData(Map<String, Object?>? body) =>
    (body?['data'] as Map<String, Object?>?) ?? const <String, Object?>{};

List<String> _strings(Object? value) => <String>[
  ...?(value as List<Object?>?)?.map((Object? e) => e.toString()),
];

String? _str(Object? value) {
  if (value == null) {
    return null;
  }
  final String text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// ISO-8601 (UTC) → lokal `DateTime`. Noto'g'ri qiymat `null`.
DateTime? _date(Object? value) {
  final String? text = _str(value);
  return text == null ? null : DateTime.tryParse(text)?.toLocal();
}

final Provider<SupportRepository> supportRepositoryProvider = Provider<SupportRepository>(
  (Ref ref) => SupportRepositoryImpl(
    dio: ref.watch(eldDioProvider),
    outbox: ref.watch(outboxRepositoryProvider),
  ),
);
