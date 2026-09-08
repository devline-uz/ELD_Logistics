@Timeout(Duration(seconds: 60))
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eld_mobile/core/files/file_upload.dart';
import 'package:eld_mobile/core/sync/sync_side_channel.dart';
import 'package:eld_mobile/core/sync/sync_transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

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

ResponseBody _json(Object body, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: <String, List<String>>{
    Headers.contentTypeHeader: <String>[Headers.jsonContentType],
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

SyncSideChannel _channel(_FakeAdapter adapter) {
  final Dio dio = _dio(adapter);
  return SyncSideChannel(
    dio: dio,
    uploader: FileUploader(
      api: FilesApi(dio: dio, uploadDio: dio),
      now: () => DateTime.utc(2026, 9, 7, 12),
    ),
  );
}

OtherPushItem _item(OutboxKind kind, Map<String, Object?> payload) =>
    OtherPushItem(kind: kind, clientId: 'client-1', payload: payload);

void main() {
  test('claim → POST /unidentified-events/{id}/claim, tanada driver_id yo\'q (M164)', () async {
    final _FakeAdapter adapter = _FakeAdapter(
      (RequestOptions options) async => _json(const <String, Object?>{}),
    );

    final List<PushItemResult> results = await _channel(adapter).send(<OtherPushItem>[
      _item(OutboxKind.claim, <String, Object?>{'event_id': 'ue-1', 'driver_id': 'd-1'}),
    ]);

    expect(results.single.result, 'accepted');
    expect(adapter.requests.single.path, '/unidentified-events/ue-1/claim');
    expect(adapter.requests.single.headers['Idempotency-Key'], 'client-1');
    expect(adapter.requests.single.data, isEmpty);
  });

  test('certify → imzo presign+upload, keyin signature_key bilan certify', () async {
    final Directory dir = Directory.systemTemp.createTempSync('eld-sig');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File signature = File('${dir.path}/sig.png')..writeAsBytesSync(<int>[1, 2, 3]);

    final _FakeAdapter adapter = _FakeAdapter((RequestOptions options) async {
      if (options.path == '/files/presign') {
        return _json(<String, Object?>{
          'data': <String, Object?>{
            'key': 'companies/6f1a/signatures/2026/09/sig.png',
            // S-H2: `upload_url` oq ro'yxatdan o'tishi shart (`*.stackyard.uz`).
            'upload_url': 'https://storage.stackyard.uz/put',
            'method': 'PUT',
            'max_bytes': 1048576,
          },
        });
      }
      return _json(const <String, Object?>{});
    });

    final List<PushItemResult> results = await _channel(adapter).send(<OtherPushItem>[
      _item(OutboxKind.certify, <String, Object?>{
        'log_date': '2026-09-07',
        'daily_log_id': 'log-1',
        'signature_local_path': signature.path,
        'device_id': 'pixel-8',
      }),
    ]);

    expect(results.single.result, 'accepted');
    final List<String> paths = adapter.requests.map((RequestOptions o) => o.path).toList();
    expect(paths, <String>[
      '/files/presign',
      'https://storage.stackyard.uz/put',
      '/daily-logs/log-1/certify',
    ]);

    final Map<String, Object?> body = adapter.requests.last.data! as Map<String, Object?>;
    expect(body['signature_key'], 'companies/6f1a/signatures/2026/09/sig.png');
    expect(body['device_id'], 'pixel-8');
    expect(body.containsKey('signature_local_path'), isFalse);
  });

  test('certify: daily_log_id hali sinxronlanmagan — qayta urinish (rejected emas)', () async {
    final _FakeAdapter adapter = _FakeAdapter(
      (RequestOptions options) async => _json(const <String, Object?>{}),
    );

    await expectLater(
      _channel(adapter).send(<OtherPushItem>[
        _item(OutboxKind.certify, <String, Object?>{'log_date': '2026-09-07'}),
      ]),
      throwsA(isA<SyncTransportException>()),
    );
    expect(adapter.requests, isEmpty);
  });

  test('422 → rejected(invalid_payload), navbat bloklanmaydi', () async {
    final _FakeAdapter adapter = _FakeAdapter(
      (RequestOptions options) async => _json(<String, Object?>{
        'error': <String, Object?>{'code': 'VALIDATION_ERROR', 'message': 'bad'},
      }, status: 422),
    );

    final List<PushItemResult> results = await _channel(adapter).send(<OtherPushItem>[
      _item(OutboxKind.feedback, <String, Object?>{'text': 'hi'}),
    ]);

    expect(results.single.result, 'rejected');
    expect(results.single.reason, 'invalid_payload');
  });

  test('409 → duplicate (xato emas)', () async {
    final _FakeAdapter adapter = _FakeAdapter(
      (RequestOptions options) async => _json(<String, Object?>{
        'error': <String, Object?>{'code': 'IDEMPOTENCY_CONFLICT', 'message': 'dup'},
      }, status: 409),
    );

    final List<PushItemResult> results = await _channel(adapter).send(<OtherPushItem>[
      _item(OutboxKind.logEdit, <String, Object?>{'daily_log_id': 'log-1'}),
    ]);

    expect(results.single.result, 'duplicate');
  });

  test('5xx → SyncTransportException (element pending ga qaytadi)', () async {
    final _FakeAdapter adapter = _FakeAdapter(
      (RequestOptions options) async => _json(const <String, Object?>{}, status: 503),
    );

    await expectLater(
      _channel(adapter).send(<OtherPushItem>[
        _item(OutboxKind.feedback, <String, Object?>{'text': 'hi'}),
      ]),
      throwsA(isA<SyncTransportException>()),
    );
  });

  test('support: ticket_id bo\'lsa xabar endpoint\'iga ketadi', () async {
    final _FakeAdapter adapter = _FakeAdapter(
      (RequestOptions options) async => _json(const <String, Object?>{}),
    );

    await _channel(adapter).send(<OtherPushItem>[
      _item(OutboxKind.support, <String, Object?>{'ticket_id': 't-1', 'text': 'help'}),
    ]);

    expect(adapter.requests.single.path, '/support-tickets/t-1/messages');
    expect(
      (adapter.requests.single.data! as Map<String, Object?>).containsKey('ticket_id'),
      isFalse,
    );
  });
}
