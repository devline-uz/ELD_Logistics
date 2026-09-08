/// S-H2: presign javobidagi `upload_url` oq ro'yxati.
@Timeout(Duration(seconds: 60))
library;

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/files/file_upload.dart';
import 'package:eld_mobile/core/files/upload_url_policy.dart';
import 'package:flutter_test/flutter_test.dart';

const UploadUrlPolicy _policy = UploadUrlPolicy();

PresignResult _presign(String url) =>
    PresignResult(key: 'dvir/2026/09/a.jpg', uploadUrl: url, headers: const <String, String>{});

void main() {
  group('validateUploadUrl', () {
    test('ruxsat etilgan storage hosti o\'tadi', () {
      final Uri uri = validateUploadUrl(
        'https://storage.stackyard.uz/bucket/a.png?X-Amz-Signature=abc',
        policy: _policy,
      );
      expect(uri.host, 'storage.stackyard.uz');
    });

    test('domenning o\'zi ham o\'tadi', () {
      expect(validateUploadUrl('https://stackyard.uz/a', policy: _policy).host, 'stackyard.uz');
    });

    test('http:// rad etiladi', () {
      expect(
        () => validateUploadUrl('http://storage.stackyard.uz/a', policy: _policy),
        throwsA(
          isA<UntrustedUploadUrlException>().having(
            (UntrustedUploadUrlException e) => e.reason,
            'reason',
            'scheme',
          ),
        ),
      );
    });

    test('boshqa host rad etiladi (eksfiltratsiya)', () {
      expect(
        () => validateUploadUrl('https://evil.example.com/a', policy: _policy),
        throwsA(
          isA<UntrustedUploadUrlException>().having(
            (UntrustedUploadUrlException e) => e.reason,
            'reason',
            'host',
          ),
        ),
      );
    });

    test('oq ro\'yxatdagi domenni suffiks sifatida taqlid qilish rad etiladi', () {
      expect(
        () => validateUploadUrl('https://stackyard.uz.evil.com/a', policy: _policy),
        throwsA(isA<UntrustedUploadUrlException>()),
      );
      expect(
        () => validateUploadUrl('https://notstackyard.uz/a', policy: _policy),
        throwsA(isA<UntrustedUploadUrlException>()),
      );
    });

    test('userinfo bilan host yashirish rad etiladi', () {
      expect(
        () => validateUploadUrl('https://storage.stackyard.uz@evil.com/a', policy: _policy),
        throwsA(isA<UntrustedUploadUrlException>()),
      );
    });

    test('nostandart port rad etiladi', () {
      expect(
        () => validateUploadUrl('https://storage.stackyard.uz:8443/a', policy: _policy),
        throwsA(
          isA<UntrustedUploadUrlException>().having(
            (UntrustedUploadUrlException e) => e.reason,
            'reason',
            'port',
          ),
        ),
      );
    });

    test('nisbiy yoki buzilgan URL rad etiladi', () {
      for (final String raw in <String>['', '/bucket/a.png', 'not a url', 'file:///etc/passwd']) {
        expect(
          () => validateUploadUrl(raw, policy: _policy),
          throwsA(isA<UntrustedUploadUrlException>()),
          reason: raw,
        );
      }
    });

    test('xato matnida imzo parametrlari yo\'q (M149)', () {
      try {
        validateUploadUrl('https://evil.com/a?X-Amz-Signature=secret', policy: _policy);
        fail('kutilgan istisno otilmadi');
      } on UntrustedUploadUrlException catch (e) {
        expect(e.toString(), isNot(contains('X-Amz-Signature')));
        expect(e.toString(), contains('evil.com'));
      }
    });

    test('outbox uchun 400 BAD_REQUEST sifatida ko\'rinadi (jimgina o\'tmaydi)', () {
      try {
        validateUploadUrl('https://evil.com/a', policy: _policy);
        fail('kutilgan istisno otilmadi');
      } on ApiError catch (e) {
        expect(e.statusCode, 400);
        expect(e.isRetryable, isFalse);
      }
    });
  });

  group('FilesApi.upload', () {
    test('ishonchsiz hostga bitta ham bayt yuborilmaydi', () async {
      final Dio dio = Dio();
      final _RecordingAdapter adapter = _RecordingAdapter();
      dio.httpClientAdapter = adapter;

      final FilesApi api = FilesApi(dio: Dio(), uploadDio: dio, uploadUrlPolicy: _policy);

      await expectLater(
        api.upload(presign: _presign('https://evil.example.com/a'), bytes: <int>[1, 2, 3]),
        throwsA(isA<UntrustedUploadUrlException>()),
      );
      expect(adapter.requests, isEmpty);
    });

    test('redirect ta\'qib qilinmaydi (3xx → xato)', () async {
      final Dio dio = Dio();
      final _RecordingAdapter adapter = _RecordingAdapter(status: 302);
      dio.httpClientAdapter = adapter;

      final FilesApi api = FilesApi(dio: Dio(), uploadDio: dio, uploadUrlPolicy: _policy);

      await expectLater(
        api.upload(presign: _presign('https://storage.stackyard.uz/a'), bytes: <int>[1]),
        throwsA(isA<ApiError>()),
      );
      expect(adapter.requests.single.followRedirects, isFalse);
    });

    test('ruxsat etilgan hostga yuboriladi', () async {
      final Dio dio = Dio();
      final _RecordingAdapter adapter = _RecordingAdapter();
      dio.httpClientAdapter = adapter;

      final FilesApi api = FilesApi(dio: Dio(), uploadDio: dio, uploadUrlPolicy: _policy);
      await api.upload(presign: _presign('https://storage.stackyard.uz/a'), bytes: <int>[1, 2]);

      expect(adapter.requests.single.uri.host, 'storage.stackyard.uz');
    });
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.status = 200});

  final int status;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString('', status);
  }

  @override
  void close({bool force = false}) {}
}
