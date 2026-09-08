/// Markazlashgan tarmoq logi — PII va tokenlar maskalanadi (M152, M159).
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'error_mapper.dart';

/// Log'da hech qachon ochiq ko'rinmaydigan sarlavhalar.
const Set<String> _maskedHeaders = <String>{'authorization', 'cookie', 'set-cookie', 'x-api-key'};

/// **S-L1** — qisman maskalanadigan sarlavhalar: qiymati barqaror qurilma
/// identifikatori (PII bilan bog'lanadigan kvazi-identifikator, M159).
/// Log'da faqat birinchi 8 belgi qoladi — korrelyatsiya uchun yetadi.
const Set<String> _partiallyMaskedHeaders = <String>{'x-device-id'};

/// `1f2a3b4c-...-...` → `1f2a3b4c***`.
String maskIdentifier(Object? value) {
  final String raw = value?.toString() ?? '';
  if (raw.length <= 8) {
    return '***';
  }
  return '${raw.substring(0, 8)}***';
}

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required this.logger, this.enabled = true});

  final Logger logger;
  final bool enabled;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      logger.d(
        '→ ${options.method} ${options.path} '
        'hdr=${_maskHeaders(options.headers)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (enabled) {
      logger.d(
        '← ${response.statusCode} ${response.requestOptions.path} '
        'reqId=${response.headers.value(HttpHeaders2.requestId) ?? '-'}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      // Javob tanasi log qilinmaydi — PII bo'lishi mumkin.
      logger.w('✗ ${err.requestOptions.path} → ${mapDioException(err)}');
    }
    handler.next(err);
  }

  /// `Authorization: Bearer …` → `***`, `X-Device-Id` → `1f2a3b4c***`.
  Map<String, Object?> _maskHeaders(Map<String, dynamic> headers) => <String, Object?>{
    for (final MapEntry<String, dynamic> e in headers.entries)
      e.key: switch (e.key.toLowerCase()) {
        final String k when _maskedHeaders.contains(k) => '***',
        final String k when _partiallyMaskedHeaders.contains(k) => maskIdentifier(e.value),
        _ => e.value,
      },
  };
}
