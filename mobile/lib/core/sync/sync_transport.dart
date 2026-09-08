/// `SyncTransport` — `/sync/push` va `/sync/pull` uchun abstraksiya (§6).
///
/// M2 bosqichida faqat interfeys va mock bor; haqiqiy `dio` implementatsiyasi
/// M5 da (`packages/eld_api` generatsiyasi ustiga) yoziladi. Scheduler transport
/// turini bilmaydi — shu sababli oflayn mantiq testlarda to'liq qoplanadi.
library;

import 'package:sync_core/sync_core.dart';

import '../security/secure_vault.dart';
import '../time/clock_verdict.dart';

/// Push so'rovi. `events`/`telemetry`/`dvir`/`chat` — outbox payload'lari.
class PushRequest {
  const PushRequest({
    required this.deviceId,
    required this.appVersion,
    required this.idempotencyKey,
    required this.phoneTime,
    this.slot = DriverSlot.primary,
    this.unitId,
    this.eldRtcTime,
    this.events = const <Map<String, Object?>>[],
    this.telemetry = const <Map<String, Object?>>[],
    this.dvir = const <Map<String, Object?>>[],
    this.chat = const <Map<String, Object?>>[],
    this.other = const <OtherPushItem>[],
  });

  final String deviceId;
  final String appVersion;

  /// M33.3: batch bilan birga saqlanadi, timeout dan keyin o'zgarmaydi.
  final String idempotencyKey;

  final DateTime phoneTime;

  /// **B-120:** batch qaysi haydovchi sessiyasidan ketadi. Transport buni
  /// `RequestExtra.slot` ga qo'yadi — `AuthInterceptor` aynan shu slotning
  /// tokenini oladi. Batch **hech qachon** ikki slotni aralashtirmaydi.
  final DriverSlot slot;

  final String? unitId;

  /// ELD ulanmagan bo'lsa **yuborilmaydi** (§6.1).
  final DateTime? eldRtcTime;

  final List<Map<String, Object?>> events;
  final List<Map<String, Object?>> telemetry;
  final List<Map<String, Object?>> dvir;
  final List<Map<String, Object?>> chat;

  /// `certify`/`claim`/`log_edit`/`push_token`/`feedback`/`support`.
  ///
  /// **Kontrakt cheklovi (M-SYNC1):** `sync_dto.PushRequest` da faqat
  /// `events`/`telemetry`/`dvir`/`chat` bucket'lari bor — bu elementlar
  /// `/sync/push` bilan **yubormaydi**, transport ularni o'z endpoint'lariga
  /// (`/daily-logs/{id}/certify`, `/unidentified-events/{id}/claim`,
  /// `/log-edit-requests`, `/feedback`, `/support-tickets`) uzatadi.
  final List<OtherPushItem> other;

  int get itemCount => events.length + telemetry.length + dvir.length + chat.length + other.length;
}

/// `other` bucket elementi — turi bilan birga (endpoint tanlash uchun).
class OtherPushItem {
  const OtherPushItem({required this.kind, required this.clientId, required this.payload});

  final OutboxKind kind;
  final String clientId;
  final Map<String, Object?> payload;
}

/// Bitta element uchun server verdikti.
class PushItemResult {
  const PushItemResult({
    required this.clientId,
    required this.result,
    this.reason,
    this.supersededBy,
  });

  final String clientId;

  /// `accepted`/`duplicate`/`rejected`.
  final String result;

  final String? reason;
  final String? supersededBy;
}

class PushResponse {
  const PushResponse({
    required this.serverTime,
    this.clock,
    this.items = const <PushItemResult>[],
    this.telemetryAccepted = 0,
    this.telemetryDuplicate = 0,
  });

  final DateTime serverTime;

  /// M39: kanonik soat verdikti.
  final ClockVerdict? clock;

  final List<PushItemResult> items;
  final int telemetryAccepted;
  final int telemetryDuplicate;
}

/// Pull javobi. Bo'limlar xom `Map` — M5 da `eld_api` modeliga bog'lanadi.
class PullResponse {
  const PullResponse({
    required this.serverTime,
    required this.nextSince,
    this.truncated = false,
    this.hosPolicy,
    this.sessionProfile,
    this.defectTypes = const <Map<String, Object?>>[],
    this.quickNotes = const <Map<String, Object?>>[],
    this.trailers = const <Map<String, Object?>>[],
    this.events = const <Map<String, Object?>>[],
    this.dailyLogs = const <Map<String, Object?>>[],
    this.logEditRequests = const <Map<String, Object?>>[],
    this.unidentifiedEvents = const <Map<String, Object?>>[],
    this.chat = const <Map<String, Object?>>[],
    this.violations = const <Map<String, Object?>>[],
  });

  final DateTime serverTime;

  /// Keyingi kursor — mijoz hisoblamaydi (M35).
  final String nextSince;

  /// `true` bo'lsa darhol yangi kursor bilan qayta pull (drenaj sikli).
  final bool truncated;

  final Map<String, Object?>? hosPolicy;

  /// `kv_settings` ga yoziladigan sessiya profili bo'lagi (`driver_name`,
  /// `carrier_name`, `home_terminal_address`, `unit_number`, `vehicle_label`,
  /// `home_terminal_tz`). Kontraktda alohida bo'lim yo'q — transport uni
  /// `daily_logs` va kunlik log formasidan yig'adi.
  final Map<String, Object?>? sessionProfile;
  final List<Map<String, Object?>> defectTypes;
  final List<Map<String, Object?>> quickNotes;
  final List<Map<String, Object?>> trailers;
  final List<Map<String, Object?>> events;
  final List<Map<String, Object?>> dailyLogs;
  final List<Map<String, Object?>> logEditRequests;
  final List<Map<String, Object?>> unidentifiedEvents;
  final List<Map<String, Object?>> chat;

  /// `GET /violations` — `sync/pull` da bo'limi yo'q, transport alohida
  /// so'rov bilan oladi va lokal keshga yozadi (oflayn Log report uchun).
  final List<Map<String, Object?>> violations;
}

/// Transport xatosi — HTTP statusi va kodi bilan (§6.1 jadvali).
class SyncTransportException implements Exception {
  const SyncTransportException({
    required this.code,
    this.statusCode,
    this.retryAfter,
    this.message,
  });

  /// `CLIENT_NETWORK`, `IDEMPOTENCY_CONFLICT`, `RATE_LIMITED`, … .
  final String code;

  final int? statusCode;

  /// `429` javobidagi `Retry-After` — backoff ladderdan ustun.
  final Duration? retryAfter;

  final String? message;

  bool get isIdempotencyConflict => statusCode == 409;

  bool get isPayloadTooLarge => statusCode == 413 || statusCode == 422 && code == 'BATCH_TOO_LARGE';

  bool get isForbidden => statusCode == 403;

  bool get isValidationError => statusCode == 422;

  @override
  String toString() => 'SyncTransportException($code, status=$statusCode)';
}

/// Server bilan aloqa. Implementatsiya M5 da.
abstract interface class SyncTransport {
  Future<PushResponse> push(PushRequest request, {required Duration timeout});

  Future<PullResponse> pull({
    String? since,
    String? unitId,
    DriverSlot slot = DriverSlot.primary,
    required Duration timeout,
  });
}
