@Timeout(Duration(seconds: 60))
/// **S-M4 / #B-130** — `SessionDataCleaner` login/logout oqimiga **ulangan**.
///
/// Ilgari tozalovchi yozilgan-u, hech qayerdan chaqirilmasdi: boshqa haydovchi
/// kirganda oldingi haydovchining loglari, chati va bildirishnomalari ekranda
/// ko'rinib turardi. Bu yerdagi testlar aynan **chaqiruvni** tekshiradi.
///
/// **M17 [MUST]:** yuborilmagan (`pending`) navbat va unga bog'langan yozuvlar
/// hech qanday holatda o'chirilmaydi.
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/db/kv_store.dart';
import 'package:eld_mobile/core/security/active_slot.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/session/session_profile.dart';
import 'package:eld_mobile/features/auth/data/auth_providers.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

const MethodChannel _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

/// `flutter_secure_storage` platforma kanali o'rniga xotiradagi «disk».
void _installMockSecureStorage() {
  final Map<String, String> values = <String, String>{};
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    _secureStorageChannel,
    (MethodCall call) async {
      final Map<Object?, Object?> args =
          (call.arguments as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
      final String key = args['key'] as String? ?? '';
      switch (call.method) {
        case 'read':
          return values[key];
        case 'write':
          values[key] = args['value'] as String? ?? '';
          return null;
        case 'delete':
          values.remove(key);
          return null;
        case 'readAll':
          return Map<String, String>.from(values);
        case 'deleteAll':
          values.clear();
          return null;
        case 'containsKey':
          return values.containsKey(key);
      }
      return null;
    },
  );
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late ProviderContainer container;
  late SessionManager manager;

  setUp(() {
    _installMockSecureStorage();
    db = AppDatabase.memory();
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        secureVaultProvider.overrideWithValue(SecureVault()),
        activeSlotHolderProvider.overrideWithValue(ActiveSlotHolder()),
        // Bootstrap'dagi kabi: sessiya profili aynan `kv_settings` ga yoziladi
        // — tozalovchi oldingi `driver_id` ni shu yerdan o'qiydi.
        kvStoreProvider.overrideWithValue(DriftKvStore(settings: db.settingsDao, now: () => t0)),
      ],
    );
    manager = container.read(sessionManagerProvider.notifier);
    addTearDown(() async {
      container.dispose();
      // Provayderlarning fon o'qishlari tugasin, keyin baza yopiladi.
      await Future<void>.delayed(Duration.zero);
      await db.close();
    });
  });

  /// A haydovchining lokal ma'lumoti: ko'zgu qatorlari + **yuborilmagan**
  /// navbat elementi va uning duty event ko'zgusi.
  Future<void> seedDriverA() async {
    await db.settingsDao.put(key: KvKeys.driverId, value: 'drv-a', now: t0);
    await db.settingsDao.put(key: KvKeys.driverEmail, value: 'a@example.com', now: t0);
    await db
        .into(db.dailyLogs)
        .insert(
          DailyLogsCompanion.insert(
            logDate: '2026-09-06',
            driverId: 'drv-a',
            timezone: 'America/Chicago',
            updatedAt: t0,
          ),
        );
    await db
        .into(db.chatMessages)
        .insert(
          ChatMessagesCompanion.insert(
            id: 'm1',
            conversationId: const Value<String?>('c1'),
            kind: 'text',
            body: const Value<String?>('salom'),
            createdAt: t0,
          ),
        );
    await db
        .into(db.outboxItems)
        .insert(
          OutboxItemsCompanion.insert(
            kind: OutboxKind.event.wire,
            payload: '{}',
            clientId: 'cid-pending',
            deviceSeq: 1,
            createdAt: t0,
            nextAttemptAt: t0,
            updatedAt: t0,
            state: Value<String>(OutboxState.pending.wire),
          ),
        );
    await db
        .into(db.dutyEvents)
        .insert(
          DutyEventsCompanion.insert(
            clientEventId: 'cid-pending',
            eventType: 'status_change',
            eventTime: t0,
            deviceSeq: 1,
            createdAt: t0,
            driverId: const Value<String?>('drv-a'),
          ),
        );
  }

  Future<int> countDailyLogs() async => (await db.select(db.dailyLogs).get()).length;

  Future<int> countChat() async => (await db.select(db.chatMessages).get()).length;

  Future<int> countOutbox() async => (await db.select(db.outboxItems).get()).length;

  Future<int> countDutyEvents() async => (await db.select(db.dutyEvents).get()).length;

  test('boshqa haydovchi login qilsa A ning loglari qolmaydi, navbati qoladi', () async {
    await seedDriverA();

    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-b', driverName: 'Bob');

    expect(await countDailyLogs(), 0, reason: 'A ning kunlik loglari ko\'rinmasligi kerak (S-M4)');
    expect(await countChat(), 0, reason: 'A ning chati ko\'rinmasligi kerak (S-M4)');
    // M17: yuborilmagan navbat va uning ko'zgusi joyida.
    expect(await countOutbox(), 1, reason: 'pending outbox hech qachon o\'chmaydi (M17)');
    expect(await countDutyEvents(), 1, reason: 'navbatga bog\'langan event qoladi (M17)');
    // Yangi haydovchi profili yozildi, A ning PII si qolmadi.
    expect(await db.settingsDao.get(KvKeys.driverId), 'drv-b');
    expect(await db.settingsDao.get(KvKeys.driverEmail), isNull);
    expect(container.read(sessionProfileProvider).driverEmail, isNull);
  });

  test('o\'sha haydovchi qayta kirsa hech narsa o\'chmaydi', () async {
    await seedDriverA();

    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-a', driverName: 'Ann');

    expect(await countDailyLogs(), 1);
    expect(await countChat(), 1);
    expect(await db.settingsDao.get(KvKeys.driverEmail), 'a@example.com');
  });

  test('co-driver ikkinchi slotga kirsa asosiy haydovchi ma\'lumoti tegilmaydi', () async {
    await seedDriverA();
    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-a', driverName: 'Ann');

    await manager.signIn(slot: DriverSlot.coDriver, driverId: 'drv-b', driverName: 'Bob');

    expect(await countDailyLogs(), 1, reason: 'kabinadagi ikkinchi haydovchi — almashuv emas');
    expect(await countChat(), 1);
    expect(await countOutbox(), 1);
  });

  test('to\'liq signOut domen ma\'lumotini tozalaydi, navbatni saqlaydi', () async {
    await seedDriverA();
    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-a', driverName: 'Ann');

    await manager.signOut(DriverSlot.primary);

    expect(await countDailyLogs(), 0);
    expect(await countChat(), 0);
    expect(await countOutbox(), 1, reason: 'M17: chiqishda ham navbat saqlanadi');
    expect(await countDutyEvents(), 1);
    expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
  });

  test('co-driver chiqsa faol haydovchining ma\'lumoti o\'chmaydi', () async {
    await seedDriverA();
    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-a', driverName: 'Ann');
    await manager.signIn(slot: DriverSlot.coDriver, driverId: 'drv-b', driverName: 'Bob');
    // `M-20` oqimi: faol slot yana asosiy haydovchida.
    await manager.switchDrivers();

    await manager.signOut(DriverSlot.coDriver);

    expect(await countDailyLogs(), 1);
    expect(container.read(sessionManagerProvider).active.driverId, 'drv-a');
  });
}
