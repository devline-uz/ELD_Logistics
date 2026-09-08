/// S-M1 (`db.cipher_ready` bayrog'i) va S-L1 (ochiq matnli faylni o'chirish).
@Timeout(Duration(seconds: 60))
library;

import 'dart:io';

import 'package:eld_mobile/core/db/connection.dart';
import 'package:eld_mobile/core/db/database_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('db_bootstrap_test');
  });

  tearDown(() {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  bool cipherAvailable() {
    final Database probe = sqlite3.openInMemory();
    try {
      return isCipherActive(probe);
    } finally {
      probe.close();
    }
  }

  group('initializeEncryptedFile (S-M1)', () {
    test('SQLCipher yo\'q build\'da `unavailable` — bayroq yozilmaydi', () {
      if (cipherAvailable()) {
        return; // Cipher'li build: bu holat yuzaga kelmaydi.
      }
      final File file = File('${dir.path}/fresh.sqlite');
      expect(initializeEncryptedFile(file: file, key: 'a' * 64), CipherMigration.unavailable);
    });

    test('cipher\'li build\'da fayl yaratiladi va `freshDatabase` qaytadi', () {
      if (!cipherAvailable()) {
        return;
      }
      final File file = File('${dir.path}/fresh.sqlite');
      expect(initializeEncryptedFile(file: file, key: 'a' * 64), CipherMigration.freshDatabase);
      expect(file.existsSync(), isTrue);
      // Kalitsiz ochilmaydi — fayl haqiqatan shifrlangan.
      expect(() => sqlite3.open(file.path).select('PRAGMA schema_version'), throwsA(anything));
    });
  });

  group('shredFile (S-L1)', () {
    test('mazmun nol baytlar bilan almashtiriladi, hajm saqlanadi', () {
      final File file = File('${dir.path}/plain.sqlite');
      file.writeAsStringSync('DRIVER_PII_SECRET' * 100);
      final int size = file.lengthSync();

      overwriteWithZeros(file);

      expect(file.lengthSync(), size);
      expect(file.readAsBytesSync().any((int b) => b != 0), isFalse);
      expect(file.readAsStringSync(), isNot(contains('DRIVER_PII_SECRET')));
    });

    test('shredFile ustiga yozadi va o\'chiradi', () {
      final File file = File('${dir.path}/plain2.sqlite');
      file.writeAsStringSync('DRIVER_PII_SECRET' * 10);

      shredFile(file);

      expect(file.existsSync(), isFalse);
    });

    test('bo\'sh va mavjud bo\'lmagan fayl xatosiz o\'tadi', () {
      final File missing = File('${dir.path}/nope.sqlite');
      expect(() => shredFile(missing), returnsNormally);

      final File empty = File('${dir.path}/empty.sqlite')..writeAsBytesSync(<int>[]);
      shredFile(empty);
      expect(empty.existsSync(), isFalse);
    });
  });
}
