/// S-M2 / S-L1(M147): DVIR fayl repozitoriysi — katalog va siqish adapteri.
@Timeout(Duration(seconds: 60))
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/dvir/data/dvir_file_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';

/// Siqishni imitatsiya qiladi: baytlarni qisqartiradi va chaqiruvni yozib oladi.
class _RecordingCompressor implements PhotoCompressor {
  int calls = 0;
  int? maxDimension;
  int? quality;

  @override
  Future<Uint8List> compress(
    Uint8List bytes, {
    int maxDimension = kPhotoMaxDimension,
    int quality = kPhotoJpegQuality,
  }) async {
    calls++;
    this.maxDimension = maxDimension;
    this.quality = quality;
    return Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xD9]);
  }
}

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late TimeSource time;
  late Directory base;
  late Directory source;

  setUp(() async {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time;
    base = await Directory.systemTemp.createTemp('dvir_files');
    source = await Directory.systemTemp.createTemp('dvir_source');
  });

  tearDown(() async {
    await time.dispose();
    await db.close();
    for (final Directory dir in <Directory>[base, source]) {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }
  });

  File writePhoto(List<int> bytes) =>
      File('${source.path}/raw.jpg')..writeAsBytesSync(bytes, flush: true);

  test('M147: siqish adapteri EXIF tozalashdan oldin chaqiriladi', () async {
    final _RecordingCompressor compressor = _RecordingCompressor();
    final DriftDvirFileRepository repo = DriftDvirFileRepository(
      dao: db.dvirDao,
      time: time,
      baseDirectory: () async => base,
      compressor: compressor,
    );

    final String path = await repo.enqueuePhoto(writePhoto(<int>[0xFF, 0xD8, 1, 2, 3, 4]).path);

    expect(compressor.calls, 1);
    expect(compressor.maxDimension, kPhotoMaxDimension);
    expect(compressor.quality, kPhotoJpegQuality);
    // Diskka siqilgan baytlar yozildi.
    expect(File(path).readAsBytesSync(), <int>[0xFF, 0xD8, 0xFF, 0xD9]);
  });

  test('standart adapter — o\'tkazib yuboruvchi (paket ulanmagan)', () async {
    final DriftDvirFileRepository repo = DriftDvirFileRepository(
      dao: db.dvirDao,
      time: time,
      baseDirectory: () async => base,
    );

    final String path = await repo.enqueuePhoto(writePhoto(<int>[0xFF, 0xD8, 7, 7]).path);
    expect(File(path).readAsBytesSync(), <int>[0xFF, 0xD8, 7, 7]);
    expect(path, startsWith('${base.path}/dvir_photos/'));
  });

  test('§16: 5 MB dan katta foto rad etiladi', () async {
    final DriftDvirFileRepository repo = DriftDvirFileRepository(
      dao: db.dvirDao,
      time: time,
      baseDirectory: () async => base,
    );

    final File big = writePhoto(List<int>.filled(kMaxPhotoBytes + 1, 0x41));
    await expectLater(repo.enqueuePhoto(big.path), throwsA(isA<PhotoTooLargeException>()));
  });

  test('foto navbatga `dvir_photo` sifatida tushadi', () async {
    final DriftDvirFileRepository repo = DriftDvirFileRepository(
      dao: db.dvirDao,
      time: time,
      baseDirectory: () async => base,
    );

    await repo.enqueuePhoto(writePhoto(<int>[0xFF, 0xD8, 1]).path);
    final List<FileQueueRow> rows = await db.dvirDao.watchPendingFiles().first;
    expect(rows.single.kind, kFileKindDvirPhoto);
    expect(rows.single.state, 'pending');
  });
}
