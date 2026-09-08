/// `other` outbox turlarini o'z endpoint'lariga uzatuvchi kanal (M-SYNC1).
///
/// **Nima uchun kerak.** Muzlatilgan `contracts/swagger.json` dagi
/// `sync_dto.PushRequest` da faqat to'rt bucket bor: `events`, `telemetry`,
/// `dvir`, `chat`. `certify`, `claim`, `log_edit`, `feedback`, `support`
/// uchun `/sync/push` da joy **yo'q**, shuning uchun ular oflayn navbatdan
/// chiqib o'z REST endpoint'lariga boradi. Idempotentlik saqlanadi: har
/// so'rovga outbox elementining `client_id` si `Idempotency-Key` sifatida
/// qo'yiladi, javob esa aynan `/sync/push` dagidek [PushItemResult] ga
/// aylantiriladi — scheduler va outbox mantiqi o'zgarmaydi.
library;

import 'package:dio/dio.dart';
import 'package:sync_core/sync_core.dart';

import '../error/api_error.dart';
import '../error/api_error_code.dart';
import '../files/file_upload.dart';
import '../network/error_mapper.dart';
import '../network/request_options_x.dart';
import '../security/secure_vault.dart';
import 'sync_transport.dart';

/// Endpointi bo'lmagan turlar uchun natija sababi.
const String kUnsupportedKindReason = 'invalid_payload';

class SyncSideChannel {
  const SyncSideChannel({required Dio dio, required FileUploader uploader}) : this._(dio, uploader);

  const SyncSideChannel._(this._dio, this._uploader);

  final Dio _dio;
  final FileUploader _uploader;

  /// Har element uchun alohida so'rov; biri yiqilsa qolganlari davom etadi
  /// (M25: rad etilgan element navbatni bloklamaydi).
  Future<List<PushItemResult>> send(
    List<OtherPushItem> items, {
    DriverSlot slot = DriverSlot.primary,
  }) async {
    final List<PushItemResult> results = <PushItemResult>[];
    for (final OtherPushItem item in items) {
      results.add(await _sendOne(item, slot));
    }
    return results;
  }

  Future<PushItemResult> _sendOne(OtherPushItem item, DriverSlot slot) async {
    try {
      return switch (item.kind) {
        OutboxKind.certify => await _certify(item, slot),
        OutboxKind.claim => await _claim(item, slot),
        OutboxKind.logEdit => await _post(item, '/log-edit-requests', item.payload, slot),
        OutboxKind.feedback => await _post(item, '/feedback', item.payload, slot),
        OutboxKind.support => await _support(item, slot),
        // TODO(CR-M06): `push_token` uchun kontraktda endpoint yo'q. Element
        // navbatni cheksiz o'stirmasligi uchun lokal ravishda yopiladi.
        OutboxKind.pushToken => PushItemResult(clientId: item.clientId, result: 'accepted'),
        OutboxKind.event ||
        OutboxKind.telemetry ||
        OutboxKind.dvir ||
        OutboxKind.chat => PushItemResult(
          clientId: item.clientId,
          result: 'rejected',
          reason: kUnsupportedKindReason,
        ),
      };
    } on ApiError catch (e) {
      return _fromApiError(item, e);
    }
  }

  // --- certify (§12, M126) ---------------------------------------------------

  /// `POST /daily-logs/{id}/certify`.
  ///
  /// Imzo PNG avval `POST /files/presign` + `PUT` orqali yuklanadi va
  /// `signature_local_path` **`signature_key`** ga almashtiriladi (M149:
  /// fayl yuklanmaguncha domen so'rovi yuborilmaydi).
  Future<PushItemResult> _certify(OtherPushItem item, DriverSlot slot) async {
    final String? dailyLogId = _string(item.payload['daily_log_id']);
    if (dailyLogId == null) {
      // Kun hali serverdan pull qilinmagan — keyingi siklda `daily_log_id`
      // paydo bo'ladi, shuning uchun bu **xato emas**, qayta urinish.
      throw const ApiError(
        code: ApiErrorCode.clientNetwork,
        message: 'daily_log_id not synced yet',
      );
    }

    String? signatureKey = _string(item.payload['signature_key']);
    final String? localPath = _string(item.payload['signature_local_path']);
    if (signatureKey == null && localPath != null) {
      signatureKey = await _uploader.uploadPath(localPath: localPath, kind: FileKind.signature);
      if (signatureKey == null) {
        return PushItemResult(
          clientId: item.clientId,
          result: 'rejected',
          reason: kUnsupportedKindReason,
        );
      }
    }

    return _post(item, '/daily-logs/$dailyLogId/certify', <String, Object?>{
      'signature_key': ?signatureKey,
      if (_string(item.payload['signature_id']) case final String id) 'signature_id': id,
      if (_string(item.payload['device_id']) case final String id) 'device_id': id,
    }, slot);
  }

  // --- unidentified claim (A§10.4) -------------------------------------------

  Future<PushItemResult> _claim(OtherPushItem item, DriverSlot slot) async {
    final String? eventId = _string(item.payload['event_id']);
    if (eventId == null) {
      return PushItemResult(
        clientId: item.clientId,
        result: 'rejected',
        reason: kUnsupportedKindReason,
      );
    }
    // M164: `driver_id` serverda tokendan olinadi — tanaga qo'yilmaydi.
    return _post(item, '/unidentified-events/$eventId/claim', const <String, Object?>{}, slot);
  }

  // --- support (§?) ----------------------------------------------------------

  Future<PushItemResult> _support(OtherPushItem item, DriverSlot slot) {
    final String? ticketId = _string(item.payload['ticket_id']);
    return ticketId == null
        ? _post(item, '/support-tickets', item.payload, slot)
        : _post(
            item,
            '/support-tickets/$ticketId/messages',
            <String, Object?>{...item.payload}..remove('ticket_id'),
            slot,
          );
  }

  // --- umumiy ---------------------------------------------------------------

  Future<PushItemResult> _post(
    OtherPushItem item,
    String path,
    Map<String, Object?> body,
    DriverSlot slot,
  ) async {
    try {
      await _dio.post<Object?>(
        path,
        data: body,
        options: Options(
          // M19: outbox `client_id` — barqaror idempotentlik kaliti.
          headers: <String, Object?>{HttpHeaders2.idempotencyKey: item.clientId},
          extra: <String, Object?>{
            RequestExtra.idempotent: true,
            RequestExtra.idempotencyKey: item.clientId,
            // B-120: element o'z sessiyasining tokeni bilan ketadi.
            RequestExtra.slot: slot,
          },
        ),
      );
      return PushItemResult(clientId: item.clientId, result: 'accepted');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// HTTP xatosini `/sync/push` verdiktlari tiliga o'giradi.
  ///
  /// * `409` — element allaqachon qabul qilingan → `duplicate` (xato emas);
  /// * `4xx` (422/400/403) — qayta urinish foydasiz → `rejected`;
  /// * qolgani (tarmoq, 5xx, 429) — [SyncTransportException] bo'lib uchadi va
  ///   element `pending` ga qaytadi.
  PushItemResult _fromApiError(OtherPushItem item, ApiError e) {
    final int status = e.statusCode ?? 0;
    if (status == 409) {
      return PushItemResult(clientId: item.clientId, result: 'duplicate', reason: e.code);
    }
    if (status == 400 || status == 403 || status == 404 || status == 422) {
      return PushItemResult(
        clientId: item.clientId,
        result: 'rejected',
        reason: _reasonFor(e, status),
      );
    }
    throw SyncTransportException(
      code: e.code,
      statusCode: e.statusCode,
      retryAfter: e.retryAfter,
      message: e.message,
    );
  }

  /// Server `reason` bersa — o'sha, aks holda §5.6 mappingiga tushadigan kod.
  String _reasonFor(ApiError e, int status) => switch (e.code) {
    ApiErrorCode.validationError => kUnsupportedKindReason,
    ApiErrorCode.forbidden when status == 403 => 'log_locked',
    _ => e.code,
  };

  static String? _string(Object? value) {
    final String? text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }
}
