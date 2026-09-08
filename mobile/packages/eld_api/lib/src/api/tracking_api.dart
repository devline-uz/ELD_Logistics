//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:eld_api/src/api_util.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_error_response.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_live_unit_list_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_trip_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_trip_list_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_tracking_dto_unidentified_event_list_envelope.dart';

class TrackingApi {

  final Dio _dio;

  final Serializers _serializers;

  const TrackingApi(this._dio, this._serializers);

  /// Live tracking map
  /// TZ §10.1 / Q63 — the last known state of every unit, read from &#x60;unit_last_state&#x60;. &#x60;online_status&#x60; is Online (telemetry within 5 minutes), Offline, Disconnected (the ELD reported losing the phone link) or Malfunction (the wired ELD carries an active FMCSA Appendix A code, which wins over the connectivity state). A branch scoped principal always sees its own branch only. Distances are metres and speeds km/h; the backend never converts units. The &#x60;online_status&#x60; filter matches the stored connectivity state, so &#x60;malfunction&#x60; is not a filter value.
  ///
  /// Parameters:
  /// * [page] - Page number
  /// * [perPage] - Rows per page (10/25/50, max 100)
  /// * [unitIds] - Comma separated unit ids (max 500)
  /// * [branchId] - Branch filter (uuid)
  /// * [onlineStatus] - Connectivity filter
  /// * [includeInactive] - Include inactive units
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope>> trackingLiveGet({ 
    int? page = 1,
    int? perPage = 25,
    String? unitIds,
    String? branchId,
    String? onlineStatus,
    bool? includeInactive,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/tracking/live';
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
      if (page != null) r'page': encodeQueryParameter(_serializers, page, const FullType(int)),
      if (perPage != null) r'per_page': encodeQueryParameter(_serializers, perPage, const FullType(int)),
      if (unitIds != null) r'unit_ids': encodeQueryParameter(_serializers, unitIds, const FullType(String)),
      if (branchId != null) r'branch_id': encodeQueryParameter(_serializers, branchId, const FullType(String)),
      if (onlineStatus != null) r'online_status': encodeQueryParameter(_serializers, onlineStatus, const FullType(String)),
      if (includeInactive != null) r'include_inactive': encodeQueryParameter(_serializers, includeInactive, const FullType(bool)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainTrackingDtoLiveUnitListEnvelope>(
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

  /// Get trip
  /// Trip detail with its track. &#x60;polyline&#x60; is a Google encoded polyline (precision 5) rebuilt from the telemetry of the trip window; &#x60;polyline_key&#x60; is the object storage key of the copy written when the trip closed, which outlives the telemetry retention window. Pass &#x60;include_polyline&#x3D;false&#x60; to skip the rebuild. Cross-tenant and out of scope trip ids answer 404, never 403.
  ///
  /// Parameters:
  /// * [id] - Trip id
  /// * [includePolyline] - Rebuild the polyline from telemetry
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope>> tripsIdGet({ 
    required String id,
    bool? includePolyline = true,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/trips/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
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
      if (includePolyline != null) r'include_polyline': encodeQueryParameter(_serializers, includePolyline, const FullType(bool)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainTrackingDtoTripEnvelope>(
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

  /// List unidentified driving events
  /// TZ A§10.4 — driving recorded without an identified driver is buffered here (unit, start/end, distance, track). Assigning an event to a driver or claiming it from the mobile app happens through the log edit request flow, not on this endpoint. &#x60;pending_days&#x60; beyond 8 raises the admin alert.
  ///
  /// Parameters:
  /// * [status] - Resolution status
  /// * [unitId] - Unit filter (uuid)
  /// * [from] - Start of the window (RFC3339 UTC)
  /// * [to] - End of the window, exclusive (RFC3339 UTC)
  /// * [page] - Page number
  /// * [perPage] - Rows per page (10/25/50, max 100)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope>> unidentifiedEventsGet({ 
    String? status,
    String? unitId,
    String? from,
    String? to,
    int? page = 1,
    int? perPage = 25,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/unidentified-events';
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
      if (unitId != null) r'unit_id': encodeQueryParameter(_serializers, unitId, const FullType(String)),
      if (from != null) r'from': encodeQueryParameter(_serializers, from, const FullType(String)),
      if (to != null) r'to': encodeQueryParameter(_serializers, to, const FullType(String)),
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

    GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventListEnvelope>(
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

  /// List unit trips of a day
  /// TZ §13 Q64/Q65 — a trip runs from ignition on to ignition off, or ends after a stop of 15 minutes or more. The &#x60;date&#x60; window is the calendar day in the **company timezone**, converted to UTC; omitting it means today. Cross-tenant and out of scope unit ids answer 404, never 403.
  ///
  /// Parameters:
  /// * [id] - Unit id
  /// * [date] - Calendar day in the company timezone (YYYY-MM-DD)
  /// * [page] - Page number
  /// * [perPage] - Rows per page (10/25/50, max 100)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope>> unitsIdTripsGet({ 
    required String id,
    String? date,
    int? page = 1,
    int? perPage = 25,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/units/{id}/trips'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
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
      if (date != null) r'date': encodeQueryParameter(_serializers, date, const FullType(String)),
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

    GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainTrackingDtoTripListEnvelope>(
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
