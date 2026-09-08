//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:eld_api/src/api_util.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_error_response.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_pull_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_push_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_push_request.dart';

class SyncApi {

  final Dio _dio;

  final Serializers _serializers;

  const SyncApi(this._dio, this._serializers);

  /// Download server changes
  /// TZ D§2 — everything the device has to catch up on since &#x60;since&#x60;: pending log edit requests, the unidentified driving buffer of the driver&#39;s unit (A§10.4), the server&#39;s canonical copies of changed duty status events and log days (conflict rule 2 — the server wins and the device rebuilds its local log), the current &#x60;hos_policy&#x60;, the DVIR defect catalogue, the quick-note templates and new chat messages. &#x60;next_since&#x60; is the newest &#x60;updated_at&#x60; actually returned, so a truncated page (&#x60;truncated&#x3D;true&#x60;) resumes exactly where it stopped. Without &#x60;since&#x60; the default window is the last 8 days. A Driver reads its own data only.
  ///
  /// Parameters:
  /// * [since] - Cursor from the previous pull, RFC3339
  /// * [unitId] - Unit the driver is logged into; selects the unidentified driving buffer
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope>> syncPullGet({ 
    String? since,
    String? unitId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/sync/pull';
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
      if (since != null) r'since': encodeQueryParameter(_serializers, since, const FullType(String)),
      if (unitId != null) r'unit_id': encodeQueryParameter(_serializers, unitId, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope>(
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

  /// Upload an offline batch
  /// TZ D§2 — the driver app drains its offline queue here. Each element is answered individually with &#x60;accepted&#x60;, &#x60;duplicate&#x60; or &#x60;rejected(reason)&#x60;; a duplicate &#x60;client_event_id&#x60; is never an error. Conflict rules: an event more than five minutes ahead of the server is &#x60;rejected(time_in_future)&#x60;; an event on a certified day is &#x60;rejected(log_locked)&#x60;; two devices claiming the same instant are resolved by &#x60;time_source&#x60; priority (eld_rtc &gt; server &gt; phone) then by the larger &#x60;device_seq&#x60;, and the loser is still stored with &#x60;superseded_by&#x60; set and reported as &#x60;accepted&#x60; with &#x60;reason&#x3D;superseded&#x60;. The server also enforces the duty rules it owns: PC/YM need &#x60;hos_policy.allow_pc&#x60;/&#x60;allow_ym&#x60;, SB needs a sleeper berth on the unit, DR is never selected by hand, and motion at or above &#x60;motion_threshold_kmh&#x60; coerces the status to DR. Ceilings: 500 events, 5000 telemetry points, 100 DVIR, 500 chat. &#x60;Idempotency-Key&#x60; is required. DVIR and chat elements are acknowledged but only processed from stages 5-6 on.
  ///
  /// Parameters:
  /// * [idempotencyKey] - Idempotency key; a repeat replays the recorded response for 24h
  /// * [body] - Offline batch
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope>> syncPushPost({ 
    required String idempotencyKey,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/sync/push';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'Idempotency-Key': idempotencyKey,
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
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest);
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

    GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope>(
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
