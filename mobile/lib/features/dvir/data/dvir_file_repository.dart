/// DVIR fotolari va imzosi: siqish, **EXIF GPS tozalash (M147)** va
/// `files_queue` ga navbatga qo'yish (§16, M149).
///
/// Foto **hech qachon** to'g'ridan-to'g'ri yuborilmaydi: avval lokal papkaga
/// tozalangan nusxa yoziladi, so'ng `files_queue` uni presign+upload qiladi.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/dvir_dao.dart';
import '../../../core/files/app_file_directories.dart';
import '../../../core/files/signature_file_store.dart';
import '../../../core/time/time_source.dart';
import '../domain/dvir_repository.dart';
import '../domain/exif_gps_scrubber.dart';

/// `files_queue.kind` qiymatlari (§16). Imzo turi `core/files` dan keladi —
/// certify va DVIR bitta manbadan foydalanadi (#B-33).
const String kFileKindDvirPhoto = 'dvir_photo';
final String kFileKindSignature = kSignatureFileKind;

/// Bitta fotoning ruxsat etilgan maksimal hajmi (§16 — 5 MB).
const int kMaxPhotoBytes = 5 * 1024 * 1024;

/// Kamera/galereya adapteri. `image_picker` pubspec'da yo'q, shuning uchun
/// interfeys shu yerda, implementatsiya bootstrap'da ulanadi.
///
/// TODO(pubspec): `image_picker` qo'shilgandan keyin haqiqiy adapter ulanadi.
abstract interface class PhotoPicker {
  Future<String?> pick({required bool fromCamera});
}

/// M147: fotoning uzun tomoni (px).
const int kPhotoMaxDimension = 1600;

/// M147: JPEG sifati.
const int kPhotoJpegQuality = 80;

/// M147 siqish adapteri: uzun tomoni <= [kPhotoMaxDimension], JPEG sifati
/// [kPhotoJpegQuality], **`Isolate` da** (UI bloklanmaydi).
///
/// Implementatsiya `image`/`flutter_image_compress` paketini talab qiladi —
/// ular `pubspec.yaml` da yo'q (pubspec taqiqlangan papkada), shuning uchun
/// hozircha faqat interfeys va o'tkazib yuboruvchi standart mavjud.
///
/// Kontrakt (haqiqiy implementatsiya uchun majburiy):
///  * `Orientation` piksellarga «yopishtiriladi» (rasm to'g'ri buriladi);
///  * chiqishda EXIF **umuman qolmaydi** (baribir [stripExifGps] qayta
///    tekshiradi — mudofaa qatlami);
///  * chaqiruv `compute`/`Isolate.run` ichida bajariladi.
///
/// TODO(pubspec): `image_picker` + `flutter_image_compress` qo'shilgandan
/// keyin `IsolatePhotoCompressor` yoziladi va bootstrap'da ulanadi.
abstract interface class PhotoCompressor {
  Future<Uint8List> compress(
    Uint8List bytes, {
    int maxDimension = kPhotoMaxDimension,
    int quality = kPhotoJpegQuality,
  });
}

/// Siqish paketi ulanmaguncha ishlaydigan standart: baytlar o'zgarmaydi.
/// Hajm cheklovi (§16 — 5 MB) baribir tekshiriladi.
class PassthroughPhotoCompressor implements PhotoCompressor {
  const PassthroughPhotoCompressor();

  @override
  Future<Uint8List> compress(
    Uint8List bytes, {
    int maxDimension = kPhotoMaxDimension,
    int quality = kPhotoJpegQuality,
  }) async => bytes;
}

class DriftDvirFileRepository implements DvirFileRepository {
  DriftDvirFileRepository({
    required this._dao,
    required this._time,
    this._picker,
    Future<Directory> Function()? baseDirectory,
    this._compressor = const PassthroughPhotoCompressor(),
    this._uuid = const Uuid(),
  }) : // S-M2: PII fayllari `app_support` da (iCloud zaxirasidan tashqarida).
       _baseDirectory = resolveFileBaseDirectory(baseDirectory),
       _signatures = SignatureFileStore(
         files: _dao,
         time: _time,
         baseDirectory: baseDirectory,
         uuid: _uuid,
       );

  final DvirDao _dao;
  final TimeSource _time;
  final PhotoPicker? _picker;

  /// M147 siqish (hozircha o'tkazib yuboruvchi standart).
  final PhotoCompressor _compressor;
  final Future<Directory> Function() _baseDirectory;
  final Uuid _uuid;

  /// #B-33: imzo yozish/navbatga qo'yish `core/files` da (certify bilan bitta).
  final SignatureFileStore _signatures;

  @override
  bool get isPhotoCaptureAvailable => _picker != null;

  @override
  Future<String?> capturePhoto({required bool fromCamera}) async =>
      _picker?.pick(fromCamera: fromCamera);

  @override
  Future<String> enqueuePhoto(String sourcePath) async {
    final Uint8List raw = await File(sourcePath).readAsBytes();

    // M147: avval siqish (Isolate), keyin EXIF tozalash — siqish adapteri
    // qanday bo'lishidan qat'i nazar GPS chiqmasligi kafolatlanadi.
    final Uint8List compressed = await _compressor.compress(raw);

    // M147: GPS (va XMP) bloklari olib tashlanadi, `Orientation` saqlanadi.
    final ExifScrubResult scrubbed = stripExifGps(compressed);
    if (scrubbed.bytes.length > kMaxPhotoBytes) {
      throw const PhotoTooLargeException(kMaxPhotoBytes);
    }

    final Directory dir = await _subdirectory('dvir_photos');
    final File target = File('${dir.path}/${_uuid.v4()}.jpg');
    await target.writeAsBytes(scrubbed.bytes, flush: true);

    await _enqueue(
      path: target.path,
      kind: kFileKindDvirPhoto,
      contentType: 'image/jpeg',
      sizeBytes: scrubbed.bytes.length,
    );
    return target.path;
  }

  @override
  Future<String> enqueueSignature(List<int> pngBytes) => _signatures.enqueue(pngBytes);

  Future<Directory> _subdirectory(String name) async {
    final Directory base = await _baseDirectory();
    final Directory dir = Directory('${base.path}/$name');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _enqueue({
    required String path,
    required String kind,
    required String contentType,
    required int sizeBytes,
  }) => _dao.enqueueFile(
    FilesQueueCompanion.insert(
      localPath: path,
      kind: kind,
      contentType: contentType,
      sizeBytes: sizeBytes,
      createdAt: _time.now(),
      state: const Value<String>('pending'),
    ),
  );
}

/// Foto hajmi §16 chegarasidan katta.
class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException(this.maxBytes);

  final int maxBytes;

  @override
  String toString() => 'PhotoTooLargeException(max=$maxBytes)';
}
