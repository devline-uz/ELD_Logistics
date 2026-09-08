/// Drift ulanishini ochish: fayl joylashuvi va shifrlash (§5, §17).
library;

import 'dart:io' show File;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';

/// Baza fayli nomi (`<app-support>/eld_local.sqlite`).
///
/// Nom barqaror: o'zgartirilsa eski fayldagi yuborilmagan outbox yo'qoladi.
const String kDatabaseFileName = 'eld_local';

/// `drift_flutter` fayl kengaytmasi.
const String kDatabaseFileExtension = '.sqlite';

/// Migratsiya paytida ishlatiladigan vaqtinchalik shifrlangan nusxa.
const String kDatabaseMigrationSuffix = '.cipher-tmp';

/// Baza faylining to'liq yo'li.
Future<File> databaseFile() async {
  final String dir = (await getApplicationSupportDirectory()).path;
  return File('$dir/$kDatabaseFileName$kDatabaseFileExtension');
}

/// SQLCipher build hook orqali ulanadi (`pubspec.yaml` → `hooks.user_defines.
/// sqlite3.source: sqlcipher`), shuning uchun Dart tomonida kutubxona
/// override'i kerak emas — barcha platformalarda va ishchi izolyatda bir xil
/// `sqlite3` yuklanadi. Bu funksiya faqat kelajakdagi diagnostika uchun
/// qoldirilgan nuqta: shifrlash haqiqatan yoqilganini [isCipherActive]
/// tekshiradi.
/// Ilova uchun ulanish.
///
/// Fayl `getApplicationSupportDirectory()` da saqlanadi (iOS'da iCloud'ga
/// zaxiralanmaydi, Android'da `no_backup` ga yaqin) — PII shu yerda yotadi.
///
/// **SQLCipher (§17):** [encryptionKey] berilsa ochilgandan keyingi **birinchi**
/// statement `PRAGMA key` bo'ladi. [requireCipher] `true` bo'lsa kalitdan keyin
/// `PRAGMA cipher_version` tekshiriladi va SQLCipher ulanmagan build'da
/// [StateError] tashlanadi — «jimgina shifrlanmagan» holat mumkin emas
/// (fail-closed). Kalit Keystore/Keychain da (`core/security/secure_vault.dart`),
/// kodda yoki `SharedPreferences` da **hech qachon** emas.
QueryExecutor openAppConnection({String? encryptionKey, bool requireCipher = false}) {
  final String? key = encryptionKey;
  final bool verify = requireCipher;
  return driftDatabase(
    name: kDatabaseFileName,
    native: DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
      shareAcrossIsolates: true,
      // Yopilgan o'zgaruvchi sifatida faqat `String?`/`bool` uzatiladi —
      // izolyatga yuborilishi mumkin (drift_flutter talabi).
      setup: key == null || key.isEmpty
          ? null
          : (CommonDatabase db) => applyCipherKey(db, key, requireCipher: verify),
    ),
  );
}

/// `PRAGMA key` — SQLCipher kaliti. Ochilgandan keyin birinchi statement
/// bo'lishi shart, aks holda fayl shifrlanmagan holda ochiladi.
void applyCipherKey(CommonDatabase db, String key, {bool requireCipher = false}) {
  db.execute("PRAGMA key = '${escapeCipherKey(key)}'");
  if (requireCipher && !isCipherActive(db)) {
    throw StateError(
      'SQLCipher ulanmagan: PRAGMA key e\'tiborsiz qoldi, lokal baza '
      'shifrlanmagan bo\'lardi (tz-mobile §17).',
    );
  }
}

/// SQL literal ichidagi apostrofni ekranlaydi.
String escapeCipherKey(String key) => key.replaceAll("'", "''");

/// SQLCipher haqiqatan ulanganmi (`PRAGMA cipher_version` bo'sh emasmi).
bool isCipherActive(CommonDatabase db) {
  try {
    final ResultSet rows = db.select('PRAGMA cipher_version');
    if (rows.isEmpty) {
      return false;
    }
    final List<Object?> values = rows.first.values;
    return values.isNotEmpty && (values.first?.toString() ?? '').isNotEmpty;
  } on SqliteException {
    return false;
  }
}

/// Testlar uchun: har chaqiruvda yangi, bo'sh in-memory baza.
QueryExecutor openInMemoryConnection() => NativeDatabase.memory();

/// Bir xil fayl ustida qayta ochish — «ilova o'ldirildi» chaos testi uchun.
QueryExecutor openFileConnection(String path) => NativeDatabase(File(path));
