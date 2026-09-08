/// DVIR HTTP kontrakti (`contracts/swagger.json` dagi endpointlar **faqat**).
///
/// TODO(M1): `packages/eld_api` generatsiyasi `pubspec.yaml` ga ulangach
/// [DioDvirApi] o'sha klient ustidagi yupqa wrapper'ga aylanadi. Hozircha
/// JSON → domen mapping shu qatlamda; `eld_api` modeli UI ga chiqmaydi (M5).
library;

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/dvir_models.dart';
import '../domain/dvir_repository.dart';
import 'dvir_json.dart';

/// DVIR va katalog uchun tarmoq kontrakti.
abstract interface class DvirApi {
  Future<List<DefectType>> defectTypes();

  Future<List<TrailerRef>> trailers(String query);

  Future<DvirReport> create(Map<String, Object?> body, {required String idempotencyKey});

  Future<DvirReport?> byId(String id);

  Future<List<DvirReport>> pendingCertification({String? unitId});

  Future<DvirReport> certify({
    required String id,
    required String signatureKey,
    required String idempotencyKey,
  });

  Future<List<int>> pdf(String id);
}

/// Haqiqiy `dio` implementatsiyasi.
class DioDvirApi implements DvirApi {
  const DioDvirApi(this._dio);

  final Dio _dio;

  @override
  Future<List<DefectType>> defectTypes() => guardApiCall(() async {
    final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>(
      '/defect-types',
      queryParameters: const <String, Object?>{'is_active': true, 'per_page': 200},
    );
    return defectTypesFromJson(response.data);
  });

  @override
  Future<List<TrailerRef>> trailers(String query) => guardApiCall(() async {
    final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>(
      '/trailers',
      queryParameters: <String, Object?>{if (query.isNotEmpty) 'search': query, 'per_page': 50},
    );
    return trailersFromJson(response.data);
  });

  @override
  Future<DvirReport> create(Map<String, Object?> body, {required String idempotencyKey}) =>
      guardApiCall(() async {
        final Response<Map<String, dynamic>> response = await _dio.post<Map<String, dynamic>>(
          '/dvir-reports',
          data: body,
          options: Options(headers: <String, Object?>{'Idempotency-Key': idempotencyKey}),
        );
        return dvirReportFromJson(response.data?['data'] as Map<String, dynamic>?)!;
      });

  @override
  Future<DvirReport?> byId(String id) => guardApiCall(() async {
    final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>(
      '/dvir-reports/$id',
    );
    return dvirReportFromJson(response.data?['data'] as Map<String, dynamic>?);
  });

  @override
  Future<List<DvirReport>> pendingCertification({String? unitId}) => guardApiCall(() async {
    final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>(
      '/dvir-reports/pending-certification',
      queryParameters: <String, Object?>{'unit_id': ?unitId},
    );
    return dvirReportsFromJson(response.data);
  });

  @override
  Future<DvirReport> certify({
    required String id,
    required String signatureKey,
    required String idempotencyKey,
  }) => guardApiCall(() async {
    final Response<Map<String, dynamic>> response = await _dio.post<Map<String, dynamic>>(
      '/dvir-reports/$id/certify',
      data: <String, Object?>{'signature_key': signatureKey},
      options: Options(headers: <String, Object?>{'Idempotency-Key': idempotencyKey}),
    );
    return dvirReportFromJson(response.data?['data'] as Map<String, dynamic>?)!;
  });

  @override
  Future<List<int>> pdf(String id) => guardApiCall(() async {
    final Response<List<int>> response = await _dio.get<List<int>>(
      '/dvir-reports/$id/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const <int>[];
  });
}
