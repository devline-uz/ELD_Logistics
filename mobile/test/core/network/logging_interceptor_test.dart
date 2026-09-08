@Timeout(Duration(seconds: 60))
/// **S-L1 / M152 / M159** — log interceptorining maskalashi.
library;

import 'package:dio/dio.dart';
import 'package:eld_mobile/core/network/error_mapper.dart';
import 'package:eld_mobile/core/network/logging_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

/// Yozilgan satrlarni to'playdigan logger chiqishi.
class _CapturingOutput extends LogOutput {
  final List<String> lines = <String>[];

  @override
  void output(OutputEvent event) => lines.addAll(event.lines);
}

void main() {
  late _CapturingOutput output;
  late LoggingInterceptor interceptor;

  setUp(() {
    output = _CapturingOutput();
    interceptor = LoggingInterceptor(
      logger: Logger(printer: SimplePrinter(colors: false), output: output),
    );
  });

  test('Authorization to\'liq maskalanadi', () {
    final RequestOptions options = RequestOptions(path: '/logs')
      ..headers[HttpHeaders2.authorization] = 'Bearer super-secret-token'
      ..headers[HttpHeaders2.deviceId] = '1f2a3b4c-5d6e-7f80-9012-3456789abcde';

    interceptor.onRequest(options, RequestInterceptorHandler());

    final String logged = output.lines.join('\n');
    expect(logged, isNot(contains('super-secret-token')));
    expect(logged, contains('***'));
  });

  test('X-Device-Id qisman maskalanadi (to\'liq identifikator logga tushmaydi)', () {
    const String deviceId = '1f2a3b4c-5d6e-7f80-9012-3456789abcde';
    final RequestOptions options = RequestOptions(path: '/logs')
      ..headers[HttpHeaders2.deviceId] = deviceId;

    interceptor.onRequest(options, RequestInterceptorHandler());

    final String logged = output.lines.join('\n');
    expect(logged, isNot(contains(deviceId)));
    expect(logged, contains('1f2a3b4c***'));
  });

  test('maskIdentifier qisqa qiymatni butunlay yashiradi', () {
    expect(maskIdentifier('abc'), '***');
    expect(maskIdentifier(null), '***');
    expect(maskIdentifier('1f2a3b4c-5d6e'), '1f2a3b4c***');
  });

  test('o\'chirilgan interceptor hech narsa yozmaydi (M163)', () {
    LoggingInterceptor(
      logger: Logger(printer: SimplePrinter(colors: false), output: output),
      enabled: false,
    ).onRequest(
      RequestOptions(path: '/logs')..headers[HttpHeaders2.deviceId] = 'abcdefgh-ijkl',
      RequestInterceptorHandler(),
    );

    expect(output.lines, isEmpty);
  });
}
