/// Ilovadagi yagona xato tipi. Barcha tarmoq/parse xatolari `ApiError` ga
/// aylantiriladi (`core/network/error_mapper.dart`), UI faqat shuni ko'radi.
library;

import 'api_error_code.dart';

/// Maydon darajasidagi validatsiya xatosi — backend `details[]` elementi.
class ApiFieldError {
  const ApiFieldError({required this.field, required this.message});

  final String field;
  final String message;

  @override
  String toString() => '$field: $message';
}

/// Backend konverti: `{"error":{"code","message","details"}}`.
class ApiError implements Exception {
  const ApiError({
    required this.code,
    required this.message,
    this.statusCode,
    this.details = const <ApiFieldError>[],
    this.retryAfter,
    this.requestId,
  });

  /// Kanonik kod, [ApiErrorCode] dan biri.
  final String code;

  /// Backend xabari — **UI da ko'rsatilmaydi** (ingliz tilidagi texnik matn).
  /// Foydalanuvchiga `ApiErrorMessages.keyOf(code)` orqali i18n kalit beriladi.
  final String message;

  /// HTTP status; mijoz tomonidagi xatolarda `null`.
  final int? statusCode;

  final List<ApiFieldError> details;

  /// `429` javobidagi `Retry-After` (sekund) dan olingan kutish muddati.
  final Duration? retryAfter;

  /// `X-Request-Id` — support ticket uchun (PII emas).
  final String? requestId;

  bool get isRetryable => ApiErrorCode.retryable.contains(code);

  bool get terminatesSession => ApiErrorCode.sessionTerminating.contains(code);

  bool get isOffline => code == ApiErrorCode.clientNetwork || code == ApiErrorCode.clientTimeout;

  Map<String, String> fieldErrors() => <String, String>{
    for (final ApiFieldError e in details) e.field: e.message,
  };

  ApiError copyWith({String? code, String? message}) => ApiError(
    code: code ?? this.code,
    message: message ?? this.message,
    statusCode: statusCode,
    details: details,
    retryAfter: retryAfter,
    requestId: requestId,
  );

  /// Log uchun — token/PII yo'q (M159).
  @override
  String toString() => 'ApiError($code, status=$statusCode, requestId=$requestId)';
}
