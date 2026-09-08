/// Testlar va dev menyusi uchun `SyncTransport` mock'i (M2; real transport M5 da).
library;

import '../security/secure_vault.dart';
import '../time/clock_verdict.dart';
import 'sync_transport.dart';

/// Barcha elementlarni `accepted` qiladigan, sozlanadigan mock.
class MockSyncTransport implements SyncTransport {
  MockSyncTransport({required this.serverTime, this.clock});

  /// Server vaqti — testda qo'lda boshqariladi.
  DateTime serverTime;

  ClockVerdict? clock;

  /// Har element uchun natijani belgilaydi; `null` — `accepted`.
  PushItemResult Function(String clientId)? verdictFor;

  /// Chaqiruv o'rniga tashlanadigan xato (tarmoq/timeout simulyatsiyasi).
  Object? failWith;

  /// Navbatdagi pull javoblari; bo'shasa bo'sh javob qaytariladi.
  final List<PullResponse> pullQueue = <PullResponse>[];

  /// Yuborilgan so'rovlar tarixi — tartib va kalitlarni tekshirish uchun.
  final List<PushRequest> pushes = <PushRequest>[];

  final List<String?> pullCursors = <String?>[];

  /// Pull qaysi slot nomidan qilinganini yozib boradi (B-120 testlari).
  final List<DriverSlot> pullSlots = <DriverSlot>[];

  @override
  Future<PushResponse> push(PushRequest request, {required Duration timeout}) async {
    pushes.add(request);
    final Object? failure = failWith;
    if (failure != null) {
      throw failure;
    }
    final List<Map<String, Object?>> all = <Map<String, Object?>>[
      ...request.events,
      ...request.dvir,
      ...request.chat,
      for (final OtherPushItem item in request.other)
        <String, Object?>{...item.payload, 'client_id': item.clientId},
    ];
    return PushResponse(
      serverTime: serverTime,
      clock: clock,
      telemetryAccepted: request.telemetry.length,
      items: all
          .map((Map<String, Object?> item) {
            final String id = (item['client_event_id'] ?? item['client_id'] ?? '').toString();
            return verdictFor?.call(id) ?? PushItemResult(clientId: id, result: 'accepted');
          })
          .toList(growable: false),
    );
  }

  @override
  Future<PullResponse> pull({
    String? since,
    String? unitId,
    DriverSlot slot = DriverSlot.primary,
    required Duration timeout,
  }) async {
    pullCursors.add(since);
    pullSlots.add(slot);
    final Object? failure = failWith;
    if (failure != null) {
      throw failure;
    }
    if (pullQueue.isEmpty) {
      return PullResponse(serverTime: serverTime, nextSince: since ?? serverTime.toIso8601String());
    }
    return pullQueue.removeAt(0);
  }
}
