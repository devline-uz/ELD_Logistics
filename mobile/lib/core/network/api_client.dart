/// Dio klientini yig'ish. Ilovada **yagona** HTTP transporti (`http` paketi taqiq).
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../config/env.dart';
import '../error/api_error.dart';
import '../security/active_slot.dart';
import '../security/secure_vault.dart';
import 'auth_interceptor.dart';
import 'certificate_pinning.dart';
import 'error_mapper.dart';
import 'idempotency_interceptor.dart';
import 'logging_interceptor.dart';
import 'refresh_coordinator.dart';
import 'retry_interceptor.dart';
import 'slot_interceptor.dart';

/// Interceptorlar tartibi muhim:
/// 1. `SlotInterceptor` — faol haydovchi sloti (M9), `AuthInterceptor` dan oldin;
/// 2. `IdempotencyInterceptor` — qurilma sarlavhalari va `Idempotency-Key`;
/// 3. `AuthInterceptor` — `Authorization`, proaktiv refresh, 401 → refresh+retry;
/// 4. `RetryInterceptor` — 429/5xx/tarmoq uchun backoff (faqat idempotent);
/// 5. `LoggingInterceptor` — maskalangan log (oxirgi, hamma narsani ko'radi).
class ApiClient {
  ApiClient._(this.dio);

  final Dio dio;

  static ApiClient create({
    required SecureVault vault,
    required RefreshCoordinator refreshCoordinator,
    required String appVersion,
    required Logger logger,
    ActiveSlotHolder? activeSlot,
    String? baseUrl,
    HttpClientAdapter? adapter,
  }) {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const <String, Object>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.json,
        // 4xx/5xx `DioException` ga aylanadi va `ApiError` ga mapping qilinadi.
        validateStatus: (int? status) => status != null && status < 400,
      ),
    );
    if (adapter != null) {
      // Testlar va soxta transport uchun; prod'da hech qachon berilmaydi.
      dio.httpClientAdapter = adapter;
    } else {
      // M153: `ENABLE_CERT_PINNING` endi haqiqiy SPKI pinningga ulangan.
      // Bayroq yoqilgan-u pin ro'yxati bo'sh bo'lsa — StateError (fail-closed).
      CertificatePinning.install(dio);
    }

    dio.interceptors.addAll(<Interceptor>[
      SlotInterceptor(activeSlot ?? ActiveSlotHolder()),
      IdempotencyInterceptor(appVersion: appVersion, deviceId: vault.deviceId),
      AuthInterceptor(vault: vault, coordinator: refreshCoordinator, dio: dio),
      RetryInterceptor(dio: dio),
      LoggingInterceptor(logger: logger, enabled: Env.current != AppFlavor.prod),
    ]);

    return ApiClient._(dio);
  }
}

/// `DioException` ni [ApiError] ga aylantiruvchi yordamchi.
///
/// `data` qatlamidagi har chaqiruv shu bilan o'raladi — `presentation` faqat
/// [ApiError] ni ko'radi.
Future<T> guardApiCall<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on DioException catch (e) {
    throw mapDioException(e);
  }
}
