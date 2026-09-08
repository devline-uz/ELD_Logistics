//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:eld_api/src/api_util.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_create.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_list_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_update.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_certify.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_create.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_repair.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_report_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_report_list_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_error_response.dart';

class DvirApi {

  final Dio _dio;

  final Serializers _serializers;

  const DvirApi(this._dio, this._serializers);

  /// List defect types
  /// Q27.1 — the inspection catalogue. Rows with &#x60;is_system&#x3D;true&#x60; are the 61 FMCSA defaults shared by every tenant and are read only; a company adds its own entries alongside them. &#x60;is_critical&#x60; drives the Q27.2 out of service rule.
  ///
  /// Parameters:
  /// * [category] - Catalogue section
  /// * [isActive] - Only active / only inactive entries
  /// * [isCritical] - Only critical / only non critical entries
  /// * [page] - Page number
  /// * [perPage] - Rows per page (10/25/50, max 100)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope>> defectTypesGet({ 
    String? category,
    bool? isActive,
    bool? isCritical,
    int? page = 1,
    int? perPage = 25,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/defect-types';
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
      if (category != null) r'category': encodeQueryParameter(_serializers, category, const FullType(String)),
      if (isActive != null) r'is_active': encodeQueryParameter(_serializers, isActive, const FullType(bool)),
      if (isCritical != null) r'is_critical': encodeQueryParameter(_serializers, isCritical, const FullType(bool)),
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

    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope>(
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

  /// Update a defect type
  /// Q27.1 — patches a company catalogue entry; nil fields are left untouched. The shared system defaults are read only and answer 409 &#x60;DEFECT_TYPE_SYSTEM_LOCKED&#x60;. Deactivating an entry (&#x60;is_active&#x3D;false&#x60;) keeps historic reports intact but removes it from new inspections.
  ///
  /// Parameters:
  /// * [id] - Defect type id
  /// * [body] - Patch payload
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope>> defectTypesIdPatch({ 
    required String id,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/defect-types/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'PATCH',
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
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate);
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

    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope>(
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

  /// Create a defect type
  /// Q27.1 — adds a company level catalogue entry. The name is unique per category inside the company; the shared defaults are untouched.
  ///
  /// Parameters:
  /// * [body] - Catalogue entry
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope>> defectTypesPost({ 
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/defect-types';
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
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate);
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

    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeEnvelope>(
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

  /// List DVIR reports
  /// TZ §7 — inspection reports of the tenant, newest first. &#x60;status&#x60; follows the §7.2 state machine and &#x60;kind&#x60; is the derived mobile label of §7.3 (&#x60;no_defects&#x60;, &#x60;defects_not_fixed&#x60;, &#x60;defects_uncertified&#x60;, &#x60;defects_fixed&#x60;). A self scoped principal (driver) only sees its own reports. Distances are metres; timestamps are ISO 8601 UTC.
  ///
  /// Parameters:
  /// * [unitId] - Unit filter (uuid)
  /// * [driverId] - Driver filter (uuid)
  /// * [type] - Inspection type
  /// * [status] - State machine status
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
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope>> dvirReportsGet({ 
    String? unitId,
    String? driverId,
    String? type,
    String? status,
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
    final _path = r'/dvir-reports';
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
      if (unitId != null) r'unit_id': encodeQueryParameter(_serializers, unitId, const FullType(String)),
      if (driverId != null) r'driver_id': encodeQueryParameter(_serializers, driverId, const FullType(String)),
      if (type != null) r'type': encodeQueryParameter(_serializers, type, const FullType(String)),
      if (status != null) r'status': encodeQueryParameter(_serializers, status, const FullType(String)),
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

    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope>(
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

  /// Certify a repaired DVIR
  /// TZ §7.2 — the driver answers \&quot;Previous defects repaired?\&quot; with a signature, moving &#x60;repaired&#x60; → &#x60;certified&#x60;. Q30.1: a different driver of the same tenant is accepted, so the endpoint only requires the caller to own a driver record. Once a critical defect report is certified the unit leaves &#x60;out_of_service&#x60;. Any other source status answers 409 &#x60;DVIR_INVALID_TRANSITION&#x60;.
  ///
  /// Parameters:
  /// * [id] - DVIR report id
  /// * [body] - Driver signature
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope>> dvirReportsIdCertifyPost({ 
    required String id,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/dvir-reports/{id}/certify'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
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
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify);
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

    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope>(
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

  /// Get DVIR report
  /// One inspection report with its defects, signatures and repair trail. Cross-tenant and out of scope ids answer 404, never 403.
  ///
  /// Parameters:
  /// * [id] - DVIR report id
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope>> dvirReportsIdGet({ 
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/dvir-reports/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
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

    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope>(
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

  /// DVIR report PDF
  /// Q31 — the administrator \&quot;Generate Report\&quot; surface: a printable copy of an existing DVIR, never a new one. The document is printed with headless Chrome; when no Chrome binary is reachable the endpoint degrades to &#x60;text/html&#x60; instead of failing, so check &#x60;Content-Type&#x60;. Signature and photo files stay object storage references and are not embedded.
  ///
  /// Parameters:
  /// * [id] - DVIR report id
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [String] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<String>> dvirReportsIdPdfGet({ 
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/dvir-reports/{id}/pdf'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
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

    String? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : rawResponse as String;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<String>(
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

  /// Record a DVIR repair
  /// TZ §7.2 — the Service Manager transition &#x60;submitted_defects_found&#x60; → &#x60;repaired&#x60;. Q27: the mechanic signature only exists on this step. An optional invoice (number, vendor, cost, file key) is written to the maintenance history. Any other source status answers 409 &#x60;DVIR_INVALID_TRANSITION&#x60;.
  ///
  /// Parameters:
  /// * [id] - DVIR report id
  /// * [body] - Repair payload
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope>> dvirReportsIdRepairPost({ 
    required String id,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/dvir-reports/{id}/repair'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
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
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair);
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

    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope>(
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

  /// DVIR reports pending certification
  /// TZ §7.2 — the reports whose defects still wait for the driver&#39;s \&quot;Previous defects repaired?\&quot; signature. The mobile app calls this before a pre-trip DVIR of the same unit. Q30.1: after seven days without a follow-up report, or once the unit goes inactive, a background sweep closes the entry as &#x60;closed_no_certification&#x60; and it disappears from this list.
  ///
  /// Parameters:
  /// * [unitId] - Unit filter (uuid)
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope>> dvirReportsPendingCertificationGet({ 
    String? unitId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/dvir-reports/pending-certification';
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

    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportListEnvelope>(
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

  /// Submit a DVIR report
  /// TZ §7.1 (mobile, driver only). Q31: an administrator never files a DVIR on a driver&#39;s behalf, so the caller must own a driver record — anyone else gets 403 &#x60;DVIR_ADMIN_CREATE_DENIED&#x60;. Q28: time, location, odometer and engine hours are captured server side from telemetry, so the body carries none of them. Q27.1: every defect references the &#x60;defect_types&#x60; catalogue and carries at most five photos. Q27.2: a defect flagged &#x60;is_critical&#x60; sets &#x60;units.out_of_service&#x60; and raises an immediate alert. The stored status is derived, not sent: no defects yields &#x60;submitted_no_defects&#x60;, any defect yields &#x60;submitted_defects_found&#x60; (the mobile &#x60;in_progress&#x60; state never reaches the server, Q30.2).
  ///
  /// Parameters:
  /// * [body] - Inspection payload
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope>> dvirReportsPost({ 
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/dvir-reports';
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
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate);
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

    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirReportEnvelope>(
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
