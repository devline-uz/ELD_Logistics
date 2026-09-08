/// Fayl yuklash oqimi (tz-mobile §16, M148–M150).
///
/// `POST /files/presign` → `PUT <upload_url>` (bevosita object storage'ga,
/// qaytgan `headers` bilan) → domen so'roviga **faqat `key`** ketadi.
///
/// * `upload_url` **hech qachon** log qilinmaydi (imzo parametrlari sir, M149);
/// * `expires_at` o'tgan bo'lsa qayta presign qilinadi;
/// * server `max_bytes` va `413 FILE_TOO_LARGE` kanonik (M148).
library;

import 'dart:io';

import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/request_options_x.dart';
import 'upload_url_policy.dart';

/// `POST /files/presign` `kind` oq ro'yxati (§16). `invoice`/`logo`/`import`
/// mobil ilovada ishlatilmaydi.
enum FileKind {
  dvirPhoto('dvir_photo', 'image/jpeg'),
  signature('signature', 'image/png'),
  chat('chat', 'application/octet-stream');

  const FileKind(this.wire, this.defaultContentType);

  final String wire;
  final String defaultContentType;
}

/// `POST /files/presign` javobi.
class PresignResult {
  const PresignResult({
    required this.key,
    required this.uploadUrl,
    this.method = 'PUT',
    this.headers = const <String, String>{},
    this.expiresAt,
    this.maxBytes,
  });

  factory PresignResult.fromJson(Map<String, Object?> json) => PresignResult(
    key: json['key']?.toString() ?? '',
    uploadUrl: json['upload_url']?.toString() ?? '',
    method: json['method']?.toString() ?? 'PUT',
    headers: <String, String>{
      if (json['headers'] case final Map<Object?, Object?> raw)
        for (final MapEntry<Object?, Object?> e in raw.entries)
          e.key.toString(): e.value?.toString() ?? '',
    },
    expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? '')?.toUtc(),
    maxBytes: json['max_bytes'] is num ? (json['max_bytes']! as num).toInt() : null,
  );

  final String key;
  final String uploadUrl;
  final String method;
  final Map<String, String> headers;
  final DateTime? expiresAt;
  final int? maxBytes;

  bool get isUsable => key.isNotEmpty && uploadUrl.isNotEmpty;

  /// M149: muddati o'tgan URL bilan yuklanmaydi — qayta presign qilinadi.
  bool isExpired(DateTime now) => expiresAt != null && !expiresAt!.isAfter(now);

  /// Log/Sentry uchun — `upload_url` **chiqmaydi**.
  @override
  String toString() => 'PresignResult(key: $key)';
}

/// `/files/presign` va bevosita object-storage `PUT`.
class FilesApi {
  const FilesApi({required Dio dio, Dio? uploadDio, UploadUrlPolicy? uploadUrlPolicy})
    : this._(dio, uploadDio, uploadUrlPolicy);

  const FilesApi._(this._dio, this._uploadDio, this._uploadUrlPolicy);

  final Dio _dio;

  /// Yuklash **interceptorlarsiz** ketadi: presigned URL o'z imzosiga ega,
  /// `Authorization` qo'shilsa S3 imzoni rad etadi. Aynan shuning uchun
  /// manzilning o'zi [UploadUrlPolicy] bilan tekshiriladi (S-H2).
  final Dio? _uploadDio;

  /// `null` — [UploadUrlPolicy.standard] (muhit hosti + `*.stackyard.uz`).
  final UploadUrlPolicy? _uploadUrlPolicy;

  Future<PresignResult> presign({
    required FileKind kind,
    required int sizeBytes,
    String? contentType,
    String? filename,
  }) => guardApiCall(() async {
    final Response<Map<String, Object?>> response = await _dio.post<Map<String, Object?>>(
      '/files/presign',
      data: <String, Object?>{
        'kind': kind.wire,
        'content_type': contentType ?? kind.defaultContentType,
        'size_bytes': sizeBytes,
        if (filename != null && filename.isNotEmpty) 'filename': filename,
      },
      options: Options(extra: <String, Object?>{RequestExtra.idempotent: true}),
    );
    final Object? data = response.data?['data'] ?? response.data;
    return PresignResult.fromJson(data is Map<String, Object?> ? data : const <String, Object?>{});
  });

  /// Faylni bevosita object storage'ga yuklaydi.
  ///
  /// S-H2: manzil avval oq ro'yxatdan o'tkaziladi ([validateUploadUrl]) —
  /// tekshiruvdan o'tmasa [UntrustedUploadUrlException] otiladi va **hech
  /// qanday bayt yuborilmaydi**. Redirect ta'qib qilinmaydi: 3xx javob
  /// oq ro'yxatni chetlab o'tishning eng oson yo'li.
  Future<void> upload({required PresignResult presign, required List<int> bytes}) async {
    final Uri target = validateUploadUrl(presign.uploadUrl, policy: _uploadUrlPolicy);
    return guardApiCall(() async {
      final Dio dio = _uploadDio ?? Dio();
      await dio.requestUri<void>(
        target,
        data: Stream<List<int>>.value(bytes),
        options: Options(
          method: presign.method,
          headers: <String, Object?>{...presign.headers, Headers.contentLengthHeader: bytes.length},
          // Object storage JSON qaytarmaydi.
          responseType: ResponseType.plain,
          followRedirects: false,
          maxRedirects: 0,
          validateStatus: (int? status) => status != null && status >= 200 && status < 300,
        ),
      );
    });
  }
}

/// Fayl hajmi server chegarasidan oshdi (M148: `413 FILE_TOO_LARGE` kanonik,
/// mijoz oldindan tekshiradi).
class FileTooLargeException implements Exception {
  const FileTooLargeException({required this.sizeBytes, required this.maxBytes});

  final int sizeBytes;
  final int maxBytes;

  @override
  String toString() => 'FileTooLargeException($sizeBytes > $maxBytes)';
}

/// Lokal fayl → `key`. Domen so'rovi **faqat** shu kalitni yuboradi.
class FileUploader {
  const FileUploader({required FilesApi api, required DateTime Function() now}) : this._(api, now);

  const FileUploader._(this._api, this._now);

  final FilesApi _api;
  final DateTime Function() _now;

  /// Faylni presign qilib yuklaydi va serverdagi kalitni qaytaradi.
  ///
  /// Fayl topilmasa `null` — chaqiruvchi elementni rad etadi (`invalid_payload`),
  /// navbat bloklanmaydi.
  Future<String?> uploadPath({
    required String localPath,
    required FileKind kind,
    String? contentType,
  }) async {
    final File file = File(localPath);
    if (!file.existsSync()) {
      return null;
    }
    final List<int> bytes = await file.readAsBytes();
    final PresignResult presign = await _api.presign(
      kind: kind,
      sizeBytes: bytes.length,
      contentType: contentType,
      filename: file.uri.pathSegments.isEmpty ? null : file.uri.pathSegments.last,
    );
    if (!presign.isUsable) {
      return null;
    }
    // M148: server `max_bytes` kanonik — yuklashdan oldin tekshiriladi.
    final int? maxBytes = presign.maxBytes;
    if (maxBytes != null && bytes.length > maxBytes) {
      throw FileTooLargeException(sizeBytes: bytes.length, maxBytes: maxBytes);
    }
    // M149: muddati o'tgan URL bilan yuklanmaydi — qayta presign qilinadi.
    final PresignResult fresh = presign.isExpired(_now())
        ? await _api.presign(
            kind: kind,
            sizeBytes: bytes.length,
            contentType: contentType,
            filename: file.uri.pathSegments.isEmpty ? null : file.uri.pathSegments.last,
          )
        : presign;
    if (!fresh.isUsable) {
      return null;
    }
    await _api.upload(presign: fresh, bytes: bytes);
    return fresh.key;
  }
}
