/// Ilova fayllarining **yagona** ildizi (S-M2, tz-mobile §17.1).
///
/// Imzo PNG lari va DVIR fotolari — PII. Ular `getApplicationSupportDirectory()`
/// da yotishi shart:
///  * iOS: `Library/Application Support` — iCloud/iTunes zaxirasiga **tushmaydi**
///    (`getApplicationDocumentsDirectory` esa tushadi — bu S-M2 nuqsoni edi);
///  * Android: `files/` ichidagi ilova katalogi, tashqi xotira emas.
///
/// Lokal baza ham shu ildizda (`core/db/connection.dart`), ya'ni butun PII
/// bitta zaxiralanmaydigan katalogda.
library;

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../db/daos/dvir_dao.dart';

/// Imzo/foto/pending fayllar uchun ildiz katalog.
Future<Directory> appFileBaseDirectory() => getApplicationSupportDirectory();

/// Eski (noto'g'ri) ildiz — faqat migratsiya uchun.
Future<Directory> legacyFileBaseDirectory() => getApplicationDocumentsDirectory();

/// Chaqiruvchi bergan ildizni normallashtiradi.
///
/// `null` yoki **eski standart** (`getApplicationDocumentsDirectory`) berilsa —
/// [appFileBaseDirectory]. Shu tufayli S-M2 tuzatmasi bitta markaziy joyda
/// qoladi: chaqiruvchi modullar (certify, dvir) eski standartni uzatsa ham
/// fayl `app_support` ga tushadi. Testlar o'z vaqtinchalik katalogini beradi va
/// u o'zgarishsiz qaytariladi.
Future<Directory> Function() resolveFileBaseDirectory(Future<Directory> Function()? injected) =>
    injected == null || injected == getApplicationDocumentsDirectory
    ? appFileBaseDirectory
    : injected;

/// Eski katalogdagi fayllarni yangi ildizga ko'chiradi va `files_queue` dagi
/// yo'llarni yangilaydi. Ko'chirilgan fayllar sonini qaytaradi.
///
/// Idempotent: qayta chaqirilsa hech narsa qilmaydi (katalog yo'q bo'ladi).
/// Xatolar yutiladi — migratsiya ishga tushishni **hech qachon** bloklamaydi;
/// ko'chirilmagan fayl eski yo'lida qolaveradi va navbat baribir ishlaydi.
Future<int> migrateLegacyFileDirectories({
  required DvirDao dao,
  Future<Directory> Function()? legacyBase,
  Future<Directory> Function()? base,
  List<String> subdirectories = const <String>['signatures', 'dvir_photos'],
}) async {
  int moved = 0;
  try {
    final Directory from = await (legacyBase ?? legacyFileBaseDirectory)();
    final Directory to = await (base ?? appFileBaseDirectory)();
    if (from.path == to.path) {
      return 0;
    }
    for (final String name in subdirectories) {
      final Directory source = Directory('${from.path}/$name');
      if (!source.existsSync()) {
        continue;
      }
      final Directory target = Directory('${to.path}/$name');
      if (!target.existsSync()) {
        await target.create(recursive: true);
      }
      for (final FileSystemEntity entity in source.listSync()) {
        if (entity is! File) {
          continue;
        }
        final String fileName = entity.uri.pathSegments.last;
        final String destination = '${target.path}/$fileName';
        if (File(destination).existsSync()) {
          continue;
        }
        await entity.rename(destination);
        await dao.relocateFile(from: entity.path, to: destination);
        moved++;
      }
      if (source.listSync().isEmpty) {
        await source.delete();
      }
    }
  } on FileSystemException {
    return moved;
  }
  return moved;
}
