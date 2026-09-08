//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:eld_api/src/api_util.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_daily_log_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_error_response.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_reject.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request_create.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request_list_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_event_create.dart';

class LogEditsApi {

  final Dio _dio;

  final Serializers _serializers;

  const LogEditsApi(this._dio, this._serializers);

  /// Driver log edit
  /// Q17 — the driver&#39;s own correction. It is applied immediately with &#x60;origin&#x3D;driver_edit&#x60;, &#x60;note&#x60; is mandatory and the original events are kept behind &#x60;superseded_by&#x60;. Q17.1 still applies: automatically recorded &#x60;DR&#x60; may not be shortened or turned into another status — the only permitted rewrite is the driver re-labelling it as Personal Conveyance or Yard Move; &#x60;intermediate&#x60;, &#x60;power_on/off&#x60; and &#x60;malfunction&#x60; events are never editable. A certified day falls back to &#x60;needs_recertify&#x60; (Q18).
  ///
  /// Parameters:
  /// * [id] - Daily log id (uuid)
  /// * [body] - Duty status interval
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope>> dailyLogsIdEventsPost({ 
    required String id,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/daily-logs/{id}/events'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate);
      _bodyData = _serializers.serialize(body, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogEnvelope>(
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

  /// List log edit requests
  /// Q17 — the propose/approve queue. An administrator sees the whole company (or its branch), a Driver (scope &#x60;self&#x60;) only its own pending edits, which is the mobile \&quot;Pending edits\&quot; screen.
  ///
  /// Parameters:
  /// * [status] - Status filter
  /// * [driverId] - Driver filter (uuid)
  /// * [page] - Page number
  /// * [perPage] - Rows per page (10/25/50, max 100)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope>> logEditRequestsGet({ 
    String? status,
    String? driverId,
    int? page = 1,
    int? perPage = 25,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/log-edit-requests';
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

    final _queryParameters = <String, dynamic>{
      if (status != null) r'status': encodeQueryParameter(_serializers, status, const FullType(String)),
      if (driverId != null) r'driver_id': encodeQueryParameter(_serializers, driverId, const FullType(String)),
      if (page != null) r'page': encodeQueryParameter(_serializers, page, const FullType(int)),
      if (perPage != null) r'per_page': encodeQueryParameter(_serializers, perPage, const FullType(int)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope>(
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

  /// Approve a log edit request
  /// Q17 — only the driver whose log is being changed may approve. The new events are written with &#x60;origin&#x3D;admin_edit&#x60;, the original events are kept and flagged with &#x60;superseded_by&#x60; (nothing is deleted) and a certified day falls back to &#x60;needs_recertify&#x60; (Q18). For an &#x60;unidentified_assign&#x60; request the stored driving rows are handed over with &#x60;origin&#x3D;assigned&#x60; (§10.4) and the 8 day &#x60;unidentified_driving&#x60; violation is closed.
  ///
  /// Parameters:
  /// * [id] - Log edit request id (uuid)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope>> logEditRequestsIdApprovePost({ 
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/log-edit-requests/{id}/approve'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
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

    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope>(
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

  /// Reject a log edit request
  /// Q17 — only the driver may reject, and the reason is mandatory. The log stays exactly as it is and the administrator is told why.
  ///
  /// Parameters:
  /// * [id] - Log edit request id (uuid)
  /// * [body] - Rejection reason
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope>> logEditRequestsIdRejectPost({ 
    required String id,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/log-edit-requests/{id}/reject'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject);
      _bodyData = _serializers.serialize(body, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope>(
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

  /// Propose a log edit
  /// TZ §5.3 / Q17 [MUST] — an administrator never rewrites a driver log directly. The proposal is stored &#x60;pending&#x60; and the driver approves or rejects it. &#x60;note&#x60; is mandatory on every change. Q17.1 is enforced already at proposal time: automatically recorded &#x60;DR&#x60; may not be shortened or re-classified (&#x60;DR_IMMUTABLE&#x60;), and &#x60;intermediate&#x60;, &#x60;power_on/off&#x60; and &#x60;malfunction&#x60; events are never editable (&#x60;EVENT_IMMUTABLE&#x60;).
  ///
  /// Parameters:
  /// * [body] - Proposed changes
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope>> logEditRequestsPost({ 
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/log-edit-requests';
    final _options = Options(
      method: r'POST',
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestCreate);
      _bodyData = _serializers.serialize(body, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestEnvelope>(
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
