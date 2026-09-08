/// `Idempotency-Key` sarlavhasi (D§3: POST larda ixtiyoriy, `/sync/push` da
/// **majburiy**) va qurilma sarlavhalari.
library;

import 'dart:math';

import 'package:dio/dio.dart';

import 'error_mapper.dart';
import 'request_options_x.dart';

/// Kalit majburiy bo'lgan yo'llar.
const Set<String> _mandatoryIdempotencyPaths = <String>{'/sync/push'};

class IdempotencyInterceptor extends Interceptor {
  IdempotencyInterceptor({required this.appVersion, required this.deviceId, Random? random})
    : _random = random ?? Random.secure();

  final String appVersion;
  final Future<String> Function() deviceId;
  final Random _random;

  String? _cachedDeviceId;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    _cachedDeviceId ??= await deviceId();
    options.headers[HttpHeaders2.appVersion] = appVersion;
    options.headers[HttpHeaders2.deviceId] = _cachedDeviceId;

    final String verb = options.method.toUpperCase();
    final bool mutating = verb == 'POST' || verb == 'PATCH' || verb == 'PUT';
    final bool mandatory = _mandatoryIdempotencyPaths.any((String p) => options.path.endsWith(p));

    if (mutating &&
        (mandatory || options.presetIdempotencyKey != null) &&
        !options.headers.containsKey(HttpHeaders2.idempotencyKey)) {
      options.headers[HttpHeaders2.idempotencyKey] = options.presetIdempotencyKey ?? _newKey();
    }

    handler.next(options);
  }

  /// Retry paytida **o'zgarmaydigan** kalit: bir marta generatsiya qilinadi va
  /// `extra` da saqlanadi.
  String _newKey() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256), growable: false);
    return bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
