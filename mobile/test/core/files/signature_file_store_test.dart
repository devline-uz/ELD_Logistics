@Timeout(Duration(seconds: 60))
/// #B-33: imzo saqlash yagona joyda — certify va DVIR bir xil natija beradi.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/dvir_dao.dart';
import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:eld_mobile/core/files/file_upload.dart';
import 'package:eld_mobile/core/files/signature_file_store.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/certify/data/certify_repository_impl.dart';
import 'package:eld_mobile/features/dvir/data/dvir_file_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);
  final Uint8List png = Uint8List.fromList(<int>[0x89, 0x50, 0x4E, 0x47, 1, 2, 3]);

  late AppDatabase db;
  late TimeSource time;
  late Directory base;

  setUp(() async {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time;
    base = await Directory.systemTemp.createTemp('sig_store_test');
  });

  tearDown(() async {
    await time.dispose();
    await db.close();
    if (base.existsSync()) {
      base.deleteSync(recursive: true);
    }
  });

  Future<List<FileQueueRow>> queue() => DvirDao(db).watchPendingFiles().first;

  test('PNG `<docs>/signatures/<uuid>.png` ga yoziladi va navbatga tushadi', () async {
    final SignatureFileStore store = SignatureFileStore(
      files: DvirDao(db),
      time: time,
      baseDirectory: () async => base,
    );

    final String path = await store.enqueue(png);

    expect(File(path).existsSync(), isTrue);
    expect(File(path).readAsBytesSync(), png);
    expect(path, startsWith('${base.path}/signatures/'));
    expect(path, endsWith('.png'));

    final List<FileQueueRow> rows = await queue();
    expect(rows, hasLength(1));
    expect(rows.single.localPath, path);
    expect(rows.single.kind, FileKind.signature.wire);
    expect(rows.single.contentType, 'image/png');
    expect(rows.single.sizeBytes, png.length);
    expect(rows.single.state, 'pending');
    expect(rows.single.createdAt, t0);
  });

  test('certify va DVIR bir xil `kind` va papkani ishlatadi (dublikat yo\'q)', () async {
    final DriftSignatureStore certify = DriftSignatureStore(
      files: DvirDao(db),
      settings: SettingsDao(db),
      time: time,
      baseDirectory: () async => base,
    );
    final DriftDvirFileRepository dvir = DriftDvirFileRepository(
      dao: DvirDao(db),
      time: time,
      baseDirectory: () async => base,
    );

    final String certifyPath = await certify.enqueue(png, remember: false);
    final String dvirPath = await dvir.enqueueSignature(png);

    final List<FileQueueRow> rows = await queue();
    expect(rows, hasLength(2));
    expect(rows.map((FileQueueRow r) => r.kind).toSet(), <String>{FileKind.signature.wire});
    expect(rows.map((FileQueueRow r) => r.contentType).toSet(), <String>{'image/png'});
    for (final String path in <String>[certifyPath, dvirPath]) {
      expect(path, startsWith('${base.path}/signatures/'));
    }
    expect(kCertifySignatureKind, kSignatureFileKind);
    expect(kFileKindSignature, kSignatureFileKind);
  });

  test('`remember: true` saqlangan imzo yo\'lini `kv_settings` ga yozadi', () async {
    final DriftSignatureStore certify = DriftSignatureStore(
      files: DvirDao(db),
      settings: SettingsDao(db),
      time: time,
      baseDirectory: () async => base,
    );

    final String path = await certify.enqueue(png, remember: true);
    expect(await certify.savedSignaturePath(), path);

    final String other = await certify.enqueue(png, remember: false);
    expect(await certify.savedSignaturePath(), path);
    expect(other, isNot(path));
  });
}
