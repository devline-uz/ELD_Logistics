//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dashboard_dto_error_response.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dashboard_dto_summary_envelope.dart';

class DashboardApi {

  final Dio _dio;

  final Serializers _serializers;

  const DashboardApi(this._dio, this._serializers);

  /// Dashboard summary
  /// TZ A§20 — the KPI cards, the current duty status block and today&#39;s routes. Every window is cut on the company timezone: &#x60;active_units&#x60; counts the units that reported telemetry today, &#x60;drivers_on_duty&#x60; the drivers currently in ON or DR, &#x60;violations&#x60; the violations of the current ISO week (Monday–Sunday), &#x60;uncertified_logs&#x60; the logs uncertified for two days or more, and &#x60;unassigned_driving&#x60; the unidentified driving events still pending. &#x60;disconnected_eld&#x60; is the stored connectivity state; &#x60;malfunction_eld&#x60; is derived from the device diagnostics. A branch scoped principal sees only its own branch in the route block. The same payload is republished on the WebSocket &#x60;dashboard&#x60; channel, so a client either polls this endpoint every 60 seconds or subscribes.
  ///
  /// Parameters:
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope>> dashboardSummaryGet({ 
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/dashboard/summary';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'BearerAuth',
            'keyName': 'Authorization',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDashboardDtoSummaryEnvelope>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
