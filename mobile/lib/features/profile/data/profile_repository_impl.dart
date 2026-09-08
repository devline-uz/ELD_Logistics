/// `GET /me`, `POST /auth/logout`, `GET /app/config` — `contracts/swagger.json`.
///
/// Javob konverti: `{"data": {...}}`. Xatolar `core/network/error_mapper.dart`
/// tomonidan `ApiError` ga aylantiriladi, bu yerda ushlanmaydi.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/app_config_info.dart';
import '../domain/driver_profile.dart';
import '../domain/profile_repository.dart';
import 'api_providers.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<DriverProfile> load() => guardApiCall<DriverProfile>(() async {
    final Response<Map<String, Object?>> res = await _dio.get<Map<String, Object?>>('/me');
    final Map<String, Object?> data = _data(res.data);
    return DriverProfile(
      id: _str(data['id']) ?? '',
      firstName: _str(data['first_name']) ?? '',
      lastName: _str(data['last_name']) ?? '',
      email: _str(data['email']) ?? '',
      username: _str(data['username']),
      pinSet: data['pin_set'] == true,
      permissions: <String>[
        ...?(data['permissions'] as List<Object?>?)?.map((Object? e) => e.toString()),
      ],
      // `unit_number`, `phone`, `license_no`, `license_region` — `/me` da yo'q.
      // TODO(M-44): kontraktga qo'shilgach shu yerda to'ldiriladi.
    );
  });

  /// `POST /auth/logout {pause:false}` — **idempotent**.
  ///
  /// #B-1: server sessiyani allaqachon yopgan bo'lsa `401 TOKEN_REVOKED`
  /// qaytaradi; bu chiqish nuqtai nazaridan **muvaffaqiyat**, shuning uchun
  /// bu yerda yutiladi. Boshqa xatolar `ApiError` bo'lib chiqadi (hech qachon
  /// xom `DioException` emas) va chaqiruvchi ularni ham best-effort ko'radi.
  @override
  Future<void> logout() => guardApiCall<void>(() async {
    try {
      await _dio.post<void>('/auth/logout', data: const <String, Object?>{'pause': false});
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return;
      }
      rethrow;
    }
  });
}

class AppConfigRepositoryImpl implements AppConfigRepository {
  const AppConfigRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<AppConfigInfo> load() => guardApiCall<AppConfigInfo>(() async {
    final Response<Map<String, Object?>> res = await _dio.get<Map<String, Object?>>('/app/config');
    final Map<String, Object?> data = _data(res.data);
    final Map<String, Object?> flags =
        (data['feature_flags'] as Map<String, Object?>?) ?? const <String, Object?>{};
    return AppConfigInfo(
      latestVersion: _str(data['latest_version']),
      minSupportedVersion: _str(data['min_supported_version']),
      forceUpdate: data['force_update'] == true,
      supportEmail: _str(data['support_email']),
      userManualUrl: _str(flags['user_manual_url']),
    );
  });
}

Map<String, Object?> _data(Map<String, Object?>? body) =>
    (body?['data'] as Map<String, Object?>?) ?? const <String, Object?>{};

String? _str(Object? value) {
  if (value == null) {
    return null;
  }
  final String text = value.toString().trim();
  return text.isEmpty ? null : text;
}

final Provider<ProfileRepository> profileRepositoryProvider = Provider<ProfileRepository>(
  (Ref ref) => ProfileRepositoryImpl(ref.watch(eldDioProvider)),
);

final Provider<AppConfigRepository> appConfigRepositoryProvider = Provider<AppConfigRepository>(
  (Ref ref) => AppConfigRepositoryImpl(ref.watch(eldDioProvider)),
);
