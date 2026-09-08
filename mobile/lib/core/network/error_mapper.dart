/// `DioException` → [ApiError] konvertatsiyasi.
///
/// Backend konverti: `{"error":{"code","message","details":[{"field","message"}]}}`.
library;

import 'dart:io';

import 'package:dio/dio.dart';

import '../error/api_error.dart';
import '../error/api_error_code.dart';

/// HTTP sarlavhalari nomlari.
abstract final class HttpHeaders2 {
  const HttpHeaders2._();

  static const String authorization = 'Authorization';
  static const String idempotencyKey = 'Idempotency-Key';
  static const String retryAfter = 'Retry-After';
  static const String requestId = 'X-Request-Id';
  static const String deviceIntegrity = 'X-Device-Integrity';
  static const String appVersion = 'X-App-Version';
  static const String deviceId = 'X-Device-Id';
}

/// Har qanday xatoni yagona [ApiError] ga aylantiradi.
ApiError mapDioException(DioException e) {
  final Response<dynamic>? response = e.response;
  final String? requestId = response?.headers.value(HttpHeaders2.requestId);

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return ApiError(
        code: ApiErrorCode.clientTimeout,
        message: 'request timed out',
        requestId: requestId,
      );
    case DioExceptionType.cancel:
      return ApiError(
        code: ApiErrorCode.clientCancelled,
        message: 'request cancelled',
        requestId: requestId,
      );
    case DioExceptionType.connectionError:
      return ApiError(
        code: ApiErrorCode.clientNetwork,
        message: 'connection failed',
        requestId: requestId,
      );
    case DioExceptionType.badCertificate:
      return ApiError(
        code: ApiErrorCode.clientTlsPinning,
        message: 'certificate rejected',
        requestId: requestId,
      );
    case DioExceptionType.unknown:
      if (e.error is SocketException || e.error is HttpException) {
        return ApiError(
          code: ApiErrorCode.clientNetwork,
          message: 'connection failed',
          requestId: requestId,
        );
      }
      if (e.error is HandshakeException || e.error is TlsException) {
        return ApiError(
          code: ApiErrorCode.clientTlsPinning,
          message: 'tls handshake failed',
          requestId: requestId,
        );
      }
      return ApiError(
        code: ApiErrorCode.clientUnknown,
        message: 'unexpected client error',
        requestId: requestId,
      );
    case DioExceptionType.badResponse:
      return _fromResponse(response!, requestId);
  }
}

ApiError _fromResponse(Response<dynamic> response, String? requestId) {
  final int status = response.statusCode ?? 0;
  final Object? data = response.data;

  String code = _codeFromStatus(status);
  String message = 'request failed';
  List<ApiFieldError> details = const <ApiFieldError>[];

  if (data is Map) {
    final Object? envelope = data['error'];
    if (envelope is Map) {
      final Object? rawCode = envelope['code'];
      if (rawCode is String && rawCode.isNotEmpty) {
        code = rawCode;
      }
      final Object? rawMessage = envelope['message'];
      if (rawMessage is String) {
        message = rawMessage;
      }
      final Object? rawDetails = envelope['details'];
      if (rawDetails is List) {
        details = rawDetails
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (Map<dynamic, dynamic> d) => ApiFieldError(
                field: d['field'] is String ? d['field'] as String : '',
                message: d['message'] is String ? d['message'] as String : '',
              ),
            )
            .where((ApiFieldError f) => f.field.isNotEmpty)
            .toList(growable: false);
      }
    }
  }

  return ApiError(
    code: code,
    message: message,
    statusCode: status,
    details: details,
    retryAfter: parseRetryAfter(response.headers.value(HttpHeaders2.retryAfter)),
    requestId: requestId,
  );
}

String _codeFromStatus(int status) => switch (status) {
  400 => ApiErrorCode.badRequest,
  401 => ApiErrorCode.unauthorized,
  403 => ApiErrorCode.forbidden,
  404 => ApiErrorCode.notFound,
  409 => ApiErrorCode.conflict,
  413 => ApiErrorCode.payloadTooLarge,
  415 => ApiErrorCode.unsupportedMediaType,
  422 => ApiErrorCode.validationError,
  429 => ApiErrorCode.rateLimited,
  503 => ApiErrorCode.serviceUnavailable,
  _ when status >= 500 => ApiErrorCode.internalError,
  _ => ApiErrorCode.clientUnknown,
};

/// `Retry-After` — sekundlar yoki HTTP-date. Noto'g'ri qiymatda `null`.
Duration? parseRetryAfter(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final int? seconds = int.tryParse(raw.trim());
  if (seconds != null) {
    return Duration(seconds: seconds.clamp(0, 3600));
  }
  try {
    final DateTime target = HttpDate.parse(raw);
    final Duration delta = target.difference(DateTime.now().toUtc());
    return delta.isNegative ? Duration.zero : delta;
  } on Exception {
    // HttpDate.parse `HttpException` yoki `FormatException` tashlashi mumkin.
    return null;
  }
}
