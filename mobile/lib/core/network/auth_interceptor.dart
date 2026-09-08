/// `Authorization` qo'shish, proaktiv refresh va 401 dan keyin bitta qayta
/// urinish (tz-mobile §4.7).
library;

import 'package:dio/dio.dart';

import '../error/api_error.dart';
import '../error/api_error_code.dart';
import '../security/secure_vault.dart';
import 'error_mapper.dart';
import 'refresh_coordinator.dart';
import 'request_options_x.dart';

/// 401 javobida refresh qilishga arziydigan kodlar.
const Set<String> _refreshableCodes = <String>{
  ApiErrorCode.unauthorized,
  ApiErrorCode.tokenExpired,
  ApiErrorCode.sessionExpired,
};

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.vault,
    required this.coordinator,
    required this.dio,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final SecureVault vault;
  final RefreshCoordinator coordinator;
  final Dio dio;
  final DateTime Function() _clock;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.isAnonymous) {
      handler.next(options);
      return;
    }

    final DriverSlot slot = options.slot;

    // Proaktiv refresh: muddat tugashiga 60 s qolganda, 401 ni kutmasdan.
    if (vault.isAccessTokenExpiring(slot, _clock())) {
      await coordinator.refresh(slot);
    }

    final String? token = vault.accessToken(slot);
    if (token != null && token.isNotEmpty) {
      options.headers[HttpHeaders2.authorization] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final RequestOptions options = err.requestOptions;

    if (err.response?.statusCode != 401 || options.isAnonymous || options.retriedAfterRefresh) {
      handler.next(err);
      return;
    }

    final ApiError mapped = mapDioException(err);
    if (!_refreshableCodes.contains(mapped.code)) {
      // TOKEN_REVOKED / TOKEN_REUSED / PIN_REQUIRED — refresh yordam bermaydi.
      handler.next(err);
      return;
    }

    final DriverSlot slot = options.slot;
    // Mutex: parallel 401 lar bitta refreshni kutadi.
    final RefreshOutcome outcome = await coordinator.refresh(slot);
    if (outcome is! RefreshSucceeded) {
      handler.next(err);
      return;
    }

    options.extra[RequestExtra.retriedAfterRefresh] = true;
    options.headers[HttpHeaders2.authorization] = 'Bearer ${outcome.accessToken}';

    try {
      final Response<dynamic> response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
