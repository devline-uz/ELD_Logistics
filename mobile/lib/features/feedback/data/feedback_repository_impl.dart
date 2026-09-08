/// `POST /feedback` (`contracts/swagger.json` → `FeedbackCreate`).
///
/// Oflayn: `ApiError.isOffline` bo'lsa yozuv `outbox_items` ga
/// `kind = feedback` bilan qo'yiladi (§5.3) va sinxronizator keyin yuboradi.
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
import '../domain/feedback_draft.dart';
import '../domain/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  const FeedbackRepositoryImpl({required this._dio, required this._outbox});

  final Dio _dio;
  final OutboxRepository _outbox;

  @override
  Future<SubmitOutcome> submit(FeedbackDraft draft) async {
    final Map<String, Object?> payload = draft.toPayload();
    // Retry paytida takroriy yozuv paydo bo'lmasligi uchun barqaror kalit.
    final String key = _outbox.newIdempotencyKey();
    try {
      await guardApiCall<void>(
        () => _dio.post<Map<String, Object?>>(
          '/feedback',
          data: payload,
          options: Options(
            extra: <String, Object?>{
              RequestExtra.idempotent: true,
              RequestExtra.idempotencyKey: key,
            },
          ),
        ),
      );
      return SubmitOutcome.sent;
    } on ApiError catch (error) {
      if (!error.isOffline) {
        rethrow;
      }
      await _outbox.enqueue(kind: OutboxKind.feedback, payload: payload, clientId: key);
      return SubmitOutcome.queued;
    }
  }
}

final Provider<FeedbackRepository> feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (Ref ref) => FeedbackRepositoryImpl(
    dio: ref.watch(eldDioProvider),
    outbox: ref.watch(outboxRepositoryProvider),
  ),
);
