/// Inspection HTTP kontrakti — `contracts/swagger.json` dagi endpointlar faqat.
///
/// TODO(M1): `packages/eld_api` generatsiyasi ulangach [DioInspectionApi]
/// o'sha klient ustidagi yupqa wrapper'ga aylanadi.
library;

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/inspection_models.dart';
import 'inspection_json.dart';

abstract interface class InspectionApi {
  /// `POST /inspection/begin`.
  Future<InspectionSession?> begin();

  /// `GET /inspection/logs?driver_id&date`.
  Future<InspectionReport?> logs({String? driverId, DateTime? date});

  /// `POST /inspection/email`.
  Future<void> email(InspectionEmailRequest request);

  /// `POST /inspection/transfer`.
  Future<InspectionTransferResult> transfer({String? driverId, DateTime? date, String? comment});
}

class DioInspectionApi implements InspectionApi {
  const DioInspectionApi(this._dio);

  final Dio _dio;

  @override
  Future<InspectionSession?> begin() => guardApiCall(() async {
    final Response<Map<String, dynamic>> response = await _dio.post<Map<String, dynamic>>(
      '/inspection/begin',
    );
    return inspectionSessionFromJson(response.data);
  });

  @override
  Future<InspectionReport?> logs({String? driverId, DateTime? date}) => guardApiCall(() async {
    final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>(
      '/inspection/logs',
      queryParameters: <String, Object?>{
        'driver_id': ?driverId,
        if (date != null) 'date': logDateParam(date),
      },
    );
    return inspectionReportFromJson(response.data);
  });

  @override
  Future<void> email(InspectionEmailRequest request) => guardApiCall(() async {
    await _dio.post<Map<String, dynamic>>(
      '/inspection/email',
      data: <String, Object?>{
        'email': request.email.trim(),
        'driver_id': ?request.driverId,
        if (request.date != null) 'date': logDateParam(request.date!),
        if (request.comment != null && request.comment!.trim().isNotEmpty)
          'comment': request.comment!.trim(),
      },
    );
  });

  @override
  Future<InspectionTransferResult> transfer({String? driverId, DateTime? date, String? comment}) =>
      guardApiCall(() async {
        final Response<Map<String, dynamic>> response = await _dio.post<Map<String, dynamic>>(
          '/inspection/transfer',
          data: <String, Object?>{
            'driver_id': ?driverId,
            if (date != null) 'date': logDateParam(date),
            if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
          },
        );
        return inspectionTransferFromJson(response.data);
      });
}
