/// Idempotent so'rovlar uchun eksponensial backoff + `429 Retry-After`.
///
/// Faqat idempotent so'rovlar (GET/HEAD yoki `Idempotency-Key` li POST)
/// takrorlanadi — aks holda server tomonida dublikat paydo bo'ladi.
library;

import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../error/api_error.dart';
import 'error_mapper.dart';
import 'request_options_x.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    Random? random,
    Future<void> Function(Duration)? sleep,
  }) : _random = random ?? Random.secure(),
       _sleep = sleep ?? Future<void>.delayed;

  final Dio dio;
  final int maxAttempts;
  final Duration baseDelay;
  final Duration maxDelay;
  final Random _random;
  final Future<void> Function(Duration) _sleep;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final RequestOptions options = err.requestOptions;
    final ApiError error = mapDioException(err);

    if (!options.isIdempotent || !error.isRetryable || options.retryCount >= maxAttempts - 1) {
      handler.next(err);
      return;
    }

    final int attempt = options.retryCount + 1;
    options.extra[RequestExtra.retryCount] = attempt;

    await _sleep(error.retryAfter ?? _backoff(attempt));

    try {
      final Response<dynamic> response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// To'liq jitter bilan eksponensial backoff.
  Duration _backoff(int attempt) {
    final int expMs = baseDelay.inMilliseconds * (1 << (attempt - 1));
    final int cappedMs = min(expMs, maxDelay.inMilliseconds);
    return Duration(milliseconds: _random.nextInt(cappedMs + 1));
  }
}
