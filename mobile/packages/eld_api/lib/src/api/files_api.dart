//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_files_dto_error_response.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_files_dto_presign_envelope.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_files_dto_presign_request.dart';

class FilesApi {

  final Dio _dio;

  final Serializers _serializers;

  const FilesApi(this._dio, this._serializers);

  /// Presign a file upload
  /// TZ B§3.4 — the API never proxies bytes. &#x60;kind&#x60; is a closed whitelist (dvir_photo, invoice, signature, logo, chat, import); the content type and the size are checked against the per-kind ceiling (DVIR photo ≤ 5 MiB, invoice ≤ 10 MiB) before anything is signed. The object key is derived server side from the tenant, the kind and a random uuid — a client supplied path is never trusted — and only that key is stored. The URL is a PUT valid for 15 minutes; its &#x60;Content-Type&#x60; **and** &#x60;Content-Length&#x60; headers are part of the signature, so the upload must be exactly &#x60;size_bytes&#x60; long — the ceiling cannot be bypassed after presigning. Send every header of &#x60;headers&#x60; verbatim.
  ///
  /// Parameters:
  /// * [body] - Upload description
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope>> filesPresignPost({ 
    required GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/files/presign';
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
      const _type = FullType(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignRequest);
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

    GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope),
      ) as GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope>(
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
