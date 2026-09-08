/// S-M2: PII fayllari `app_support` da (documents emas) + eski yo'l migratsiyasi.
@Timeout(Duration(seconds: 60))
library;

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/dvir_dao.dart';
import 'package:eld_mobile/core/files/app_file_directories.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

import '../helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late TimeSource time;
  late Directory legacy;
  late Directory support;

  setUp(() async {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time;
    legacy = await Directory.systemTemp.createTemp('legacy_docs');
    support = await Directory.systemTemp.createTemp('app_support');
  });

  tearDown(() async {
    await time.dispose();
    await db.close();
    for (final Directory dir in <Directory>[legacy, support]) {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }
  });

  test('resolveFileBaseDirectory: null → app_support', () {
    expect(resolveFileBaseDirectory(null), same(appFileBaseDirectory));
  });

  test('resolveFileBaseDirectory: eski `documents` standarti → app_support', () {
    // certify/dvir eski standartni uzatsa ham fayl `app_support` ga tushadi.
    expect(resolveFileBaseDirectory(getApplicationDocumentsDirectory), same(appFileBaseDirectory));
  });

  test('resolveFileBaseDirectory: test/maxsus katalog o\'zgarishsiz qoladi', () async {
    Future<Directory> custom() async => support;
    expect(resolveFileBaseDirectory(custom), same(custom));
  });

  test('migratsiya: eski fayllar ko\'chiriladi va navbatdagi yo\'l yangilanadi', () async {
    final Directory oldDir = Directory('${legacy.path}/signatures')..createSync(recursive: true);
    final File oldFile = File('${oldDir.path}/sig.png')..writeAsBytesSync(<int>[1, 2, 3]);
    final DvirDao dao = db.dvirDao;
    await dao.enqueueFile(
      FilesQueueCompanion.insert(
        localPath: oldFile.path,
        kind: 'signature',
        contentType: 'image/png',
        sizeBytes: 3,
        createdAt: t0,
        state: const Value<String>('pending'),
      ),
    );

    final int moved = await migrateLegacyFileDirectories(
      dao: dao,
      legacyBase: () async => legacy,
      base: () async => support,
    );

    expect(moved, 1);
    final File newFile = File('${support.path}/signatures/sig.png');
    expect(newFile.existsSync(), isTrue);
    expect(newFile.readAsBytesSync(), <int>[1, 2, 3]);
    expect(oldFile.existsSync(), isFalse);

    final List<FileQueueRow> rows = await dao.watchPendingFiles().first;
    expect(rows.single.localPath, newFile.path);
  });

  test('migratsiya idempotent — ikkinchi chaqiruv hech narsa qilmaydi', () async {
    Directory('${legacy.path}/dvir_photos').createSync(recursive: true);
    File('${legacy.path}/dvir_photos/a.jpg').writeAsBytesSync(<int>[9]);

    expect(
      await migrateLegacyFileDirectories(
        dao: db.dvirDao,
        legacyBase: () async => legacy,
        base: () async => support,
      ),
      1,
    );
    expect(
      await migrateLegacyFileDirectories(
        dao: db.dvirDao,
        legacyBase: () async => legacy,
        base: () async => support,
      ),
      0,
    );
  });

  test('migratsiya eski katalog yo\'q bo\'lsa yiqilmaydi', () async {
    expect(
      await migrateLegacyFileDirectories(
        dao: db.dvirDao,
        legacyBase: () async => legacy,
        base: () async => support,
      ),
      0,
    );
  });
}
