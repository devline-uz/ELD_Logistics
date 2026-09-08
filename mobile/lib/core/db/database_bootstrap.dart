/// Lokal bazani **shifrlangan** holatda ochish (tz-mobile §17, flutter-drift).
///
/// Ketma-ketlik:
///  1. kalit `SecureVault` dan (birinchi ishga tushishda `Random.secure()` bilan
///     generatsiya qilinadi va Keystore/Keychain ga yoziladi);
///  2. `db.cipher_ready` bayrog'i yo'q bo'lsa — **migratsiya**: mavjud
///     shifrlanmagan fayl `sqlcipher_export()` bilan shifrlangan nusxaga
///     ko'chiriladi (outbox va eventlar yo'qolmaydi — «0 event yo'qotish» NFR);
///  3. baza kalit bilan ochiladi.
///
/// **Migratsiya qarori (M-DB1):** eski fayl **o'chirilmaydi va tashlanmaydi** —
/// `sqlcipher_export` ATTACH orqali to'liq nusxa ko'chiradi, so'ng asl fayl
/// almashtiriladi. Nusxa yiqilsa bayroq yozilmaydi va ilova keyingi ishga
/// tushishda yana urinadi; ma'lumot hech qachon jimgina yo'qolmaydi.
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../security/secure_vault.dart';
import 'app_database.dart';
import 'connection.dart';

/// Migratsiya natijasi — diagnostikada (`M-46`) ko'rsatiladi.
enum CipherMigration {
  /// Baza allaqachon shifrlangan edi.
  alreadyEncrypted,

  /// Fayl yo'q edi — yangi baza darhol shifrlangan holda yaratiladi.
  freshDatabase,

  /// Shifrlanmagan fayl ko'chirildi.
  migrated,

  /// SQLCipher mavjud emas (desktop/test build) — shifrlash qo'llanmadi.
  unavailable,
}

/// Shifrlangan `AppDatabase` ni ochadi.
///
/// [requireCipher] `true` bo'lsa SQLCipher ulanmagan build'da [StateError]
/// tashlanadi (prod/stage uchun fail-closed).
Future<({AppDatabase db, CipherMigration migration})> openEncryptedDatabase({
  required SecureVault vault,
  bool requireCipher = false,
}) async {
  final String key = await vault.databaseKey();
  final CipherMigration migration = await prepareEncryptedFile(vault: vault, key: key);

  if (migration == CipherMigration.unavailable && requireCipher) {
    throw StateError('SQLCipher ulanmagan: lokal baza shifrlanmagan bo\'lardi (tz-mobile §17).');
  }

  final QueryExecutor executor = migration == CipherMigration.unavailable
      ? openAppConnection()
      : openAppConnection(encryptionKey: key, requireCipher: requireCipher);
  return (db: AppDatabase(executor), migration: migration);
}

/// Fayl darajasidagi tayyorgarlik: kerak bo'lsa shifrlanmagan bazani ko'chiradi.
Future<CipherMigration> prepareEncryptedFile({
  required SecureVault vault,
  required String key,
}) async {
  if (await vault.isDatabaseEncrypted()) {
    return CipherMigration.alreadyEncrypted;
  }

  final File file = await databaseFile();
  if (!file.existsSync()) {
    // S-M1: bayroq **faqat** SQLCipher haqiqatan ishlayotgani tasdiqlangandan
    // keyin yoziladi. Ilgari u shu yerda, hech narsa tekshirmasdan yozilardi:
    // cipher-siz build (dev/test/desktop) `db.cipher_ready='1'` qoldirar,
    // keyinchalik migratsiya hech qachon bajarilmas, cipher'li build esa
    // ochiq matnli faylni `SQLITE_NOTADB` bilan rad etardi.
    final CipherMigration fresh = initializeEncryptedFile(file: file, key: key);
    if (fresh == CipherMigration.freshDatabase) {
      await vault.markDatabaseEncrypted();
    }
    return fresh;
  }

  final CipherMigration result = migratePlaintextDatabase(file: file, key: key);
  if (result == CipherMigration.migrated) {
    await vault.markDatabaseEncrypted();
  }
  return result;
}

/// Yangi o'rnatish: faylni kalit bilan yaratib, SQLCipher **haqiqatan**
/// ulanganini tekshiradi (S-M1).
///
/// * [CipherMigration.freshDatabase] — fayl shifrlangan holda yaratildi,
///   `db.cipher_ready` bayrog'ini yozish mumkin;
/// * [CipherMigration.unavailable] — SQLCipher yo'q; **hech qanday fayl
///   qoldirilmaydi** va bayroq yozilmaydi, keyingi ishga tushishda yana
///   urinib ko'riladi (yoki `requireCipher` bilan fail-closed).
CipherMigration initializeEncryptedFile({required File file, required String key}) {
  Database? db;
  try {
    db = sqlite3.open(file.path);
    db.execute("PRAGMA key = '${escapeCipherKey(key)}'");
    if (!isCipherActive(db)) {
      return CipherMigration.unavailable;
    }
    // Sahifalarni yozdirish: shundan keyingina fayl sarlavhasi shifrlangan
    // bo'ladi (SQLite faylni birinchi yozuvgacha yaratmaydi).
    db
      ..execute('CREATE TABLE IF NOT EXISTS _cipher_probe (id INTEGER PRIMARY KEY)')
      ..execute('DROP TABLE _cipher_probe');
    return CipherMigration.freshDatabase;
  } on SqliteException {
    return CipherMigration.unavailable;
  } finally {
    db?.close();
  }
}

/// `sqlcipher_export()` bilan shifrlanmagan bazani shifrlangan nusxaga ko'chiradi.
///
/// Sinxron: `sqlite3` FFI chaqiruvlari bloklovchi, ammo bu **faqat bir marta**,
/// ilova ishga tushishida bajariladi.
CipherMigration migratePlaintextDatabase({required File file, required String key}) {
  // SQLCipher build hook orqali ulangan — kutubxona override'i kerak emas.

  final String target = '${file.path}$kDatabaseMigrationSuffix';
  final File targetFile = File(target);
  if (targetFile.existsSync()) {
    targetFile.deleteSync();
  }

  Database? source;
  try {
    source = sqlite3.open(file.path);
    if (!isCipherActive(source)) {
      // SQLCipher yo'q — `PRAGMA key` jimgina e'tiborsiz qolardi.
      return CipherMigration.unavailable;
    }
    final String escapedPath = target.replaceAll("'", "''");
    source
      ..execute("ATTACH DATABASE '$escapedPath' AS encrypted KEY '${escapeCipherKey(key)}'")
      ..execute("SELECT sqlcipher_export('encrypted')")
      ..execute('DETACH DATABASE encrypted');
  } on SqliteException {
    if (targetFile.existsSync()) {
      targetFile.deleteSync();
    }
    return CipherMigration.unavailable;
  } finally {
    source?.close();
  }

  // Almashtirish: asl faylni **ustiga yozib** o'chiramiz, so'ng shifrlangan
  // nusxani uning o'rniga qo'yamiz.
  shredFile(file);
  targetFile.renameSync(file.path);
  _deleteSidecars(file);
  return CipherMigration.migrated;
}

/// WAL/SHM yordamchi fayllari eski (shifrlanmagan) sahifalarni saqlab qolishi
/// mumkin — ular ham ustiga yozilib o'chiriladi.
void _deleteSidecars(File file) {
  for (final String suffix in const <String>['-wal', '-shm', '-journal']) {
    final File sidecar = File('${file.path}$suffix');
    if (sidecar.existsSync()) {
      shredFile(sidecar);
    }
  }
}

/// S-L1: ochiq matnli baza faylini o'chirishdan oldin **ustiga yozadi**.
///
/// `delete` faqat katalog yozuvini olib tashlaydi — sahifalar (PII: eventlar,
/// koordinatalar, chat) fayl tizimida qolib ketadi. Fayl nol baytlar bilan
/// qayta yoziladi (`writeOnly` — truncate + bir xil uzunlikda nol yozish), so'ng
/// o'chiriladi. Wear-leveling/copy-on-write tufayli bu 100% kafolat emas, lekin
/// oddiy tiklash vositalariga jiddiy to'siq. Xatolik yuz bersa ham fayl baribir
/// o'chiriladi.
void shredFile(File file) {
  overwriteWithZeros(file);
  if (file.existsSync()) {
    file.deleteSync();
  }
}

/// Fayl mazmunini nol baytlar bilan almashtiradi (fayl **o'chirilmaydi**).
/// Alohida funksiya — testda tekshirish uchun.
void overwriteWithZeros(File file) {
  try {
    if (!file.existsSync()) {
      return;
    }
    final int length = file.lengthSync();
    if (length > 0) {
      final RandomAccessFile handle = file.openSync(mode: FileMode.writeOnly);
      try {
        const int chunk = 64 * 1024;
        final Uint8List zeros = Uint8List(chunk);
        int written = 0;
        while (written < length) {
          final int size = (length - written) < chunk ? length - written : chunk;
          handle.writeFromSync(zeros, 0, size);
          written += size;
        }
        handle.flushSync();
      } finally {
        handle.closeSync();
      }
    }
  } on FileSystemException {
    // O'chirish baribir bajariladi — migratsiya to'xtamaydi.
  }
}
