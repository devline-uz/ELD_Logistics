/// `M-47 Check network` o'lchovi (tz-mobile §10.5, **M75**, ❓**M76**).
///
/// **M75 [MUST]** tashqi speedtest xizmatlari ishlatilmaydi (PII + sertifikat
/// pinning). O'lchov faqat backend so'rovi bilan bajariladi.
///
/// **❓M76:** `v1` kontraktida test fayli endpoint'i **yo'q** (CR nomzodi).
/// MVP: `GET /app/config` javobining **davomiyligi va hajmi** bo'yicha
/// taxminiy tezlik hisoblanadi va UI da `approx.` yorlig'i turadi. Endpoint
/// paydo bo'lganda faqat [DioNetworkProbe._path] va [_minPayloadBytes]
/// almashtiriladi.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/request_options_x.dart';
import '../../profile/data/api_providers.dart';
import '../domain/diagnostics_models.dart';

/// O'lchov shartnomasi — testda soxta implementatsiya beriladi.
abstract class NetworkProbe {
  Future<NetworkMeasurement> measure();
}

/// Javob juda kichik bo'lsa taxminiy tezlik cheksizga intiladi — shuning
/// uchun pastdan chegaralanadi (`GET /app/config` odatda 1–3 KB).
const int _minPayloadBytes = 2048;

class DioNetworkProbe implements NetworkProbe {
  const DioNetworkProbe(this._dio);

  final Dio _dio;

  /// TODO(M76): test fayli endpoint'i qo'shilsa shu yo'l almashtiriladi.
  static const String _path = '/app/config';

  @override
  Future<NetworkMeasurement> measure() async {
    final Stopwatch watch = Stopwatch()..start();
    final Response<List<int>> response = await _dio.get<List<int>>(
      _path,
      options: Options(
        responseType: ResponseType.bytes,
        // `app/config` anonim — o'lchov token yangilash bilan buzilmaydi.
        extra: const <String, Object?>{RequestExtra.anonymous: true},
      ),
    );
    watch.stop();

    final int bytes = (response.data?.length ?? 0).clamp(_minPayloadBytes, 1 << 24);
    final Duration elapsed = watch.elapsed <= Duration.zero
        ? const Duration(milliseconds: 1)
        : watch.elapsed;
    final double mbps = (bytes * 8) / elapsed.inMicroseconds; // bit/µs == Mbit/s
    return NetworkMeasurement(
      mbps: mbps.clamp(0, kNetworkGaugeTicks.last).toDouble(),
      roundTrip: elapsed,
    );
  }
}

final Provider<NetworkProbe> networkProbeProvider = Provider<NetworkProbe>(
  (Ref ref) => DioNetworkProbe(ref.watch(eldDioProvider)),
);
