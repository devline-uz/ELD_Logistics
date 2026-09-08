/// `SyncTransport` ning haqiqiy (Dio) implementatsiyasi — §6, `eld-sync`.
///
/// Kontrakt: `contracts/swagger.json` → `POST /sync/push`, `GET /sync/pull`.
/// Endpoint yoki maydon **o'ylab topilmaydi**.
///
/// Mas'uliyat chegarasi: bu sinf faqat HTTP va JSON bilan ishlaydi. Batch
/// bo'lish (413), `409` da kalitni yangilash, `truncated` drenaji va backoff
/// — [SyncEngine] va [SyncScheduler] zimmasida; transport ularga to'g'ri
/// [SyncTransportException] beradi.
library;

import 'package:dio/dio.dart';

import '../error/api_error.dart';
import '../error/api_error_code.dart';
import '../network/error_mapper.dart';
import '../network/request_options_x.dart';
import '../security/secure_vault.dart';
import '../time/clock_verdict.dart';
import 'sync_side_channel.dart';
import 'sync_transport.dart';

/// `/sync/push` va `/sync/pull` yo'llari (`basePath=/api/v1` Dio da).
const String kSyncPushPath = '/sync/push';
const String kSyncPullPath = '/sync/pull';

/// Kunlik log formasidan sessiya profilini qayta o'qish davri.
const Duration kSessionProfileRefresh = Duration(hours: 12);

/// `GET /violations` sahifasi hajmi (14 kunlik oyna uchun yetarli).
const int kViolationsPageSize = 200;

class DioSyncTransport implements SyncTransport {
  DioSyncTransport({required Dio dio, SyncSideChannel? sideChannel}) : this._(dio, sideChannel);

  DioSyncTransport._(this._dio, this._sideChannel);

  final Dio _dio;

  /// `certify`/`claim`/`log_edit`/`feedback`/`support` uchun (M-SYNC1).
  final SyncSideChannel? _sideChannel;

  /// Oxirgi marta kunlik log formasi o'qilgan vaqt (`server_time` bo'yicha).
  DateTime? _profileReadAt;

  // --- push -------------------------------------------------------------------

  @override
  Future<PushResponse> push(PushRequest request, {required Duration timeout}) async {
    // Kontraktdagi to'rt bucket. `other` bu yerda **yuborilmaydi**.
    final Map<String, Object?> body = <String, Object?>{
      'device_id': request.deviceId,
      'app_version': request.appVersion,
      if (request.unitId != null) 'unit_id': request.unitId,
      'clock': <String, Object?>{
        'phone': request.phoneTime.toUtc().toIso8601String(),
        if (request.eldRtcTime != null) 'eld_rtc': request.eldRtcTime!.toUtc().toIso8601String(),
      },
      if (request.events.isNotEmpty) 'events': request.events,
      if (request.telemetry.isNotEmpty) 'telemetry': request.telemetry,
      if (request.dvir.isNotEmpty)
        'dvir': <Map<String, Object?>>[
          for (final Map<String, Object?> item in request.dvir)
            <String, Object?>{'client_id': item['client_id'] ?? item['client_event_id']},
        ],
      if (request.chat.isNotEmpty)
        'chat': <Map<String, Object?>>[
          for (final Map<String, Object?> item in request.chat)
            <String, Object?>{'client_id': item['client_id'] ?? item['client_event_id']},
        ],
    };

    final bool hasSyncPayload =
        request.events.isNotEmpty ||
        request.telemetry.isNotEmpty ||
        request.dvir.isNotEmpty ||
        request.chat.isNotEmpty;

    Map<String, Object?> data = const <String, Object?>{};
    if (hasSyncPayload) {
      final Response<Map<String, Object?>> response = await _send<Map<String, Object?>>(
        () => _dio.post<Map<String, Object?>>(
          kSyncPushPath,
          data: body,
          options: Options(
            sendTimeout: timeout,
            receiveTimeout: timeout,
            // M33.3: kalit batch bilan birga saqlanadi va retry'da o'zgarmaydi.
            headers: <String, Object?>{HttpHeaders2.idempotencyKey: request.idempotencyKey},
            extra: <String, Object?>{
              RequestExtra.idempotent: true,
              RequestExtra.idempotencyKey: request.idempotencyKey,
              // B-120: batch aynan o'z haydovchisining tokeni bilan ketadi.
              RequestExtra.slot: request.slot,
            },
          ),
        ),
      );
      data = _envelope(response.data);
    }

    final List<PushItemResult> items = <PushItemResult>[
      ..._results(data['events']),
      ..._results(data['dvir']),
      ..._results(data['chat']),
      // Kontraktda bucket'i yo'q turlar — o'z endpoint'lariga (M-SYNC1).
      if (request.other.isNotEmpty && _sideChannel != null)
        ...await _sideChannel.send(request.other, slot: request.slot),
    ];

    final Map<String, Object?> telemetry = _map(data['telemetry']);
    return PushResponse(
      serverTime: _time(data['server_time']) ?? request.phoneTime.toUtc(),
      clock: _clock(data['clock']),
      items: items,
      telemetryAccepted: _int(telemetry['accepted']),
      telemetryDuplicate: _int(telemetry['duplicate']),
    );
  }

  // --- pull -------------------------------------------------------------------

  @override
  Future<PullResponse> pull({
    String? since,
    String? unitId,
    DriverSlot slot = DriverSlot.primary,
    required Duration timeout,
  }) async {
    final Response<Map<String, Object?>> response = await _send<Map<String, Object?>>(
      () => _dio.get<Map<String, Object?>>(
        kSyncPullPath,
        queryParameters: <String, Object?>{
          if (since != null && since.isNotEmpty) 'since': since,
          if (unitId != null && unitId.isNotEmpty) 'unit_id': unitId,
        },
        options: Options(
          receiveTimeout: timeout,
          extra: <String, Object?>{RequestExtra.slot: slot},
        ),
      ),
    );

    final Map<String, Object?> data = _envelope(response.data);
    final DateTime serverTime =
        _time(data['server_time']) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final List<Map<String, Object?>> dailyLogs = _list(data['daily_logs']);

    return PullResponse(
      serverTime: serverTime,
      nextSince: data['next_since']?.toString() ?? since ?? '',
      truncated: data['truncated'] == true,
      hosPolicy: _policyPayload(data['hos_policy']),
      sessionProfile: await _sessionProfile(
        dailyLogs: dailyLogs,
        serverTime: serverTime,
        slot: slot,
      ),
      defectTypes: <Map<String, Object?>>[
        for (final Map<String, Object?> m in _list(data['defect_types'])) _defectType(m),
      ],
      // Kontraktda `quick_notes` — oddiy satrlar massivi.
      quickNotes: <Map<String, Object?>>[
        for (final Object? note in _rawList(data['quick_notes']))
          if (note?.toString() case final String text when text.isNotEmpty)
            <String, Object?>{'id': text, 'text': text},
      ],
      trailers: _list(data['trailers']),
      events: _list(data['events']),
      dailyLogs: dailyLogs,
      logEditRequests: _list(data['log_edit_requests']),
      unidentifiedEvents: _list(data['unidentified_events']),
      chat: _list(data['chat']),
      violations: await _violations(since: since, slot: slot),
    );
  }

  /// `GET /violations` (`violations.read`).
  ///
  /// `sync_dto.PullResponse` da buzilishlar bo'limi yo'q va `logs_dto.DayTotals`
  /// da ham `violations` maydoni yo'q — yagona manba shu endpoint. Ruxsat
  /// bo'lmasa (`403`) jimgina o'tkazib yuboriladi: sync sikli buzilmaydi.
  Future<List<Map<String, Object?>>> _violations({
    String? since,
    DriverSlot slot = DriverSlot.primary,
  }) async {
    try {
      final Response<Map<String, Object?>> response = await _dio.get<Map<String, Object?>>(
        '/violations',
        queryParameters: <String, Object?>{
          if (since != null && since.isNotEmpty) 'from': since,
          'per_page': kViolationsPageSize,
        },
        options: Options(extra: <String, Object?>{RequestExtra.slot: slot}),
      );
      final Object? data = response.data?['data'];
      return _list(data);
    } on DioException {
      return const <Map<String, Object?>>[];
    }
  }

  /// `kv_settings` uchun profil bo'lagi.
  ///
  /// `sync_dto.PullResponse` da haydovchi/carrier bo'limi **yo'q**, ammo
  /// `GET /daily-logs/{id}` (`logs.read`) javobidagi `form` da `carrier_name`,
  /// `home_terminal_address`, `driver_name` va `units[]` bor. Shu sababli eng
  /// yangi kunlik log bo'yicha 12 soatda bir marta qo'shimcha so'rov qilinadi.
  Future<Map<String, Object?>?> _sessionProfile({
    required List<Map<String, Object?>> dailyLogs,
    required DateTime serverTime,
    DriverSlot slot = DriverSlot.primary,
  }) async {
    if (dailyLogs.isEmpty) {
      return null;
    }
    final DateTime? last = _profileReadAt;
    if (last != null && serverTime.difference(last).abs() < kSessionProfileRefresh) {
      // Timezone har pull'da tekin keladi — u har doim yangilanadi.
      return _timezoneOnly(dailyLogs);
    }

    final String? id = dailyLogs.last['id']?.toString();
    if (id == null || id.isEmpty) {
      return _timezoneOnly(dailyLogs);
    }

    try {
      final Response<Map<String, Object?>> response = await _dio.get<Map<String, Object?>>(
        '/daily-logs/$id',
        options: Options(extra: <String, Object?>{RequestExtra.slot: slot}),
      );
      _profileReadAt = serverTime;
      final Map<String, Object?> detail = _envelope(response.data);
      final Map<String, Object?> form = _map(detail['form']);
      final List<Map<String, Object?>> units = _list(form['units']);
      final Map<String, Object?> unit = units.isEmpty ? const <String, Object?>{} : units.first;
      return <String, Object?>{
        ...?_timezoneOnly(dailyLogs),
        'driver_id': detail['driver_id'],
        'driver_name': form['driver_name'] ?? detail['driver_name'],
        'carrier_name': form['carrier_name'],
        'home_terminal_address': form['home_terminal_address'],
        'unit_id': unit['id'],
        'unit_number': unit['unit_number'],
        // `vehicle_label` — Home kartasidagi ikkilamchi satr (davlat raqami).
        'vehicle_label': unit['license_plate'] ?? unit['unit_number'],
      };
    } on DioException {
      // Profil — ikkilamchi ma'lumot: yiqilsa sync sikli buzilmaydi.
      return _timezoneOnly(dailyLogs);
    }
  }

  Map<String, Object?>? _timezoneOnly(List<Map<String, Object?>> dailyLogs) {
    final String? tz = dailyLogs.last['timezone']?.toString();
    return tz == null || tz.isEmpty ? null : <String, Object?>{'home_terminal_tz': tz};
  }

  // --- yordamchi --------------------------------------------------------------

  /// `hos_policy` — kontraktda **yassi** obyekt; `hos_engine.parsePolicy()`
  /// esa `warning_thresholds` ni ichma-ich kutadi (M-HOS1).
  Map<String, Object?>? _policyPayload(Object? raw) {
    final Map<String, Object?> policy = _map(raw);
    if (policy.isEmpty) {
      return null;
    }
    final Map<String, Object?> document = <String, Object?>{
      ...policy,
      'warning_thresholds': <String, Object?>{
        'drive': policy['warn_drive_min'],
        'shift': policy['warn_shift_min'],
        'break': policy['warn_break_min'],
        'cycle': policy['warn_cycle_min'],
      }..removeWhere((String _, Object? value) => value == null),
    };
    return <String, Object?>{
      'version_id': policy['version_id'],
      'effective_from': policy['effective_from'],
      'document': document,
    };
  }

  Map<String, Object?> _defectType(Map<String, Object?> m) => <String, Object?>{
    'id': m['id'],
    'code': m['id'],
    'label': m['name'],
    'category': m['category'],
    // `category` (truck/trailer) — `applies_to` ning kontraktdagi nomi.
    'applies_to': m['category'] == 'trailer' ? 'trailer' : 'vehicle',
    'is_critical': m['is_critical'],
    'sort_order': m['sort_order'],
  };

  /// Dio xatolarini [SyncTransportException] ga o'giradi (§6.1 jadvali).
  Future<Response<T>> _send<T>(Future<Response<T>> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      final ApiError error = mapDioException(e);
      throw SyncTransportException(
        code: error.code,
        statusCode: error.statusCode,
        retryAfter: error.retryAfter ?? _retryAfterFallback(error),
        message: error.message,
      );
    }
  }

  /// `429` da `Retry-After` sarlavhasi yo'q bo'lsa — konservativ 60 s.
  Duration? _retryAfterFallback(ApiError error) =>
      error.code == ApiErrorCode.rateLimited ? const Duration(seconds: 60) : null;

  ClockVerdict? _clock(Object? raw) {
    final Map<String, Object?> m = _map(raw);
    return m.isEmpty ? null : ClockVerdict.fromJson(m);
  }

  List<PushItemResult> _results(Object? raw) => <PushItemResult>[
    for (final Map<String, Object?> m in _list(raw))
      PushItemResult(
        clientId: (m['client_event_id'] ?? m['client_id'] ?? '').toString(),
        result: m['result']?.toString() ?? 'accepted',
        reason: m['reason']?.toString(),
        supersededBy: m['superseded_by']?.toString(),
      ),
  ];

  /// Backend konverti: `{"data": {...}}`.
  static Map<String, Object?> _envelope(Map<String, Object?>? body) {
    if (body == null) {
      return const <String, Object?>{};
    }
    final Object? data = body['data'];
    return data is Map<String, Object?> ? data : body;
  }

  static Map<String, Object?> _map(Object? raw) =>
      raw is Map<String, Object?> ? raw : const <String, Object?>{};

  static List<Object?> _rawList(Object? raw) => raw is List ? raw : const <Object?>[];

  static List<Map<String, Object?>> _list(Object? raw) => <Map<String, Object?>>[
    for (final Object? item in _rawList(raw))
      if (item is Map<String, Object?>) item,
  ];

  static DateTime? _time(Object? raw) => DateTime.tryParse(raw?.toString() ?? '')?.toUtc();

  static int _int(Object? raw) => raw is num ? raw.toInt() : 0;
}
