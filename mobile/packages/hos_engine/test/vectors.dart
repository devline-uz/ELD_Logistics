// Golden vektor faylini yuklash (M45/M174).
//
// Fayl `packages/hos_engine` ichiga NUSXALANMAYDI: yagona manba
// `backend/internal/hos/testdata/hos-test-vectors.json`. Backend daraxti mavjud
// bo'lsa o'sha fayl to'g'ridan-to'g'ri o'qiladi; CI da backend bo'lmasa
// `tool/sync_vectors.sh` tayyorlagan nusxa ishlatiladi. Har ikkalasida ham
// SHA-256 qulfi tekshiriladi — mos kelmasa test yiqiladi.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Backenddagi kanonik fayl (test cwd = paket ildizi).
const String backendVectorPath = '../../../backend/internal/hos/testdata/hos-test-vectors.json';

/// `tool/sync_vectors.sh` tayyorlagan nusxa.
const String syncedVectorPath = 'test/testdata/hos-test-vectors.json';

/// Kontrakt qulfi (M174).
const String vectorLockPath = 'test/testdata/hos-test-vectors.sha256';

class VectorSource {
  const VectorSource(this.path, this.sha256, this.json);

  final String path;
  final String sha256;
  final Map<String, dynamic> json;

  List<Map<String, dynamic>> get vectors => (json['vectors'] as List)
      .map((e) => (e as Map).cast<String, dynamic>())
      .toList(growable: false);

  int get version => json['version'] as int;
}

/// Vektor faylini o'qiydi va hash qulfini tekshiradi.
VectorSource loadVectors() {
  final backend = File(backendVectorPath);
  final synced = File(syncedVectorPath);
  final file = backend.existsSync() ? backend : synced;
  if (!file.existsSync()) {
    throw StateError('hos-test-vectors.json topilmadi. `tool/sync_vectors.sh` ni ishga tushiring.');
  }
  final bytes = file.readAsBytesSync();
  final digest = sha256.convert(bytes).toString();

  final lock = File(vectorLockPath);
  if (!lock.existsSync()) {
    throw StateError('$vectorLockPath yo\'q — M174 qulfi majburiy.');
  }
  final expected = lock.readAsStringSync().trim();
  if (digest != expected) {
    throw StateError(
      'STOP: hos-test-vectors.json kontrakti o\'zgardi (M174).\n'
      '  fayl:     ${file.path}\n'
      '  kutilgan: $expected\n'
      '  topilgan: $digest\n'
      'Vektor formati Go va Dart uchun umumiy kontrakt — CR kerak.',
    );
  }

  // Ikkala nusxa ham bo'lsa, bir xilligi ham tekshiriladi.
  if (backend.existsSync() && synced.existsSync()) {
    final other = sha256.convert(synced.readAsBytesSync()).toString();
    if (other != digest) {
      throw StateError(
        'test/testdata nusxasi backend fayldan farq qiladi — '
        '`tool/sync_vectors.sh` ni qayta ishga tushiring.',
      );
    }
  }

  final decoded = (jsonDecode(utf8.decode(bytes)) as Map).cast<String, dynamic>();
  return VectorSource(file.path, digest, decoded);
}
