@Timeout(Duration(seconds: 60))
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eld_mobile/core/sync/dio_sync_transport.dart';
import 'package:eld_mobile/core/sync/sync_transport.dart';
import 'package:eld_mobile/core/time/clock_verdict.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

/// Yozib oluvchi soxta adapter — so'rovlarni tekshirish uchun.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, {int status = 200, Map<String, List<String>>? headers}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        ...?headers,
      },
    );

Dio _dio(_FakeAdapter adapter) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.test/api/v1',
      validateStatus: (int? status) => status != null && status < 400,
    ),
  );
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  final DateTime phoneTime = DateTime.utc(2026, 9, 7, 12);

  PushRequest pushWith({
    List<Map<String, Object?>> events = const <Map<String, Object?>>[],
    List<OtherPushItem> other = const <OtherPushItem>[],
  }) => PushRequest(
    deviceId: 'device-1',
    appVersion: '1.0.0',
    idempotencyKey: 'key-1',
    phoneTime: phoneTime,
    events: events,
    other: other,
  );

  group('push', () {
    test('kontraktdagi to\'rt bucket yuboriladi, `other` yuborilmaydi', () async {
      late Map<String, Object?> sent;
      final _FakeAdapter adapter = _FakeAdapter((RequestOptions options) async {
        sent = (options.data as Map<String, Object?>?) ?? <String, Object?>{};
        return _json(<String, Object?>{
          'data': <String, Object?>{
            'server_time': '2026-09-07T12:00:05Z',
            'events': <Object?>[
              <String, Object?>{'client_event_id': 'e-1', 'result': 'accepted'},
            ],
            'telemetry': <String, Object?>{'accepted': 3, 'duplicate': 1},
          },
        });
      });
      final DioSyncTransport transport = DioSyncTransport(dio: _dio(adapter));

      final PushResponse response = await transport.push(
        pushWith(
          events: <Map<String, Object?>>[
            <String, Object?>{'client_event_id': 'e-1'},
          ],
        ),
        timeout: const Duration(seconds: 30),
      );

      expect(adapter.requests.single.path, '/sync/push');
      expect(adapter.requests.single.headers['Idempotency-Key'], 'key-1');
      expect(sent.keys, containsAll(<String>['device_id', 'app_version', 'clock', 'events']));
      expect(sent.containsKey('other'), isFalse);
      expect(response.items.single.result, 'accepted');
      expect(response.telemetryAccepted, 3);
      expect(response.telemetryDuplicate, 1);
      expect(response.serverTime, DateTime.utc(2026, 9, 7, 12, 0, 5));
    });

    test('bo\'sh batch server so\'rovisiz qaytadi', () async {
      final _FakeAdapter adapter = _FakeAdapter(
        (RequestOptions options) async => _json(const <String, Object?>{}),
      );
      final DioSyncTransport transport = DioSyncTransport(dio: _dio(adapter));

      final PushResponse response = await transport.push(
        pushWith(),
        timeout: const Duration(seconds: 30),
      );

      expect(adapter.requests, isEmpty);
      expect(response.items, isEmpty);
    });

    test('clock verdikti o\'qiladi (M39)', () async {
      final _FakeAdapter adapter = _FakeAdapter(
        (RequestOptions options) async => _json(<String, Object?>{
          'data': <String, Object?>{
            'server_time': '2026-09-07T12:00:05Z',
            'clock': <String, Object?>{
              'source': 'eld_rtc',
              'clock_skew_sec': 130,
              'time_unverified': false,
              'warning': true,
            },
          },
        }),
      );
      final DioSyncTransport transport = DioSyncTransport(dio: _dio(adapter));

      final PushResponse response = await transport.push(
        pushWith(
          events: <Map<String, Object?>>[
            <String, Object?>{'client_event_id': 'e-1'},
          ],
        ),
        timeout: const Duration(seconds: 30),
      );

      final ClockVerdict verdict = response.clock!;
      expect(verdict.source, EventTimeSource.eldRtc);
      expect(verdict.clockSkewSec, 130);
      expect(verdict.level, ClockSkewLevel.warning);
    });

    test('429 → RATE_LIMITED va Retry-After', () async {
      final _FakeAdapter adapter = _FakeAdapter(
        (RequestOptions options) async => _json(
          <String, Object?>{
            'error': <String, Object?>{'code': 'RATE_LIMITED', 'message': 'slow down'},
          },
          status: 429,
          headers: <String, List<String>>{
            'retry-after': <String>['42'],
          },
        ),
      );
      final DioSyncTransport transport = DioSyncTransport(dio: _dio(adapter));

      await expectLater(
        transport.push(
          pushWith(
            events: <Map<String, Object?>>[
              <String, Object?>{'client_event_id': 'e-1'},
            ],
          ),
          timeout: const Duration(seconds: 30),
        ),
        throwsA(
          isA<SyncTransportException>()
              .having((SyncTransportException e) => e.code, 'code', 'RATE_LIMITED')
              .having(
                (SyncTransportException e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 42),
              ),
        ),
      );
    });

    test('413 → isPayloadTooLarge (engine batchni bo\'ladi)', () async {
      final _FakeAdapter adapter = _FakeAdapter(
        (RequestOptions options) async => _json(const <String, Object?>{}, status: 413),
      );
      final DioSyncTransport transport = DioSyncTransport(dio: _dio(adapter));

      await expectLater(
        transport.push(
          pushWith(
            events: <Map<String, Object?>>[
              <String, Object?>{'client_event_id': 'e-1'},
            ],
          ),
          timeout: const Duration(seconds: 30),
        ),
        throwsA(
          isA<SyncTransportException>().having(
            (SyncTransportException e) => e.isPayloadTooLarge,
            'isPayloadTooLarge',
            isTrue,
          ),
        ),
      );
    });

    test('409 → isIdempotencyConflict (engine yangi kalit oladi)', () async {
      final _FakeAdapter adapter = _FakeAdapter(
        (RequestOptions options) async => _json(<String, Object?>{
          'error': <String, Object?>{'code': 'IDEMPOTENCY_CONFLICT', 'message': 'conflict'},
        }, status: 409),
      );
      final DioSyncTransport transport = DioSyncTransport(dio: _dio(adapter));

      await expectLater(
        transport.push(
          pushWith(
            events: <Map<String, Object?>>[
              <String, Object?>{'client_event_id': 'e-1'},
            ],
          ),
          timeout: const Duration(seconds: 30),
        ),
        throwsA(
          isA<SyncTransportException>().having(
            (SyncTransportException e) => e.isIdempotencyConflict,
            'isIdempotencyConflict',
            isTrue,
          ),
        ),
      );
    });
  });

  group('pull', () {
    Future<PullResponse> pullWith(
      Map<String, Object?> data, {
      String? since,
      List<RequestOptions>? seen,
    }) async {
      final _FakeAdapter adapter = _FakeAdapter((RequestOptions options) async {
        if (options.path == '/violations') {
          return _json(<String, Object?>{'data': <Object?>[]});
        }
        if (options.path.startsWith('/daily-logs/')) {
          return _json(<String, Object?>{
            'data': <String, Object?>{
              'driver_id': 'driver-1',
              'form': <String, Object?>{
                'driver_name': 'Ali Karimov',
                'carrier_name': 'Onebook LLC',
                'home_terminal_address': '12 Main St',
                'units': <Object?>[
                  <String, Object?>{
                    'id': 'unit-1',
                    'unit_number': '1021',
                    'license_plate': 'ABC-123',
                  },
                ],
              },
            },
          });
        }
        return _json(<String, Object?>{'data': data});
      });
      final DioSyncTransport transport = DioSyncTransport(dio: _dio(adapter));
      final PullResponse response = await transport.pull(
        since: since,
        timeout: const Duration(seconds: 30),
      );
      seen?.addAll(adapter.requests);
      return response;
    }

    test('kursor va truncated o\'qiladi (drenaj sikli)', () async {
      final PullResponse response = await pullWith(<String, Object?>{
        'server_time': '2026-09-07T12:00:05Z',
        'next_since': '2026-09-07T11:59:00Z',
        'truncated': true,
      });

      expect(response.nextSince, '2026-09-07T11:59:00Z');
      expect(response.truncated, isTrue);
    });

    test('#B-BUG2: `/violations` ruxsat etilgan `per_page` va RFC3339 `from` bilan', () async {
      final List<RequestOptions> seen = <RequestOptions>[];
      await pullWith(
        <String, Object?>{
          'server_time': '2026-09-07T12:00:05Z',
          'next_since': '2026-09-07T11:59:00Z',
        },
        since: '2026-09-07T11:00:00Z',
        seen: seen,
      );

      final RequestOptions violations = seen.firstWhere(
        (RequestOptions o) => o.path == '/violations',
      );
      // `httpx.AllowedPerPage` = 10/25/50 — 200 `422 VALIDATION_ERROR` berardi.
      expect(violations.queryParameters['per_page'], anyOf(10, 25, 50));
      expect(
        DateTime.tryParse(violations.queryParameters['from']! as String),
        DateTime.utc(2026, 9, 7, 11),
      );
    });

    test('#B-BUG2: RFC3339 bo\'lmagan kursor `from` sifatida yuborilmaydi', () async {
      final List<RequestOptions> seen = <RequestOptions>[];
      await pullWith(
        <String, Object?>{'server_time': '2026-09-07T12:00:05Z', 'next_since': 'opaque-cursor'},
        since: 'opaque-cursor',
        seen: seen,
      );

      final RequestOptions violations = seen.firstWhere(
        (RequestOptions o) => o.path == '/violations',
      );
      expect(violations.queryParameters.containsKey('from'), isFalse);
    });

    test('quick_notes satrlar massivi map ga o\'giriladi', () async {
      final PullResponse response = await pullWith(<String, Object?>{
        'server_time': '2026-09-07T12:00:05Z',
        'next_since': 'c1',
        'quick_notes': <Object?>['Pickup', 'Delivery', ''],
      });

      expect(response.quickNotes.length, 2);
      expect(response.quickNotes.first['text'], 'Pickup');
    });

    test('hos_policy yassi obyektdan hujjatga yig\'iladi (warning_thresholds)', () async {
      final PullResponse response = await pullWith(<String, Object?>{
        'server_time': '2026-09-07T12:00:05Z',
        'next_since': 'c1',
        'hos_policy': <String, Object?>{
          'version_id': 'v-1',
          'effective_from': '2026-01-01T00:00:00Z',
          'drive_limit_min': 660,
          'warn_drive_min': 30,
          'warn_shift_min': 60,
        },
      });

      final Map<String, Object?> policy = response.hosPolicy!;
      expect(policy['version_id'], 'v-1');
      final Map<String, Object?> document = policy['document']! as Map<String, Object?>;
      expect(document['drive_limit_min'], 660);
      expect(document['warning_thresholds'], <String, Object?>{'drive': 30, 'shift': 60});
    });

    test('defect_types kontrakt maydonlaridan mapping qilinadi', () async {
      final PullResponse response = await pullWith(<String, Object?>{
        'server_time': '2026-09-07T12:00:05Z',
        'next_since': 'c1',
        'defect_types': <Object?>[
          <String, Object?>{
            'id': 'd-1',
            'name': 'Brakes',
            'category': 'trailer',
            'is_critical': true,
          },
        ],
      });

      final Map<String, Object?> defect = response.defectTypes.single;
      expect(defect['label'], 'Brakes');
      expect(defect['applies_to'], 'trailer');
      expect(defect['is_critical'], isTrue);
    });

    test('daily_logs bo\'lsa sessiya profili log formasidan yig\'iladi', () async {
      final List<RequestOptions> seen = <RequestOptions>[];
      final PullResponse response = await pullWith(<String, Object?>{
        'server_time': '2026-09-07T12:00:05Z',
        'next_since': 'c1',
        'daily_logs': <Object?>[
          <String, Object?>{'id': 'log-1', 'log_date': '2026-09-07', 'timezone': 'America/Chicago'},
        ],
      }, seen: seen);

      final Map<String, Object?> profile = response.sessionProfile!;
      expect(profile['driver_id'], 'driver-1');
      expect(profile['carrier_name'], 'Onebook LLC');
      expect(profile['home_terminal_address'], '12 Main St');
      expect(profile['unit_number'], '1021');
      expect(profile['vehicle_label'], 'ABC-123');
      expect(profile['home_terminal_tz'], 'America/Chicago');
      expect(seen.map((RequestOptions o) => o.path), contains('/daily-logs/log-1'));
    });

    test('daily_logs bo\'sh bo\'lsa qo\'shimcha so\'rov qilinmaydi', () async {
      final List<RequestOptions> seen = <RequestOptions>[];
      final PullResponse response = await pullWith(<String, Object?>{
        'server_time': '2026-09-07T12:00:05Z',
        'next_since': 'c1',
      }, seen: seen);

      expect(response.sessionProfile, isNull);
      expect(seen.map((RequestOptions o) => o.path), isNot(contains('/daily-logs/log-1')));
    });
  });
}
