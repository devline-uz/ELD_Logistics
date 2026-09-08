// M174 — golden vektor fayli ikkala tomonning kontrakti. Hash mos kelmasa
// build to'xtaydi.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

import 'vectors.dart';

void main() {
  test('backend fayl mavjud va kanonik manba', () {
    final backend = File(backendVectorPath);
    expect(
      backend.existsSync(),
      isTrue,
      reason: 'yagona manba backend/internal/hos/testdata/hos-test-vectors.json',
    );
  });

  test('SHA-256 qulfi faylga mos', () {
    final src = loadVectors();
    final lock = File(vectorLockPath).readAsStringSync().trim();
    expect(src.sha256, lock);
    expect(src.version, 1);
    expect(src.vectors.length, 35);
  });

  test('backend va sinxronlangan nusxa bir xil', () {
    final a = sha256.convert(File(backendVectorPath).readAsBytesSync()).toString();
    final b = sha256.convert(File(syncedVectorPath).readAsBytesSync()).toString();
    expect(a, b, reason: 'tool/sync_vectors.sh ni qayta ishga tushiring');
  });

  test('o\'zgargan fayl hash tekshiruvini yiqitadi', () {
    // Kontrakt buzilishini simulyatsiya qilamiz: bir bayt o'zgarsa hash boshqa.
    final bytes = File(syncedVectorPath).readAsBytesSync();
    final tampered = List<int>.of(bytes)..[0] = bytes[0] ^ 0x20;
    final lock = File(vectorLockPath).readAsStringSync().trim();
    expect(sha256.convert(tampered).toString(), isNot(lock));
  });

  test('har bir vektorda majburiy maydonlar bor', () {
    for (final v in loadVectors().vectors) {
      expect(v['name'], isA<String>());
      expect(v['timezone'], isA<String>());
      expect(v['now'], isA<String>());
      expect(v['events'], isA<List<dynamic>>());
      final expect_ = (v['expect'] as Map).cast<String, dynamic>();
      for (final key in <String>['counters', 'totals', 'violations']) {
        expect(expect_.containsKey(key), isTrue, reason: '${v['name']}.$key');
      }
      final counters = (expect_['counters'] as Map).cast<String, dynamic>();
      for (final key in <String>[
        'break_left_min',
        'drive_left_min',
        'shift_left_min',
        'cycle_left_min',
      ]) {
        expect(counters[key], isA<int>(), reason: '${v['name']}.$key');
      }
    }
  });

  test('vektor fayli JSON sifatida qayta o\'qiladi', () {
    final raw = File(syncedVectorPath).readAsStringSync();
    expect(jsonDecode(raw), isA<Map<String, dynamic>>());
  });
}
