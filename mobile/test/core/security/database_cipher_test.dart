@Timeout(Duration(seconds: 60))
library;

import 'dart:io';

import 'package:eld_mobile/core/db/connection.dart';
import 'package:eld_mobile/core/db/database_bootstrap.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Xotiradagi `FlutterSecureStorage` — Keychain/Keystore ga tegilmaydi.
class _MemoryStorage implements FlutterSecureStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late SecureVault vault;
  late _MemoryStorage storage;

  setUp(() {
    storage = _MemoryStorage();
    vault = SecureVault(storage: storage);
  });

  test('kalit birinchi murojaatda generatsiya qilinadi va barqaror qoladi', () async {
    final String first = await vault.databaseKey();
    final String second = await vault.databaseKey();

    expect(first.length, 64, reason: '32 bayt hex');
    expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(first), isTrue);
    expect(second, first);
  });

  test('kalit faqat secure storage da (kodda yoki prefs da emas)', () async {
    final String key = await vault.databaseKey();
    expect(storage.values[VaultKeys.databaseKey], key);
  });

  test('ikki qurilma kaliti bir xil emas', () async {
    final String a = await SecureVault(storage: _MemoryStorage()).databaseKey();
    final String b = await SecureVault(storage: _MemoryStorage()).databaseKey();
    expect(a, isNot(b));
  });

  test('shifrlash bayrog\'i faqat aniq belgilanganda `true`', () async {
    expect(await vault.isDatabaseEncrypted(), isFalse);
    await vault.markDatabaseEncrypted();
    expect(await vault.isDatabaseEncrypted(), isTrue);
  });

  test('clearSession kalitni o\'chirmaydi (baza qayta yaratilmaydi)', () async {
    final String key = await vault.databaseKey();
    await vault.markDatabaseEncrypted();

    await vault.clearSession(DriverSlot.primary);

    expect(await vault.databaseKey(), key);
    expect(await vault.isDatabaseEncrypted(), isTrue);
  });

  test('escapeCipherKey SQL literalni buzmaydi', () {
    expect(escapeCipherKey("a'b"), "a''b");
    expect(escapeCipherKey('abc'), 'abc');
  });

  test('SQLCipher build hook orqali ulangan (§17)', () {
    // `pubspec.yaml` → `hooks.user_defines.sqlite3.source: sqlcipher`.
    // Bu tekshiruv yiqilsa — build shifrlanmagan SQLite bilan qurilgan.
    final Database db = sqlite3.openInMemory();
    addTearDown(db.close);
    expect(isCipherActive(db), isTrue, reason: 'PRAGMA cipher_version bo\'sh');
  });

  test('shifrlangan fayl kalitsiz ochilmaydi', () {
    final Directory dir = Directory.systemTemp.createTempSync('eld-cipher');
    addTearDown(() => dir.deleteSync(recursive: true));
    final String path = '${dir.path}/enc.sqlite';
    final String key = 'f' * 64;

    final Database created = sqlite3.open(path);
    applyCipherKey(created, key, requireCipher: true);
    created
      ..execute('CREATE TABLE t (v TEXT)')
      ..execute("INSERT INTO t VALUES ('secret')")
      ..close();

    // Kalitsiz — SQLCipher faylni o'qiy olmaydi.
    final Database wrong = sqlite3.open(path);
    addTearDown(wrong.close);
    expect(() => wrong.select('SELECT v FROM t'), throwsA(isA<SqliteException>()));

    // To'g'ri kalit bilan — ma'lumot joyida.
    final Database right = sqlite3.open(path);
    addTearDown(right.close);
    applyCipherKey(right, key);
    expect(right.select('SELECT v FROM t').single.values.single, 'secret');
  });

  test('migratsiya: shifrlanmagan baza yo\'qotishsiz ko\'chiriladi (M-DB1)', () {
    final Directory dir = Directory.systemTemp.createTempSync('eld-plain');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File file = File('${dir.path}/eld_local.sqlite');
    final String key = 'a' * 64;

    // Eski, shifrlanmagan baza (outbox elementi bilan).
    final Database plain = sqlite3.open(file.path);
    plain
      ..execute('CREATE TABLE outbox_items (client_id TEXT)')
      ..execute("INSERT INTO outbox_items VALUES ('queued-event')")
      ..close();

    final CipherMigration result = migratePlaintextDatabase(file: file, key: key);
    expect(result, CipherMigration.migrated);

    // Fayl endi shifrlangan: kalitsiz o'qilmaydi.
    final Database wrong = sqlite3.open(file.path);
    addTearDown(wrong.close);
    expect(() => wrong.select('SELECT * FROM outbox_items'), throwsA(isA<SqliteException>()));

    // Kalit bilan — «0 event yo'qotish»: navbat joyida.
    final Database migrated = sqlite3.open(file.path);
    addTearDown(migrated.close);
    applyCipherKey(migrated, key);
    expect(
      migrated.select('SELECT client_id FROM outbox_items').single.values.single,
      'queued-event',
    );
  });
}
