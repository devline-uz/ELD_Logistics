//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:eld_api/src/api_util.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auditlog_dto_entry_list_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auditlog_dto_error_response.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auditlog_dto_table_list_envelope.dart';

class AuditApi {

  final Dio _dio;

  final Serializers _serializers;

  const AuditApi(this._dio, this._serializers);

  /// List audit log entries
  /// TZ A§17 — the single audit trail; the four journals of the UI are filtered views of this endpoint. Newest first by default. &#x60;old_value&#x60; and &#x60;new_value&#x60; are masked: a password hash, session token, encrypted column or driver licence number is returned as &#x60;[REDACTED]&#x60; and &#x60;masked&#x60; is true. The table is append-only, so there is no create, update or delete route.
  ///
  /// Parameters:
  /// * [page] - Page number
  /// * [perPage] - Rows per page (10/25/50, max 100)
  /// * [order] - Timestamp order
  /// * [table] - Audited table name
  /// * [recordId] - Audited row id (uuid)
  /// * [user] - Acting user id (uuid), matches audit_log.edited_by
  /// * [action] - Audited action
  /// * [from] - Timestamp at or after (RFC3339)
  /// * [to] - Timestamp before (RFC3339)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope>> auditLogGet({ 
    int? page = 1,
    int? perPage = 25,
    String? order = 'desc',
    String? table,
    String? recordId,
    String? user,
    String? action,
    String? from,
    String? to,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/audit-log';
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
      if (order != null) r'order': encodeQueryParameter(_serializers, order, const FullType(String)),
      if (table != null) r'table': encodeQueryParameter(_serializers, table, const FullType(String)),
      if (recordId != null) r'record_id': encodeQueryParameter(_serializers, recordId, const FullType(String)),
      if (user != null) r'user': encodeQueryParameter(_serializers, user, const FullType(String)),
      if (action != null) r'action': encodeQueryParameter(_serializers, action, const FullType(String)),
      if (from != null) r'from': encodeQueryParameter(_serializers, from, const FullType(String)),
      if (to != null) r'to': encodeQueryParameter(_serializers, to, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope>(
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

  /// List audited table names
  /// Distinct &#x60;audit_log.table_name&#x60; values of the company, for the filter dropdown of the audit journal screen.
  ///
  /// Parameters:
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope>> auditLogTablesGet({ 
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/audit-log/tables';
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

    GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope>(
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
