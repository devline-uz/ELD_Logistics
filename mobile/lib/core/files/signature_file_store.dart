/// Imzo PNG ini lokal saqlab `files_queue` ga qo'yuvchi **yagona** joy (#B-33).
///
/// Ilgari bir xil kod ikki nusxada edi: `certify/.../DriftSignatureStore` va
/// `dvir/.../DriftDvirFileRepository.enqueueSignature` — ikkalasi ham
/// `<docs>/signatures/<uuid>.png` yozib, `kind='signature'` bilan navbatga
/// qo'yardi. Endi ikkalasi ham shu sinfga delegatsiya qiladi.
///
/// Navbatni `files_queue` ishchisi tutadi: presign → `PUT` → `signature_key`
/// ([FileUploader], §16 · M149). Fayl **hech qachon** to'g'ridan-to'g'ri
/// domen so'roviga qo'yilmaydi.
library;

import 'dart:io';

import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/daos/dvir_dao.dart';
import '../time/time_source.dart';
import 'app_file_directories.dart';
import 'file_upload.dart';

/// `files_queue.kind` — `POST /files/presign` oq ro'yxatidan (§16).
final String kSignatureFileKind = FileKind.signature.wire;

/// Imzo PNG ining `Content-Type` i.
final String kSignatureContentType = FileKind.signature.defaultContentType;

class SignatureFileStore {
  /// [baseDirectory] berilmasa (yoki eski standart `documents` berilsa) —
  /// `app_support` (S-M2). Normalizatsiya [resolveFileBaseDirectory] da.
  SignatureFileStore({
    required DvirDao files,
    required TimeSource time,
    Future<Directory> Function()? baseDirectory,
    Uuid uuid = const Uuid(),
  }) : this._(files, time, resolveFileBaseDirectory(baseDirectory), uuid);

  const SignatureFileStore._(this._files, this._time, this._baseDirectory, this._uuid);

  final DvirDao _files;
  final TimeSource _time;
  final Uuid _uuid;
  final Future<Directory> Function() _baseDirectory;

  /// PNG ni `<app_support>/signatures/<uuid>.png` ga yozadi va navbatga qo'yadi.
  /// Qaytadigan qiymat — **lokal yo'l** (server kaliti yuklashdan keyin keladi).
  Future<String> enqueue(List<int> pngBytes) async {
    final Directory base = await _baseDirectory();
    final Directory dir = Directory('${base.path}/signatures');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    final File target = File('${dir.path}/${_uuid.v4()}.png');
    await target.writeAsBytes(pngBytes, flush: true);

    await _files.enqueueFile(
      FilesQueueCompanion.insert(
        localPath: target.path,
        kind: kSignatureFileKind,
        contentType: kSignatureContentType,
        sizeBytes: pngBytes.length,
        createdAt: _time.now(),
      ),
    );
    return target.path;
  }
}
