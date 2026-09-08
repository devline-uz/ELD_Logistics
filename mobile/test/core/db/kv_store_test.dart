@Timeout(Duration(seconds: 60))
library;

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:eld_mobile/core/db/kv_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryKvStore', () {
    test('bo\'sh qiymatlar yozilmaydi (mavjudini o\'chirmasin)', () async {
      final InMemoryKvStore store = InMemoryKvStore(<String, String>{
        KvKeys.driverName: 'Ali Karimov',
      });

      await store.writeAll(<String, String?>{
        KvKeys.driverName: '',
        KvKeys.unitNumber: null,
        KvKeys.carrierName: 'Onebook LLC',
      });

      expect(await store.read(KvKeys.driverName), 'Ali Karimov');
      expect(await store.read(KvKeys.unitNumber), isNull);
      expect(await store.read(KvKeys.carrierName), 'Onebook LLC');
    });

    test('readAll faqat bo\'sh bo\'lmagan kalitlarni qaytaradi', () async {
      final InMemoryKvStore store = InMemoryKvStore(<String, String>{
        KvKeys.driverId: 'd-1',
        KvKeys.driverName: '',
      });

      final Map<String, String> values = await store.readAll(KvKeys.sessionProfile);
      expect(values, <String, String>{KvKeys.driverId: 'd-1'});
    });
  });

  group('DriftKvStore', () {
    late AppDatabase db;
    final DateTime now = DateTime.utc(2026, 9, 7, 12);

    setUp(() => db = AppDatabase.memory());
    tearDown(() => db.close());

    test('kv_settings ga yozadi va qayta o\'qiydi', () async {
      final DriftKvStore store = DriftKvStore(settings: db.settingsDao, now: () => now);

      await store.writeAll(<String, String?>{
        KvKeys.driverId: 'driver-1',
        KvKeys.unitNumber: '1021',
        KvKeys.vehicleLabel: null,
      });

      expect(await store.read(KvKeys.driverId), 'driver-1');
      expect(await db.settingsDao.get(KvKeys.unitNumber), '1021');
      expect(await store.read(KvKeys.vehicleLabel), isNull);
    });

    test('takroriy yozuv qiymatni yangilaydi', () async {
      final DriftKvStore store = DriftKvStore(settings: db.settingsDao, now: () => now);
      await store.write(KvKeys.themeMode, 'dark');
      await store.write(KvKeys.themeMode, 'light');
      expect(await store.read(KvKeys.themeMode), 'light');
    });
  });
}
