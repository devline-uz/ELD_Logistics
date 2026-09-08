import 'package:dio/dio.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/network/error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

RequestOptions _opts() => RequestOptions(path: '/me');

DioException _badResponse({
  required int status,
  Object? body,
  Map<String, List<String>>? headers,
}) => DioException(
  requestOptions: _opts(),
  type: DioExceptionType.badResponse,
  response: Response<dynamic>(
    requestOptions: _opts(),
    statusCode: status,
    data: body,
    headers: Headers.fromMap(headers ?? <String, List<String>>{}),
  ),
);

void main() {
  test('backend konverti kod, xabar va details ni beradi', () {
    final ApiError error = mapDioException(
      _badResponse(
        status: 422,
        body: <String, Object>{
          'error': <String, Object>{
            'code': ApiErrorCode.validationError,
            'message': 'validation failed',
            'details': <Object>[
              <String, String>{'field': 'unit_number', 'message': 'required'},
            ],
          },
        },
        headers: <String, List<String>>{
          'x-request-id': <String>['req-1'],
        },
      ),
    );

    expect(error.code, ApiErrorCode.validationError);
    expect(error.statusCode, 422);
    expect(error.fieldErrors(), <String, String>{'unit_number': 'required'});
    expect(error.requestId, 'req-1');
  });

  test('429 Retry-After sekundlarda o\'qiladi', () {
    final ApiError error = mapDioException(
      _badResponse(
        status: 429,
        body: <String, Object>{
          'error': <String, Object>{'code': ApiErrorCode.rateLimited, 'message': 'slow down'},
        },
        headers: <String, List<String>>{
          'retry-after': <String>['12'],
        },
      ),
    );

    expect(error.code, ApiErrorCode.rateLimited);
    expect(error.retryAfter, const Duration(seconds: 12));
    expect(error.isRetryable, isTrue);
  });

  test('konvertsiz javob status bo\'yicha kodga tushadi', () {
    final ApiError error = mapDioException(_badResponse(status: 503, body: 'gateway down'));

    expect(error.code, ApiErrorCode.serviceUnavailable);
    expect(error.isRetryable, isTrue);
  });

  test('tarmoq xatosi CLIENT_NETWORK ga aylanadi', () {
    final ApiError error = mapDioException(
      DioException(requestOptions: _opts(), type: DioExceptionType.connectionError),
    );

    expect(error.code, ApiErrorCode.clientNetwork);
    expect(error.isOffline, isTrue);
  });

  test('TOKEN_REVOKED sessiyani tugatadigan kod', () {
    const ApiError error = ApiError(code: ApiErrorCode.tokenRevoked, message: 'revoked');

    expect(error.terminatesSession, isTrue);
    expect(error.isRetryable, isFalse);
  });

  test('parseRetryAfter noto\'g\'ri qiymatda null qaytaradi', () {
    expect(parseRetryAfter('not-a-date'), isNull);
    expect(parseRetryAfter(''), isNull);
    expect(parseRetryAfter('5'), const Duration(seconds: 5));
  });
}
