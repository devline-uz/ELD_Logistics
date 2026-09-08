@Timeout(Duration(seconds: 60))
/// **M9** — ikki sessiya menejeri: `SecureVault` ga yozish, faol slotni
/// `ActiveSlotHolder` ga uzatish va `SlotInterceptor` orqali so'rovga muhrlash.
///
/// `flutter_secure_storage` platforma kanali test uchun xotiradagi xarita
/// bilan almashtiriladi — Keychain/Keystore ga umuman tegilmaydi.
library;

import 'package:dio/dio.dart';
import 'package:eld_mobile/core/network/request_options_x.dart';
import 'package:eld_mobile/core/network/slot_interceptor.dart';
import 'package:eld_mobile/core/security/active_slot.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/features/auth/data/auth_providers.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:eld_mobile/features/auth/data/session_store.dart';
import 'package:eld_mobile/features/auth/domain/session_policy.dart';
import 'package:eld_mobile/features/auth/domain/session_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// `flutter_secure_storage` ning platforma kanali (11.x).
const MethodChannel _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

/// Kanal javoblarini beradigan xotiradagi «disk».
Map<String, String> _installMockSecureStorage() {
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
  return values;
}

ProviderContainer _container(SecureVault vault, ActiveSlotHolder holder) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      secureVaultProvider.overrideWithValue(vault),
      activeSlotHolderProvider.overrideWithValue(holder),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> storage;
  late SecureVault vault;
  late ActiveSlotHolder holder;

  setUp(() {
    storage = _installMockSecureStorage();
    vault = SecureVault();
    holder = ActiveSlotHolder();
  });

  test('signIn holatni `SecureVault` ga yozadi va faol slotni uzatadi', () async {
    final ProviderContainer container = _container(vault, holder);
    final SessionManager manager = container.read(sessionManagerProvider.notifier);

    await manager.signIn(
      slot: DriverSlot.primary,
      driverId: 'drv-1',
      driverName: 'John Smith',
      sessionId: 'sess-1',
    );

    expect(holder.value, DriverSlot.primary);
    expect(storage[VaultKeys.sessionSlots], isNotNull);
    expect(container.read(sessionManagerProvider).primary.isActive, isTrue);
  });

  test('ikkinchi login co-driver slotiga tushadi, ikkala token kaliti alohida', () async {
    final ProviderContainer container = _container(vault, holder);
    final SessionManager manager = container.read(sessionManagerProvider.notifier);

    await vault.writeRefreshToken(DriverSlot.primary, 'rt-primary');
    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-1', driverName: 'John');
    await vault.writeRefreshToken(DriverSlot.coDriver, 'rt-co');
    await manager.signIn(slot: DriverSlot.coDriver, driverId: 'drv-2', driverName: 'Maria');

    expect(await vault.readRefreshToken(DriverSlot.primary), 'rt-primary');
    expect(await vault.readRefreshToken(DriverSlot.coDriver), 'rt-co');
    expect(holder.value, DriverSlot.coDriver);
  });

  test('switchDrivers bo\'sh co-driver da bloklanadi', () async {
    final ProviderContainer container = _container(vault, holder);
    final SessionManager manager = container.read(sessionManagerProvider.notifier);

    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-1', driverName: 'John');

    expect(await manager.switchDrivers(), SwitchBlockReason.noCoDriver);
    expect(holder.value, DriverSlot.primary);
  });

  test('switchDrivers faol slotni almashtiradi va holderga yozadi', () async {
    final ProviderContainer container = _container(vault, holder);
    final SessionManager manager = container.read(sessionManagerProvider.notifier);

    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-1', driverName: 'John');
    await manager.signIn(slot: DriverSlot.coDriver, driverId: 'drv-2', driverName: 'Maria');

    expect(await manager.switchDrivers(), isNull);
    expect(holder.value, DriverSlot.primary);
    expect(container.read(sessionManagerProvider).active.driverId, 'drv-1');
  });

  test('leaveTruck: co-driver bo\'lsa u faol bo\'ladi, refresh token saqlanadi', () async {
    final ProviderContainer container = _container(vault, holder);
    final SessionManager manager = container.read(sessionManagerProvider.notifier);

    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-1', driverName: 'John');
    await manager.signIn(slot: DriverSlot.coDriver, driverId: 'drv-2', driverName: 'Maria');
    await vault.writeRefreshToken(DriverSlot.coDriver, 'rt-co');

    expect(await manager.leaveTruck(), LeaveTruckOutcome.coDriverPromoted);
    expect(holder.value, DriverSlot.primary);
    // M18: pauzada refresh token TIRIK qoladi.
    expect(await vault.readRefreshToken(DriverSlot.coDriver), 'rt-co');
  });

  test('signOut tokenni o\'chiradi, boshqa slot tegilmaydi (M17)', () async {
    final ProviderContainer container = _container(vault, holder);
    final SessionManager manager = container.read(sessionManagerProvider.notifier);

    await manager.signIn(slot: DriverSlot.primary, driverId: 'drv-1', driverName: 'John');
    await vault.writeRefreshToken(DriverSlot.primary, 'rt-primary');
    await manager.signIn(slot: DriverSlot.coDriver, driverId: 'drv-2', driverName: 'Maria');
    await vault.writeRefreshToken(DriverSlot.coDriver, 'rt-co');

    await manager.signOut(DriverSlot.primary);

    expect(await vault.readRefreshToken(DriverSlot.primary), isNull);
    expect(await vault.readRefreshToken(DriverSlot.coDriver), 'rt-co');
    expect(container.read(sessionManagerProvider).isSignedOut, isFalse);
  });

  test('restore: ilova qayta ochilganda holat diskdan tiklanadi', () async {
    final SessionStore store = SessionStore(vault);
    await store.write(
      SessionPolicy.signIn(
        const DualSessionState.signedOut(),
        slot: DriverSlot.primary,
        driverId: 'drv-1',
        driverName: 'John Smith',
      ),
    );

    final ProviderContainer container = _container(vault, holder);
    final SessionManager manager = container.read(sessionManagerProvider.notifier);
    await manager.restore();

    expect(container.read(sessionManagerProvider).primary.driverId, 'drv-1');
    expect(holder.value, DriverSlot.primary);
  });

  test('buzilgan JSON ilovani yiqitmaydi', () async {
    storage[VaultKeys.sessionSlots] = 'not-json';

    final ProviderContainer container = _container(vault, holder);
    await container.read(sessionManagerProvider.notifier).restore();

    expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
  });

  group('SlotInterceptor (M9)', () {
    test('slot berilmagan so\'rovga faol slot muhrlanadi', () {
      holder.value = DriverSlot.coDriver;
      final RequestOptions options = RequestOptions(path: '/me');

      SlotInterceptor(holder).onRequest(options, RequestInterceptorHandler());

      expect(options.slot, DriverSlot.coDriver);
    });

    test('aniq berilgan slot ustidan yozilmaydi', () {
      holder.value = DriverSlot.coDriver;
      final RequestOptions options = RequestOptions(
        path: '/auth/refresh',
        extra: <String, Object?>{RequestExtra.slot: DriverSlot.primary},
      );

      SlotInterceptor(holder).onRequest(options, RequestInterceptorHandler());

      expect(options.slot, DriverSlot.primary);
    });
  });
}
